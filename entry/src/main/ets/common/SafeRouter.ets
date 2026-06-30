import router from '@ohos.router';
import { Router } from '@ohos.arkui.UIContext';

export function safeGetParams(pageRouter: Router): Object | undefined {
  try {
    return pageRouter.getParams();
  } catch {
    return undefined;
  }
}

export function safePushUrl(pageRouter: Router, options: router.RouterOptions): void {
  try {
    pageRouter.pushUrl(options).then(() => {
    }).catch(() => {
    });
  } catch {
  }
}

export function safeReplaceUrl(pageRouter: Router, options: router.RouterOptions): void {
  try {
    pageRouter.replaceUrl(options).then(() => {
    }).catch(() => {
    });
  } catch {
  }
}

export function safeBackOrReplace(pageRouter: Router, fallbackOptions: router.RouterOptions): void {
  try {
    const length = pageRouter.getStackSize();
    if (length > 1) {
      pageRouter.back();
      return;
    }
  } catch {
  }
  safeReplaceUrl(pageRouter, fallbackOptions);
}

export function safeBack(pageRouter: Router, options?: router.RouterOptions): void {
  try {
    pageRouter.back(options);
  } catch {
  }
}
