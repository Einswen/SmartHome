import { safeBack, safeGetParams, safePushUrl } from '../../common/SafeRouter';

interface StoreCategoryRouteParams {
  isNight?: boolean;
  categoryId?: string;
}

interface CategoryProductSpec {
  id: string;
  title: string;
  desc: string;
  image: Resource;
  productId: string;
  color: string;
}

const BUNDLE_PRODUCTS: CategoryProductSpec[] = [
  {
    id: 'bundle_gateway',
    title: '智能网关 M2',
    desc: '全屋中枢，负责连接传感器、照明模块和自动化场景。',
    image: $r('app.media.store_gateway_m2'),
    productId: 'gateway_m2',
    color: '#5E8CFF'
  },
  {
    id: 'bundle_sensor',
    title: '环境传感器 Pro',
    desc: '感知温湿度、光照和人体存在，作为全屋联动触发器。',
    image: $r('app.media.store_sensor_pro'),
    productId: 'sensor_pro',
    color: '#19B7A4'
  },
  {
    id: 'bundle_light',
    title: '智能照明模块',
    desc: '升级主灯和氛围灯，配合网关完成回家、观影和睡眠场景。',
    image: $r('app.media.store_light_module'),
    productId: 'light_module',
    color: '#F3A33A'
  }
];

@Entry
@Component
struct StoreCategoryPage {
  @State isNight: boolean = false;
  @State networkFailed: boolean = false;
  @State showEmpty: boolean = false;
  @State categoryId: string = '';
  @StorageLink('cartLinePayload') cartLinePayload: string = '';
  @StorageLink('cartCleared') cartCleared: boolean = false;
  @StorageLink('cartEdited') cartEdited: boolean = false;
  @StorageLink('cartSchemaVersion') cartSchemaVersion: string = '';

  aboutToAppear(): void {
    const params = safeGetParams(this.getUIContext().getRouter()) as StoreCategoryRouteParams | undefined;
    if (params && params.isNight !== undefined) {
      this.isNight = params.isNight;
    }
    if (params && params.categoryId !== undefined) {
      this.categoryId = params.categoryId;
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

  private bundlePayload(): string {
    return 'gateway_m2:1;sensor_pro:1;light_module:1';
  }

  private mergeCartPayload(addPayload: string): string {
    const lines: string[] = [];
    const source: string[] = this.cartLinePayload.length > 0 ? this.cartLinePayload.split(';') : [];
    const additions: string[] = addPayload.split(';');
    for (let i = 0; i < source.length; i++) {
      if (source[i].length > 0) {
        lines.push(source[i]);
      }
    }
    for (let addIndex = 0; addIndex < additions.length; addIndex++) {
      const addPair: string[] = additions[addIndex].split(':');
      if (addPair.length !== 2 || addPair[0].length === 0) {
        continue;
      }
      const addCount: number = Number(addPair[1]);
      let merged: boolean = false;
      for (let lineIndex = 0; lineIndex < lines.length; lineIndex++) {
        const pair: string[] = lines[lineIndex].split(':');
        if (pair.length !== 2 || pair[0] !== addPair[0]) {
          continue;
        }
        const storedCount: number = Number(pair[1]);
        lines[lineIndex] = `${pair[0]}:${(isNaN(storedCount) ? 0 : storedCount) + (isNaN(addCount) ? 0 : addCount)}`;
        merged = true;
      }
      if (!merged) {
        lines.push(additions[addIndex]);
      }
    }
    return lines.join(';');
  }

  private addBundleToCart(): void {
    this.cartLinePayload = this.mergeCartPayload(this.bundlePayload());
    this.cartCleared = false;
    this.cartEdited = true;
    this.cartSchemaVersion = 'empty_cart_v1';
    safePushUrl(this.getUIContext().getRouter(), { url: 'pages/store/storecart', params: { isNight: this.isNight } });
  }

  build() {
    Column() {
      this.TopBar()
      if (this.networkFailed) {
        this.NetworkState()
      } else {
        Scroll() {
          Column() {
            this.Hero()
            if (this.showEmpty) {
              this.EmptyState()
            } else if (this.categoryId === 'bundle') {
              ForEach(BUNDLE_PRODUCTS, (item: CategoryProductSpec) => {
                this.CategoryCard(item.title, item.desc, item.image, item.productId, item.color)
              }, (item: CategoryProductSpec) => item.id)
              this.BundleAction()
            } else {
              this.CategoryCard('传感与环境', '感知温湿度、光照、人体存在，用于精细化自动化。', $r('app.media.store_sensor_pro'), 'sensor_pro', '#19B7A4')
              this.CategoryCard('灯光与氛围', '亮度、色温、场景联动，让客厅和卧室更舒适。', $r('app.media.store_light_module'), 'light_module', '#F3A33A')
              this.CategoryCard('窗帘与遮阳', '窗帘电机接入日照、观影和离家场景，不归入照明类。', $r('app.media.device_living_curtain'), 'living_curtain_motor', '#D76626')
              this.CategoryCard('安防与控制', '网关、面板、门锁与异常告警服务。', $r('app.media.store_gesture_panel'), 'gesture_panel', '#5E8CFF')
              this.CategoryCard('清洁与耗材', '扫地机器人维护套装、净化器滤芯和电池。', $r('app.media.store_robot_pack'), 'robot_pack', '#7F72F2')
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
          safeBack(this.getUIContext().getRouter());
        })
      Text(this.categoryId === 'bundle' ? '全屋升级套装' : '商品分类')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .margin({ left: 14 })
        .layoutWeight(1)
      if (this.categoryId !== 'bundle') {
        Button(this.showEmpty ? '恢复' : '空数据')
          .height(34)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5E8CFF')
          .backgroundColor(this.isNight ? '#335E8CFF' : '#EAF0FF')
          .borderRadius(17)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.showEmpty = !this.showEmpty;
          })
      }
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 28, bottom: 14 })
  }

  @Builder
  Hero() {
    Column() {
      Text(this.categoryId === 'bundle' ? '全屋升级套装' : '按家庭场景选购')
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
      Text(this.categoryId === 'bundle' ? '全屋升级套装包含网关、传感器和照明模块，可分别查看详情。' : '每个分类都对应首页设备和自动化能力，避免买了不能联动。')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(this.secondaryText())
        .margin({ top: 8 })
        .width('100%')
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 22, bottom: 22 })
    .linearGradient({ angle: 135, colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#23342D', 1.0]] : [['#EAF2FF', 0.0], ['#FFFFFF', 0.62], ['#EAF8F4', 1.0]] })
    .borderRadius(26)
  }

  @Builder
  CategoryCard(title: string, desc: string, image: Resource, productId: string, color: string) {
    Row() {
      Column() {
        Column()
          .width(30)
          .height(4)
          .borderRadius(2)
          .backgroundColor(color)
          .margin({ bottom: 12 })
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

      Image(image)
        .width(86)
        .height(86)
        .objectFit(ImageFit.Contain)
        .backgroundColor('#00000000')
        .borderRadius(22)
    }
    .width('100%')
    .padding({ left: 18, right: 14, top: 18, bottom: 18 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 12 })
    .onClick(() => {
      safePushUrl(this.getUIContext().getRouter(), { url: 'pages/store/storeproduct', params: { productId: productId, isNight: this.isNight } });
    })
  }

  @Builder
  BundleAction() {
    Button('一键加入购物车')
      .width('100%')
      .height(46)
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.isNight ? '#11151D' : '#FFFFFF')
      .backgroundColor(this.isNight ? '#F5F7FB' : '#11151D')
      .borderRadius(23)
      .margin({ top: 16 })
      .onClick(() => {
        this.addBundleToCart();
      })
  }

  @Builder
  EmptyState() {
    Column() {
      Text('暂无分类商品')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('当前筛选没有可购买设备，可恢复分类后继续浏览。')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(this.secondaryText())
        .textAlign(TextAlign.Center)
        .margin({ top: 8 })
      Button('恢复分类')
        .height(40)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#11151D')
        .borderRadius(20)
        .padding({ left: 18, right: 18 })
        .margin({ top: 18 })
        .onClick(() => {
          this.showEmpty = false;
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
      Text('分类加载失败')
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('网络异常，暂时无法同步最新分类和商品库存。')
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
