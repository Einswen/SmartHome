# Smart Assistant

DeepSeek is wired through `DeepSeekService.ets`.

To enable online daily conversation, open `DeepSeekConfig.ets` and fill:

```ts
export const DEEPSEEK_API_KEY: string = 'your_deepseek_api_key';
```

The app already has `ohos.permission.INTERNET` in `module.json5`.

Smart-home commands still use the local parser first. Daily questions without smart-home keywords go to DeepSeek.
