import { safePushUrl } from '../../common/SafeRouter';

interface MyFeatureSpec {
  id: string;
  title: string;
  desc: string;
  route: string;
  accent: string;
}

interface MyServiceSpec {
  id: string;
  title: string;
  desc: string;
  tag: string;
  route: string;
}

const MY_FEATURES: MyFeatureSpec[] = [
  { id: 'devices', title: '设备中心', desc: '与首页客厅设备同步，支持扩展设备管理', route: 'pages/my/mydevices', accent: '#5E8CFF' },
  { id: 'family', title: '家庭管理', desc: '成员、邀请、权限与家庭切换', route: 'pages/my/myfamily', accent: '#19B7A4' },
  { id: 'plans', title: '方案中心', desc: '全屋场景、节能模式与设备联动方案', route: 'pages/plancenter/plancenter', accent: '#F3A33A' },
  { id: 'settings', title: '授权中心', desc: '账号安全、隐私授权与通用偏好', route: 'pages/my/mysettings', accent: '#7F72F2' }
];

const MY_SERVICES: MyServiceSpec[] = [
  { id: 'login', title: 'Lumi 登录', desc: '手机号、密码与家庭身份', tag: '账号', route: 'pages/my/mylogin' },
  { id: 'after_sale', title: '售后支持', desc: '保修、工单与上门服务', tag: '2 小时响应', route: 'pages/store/storeservice' },
  { id: 'orders', title: '商城订单', desc: '耗材订阅与订单跟踪', tag: '订单', route: 'pages/store/storeorders' },
  { id: 'privacy', title: '通用偏好', desc: '通知、升级和第三方授权', tag: '可交互', route: 'pages/my/mysettings' }
];

@Component
export struct P21_MyProfile {
  @Prop isNight: boolean;
  @Prop transparentBg: boolean = false;
  @State pressedKey: string = '';
  @StorageLink('lumiUserSignedIn') signedIn: boolean = false;
  @StorageLink('lumiAuthToken') authToken: string = '';
  @StorageLink('lumiHomeState') homeStateText: string = '';
  @StorageLink('lumiUserPhone') signedPhone: string = '';
  @StorageLink('lumiUserName') signedName: string = '';
  @StorageLink('homeLivingPointIds') livingPointIdsText: string = '';
  @StorageLink('homeLivingDeviceCount') livingDeviceCount: number = 0;

  private primaryText(): string {
    return this.isNight ? '#F7F9FD' : '#11151D';
  }

  private secondaryText(): string {
    return this.isNight ? '#A8B0BF' : '#687181';
  }

  private bgColor(): string {
    if (this.transparentBg) {
      return '#00000000';
    }
    return this.isNight ? '#060709' : '#F2F4F8';
  }

  private panelColor(): string {
    return this.isNight ? '#731F232A' : '#B8FFFFFF';
  }

  private softPanelColor(): string {
    return this.isNight ? '#73161A20' : '#B8EFF2F7';
  }

  private lineColor(): string {
    return this.isNight ? '#24FFFFFF' : '#5CFFFFFF';
  }

  private hasAuthSession(): boolean {
    return this.signedIn && this.authToken.trim().length > 0;
  }

  private shadowColor(): string {
    return this.isNight ? '#66000000' : '#14151C20';
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

  private go(route: string): void {
    safePushUrl(this.getUIContext().getRouter(), { url: route, params: { isNight: this.isNight } });
  }

  build() {
    Scroll() {
      Column() {
        this.ProfileHeader()
        if (this.hasAuthSession()) {
          this.CommonFeatureBoard()
          this.HealthSummary()
        } else {
          this.ProfileLoginPrompt()
        }
        this.ServiceGrid()
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 30, bottom: 126 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor())
    .scrollBar(BarState.Off)
  }

  @Builder
  ProfileHeader() {
    Row() {
      Stack() {
        Column()
          .width(58)
          .height(58)
          .borderRadius(20)
          .linearGradient({
            angle: 135,
            colors: this.isNight ? [['#33445E', 0.0], ['#1A202B', 1.0]] : [['#E8F0FF', 0.0], ['#DFF8EF', 1.0]]
          })

        Text('L')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isNight ? '#EAF0FF' : '#36507A')
      }
      .width(58)
      .height(58)
      .margin({ right: 14 })

      Column() {
        Text(this.hasAuthSession() ? 'Lumi 用户' : '未登录')
          .fontSize(25)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .maxLines(1)

        Text(this.hasAuthSession() ? 'Lumi 用户' : '未登录')
          .fontSize(13)
          .fontColor(this.secondaryText())
          .margin({ top: 7 })
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Button(this.hasAuthSession() ? '退出登录' : '登录')
        .height(36)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.hasAuthSession() ? '#D35B4B' : '#FFFFFF')
        .backgroundColor(this.hasAuthSession() ? (this.isNight ? '#33D35B4B' : '#FFF1EF') : '#11151D')
        .borderRadius(18)
        .padding({ left: 14, right: 14 })
        .onClick(() => {
          if (this.hasAuthSession()) {
            this.signedIn = false;
            this.authToken = '';
            this.homeStateText = '';
            this.livingPointIdsText = '';
            this.livingDeviceCount = 0;
            this.signedPhone = '';
            this.signedName = '';
          } else {
            safePushUrl(this.getUIContext().getRouter(), { url: 'pages/my/mylogin', params: { isNight: this.isNight } });
          }
        })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  ProfileLoginPrompt() {
    Column() {
      Text('登录后同步家庭')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())

      Text('设备、家庭、健康状态和自动化方案会跟随账号同步。')
        .fontSize(12)
        .lineHeight(20)
        .fontColor(this.secondaryText())
        .textAlign(TextAlign.Center)
        .width('82%')
        .margin({ top: 8 })

      Button('登录账号')
        .height(40)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#11151D')
        .borderRadius(20)
        .padding({ left: 20, right: 20 })
        .margin({ top: 18 })
        .onClick(() => {
          safePushUrl(this.getUIContext().getRouter(), { url: 'pages/my/mylogin', params: { isNight: this.isNight } });
        })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 26, bottom: 26 })
    .backgroundColor(this.panelColor())
    .border({ width: 1, color: this.lineColor() })
    .borderRadius(24)
    .margin({ top: 22 })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  CommonFeatureBoard() {
    Column() {
      Text('常用功能')
        .width('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .margin({ bottom: 14 })

      Row() {
        this.FeatureCard(MY_FEATURES[0], '设')
        Blank().width(12)
        this.FeatureCard(MY_FEATURES[1], '家')
      }
      .width('100%')

      Row() {
        this.FeatureCard(MY_FEATURES[2], '讯')
        Blank().width(12)
        this.FeatureCard(MY_FEATURES[3], '权')
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .margin({ top: 22 })
  }

  @Builder
  FeatureCard(item: MyFeatureSpec, badge: string) {
    Column() {
      Row() {
        Text(badge)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(item.accent)
          .width(46)
          .height(46)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.softPanelColor())
          .borderRadius(16)

        Blank()

        Image($r('sys.media.ohos_ic_public_arrow_right'))
          .width(16)
          .height(16)
          .fillColor(this.secondaryText())
          .opacity(0.62)
      }
      .width('100%')

      Text(item.title)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .margin({ top: 18 })
        .maxLines(1)

      Text(item.desc)
        .fontSize(12)
        .lineHeight(18)
        .fontColor(this.secondaryText())
        .margin({ top: 6 })
        .maxLines(2)

      Column()
        .width(28)
        .height(4)
        .borderRadius(2)
        .backgroundColor(item.accent)
        .margin({ top: 18 })
    }
    .layoutWeight(1)
    .height(174)
    .padding({ left: 16, right: 16, top: 16, bottom: 14 })
    .backgroundColor(this.panelColor())
    .border({ width: 1, color: this.lineColor() })
    .borderRadius(22)
    .shadow({ radius: 16, color: this.shadowColor(), offsetY: 8 })
    .scale(this.buttonScale(`feature_${item.id}`))
    .animation({ duration: 120, curve: Curve.EaseOut })
    .onTouch((event: TouchEvent) => {
      this.handlePressState(`feature_${item.id}`, event);
    })
    .onClick(() => {
      this.go(item.route);
    })
  }

  @Builder
  HealthSummary() {
    Column() {
      Row() {
        Text('家庭状态')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .layoutWeight(1)

        Text('刚刚同步')
          .fontSize(12)
          .fontColor(this.secondaryText())
      }
      .width('100%')

      Row() {
        this.HealthMetric('设备数', `${this.livingDeviceCount}`, '#35D27A')
        Blank().width(8)
        this.HealthMetric('异常设备', '0', '#F3A33A')
        Blank().width(8)
        this.HealthMetric('自动化', '0', '#5E8CFF')
      }
      .width('100%')
      .margin({ top: 14 })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(this.panelColor())
    .border({ width: 1, color: this.lineColor() })
    .borderRadius(24)
    .margin({ top: 22 })
    .onClick(() => {
      safePushUrl(this.getUIContext().getRouter(), { url: 'pages/my/myhomehealth', params: { isNight: this.isNight } });
    })
  }

  @Builder
  HealthMetric(label: string, value: string, color: string) {
    Column() {
      Text(value)
        .fontSize(21)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(11)
        .fontColor(this.secondaryText())
        .margin({ top: 5 })
    }
    .layoutWeight(1)
    .height(70)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.softPanelColor())
    .borderRadius(18)
  }

  @Builder
  ServiceGrid() {
    Column() {
      Text('更多服务')
        .width('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .margin({ bottom: 14 })

      Row() {
        this.ServiceTile(MY_SERVICES[0])
        Blank().width(10)
        this.ServiceTile(MY_SERVICES[1])
      }
      .width('100%')

      Row() {
        this.ServiceTile(MY_SERVICES[2])
        Blank().width(10)
        this.ServiceTile(MY_SERVICES[3])
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .margin({ top: 22 })
  }

  @Builder
  ServiceTile(item: MyServiceSpec) {
    Column() {
      Text(item.tag)
        .fontSize(10)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5E8CFF')
        .padding({ left: 8, right: 8, top: 5, bottom: 5 })
        .backgroundColor(this.softPanelColor())
        .borderRadius(12)
        .margin({ bottom: 12 })

      Text(item.title)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .maxLines(1)

      Text(item.desc)
        .fontSize(11)
        .lineHeight(17)
        .fontColor(this.secondaryText())
        .margin({ top: 6 })
        .maxLines(2)
    }
    .layoutWeight(1)
    .height(126)
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 15, right: 15, top: 15, bottom: 14 })
    .backgroundColor(this.panelColor())
    .border({ width: 1, color: this.lineColor() })
    .borderRadius(20)
    .scale(this.buttonScale(`service_${item.id}`))
    .animation({ duration: 120, curve: Curve.EaseOut })
    .onTouch((event: TouchEvent) => {
      this.handlePressState(`service_${item.id}`, event);
    })
    .onClick(() => {
      this.go(item.route);
    })
  }
}
