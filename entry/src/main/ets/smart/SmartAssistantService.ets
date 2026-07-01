import { askDeepSeekWithSystem } from './DeepSeekService';
import { createDraftActions } from './SmartPromptParser';
import { SmartActionExtraSpec, SmartActionSpec, SmartAssistantReply, SmartPromptDraft, SmartTriggerSpec } from './SmartModels';

interface SmartDeviceCatalogItem {
  pointId: string;
  roomName: string;
  deviceName: string;
  action: string;
}

interface LlmTriggerPayload {
  type?: string;
  label?: string;
  time?: string;
  weekday?: string;
  sceneId?: string;
  roomId?: string;
}

interface LlmActionPayload {
  pointId?: string;
  command?: string;
  value?: number;
  label?: string;
}

interface LlmIntentPayload {
  intent?: string;
  title?: string;
  response?: string;
  automation?: boolean;
  trigger?: LlmTriggerPayload;
  actions?: LlmActionPayload[];
}

const SMART_DEVICE_CATALOG: SmartDeviceCatalogItem[] = [
  { pointId: 'living_air', roomName: '客厅', deviceName: '空调', action: 'temperature' },
  { pointId: 'living_curtain', roomName: '客厅', deviceName: '窗帘', action: 'curtain' },
  { pointId: 'living_tv', roomName: '客厅', deviceName: '电视', action: 'toggle' },
  { pointId: 'living_purifier', roomName: '客厅', deviceName: '空气净化器', action: 'toggle' },
  { pointId: 'living_robot', roomName: '客厅', deviceName: '扫地机器人', action: 'toggle' },
  { pointId: 'living_light', roomName: '客厅', deviceName: '灯', action: 'light' },
  { pointId: 'bedroom_air', roomName: '卧室', deviceName: '空调', action: 'temperature' },
  { pointId: 'bedroom_curtain', roomName: '卧室', deviceName: '窗帘', action: 'curtain' },
  { pointId: 'bedroom_left_light', roomName: '卧室', deviceName: '左床头灯', action: 'light' },
  { pointId: 'bedroom_right_light', roomName: '卧室', deviceName: '右床头灯', action: 'light' },
  { pointId: 'bedroom_robot', roomName: '卧室', deviceName: '扫地机器人', action: 'toggle' },
  { pointId: 'bedroom_door', roomName: '卧室', deviceName: '门锁', action: 'toggle' }
];

const SMART_INTENT_SYSTEM_PROMPT: string =
  '你是智能家居前端的指令识别层。你的任务是把用户输入识别为 JSON，不能输出 Markdown、解释或代码块。' +
    '如果用户是在控制家居设备、创建自动化、描述场景联动，intent 必须是 smart_home；如果是普通聊天或提问，intent 是 chat 并在 response 中直接简短回答。' +
    '只允许输出这个 JSON 结构：{"intent":"smart_home|chat|unsupported","title":"短标题","response":"给用户看的中文回复","automation":false,"trigger":{"type":"manual|time|weekly|presence|scene","label":"触发条件","time":"HH:mm","weekday":"周一"},"actions":[{"pointId":"设备点位","command":"on|off|set","value":数字,"label":"动作说明"}]}。' +
    '设备点位白名单：living_air 客厅空调，living_curtain 客厅窗帘，living_tv 客厅电视，living_purifier 客厅空气净化器，living_robot 客厅扫地机器人，living_light 客厅灯，bedroom_air 卧室空调，bedroom_curtain 卧室窗帘，bedroom_left_light 卧室左床头灯，bedroom_right_light 卧室右床头灯，bedroom_robot 卧室扫地机器人，bedroom_door 卧室门锁。' +
    '多指令要拆成多个 actions 并保持顺序。灯光和窗帘的 set value 是 0-100 百分比，空调 set value 是 16-30 摄氏度。开灯、开电视、启动扫地机器人、开启净化器用 on；关闭或暂停用 off。窗帘打开可用 set 100，关闭可用 set 0。门锁上锁用 on，解锁用 off。' +
    '如果有“每天、每周、离家、回家、几点”等触发条件，automation 为 true；立即执行则 automation 为 false 且 trigger.type 为 manual。无法确定设备时 intent 用 unsupported，actions 为空。';

function extractJsonObject(content: string): string {
  const start = content.indexOf('{');
  const end = content.lastIndexOf('}');
  if (start < 0 || end <= start) {
    return '';
  }
  return content.substring(start, end + 1);
}

function parseLlmIntent(content: string): LlmIntentPayload | undefined {
  const jsonText = extractJsonObject(content);
  if (jsonText.length === 0) {
    return undefined;
  }
  try {
    return JSON.parse(jsonText) as LlmIntentPayload;
  } catch {
    return undefined;
  }
}

function catalogItemByPointId(pointId: string): SmartDeviceCatalogItem | undefined {
  for (let i = 0; i < SMART_DEVICE_CATALOG.length; i++) {
    if (SMART_DEVICE_CATALOG[i].pointId === pointId) {
      return SMART_DEVICE_CATALOG[i];
    }
  }
  return undefined;
}

function normalizeCommand(command: string | undefined): string {
  if (command === undefined) {
    return '';
  }
  const lower = command.toLowerCase();
  if (lower === 'on' || lower === 'open' || lower === 'start' || lower === 'lock') {
    return 'on';
  }
  if (lower === 'off' || lower === 'close' || lower === 'stop' || lower === 'pause' || lower === 'unlock') {
    return 'off';
  }
  if (lower === 'set') {
    return 'set';
  }
  return '';
}

function clamp(value: number, min: number, max: number): number {
  if (value < min) {
    return min;
  }
  if (value > max) {
    return max;
  }
  return value;
}

function normalizedValue(item: SmartDeviceCatalogItem, command: string, value: number | undefined): number | undefined {
  if (command !== 'set') {
    return undefined;
  }
  if (value === undefined || Number.isNaN(value)) {
    if (item.action === 'curtain') {
      return 100;
    }
    return undefined;
  }
  if (item.action === 'temperature') {
    return clamp(Math.round(value), 16, 30);
  }
  if (item.action === 'curtain' || item.action === 'light') {
    return clamp(Math.round(value), 0, 100);
  }
  return value > 0 ? 100 : 0;
}

function normalizeAction(payload: LlmActionPayload): SmartActionSpec | undefined {
  if (payload.pointId === undefined) {
    return undefined;
  }
  const item = catalogItemByPointId(payload.pointId);
  if (item === undefined) {
    return undefined;
  }
  let command = normalizeCommand(payload.command);
  const value = normalizedValue(item, command, payload.value);
  if (command.length === 0) {
    return undefined;
  }
  if (item.action === 'temperature' && (command === 'on' || command === 'off')) {
    command = command;
  } else if ((item.action === 'curtain' || item.action === 'light') && command === 'set' && value === 0) {
    command = 'set';
  } else if (item.action === 'toggle' && command === 'set') {
    command = value === undefined || value > 0 ? 'on' : 'off';
  }

  const extra: SmartActionExtraSpec = {
    source: 'llm_intent',
    roomName: item.roomName,
    deviceName: item.deviceName
  };

  return {
    pointId: item.pointId,
    command: command,
    value: command === 'set' ? value : undefined,
    label: payload.label !== undefined && payload.label.length > 0 ? payload.label : buildActionLabel(item, command, value),
    extra: extra
  };
}

function buildActionLabel(item: SmartDeviceCatalogItem, command: string, value?: number): string {
  const name = `${item.roomName}${item.deviceName}`;
  if (command === 'on') {
    if (item.pointId === 'bedroom_door') {
      return `${name}上锁`;
    }
    return `${name}开启`;
  }
  if (command === 'off') {
    if (item.pointId === 'bedroom_door') {
      return `${name}解锁`;
    }
    if (item.pointId.indexOf('robot') >= 0) {
      return `${name}暂停`;
    }
    return `${name}关闭`;
  }
  if (item.action === 'temperature' && value !== undefined) {
    return `${name}调到 ${value}°C`;
  }
  if ((item.action === 'curtain' || item.action === 'light') && value !== undefined) {
    return `${name}调到 ${value}%`;
  }
  return `${name}执行设置`;
}

function normalizeTrigger(payload: LlmTriggerPayload | undefined, automation: boolean | undefined): SmartTriggerSpec {
  if (payload === undefined) {
    return {
      type: automation === true ? 'manual' : 'manual',
      label: '手动执行'
    };
  }
  const type = payload.type === 'time' || payload.type === 'weekly' || payload.type === 'presence' || payload.type === 'scene' ? payload.type : 'manual';
  return {
    type: type,
    label: payload.label !== undefined && payload.label.length > 0 ? payload.label : (type === 'manual' ? '手动执行' : '智能触发'),
    time: payload.time,
    weekday: payload.weekday,
    sceneId: payload.sceneId,
    roomId: payload.roomId
  };
}

function normalizeActions(payload: LlmIntentPayload): SmartActionSpec[] {
  const actions: SmartActionSpec[] = [];
  if (payload.actions === undefined || !Array.isArray(payload.actions)) {
    return actions;
  }
  for (let i = 0; i < payload.actions.length; i++) {
    const action = normalizeAction(payload.actions[i]);
    if (action !== undefined) {
      actions.push(action);
    }
  }
  return actions;
}

function actionSummary(actions: SmartActionSpec[]): string {
  const labels: string[] = [];
  for (let i = 0; i < actions.length; i++) {
    labels.push(actions[i].label);
  }
  return labels.join('，');
}

function buildDraft(prompt: string, payload: LlmIntentPayload): SmartPromptDraft {
  const triggerSpec = normalizeTrigger(payload.trigger, payload.automation);
  let actions = normalizeActions(payload);
  if (actions.length === 0) {
    actions = createDraftActions(prompt);
  }
  const actionText = actionSummary(actions);
  const shouldCreateAutomation = payload.automation === true || triggerSpec.type !== 'manual';
  return {
    title: payload.title !== undefined && payload.title.length > 0 ? payload.title : (shouldCreateAutomation ? '智能自动化脚本' : '智能执行方案'),
    trigger: triggerSpec.label,
    action: actionText.length > 0 ? actionText : prompt,
    shouldCreateAutomation: shouldCreateAutomation,
    triggerSpec: triggerSpec,
    actions: actions,
    response: payload.response !== undefined && payload.response.length > 0 ? payload.response : (
      shouldCreateAutomation ?
        `我已整理出触发条件“${triggerSpec.label}”，并生成 ${actions.length} 个设备动作。` :
        `我已识别出 ${actions.length} 个设备动作：${actionText}。`
    )
  };
}

export async function resolveSmartAssistantPrompt(prompt: string): Promise<SmartAssistantReply> {
  const answer = await askDeepSeekWithSystem(SMART_INTENT_SYSTEM_PROMPT, prompt, 0.1);
  if (!answer.ok) {
    return {
      mode: 'llm',
      title: '智能识别未连接',
      detail: answer.content,
      ok: false
    };
  }

  const payload = parseLlmIntent(answer.content);
  if (payload === undefined || payload.intent === undefined) {
    return {
      mode: 'llm',
      title: '智能识别失败',
      detail: '没有解析到有效的 JSON 指令，请稍后重试。',
      ok: false
    };
  }

  if (payload.intent === 'chat') {
    return {
      mode: 'llm',
      title: payload.title !== undefined && payload.title.length > 0 ? payload.title : 'DeepSeek',
      detail: payload.response !== undefined && payload.response.length > 0 ? payload.response : '我已收到。',
      ok: true
    };
  }

  if (payload.intent !== 'smart_home') {
    return {
      mode: 'llm',
      title: payload.title !== undefined && payload.title.length > 0 ? payload.title : '暂未识别设备',
      detail: payload.response !== undefined && payload.response.length > 0 ? payload.response : '这条指令暂时没有匹配到可控制的设备。',
      ok: false
    };
  }

  const draft = buildDraft(prompt, payload);
  return {
    mode: 'smart_home',
    title: draft.shouldCreateAutomation ? '智能助手已生成自动化草稿' : '智能助手已生成执行方案',
    detail: draft.response,
    draft: draft,
    ok: true
  };
}
