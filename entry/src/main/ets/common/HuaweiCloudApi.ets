import http from '@ohos.net.http';
import BusinessError from '@ohos.base';

// 定义华为云认证相关的接口
interface AuthDomain {
  name: string;
}

interface AuthPasswordUser {
  name: string;
  domain: AuthDomain;
  password: string;
}

interface AuthPassword {
  user: AuthPasswordUser;
}

interface AuthIdentity {
  methods: string[];
  password: AuthPassword;
}

interface AuthProject {
  id: string;
}

interface AuthScope {
  project: AuthProject;
}

interface MyAuth {
  identity: AuthIdentity;
  scope: AuthScope;
}

interface AuthBody {
  auth: MyAuth;
}

// 定义命令参数接口
interface LightCmd {
  Light: string;
}

interface MotorCmd {
  Motor: string;
}

interface CommandBody<T> {
  service_id: string;
  command_name: string;
  paras: T;
}

// 华为云 API 工具类
export class HuaweiCloudApi {
  // ============================================
  // 【你只需要改这里 6 个值】
  // ============================================
  private static readonly PROJECT_ID = "019f12281b257ab0a026c4c3262ae9df";
  private static readonly DEVICE_ID = "6a436acccbb0cf6bb96a80f9_E53_IA";
  private static readonly REGION = "cn-north-4";
  private static readonly DOMAIN_NAME = "jackey-unique"; // 华为云主账号名/租户名
  private static readonly IAM_USER = "jackey"; // IAM用户名
  private static readonly IAM_PWD = "yLTr#UqR#CAau96BoXqS3qy&W";
  private static readonly IOTDA_HOST = "e52f26ce1b.st1.iotda-app.cn-north-4.myhuaweicloud.com";
  // ============================================

  // 注意：PDF原文使用了 $this 错误语法，已修正为标准模板字符串
  private static readonly IAM_URL = `https://iam.${HuaweiCloudApi.REGION}.myhuaweicloud.com/v3/auth/tokens`;
  private static readonly IOTDA_URL = `https://${HuaweiCloudApi.IOTDA_HOST}/v5/iot/${HuaweiCloudApi.PROJECT_ID}`;

  private static responseText(data: http.HttpResponse): string {
    if (data.result === undefined || data.result === null) {
      return '';
    }
    if (typeof data.result === 'string') {
      return data.result;
    }
    return JSON.stringify(data.result);
  }

  private static subjectToken(data: http.HttpResponse): string {
    const headerText = JSON.stringify(data.header);
    let token = HuaweiCloudApi.headerValue(headerText, 'X-Subject-Token');
    if (token.length === 0) {
      token = HuaweiCloudApi.headerValue(headerText, 'x-subject-token');
    }
    if (token.length === 0) {
      token = HuaweiCloudApi.headerValue(headerText, 'X-Subject-token');
    }
    return token;
  }

  private static headerValue(headerText: string, key: string): string {
    const marker = `"${key}":"`;
    const start = headerText.indexOf(marker);
    if (start < 0) {
      return '';
    }
    const valueStart = start + marker.length;
    const valueEnd = headerText.indexOf('"', valueStart);
    if (valueEnd < 0) {
      return '';
    }
    return headerText.substring(valueStart, valueEnd);
  }

  private static errorText(err: Object | string | undefined): string {
    if (err === undefined || err === null) {
      return '未知错误';
    }
    if (typeof err === 'string') {
      return err;
    }
    const businessErr = err as BusinessError<void>;
    const code = businessErr.code !== undefined ? `code=${businessErr.code}; ` : '';
    const message = businessErr.message !== undefined && businessErr.message.length > 0 ? businessErr.message : JSON.stringify(err);
    return `${code}${message}`;
  }

  private static ensureSuccess(stage: string, data: http.HttpResponse): void {
    const statusCode = data.responseCode;
    const responseBody = HuaweiCloudApi.responseText(data);
    if (statusCode < 200 || statusCode >= 300) {
      throw new Error(`${stage}失败：HTTP ${statusCode}，响应：${responseBody}`);
    }
  }

  private static debugLog(stage: string, message: string): void {
    console.info(`[HuaweiCloudApi][${stage}] ${message}`);
  }

  private static debugError(stage: string, message: string): void {
    console.error(`[HuaweiCloudApi][${stage}] ${message}`);
  }

  // 1. 获取 Token (IAM 账号密码)
  static async getToken(): Promise<string> {
    const domain: AuthDomain = { name: HuaweiCloudApi.DOMAIN_NAME };
    const user: AuthPasswordUser = {
      name: HuaweiCloudApi.IAM_USER,
      domain: domain,
      password: HuaweiCloudApi.IAM_PWD
    };
    const password: AuthPassword = { user: user };
    const identity: AuthIdentity = {
      methods: ["password"],
      password: password
    };
    const project: AuthProject = { id: HuaweiCloudApi.PROJECT_ID };
    const scope: AuthScope = { project: project };

    const body: AuthBody = {
      auth: {
        identity: identity,
        scope: scope
      }
    };

    return new Promise((resolve, reject) => {
      const h = http.createHttp();
      HuaweiCloudApi.debugLog('getToken', `开始请求 IAM Token：${HuaweiCloudApi.IAM_URL}`);
      h.request(
        HuaweiCloudApi.IAM_URL,
        {
          method: http.RequestMethod.POST,
          header: { "Content-Type": "application/json" },
          extraData: JSON.stringify(body),
          connectTimeout: 10000,
          readTimeout: 10000
        },
        (err: BusinessError, data: http.HttpResponse) => {
          if (err) {
            const message = `获取 IAM Token 网络请求失败：${HuaweiCloudApi.errorText(err)}`;
            HuaweiCloudApi.debugError('getToken', message);
            reject(new Error(message));
            return;
          }
          try {
            HuaweiCloudApi.ensureSuccess('获取 IAM Token', data);
            // 从响应头获取 Token
            const token = HuaweiCloudApi.subjectToken(data);
            if (token.length === 0) {
              throw new Error(`获取 IAM Token失败：响应头缺少 X-Subject-Token，响应头：${JSON.stringify(data.header)}，响应：${HuaweiCloudApi.responseText(data)}`);
            }
            HuaweiCloudApi.debugLog('getToken', `Token 获取成功，HTTP ${data.responseCode}`);
            resolve(token);
          } catch (e) {
            const message = HuaweiCloudApi.errorText(e as Error);
            HuaweiCloudApi.debugError('getToken', message);
            reject(new Error(message));
          }
        }
      );
    });
  }

  // 2. 获取设备数据 (影子数据)
  static async getDeviceData(): Promise<string> {
    const token: string = await HuaweiCloudApi.getToken();
    return new Promise((resolve, reject) => {
      const h: http.HttpRequest = http.createHttp();
      // 修正了路径拼接语法
      const url = `${HuaweiCloudApi.IOTDA_URL}/devices/${HuaweiCloudApi.DEVICE_ID}/shadow`;
      HuaweiCloudApi.debugLog('getDeviceData', `开始读取设备影子：${url}`);
      h.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            "X-Auth-Token": token,
            "Content-Type": "application/json"
          },
          connectTimeout: 10000,
          readTimeout: 10000
        },
        (err: BusinessError<void>, data: http.HttpResponse) => {
          if (err) {
            const message = `读取设备影子网络请求失败：${HuaweiCloudApi.errorText(err)}`;
            HuaweiCloudApi.debugError('getDeviceData', message);
            reject(new Error(message));
            return;
          }
          try {
            HuaweiCloudApi.ensureSuccess('读取设备影子', data);
            // 直接返回原始字符串，不解析、不转对象
            const resultStr: string = HuaweiCloudApi.responseText(data);
            HuaweiCloudApi.debugLog('getDeviceData', `读取设备影子成功，HTTP ${data.responseCode}，响应：${resultStr}`);
            resolve(resultStr);
          } catch (e) {
            const message = HuaweiCloudApi.errorText(e as Error);
            HuaweiCloudApi.debugError('getDeviceData', message);
            reject(new Error(message));
          }
        }
      );
    });
  }

  private static async sendCommand<T>(stage: string, body: CommandBody<T>): Promise<string> {
    const token: string = await HuaweiCloudApi.getToken();
    const bodyStr: string = JSON.stringify(body);

    return new Promise((resolve, reject) => {
      const h: http.HttpRequest = http.createHttp();
      // 修正了路径拼接语法
      const url = `${HuaweiCloudApi.IOTDA_URL}/devices/${HuaweiCloudApi.DEVICE_ID}/commands`;
      HuaweiCloudApi.debugLog(stage, `开始下发命令：${url}，body=${bodyStr}`);
      h.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            "X-Auth-Token": token,
            "Content-Type": "application/json"
          },
          extraData: bodyStr,
          connectTimeout: 10000,
          readTimeout: 10000
        },
        (err: BusinessError<void>, data: http.HttpResponse) => {
          if (err) {
            const message = `${stage}网络请求失败：${HuaweiCloudApi.errorText(err)}，body=${bodyStr}`;
            HuaweiCloudApi.debugError(stage, message);
            reject(new Error(message));
            return;
          }
          try {
            HuaweiCloudApi.ensureSuccess(stage, data);
            const resultStr = HuaweiCloudApi.responseText(data);
            HuaweiCloudApi.debugLog(stage, `命令下发成功，HTTP ${data.responseCode}，响应：${resultStr}`);
            resolve(resultStr);
          } catch (e) {
            const message = `${HuaweiCloudApi.errorText(e as Error)}，body=${bodyStr}`;
            HuaweiCloudApi.debugError(stage, message);
            reject(new Error(message));
          }
        }
      );
    });
  }

  // 3. 控制紫光灯
  static async sendLightCommand(status: string): Promise<void> {
    await HuaweiCloudApi.sendCommand<LightCmd>('紫光灯命令下发', {
      service_id: "智慧农业",
      command_name: "紫光灯控制",
      paras: { Light: status } as LightCmd
    });
  }

  // 4. 控制电机
  static async sendMotorCommand(status: string): Promise<void> {
    await HuaweiCloudApi.sendCommand<MotorCmd>('电机命令下发', {
      service_id: "智慧农业",
      command_name: "电机控制",
      paras: { Motor: status } as MotorCmd
    });
  }

  static async sendSceneCommand(scene: string): Promise<void> {
    await HuaweiCloudApi.sendCommand<MotorCmd>('Scene command', {
      service_id: "鏅烘収鍐滀笟",
      command_name: "鐢垫満鎺у埗",
      paras: { Motor: scene } as MotorCmd
    });
  }
}
