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
  category: string;
  content: string;
}

const NOTICE_LIST: NoticeSpec[] = [
  {
    id: 'order',
    title: '商城订单',
    desc: '智能门锁 Pro 订单已确认',
    time: '21:05',
    badge: '订',
    color: '#F3A33A',
    category: '商城订单',
    content: '你购买的智能门锁 Pro 套装订单已确认，商品库存已锁定。后续物流、安装预约和发票状态会继续在消息中心同步。'
  },
  {
    id: 'system',
    title: '系统通知',
    desc: '家庭安防策略已更新',
    time: '现在',
    badge: '系',
    color: '#5E79FF',
    category: '系统通知',
    content: '系统已同步新的家庭安防策略。夜间模式下门锁、玄关传感器与客厅摄像头会保持联动，如发现异常开门或长时间未关门，会在消息中心继续提醒。'
  },
  {
    id: 'service',
    title: '售后工单',
    desc: '上门安装已匹配明天 14:00',
    time: '19:30',
    badge: '售',
    color: '#7F72F2',
    category: '售后服务',
    content: '售后服务已为智能照明模块匹配明天 14:00 的上门安装时段。安装前可在售后服务中继续修改地址和联系人。'
  },
  {
    id: 'scene',
    title: '家庭事件',
    desc: '玄关门锁已完成夜间布防',
    time: '20:15',
    badge: '家',
    color: '#12C995',
    category: '家庭事件',
    content: '玄关门锁已完成夜间布防，家庭事件记录已保存。当前门锁状态正常，客厅与卧室设备保持原有运行状态。'
  },
  {
    id: 'device',
    title: '设备消息',
    desc: '客厅空调滤网建议本周清洁',
    time: '18:45',
    badge: '设',
    color: '#FF9F1C',
    category: '设备消息',
    content: '客厅空调滤网已接近建议清洁周期。设备仍可正常运行，建议本周完成滤网清洁，保持送风效率和室内空气质量。'
  },
  {
    id: 'automation',
    title: '场景执行',
    desc: '离家模式已关闭灯光和窗帘',
    time: '17:20',
    badge: '场',
    color: '#2F80ED',
    category: '场景执行',
    content: '离家模式已完成执行：客厅主灯关闭，卧室窗帘调整至 0%，扫地机器人保持待机。你可以回到首页查看各房间当前状态。'
  }
];

@Entry
@Component
struct MyMessagesPage {
  @State isNight: boolean = false;
  @State selectedNoticeId: string = '';

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

  private selectedNotice(): NoticeSpec {
    for (let index = 0; index < NOTICE_LIST.length; index++) {
      if (NOTICE_LIST[index].id === this.selectedNoticeId) {
        return NOTICE_LIST[index];
      }
    }
    return NOTICE_LIST[0];
  }

  build() {
    Stack() {
      this.PageAtmosphere()

      Column() {
        this.PageTitle()
        if (this.selectedNoticeId === '') {
          this.NoticePanel()
        } else {
          this.NoticeDetailPanel(this.selectedNotice())
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 28, right: 28, top: 50, bottom: 38 })
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
      Button('<')
        .width(40)
        .height(40)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .backgroundColor(this.cardColor())
        .border({
          width: 1,
          color: this.lineColor()
        })
        .borderRadius(20)
        .padding({ left: 0, right: 0 })
        .margin({ right: 12 })
        .onClick(() => {
          if (this.selectedNoticeId !== '') {
            this.selectedNoticeId = '';
          } else {
            router.back();
          }
        })

      Column() {
        Text(this.selectedNoticeId === '' ? '消息中心' : this.selectedNotice().title)
          .fontSize(31)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())

        Text(this.selectedNoticeId === '' ? '家庭通知、设备与商城服务' : `${this.selectedNotice().category} · ${this.selectedNotice().time}`)
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

        Text(`${NOTICE_LIST.length}条`)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.secondaryText())
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
    .margin({ bottom: 14 })
  }

  @Builder
  NoticeItem(notice: NoticeSpec) {
    Row() {
      Column() {
        Text(notice.badge)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(notice.color)
      .borderRadius(22)

      Column() {
        Row() {
          Text(notice.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())
            .maxLines(1)
            .layoutWeight(1)

          Text(notice.category)
            .fontSize(10)
            .fontWeight(FontWeight.Bold)
            .fontColor(notice.color)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor(this.isNight ? '#18232C36' : '#F7F8FB')
            .borderRadius(10)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

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

      Text('>')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.secondaryText())
        .margin({ left: 8 })
    }
    .width('100%')
    .height(66)
    .padding({ left: 14, right: 14 })
    .backgroundColor(this.cardColor())
    .border({
      width: 1,
      color: this.lineColor()
    })
    .borderRadius(20)
    .margin({ top: 10 })
    .onClick(() => {
      this.selectedNoticeId = notice.id;
    })
  }

  @Builder
  NoticeDetailPanel(notice: NoticeSpec) {
    Column() {
      Row() {
        Text('消息详情')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .layoutWeight(1)

        Text(notice.category)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(notice.color)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 14 })

      Row() {
        Column() {
          Text(notice.badge)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(notice.color)
        .borderRadius(22)

        Column() {
          Text(notice.title)
            .fontSize(19)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())

          Text(`${notice.time} · ${notice.desc}`)
            .fontSize(12)
            .fontColor(this.secondaryText())
            .maxLines(1)
            .margin({ top: 5 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text(notice.content)
        .fontSize(14)
        .fontColor(this.secondaryText())
        .lineHeight(23)
        .margin({ top: 18 })

      Row() {
        Text('已读')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(notice.color)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(this.isNight ? '#18232C36' : '#F7F8FB')
          .borderRadius(12)

        Blank()

        Text('已同步')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.secondaryText())
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ top: 20 })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(this.panelColor())
    .border({
      width: 1,
      color: this.lineColor()
    })
    .borderRadius(24)
  }
}
