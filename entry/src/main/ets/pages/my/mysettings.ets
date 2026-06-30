import router from '@ohos.router';

interface MySettingsRouteParams {
  isNight?: boolean;
}

interface SettingRowSpec {
  id: string;
  title: string;
  desc: string;
  value: string;
}

const SECURITY_ROWS: SettingRowSpec[] = [
  { id: 'login', title: '登录保护', desc: '新设备登录需要短信验证', value: '已开启' },
  { id: 'devices', title: '已登录设备', desc: '手机、平板与家庭中控屏', value: '3 台' },
  { id: 'password', title: '修改密码', desc: '建议 90 天定期更新一次', value: '去设置' }
];

const NOTICE_ROWS: SettingRowSpec[] = [
  { id: 'alert', title: '重要告警', desc: '漏水、门锁、烟雾与离线提醒', value: '立即推送' },
  { id: 'auto', title: '自动化通知', desc: '脚本执行完成或失败后提醒', value: '仅失败' },
  { id: 'mall', title: '商城服务', desc: '订单、优惠与耗材到期提醒', value: '低频' }
];

const PRIVACY_ROWS: SettingRowSpec[] = [
  { id: 'location', title: '位置权限', desc: '用于离家/到家自动化判断', value: '使用时' },
  { id: 'voice', title: '语音记录', desc: '用于提升家庭语义识别准确率', value: '关闭' },
  { id: 'share', title: '第三方授权', desc: '查看已授权的云服务和插件', value: '2 项' }
];

@Entry
@Component
struct MySettingsPage {
  @State networkFailed: boolean = false;
  @State activeTab: string = 'security';
  @StorageLink('myPrefPushEnabled') pushEnabled: boolean = true;
  @StorageLink('myPrefAutoUpgrade') autoUpgrade: boolean = false;
  @StorageLink('myPrefDarkFollowHome') darkFollowHome: boolean = true;
  @StorageLink('myPrefMallNotify') mallNotify: boolean = true;
  @StorageLink('homeNightMode') isNight: boolean = false;
  @StorageLink('homeNightManual') nightManual: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams() as MySettingsRouteParams;
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

  private softColor(): string {
    return this.isNight ? '#661F2632' : '#F0F4FA';
  }

  private rows(): SettingRowSpec[] {
    if (this.activeTab === 'notice') {
      return NOTICE_ROWS;
    }
    if (this.activeTab === 'privacy') {
      return PRIVACY_ROWS;
    }
    return SECURITY_ROWS;
  }

  private togglePreference(key: string): void {
    if (key === 'push') {
      this.pushEnabled = !this.pushEnabled;
    } else if (key === 'upgrade') {
      this.autoUpgrade = !this.autoUpgrade;
    } else if (key === 'night') {
      this.nightManual = true;
      this.isNight = !this.isNight;
    } else if (key === 'auto_night') {
      this.nightManual = !this.nightManual;
      if (!this.nightManual) {
        const hour = new Date().getHours();
        this.isNight = hour >= 18 || hour < 6;
      }
    } else if (key === 'dark') {
      this.darkFollowHome = !this.darkFollowHome;
    } else {
      this.mallNotify = !this.mallNotify;
    }
  }

  private preferenceEnabled(key: string): boolean {
    if (key === 'push') {
      return this.pushEnabled;
    }
    if (key === 'upgrade') {
      return this.autoUpgrade;
    }
    if (key === 'night') {
      return this.isNight;
    }
    if (key === 'auto_night') {
      return !this.nightManual;
    }
    if (key === 'dark') {
      return this.darkFollowHome;
    }
    return this.mallNotify;
  }

  build() {
    Column() {
      this.TopBar()

      if (this.networkFailed) {
        this.NetworkState()
      } else {
        Scroll() {
          Column() {
            this.SecurityCard()
            this.HardwareCloudCard()
            this.TabBar()
            this.SettingList()
            this.PreferenceCard()
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

      Text('授权中心')
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
        .backgroundColor(this.networkFailed ? '#7F72F2' : this.cardColor())
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
  HardwareCloudCard() {
    Row() {
      Column() {
        Text('硬件联调')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
        Text('连接华为云 IoTDA，测试 IA01 灯、电机和设备影子。')
          .fontSize(12)
          .lineHeight(18)
          .fontColor(this.secondaryText())
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Button('打开')
        .height(36)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#5E8CFF')
        .borderRadius(18)
        .padding({ left: 18, right: 18 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/hardware/HuaweiCloudDemo', params: { isNight: this.isNight } });
        })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 16, bottom: 16 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 16 })
  }

  @Builder
  SecurityCard() {
    Column() {
      Row() {
        Column() {
          Text('安全评分')
            .fontSize(14)
            .fontColor(this.secondaryText())
          Text('92')
            .fontSize(42)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('优秀')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor('#35D27A')
          .borderRadius(17)
      }
      .width('100%')

      Text('已开启登录保护，建议定期检查家庭共享成员、位置权限和第三方授权。')
        .fontSize(13)
        .lineHeight(21)
        .fontColor(this.secondaryText())
        .margin({ top: 10 })
        .width('100%')
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 22, bottom: 22 })
    .linearGradient({ angle: 135, colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#251C33', 1.0]] : [['#EFEAFF', 0.0], ['#FFFFFF', 0.62], ['#EAF8F4', 1.0]] })
    .borderRadius(26)
  }

  @Builder
  TabBar() {
    Row() {
      this.TabChip('security', '安全')
      this.TabChip('notice', '通知')
      this.TabChip('privacy', '隐私')
    }
    .width('100%')
    .padding({ left: 6, right: 6, top: 6, bottom: 6 })
    .backgroundColor(this.cardColor())
    .borderRadius(22)
    .margin({ top: 16 })
  }

  @Builder
  TabChip(id: string, label: string) {
    Text(label)
      .layoutWeight(1)
      .height(38)
      .fontSize(13)
      .fontWeight(this.activeTab === id ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(this.activeTab === id ? (this.isNight ? '#11151D' : '#FFFFFF') : this.secondaryText())
      .textAlign(TextAlign.Center)
      .backgroundColor(this.activeTab === id ? (this.isNight ? '#F5F7FB' : '#11151D') : '#00000000')
      .borderRadius(18)
      .onClick(() => {
        this.activeTab = id;
      })
  }

  @Builder
  SettingList() {
    Column() {
      ForEach(this.rows(), (item: SettingRowSpec) => {
        Row() {
          Column() {
            Text(item.title)
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.primaryText())
            Text(item.desc)
              .fontSize(12)
              .fontColor(this.secondaryText())
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text(item.value)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#5E8CFF')
        }
        .width('100%')
        .height(72)
        .border({ width: { bottom: 1 }, color: this.isNight ? '#18FFFFFF' : '#10000000' })
      }, (item: SettingRowSpec) => item.id)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 8, bottom: 8 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 16 })
  }

  @Builder
  PreferenceCard() {
    Column() {
      Text('通用偏好')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
        .margin({ bottom: 12 })

      this.SwitchRow('重要告警推送', '断网、漏水、门锁异常立即提醒', 'push')
      this.SwitchRow('夜间自动升级', '低峰时段静默升级设备固件', 'upgrade')
      this.SwitchRow('全局夜间模式', '立即切换首页、商城和我的页面深色视觉', 'night')
      this.SwitchRow('跟随时间自动切换', '18:00 后进入夜间，06:00 后恢复日间', 'auto_night')
      this.SwitchRow('跨页面视觉同步', '商城、我的和设备详情沿用同一套夜间状态', 'dark')
      this.SwitchRow('商城服务提醒', '订单、耗材和售后工单低频提醒', 'mall')
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 6 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 16 })
  }

  @Builder
  SwitchRow(title: string, desc: string, key: string) {
    Row() {
      Column() {
        Text(title).fontSize(15).fontWeight(FontWeight.Bold).fontColor(this.primaryText())
        Text(desc).fontSize(12).fontColor(this.secondaryText()).margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Row() {
        if (this.preferenceEnabled(key)) {
          Blank()
        }
        Circle()
          .width(24)
          .height(24)
          .fill('#FFFFFF')
          .margin({ left: 4, right: 4 })
        if (!this.preferenceEnabled(key)) {
          Blank()
        }
      }
      .width(54)
      .height(32)
      .backgroundColor(this.preferenceEnabled(key) ? '#F3A33A' : this.softColor())
      .borderRadius(16)
      .animation({ duration: 160, curve: Curve.EaseOut })
    }
    .width('100%')
    .height(70)
    .onClick(() => {
      this.togglePreference(key);
    })
  }

  @Builder
  NetworkState() {
    Column() {
      Blank().height(86)
      Text('设置同步失败')
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('当前展示的是本地缓存，账号安全和授权状态暂时无法更新。')
        .fontSize(13)
        .lineHeight(21)
        .fontColor(this.secondaryText())
        .textAlign(TextAlign.Center)
        .margin({ left: 36, right: 36, top: 10 })
      Button('重新同步')
        .height(42)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#7F72F2')
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
