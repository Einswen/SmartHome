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

// 华为云 API 工具类
export class HuaweiCloudApi {
  // ============================================
  // 【你只需要改这里 4 个值】
  // ============================================
  private static readonly PROJECT_ID = "019f12281b257ab0a026c4c3262ae9df";
  private static readonly DEVICE_ID = "6a421c8c7f2e6c302f802e54_11111";
  private static readonly REGION = "cn-north-4";
  private static readonly IAM_USER = "hid_7o3kzihkztsqxr-"; // IAM账户名
  private static readonly IAM_PWD = "qwer1234";
  private static readonly IOTDA_HOST = "e52f26ce1b.st1.iotda-app.cn-north-4.myhuaweicloud.com";
  // ============================================

  // 注意：PDF原文使用了 $this 错误语法，已修正为标准模板字符串
  private static readonly IAM_URL = `https://iam.${HuaweiCloudApi.REGION}.myhuaweicloud.com/v3/auth/tokens`;
  private static readonly IOTDA_URL = `https://${HuaweiCloudApi.IOTDA_HOST}/v5/iot/${HuaweiCloudApi.PROJECT_ID}`;

  // 1. 获取 Token (IAM 账号密码)
  static async getToken(): Promise<string> {
    const domain: AuthDomain = { name: HuaweiCloudApi.IAM_USER };
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
            reject(err);
            return;
          }
          // 从响应头获取 Token
          const token = data.header["X-Subject-Token"] as string ?? "";
          resolve(token);
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
      h.request(
        `${HuaweiCloudApi.IOTDA_URL}/devices/${HuaweiCloudApi.DEVICE_ID}/shadow`,
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
            reject(err);
            return;
          }
          // 直接返回原始字符串，不解析、不转对象
          const resultStr: string = data.result as string;
          resolve(resultStr);
        }
      );
    });
  }

  // 3. 控制紫光灯
  static async sendLightCommand(status: string): Promise<void> {
    const token: string = await HuaweiCloudApi.getToken();
    const bodyStr: string = JSON.stringify({
      service_id: "智慧农业",
      command_name: "紫光灯控制",
      paras: { Light: status } as LightCmd
    });

    return new Promise((resolve, reject) => {
      const h: http.HttpRequest = http.createHttp();
      // 修正了路径拼接语法
      h.request(
        `${HuaweiCloudApi.IOTDA_URL}/devices/${HuaweiCloudApi.DEVICE_ID}/commands`,
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
            console.error("紫光灯命令下发失败", JSON.stringify(err));
            reject(err);
            return;
          }
          console.info("紫光灯命令下发成功，返回", data.result as string);
          resolve();
        }
      );
    });
  }

  // 4. 控制电机
  static async sendMotorCommand(status: string): Promise<void> {
    const token: string = await HuaweiCloudApi.getToken();
    const bodyStr: string = JSON.stringify({
      service_id: "智慧农业",
      command_name: "电机控制",
      paras: { Motor: status } as MotorCmd
    });

    return new Promise((resolve, reject) => {
      const h: http.HttpRequest = http.createHttp();
      // 修正了路径拼接语法
      h.request(
        `${HuaweiCloudApi.IOTDA_URL}/devices/${HuaweiCloudApi.DEVICE_ID}/commands`,
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
            console.error("电机命令下发失败:", JSON.stringify(err));
            reject(err);
            return;
          }
          console.info("电机命令下发成功，返回:", data.result as string);
          resolve();
        }
      );
    });
  }
}