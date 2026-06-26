import http from '@ohos.net.http';
import { DEEPSEEK_API_KEY, DEEPSEEK_API_URL, DEEPSEEK_MODEL } from './DeepSeekConfig';

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

export function hasDeepSeekApiKey(): boolean {
  return DEEPSEEK_API_KEY.trim().length > 0;
}

export async function askDeepSeek(prompt: string): Promise<string> {
  if (!hasDeepSeekApiKey()) {
    return 'DeepSeek API Key 还没有配置。你可以先把 Key 放到 DeepSeekConfig.ets，之后我就能回答日常问题。';
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
      readTimeout: 20000,
      connectTimeout: 20000
    });
    const data = JSON.parse(`${response.result}`);
    const choices = data['choices'];
    if (choices !== undefined && choices.length > 0) {
      const message = choices[0]['message'];
      if (message !== undefined && message['content'] !== undefined) {
        return `${message['content']}`;
      }
    }
    return 'DeepSeek 已返回结果，但我没有解析到有效内容。';
  } catch (error) {
    return `DeepSeek 请求失败：${error}`;
  } finally {
    request.destroy();
  }
}
