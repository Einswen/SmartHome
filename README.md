# SmartHome

SmartHome 是一个基于 HarmonyOS / ArkTS / ArkUI 的智能家居中控原型。项目以“先看见家，再操作设备”为核心，把首页做成空间化的家居控制台，并在同一个应用里整合设备管理、家庭管理、消息中心、个人中心、智能助手和商城购买流程。

当前代码主要服务于产品原型和课程/实训展示：界面、页面流转、交互状态和资源组织已经比较完整，但大部分业务数据仍是本地模拟数据，真实设备、账号、订单和云端状态尚未接入生产后端。

## 当前页面数量

当前 `entry/src/main/ets/pages` 下共有 **16 个页面文件**。

其中 **15 个页面已注册到路由表** `entry/src/main/resources/base/profile/main_pages.json`，可以通过 `router.pushUrl` 或 DevEco 页面预览访问：

| 模块 | 页面 | 路由 | 作用 |
| --- | --- | --- | --- |
| 首页 | `Index.ets` | `pages/Index` | 应用入口，承载首页、智能 tab、商城 tab、我的 tab |
| 我的 | `mydevices.ets` | `pages/my/mydevices` | 设备中心，展示和操作家庭设备 |
| 我的 | `mydevicedetail.ets` | `pages/my/mydevicedetail` | 我的模块里的设备详情页 |
| 我的 | `myfamily.ets` | `pages/my/myfamily` | 家庭管理、成员和权限 |
| 我的 | `mysettings.ets` | `pages/my/mysettings` | 授权中心、账号安全和通用偏好 |
| 我的 | `mymessages.ets` | `pages/my/mymessages` | 消息中心，设备告警、自动化和服务通知 |
| 我的 | `myhomehealth.ets` | `pages/my/myhomehealth` | 家庭健康报告、巡检项目和设备闭环入口 |
| 我的 | `mylogin.ets` | `pages/my/mylogin` | Lumi 登录页 |
| 商城 | `storehome.ets` | `pages/store/storehome` | Lumi 商城首页 |
| 商城 | `storeproduct.ets` | `pages/store/storeproduct` | 商品详情、数量选择和加入购物车 |
| 商城 | `storecategory.ets` | `pages/store/storecategory` | 商品分类与场景化选购 |
| 商城 | `storeorders.ets` | `pages/store/storeorders` | 订单、订阅和物流跟踪 |
| 商城 | `storetracking.ets` | `pages/store/storetracking` | 物流跟踪、订阅管理和售后申请承接页 |
| 商城 | `storeservice.ets` | `pages/store/storeservice` | 售后、安装、保修和工单 |
| 商城 | `storecart.ets` | `pages/store/storecart` | 购物车和结算入口 |

另外还有 **1 个未单独注册为路由页的页面组件**：

| 模块 | 文件 | 当前使用方式 |
| --- | --- | --- |
| 我的 | `myprofile.ets` | 导出 `P21_MyProfile`，由 `Index.ets` 的“我的”底部 tab 内嵌渲染 |

也就是说，从用户能看到的功能界面来看，当前项目已经做了 **首页/智能/商城/我的四个底部 tab**，并包含 **16 个页面级界面**。从 HarmonyOS 路由注册角度看，目前是 **15 个可路由页面 + 1 个内嵌页面组件**。

## 功能概览

### 首页中控

入口文件是 `entry/src/main/ets/pages/Index.ets`，应用启动时由 `EntryAbility` 加载 `pages/Index`。

首页包含：

- 客厅、卧室等房间视图
- 日间/夜间状态切换
- 房间灯光、窗帘、空调、电视、空气净化器、扫地机器人、门锁等设备状态
- 房间图片上的点位交互
- 设备控制面板和详情面板
- 场景入口，例如早安、回家、观影、睡眠
- 添加房间、添加场景、设备选择等原型交互

首页设备详情的公共组件在 `entry/src/main/ets/components/DeviceDetailPages.ets`。

### 智能助手和自动化

智能相关代码位于 `entry/src/main/ets/smart`：

- `SmartModels.ets`：消息、自动化和智能记录的数据模型
- `SmartPromptParser.ets`：本地智能家居指令解析
- `SmartAssistantService.ets`：智能助手调度
- `DeepSeekService.ets`：DeepSeek 在线对话服务
- `DeepSeekConfig.ets`：DeepSeek API key 配置

当前策略是：智能家居相关指令优先走本地解析；普通日常问题可以转发到 DeepSeek。要启用在线对话，需要在 `DeepSeekConfig.ets` 中配置 API key。应用权限里已经声明了 `ohos.permission.INTERNET`。

### 我的模块

我的模块聚合账号、家庭、设备和消息能力：

- `myprofile.ets`：我的首页，展示用户、家庭状态、常用功能和更多服务
- `mydevices.ets`：设备中心，强调与首页点位联动
- `mydevicedetail.ets`：设备详情和快捷控制
- `myfamily.ets`：家庭成员、邀请和权限管理
- `mymessages.ets`：设备告警、自动化执行和服务通知
- `myhomehealth.ets`：家庭健康报告，承接我的首页家庭状态卡片
- `mysettings.ets`：授权中心、安全评分和通用偏好
- `mylogin.ets`：Lumi 账号登录原型

### 商城模块

商城模块模拟智能家居设备购买闭环：

- `storehome.ets`：商城首页，展示全屋升级套装和精选商品
- `storecategory.ets`：按家庭场景分类选购
- `storeproduct.ets`：商品详情、购买数量、推荐搭配、加入购物车
- `storecart.ets`：购物车、优惠、结算和订单生成
- `storeorders.ets`：订单、订阅、物流和安装服务入口
- `storetracking.ets`：承接查看物流、管理订阅、申请售后三类订单操作
- `storeservice.ets`：售后服务、保修、工单和发票

商城数据目前是页面内的本地模拟数据，适合展示页面流和交互，不代表真实库存、支付或订单系统。

## 项目结构

```text
SmartHome/
  AppScope/
    app.json5
    resources/
  entry/
    src/main/
      ets/
        entryability/EntryAbility.ets
        entrybackupability/EntryBackupAbility.ets
        components/DeviceDetailPages.ets
        pages/
          Index.ets
          my/
          store/
        smart/
      resources/
        base/
          element/
          media/
          profile/main_pages.json
        rawfile/
          models-glb/
          models-gltf/
    src/test/
    src/ohosTest/
  hvigor/
  image/
  report_assets/
  scripts/
  PRODUCT.md
  README.md
```

关键文件：

- `entry/src/main/ets/entryability/EntryAbility.ets`：应用入口 Ability，加载 `pages/Index`
- `entry/src/main/resources/base/profile/main_pages.json`：HarmonyOS 页面路由注册表
- `entry/src/main/module.json5`：模块配置、设备类型和权限声明
- `entry/src/main/ets/pages/Index.ets`：主界面和底部 tab 容器
- `entry/src/main/ets/pages/my`：我的模块页面
- `entry/src/main/ets/pages/store`：商城模块页面
- `entry/src/main/ets/smart`：智能助手、指令解析和 DeepSeek 服务
- `PRODUCT.md`：产品定位、用户、设计原则和素材来源说明

## 资源情况

当前项目包含：

- `entry/src/main/resources/base/media`：48 个媒体资源
- `entry/src/main/resources/rawfile/models-glb`：GLB 模型资源
- `entry/src/main/resources/rawfile/models-gltf`：GLTF 模型资源
- `image/`：早期房间状态图
- `report_assets/`：报告插图素材

原型 3D 家具模型来自 Kenney Furniture Kit 2.0，许可证文件位于：

- `entry/src/main/resources/rawfile/models/KENNEY_LICENSE.txt`
- `entry/src/main/resources/rawfile/models-glb/KENNEY_LICENSE.txt`
- `entry/src/main/resources/rawfile/models-gltf/KENNEY_LICENSE.txt`

## 分支盘点

我只读检查了当前仓库的本地分支和远程分支文件树，没有切换、合并或提交。

当前本地分支：

- `store`：当前所在分支，包含首页、我的、商城和智能助手相关代码
- `main`：本地 main 是较早的入口页结构

远端分支概况：

| 分支 | 文件数 | App 页面数 | 主要内容 |
| --- | ---: | ---: | --- |
| `origin/main` | 178 | 14 | 完整 App 工程，包含首页、智能助手、我的模块和商城模块 |
| `origin/store` | 178 | 14 | 完整 App 工程，页面结构与当前 store 分支一致 |
| `origin/mainDetailedInterface` | 178 | 14 | 完整 App 工程，包含当前这批 `my` 和 `store` 页面 |
| `origin/message` | 178 | 14 | 完整 App 工程，包含消息/我的/商城等页面 |
| `origin/AIAgent` | 159 | 1 | 以首页和智能助手为主，包含 `entry/src/main/ets/smart`，但没有 `my` 和 `store` 页面目录 |
| `origin/ServerBackend` | 147 | 1 | 以首页和智能助手相关代码为主，未发现独立后端服务目录，也没有 `my` 和 `store` 页面目录 |
| `origin/firmware` | 33677 | 0 | 大体量 OpenHarmony/固件类代码树，包含 `applications`、`base`、`build`、`device`、`drivers`、`foundation`、`kernel`、`vendor` 等目录，不是当前 ArkTS App 页面工程 |

所以，当前 README 描述的 16 个页面以本地 `store` 分支为准，其中新增的家庭健康报告和订单跟踪页用于补齐我的/商城流程闭环。远端 `origin/main`、`origin/store`、`origin/mainDetailedInterface` 和 `origin/message` 在只读盘点时是 14 个 App 页面；`origin/AIAgent` 和 `origin/ServerBackend` 更像早期/专项分支，只保留入口页和智能相关代码；`origin/firmware` 是另一类固件工程，不参与当前 App 页面数量统计。

## 运行和预览

推荐使用 DevEco Studio 打开工程：

1. 打开 `SmartHome` 根目录。
2. 等待 oh_modules / hvigor 配置加载完成。
3. 选择 `entry` 模块。
4. 使用 Previewer 或模拟器运行。

应用启动路径：

```text
EntryAbility -> windowStage.loadContent('pages/Index') -> Index.ets
```

底部 tab 当前包含：

- 首页
- 智能
- 商城
- 我的

商城和我的页面已经在 `Index.ets` 中以内嵌组件方式接入：

- 商城 tab 渲染 `P31_StoreHome`
- 我的 tab 渲染 `P21_MyProfile`

## 测试

项目包含 4 个 ArkTS 测试文件，分布在：

- `entry/src/test`
- `entry/src/ohosTest`

当前仓库根目录没有发现本地 `hvigorw` 包装脚本，因此命令行构建通常依赖 DevEco Studio 自带工具链。实际构建和预览建议以 DevEco Studio 为准。

## 当前状态

已经完成或具备原型能力：

- 首页空间化中控
- 房间和设备点位交互
- 设备控制面板和详情面板
- 智能助手入口、本地指令解析和 DeepSeek 服务接入点
- 我的模块：登录、设备、家庭、消息、授权中心
- 商城模块：商城首页、分类、商品详情、购物车、订单、售后
- 暗色/夜间状态在多个页面中通过 `isNight` 参数保持一致

仍属于原型或待接入：

- 真实 IoT 设备通信
- 账号认证后端
- 真实订单、支付、库存和物流
- 数据持久化和跨设备同步
- DeepSeek API key 的安全配置和生产环境代理
- 更完整的自动化规则编辑、保存和执行

## 设计方向

项目产品原则来自 `PRODUCT.md`：

- Minimal
- Calm
- Spatial
- Direct manipulation over nested settings

也就是尽量避免把智能家居做成拥挤的设备后台，而是让用户先看到家庭空间，再直接操作位于空间中的设备、场景和服务。
