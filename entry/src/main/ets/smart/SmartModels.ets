export interface AgentSuggestionSpec {
  id: string;
  label: string;
  prompt: string;
}

export interface AgentRecordSpec {
  id: string;
  title: string;
  detail: string;
  time: string;
  status: string;
}

export interface SmartTriggerSpec {
  type: string;
  label: string;
  time?: string;
  weekday?: string;
  sceneId?: string;
  roomId?: string;
}

export interface SmartActionSpec {
  pointId: string;
  command: string;
  label: string;
  value?: number;
  extra?: SmartActionExtraSpec;
}

export interface SmartActionExtraSpec {
  source?: string;
  label?: string;
  roomName?: string;
  deviceName?: string;
}

export interface SmartPromptDraft {
  title: string;
  trigger: string;
  action: string;
  shouldCreateAutomation: boolean;
  triggerSpec: SmartTriggerSpec;
  actions: SmartActionSpec[];
  response: string;
}

export interface SmartAssistantReply {
  mode: string;
  title: string;
  detail: string;
  draft?: SmartPromptDraft;
  ok: boolean;
}

export interface AutomationSpec {
  id: string;
  title: string;
  trigger: string;
  action: string;
  source: string;
  enabled: boolean;
  triggerSpec: SmartTriggerSpec;
  actions: SmartActionSpec[];
}

export interface AgentMessageSpec {
  id: string;
  role: string;
  text: string;
  meta: string;
}

export const SMART_SUGGESTIONS: AgentSuggestionSpec[] = [
  { id: 'leave', label: '离家断电', prompt: '当我出门时，关闭客厅电视、空气净化器和主灯，并开启安防提醒' },
  { id: 'night', label: '夜间入睡', prompt: '每天晚上十点半关闭客厅灯，拉上卧室窗帘并把卧室空调调到23度' },
  { id: 'return', label: '回家模式', prompt: '我回家后打开客厅灯到70%，启动空气净化器并让电视进入待机' },
  { id: 'clean', label: '周末清洁', prompt: '每周六上午十点启动客厅和卧室扫地机器人，清洁完成后提醒我' }
];

export const DEFAULT_AGENT_RECORDS: AgentRecordSpec[] = [
  {
    id: 'record_seed_1',
    title: '智能助手已整理晨间场景',
    detail: '建议把窗帘、空调和照明联动成一键场景。',
    time: '09:12',
    status: '建议'
  },
  {
    id: 'record_seed_2',
    title: '离家脚本已同步',
    detail: '关闭高功率设备，并保留必要的安防提醒。',
    time: '08:46',
    status: '已执行'
  }
];

export const DEFAULT_AGENT_MESSAGES: AgentMessageSpec[] = [
  {
    id: 'agent_seed_1',
    role: 'agent',
    text: '我可以帮你控制空调、窗帘、灯光和扫地机器人，也可以回答普通问题。',
    meta: '在线'
  }
];

export const DEFAULT_AUTOMATIONS: AutomationSpec[] = [
  {
    id: 'auto_seed_morning',
    title: '晨间唤醒',
    trigger: '每天 07:30',
    action: '打开客厅灯，调整窗帘和空调',
    source: 'agent',
    enabled: true,
    triggerSpec: {
      type: 'time',
      label: '每天 07:30',
      time: '07:30'
    },
    actions: [
      { pointId: 'living_light', command: 'set', label: '客厅灯调到 70%', value: 70 },
      { pointId: 'living_curtain', command: 'set', label: '打开客厅窗帘', value: 100 },
      { pointId: 'living_air', command: 'set', label: '客厅空调调到 24°C', value: 24 }
    ]
  },
  {
    id: 'auto_seed_sleep',
    title: '睡眠模式',
    trigger: '每天 22:30',
    action: '关闭客厅灯，拉上卧室窗帘，调整卧室空调',
    source: 'agent',
    enabled: true,
    triggerSpec: {
      type: 'time',
      label: '每天 22:30',
      time: '22:30'
    },
    actions: [
      { pointId: 'living_light', command: 'off', label: '关闭客厅灯' },
      { pointId: 'bedroom_curtain', command: 'set', label: '关闭卧室窗帘', value: 0 },
      { pointId: 'bedroom_air', command: 'set', label: '卧室空调调至 23°C', value: 23 }
    ]
  }
];
