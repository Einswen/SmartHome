import { safeBack, safeGetParams, safePushUrl } from '../../common/SafeRouter';

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

const CART_CATALOG: CartItemSpec[] = [
  { id: 'sensor_pro', title: '环境传感器 Pro', desc: '温湿度、光照、人体存在三合一', price: '¥199', count: 1, image: $r('app.media.store_sensor_pro') },
  { id: 'light_module', title: '智能照明模块', desc: '适配客厅主灯与氛围灯联动', price: '¥129', count: 1, image: $r('app.media.store_light_module') },
  { id: 'gesture_panel', title: '手势控制面板', desc: '无接触切换家庭场景', price: '¥299', count: 1, image: $r('app.media.store_gesture_panel') },
  { id: 'robot_pack', title: '清洁维护套装', desc: '主刷、边刷、滤网组合装', price: '¥89', count: 1, image: $r('app.media.store_robot_pack') },
  { id: 'gateway_m2', title: '智能网关 M2', desc: '全屋中枢，适配蓝牙 Mesh / Zigbee', price: '¥369', count: 1, image: $r('app.media.store_gateway_m2') },
  { id: 'filter', title: '净化器滤芯', desc: '适配空气净化器，建议 6 个月更换', price: '¥159', count: 1, image: $r('app.media.device_living_purifier') },
  { id: 'living_curtain_motor', title: '智能窗帘电机', desc: '接入日照跟随和观影联动', price: '¥249', count: 1, image: $r('app.media.device_living_curtain') },
  { id: 'bedroom_air_guard', title: '睡眠空调伴侣', desc: '夜间降噪和温度曲线控制', price: '¥169', count: 1, image: $r('app.media.device_bedroom_air') },
  { id: 'door_sensor', title: '门窗安全传感器', desc: '门磁、夜间提醒和离家安防联动', price: '¥99', count: 1, image: $r('app.media.device_bedroom_door') },
  { id: 'robot_dock', title: '机器人回充底座', desc: '改善多房间回充路径识别', price: '¥139', count: 1, image: $r('app.media.device_bedroom_robot') }
];

@Entry
@Component
struct StoreCartPage {
  @State networkFailed: boolean = false;
  @State selectedItemIds: string = '';
  @State checkoutDone: boolean = false;
  @State isNight: boolean = false;
  @State addedProductId: string = '';
  @State addedCount: number = 1;
  @StorageLink('cartAddedProductId') cartAddedProductId: string = '';
  @StorageLink('cartAddedCount') cartAddedCount: number = 0;
  @StorageLink('cartLinePayload') cartLinePayload: string = '';
  @StorageLink('cartEdited') cartEdited: boolean = false;
  @StorageLink('storePendingOrderPayload') pendingOrderPayload: string = '';
  @StorageLink('cartCleared') cartCleared: boolean = false;
  @StorageLink('cartSchemaVersion') cartSchemaVersion: string = '';

  aboutToAppear(): void {
    const params = safeGetParams(this.getUIContext().getRouter()) as CartRouteParams | undefined;
    if (params && params.isNight !== undefined) {
      this.isNight = params.isNight;
    }
    if (params && params.addedProductId !== undefined) {
      this.addedProductId = params.addedProductId;
    }
    if (params && params.addedCount !== undefined) {
      this.addedCount = params.addedCount;
    }
    this.migrateCartSchema(this.addedProductId.length > 0 || this.cartLinePayload.length > 0);
    this.mergeRouteAddedProduct();
  }

  private migrateCartSchema(hasCurrentCartData: boolean): void {
    if (this.cartSchemaVersion === 'empty_cart_v1') {
      return;
    }
    if (!hasCurrentCartData) {
      this.cartLinePayload = '';
      this.cartAddedProductId = '';
      this.cartAddedCount = 0;
      this.selectedItemIds = '';
      this.cartCleared = false;
      this.cartEdited = true;
    }
    this.cartSchemaVersion = 'empty_cart_v1';
  }

  private mergeRouteAddedProduct(): void {
    if (this.addedProductId.length === 0 || this.addedCount <= 0) {
      return;
    }
    const currentItems: CartItemSpec[] = this.items();
    const nextItems: CartItemSpec[] = [];
    let merged: boolean = false;
    for (let i = 0; i < currentItems.length; i++) {
      const item = currentItems[i];
      if (item.id === this.addedProductId) {
        nextItems.push({
          id: item.id,
          title: item.title,
          desc: item.desc,
          price: item.price,
          count: item.count + this.addedCount,
          image: item.image
        });
        merged = true;
      } else {
        nextItems.push(item);
      }
    }
    if (!merged) {
      const catalog: CartItemSpec | undefined = this.catalogItem(this.addedProductId);
      if (catalog !== undefined) {
        nextItems.push({
          id: catalog.id,
          title: catalog.title,
          desc: catalog.desc,
          price: catalog.price,
          count: this.addedCount,
          image: catalog.image
        });
      }
    }
    this.persistItems(nextItems);
    this.setItemSelected(this.addedProductId, true);
    this.addedProductId = '';
    this.addedCount = 1;
  }

  private primaryText(): string {
    return this.isNight ? '#F6F8FC' : '#11151D';
  }

  private secondaryText(): string {
    return this.isNight ? '#A7AFBD' : '#657083';
  }

  private bgColor(): string {
    return this.isNight ? '#060709' : '#F2F4F8';
  }

  private cardColor(): string {
    return this.isNight ? '#731F232A' : '#B8FFFFFF';
  }

  private softColor(): string {
    return this.isNight ? '#73161A20' : '#B8EFF2F7';
  }

  private items(): CartItemSpec[] {
    if (this.cartCleared) {
      return [];
    }
    if (this.cartLinePayload.length > 0) {
      return this.itemsFromPayload(this.cartLinePayload);
    }
    return [];
  }

  private catalogItem(id: string): CartItemSpec | undefined {
    for (let i = 0; i < CART_CATALOG.length; i++) {
      if (CART_CATALOG[i].id === id) {
        return CART_CATALOG[i];
      }
    }
    return undefined;
  }

  private itemsFromPayload(payload: string): CartItemSpec[] {
    const result: CartItemSpec[] = [];
    if (payload.length === 0) {
      return result;
    }
    const lines: string[] = payload.split(';');
    for (let i = 0; i < lines.length; i++) {
      const pair: string[] = lines[i].split(':');
      if (pair.length !== 2 || pair[0].length === 0) {
        continue;
      }
      const parsedCount: number = Number(pair[1]);
      const count: number = isNaN(parsedCount) ? 0 : parsedCount;
      const catalog: CartItemSpec | undefined = this.catalogItem(pair[0]);
      if (catalog === undefined || count <= 0) {
        continue;
      }
      result.push({
        id: catalog.id,
        title: catalog.title,
        desc: catalog.desc,
        price: catalog.price,
        count: count,
        image: catalog.image
      });
    }
    return result;
  }

  private persistItems(nextItems: CartItemSpec[]): void {
    const lines: string[] = [];
    const selectedIds: string[] = [];
    for (let i = 0; i < nextItems.length; i++) {
      lines.push(`${nextItems[i].id}:${nextItems[i].count}`);
      if (this.itemSelected(nextItems[i].id)) {
        selectedIds.push(nextItems[i].id);
      }
    }
    this.cartLinePayload = lines.join(';');
    this.cartEdited = true;
    this.cartCleared = nextItems.length === 0;
    this.selectedItemIds = selectedIds.join('|');
    this.cartAddedProductId = '';
    this.cartAddedCount = 0;
    this.addedProductId = '';
    this.addedCount = 1;
    this.pendingOrderPayload = '';
    this.checkoutDone = false;
  }

  private changeItemCount(id: string, delta: number): void {
    const currentItems: CartItemSpec[] = this.items();
    const nextItems: CartItemSpec[] = [];
    for (let i = 0; i < currentItems.length; i++) {
      const item = currentItems[i];
      const nextCount: number = item.id === id ? item.count + delta : item.count;
      nextItems.push({
        id: item.id,
        title: item.title,
        desc: item.desc,
        price: item.price,
        count: nextCount < 1 ? 1 : nextCount,
        image: item.image
      });
    }
    this.persistItems(nextItems);
  }

  private removeItem(id: string): void {
    const currentItems: CartItemSpec[] = this.items();
    const nextItems: CartItemSpec[] = [];
    for (let i = 0; i < currentItems.length; i++) {
      if (currentItems[i].id !== id) {
        nextItems.push(currentItems[i]);
      }
    }
    this.persistItems(nextItems);
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
    if (id === 'door_sensor') {
      return 99;
    }
    if (id === 'robot_dock') {
      return 139;
    }
    return 0;
  }

  private selectedIds(): string[] {
    return this.selectedItemIds.length > 0 ? this.selectedItemIds.split('|').filter((id: string) => id.length > 0) : [];
  }

  private itemSelected(id: string): boolean {
    return this.selectedIds().indexOf(id) >= 0;
  }

  private selectedCount(): number {
    const currentItems: CartItemSpec[] = this.items();
    let count: number = 0;
    for (let i = 0; i < currentItems.length; i++) {
      if (this.itemSelected(currentItems[i].id)) {
        count++;
      }
    }
    return count;
  }

  private allSelected(): boolean {
    const currentItems: CartItemSpec[] = this.items();
    return currentItems.length > 0 && this.selectedCount() === currentItems.length;
  }

  private selectAllItems(): void {
    const ids: string[] = [];
    const currentItems: CartItemSpec[] = this.items();
    for (let i = 0; i < currentItems.length; i++) {
      ids.push(currentItems[i].id);
    }
    this.selectedItemIds = ids.join('|');
  }

  private toggleAllSelected(): void {
    if (this.allSelected()) {
      this.selectedItemIds = '';
    } else {
      this.selectAllItems();
    }
    this.checkoutDone = false;
  }

  private toggleItemSelected(id: string): void {
    const ids: string[] = this.selectedIds();
    const index = ids.indexOf(id);
    if (index >= 0) {
      ids.splice(index, 1);
    } else {
      ids.push(id);
    }
    this.selectedItemIds = ids.join('|');
    this.checkoutDone = false;
  }

  private selectedPayload(): string {
    const currentItems: CartItemSpec[] = this.items();
    const lines: string[] = [];
    for (let i = 0; i < currentItems.length; i++) {
      if (this.itemSelected(currentItems[i].id)) {
        lines.push(`${currentItems[i].id}:${currentItems[i].count}`);
      }
    }
    return lines.join(';');
  }

  private totalText(): string {
    const currentItems: CartItemSpec[] = this.items();
    let total: number = 0;
    for (let i = 0; i < currentItems.length; i++) {
      if (this.itemSelected(currentItems[i].id)) {
        total += this.priceNumber(currentItems[i].id) * currentItems[i].count;
      }
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
              }, (item: CartItemSpec) => `${item.id}_${item.count}_${this.itemSelected(item.id)}`)
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
          safeBack(this.getUIContext().getRouter());
        })
      Text('购物车')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .margin({ left: 14 })
        .layoutWeight(1)
      Button('地址')
        .height(34)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .backgroundColor(this.cardColor())
        .borderRadius(17)
        .padding({ left: 12, right: 12 })
        .margin({ right: 8 })
        .onClick(() => {
          safePushUrl(this.getUIContext().getRouter(), { url: 'pages/store/storeaddress', params: { isNight: this.isNight } });
        })
      Button(this.cartCleared ? '恢复' : '清空')
        .height(34)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#D35B4B')
        .backgroundColor(this.isNight ? '#33D35B4B' : '#FFF1EF')
        .borderRadius(17)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          this.cartCleared = true;
          this.checkoutDone = false;
          this.pendingOrderPayload = '';
          this.selectedItemIds = '';
          this.cartLinePayload = '';
          this.cartEdited = true;
          this.cartAddedProductId = '';
          this.cartAddedCount = 0;
          this.addedProductId = '';
          this.addedCount = 1;
        })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 28, bottom: 14 })
  }

  @Builder
  SummaryCard() {
    Row() {
      Column() {
        Text('购物车商品')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
        Text('已选商品会在结算后生成待支付订单')
          .fontSize(13)
          .fontColor(this.secondaryText())
          .margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Text(`${this.items().length} 类`)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .padding({ left: 12, right: 12, top: 7, bottom: 7 })
        .backgroundColor('#D76626')
        .borderRadius(16)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .linearGradient({ angle: 135, colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#23342D', 1.0]] : [['#FFF2D7', 0.0], ['#B8FFFFFF', 0.64], ['#EAF8F4', 1.0]] })
    .borderRadius(26)
  }

  @Builder
  CheckBox(selected: boolean, size: number, actionKey: string) {
    Checkbox()
      .width(size)
      .height(size)
      .select(selected)
      .selectedColor('#F3A33A')
      .onChange((checked: boolean) => {
        if (actionKey === 'all') {
          this.toggleAllSelected();
        } else {
          this.setItemSelected(actionKey, checked);
        }
      })
  }

  private setItemSelected(id: string, selected: boolean): void {
    const ids: string[] = this.selectedIds();
    const index = ids.indexOf(id);
    if (selected && index < 0) {
      ids.push(id);
    }
    if (!selected && index >= 0) {
      ids.splice(index, 1);
    }
    this.selectedItemIds = ids.join('|');
    this.checkoutDone = false;
  }

  @Builder
  CheckCircle(selected: boolean, size: number, actionKey: string) {
    this.CheckBox(selected, size, actionKey)
  }

  @Builder
  CartCard(item: CartItemSpec) {
    Row() {
      this.CheckCircle(this.itemSelected(item.id), 28, item.id)
      Image(item.image)
        .width(74)
        .height(74)
        .objectFit(ImageFit.Contain)
        .backgroundColor('#FFFFFF')
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
            .maxLines(1)
          Button('删除')
            .height(28)
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor('#D35B4B')
            .backgroundColor(this.isNight ? '#33D35B4B' : '#FFF1EF')
            .borderRadius(14)
            .padding({ left: 10, right: 10 })
            .onClick(() => {
              this.removeItem(item.id);
            })
        }
        .width('100%')
        .margin({ top: 8 })
        Row() {
          Blank()
          this.CountButton('-', item.id, item.count > 1)
          Text(`${item.count}`)
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())
            .width(28)
            .textAlign(TextAlign.Center)
          this.CountButton('+', item.id, true)
        }
        .width('100%')
        .margin({ top: 6 })
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
  CountButton(label: string, itemId: string, enabled: boolean) {
    Stack({ alignContent: Alignment.Center }) {
      Circle()
        .width(30)
        .height(30)
        .fill(enabled ? (this.isNight ? '#F5F7FB' : '#11151D') : (this.isNight ? '#1D232B' : '#E1E6EF'))
      Text(label)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(enabled ? (this.isNight ? '#11151D' : '#FFFFFF') : this.secondaryText())
        .textAlign(TextAlign.Center)
    }
      .width(28)
      .height(30)
      .opacity(enabled ? 1 : 0.55)
      .onClick(() => {
        if (enabled) {
          this.changeItemCount(itemId, label === '+' ? 1 : -1);
        }
      })
  }

  @Builder
  CheckoutBar() {
    Row() {
      this.CheckCircle(this.allSelected(), 30, 'all')
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
        .backgroundColor(this.selectedCount() > 0 ? '#F3A33A' : '#B8C0CC')
        .borderRadius(22)
        .padding({ left: 24, right: 24 })
        .onClick(() => {
          if (this.selectedCount() > 0) {
            this.pendingOrderPayload = this.selectedPayload();
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
          safePushUrl(this.getUIContext().getRouter(), { url: 'pages/store/storeorders', params: { isNight: this.isNight } });
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
          safeBack(this.getUIContext().getRouter());
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
