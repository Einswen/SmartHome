import { askDeepSeek } from './DeepSeekService';
import { parseSmartPrompt } from './SmartPromptParser';
import { SmartAssistantReply } from './SmartModels';

function shouldUseLocalSmartHome(prompt: string): boolean {
  const keywords: string[] = [
    '灯', '空调', '窗帘', '电视', '净化器', '扫地机器人', '门', '安防',
    '自动', '脚本', '每天', '每周', '离家', '出门', '回家', '睡眠', '清洁'
  ];
  for (let i = 0; i < keywords.length; i++) {
    if (prompt.indexOf(keywords[i]) >= 0) {
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
      draft: draft
    };
  }

  const answer = await askDeepSeek(prompt);
  return {
    mode: 'llm',
    title: 'DeepSeek',
    detail: answer
  };
}
