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
