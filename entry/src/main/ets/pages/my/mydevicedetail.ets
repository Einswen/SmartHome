import { safeBack, safeGetParams } from '../../common/SafeRouter';

interface DeviceDetailRouteParams {
  deviceId?: string;
  isNight?: boolean;
}

interface DeviceDetailSpec {
  id: string;
  name: string;
  room: string;
  state: string;
  online: boolean;
  image: Resource;
  desc: string;
  metricA: string;
  metricB: string;
  point: string;
}

const DEVICE_DETAIL_LIST: DeviceDetailSpec[] = [
  { id: 'living_air', name: '客厅空调', room: '客厅', state: '恒温运行', online: true, image: $r('app.media.device_living_air'), desc: '根据室内温差自动调整风速，优先保持沙发区域舒适。', metricA: '24°C', metricB: '自动风', point: '首图北侧温控点' },
  { id: 'living_curtain', name: '客厅窗帘', room: '客厅', state: '半开', online: true, image: $r('app.media.device_living_curtain'), desc: '根据光照强度和观影状态自动调整开合比例。', metricA: '46%', metricB: '612 lx', point: '首图窗边遮阳点' },
  { id: 'living_tv', name: '客厅电视', room: '客厅', state: '待机', online: true, image: $r('app.media.device_living_tv'), desc: '可联动窗帘、灯光和音响输入源，一键进入观影模式。', metricA: 'HDMI 1', metricB: '0.8 W', point: '首图影音点' },
  { id: 'living_purifier', name: '空气净化器', room: '客厅', state: '自动净化', online: true, image: $r('app.media.device_living_purifier'), desc: '空气质量良好，滤芯预计 28 天后需要更换。', metricA: 'PM2.5 优', metricB: '28 天', point: '首图空气点' },
  { id: 'living_robot', name: '扫地机器人', room: '客厅', state: '待命', online: true, image: $r('app.media.device_living_robot'), desc: '已回充，当前电量足够完成一次客厅清洁。', metricA: '86%', metricB: '已回充', point: '首图清洁点' },
  { id: 'living_light', name: '客厅灯', room: '客厅', state: '已关闭', online: true, image: $r('app.media.device_living_light'), desc: '支持与电视、窗帘联动，自动切换观影、回家和夜间路径灯光。', metricA: '68%', metricB: '3600K', point: '首图灯光点' }
];

@Entry
@Component
struct MyDeviceDetailPage {
  @State deviceId: string = 'living_air';
  @State networkFailed: boolean = false;
  @State deviceEnabled: boolean = true;
  @State level: number = 62;
  @State isNight: boolean = false;

  aboutToAppear(): void {
    const params = safeGetParams(this.getUIContext().getRouter()) as DeviceDetailRouteParams | undefined;
    if (params && params.deviceId !== undefined) {
      this.deviceId = params.deviceId;
    }
    if (params && params.isNight !== undefined) {
      this.isNight = params.isNight;
    }
  }

  private page(): DeviceDetailSpec {
    for (let i = 0; i < DEVICE_DETAIL_LIST.length; i++) {
      if (DEVICE_DETAIL_LIST[i].id === this.deviceId) {
        return DEVICE_DETAIL_LIST[i];
      }
    }
    return DEVICE_DETAIL_LIST[0];
  }

  private primaryText(): string {
    return this.isNight ? '#F6F8FC' : '#11151D';
  }

  private secondaryText(): string {
    return this.isNight ? '#A7AFBD' : '#657083';
  }

  private bgColor(): string {
    return this.isNight ? '#070A0F' : '#F4F6FA';
  }

  private cardColor(): string {
    return this.isNight ? '#D9151A22' : '#FFFFFF';
  }

  private softColor(): string {
    return this.isNight ? '#661F2632' : '#F0F4FA';
  }

  build() {
    Column() {
      this.TopBar()

      if (this.networkFailed) {
        this.NetworkState()
      } else {
        Scroll() {
          Column() {
            this.HeroCard(this.page())
            this.ControlCard(this.page())
            this.HealthCard(this.page())
          }
          .width('100%')
          .padding({ left: 18, right: 18, bottom: 28 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor())
  }

  @Builder
  TopBar() {
    Row() {
      Button('<')
        .width(40)
        .height(40)
        .fontSize(20)
        .fontColor(this.primaryText())
        .backgroundColor(this.cardColor())
        .borderRadius(20)
        .onClick(() => {
          safeBack(this.getUIContext().getRouter());
        })

      Text('设备详情')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .margin({ left: 14 })
        .layoutWeight(1)

      Button(this.networkFailed ? '恢复' : '断网')
        .height(34)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.networkFailed ? '#FFFFFF' : this.primaryText())
        .backgroundColor(this.networkFailed ? '#5E8CFF' : this.cardColor())
        .borderRadius(17)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          this.networkFailed = !this.networkFailed;
        })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 28, bottom: 14 })
  }

  @Builder
  HeroCard(page: DeviceDetailSpec) {
    Row() {
      Column() {
        Text(page.name)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
        Text(`${page.room} · ${page.state}`)
          .fontSize(13)
          .fontColor(page.online ? '#20B86D' : '#D35B4B')
          .margin({ top: 7 })
        Text(page.point)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5E8CFF')
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('#EAF0FF')
          .borderRadius(14)
          .margin({ top: 12 })
        Text(page.desc)
          .fontSize(13)
          .lineHeight(21)
          .fontColor(this.secondaryText())
          .margin({ top: 14 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Image(page.image)
        .width(124)
        .height(124)
        .objectFit(ImageFit.Contain)
    }
    .width('100%')
    .padding({ left: 20, right: 12, top: 22, bottom: 22 })
    .linearGradient({ angle: 135, colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#23342D', 1.0]] : [['#E6EEFF', 0.0], ['#FFFFFF', 0.62], ['#EAF8F4', 1.0]] })
    .borderRadius(26)
  }

  @Builder
  ControlCard(page: DeviceDetailSpec) {
    Column() {
      Text('快捷控制')
        .width('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())

      Row() {
        this.ControlButton(this.deviceEnabled ? '已开启' : '已关闭', this.deviceEnabled ? '#35D27A' : '#939BA8')
        this.ControlButton('自动模式', '#5E8CFF')
        this.ControlButton('定时', '#7F72F2')
      }
      .width('100%')
      .margin({ top: 14 })

      Row() {
        Text(page.id === 'living_air' ? '目标值' : '强度')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .layoutWeight(1)
        Text(`${this.level}%`)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5E8CFF')
      }
      .width('100%')
      .margin({ top: 18 })

      Slider({ value: this.level, min: 0, max: 100, step: 1 })
        .width('100%')
        .selectedColor('#5E8CFF')
        .trackColor('#E5EAF2')
        .onChange((value: number) => {
          this.level = value;
        })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 16 })
  }

  @Builder
  ControlButton(label: string, color: string) {
    Button(label)
      .layoutWeight(1)
      .height(40)
      .fontSize(13)
      .fontWeight(FontWeight.Bold)
      .fontColor('#FFFFFF')
      .backgroundColor(color)
      .borderRadius(20)
      .margin({ right: 8 })
      .onClick(() => {
        this.deviceEnabled = !this.deviceEnabled;
      })
  }

  @Builder
  HealthCard(page: DeviceDetailSpec) {
    Column() {
      Text('运行健康')
        .width('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())

      Row() {
        this.HealthMetric('关键指标', page.metricA)
        Blank().width(8)
        this.HealthMetric('状态补充', page.metricB)
      }
      .width('100%')
      .margin({ top: 14 })

      Text(page.online ? '当前设备运行正常，暂无需要处理的异常。' : '设备离线时仍可查看缓存状态，重新上线后会自动同步控制指令。')
        .fontSize(13)
        .lineHeight(21)
        .fontColor(page.online ? this.secondaryText() : '#D35B4B')
        .margin({ top: 14 })
        .width('100%')
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 16 })
  }

  @Builder
  HealthMetric(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text(label)
        .fontSize(11)
        .fontColor(this.secondaryText())
        .margin({ top: 5 })
    }
    .layoutWeight(1)
    .height(72)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.softColor())
    .borderRadius(18)
  }

  @Builder
  NetworkState() {
    Column() {
      Blank().height(86)
      Text('设备详情同步失败')
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('当前网络不可用，控制指令会在恢复连接后再下发。')
        .fontSize(13)
        .lineHeight(21)
        .fontColor(this.secondaryText())
        .textAlign(TextAlign.Center)
        .margin({ left: 36, right: 36, top: 10 })
      Button('重试')
        .height(42)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#5E8CFF')
        .borderRadius(21)
        .padding({ left: 24, right: 24 })
        .margin({ top: 22 })
        .onClick(() => {
          this.networkFailed = false;
        })
    }
    .layoutWeight(1)
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
