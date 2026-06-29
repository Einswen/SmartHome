import router from '@ohos.router';

interface MyMessagesRouteParams {
  isNight?: boolean;
}

interface NoticeSpec {
  id: string;
  title: string;
  desc: string;
  time: string;
  badge: string;
  color: string;
  route?: string;
}

const NOTICE_LIST: NoticeSpec[] = [
  {
    id: 'assistant',
    title: '智能助手',
    desc: '点击进入智能助手对话',
    time: '现在',
    badge: 'AI',
    color: '#6C86FF',
    route: 'pages/Index'
  },
  {
    id: 'scene',
    title: '场景执行',
    desc: '智能场景执行记录已同步',
    time: '20:15',
    badge: '场',
    color: '#FF9F1C'
  },
  {
    id: 'device',
    title: '设备提醒',
    desc: '客厅设备状态保持正常',
    time: '18:45',
    badge: '设',
    color: '#FF9F1C'
  }
];

@Entry
@Component
struct MyMessagesPage {
  @State isNight: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams() as MyMessagesRouteParams;
    if (params.isNight !== undefined) {
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

  private panelColor(): string {
    return this.isNight ? '#D9151A22' : '#EFFFFFFF';
  }

  private cardColor(): string {
    return this.isNight ? '#661F2632' : '#FFFFFFFF';
  }

  private lineColor(): string {
    return this.isNight ? '#20FFFFFF' : '#12000000';
  }

  private softBlue(): string {
    return this.isNight ? '#223A5E8C' : '#DCEAFF';
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      this.PageAtmosphere()

      Column() {
        this.PageTitle()
        this.NoticePanel()
      }
      .width('100%')
      .height('100%')
      .padding({ left: 28, right: 28, top: 50, bottom: 118 })

      this.BottomNav()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor())
  }

  @Builder
  PageAtmosphere() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.bgColor())

      Column()
        .width(430)
        .height(290)
        .borderRadius(160)
        .backgroundColor(this.softBlue())
        .position({ x: 44, y: -84 })

      Column()
        .width(500)
        .height(300)
        .borderRadius(180)
        .backgroundColor(this.isNight ? '#222B2018' : '#F7E9D4')
        .position({ x: 56, y: 610 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  PageTitle() {
    Row() {
      Column() {
        Text('消息中心')
          .fontSize(31)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())

        Text('智能消息与助手入口')
          .fontSize(12)
          .fontColor(this.secondaryText())
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column()
        .width(9)
        .height(9)
        .borderRadius(5)
        .backgroundColor('#12C995')
        .margin({ right: 6 })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 20 })
  }

  @Builder
  NoticePanel() {
    Column() {
      Row() {
        Text('消息通知')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .layoutWeight(1)

        Text('全部')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5E79FF')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 10 })

      ForEach(NOTICE_LIST, (notice: NoticeSpec) => {
        this.NoticeItem(notice)
      }, (notice: NoticeSpec) => notice.id)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 12 })
    .backgroundColor(this.panelColor())
    .border({
      width: 1,
      color: this.lineColor()
    })
    .borderRadius(24)
  }

  @Builder
  NoticeItem(notice: NoticeSpec) {
    Row() {
      Column() {
        Text(notice.badge)
          .fontSize(notice.badge === 'AI' ? 18 : 17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')

        if (notice.id === 'assistant') {
          Text('2/2')
            .fontSize(9)
            .fontColor('#EAF0FF')
            .margin({ top: 2 })
        }
      }
      .width(notice.id === 'assistant' ? 50 : 44)
      .height(notice.id === 'assistant' ? 50 : 44)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(notice.color)
      .borderRadius(25)

      Column() {
        Text(notice.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .maxLines(1)

        Text(notice.desc)
          .fontSize(12)
          .fontColor(this.secondaryText())
          .maxLines(1)
          .margin({ top: 5 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 14 })

      Text(notice.time)
        .fontSize(11)
        .fontColor(this.secondaryText())
        .margin({ left: 8 })
    }
    .width('100%')
    .height(notice.id === 'assistant' ? 66 : 66)
    .padding({ left: 14, right: 14 })
    .backgroundColor(this.cardColor())
    .border({
      width: 1,
      color: notice.id === 'assistant' ? '#335E79FF' : this.lineColor()
    })
    .borderRadius(20)
    .margin({ top: 10 })
    .onClick(() => {
      if (notice.route !== undefined) {
        router.pushUrl({ url: notice.route, params: { isNight: this.isNight, activeTab: 'smart' } });
      }
    })
  }

  @Builder
  BottomNav() {
    Row() {
      this.NavItem('家', '家', false)
      this.NavItem('智', '智能', true)
      this.NavItem('商', '商场', false)
      this.NavItem('我', '我的', false)
    }
    .width('100%')
    .height(86)
    .padding({ left: 18, right: 18, top: 10, bottom: 10 })
    .backgroundColor(this.cardColor())
    .borderRadius(30)
    .margin({ left: 28, right: 28, bottom: 28 })
  }

  @Builder
  NavItem(icon: string, label: string, active: boolean) {
    Column() {
      Text(icon)
        .fontSize(22)
        .fontWeight(FontWeight.Medium)
        .fontColor(active ? this.primaryText() : this.secondaryText())

      Text(label)
        .fontSize(13)
        .fontWeight(active ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(active ? this.primaryText() : this.secondaryText())
        .margin({ top: 3 })
    }
    .layoutWeight(1)
    .height(62)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(active ? (this.isNight ? '#33262D36' : '#F7F8FB') : '#00000000')
    .borderRadius(22)
    .onClick(() => {
      if (label === '我的') {
        router.back();
      } else if (label === '智能') {
        router.pushUrl({ url: 'pages/Index', params: { isNight: this.isNight, activeTab: 'smart' } });
      } else if (label === '家') {
        router.pushUrl({ url: 'pages/Index', params: { isNight: this.isNight, activeTab: 'home' } });
      }
    })
  }
}
