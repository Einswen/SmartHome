# Smart Assistant

DeepSeek is wired through `DeepSeekService.ets`.

To enable online daily conversation, open `DeepSeekConfig.ets` and fill:

```ts
export const DEEPSEEK_API_KEY: string = 'your_deepseek_api_key';
```

The app already has `ohos.permission.INTERNET` in `module.json5`.

Smart-home commands now go through the LLM intent layer first. DeepSeek returns a strict JSON payload, the frontend validates the device/action whitelist, then sends compatible device-action JSON to the existing backend API.
