import router from '@ohos.router';

interface StoreOrdersRouteParams {
  isNight?: boolean;
}

interface OrderSpec {
  id: string;
  title: string;
  state: string;
  desc: string;
  price: string;
  time: string;
  color: string;
}

const STORE_ORDERS: OrderSpec[] = [
  { id: 'order_1', title: '环境传感器 Pro', state: '运输中', desc: '预计明天 18:00 前送达，已到达上海分拨中心', price: '¥199', time: '今天 10:20', color: '#5E8CFF' },
  { id: 'order_2', title: '净化器滤芯订阅', state: '下月扣款', desc: '每 6 个月自动补货一次，可随时暂停订阅', price: '¥135', time: '06-20', color: '#19B7A4' },
  { id: 'order_3', title: '智能照明模块', state: '已完成', desc: '已安装至客厅主灯线路，售后保障剩余 362 天', price: '¥129', time: '06-12', color: '#F3A33A' }
];

@Entry
@Component
struct StoreOrdersPage {
  @State showEmpty: boolean = false;
  @State networkFailed: boolean = false;
  @State expandedOrderId: string = 'order_1';
  @StorageLink('homeNightMode') isNight: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams() as StoreOrdersRouteParams;
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

  private cardColor(): string {
    return this.isNight ? '#D9151A22' : '#FFFFFF';
  }

  private orders(): OrderSpec[] {
    return this.showEmpty ? [] : STORE_ORDERS;
  }

  private trackingMode(orderId: string): string {
    if (orderId === 'order_2') {
      return 'subscription';
    }
    if (orderId === 'order_3') {
      return 'after_sale';
    }
    return 'logistics';
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
            this.FilterBar()
            if (this.orders().length === 0) {
              this.EmptyState()
            } else {
              ForEach(this.orders(), (item: OrderSpec) => {
                this.OrderCard(item)
              }, (item: OrderSpec) => item.id)
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
      Text('我的订单')
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
  Summary() {
    Row() {
      Column() {
        Text('订单与订阅')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
        Text('物流、耗材订阅、安装服务统一跟踪')
          .fontSize(13)
          .fontColor(this.secondaryText())
          .margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Text('3 单')
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .padding({ left: 13, right: 13, top: 8, bottom: 8 })
        .backgroundColor('#11151D')
        .borderRadius(17)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 22, bottom: 22 })
    .linearGradient({ angle: 135, colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#332B1C', 1.0]] : [['#EAF2FF', 0.0], ['#FFFFFF', 0.62], ['#FFF2D7', 1.0]] })
    .borderRadius(26)
  }

  @Builder
  FilterBar() {
    Row() {
      Text('最近订单')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .layoutWeight(1)
      Button(this.showEmpty ? '恢复' : '空数据')
        .height(32)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#F3A33A')
        .backgroundColor('#FFF4E1')
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
  OrderCard(item: OrderSpec) {
    Column() {
      Row() {
        Column()
          .width(8)
          .height(48)
          .borderRadius(4)
          .backgroundColor(item.color)
        Column() {
          Row() {
            Text(item.title)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.primaryText())
              .layoutWeight(1)
            Text(item.state)
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor(item.color)
          }
          .width('100%')
          Text(item.desc)
            .fontSize(13)
            .lineHeight(20)
            .fontColor(this.secondaryText())
            .margin({ top: 7 })
            .maxLines(2)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 12 })
      }
      .width('100%')
      Row() {
        Text(item.time)
          .fontSize(12)
          .fontColor(this.secondaryText())
          .layoutWeight(1)
        Text(item.price)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#D76626')
      }
      .width('100%')
      .margin({ top: 14 })
      if (this.expandedOrderId === item.id) {
        this.OrderTimeline(item)
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(this.cardColor())
    .borderRadius(22)
    .margin({ top: 12 })
    .onClick(() => {
      this.expandedOrderId = this.expandedOrderId === item.id ? '' : item.id;
    })
  }

  @Builder
  OrderTimeline(item: OrderSpec) {
    Column() {
      Row() {
        this.StepDot(true, item.color)
        Text('订单已确认')
          .fontSize(12)
          .fontColor(this.secondaryText())
          .layoutWeight(1)
        this.StepDot(item.id !== 'order_3', item.color)
        Text(item.state)
          .fontSize(12)
          .fontColor(this.secondaryText())
          .layoutWeight(1)
        this.StepDot(item.id === 'order_3', item.color)
        Text(item.id === 'order_3' ? '已完成' : '待完成')
          .fontSize(12)
          .fontColor(this.secondaryText())
      }
      .width('100%')
      .margin({ top: 14 })

      Row() {
        Button(item.id === 'order_1' ? '查看物流' : item.id === 'order_2' ? '管理订阅' : '申请售后')
          .layoutWeight(1)
          .height(36)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isNight ? '#11151D' : '#FFFFFF')
          .backgroundColor(this.isNight ? '#F5F7FB' : '#11151D')
          .borderRadius(18)
          .margin({ right: 8 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/store/storetracking', params: { orderId: item.id, mode: this.trackingMode(item.id), isNight: this.isNight } });
          })
        Button('售后支持')
          .layoutWeight(1)
          .height(36)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(item.color)
          .backgroundColor(this.isNight ? '#33262D36' : '#FFF4E1')
          .borderRadius(18)
          .margin({ left: 8 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/store/storeservice', params: { isNight: this.isNight } });
          })
      }
      .width('100%')
      .margin({ top: 14 })
    }
    .width('100%')
  }

  @Builder
  StepDot(done: boolean, color: string) {
    Circle()
      .width(8)
      .height(8)
      .fill(done ? color : (this.isNight ? '#33424A55' : '#D8DEE8'))
      .margin({ right: 6 })
  }

  @Builder
  EmptyState() {
    Column() {
      Text('暂无订单')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('购买设备、耗材订阅和售后服务订单会出现在这里。')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(this.secondaryText())
        .textAlign(TextAlign.Center)
        .margin({ top: 8 })
      Button('去商城选购')
        .height(40)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#11151D')
        .borderRadius(20)
        .padding({ left: 18, right: 18 })
        .margin({ top: 18 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .padding({ left: 30, right: 30, top: 46, bottom: 46 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 12 })
  }

  @Builder
  NetworkState() {
    Column() {
      Blank().height(86)
      Text('订单同步失败')
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('当前显示本地缓存订单，恢复网络后会刷新物流和订阅状态。')
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

