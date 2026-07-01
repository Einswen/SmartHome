import { askDeepSeek } from './DeepSeekService';
import { parseSmartPrompt } from './SmartPromptParser';
import { SmartAssistantReply } from './SmartModels';

function shouldUseLocalSmartHome(prompt: string): boolean {
  const lower = prompt.toLowerCase();
  const englishDeviceKeywords: string[] = [
    'air conditioner', 'aircon', 'light', 'lamp', 'curtain', 'robot', 'vacuum', 'tv', 'purifier', 'door'
  ];
  if ((isEnglishAcPrompt(lower) || includesEnglishKeyword(lower, englishDeviceKeywords)) && hasEnglishDeviceAction(lower)) {
    return true;
  }

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

function isEnglishAcPrompt(lower: string): boolean {
  return lower === 'ac' ||
    lower.indexOf(' ac ') >= 0 ||
    lower.indexOf(' ac') === lower.length - 3 ||
    lower.indexOf('ac ') === 0;
}

function hasEnglishDeviceAction(lower: string): boolean {
  if (includesEnglishKeyword(lower, ['turn on', 'turn off', 'switch on', 'switch off', 'open', 'close', 'start', 'stop', 'pause'])) {
    return true;
  }
  const padded = ` ${lower.replace(/[.,!?]/g, ' ')} `;
  return padded.indexOf(' on ') >= 0 || padded.indexOf(' off ') >= 0;
}

function includesEnglishKeyword(text: string, keywords: string[]): boolean {
  for (let i = 0; i < keywords.length; i++) {
    if (text.indexOf(keywords[i]) >= 0) {
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
