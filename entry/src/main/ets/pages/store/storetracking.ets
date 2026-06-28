import router from '@ohos.router';

interface StoreTrackingRouteParams {
  orderId?: string;
  mode?: string;
  isNight?: boolean;
}

interface TrackStepSpec {
  title: string;
  desc: string;
  done: boolean;
}

@Entry
@Component
struct StoreTrackingPage {
  @StorageLink('homeNightMode') isNight: boolean = false;
  @State orderId: string = 'order_1';
  @State mode: string = 'logistics';
  @State reminderEnabled: boolean = true;
  @State serviceBooked: boolean = false;
  @State networkFailed: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams() as StoreTrackingRouteParams;
    if (params.orderId !== undefined) {
      this.orderId = params.orderId;
    }
    if (params.mode !== undefined) {
      this.mode = params.mode;
    }
    if (params.isNight !== undefined) {
      this.isNight = params.isNight;
    }
  }

  private title(): string {
    if (this.mode === 'subscription') {
      return '订阅管理';
    }
    if (this.mode === 'after_sale') {
      return '售后申请';
    }
    return '物流跟踪';
  }

  private subtitle(): string {
    if (this.mode === 'subscription') {
      return '耗材周期、下次扣款和配送地址集中管理';
    }
    if (this.mode === 'after_sale') {
      return '选择问题类型后生成服务工单并同步消息中心';
    }
    return '订单已出库，安装预约和配送进度保持同步';
  }

  private orderLabel(): string {
    if (this.orderId === 'order_2') {
      return '净化器滤芯订阅';
    }
    if (this.orderId === 'order_3') {
      return '上门安装服务';
    }
    return '全屋升级套装';
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

  private lineColor(): string {
    return this.isNight ? '#20FFFFFF' : '#12000000';
  }

  private accentColor(): string {
    if (this.mode === 'subscription') {
      return '#35D27A';
    }
    if (this.mode === 'after_sale') {
      return '#7F72F2';
    }
    return '#F3A33A';
  }

  private steps(): TrackStepSpec[] {
    if (this.mode === 'subscription') {
      return [
        { title: '订阅生效', desc: '已绑定空气净化器滤芯', done: true },
        { title: '下次配送', desc: '预计 7 月 18 日发出', done: true },
        { title: '扣款提醒', desc: this.reminderEnabled ? '提前 3 天通知' : '已关闭提醒', done: this.reminderEnabled }
      ];
    }
    if (this.mode === 'after_sale') {
      return [
        { title: '选择问题', desc: '设备、订单或安装服务', done: true },
        { title: '生成工单', desc: this.serviceBooked ? '已生成服务记录' : '等待提交', done: this.serviceBooked },
        { title: '专员跟进', desc: '预计 2 小时内响应', done: false }
      ];
    }
    return [
      { title: '订单确认', desc: '库存已锁定，服务单已创建', done: true },
      { title: '仓库出库', desc: '网关和传感器已打包', done: true },
      { title: '上门安装', desc: this.serviceBooked ? '明天 14:00 已预约' : '等待选择时间', done: this.serviceBooked }
    ];
  }

  build() {
    Column() {
      this.TopBar()

      if (this.networkFailed) {
        this.NetworkState()
      } else {
        Scroll() {
          Column() {
            this.HeroCard()
            this.ProgressCard()
            this.ActionPanel()
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
          router.back();
        })

      Text(this.title())
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
        .backgroundColor(this.networkFailed ? this.accentColor() : this.cardColor())
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
  HeroCard() {
    Column() {
      Text(this.orderLabel())
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')

      Text(this.subtitle())
        .fontSize(13)
        .lineHeight(21)
        .fontColor(this.secondaryText())
        .margin({ top: 8 })
        .width('100%')

      Row() {
        this.MetricChip('订单', this.orderId.toUpperCase())
        this.MetricChip('状态', this.mode === 'after_sale' ? '处理中' : '进行中')
        this.MetricChip('提醒', this.reminderEnabled ? '已开' : '关闭')
      }
      .width('100%')
      .margin({ top: 18 })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 22, bottom: 20 })
    .linearGradient({ angle: 135, colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#332B1C', 1.0]] : [['#FFF2D7', 0.0], ['#FFFFFF', 0.62], ['#EAF2FF', 1.0]] })
    .borderRadius(26)
  }

  @Builder
  MetricChip(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .maxLines(1)
      Text(label)
        .fontSize(11)
        .fontColor(this.secondaryText())
        .margin({ top: 5 })
    }
    .layoutWeight(1)
    .height(66)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.isNight ? '#331E2530' : '#CCFFFFFF')
    .borderRadius(18)
    .margin({ right: 8 })
  }

  @Builder
  ProgressCard() {
    Column() {
      Text('处理进度')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
        .margin({ bottom: 8 })

      ForEach(this.steps(), (item: TrackStepSpec) => {
        Row() {
          Circle()
            .width(12)
            .height(12)
            .fill(item.done ? this.accentColor() : (this.isNight ? '#33424A55' : '#D8DEE8'))
            .margin({ right: 12 })

          Column() {
            Text(item.title)
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.primaryText())
            Text(item.desc)
              .fontSize(12)
              .fontColor(this.secondaryText())
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ top: 12, bottom: 12 })
        .border({ width: { bottom: 1 }, color: this.lineColor() })
      }, (item: TrackStepSpec) => item.title)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 10 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 16 })
  }

  @Builder
  ActionPanel() {
    Column() {
      Text('下一步')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
        .margin({ bottom: 12 })

      Button(this.mode === 'after_sale' ? (this.serviceBooked ? '工单已提交' : '提交售后工单') : (this.serviceBooked ? '预约已确认' : '预约安装时间'))
        .width('100%')
        .height(44)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor(this.accentColor())
        .borderRadius(22)
        .onClick(() => {
          this.serviceBooked = true;
        })

      Button(this.reminderEnabled ? '关闭进度提醒' : '开启进度提醒')
        .width('100%')
        .height(42)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .backgroundColor(this.softColor())
        .borderRadius(21)
        .margin({ top: 10 })
        .onClick(() => {
          this.reminderEnabled = !this.reminderEnabled;
        })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 16 })
  }

  @Builder
  NetworkState() {
    Column() {
      Blank().height(92)
      Text('跟踪信息加载失败')
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('当前无法同步物流、订阅和售后进度，本地会保留上次状态。')
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
        .backgroundColor(this.accentColor())
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
