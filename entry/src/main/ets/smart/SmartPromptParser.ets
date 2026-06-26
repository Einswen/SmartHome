import { SmartActionSpec, SmartPromptDraft, SmartTriggerSpec } from './SmartModels';

function includesAny(text: string, keywords: string[]): boolean {
  for (let i = 0; i < keywords.length; i++) {
    if (text.indexOf(keywords[i]) >= 0) {
      return true;
    }
  }
  return false;
}

function extractNumberAfter(text: string, keyword: string): number {
  const index = text.indexOf(keyword);
  if (index < 0) {
    return -1;
  }
  const suffix = text.substring(index + keyword.length);
  const match = suffix.match(/\d+/);
  if (match === null) {
    return -1;
  }
  return Number(match[0]);
}

export function createDraftActions(action: string): SmartActionSpec[] {
  return [
    {
      pointId: '',
      command: 'draft',
      label: action
    }
  ];
}

export function createManualTriggerSpec(trigger: string): SmartTriggerSpec {
  if (trigger.indexOf('每天') >= 0 || trigger.indexOf(':') >= 0 || trigger.indexOf('点') >= 0) {
    return {
      type: 'time',
      label: trigger
    };
  }
  if (trigger.indexOf('每周') >= 0 || trigger.indexOf('周') >= 0) {
    return {
      type: 'weekly',
      label: trigger
    };
  }
  if (trigger.indexOf('离家') >= 0 || trigger.indexOf('回家') >= 0) {
    return {
      type: 'presence',
      label: trigger
    };
  }
  return {
    type: 'manual',
    label: trigger
  };
}

function parsePromptTrigger(prompt: string): SmartTriggerSpec {
  if (includesAny(prompt, ['每周', '周六', '周日', '周一', '周二', '周三', '周四', '周五'])) {
    const weekday = includesAny(prompt, ['周六', '星期六']) ? '周六' :
      includesAny(prompt, ['周日', '星期日']) ? '周日' :
        includesAny(prompt, ['周一', '星期一']) ? '周一' :
          includesAny(prompt, ['周二', '星期二']) ? '周二' :
            includesAny(prompt, ['周三', '星期三']) ? '周三' :
              includesAny(prompt, ['周四', '星期四']) ? '周四' :
                includesAny(prompt, ['周五', '星期五']) ? '周五' : '每周';
    return {
      type: 'weekly',
      label: prompt.indexOf('上午十点') >= 0 ? `${weekday} 10:00` : weekday,
      weekday: weekday,
      time: prompt.indexOf('上午十点') >= 0 ? '10:00' : undefined
    };
  }
  if (includesAny(prompt, ['每天', '晚上', '早上', '上午', '下午', '点'])) {
    let time = '';
    if (includesAny(prompt, ['十点半', '10点半', '22:30'])) {
      time = '22:30';
    } else if (includesAny(prompt, ['十点', '10点'])) {
      time = includesAny(prompt, ['晚上', '晚间']) ? '22:00' : '10:00';
    }
    return {
      type: 'time',
      label: time.length > 0 ? `每天 ${time}` : '按时间触发',
      time: time.length > 0 ? time : undefined
    };
  }
  if (includesAny(prompt, ['离家', '出门'])) {
    return {
      type: 'presence',
      label: '离家时'
    };
  }
  if (includesAny(prompt, ['回家', '到家'])) {
    return {
      type: 'presence',
      label: '回家时'
    };
  }
  return {
    type: 'manual',
    label: '手动执行'
  };
}

function appendPromptAction(actions: SmartActionSpec[], pointId: string, command: string, label: string, value?: number): void {
  actions.push({
    pointId: pointId,
    command: command,
    label: label,
    value: value
  });
}

function parsePromptActions(prompt: string): SmartActionSpec[] {
  const actions: SmartActionSpec[] = [];
  const isOff = includesAny(prompt, ['关闭', '关掉', '关上', '断电', '待机']);

  if (prompt.indexOf('客厅灯') >= 0 || prompt.indexOf('主灯') >= 0) {
    const lightLevel = extractNumberAfter(prompt, '客厅灯到');
    if (lightLevel > 0) {
      appendPromptAction(actions, 'living_light', 'set', `客厅灯调到 ${lightLevel}%`, lightLevel);
    } else {
      appendPromptAction(actions, 'living_light', isOff ? 'off' : 'on', isOff ? '关闭客厅灯' : '打开客厅灯');
    }
  }
  if (prompt.indexOf('卧室灯') >= 0 || prompt.indexOf('床头灯') >= 0) {
    appendPromptAction(actions, 'bedroom_left_light', isOff ? 'off' : 'on', isOff ? '关闭卧室灯' : '打开卧室灯');
  }
  if (prompt.indexOf('电视') >= 0) {
    appendPromptAction(actions, 'living_tv', isOff ? 'off' : 'on', isOff ? '关闭客厅电视' : '打开客厅电视');
  }
  if (prompt.indexOf('空气净化器') >= 0 || prompt.indexOf('净化器') >= 0) {
    appendPromptAction(actions, 'living_purifier', isOff ? 'off' : 'on', isOff ? '关闭空气净化器' : '启动空气净化器');
  }
  if (prompt.indexOf('扫地机器人') >= 0) {
    let robotMatched = false;
    if (prompt.indexOf('客厅') >= 0 || prompt.indexOf('客厅和卧室') >= 0) {
      appendPromptAction(actions, 'living_robot', isOff ? 'off' : 'on', isOff ? '暂停客厅扫地机器人' : '启动客厅扫地机器人');
      robotMatched = true;
    }
    if (prompt.indexOf('卧室') >= 0 || prompt.indexOf('客厅和卧室') >= 0) {
      appendPromptAction(actions, 'bedroom_robot', isOff ? 'off' : 'on', isOff ? '暂停卧室扫地机器人' : '启动卧室扫地机器人');
      robotMatched = true;
    }
    if (!robotMatched) {
      appendPromptAction(actions, 'living_robot', isOff ? 'off' : 'on', isOff ? '暂停扫地机器人' : '启动扫地机器人');
    }
  }
  if (prompt.indexOf('卧室窗帘') >= 0 || prompt.indexOf('窗帘') >= 0) {
    const curtainValue = extractNumberAfter(prompt, '窗帘到');
    if (prompt.indexOf('卧室') >= 0 || prompt.indexOf('拉上') >= 0) {
      appendPromptAction(actions, 'bedroom_curtain', 'set', curtainValue >= 0 ? `卧室窗帘调到 ${curtainValue}%` : '拉上卧室窗帘', curtainValue >= 0 ? curtainValue : 100);
    } else {
      appendPromptAction(actions, 'living_curtain', 'set', curtainValue >= 0 ? `客厅窗帘调到 ${curtainValue}%` : '调整客厅窗帘', curtainValue >= 0 ? curtainValue : 100);
    }
  }
  if (prompt.indexOf('卧室空调') >= 0) {
    const temperature = extractNumberAfter(prompt, '调到');
    appendPromptAction(actions, 'bedroom_air', 'set', temperature > 0 ? `卧室空调调到 ${temperature}°C` : '调整卧室空调', temperature > 0 ? temperature : undefined);
  }
  if (prompt.indexOf('客厅空调') >= 0) {
    const temperature = extractNumberAfter(prompt, '调到');
    appendPromptAction(actions, 'living_air', 'set', temperature > 0 ? `客厅空调调到 ${temperature}°C` : '调整客厅空调', temperature > 0 ? temperature : undefined);
  }
  if (prompt.indexOf('门') >= 0 || prompt.indexOf('安防') >= 0) {
    appendPromptAction(actions, 'bedroom_door', prompt.indexOf('解锁') >= 0 ? 'off' : 'on', prompt.indexOf('解锁') >= 0 ? '解除卧室门锁' : '开启安防提醒');
  }
  if (actions.length === 0) {
    return createDraftActions(prompt);
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

function promptShouldCreateAutomation(prompt: string, triggerSpec: SmartTriggerSpec): boolean {
  return triggerSpec.type !== 'manual' || includesAny(prompt, ['自动', '脚本', '每天', '每周', '离家', '出门', '回家']);
}

function buildPromptTitle(prompt: string, triggerSpec: SmartTriggerSpec): string {
  if (includesAny(prompt, ['离家', '出门'])) {
    return '离家智能脚本';
  }
  if (includesAny(prompt, ['睡眠', '入睡', '晚上'])) {
    return '夜间入睡脚本';
  }
  if (includesAny(prompt, ['回家', '到家'])) {
    return '回家智能脚本';
  }
  if (includesAny(prompt, ['清洁', '扫地'])) {
    return '清洁自动化脚本';
  }
  return triggerSpec.type === 'manual' ? '智能执行方案' : '智能自动化脚本';
}

export function parseSmartPrompt(prompt: string): SmartPromptDraft {
  const triggerSpec = parsePromptTrigger(prompt);
  const actions = parsePromptActions(prompt);
  const actionText = actionSummary(actions);
  const shouldCreateAutomation = promptShouldCreateAutomation(prompt, triggerSpec);
  const title = buildPromptTitle(prompt, triggerSpec);
  return {
    title: title,
    trigger: triggerSpec.label,
    action: actionText.length > 0 ? actionText : prompt,
    shouldCreateAutomation: shouldCreateAutomation,
    triggerSpec: triggerSpec,
    actions: actions,
    response: shouldCreateAutomation ?
      `我已解析出触发条件“${triggerSpec.label}”，并整理了 ${actions.length} 个设备动作，脚本已放到上方。` :
      `我已解析出 ${actions.length} 个设备动作：${actionText}。`
  };
}
