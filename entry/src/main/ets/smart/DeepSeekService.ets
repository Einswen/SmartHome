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
  response_format?: DeepSeekResponseFormat;
  max_tokens?: number;
}

interface DeepSeekResponseFormat {
  type: string;
}

interface DeepSeekResponseMessage {
  role?: string;
  content?: string;
}

interface DeepSeekResponseChoice {
  message?: DeepSeekResponseMessage;
}

interface DeepSeekResponseBody {
  choices?: DeepSeekResponseChoice[];
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
  try {
    const parsed = JSON.parse(raw) as DeepSeekResponseBody;
    if (parsed.choices !== undefined && parsed.choices.length > 0 &&
      parsed.choices[0].message !== undefined && parsed.choices[0].message.content !== undefined) {
      return parsed.choices[0].message.content.trim();
    }
  } catch {
  }

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

async function requestDeepSeek(messages: DeepSeekMessage[], temperature: number, jsonMode: boolean): Promise<DeepSeekAnswer> {
  if (!hasDeepSeekApiKey()) {
    return {
      ok: false,
      content: 'API Key 配置。',
      statusCode: 0,
      error: 'missing_api_key'
    };
  }

  const request = http.createHttp();
  const body: DeepSeekRequestBody = {
    model: DEEPSEEK_MODEL,
    messages: messages,
    temperature: temperature,
    stream: false
  };
  if (jsonMode) {
    body.response_format = {
      type: 'json_object'
    };
    body.max_tokens = 2048;
  }

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
  } catch {
    return {
      ok: false,
      content: 'DeepSeek 请求失败，请检查网络连接或 API Key。',
      statusCode: 0,
      error: 'request failed'
    };
  } finally {
    request.destroy();
  }
}

export async function askDeepSeek(prompt: string): Promise<DeepSeekAnswer> {
  return requestDeepSeek([
    {
      role: 'system',
      content: '你是一个智能家居应用里的中文语音助手。回答要简洁、自然，可以帮助用户解决日常问题，也可以协助整理智能家居自动化想法。'
    },
    {
      role: 'user',
      content: prompt
    }
  ], 0.7, false);
}

export async function askDeepSeekWithSystem(systemPrompt: string, userPrompt: string, temperature: number): Promise<DeepSeekAnswer> {
  return requestDeepSeek([
    {
      role: 'system',
      content: systemPrompt
    },
    {
      role: 'user',
      content: userPrompt
    }
  ], temperature, true);
}
