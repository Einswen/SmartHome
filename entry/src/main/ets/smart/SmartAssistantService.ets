import { askDeepSeek } from './DeepSeekService';
import { parseSmartPrompt } from './SmartPromptParser';
import { SmartAssistantReply } from './SmartModels';

function shouldUseLocalSmartHome(prompt: string): boolean {
  const deviceKeywords: string[] = [
    '灯', '空调', '窗帘', '电视', '净化器', '扫地机器人', '门锁', '安防'
  ];
  const actionKeywords: string[] = [
    '打开', '开启', '启动', '关闭', '关掉', '关上', '调到', '调至', '设置',
    '自动', '脚本', '每天', '每周', '离家', '出门', '回家', '睡眠模式', '清洁模式'
  ];

  let hasDevice = false;
  for (let i = 0; i < deviceKeywords.length; i++) {
    if (prompt.indexOf(deviceKeywords[i]) >= 0) {
      hasDevice = true;
      break;
    }
  }
  if (!hasDevice) {
    return false;
  }

  for (let i = 0; i < actionKeywords.length; i++) {
    if (prompt.indexOf(actionKeywords[i]) >= 0) {
      return true;
    }
  }
  return false;
}

export async function resolveSmartAssistantPrompt(prompt: string): Promise<SmartAssistantReply> {
  if (shouldUseLocalSmartHome(prompt)) {
    const draft = parseSmartPrompt(prompt);
    return {
      mode: 'smart_home',
      title: draft.shouldCreateAutomation ? '智能助手已生成自动化草稿' : '智能助手已生成执行方案',
      detail: draft.response,
      draft: draft,
      ok: true
    };
  }

  const answer = await askDeepSeek(prompt);
  return {
    mode: 'llm',
    title: answer.ok ? 'DeepSeek' : 'DeepSeek 未连接',
    detail: answer.content,
    ok: answer.ok
  };
}
