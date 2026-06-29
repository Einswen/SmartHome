import router from '@ohos.router';

interface CartRouteParams {
  isNight?: boolean;
  addedProductId?: string;
  addedCount?: number;
}

interface CartItemSpec {
  id: string;
  title: string;
  desc: string;
  price: string;
  count: number;
  image: Resource;
}

const CART_ITEMS: CartItemSpec[] = [
  { id: 'gateway_m2', title: 'Lumi 网关 M2', desc: '全屋中枢，适配蓝牙 Mesh / Zigbee', price: '¥369', count: 1, image: $r('app.media.device_lumi_gateway') },
  { id: 'light_module', title: '智能照明模块', desc: '适配客厅主灯与氛围灯联动', price: '¥129', count: 2, image: $r('app.media.device_living_light') }
];

const CART_CATALOG: CartItemSpec[] = [
  { id: 'sensor_pro', title: '环境传感器 Pro', desc: '温湿度、光照、人体存在三合一', price: '¥199', count: 1, image: $r('app.media.device_environment_sensor') },
  { id: 'light_module', title: '智能照明模块', desc: '适配客厅主灯与氛围灯联动', price: '¥129', count: 1, image: $r('app.media.device_living_light') },
  { id: 'gesture_panel', title: '手势控制面板', desc: '无接触切换家庭场景', price: '¥299', count: 1, image: $r('app.media.device_gesture_sensor') },
  { id: 'robot_pack', title: '清洁维护套装', desc: '主刷、边刷、滤网组合装', price: '¥89', count: 1, image: $r('app.media.device_living_robot') },
  { id: 'gateway_m2', title: 'Lumi 网关 M2', desc: '全屋中枢，适配蓝牙 Mesh / Zigbee', price: '¥369', count: 1, image: $r('app.media.device_lumi_gateway') },
  { id: 'filter', title: '净化器滤芯', desc: '适配空气净化器，建议 6 个月更换', price: '¥159', count: 1, image: $r('app.media.device_living_purifier') },
  { id: 'living_curtain_motor', title: '智能窗帘电机', desc: '接入日照跟随和观影联动', price: '¥249', count: 1, image: $r('app.media.device_living_curtain') },
  { id: 'bedroom_air_guard', title: '睡眠空调伴侣', desc: '夜间降噪和温度曲线控制', price: '¥169', count: 1, image: $r('app.media.device_bedroom_air') },
  { id: 'door_sensor', title: '门窗安全传感器', desc: '门磁、夜间提醒和离家安防联动', price: '¥99', count: 1, image: $r('app.media.device_bedroom_door') },
  { id: 'robot_dock', title: '机器人回充底座', desc: '改善多房间回充路径识别', price: '¥139', count: 1, image: $r('app.media.device_bedroom_robot') }
];

@Entry
@Component
struct StoreCartPage {
  @State showEmpty: boolean = false;
  @State networkFailed: boolean = false;
  @State selectedAll: boolean = true;
  @State checkoutDone: boolean = false;
  @State isNight: boolean = false;
  @State addedProductId: string = '';
  @State addedCount: number = 1;
  @StorageLink('cartAddedProductId') cartAddedProductId: string = '';
  @StorageLink('cartAddedCount') cartAddedCount: number = 0;
  @StorageLink('cartLinePayload') cartLinePayload: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as CartRouteParams | undefined;
    if (params && params.isNight !== undefined) {
      this.isNight = params.isNight;
    }
    if (params && params.addedProductId !== undefined) {
      this.addedProductId = params.addedProductId;
    }
    if (params && params.addedCount !== undefined) {
      this.addedCount = params.addedCount;
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

  private items(): CartItemSpec[] {
    if (this.showEmpty) {
      return [];
    }
    const nextItems: CartItemSpec[] = [];
    for (let baseIndex = 0; baseIndex < CART_ITEMS.length; baseIndex++) {
      const baseItem = CART_ITEMS[baseIndex];
      nextItems.push({
        id: baseItem.id,
        title: baseItem.title,
        desc: baseItem.desc,
        price: baseItem.price,
        count: baseItem.count,
        image: baseItem.image
      });
    }

    let payload: string = this.cartLinePayload;
    if (payload.length === 0) {
      const effectiveProductId: string = this.addedProductId.length > 0 ? this.addedProductId : this.cartAddedProductId;
      const effectiveCount: number = this.addedProductId.length > 0 ? this.addedCount : this.cartAddedCount;
      if (effectiveProductId.length > 0 && effectiveCount > 0) {
        payload = `${effectiveProductId}:${effectiveCount}`;
      }
    }

    if (payload.length === 0) {
      return nextItems;
    }

    const lines: string[] = payload.split(';');
    for (let lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      const pair: string[] = lines[lineIndex].split(':');
      if (pair.length !== 2 || pair[0].length === 0) {
        continue;
      }
      const parsedCount: number = Number(pair[1]);
      const lineCount: number = isNaN(parsedCount) ? 0 : parsedCount;
      if (lineCount <= 0) {
        continue;
      }
      let merged: boolean = false;
      for (let itemIndex = 0; itemIndex < nextItems.length; itemIndex++) {
        const current = nextItems[itemIndex];
        if (current.id === pair[0]) {
          const mergedItem: CartItemSpec = {
            id: current.id,
            title: current.title,
            desc: current.desc,
            price: current.price,
            count: current.count + lineCount,
            image: current.image
          };
          nextItems[itemIndex] = mergedItem;
          merged = true;
        }
      }
      if (merged) {
        continue;
      }
      for (let catalogIndex = 0; catalogIndex < CART_CATALOG.length; catalogIndex++) {
        if (CART_CATALOG[catalogIndex].id === pair[0]) {
          const addedItem: CartItemSpec = {
            id: CART_CATALOG[catalogIndex].id,
            title: CART_CATALOG[catalogIndex].title,
            desc: CART_CATALOG[catalogIndex].desc,
            price: CART_CATALOG[catalogIndex].price,
            count: lineCount,
            image: CART_CATALOG[catalogIndex].image
          };
          nextItems.push(addedItem);
        }
      }
    }
    return nextItems;
  }

  private priceNumber(id: string): number {
    if (id === 'sensor_pro') {
      return 199;
    }
    if (id === 'light_module') {
      return 129;
    }
    if (id === 'gesture_panel') {
      return 299;
    }
    if (id === 'robot_pack') {
      return 89;
    }
    if (id === 'gateway_m2') {
      return 369;
    }
    if (id === 'filter') {
      return 159;
    }
    if (id === 'living_curtain_motor') {
      return 249;
    }
    if (id === 'bedroom_air_guard') {
      return 169;
    }
    if (id === 'door_lock_battery') {
      return 69;
    }
    return 0;
  }

  private totalText(): string {
    if (!this.selectedAll) {
      return '¥0';
    }
    const currentItems: CartItemSpec[] = this.items();
    let total: number = 0;
    for (let i = 0; i < currentItems.length; i++) {
      total += this.priceNumber(currentItems[i].id) * currentItems[i].count;
    }
    return `¥${total}`;
  }

  build() {
    Column() {
      this.TopBar()
      if (this.networkFailed) {
        this.NetworkState()
      } else {
        Scroll() {
          Column() {
            this.SummaryCard()
            if (this.items().length === 0) {
              this.EmptyState()
            } else {
              ForEach(this.items(), (item: CartItemSpec) => {
                this.CartCard(item)
              }, (item: CartItemSpec) => item.id)
              if (this.checkoutDone) {
                this.CheckoutSuccess()
              }
            }
          }
          .width('100%')
          .padding({ left: 18, right: 18, bottom: 104 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        this.CheckoutBar()
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
      Text('购物车')
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
        .margin({ right: 8 })
        .onClick(() => {
          this.networkFailed = !this.networkFailed;
        })
      Button(this.showEmpty ? '恢复' : '清空')
        .height(34)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#D35B4B')
        .backgroundColor(this.isNight ? '#33D35B4B' : '#FFF1EF')
        .borderRadius(17)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          this.showEmpty = !this.showEmpty;
        })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 28, bottom: 14 })
  }

  @Builder
  SummaryCard() {
    Row() {
      Column() {
        Text('智能套装已合并优惠')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
        Text('网关和照明模块可组成客厅自动化基础包')
          .fontSize(13)
          .fontColor(this.secondaryText())
          .margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Text('省 ¥31')
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .padding({ left: 12, right: 12, top: 7, bottom: 7 })
        .backgroundColor('#D76626')
        .borderRadius(16)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .linearGradient({ angle: 135, colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#23342D', 1.0]] : [['#FFF2D7', 0.0], ['#FFFFFF', 0.64], ['#EAF8F4', 1.0]] })
    .borderRadius(26)
  }

  @Builder
  CheckCircle(selected: boolean, size: number) {
    Stack() {
      Circle()
        .width(size)
        .height(size)
        .fill(selected ? '#F3A33A' : '#00000000')
        .stroke(selected ? '#F3A33A' : (this.isNight ? '#66FFFFFF' : '#B8C0CC'))
        .strokeWidth(1.6)
      if (selected) {
        Text('✓')
          .fontSize(size === 30 ? 17 : 16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
      }
    }
    .width(size)
    .height(size)
    .onClick(() => {
      this.selectedAll = !this.selectedAll;
    })
  }

  @Builder
  CartCard(item: CartItemSpec) {
    Row() {
      this.CheckCircle(this.selectedAll, 28)
      Image(item.image)
        .width(74)
        .height(74)
        .objectFit(ImageFit.Contain)
        .backgroundColor(this.softColor())
        .borderRadius(20)
        .margin({ left: 12 })
      Column() {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
        Text(item.desc)
          .fontSize(12)
          .lineHeight(18)
          .fontColor(this.secondaryText())
          .margin({ top: 5 })
          .maxLines(2)
        Row() {
          Text(item.price)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#D76626')
            .layoutWeight(1)
          Text(`x${item.count}`)
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.secondaryText())
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 12 })
  }

  @Builder
  CheckoutBar() {
    Row() {
      this.CheckCircle(this.selectedAll, 30)
      Text('全选')
        .fontSize(13)
        .fontColor(this.secondaryText())
        .margin({ left: 8 })
      Blank()
      Text(this.totalText())
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#D76626')
        .margin({ right: 12 })
      Button('结算')
        .height(44)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor(this.selectedAll && this.items().length > 0 ? '#F3A33A' : '#B8C0CC')
        .borderRadius(22)
        .padding({ left: 24, right: 24 })
        .onClick(() => {
          if (this.selectedAll && this.items().length > 0) {
            this.checkoutDone = true;
          }
        })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 12, bottom: 18 })
    .backgroundColor(this.cardColor())
  }

  @Builder
  CheckoutSuccess() {
    Column() {
      Row() {
        Text('已生成待支付订单')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .layoutWeight(1)
        Text('待支付')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('#F3A33A')
          .borderRadius(14)
      }
      .width('100%')
      Text('商品已锁定库存，可前往订单页继续支付、查看物流或修改服务预约。')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(this.secondaryText())
        .margin({ top: 8 })
        .width('100%')
      Button('查看订单')
        .height(38)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isNight ? '#11151D' : '#FFFFFF')
        .backgroundColor(this.isNight ? '#F5F7FB' : '#11151D')
        .borderRadius(19)
        .padding({ left: 18, right: 18 })
        .margin({ top: 14 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/store/storeorders', params: { isNight: this.isNight } });
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(this.cardColor())
    .borderRadius(22)
    .margin({ top: 12 })
  }

  @Builder
  EmptyState() {
    Column() {
      Text('购物车是空的')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('你加入的设备、耗材和服务会出现在这里。')
        .fontSize(13)
        .fontColor(this.secondaryText())
        .margin({ top: 8 })
      Button('去商城看看')
        .height(40)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isNight ? '#11151D' : '#FFFFFF')
        .backgroundColor(this.isNight ? '#F5F7FB' : '#11151D')
        .borderRadius(20)
        .padding({ left: 18, right: 18 })
        .margin({ top: 18 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .padding({ left: 28, right: 28, top: 54, bottom: 54 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 12 })
  }

  @Builder
  NetworkState() {
    Column() {
      Blank().height(86)
      Text('购物车同步失败')
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('当前展示本地缓存，恢复网络后会同步最新库存和优惠。')
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
