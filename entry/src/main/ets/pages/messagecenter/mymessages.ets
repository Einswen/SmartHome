import router from '@ohos.router';

interface MyMessagesRouteParams {
  isNight?: boolean;
}

interface NoticeSpec {
  id: string;
  accountId: string;
  title: string;
  desc: string;
  time: string;
  badge: string;
  color: string;
  category: string;
  content: string;
}

interface AccountSpec {
  id: string;
  name: string;
  phone: string;
  role: string;
  color: string;
}

const ACCOUNT_LIST: AccountSpec[] = [
  { id: 'owner', name: 'Lumi 用户', phone: '138 **** 8888', role: '家庭拥有者', color: '#5E79FF' },
  { id: 'parent', name: '家人账号', phone: '136 **** 6620', role: '家庭成员', color: '#12C995' },
  { id: 'backup', name: '备用账号', phone: '159 **** 2066', role: '独立家庭', color: '#F3A33A' }
];

const NOTICE_LIST: NoticeSpec[] = [
  {
    id: 'order',
    accountId: 'owner',
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
    accountId: 'owner',
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
    accountId: 'owner',
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
    accountId: 'owner',
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
    accountId: 'owner',
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
    accountId: 'owner',
    title: '场景执行',
    desc: '离家模式已关闭灯光和窗帘',
    time: '17:20',
    badge: '场',
    color: '#2F80ED',
    category: '场景执行',
    content: '离家模式已完成执行：客厅主灯关闭，卧室窗帘调整至 0%，扫地机器人保持待机。你可以回到首页查看各房间当前状态。'
  },
  {
    id: 'parent_device',
    accountId: 'parent',
    title: '设备提醒',
    desc: '卧室空调已切换为睡眠模式',
    time: '22:10',
    badge: '设',
    color: '#FF9F1C',
    category: '设备消息',
    content: '家人账号下的卧室空调已切换为睡眠模式，温度保持 23°C，风速调整为低档。'
  },
  {
    id: 'parent_family',
    accountId: 'parent',
    title: '家庭共享',
    desc: '家庭成员权限已同步',
    time: '16:40',
    badge: '家',
    color: '#12C995',
    category: '家庭事件',
    content: '家庭成员权限已完成同步。家人账号可查看常用设备、场景状态和基础家庭事件。'
  },
  {
    id: 'service_order',
    accountId: 'backup',
    title: '物流更新',
    desc: '智能照明模块正在配送',
    time: '14:05',
    badge: '物',
    color: '#F3A33A',
    category: '商城订单',
    content: '智能照明模块已从本地仓发出，预计明天送达。安装服务会在签收后继续提醒。'
  },
  {
    id: 'service_ticket',
    accountId: 'backup',
    title: '工单进度',
    desc: '售后工单已生成服务记录',
    time: '11:20',
    badge: '售',
    color: '#7F72F2',
    category: '售后服务',
    content: '售后工单已生成服务记录，当前状态为待上门。服务完成后会同步保修和安装凭证。'
  }
];

@Entry
@Component
struct MyMessagesPage {
  @State isNight: boolean = false;
  @State selectedNoticeId: string = '';
  @State selectedAccountId: string = 'owner';
  @State accountPanelVisible: boolean = false;

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
    return this.isNight ? '#070A0F' : '#F5F5F5';
  }

  private panelColor(): string {
    return this.isNight ? '#661F2632' : '#FFFFFFFF';
  }

  private cardColor(): string {
    return this.isNight ? '#661F2632' : '#FFFFFFFF';
  }

  private lineColor(): string {
    return this.isNight ? '#20FFFFFF' : '#12000000';
  }

  private currentAccount(): AccountSpec {
    for (let index = 0; index < ACCOUNT_LIST.length; index++) {
      if (ACCOUNT_LIST[index].id === this.selectedAccountId) {
        return ACCOUNT_LIST[index];
      }
    }
    return ACCOUNT_LIST[0];
  }

  private accountMessages(): NoticeSpec[] {
    const messages: NoticeSpec[] = [];
    for (let index = 0; index < NOTICE_LIST.length; index++) {
      if (NOTICE_LIST[index].accountId === this.selectedAccountId) {
        messages.push(NOTICE_LIST[index]);
      }
    }
    return messages;
  }

  private selectedNotice(): NoticeSpec {
    for (let index = 0; index < NOTICE_LIST.length; index++) {
      if (NOTICE_LIST[index].id === this.selectedNoticeId) {
        return NOTICE_LIST[index];
      }
    }
    return NOTICE_LIST[0];
  }

  private backToHome(): void {
    router.replaceUrl({ url: 'pages/Index', params: { isNight: this.isNight, activeTab: 'home' } });
  }

  build() {
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
    .padding({ left: 24, right: 24, top: 34, bottom: 24 })
    .backgroundColor(this.bgColor())
  }

  @Builder
  PageTitle() {
    Column() {
      Row() {
        Button('<')
          .width(34)
          .height(34)
          .fontSize(21)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .backgroundColor('#00000000')
          .borderRadius(17)
          .padding({ left: 0, right: 0 })
          .margin({ right: 10 })
          .onClick(() => {
            if (this.selectedNoticeId !== '') {
              this.selectedNoticeId = '';
            } else {
              this.backToHome();
            }
          })

        Column() {
          Text(this.selectedNoticeId === '' ? '消息中心' : this.selectedNotice().title)
            .fontSize(27)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())

          Text(this.selectedNoticeId === '' ? `${this.currentAccount().name} · ${this.accountMessages().length}条消息` : `${this.selectedNotice().category} · ${this.selectedNotice().time}`)
            .fontSize(12)
            .fontColor(this.secondaryText())
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        if (this.selectedNoticeId === '') {
          Column() {
            Text(this.currentAccount().name.substring(0, 1))
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .width(34)
          .height(34)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor(this.currentAccount().color)
          .borderRadius(17)
          .onClick(() => {
            this.accountPanelVisible = !this.accountPanelVisible;
          })
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      if (this.selectedNoticeId === '') {
        if (this.accountPanelVisible) {
          Row() {
            Blank()

            Column() {
              ForEach(ACCOUNT_LIST, (account: AccountSpec) => {
                this.AccountItem(account)
              }, (account: AccountSpec) => account.id)
            }
            .width(190)
            .backgroundColor(this.cardColor())
            .border({
              width: 1,
              color: this.lineColor()
            })
            .borderRadius(16)
          }
          .width('100%')
          .margin({ top: 8 })
        }
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 6 })
  }

  @Builder
  AccountItem(account: AccountSpec) {
    Row() {
      Column()
        .width(8)
        .height(8)
        .borderRadius(4)
        .backgroundColor(account.color)

      Column() {
        Text(account.name)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())

        Text(account.role)
          .fontSize(10)
          .fontColor(this.secondaryText())
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 10 })

      if (this.selectedAccountId === account.id) {
        Text('当前')
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .fontColor(account.color)
      }
    }
    .width('100%')
    .height(46)
    .padding({ left: 12, right: 12 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.selectedAccountId = account.id;
      this.selectedNoticeId = '';
      this.accountPanelVisible = false;
    })
  }

  @Builder
  NoticePanel() {
    Column() {
      ForEach(this.accountMessages(), (notice: NoticeSpec) => {
        this.NoticeItem(notice)
      }, (notice: NoticeSpec) => notice.id)
    }
    .width('100%')
    .backgroundColor(this.cardColor())
    .borderRadius(10)
  }

  @Builder
  NoticeItem(notice: NoticeSpec) {
    Column() {
      Row() {
        Column() {
          Text(notice.badge)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(notice.color)
        .borderRadius(20)

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
            .margin({ top: 6 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 13 })

        Column() {
          Text(notice.time)
            .fontSize(11)
            .fontColor(this.secondaryText())
        }
        .alignItems(HorizontalAlign.End)
        .margin({ left: 8 })
      }
      .width('100%')
      .height(68)
      .padding({ left: 14, right: 14 })
      .alignItems(VerticalAlign.Center)

      Row() {
        Blank()
          .width(67)

        Column()
          .height(1)
          .layoutWeight(1)
          .backgroundColor(this.lineColor())
      }
      .width('100%')
      .padding({ right: 14 })
    }
    .width('100%')
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
