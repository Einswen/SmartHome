import router from '@ohos.router';

interface MyMessagesRouteParams {
  isNight?: boolean;
}

interface MessageSpec {
  id: string;
  title: string;
  desc: string;
  time: string;
  level: string;
  color: string;
}

const MESSAGE_LIST: MessageSpec[] = [
  { id: 'light', title: '客厅灯已关闭', desc: '夜间模式生效，商城和我的页面已同步切换为深色视觉。', time: '10:42', level: '设备', color: '#5E8CFF' },
  { id: 'auto', title: '离家模式已执行', desc: '已关闭客厅电视、主灯与空气净化器。', time: '09:16', level: '自动化', color: '#19B7A4' },
  { id: 'mall', title: '滤芯补货提醒', desc: '空气净化器滤芯预计 12 天后到期，可在商城一键订阅。', time: '昨天', level: '服务', color: '#F3A33A' }
];

@Entry
@Component
struct MyMessagesPage {
  @State showEmpty: boolean = false;
  @State networkFailed: boolean = false;
  @State isNight: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams() as MyMessagesRouteParams | undefined;
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

  private messages(): MessageSpec[] {
    return this.showEmpty ? [] : MESSAGE_LIST;
  }

  build() {
    Column() {
      this.TopBar()

      if (this.networkFailed) {
        this.NetworkState()
      } else {
        Scroll() {
          Column() {
            this.Summary()
            this.MessageHeader()

            if (this.messages().length === 0) {
              this.EmptyState()
            } else {
              ForEach(this.messages(), (message: MessageSpec) => {
                this.MessageCard(message)
              }, (message: MessageSpec) => message.id)
            }
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

      Text('消息中心')
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
  Summary() {
    Column() {
      Text('需要关注 1 条')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
      Text('系统已按设备、自动化、服务三类聚合，重要告警会保持置顶。')
        .fontSize(13)
        .lineHeight(21)
        .fontColor(this.secondaryText())
        .width('100%')
        .margin({ top: 8 })
      Row() {
        this.Metric('设备', '1')
        Blank().width(8)
        this.Metric('自动化', '1')
        Blank().width(8)
        this.Metric('服务', '1')
      }
      .width('100%')
      .margin({ top: 16 })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 22, bottom: 22 })
    .linearGradient({ angle: 135, colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#332B1C', 1.0]] : [['#E6EEFF', 0.0], ['#FFFFFF', 0.62], ['#FFF2D7', 1.0]] })
    .borderRadius(26)
  }

  @Builder
  Metric(label: string, value: string) {
    Column() {
      Text(value).fontSize(18).fontWeight(FontWeight.Bold).fontColor(this.primaryText())
      Text(label).fontSize(11).fontColor(this.secondaryText()).margin({ top: 4 })
    }
    .layoutWeight(1)
    .height(62)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.isNight ? '#331E2530' : '#CCFFFFFF')
    .borderRadius(18)
  }

  @Builder
  MessageHeader() {
    Row() {
      Text('最近通知')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .layoutWeight(1)

      Button(this.showEmpty ? '恢复' : '清空')
        .height(32)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5E8CFF')
        .backgroundColor(this.isNight ? '#335E8CFF' : '#EAF0FF')
        .borderRadius(16)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          this.showEmpty = !this.showEmpty;
        })
    }
    .width('100%')
    .margin({ top: 22, bottom: 10 })
  }

  @Builder
  MessageCard(message: MessageSpec) {
    Row() {
      Column()
        .width(8)
        .height(48)
        .borderRadius(4)
        .backgroundColor(message.color)

      Column() {
        Row() {
          Text(message.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())
            .layoutWeight(1)
            .maxLines(1)
          Text(message.time)
            .fontSize(11)
            .fontColor(this.secondaryText())
        }
        .width('100%')

        Text(message.desc)
          .fontSize(12)
          .lineHeight(19)
          .fontColor(this.secondaryText())
          .margin({ top: 6 })
          .maxLines(2)

        Text(message.level)
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .fontColor(message.color)
          .padding({ left: 8, right: 8, top: 5, bottom: 5 })
          .backgroundColor(this.softColor())
          .borderRadius(12)
          .margin({ top: 10 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(this.cardColor())
    .borderRadius(22)
    .margin({ top: 10 })
  }

  @Builder
  EmptyState() {
    Column() {
      Text('暂无消息')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('设备告警、自动化执行与服务提醒会出现在这里。')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(this.secondaryText())
        .textAlign(TextAlign.Center)
        .margin({ top: 8 })
    }
    .width('100%')
    .padding({ left: 30, right: 30, top: 46, bottom: 46 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
  }

  @Builder
  NetworkState() {
    Column() {
      Blank().height(86)
      Text('消息加载失败')
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('当前网络不可用，暂时无法同步最新告警。')
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
