# SmartHome

> A calm, spatial smart-home control surface for HarmonyOS.

`SmartHome` 是一个基于 HarmonyOS / ArkTS 的智能家居中控项目。它把首页做成了带空间感的 2.5D 房间视图，让用户先“看到家”，再直接操作家里的设备、场景和自动化。

---

## Overview

这个项目面向 HarmonyOS 手机、平板和 2-in-1 设备，核心目标是：

- 在首页直接感知房间状态
- 用 2.5D 场景表达设备的物理位置
- 让设备控制、场景切换和自动化创建尽量直达
- 保持界面安静、克制、可读

---

## Features

### 1. Home-first UI

- 首页以房间为中心，而不是传统设备列表
- 支持客厅、卧室等房间的横向切换
- 右侧尾页支持继续添加房间

### 2. 2.5D Room Interaction

- 房间卡片支持滑动切换
- 房间中的设备通过白点映射到空间位置
- 房间切换时，下方设备面板同步更新

### 3. Device Control

- 支持温控、灯光、安防、空气、影音、清洁等设备类型
- 可为当前房间添加 / 删除设备
- 设备点位与设备区保持联动

### 4. Scene Management

- 支持场景横向滑动切换
- 最右侧提供“添加场景”入口
- 支持从模板快速复制场景
- 支持创建自定义场景

### 5. Detailed Device Pages

- 设备详情采用独立大面板，而不是传统小气泡
- 支持更丰富的指标、动作、联动状态与参数展示

### 6. Smart / Automation Experience

- 首页包含场景、设备、脚本与智能助手相关能力
- 支持基础自动化草稿与智能化交互入口

---

## Tech Stack

- **HarmonyOS**
- **ArkTS**
- **ArkUI**
- **hvigor**
- **Hypium** for tests

---

## Project Structure

```text
SmartHome
├─ AppScope/
├─ entry/
│  ├─ src/main/ets/
│  │  ├─ pages/Index.ets
│  │  ├─ components/DeviceDetailPages.ets
│  │  ├─ entryability/EntryAbility.ets
│  │  └─ smart/
│  ├─ src/main/resources/
│  └─ src/test/
├─ build-profile.json5
├─ hvigorfile.ts
└─ PRODUCT.md
```

关键文件：

- `entry/src/main/ets/pages/Index.ets`：首页主界面、房间 / 场景 / 弹层交互
- `entry/src/main/ets/components/DeviceDetailPages.ets`：设备详情页
- `entry/src/main/ets/entryability/EntryAbility.ets`：应用入口 Ability
- `PRODUCT.md`：产品定位与设计原则

---

## Run

### DevEco Studio

直接使用 DevEco Studio 打开项目后运行预览或模拟器即可。

### Preview

```bash
/Applications/DevEco-Studio.app/Contents/tools/node/bin/node \
/Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw.js \
--mode module -p module=entry@default -p product=default \
-p pageType=page -p compileResInc=true -p previewMode=true \
-p buildRoot=.preview PreviewBuild --analyze=normal --parallel --incremental --daemon
```

### Build Hap

```bash
/Applications/DevEco-Studio.app/Contents/tools/node/bin/node \
/Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw.js \
clean --mode module -p product=default assembleHap \
--analyze=normal --parallel --incremental --daemon
```

---

## Notes

- 当前 `build-profile.json5` 中未配置签名，所以构建时会跳过 `hos_hap` 签名。
- 项目内包含 2.5D 房间图、设备贴图以及原型 3D 家具资源。
- 原型 3D 家具模型部分来自 **Kenney Furniture Kit 2.0 (CC0)**，许可证文件位于：
  - `entry/src/main/resources/rawfile/models/KENNEY_LICENSE.txt`
  - `entry/src/main/resources/rawfile/models-glb/KENNEY_LICENSE.txt`

---

## Design Direction

根据当前产品文档，这个项目强调：

- Minimal
- Calm
- Spatial
- Direct manipulation over nested settings

它更像一个“家的控制界面”，而不是一个堆满卡片的设备管理后台。

---

## Status

当前版本已经具备：

- 首页 2.5D 房间切换
- 设备联动与详情页
- 场景新增入口
- 房间新增入口
- 基础自动化与智能助手界面

后续可以继续扩展：

- 更真实的设备状态同步
- 持久化数据存储
- 场景 / 自动化编辑能力
- 与真实 IoT 设备或云服务对接

---

## License

This project is currently for product prototyping / local development.
