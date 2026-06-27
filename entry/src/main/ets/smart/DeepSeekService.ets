import http from '@ohos.net.http';
import { DEEPSEEK_API_KEY, DEEPSEEK_API_URL, DEEPSEEK_MODEL, DEEPSEEK_TIMEOUT_MS } from './DeepSeekConfig';

interface DeepSeekMessage {
  role: string;
  content: string;
}

interface DeepSeekRequestBody {
  model: string;
  messages: DeepSeekMessage[];
  temperature: number;
  stream: boolean;
}

export interface DeepSeekAnswer {
  ok: boolean;
  content: string;
  statusCode: number;
  error?: string;
}

export function hasDeepSeekApiKey(): boolean {
  return DEEPSEEK_API_KEY.trim().length > 0;
}

function unescapeJsonString(value: string): string {
  return value
    .replace(/\\n/g, '\n')
    .replace(/\\"/g, '"')
    .replace(/\\\\/g, '\\')
    .replace(/\\t/g, '  ')
    .replace(/\\r/g, '')
    .trim();
}

function parseDeepSeekContent(raw: string): string {
  const contentKey = '"content"';
  const keyIndex = raw.indexOf(contentKey);
  if (keyIndex < 0) {
    return '';
  }
  const colonIndex = raw.indexOf(':', keyIndex + contentKey.length);
  if (colonIndex < 0) {
    return '';
  }
  const startQuoteIndex = raw.indexOf('"', colonIndex + 1);
  if (startQuoteIndex < 0) {
    return '';
  }

  let endQuoteIndex = -1;
  let slashCount = 0;
  for (let i = startQuoteIndex + 1; i < raw.length; i++) {
    const char = raw.charAt(i);
    if (char === '\\') {
      slashCount++;
    } else {
      if (char === '"' && slashCount % 2 === 0) {
        endQuoteIndex = i;
        break;
      }
      slashCount = 0;
    }
  }
  if (endQuoteIndex < 0) {
    return '';
  }
  return unescapeJsonString(raw.substring(startQuoteIndex + 1, endQuoteIndex));
}

export async function askDeepSeek(prompt: string): Promise<DeepSeekAnswer> {
  if (!hasDeepSeekApiKey()) {
    return {
      ok: false,
      content: 'DeepSeek API Key 还没有配置。请打开 smart/DeepSeekConfig.ets，把 DEEPSEEK_API_KEY 填成你的 Key。',
      statusCode: 0,
      error: 'missing_api_key'
    };
  }

  const request = http.createHttp();
  const body: DeepSeekRequestBody = {
    model: DEEPSEEK_MODEL,
    messages: [
      {
        role: 'system',
        content: '你是一个智能家居应用里的中文语音助手。回答要简洁、自然，可以帮助用户解决日常问题，也可以协助整理智能家居自动化想法。'
      },
      {
        role: 'user',
        content: prompt
      }
    ],
    temperature: 0.7,
    stream: false
  };

  try {
    const response = await request.request(DEEPSEEK_API_URL, {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${DEEPSEEK_API_KEY}`
      },
      extraData: JSON.stringify(body),
      expectDataType: http.HttpDataType.STRING,
      readTimeout: DEEPSEEK_TIMEOUT_MS,
      connectTimeout: DEEPSEEK_TIMEOUT_MS
    });
    const statusCode = Number(response.responseCode);
    const raw = `${response.result}`;
    if (statusCode < 200 || statusCode >= 300) {
      return {
        ok: false,
        content: `DeepSeek 请求失败，HTTP 状态码 ${statusCode}。`,
        statusCode: statusCode,
        error: raw
      };
    }
    const content = parseDeepSeekContent(raw);
    return {
      ok: content.length > 0,
      content: content.length > 0 ? content : 'DeepSeek 已返回结果，但没有解析到有效内容。',
      statusCode: statusCode,
      error: content.length > 0 ? undefined : raw
    };
  } catch (error) {
    return {
      ok: false,
      content: `DeepSeek 请求失败：${error}`,
      statusCode: 0,
      error: `${error}`
    };
  } finally {
    request.destroy();
  }
}
