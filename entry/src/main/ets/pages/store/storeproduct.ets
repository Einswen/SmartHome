import { safeBack, safeGetParams, safePushUrl } from '../../common/SafeRouter';

interface ProductRouteParams {
  productId?: string;
  isNight?: boolean;
}

interface ProductSpec {
  id: string;
  title: string;
  desc: string;
  price: string;
  image: Resource;
  tag: string;
  scene: string;
}

interface StoreRouteParams {
  isNight: boolean;
}

interface ProductShotSpec {
  id: string;
  mode: number;
  imageSize: number;
  offsetX: number;
  offsetY: number;
  bgStart: string;
  bgEnd: string;
  image?: Resource;
}

const PRODUCT_LIST: ProductSpec[] = [
  { id: 'sensor_pro', title: '环境传感器 Pro', desc: '温湿度、光照、人体存在三合一，可触发空调、窗帘与灯光联动。', price: '¥199', image: $r('app.media.store_sensor_pro'), tag: '套装推荐', scene: '客厅 / 卧室' },
  { id: 'light_module', title: '智能照明模块', desc: '支持亮度、色温与场景联动，适合全屋灯光升级。', price: '¥129', image: $r('app.media.store_light_module'), tag: '热卖', scene: '客厅主灯' },
  { id: 'gesture_panel', title: '手势控制面板', desc: '无接触切换回家、观影、睡眠等高频场景。', price: '¥299', image: $r('app.media.store_gesture_panel'), tag: '新品', scene: '玄关 / 客厅' },
  { id: 'robot_pack', title: '清洁维护套装', desc: '扫地机器人主刷、边刷、滤网组合装。', price: '¥89', image: $r('app.media.store_robot_pack'), tag: '耗材', scene: '扫地机器人' },
  { id: 'gateway_m2', title: '智能网关 M2', desc: '蓝牙 Mesh 与 Zigbee 双协议接入，覆盖主流智能设备。', price: '¥369', image: $r('app.media.store_gateway_m2'), tag: '中枢', scene: '全屋' },
  { id: 'filter', title: '净化器滤芯', desc: '高效过滤颗粒物和异味，建议每 6 个月更换。', price: '¥159', image: $r('app.media.device_living_purifier'), tag: '订阅省 15%', scene: '空气净化器' }
  ,
  { id: 'living_curtain_motor', title: '智能窗帘电机', desc: '适配客厅西侧窗帘，可接入日照跟随和观影联动。', price: '¥249', image: $r('app.media.device_living_curtain'), tag: '联动', scene: '客厅窗帘' },
  { id: 'bedroom_air_guard', title: '睡眠空调伴侣', desc: '夜间自动降噪和温度曲线控制，适合卧室睡眠场景。', price: '¥169', image: $r('app.media.device_bedroom_air'), tag: '睡眠', scene: '卧室空调' },
  { id: 'door_sensor', title: '门窗安全传感器', desc: '门磁、夜间提醒和离家安防联动，异常立即通知。', price: '¥99', image: $r('app.media.device_bedroom_door'), tag: '安防', scene: '门窗安防' },
  { id: 'robot_dock', title: '机器人回充底座', desc: '改善回充路径识别，适合客厅和卧室多房间清洁。', price: '¥139', image: $r('app.media.device_bedroom_robot'), tag: '配件', scene: '扫地机器人' }
];

@Entry
@Component
struct StoreProductPage {
  @State productId: string = 'sensor_pro';
  @State count: number = 1;
  @State networkFailed: boolean = false;
  @State added: boolean = false;
  @State isNight: boolean = false;
  @State activeShotIndex: number = 0;
  @StorageLink('cartAddedProductId') cartAddedProductId: string = '';
  @StorageLink('cartAddedCount') cartAddedCount: number = 0;
  @StorageLink('cartLinePayload') cartLinePayload: string = '';
  @StorageLink('cartCleared') cartCleared: boolean = false;
  @StorageLink('cartEdited') cartEdited: boolean = false;
  @StorageLink('cartSchemaVersion') cartSchemaVersion: string = '';

  aboutToAppear(): void {
    const params = safeGetParams(this.getUIContext().getRouter()) as ProductRouteParams | undefined;
    if (params && params.productId !== undefined) {
      this.productId = params.productId;
      this.activeShotIndex = 0;
    }
    if (params && params.isNight !== undefined) {
      this.isNight = params.isNight;
    }
  }

  private product(): ProductSpec {
    for (let i = 0; i < PRODUCT_LIST.length; i++) {
      if (PRODUCT_LIST[i].id === this.productId) {
        return PRODUCT_LIST[i];
      }
    }
    return PRODUCT_LIST[0];
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

  private productShots(product: ProductSpec): ProductShotSpec[] {
    if (product.id === 'sensor_pro') {
      return [
        {
          id: `${product.id}_front`,
          mode: 0,
          imageSize: 176,
          offsetX: 0,
          offsetY: 0,
          bgStart: '#FFF2D7',
          bgEnd: '#EAF2FF',
          image: $r('app.media.store_sensor_pro')
        },
        {
          id: `${product.id}_side`,
          mode: 1,
          imageSize: 178,
          offsetX: 34,
          offsetY: 2,
          bgStart: '#EAF8F4',
          bgEnd: '#F5F7FB',
          image: $r('app.media.store_sensor_pro_side')
        },
        {
          id: `${product.id}_angle`,
          mode: 2,
          imageSize: 178,
          offsetX: -34,
          offsetY: 2,
          bgStart: '#EAF0FF',
          bgEnd: '#FFF8EC',
          image: $r('app.media.store_sensor_pro_angle')
        }
      ];
    }

    if (product.id === 'light_module') {
      return [
        {
          id: `${product.id}_front`,
          mode: 0,
          imageSize: 176,
          offsetX: 0,
          offsetY: 0,
          bgStart: '#FFF2D7',
          bgEnd: '#EAF2FF',
          image: $r('app.media.store_light_module')
        },
        {
          id: `${product.id}_side`,
          mode: 1,
          imageSize: 178,
          offsetX: 34,
          offsetY: 2,
          bgStart: '#EAF8F4',
          bgEnd: '#F5F7FB',
          image: $r('app.media.store_light_module_side')
        },
        {
          id: `${product.id}_angle`,
          mode: 2,
          imageSize: 178,
          offsetX: -34,
          offsetY: 2,
          bgStart: '#EAF0FF',
          bgEnd: '#FFF8EC',
          image: $r('app.media.store_light_module_angle')
        }
      ];
    }

    if (product.id === 'gesture_panel') {
      return [
        {
          id: `${product.id}_front`,
          mode: 0,
          imageSize: 176,
          offsetX: 0,
          offsetY: 0,
          bgStart: '#FFF2D7',
          bgEnd: '#EAF2FF',
          image: $r('app.media.store_gesture_panel')
        },
        {
          id: `${product.id}_side`,
          mode: 1,
          imageSize: 178,
          offsetX: 34,
          offsetY: 2,
          bgStart: '#EAF8F4',
          bgEnd: '#F5F7FB',
          image: $r('app.media.store_gesture_panel_side')
        },
        {
          id: `${product.id}_angle`,
          mode: 2,
          imageSize: 178,
          offsetX: -34,
          offsetY: 2,
          bgStart: '#EAF0FF',
          bgEnd: '#FFF8EC',
          image: $r('app.media.store_gesture_panel_angle')
        }
      ];
    }

    if (product.id === 'robot_pack') {
      return [
        {
          id: `${product.id}_full`,
          mode: 3,
          imageSize: 188,
          offsetX: 0,
          offsetY: -2,
          bgStart: '#FFF2D7',
          bgEnd: '#EAF2FF',
          image: $r('app.media.store_robot_pack_full')
        },
        {
          id: `${product.id}_brush`,
          mode: 4,
          imageSize: 188,
          offsetX: 0,
          offsetY: -4,
          bgStart: '#EAF0FF',
          bgEnd: '#FFF8EC',
          image: $r('app.media.store_robot_pack_brush')
        },
        {
          id: `${product.id}_filter`,
          mode: 5,
          imageSize: 196,
          offsetX: 0,
          offsetY: 4,
          bgStart: '#FFF6E8',
          bgEnd: '#EAF8F4',
          image: $r('app.media.store_robot_pack_filter')
        }
      ];
    }

    if (product.id === 'gateway_m2') {
      return [
        {
          id: `${product.id}_front`,
          mode: 0,
          imageSize: 176,
          offsetX: 0,
          offsetY: 0,
          bgStart: '#FFF2D7',
          bgEnd: '#EAF2FF',
          image: $r('app.media.store_gateway_m2')
        },
        {
          id: `${product.id}_side`,
          mode: 1,
          imageSize: 178,
          offsetX: 34,
          offsetY: 2,
          bgStart: '#EAF8F4',
          bgEnd: '#F5F7FB',
          image: $r('app.media.store_gateway_m2_side')
        },
        {
          id: `${product.id}_angle`,
          mode: 2,
          imageSize: 178,
          offsetX: -34,
          offsetY: 2,
          bgStart: '#EAF0FF',
          bgEnd: '#FFF8EC',
          image: $r('app.media.store_gateway_m2_angle')
        }
      ];
    }

    const shots: ProductShotSpec[] = [
      {
        id: `${product.id}_front`,
        mode: 0,
        imageSize: 176,
        offsetX: 0,
        offsetY: 0,
        bgStart: '#FFF2D7',
        bgEnd: '#EAF2FF'
      },
      {
        id: `${product.id}_side`,
        mode: 1,
        imageSize: 178,
        offsetX: 34,
        offsetY: 2,
        bgStart: '#EAF8F4',
        bgEnd: '#F5F7FB'
      },
      {
        id: `${product.id}_angle`,
        mode: 2,
        imageSize: 178,
        offsetX: -34,
        offsetY: 2,
        bgStart: '#EAF0FF',
        bgEnd: '#FFF8EC'
      }
    ];
    return shots;
  }

  private addCartLine(productId: string, count: number): void {
    const storedParts: string[] = this.cartLinePayload.length > 0 ? this.cartLinePayload.split(';') : [];
    const parts: string[] = storedParts;
    const nextParts: string[] = [];
    let merged: boolean = false;
    for (let i = 0; i < parts.length; i++) {
      const pair: string[] = parts[i].split(':');
      if (pair.length !== 2 || pair[0].length === 0) {
        continue;
      }
      const storedCount: number = Number(pair[1]);
      const safeCount: number = isNaN(storedCount) ? 0 : storedCount;
      if (pair[0] === productId) {
        nextParts.push(`${pair[0]}:${safeCount + count}`);
        merged = true;
      } else {
        nextParts.push(`${pair[0]}:${safeCount}`);
      }
    }
    if (!merged) {
      nextParts.push(`${productId}:${count}`);
    }
    this.cartLinePayload = nextParts.join(';');
  }

  private routeParams(): StoreRouteParams {
    return { isNight: this.isNight };
  }

  build() {
    Column() {
      this.TopBar()

      if (this.networkFailed) {
        this.NetworkState()
      } else {
        Scroll() {
          Column() {
            this.Hero(this.product())
            this.QuantityCard()
            this.SpecCard()
            this.BundleCard()
          }
          .width('100%')
          .padding({ left: 18, right: 18, bottom: 100 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        this.BuyBar(this.product())
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

      Text('商品详情')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .margin({ left: 14 })
        .layoutWeight(1)

      Button('购物车')
        .height(34)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .backgroundColor(this.cardColor())
        .borderRadius(17)
        .padding({ left: 12, right: 12 })
        .margin({ right: 8 })
        .onClick(() => {
          safePushUrl(this.getUIContext().getRouter(), { url: 'pages/store/storecart', params: this.routeParams() });
        })

    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 28, bottom: 14 })
  }

  @Builder
  Hero(product: ProductSpec) {
    Column() {
      Text(product.tag)
        .fontSize(11)
        .fontWeight(FontWeight.Bold)
        .fontColor('#D76626')
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor(this.isNight ? '#33F3A33A' : '#FFF2D7')
        .borderRadius(14)

      Swiper() {
        ForEach(this.productShots(product), (shot: ProductShotSpec) => {
          this.ProductShot(product, shot)
        }, (shot: ProductShotSpec) => shot.id)
      }
      .width('100%')
      .height(236)
      .indicator(false)
      .loop(true)
      .autoPlay(false)
      .margin({ top: 12 })
      .onChange((index: number) => {
        this.activeShotIndex = index;
      })

      this.ShotDots(this.productShots(product))

      Text(product.title)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .margin({ top: 12 })

      Text(product.desc)
        .fontSize(13)
        .lineHeight(21)
        .fontColor(this.secondaryText())
        .textAlign(TextAlign.Center)
        .margin({ left: 20, right: 20, top: 8 })

      Row() {
        Text(product.price)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor('#D76626')
        Text(product.scene)
          .fontSize(12)
          .fontColor(this.secondaryText())
          .margin({ left: 12, top: 9 })
      }
      .margin({ top: 12 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 24, bottom: 24 })
    .linearGradient({ angle: 135, colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#23342D', 1.0]] : [['#FFF2D7', 0.0], ['#FFFFFF', 0.62], ['#EAF2FF', 1.0]] })
    .borderRadius(28)
  }

  @Builder
  ProductShot(product: ProductSpec, shot: ProductShotSpec) {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('86%')
        .height(176)
        .linearGradient({
          angle: 135,
          colors: this.isNight ? [['#202A38', 0.0], ['#111820', 0.62], ['#27313A', 1.0]] : [[shot.bgStart, 0.0], ['#FFFFFF', 0.58], [shot.bgEnd, 1.0]]
        })
        .borderRadius(28)

      Ellipse()
        .width(176)
        .height(34)
        .fill(this.isNight ? '#66101620' : '#22000000')
        .translate({ x: shot.mode === 1 ? 28 : (shot.mode === 2 ? -28 : 0), y: 82 })

      if (shot.mode === 1) {
        Column()
          .width(54)
          .height(118)
          .linearGradient({ angle: 90, colors: this.isNight ? [['#303947', 0.0], ['#1A2029', 1.0]] : [['#FFFFFF', 0.0], ['#DDE6F3', 1.0]] })
          .borderRadius(16)
          .opacity(0.72)
          .translate({ x: -56, y: 0 })
        Image(shot.image !== undefined ? shot.image : product.image)
          .width(shot.imageSize)
          .height(shot.imageSize)
          .objectFit(ImageFit.Contain)
          .scale({ x: 0.78, y: 1.02 })
          .translate({ x: shot.offsetX, y: shot.offsetY })
      } else if (shot.mode === 2) {
        Column()
          .width(54)
          .height(118)
          .linearGradient({ angle: 90, colors: this.isNight ? [['#1A2029', 0.0], ['#303947', 1.0]] : [['#DDE6F3', 0.0], ['#FFFFFF', 1.0]] })
          .borderRadius(16)
          .opacity(0.72)
          .translate({ x: 56, y: 0 })
        Image(shot.image !== undefined ? shot.image : product.image)
          .width(shot.imageSize)
          .height(shot.imageSize)
          .objectFit(ImageFit.Contain)
          .scale({ x: 0.78, y: 1.02 })
          .translate({ x: shot.offsetX, y: shot.offsetY })
      } else if (shot.mode === 3) {
        Stack({ alignContent: Alignment.Center }) {
          Image(shot.image !== undefined ? shot.image : product.image)
            .width(shot.imageSize)
            .height(shot.imageSize)
            .objectFit(ImageFit.Contain)
            .translate({ x: shot.offsetX, y: shot.offsetY })
        }
        .width('72%')
        .height(176)
        .clip(true)
        .borderRadius(28)
      } else if (shot.mode === 4) {
        Column()
          .width(62)
          .height(126)
          .linearGradient({ angle: 90, colors: this.isNight ? [['#273241', 0.0], ['#131A22', 1.0]] : [['#EEF3FF', 0.0], ['#FFFFFF', 1.0]] })
          .borderRadius(20)
          .opacity(0.78)
          .translate({ x: 58, y: -4 })
        Image(shot.image !== undefined ? shot.image : product.image)
          .width(shot.imageSize)
          .height(shot.imageSize)
          .objectFit(ImageFit.Contain)
          .translate({ x: shot.offsetX, y: shot.offsetY })
      } else if (shot.mode === 5) {
        Column()
          .width(62)
          .height(126)
          .linearGradient({ angle: 90, colors: this.isNight ? [['#131A22', 0.0], ['#273241', 1.0]] : [['#FFFFFF', 0.0], ['#EEF3FF', 1.0]] })
          .borderRadius(20)
          .opacity(0.78)
          .translate({ x: -58, y: -4 })
        Image(shot.image !== undefined ? shot.image : product.image)
          .width(shot.imageSize)
          .height(shot.imageSize)
          .objectFit(ImageFit.Contain)
          .translate({ x: shot.offsetX, y: shot.offsetY })
      } else {
        Circle()
          .width(130)
          .height(130)
          .fill(this.isNight ? '#262C36' : '#F8FAFD')
          .opacity(0.72)
          .translate({ x: 0, y: 32 })
        Image(shot.image !== undefined ? shot.image : product.image)
          .width(shot.imageSize)
          .height(shot.imageSize)
          .objectFit(ImageFit.Contain)
          .translate({ x: shot.offsetX, y: shot.offsetY })
      }
    }
    .width('100%')
    .height(236)
  }

  @Builder
  ShotDots(shots: ProductShotSpec[]) {
    Row() {
      ForEach(shots, (shot: ProductShotSpec, index?: number) => {
        Column()
          .width(this.activeShotIndex === index ? 18 : 6)
          .height(6)
          .backgroundColor(this.activeShotIndex === index ? '#F3A33A' : (this.isNight ? '#44FFFFFF' : '#D4DAE4'))
          .borderRadius(3)
          .margin({ left: 3, right: 3 })
      }, (shot: ProductShotSpec) => shot.id)
    }
    .height(14)
    .justifyContent(FlexAlign.Center)
    .margin({ top: 2 })
  }

  @Builder
  QuantityCard() {
    Row() {
      Column() {
        Text('购买数量')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
        Text(this.added ? '已加入购物车，可继续调整数量' : '库存充足，支持 7 天无理由退换')
          .fontSize(12)
          .fontColor(this.secondaryText())
          .margin({ top: 5 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      this.QuantityButton('-', false)
      Text(`${this.count}`)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width(34)
        .textAlign(TextAlign.Center)
      this.QuantityButton('+', true)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 16 })
  }

  @Builder
  QuantityButton(label: string, strong: boolean) {
    Stack() {
      Circle()
        .width(34)
        .height(34)
        .fill(strong ? (this.isNight ? '#F5F7FB' : '#11151D') : this.softColor())
      Text(label)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(strong ? (this.isNight ? '#11151D' : '#FFFFFF') : this.primaryText())
        .textAlign(TextAlign.Center)
    }
    .width(34)
    .height(34)
    .onClick(() => {
      if (label === '-') {
        if (this.count > 1) {
          this.count--;
        }
      } else {
        if (this.count < 9) {
          this.count++;
        }
      }
    })
  }

  @Builder
  SpecCard() {
    Column() {
      Text('核心能力')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
      this.SpecRow('联动能力', '可加入回家、离家、睡眠等自动化')
      this.SpecRow('安装方式', '支持自助安装，复杂场景可预约上门')
      this.SpecRow('售后保障', '一年质保，7 天无理由退换')
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 10 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 16 })
  }

  @Builder
  SpecRow(title: string, value: string) {
    Row() {
      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width(86)
      Text(value)
        .fontSize(13)
        .fontColor(this.secondaryText())
        .layoutWeight(1)
    }
    .width('100%')
    .height(50)
  }

  @Builder
  BundleCard() {
    Column() {
      Text('推荐搭配')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
      Text('搭配网关、环境传感器和照明模块，可一次完成客厅核心自动化套装。')
        .fontSize(13)
        .lineHeight(21)
        .fontColor(this.secondaryText())
        .margin({ top: 8 })
        .width('100%')
      Row() {
        this.BundleChip('网关', '#5E8CFF')
        this.BundleChip('传感', '#19B7A4')
        this.BundleChip('照明', '#F3A33A')
      }
      .width('100%')
      .margin({ top: 14 })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 16 })
  }

  @Builder
  BundleChip(label: string, color: string) {
    Text(label)
      .fontSize(12)
      .fontWeight(FontWeight.Bold)
      .fontColor(color)
      .padding({ left: 12, right: 12, top: 7, bottom: 7 })
      .backgroundColor(this.softColor())
      .borderRadius(16)
      .margin({ right: 8 })
  }

  @Builder
  BuyBar(product: ProductSpec) {
    Row() {
      Column() {
        Text(product.price)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#D76626')
        Text(this.added ? '已加入购物车' : '含安装指引与售后保障')
          .fontSize(11)
          .fontColor(this.secondaryText())
          .margin({ top: 3 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Button('加入购物车')
        .height(44)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#11151D')
        .backgroundColor('#F3C74D')
        .borderRadius(22)
        .padding({ left: 18, right: 18 })
        .margin({ right: 8 })
        .onClick(() => {
          this.addCartLine(this.productId, this.count);
          this.cartAddedProductId = this.productId;
          this.cartAddedCount = this.count;
          this.cartCleared = false;
          this.cartEdited = true;
          this.cartSchemaVersion = 'empty_cart_v1';
          this.added = true;
          safePushUrl(this.getUIContext().getRouter(), { url: 'pages/store/storecart', params: this.routeParams() });
        })
      Button('去结算')
        .height(44)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isNight ? '#11151D' : '#FFFFFF')
        .backgroundColor(this.isNight ? '#F5F7FB' : '#11151D')
        .borderRadius(22)
        .padding({ left: 18, right: 18 })
        .onClick(() => {
          safePushUrl(this.getUIContext().getRouter(), { url: 'pages/store/storecart', params: this.routeParams() });
        })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 12, bottom: 18 })
    .backgroundColor(this.cardColor())
  }

  @Builder
  NetworkState() {
    Column() {
      Blank().height(86)
      Text('商品详情加载失败')
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('网络异常，价格和库存可能不是最新状态。购物车会保留上次选择。')
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
