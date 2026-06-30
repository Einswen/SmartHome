
# SmartHome 项目层次图

本文档用于说明 SmartHome 项目的目录分层、页面归属和各模块职责，方便组内协作、后续接入硬件接口以及代码维护。

## 目录总览

```text
SmartHome/
├─ AppScope/                                      应用级配置、应用资源
│  ├─ app.json5                                  应用全局配置
│  └─ resources/                                 应用级图标、字符串等资源
│
├─ entry/                                        HarmonyOS 主模块
│  ├─ build-profile.json5                       entry 模块构建配置
│  ├─ hvigorfile.ts                             entry 模块 hvigor 构建脚本
│  ├─ oh-package.json5                          entry 模块依赖配置
│  │
│  └─ src/
│     ├─ main/                                  应用主代码与主资源
│     │  ├─ module.json5                        模块能力、页面入口、权限配置
│     │  │
│     │  ├─ ets/                                ArkTS / ArkUI 业务代码
│     │  │  ├─ entryability/
│     │  │  │  └─ EntryAbility.ets              应用主 Ability 入口
│     │  │  │
│     │  │  ├─ entrybackupability/
│     │  │  │  └─ EntryBackupAbility.ets        备份恢复能力入口
│     │  │  │
│     │  │  ├─ pages/                           页面层
│     │  │  │  ├─ Index.ets                     应用首页 / 底部导航 / 房间总入口
│     │  │  │  │
│     │  │  │  ├─ my/                           “我的”模块页面集合
│     │  │  │  │  ├─ myprofile.ets              我的首页 / 个人中心
│     │  │  │  │  ├─ mylogin.ets                登录页面
│     │  │  │  │  ├─ myfamily.ets               家庭管理页面
│     │  │  │  │  ├─ mydevices.ets              设备管理页面
│     │  │  │  │  ├─ mydevicedetail.ets         我的设备详情页面
│     │  │  │  │  └─ mysettings.ets             设置页面
│     │  │  │  │
│     │  │  │  ├─ store/                        商城模块页面集合
│     │  │  │  │  ├─ storehome.ets              商城首页
│     │  │  │  │  ├─ storecategory.ets          商品分类页面
│     │  │  │  │  ├─ storeproduct.ets           商品详情页面
│     │  │  │  │  ├─ storecart.ets              购物车页面
│     │  │  │  │  ├─ storeorders.ets            订单页面
│     │  │  │  │  └─ storeservice.ets           售后 / 服务页面
│     │  │  │  │
│     │  │  │  └─ messagecenter/
│     │  │  │     └─ mymessages.ets             消息中心页面
│     │  │  │
│     │  │  ├─ components/                      组件层
│     │  │  │  ├─ DeviceDetailPages.ets         设备详情页统一导出 / 入口聚合
│     │  │  │  │
│     │  │  │  └─ deviceDetail/                 客厅 6 个设备详情页拆分目录
│     │  │  │     ├─ LivingAirPage.ets          空调详情页
│     │  │  │     ├─ LivingCurtainPage.ets      窗帘详情页
│     │  │  │     ├─ LivingLightPage.ets        客厅灯详情页
│     │  │  │     ├─ LivingPurifierPage.ets     空气净化器详情页
│     │  │  │     ├─ LivingRobotPage.ets        扫地机器人详情页
│     │  │  │     └─ LivingTvPage.ets           电视详情页
│     │  │  │
│     │  │  └─ smart/                           智能助手 / 指令解析模块
│     │  │     ├─ README.md                     智能模块说明
│     │  │     ├─ SmartAssistantService.ets     智能助手服务封装
│     │  │     ├─ SmartModels.ets               智能助手数据模型
│     │  │     ├─ SmartPromptParser.ets         用户指令解析
│     │  │     ├─ DeepSeekService.ets           DeepSeek 调用服务
│     │  │     └─ DeepSeekConfig.ets            DeepSeek 配置
│     │  │
│     │  └─ resources/                          应用资源层
│     │     ├─ base/
│     │     │  ├─ element/                      字符串、颜色、尺寸等基础资源
│     │     │  ├─ media/                        页面图片、设备图片、房间图片
│     │     │  └─ profile/                      页面路由、备份配置等 profile
│     │     │
│     │     ├─ dark/
│     │     │  └─ element/                      深色模式资源
│     │     │
│     │     └─ rawfile/                         原始资源文件
│     │        ├─ models-glb/                   3D 模型 glb 文件
│     │        └─ models-gltf/                  3D 模型 gltf/bin 文件
│     │
│     ├─ mock/
│     │  └─ mock-config.json5                   预览 / 测试 Mock 配置
│     │
│     ├─ test/                                  本地单元测试
│     └─ ohosTest/                              HarmonyOS 设备测试
│
├─ hvigor/                                      hvigor 工程配置
│  └─ hvigor-config.json5
│
├─ image/                                       项目外部图片素材备份
├─ report_assets/                               实训报告 / 文档配图资源
├─ scripts/                                     报告、图片等辅助脚本
│
├─ build-profile.json5                         工程级构建配置
├─ hvigorfile.ts                               工程级 hvigor 构建入口
├─ oh-package.json5                            工程级依赖配置
├─ README.md                                   项目说明
├─ PRODUCT.md                                  产品定位和设计原则
└─ PROJECT_STRUCTURE.md                        项目层次说明文档
```

## 分层说明

### 1. 应用配置层

```text
AppScope/
entry/src/main/module.json5
build-profile.json5
oh-package.json5
hvigorfile.ts
```

这一层主要负责 HarmonyOS 应用配置、模块配置、构建配置和依赖管理。平时开发页面功能时一般不用频繁修改，只有新增权限、页面入口、依赖包或构建配置时才需要改。

### 2. 页面层

```text
entry/src/main/ets/pages/
```

页面层负责完整页面的展示和跳转。当前主要分为首页、我的、商城和消息中心：

- `Index.ets`：应用主入口页面，负责首页房间展示、底部导航和设备详情入口。
- `pages/my/`：个人中心、登录、家庭管理、设备管理、设置等页面。
- `pages/store/`：商城首页、分类、商品详情、购物车、订单和服务页面。
- `pages/messagecenter/`：消息中心页面。

### 3. 组件层

```text
entry/src/main/ets/components/
```

组件层负责可复用的 UI 和业务组件。当前设备详情页相关内容放在这里：

- `DeviceDetailPages.ets`：作为设备详情页的统一入口，负责把外部调用和具体设备详情页连接起来。
- `components/deviceDetail/`：把客厅 6 个设备详情页拆成 6 个独立文件，方便分工、维护和后续对接硬件接口。

### 4. 客厅 6 个设备详情页

```text
entry/src/main/ets/components/deviceDetail/
├─ LivingAirPage.ets
├─ LivingCurtainPage.ets
├─ LivingLightPage.ets
├─ LivingPurifierPage.ets
├─ LivingRobotPage.ets
└─ LivingTvPage.ets
```

这 6 个页面是后续和硬件接口对接的重点。建议每个页面只负责自己的 UI 和交互，把真实硬件通信统一交给后续的 `DeviceApi` 或硬件服务层。

| 文件 | 对应设备 | 建议设备 ID | 后续硬件对接方向 |
| --- | --- | --- | --- |
| `LivingAirPage.ets` | 空调 | `living_air` | 温度、模式、开关状态 |
| `LivingCurtainPage.ets` | 窗帘 | `living_curtain` | 开合比例、电机控制 |
| `LivingLightPage.ets` | 客厅灯 | `living_light` | 灯光开关、亮度、光照传感器 |
| `LivingPurifierPage.ets` | 空气净化器 | `living_purifier` | PM2.5、风量、运行模式 |
| `LivingRobotPage.ets` | 扫地机器人 | `living_robot` | 开始、暂停、电量、清扫状态 |
| `LivingTvPage.ets` | 电视 | `living_tv` | 开关、频道、音量、手势遥控 |

### 5. 智能助手层

```text
entry/src/main/ets/smart/
```

这一层负责智能助手、自然语言指令解析和 DeepSeek 服务调用。它可以把用户输入的自然语言转换为设备控制意图，例如“打开客厅灯”“把空调调到 26 度”。

### 6. 资源层

```text
entry/src/main/resources/
```

资源层存放应用运行时需要的图片、颜色、字符串、路由配置和 3D 模型：

- `base/element/`：颜色、字符串、尺寸等基础资源。
- `base/media/`：房间图、设备图、图标等图片资源。
- `base/profile/`：页面路由、备份配置等 profile 文件。
- `dark/element/`：深色模式资源。
- `rawfile/models-glb/`、`rawfile/models-gltf/`：3D 家具模型资源。

### 7. 测试与 Mock 层

```text
entry/src/mock/
entry/src/test/
entry/src/ohosTest/
```

这一层用于预览、测试和模拟数据：

- `mock/`：DevEco 预览或接口模拟配置。
- `test/`：本地单元测试。
- `ohosTest/`：HarmonyOS 真机或模拟器测试。

## 后续协作建议

1. 页面开发只改 `pages/` 和 `components/`。
2. 客厅 6 个设备详情页已经拆到 `components/deviceDetail/`，后续每个设备可以单独分工。
3. 硬件接口不要直接写死在页面里，建议后续新增统一接口层，例如：

```text
entry/src/main/ets/data/
└─ hardware/
   ├─ DeviceApi.ets             App 调用硬件能力的统一入口
   ├─ DeviceModels.ets          设备状态、命令、返回值模型
   └─ DeviceMockRepository.ets  没接真实硬件时的模拟数据
```

4. 页面只传 `deviceId`，由接口层决定是走 Mock、HTTP、MQTT 还是串口中转。
5. 这样可以保证页面、硬件和后端互不影响，组员之间也更容易合并代码。
