import { safePushUrl } from '../../common/SafeRouter';

interface StoreCategorySpec {
  id: string;
  label: string;
}

interface StoreProductSpec {
  id: string;
  title: string;
  desc: string;
  price: string;
  tag: string;
  categoryId: string;
  image: Resource;
  stock: string;
  fit: string;
}

interface StoreRouteParams {
  isNight: boolean;
}

const STORE_CATEGORIES: StoreCategorySpec[] = [
  { id: 'all', label: '推荐' },
  { id: 'sensor', label: '感知' },
  { id: 'light', label: '照明' },
  { id: 'security', label: '中枢' },
  { id: 'clean', label: '清洁' },
  { id: 'supply', label: '耗材' }
];

const STORE_PRODUCTS: StoreProductSpec[] = [
  {
    id: 'sensor_pro',
    title: '环境传感器 Pro',
    desc: '温湿度、光照、人体存在三合一，适合做全屋自动化触发器。',
    price: '¥199',
    tag: '套装推荐',
    categoryId: 'sensor',
    image: $r('app.media.store_sensor_pro'),
    stock: '现货',
    fit: '客厅 / 卧室'
  },
  {
    id: 'light_module',
    title: '智能照明模块',
    desc: '亮度、色温和场景联动，和首页灯光状态保持一套控制逻辑。',
    price: '¥129',
    tag: '热卖',
    categoryId: 'light',
    image: $r('app.media.store_light_module'),
    stock: '次日达',
    fit: '客厅主灯'
  },
  {
    id: 'gesture_panel',
    title: '手势控制面板',
    desc: '无接触切换回家、观影、睡眠等高频场景。',
    price: '¥299',
    tag: '新品',
    categoryId: 'security',
    image: $r('app.media.store_gesture_panel'),
    stock: '少量',
    fit: '玄关 / 客厅'
  },
  {
    id: 'robot_pack',
    title: '清洁维护套装',
    desc: '主刷、边刷、滤网一次补齐，适配客厅与卧室扫地机器人。',
    price: '¥89',
    tag: '耗材',
    categoryId: 'clean',
    image: $r('app.media.store_robot_pack'),
    stock: '现货',
    fit: '扫地机器人'
  },
  {
    id: 'gateway_m2',
    title: 'Lumi 网关 M2',
    desc: '蓝牙 Mesh 与 Zigbee 双协议接入，覆盖家庭核心智能设备。',
    price: '¥369',
    tag: '中枢',
    categoryId: 'security',
    image: $r('app.media.store_gateway_m2'),
    stock: '现货',
    fit: '全屋中枢'
  },
  {
    id: 'filter',
    title: '净化器滤芯',
    desc: '高效过滤颗粒物和异味，建议每 6 个月更换。',
    price: '¥159',
    tag: '补货',
    categoryId: 'supply',
    image: $r('app.media.device_living_purifier'),
    stock: '订阅省 15%',
    fit: '空气净化器'
  },
  {
    id: 'living_curtain_motor',
    title: '智能窗帘电机',
    desc: '适配客厅西侧窗帘，可接入日照跟随和观影联动。',
    price: '¥249',
    tag: '联动',
    categoryId: 'light',
    image: $r('app.media.device_living_curtain'),
    stock: '现货',
    fit: '客厅窗帘'
  },
  {
    id: 'bedroom_air_guard',
    title: '睡眠空调伴侣',
    desc: '夜间自动降噪和温度曲线控制，适合卧室睡眠场景。',
    price: '¥169',
    tag: '睡眠',
    categoryId: 'sensor',
    image: $r('app.media.device_bedroom_air'),
    stock: '次日达',
    fit: '卧室空调'
  },
  {
    id: 'door_sensor',
    title: '门窗安全传感器',
    desc: '门磁、夜间提醒和离家安防联动，异常立即通知。',
    price: '¥99',
    tag: '安防',
    categoryId: 'security',
    image: $r('app.media.device_bedroom_door'),
    stock: '现货',
    fit: '门窗安防'
  },
  {
    id: 'robot_dock',
    title: '机器人回充底座',
    desc: '改善回充路径识别，适合客厅和卧室多房间清洁。',
    price: '¥139',
    tag: '配件',
    categoryId: 'clean',
    image: $r('app.media.device_bedroom_robot'),
    stock: '少量',
    fit: '扫地机器人'
  }
];

@Component
export struct P31_StoreHome {
  @Prop isNight: boolean = false;
  @State activeCategoryId: string = 'all';
  @State networkFailed: boolean = false;
  @State showEmpty: boolean = false;
  @State pressedKey: string = '';

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
    return this.isNight ? '#D9151A22' : '#FFFFFFFF';
  }

  private softColor(): string {
    return this.isNight ? '#661F2632' : '#F0F4FA';
  }

  private lineColor(): string {
    return this.isNight ? '#20FFFFFF' : '#12000000';
  }

  private accent(): string {
    return this.isNight ? '#8DB7FF' : '#5E8CFF';
  }

  private routeParams(): StoreRouteParams {
    return { isNight: this.isNight };
  }

  private products(): StoreProductSpec[] {
    if (this.showEmpty) {
      return [];
    }
    if (this.activeCategoryId === 'all') {
      return STORE_PRODUCTS;
    }
    return STORE_PRODUCTS.filter((item: StoreProductSpec) => item.categoryId === this.activeCategoryId);
  }

  private handlePressState(key: string, event: TouchEvent): void {
    if (event.type === TouchType.Down) {
      this.pressedKey = key;
    } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      if (this.pressedKey === key) {
        this.pressedKey = '';
      }
    }
  }

  private buttonScale(key: string): ScaleOptions {
    return this.pressedKey === key ? { x: 0.97, y: 0.97 } : { x: 1, y: 1 };
  }

  build() {
    Column() {
      this.Header()

      if (this.networkFailed) {
        this.NetworkState()
      } else {
        Scroll() {
          Column() {
            this.Hero()
            this.CategoryScroller()
            this.QuickEntrances()
            this.ProductSection()
          }
          .width('100%')
          .padding({ left: 18, right: 18, bottom: 126 })
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
  Header() {
    Row() {
      Column() {
        Text('Lumi 商城')
          .fontSize(25)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .maxLines(1)

        Text('按你的家庭设备推荐可联动配件')
          .fontSize(13)
          .fontColor(this.secondaryText())
          .margin({ top: 6 })
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Button('购物车')
        .height(36)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .backgroundColor(this.cardColor())
        .border({ width: 1, color: this.lineColor() })
        .borderRadius(18)
        .padding({ left: 14, right: 14 })
        .margin({ right: 8 })
        .onClick(() => {
          safePushUrl(this.getUIContext().getRouter(), { url: 'pages/store/storecart', params: this.routeParams() });
        })

      Button('地址')
        .height(36)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .backgroundColor(this.cardColor())
        .border({ width: 1, color: this.lineColor() })
        .borderRadius(18)
        .padding({ left: 14, right: 14 })
        .onClick(() => {
          safePushUrl(this.getUIContext().getRouter(), { url: 'pages/store/storeaddress', params: this.routeParams() });
        })

    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 30, bottom: 14 })
  }

  @Builder
  Hero() {
    Column() {
      Row() {
        Column() {
          Text('全屋升级套装')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())
            .maxLines(1)
          Text('网关 + 传感器 + 灯光模块，一次补齐回家、观影、睡眠场景。')
            .fontSize(13)
            .lineHeight(20)
            .fontColor(this.secondaryText())
            .margin({ top: 8 })
            .maxLines(2)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Stack() {
          Circle()
            .width(104)
            .height(104)
            .fill(this.isNight ? '#243148' : '#E8F0FF')
          Image($r('app.media.device_lumi_gateway'))
            .width(108)
            .height(108)
            .objectFit(ImageFit.Contain)
        }
        .width(112)
        .height(112)
        .margin({ left: 10 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row() {
        Column() {
          Text('组合价')
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor('#D76626')
          Text('¥629')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#D76626')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Button('查看组合')
          .width(108)
          .height(36)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isNight ? '#11151D' : '#FFFFFF')
          .backgroundColor(this.isNight ? '#F5F7FB' : '#11151D')
          .borderRadius(18)
          .onClick(() => {
            safePushUrl(this.getUIContext().getRouter(), { url: 'pages/store/storecategory', params: { categoryId: 'sensor', isNight: this.isNight } });
          })
      }
      .width('100%')
      .height(64)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 14, right: 12 })
      .backgroundColor(this.isNight ? '#33262D36' : '#FFF8EC')
      .borderRadius(20)
      .margin({ top: 16 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 20, right: 20, top: 22, bottom: 22 })
    .linearGradient({
      angle: 135,
      colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#23342D', 1.0]] : [['#FFF2D7', 0.0], ['#FFFFFF', 0.62], ['#EAF2FF', 1.0]]
    })
    .border({ width: 1, color: this.lineColor() })
    .borderRadius(26)
  }

  @Builder
  CategoryScroller() {
    Scroll() {
      Row() {
        ForEach(STORE_CATEGORIES, (item: StoreCategorySpec) => {
          Text(item.label)
            .fontSize(13)
            .fontWeight(this.activeCategoryId === item.id ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(this.activeCategoryId === item.id ? (this.isNight ? '#11151D' : '#FFFFFF') : this.primaryText())
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(this.activeCategoryId === item.id ? (this.isNight ? '#F5F7FB' : '#11151D') : this.cardColor())
            .border({ width: 1, color: this.lineColor() })
            .borderRadius(18)
            .margin({ right: 8 })
            .onClick(() => {
              this.activeCategoryId = item.id;
            })
        }, (item: StoreCategorySpec) => item.id)
      }
      .padding({ right: 8 })
    }
    .width('100%')
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Horizontal)
    .margin({ top: 16 })
  }

  @Builder
  QuickEntrances() {
    Row() {
      this.Entrance('分类', '按场景找设备', 'pages/store/storecategory', '#5E8CFF')
      this.Entrance('购物车', '2 件待确认', 'pages/store/storecart', '#19B7A4')
      this.Entrance('订单', '物流与订阅', 'pages/store/storeorders', '#F3A33A')
      this.Entrance('地址', '配送与安装', 'pages/store/storeaddress', '#7F72F2')
    }
    .width('100%')
    .margin({ top: 16 })
  }

  @Builder
  Entrance(title: string, desc: string, route: string, color: string) {
    Column() {
      Column()
        .width(24)
        .height(4)
        .borderRadius(2)
        .backgroundColor(color)
        .margin({ bottom: 10 })
      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .maxLines(1)
      Text(desc)
        .fontSize(10)
        .fontColor(this.secondaryText())
        .margin({ top: 5 })
        .maxLines(1)
    }
    .layoutWeight(1)
    .height(86)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .padding({ left: 12, right: 10 })
    .backgroundColor(this.cardColor())
    .border({ width: 1, color: this.lineColor() })
    .borderRadius(18)
    .margin({ right: 8 })
    .onClick(() => {
      safePushUrl(this.getUIContext().getRouter(), { url: route, params: this.routeParams() });
    })
  }

  @Builder
  ProductSection() {
    Column() {
      Row() {
        Text('为你精选')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .layoutWeight(1)

        Button(this.showEmpty ? '恢复' : '空数据')
          .height(32)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F3A33A')
          .backgroundColor(this.isNight ? '#33F3A33A' : '#FFF4E1')
          .borderRadius(16)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.showEmpty = !this.showEmpty;
          })
      }
      .width('100%')
      .margin({ bottom: 10 })

      if (this.products().length === 0) {
        this.EmptyState()
      } else {
        ForEach(this.products(), (item: StoreProductSpec) => {
          this.ProductCard(item)
        }, (item: StoreProductSpec) => item.id)
      }
    }
    .width('100%')
    .margin({ top: 22 })
  }

  @Builder
  ProductCard(item: StoreProductSpec) {
    Row() {
      Image(item.image)
        .width(82)
        .height(82)
        .objectFit(ImageFit.Contain)
        .backgroundColor('#00000000')
        .borderRadius(22)

      Column() {
        Row() {
          Text(item.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())
            .layoutWeight(1)
            .maxLines(1)
          Text(item.tag)
            .fontSize(10)
            .fontWeight(FontWeight.Bold)
            .fontColor('#F3A33A')
            .padding({ left: 8, right: 8, top: 5, bottom: 5 })
            .backgroundColor(this.isNight ? '#33F3A33A' : '#FFF4E1')
            .borderRadius(12)
        }
        .width('100%')

        Text(item.desc)
          .fontSize(12)
          .lineHeight(18)
          .fontColor(this.secondaryText())
          .margin({ top: 6 })
          .maxLines(2)

        Row() {
          Text(item.price)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#D76626')
          Text(`${item.stock} · ${item.fit}`)
            .fontSize(11)
            .fontColor(this.secondaryText())
            .margin({ left: 10 })
            .layoutWeight(1)
            .maxLines(1)
          Button('查看')
            .height(32)
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isNight ? '#11151D' : '#FFFFFF')
            .backgroundColor(this.isNight ? '#F5F7FB' : '#11151D')
            .borderRadius(16)
            .padding({ left: 14, right: 14 })
        }
        .width('100%')
        .margin({ top: 10 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 14 })
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor(this.cardColor())
    .border({ width: 1, color: this.lineColor() })
    .borderRadius(24)
    .margin({ top: 10 })
    .scale(this.buttonScale(item.id))
    .animation({ duration: 120, curve: Curve.EaseOut })
    .onTouch((event: TouchEvent) => {
      this.handlePressState(item.id, event);
    })
    .onClick(() => {
      safePushUrl(this.getUIContext().getRouter(), { url: 'pages/store/storeproduct', params: { productId: item.id, isNight: this.isNight } });
    })
  }

  @Builder
  EmptyState() {
    Column() {
      Text('暂无可售商品')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('当前分类没有匹配商品，可切换分类或稍后刷新。已保留购物车与订单入口。')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(this.secondaryText())
        .textAlign(TextAlign.Center)
        .margin({ top: 8 })
      Button('查看全部分类')
        .height(40)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isNight ? '#11151D' : '#FFFFFF')
        .backgroundColor(this.isNight ? '#F5F7FB' : '#11151D')
        .borderRadius(20)
        .padding({ left: 18, right: 18 })
        .margin({ top: 18 })
        .onClick(() => {
          this.showEmpty = false;
          this.activeCategoryId = 'all';
        })
    }
    .width('100%')
    .padding({ left: 30, right: 30, top: 42, bottom: 42 })
    .backgroundColor(this.cardColor())
    .border({ width: 1, color: this.lineColor() })
    .borderRadius(24)
  }

  @Builder
  NetworkState() {
    Column() {
      Blank().height(86)
      Text('商城加载失败')
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('网络异常导致商品、优惠和库存暂不可用。订单与购物车会显示本地缓存。')
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

@Entry
@Component
struct StoreHomeEntry {
  build() {
    Column() {
      P31_StoreHome({ isNight: false })
    }
    .width('100%')
    .height('100%')
  }
}
