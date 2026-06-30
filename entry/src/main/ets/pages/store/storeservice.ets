import { safeBack, safeGetParams } from '../../common/SafeRouter';

interface StoreServiceRouteParams {
  isNight?: boolean;
}

@Entry
@Component
struct StoreServicePage {
  @State networkFailed: boolean = false;
  @State activeTicket: string = 'install';
  @State isNight: boolean = false;
  @State selectedService: string = '上门安装';
  @State serviceSubmitted: boolean = false;

  aboutToAppear(): void {
    const params = safeGetParams(this.getUIContext().getRouter()) as StoreServiceRouteParams | undefined;
    if (params && params.isNight !== undefined) {
      this.isNight = params.isNight;
    }
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
            this.ServiceHero()
            this.TicketCard()
            this.ServiceDetail()
            this.ServiceCard('保修查询', '输入 SN 或从已绑定设备中选择，查看保修剩余时间。', '#5E8CFF')
            this.ServiceCard('上门安装', '灯光、窗帘、网关等复杂设备可预约工程师。', '#19B7A4')
            this.ServiceCard('故障工单', '设备离线、控制失败、传感器误报可提交工单。', '#F3A33A')
            this.ServiceCard('退换与发票', '查看退换进度、申请电子发票和订单凭证。', '#7F72F2')
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
      Text('售后服务')
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
        .backgroundColor(this.networkFailed ? '#F3A33A' : this.cardColor())
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
  ServiceHero() {
    Column() {
      Text('服务管家')
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
      Text('保修、安装、工单和发票集中处理，避免页面上方空白。')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(this.secondaryText())
        .margin({ top: 8 })
        .width('100%')
      Row() {
        this.Metric('响应', '2 小时')
        Blank().width(8)
        this.Metric('保内', '5 台')
        Blank().width(8)
        this.Metric('工单', '1 个')
      }
      .width('100%')
      .margin({ top: 16 })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 22, bottom: 22 })
    .linearGradient({ angle: 135, colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#332B1C', 1.0]] : [['#EAF8F4', 0.0], ['#FFFFFF', 0.62], ['#FFF2D7', 1.0]] })
    .borderRadius(26)
  }

  @Builder
  Metric(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text(label)
        .fontSize(11)
        .fontColor(this.secondaryText())
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .height(64)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#CCFFFFFF')
    .borderRadius(18)
  }

  @Builder
  TicketCard() {
    Column() {
      Text('当前工单')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
      Row() {
        this.TicketChip('install', '安装预约')
        this.TicketChip('repair', '离线排查')
        this.TicketChip('invoice', '发票')
      }
      .width('100%')
      .margin({ top: 14 })
      Text(this.activeTicket === 'install' ? '明天 14:00 工程师上门安装智能照明模块。' : this.activeTicket === 'repair' ? '卧室窗帘离线排查工单已创建，等待远程诊断。' : '电子发票申请已受理，预计 24 小时内开具。')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(this.secondaryText())
        .margin({ top: 12 })
        .width('100%')
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 14 })
  }

  @Builder
  TicketChip(id: string, label: string) {
    Text(label)
      .fontSize(12)
      .fontWeight(this.activeTicket === id ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(this.activeTicket === id ? (this.isNight ? '#11151D' : '#FFFFFF') : this.primaryText())
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.activeTicket === id ? (this.isNight ? '#F5F7FB' : '#11151D') : this.softColor())
      .borderRadius(16)
      .margin({ right: 8 })
      .onClick(() => {
        this.activeTicket = id;
      })
  }

  @Builder
  ServiceDetail() {
    Column() {
      Row() {
        Text(this.selectedService)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .layoutWeight(1)
        Text(this.serviceSubmitted ? '已提交' : '处理中')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor('#19B7A4')
          .padding({ left: 9, right: 9, top: 5, bottom: 5 })
          .backgroundColor(this.isNight ? '#3319B7A4' : '#EAF8F4')
          .borderRadius(12)
      }
      .width('100%')
      Text(this.selectedService === '保修查询' ? '已读取 5 台保内设备，可选择设备查看剩余保修和延保方案。' : this.selectedService === '故障工单' ? '可从设备中心带入故障设备，提交后生成诊断记录和处理进度。' : this.selectedService === '退换与发票' ? '支持订单退换、电子发票申请、安装凭证下载。' : '已匹配明天 14:00 上门安装时段，可继续修改地址和联系人。')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(this.secondaryText())
        .margin({ top: 10 })
        .width('100%')
      Text(this.serviceSubmitted ? '已生成服务记录，可在订单页或消息中心查看跟进提醒。' : '选择服务后继续处理，系统会生成工单记录并保留本次上下文。')
        .fontSize(12)
        .lineHeight(18)
        .fontColor(this.secondaryText())
        .margin({ top: 10 })
        .width('100%')
      Button(this.serviceSubmitted ? '已提交处理' : '继续处理')
        .height(38)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isNight ? '#11151D' : '#FFFFFF')
        .backgroundColor(this.isNight ? '#F5F7FB' : '#11151D')
        .borderRadius(19)
        .padding({ left: 18, right: 18 })
        .margin({ top: 14 })
        .onClick(() => {
          this.serviceSubmitted = true;
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 14 })
  }

  @Builder
  ServiceCard(title: string, desc: string, color: string) {
    Row() {
      Column()
        .width(8)
        .height(48)
        .borderRadius(4)
        .backgroundColor(color)
      Column() {
        Text(title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
        Text(desc)
          .fontSize(13)
          .lineHeight(20)
          .fontColor(this.secondaryText())
          .margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 14 })
      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(16)
        .height(16)
        .fillColor(this.secondaryText())
        .opacity(0.56)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 12 })
    .onClick(() => {
      this.selectedService = title;
      this.serviceSubmitted = false;
    })
  }

  @Builder
  NetworkState() {
    Column() {
      Blank().height(86)
      Text('服务列表加载失败')
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('当前无法同步工单和保修信息，请稍后重试。')
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
        .backgroundColor('#F3A33A')
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
