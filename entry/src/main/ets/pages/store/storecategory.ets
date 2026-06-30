import { safeBack, safeGetParams, safePushUrl } from '../../common/SafeRouter';

interface StoreCategoryRouteParams {
  isNight?: boolean;
}

@Entry
@Component
struct StoreCategoryPage {
  @State isNight: boolean = false;
  @State networkFailed: boolean = false;
  @State showEmpty: boolean = false;

  aboutToAppear(): void {
    const params = safeGetParams(this.getUIContext().getRouter()) as StoreCategoryRouteParams | undefined;
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
            } else {
              this.CategoryCard('传感与环境', '感知温湿度、光照、人体存在，用于精细化自动化。', $r('app.media.device_environment_sensor'), 'sensor_pro', '#19B7A4')
              this.CategoryCard('灯光与氛围', '亮度、色温、场景联动，让客厅和卧室更舒适。', $r('app.media.device_living_light'), 'light_module', '#F3A33A')
              this.CategoryCard('安防与控制', '网关、面板、门锁与异常告警服务。', $r('app.media.device_gesture_sensor'), 'gesture_panel', '#5E8CFF')
              this.CategoryCard('清洁与耗材', '扫地机器人维护套装、净化器滤芯和电池。', $r('app.media.device_living_robot'), 'robot_pack', '#7F72F2')
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
      Text('商品分类')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .margin({ left: 14 })
        .layoutWeight(1)
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
    .width('100%')
    .padding({ left: 18, right: 18, top: 28, bottom: 14 })
  }

  @Builder
  Hero() {
    Column() {
      Text('按家庭场景选购')
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
      Text('每个分类都对应首页设备和自动化能力，避免买了不能联动。')
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
        .backgroundColor(this.softColor())
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
