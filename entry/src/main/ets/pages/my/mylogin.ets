import { safeBack, safeGetParams } from '../../common/SafeRouter';
import { loginSmartHome, registerSmartHome, SmartHomeAuthResponse, SmartHomeApiResult } from '../../common/SmartHomeApi';

interface MyLoginRouteParams {
  isNight?: boolean;
}

@Entry
@Component
struct MyLoginPage {
  @State phone: string = '13888888888';
  @State password: string = '123456';
  @State agreed: boolean = true;
  @State networkFailed: boolean = false;
  @State loginSuccess: boolean = false;
  @State loginLoading: boolean = false;
  @State passwordFocused: boolean = false;
  @State isNight: boolean = false;
  @StorageLink('lumiUserSignedIn') signedIn: boolean = false;
  @StorageLink('lumiAuthToken') authToken: string = '';
  @StorageLink('lumiUserPhone') signedPhone: string = '';
  @StorageLink('lumiUserName') signedName: string = '';

  aboutToAppear(): void {
    const params = safeGetParams(this.getUIContext().getRouter()) as MyLoginRouteParams | undefined;
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
    return this.isNight ? '#060709' : '#F2F4F8';
  }

  private cardColor(): string {
    return this.isNight ? '#731F232A' : '#B8FFFFFF';
  }

  private softColor(): string {
    return this.isNight ? '#73161A20' : '#B8EFF2F7';
  }

  private lineColor(): string {
    return this.isNight ? '#24FFFFFF' : '#5CFFFFFF';
  }

  private canLogin(): boolean {
    return this.agreed && this.phone.trim().length >= 6 && this.password.length >= 6 && !this.networkFailed && !this.loginLoading;
  }

  private async handleLogin(): Promise<void> {
    if (!this.canLogin()) {
      return;
    }
    this.loginLoading = true;
    let result: SmartHomeApiResult<SmartHomeAuthResponse> = await loginSmartHome(this.phone.trim(), this.password);
    if (!result.ok && result.statusCode === 401) {
      result = await registerSmartHome(this.phone.trim(), this.password, 'Lumi 用户');
    }
    this.loginLoading = false;
    if (!result.ok || result.data === undefined) {
      this.networkFailed = true;
      return;
    }
    this.authToken = result.data.token;
    this.signedPhone = result.data.user.phone;
    this.signedName = result.data.user.displayName;
    this.signedIn = true;
    this.loginSuccess = true;
  }

  private handleLogout(): void {
    this.signedIn = false;
    this.loginSuccess = false;
    this.authToken = '';
    this.signedPhone = '';
    this.signedName = '';
    this.networkFailed = false;
  }

  build() {
    Stack() {
      Column() {
        this.TopBar()
        if (this.networkFailed) {
          this.NetworkState()
        } else {
          Scroll() {
            Column() {
              this.Hero()
              if (this.signedIn) {
                this.AccountStateCard()
              }
              this.FormCard()
              this.SecurityTips()
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

      if (this.loginSuccess) {
        this.SuccessDialog()
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
      Text('Lumi 登录')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .margin({ left: 14 })
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 28, bottom: 14 })
  }

  @Builder
  Hero() {
    Column() {
      Stack() {
        Column()
          .width(72)
          .height(72)
          .borderRadius(24)
          .linearGradient({ angle: 135, colors: [['#E8F0FF', 0.0], ['#DFF8EF', 1.0]] })
        Text('L')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#36507A')
      }
      .width(72)
      .height(72)
      Text('欢迎回到 Lumi')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .margin({ top: 18 })
      Text('使用密码登录后同步家庭、设备、购物车和授权偏好。')
        .fontSize(13)
        .fontColor(this.secondaryText())
        .margin({ top: 8 })
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 30, bottom: 26 })
    .linearGradient({
      angle: 135,
      colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#23342D', 1.0]] : [['#EAF2FF', 0.0], ['#B8FFFFFF', 0.62], ['#EAF8F4', 1.0]]
    })
    .borderRadius(28)
  }

  @Builder
  FormCard() {
    Column() {
      if (this.signedIn) {
        Text('当前账号')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .width('100%')
        Text(this.phone)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .margin({ top: 8 })
          .width('100%')
        Text('退出后将停止同步家庭、设备、商城订单和授权偏好。')
          .fontSize(12)
          .lineHeight(19)
          .fontColor(this.secondaryText())
          .margin({ top: 8 })
          .width('100%')
      } else {
      Text('手机号')
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
      TextInput({ placeholder: '请输入手机号', text: this.phone })
        .height(48)
        .fontSize(15)
        .fontColor(this.primaryText())
        .backgroundColor(this.softColor())
        .borderRadius(16)
        .padding({ left: 14, right: 14 })
        .margin({ top: 8 })
        .onChange((value: string) => {
          this.phone = value;
        })

      Row() {
        Text('登录密码')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .layoutWeight(1)
        Text(this.password.length >= 6 ? '安全' : '至少 6 位')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.password.length >= 6 ? '#19B7A4' : this.secondaryText())
      }
      .width('100%')
      .margin({ top: 16 })

      TextInput({ placeholder: '请输入 Lumi 密码', text: this.password })
        .type(InputType.Password)
        .height(48)
        .fontSize(15)
        .fontColor(this.primaryText())
        .backgroundColor(this.softColor())
        .borderRadius(16)
        .padding({ left: 14, right: 14 })
        .margin({ top: 8 })
        .border({
          width: this.passwordFocused ? 1.4 : 0,
          color: this.passwordFocused ? '#F3A33A' : '#00000000'
        })
        .onFocus(() => {
          this.passwordFocused = true;
        })
        .onBlur(() => {
          this.passwordFocused = false;
        })
        .onChange((value: string) => {
          this.password = value;
        })

      Row() {
        this.AgreementCheck()
        Text('同意 Lumi 用户协议与隐私政策')
          .fontSize(12)
          .fontColor(this.secondaryText())
          .margin({ left: 8 })
      }
      .width('100%')
      .margin({ top: 16 })

      Button(this.loginLoading ? '正在同步...' : '登录并同步')
        .width('100%')
        .height(46)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor(this.canLogin() ? '#F3A33A' : '#B8C0CC')
        .borderRadius(23)
        .margin({ top: 18 })
        .onClick(() => {
          this.handleLogin();
        })

      Row() {
        Text('忘记密码')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#5E8CFF')
        Blank()
        Text('设备登录保护已开启')
          .fontSize(12)
          .fontColor(this.secondaryText())
      }
      .width('100%')
      .margin({ top: 14 })
      }
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 16 })
    .shadow({ radius: 18, color: this.isNight ? '#66000000' : '#12151C20', offsetY: 8 })
  }

  @Builder
  AccountStateCard() {
    Row() {
      Column() {
        Text('已登录')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
        Text('Lumi 家庭数据正在同步')
          .fontSize(12)
          .fontColor(this.secondaryText())
          .margin({ top: 6 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Button('退出登录')
        .height(36)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#D35B4B')
        .backgroundColor(this.isNight ? '#33D35B4B' : '#FFF1EF')
        .borderRadius(18)
        .padding({ left: 14, right: 14 })
        .onClick(() => {
          this.handleLogout();
        })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 16, bottom: 16 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 16 })
  }

  @Builder
  AgreementCheck() {
    Stack() {
      Circle()
        .width(24)
        .height(24)
        .fill(this.agreed ? '#F3A33A' : '#00000000')
        .stroke(this.agreed ? '#F3A33A' : (this.isNight ? '#66FFFFFF' : '#B8C0CC'))
        .strokeWidth(1.4)
      if (this.agreed) {
        Text('√')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
      }
    }
    .width(24)
    .height(24)
    .onClick(() => {
      this.agreed = !this.agreed;
    })
  }

  @Builder
  SecurityTips() {
    Column() {
      Text('安全提示')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
      Text('Lumi 密码用于保护家庭成员、设备授权和商城订单。新设备登录后会同步家庭权限，并在消息中心生成安全提醒。')
        .fontSize(13)
        .lineHeight(21)
        .fontColor(this.secondaryText())
        .margin({ top: 8 })
        .width('100%')
      Row() {
        this.SecurityChip('密码保护')
        this.SecurityChip('家庭权限同步')
        this.SecurityChip('订单同步')
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
  SecurityChip(text: string) {
    Text(text)
      .fontSize(11)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.isNight ? '#F6F8FC' : '#36507A')
      .padding({ left: 10, right: 10, top: 7, bottom: 7 })
      .backgroundColor(this.softColor())
      .borderRadius(15)
      .margin({ right: 8 })
  }

  @Builder
  NetworkState() {
    Column() {
      Blank().height(86)
      Text('登录服务不可用')
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('当前网络异常，暂时无法校验账号密码。你仍可返回查看本地缓存家庭。')
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
        .backgroundColor('#5E8CFF')
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

  @Builder
  SuccessDialog() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.isNight ? '#52000000' : '#26000000')

      Column() {
      Stack() {
        Circle()
          .width(58)
          .height(58)
          .fill('#35D27A')
        Text('√')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width(58)
      .height(58)

        Text('登录成功')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .margin({ top: 16 })

        Text('家庭、设备、购物车和授权偏好已同步')
          .fontSize(13)
          .lineHeight(21)
          .fontColor(this.secondaryText())
          .textAlign(TextAlign.Center)
          .margin({ left: 12, right: 12, top: 10 })

        Button('进入我的')
          .width('100%')
          .height(42)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isNight ? '#11151D' : '#FFFFFF')
          .backgroundColor(this.isNight ? '#F5F7FB' : '#11151D')
          .borderRadius(21)
          .margin({ top: 20 })
          .onClick(() => {
            safeBack(this.getUIContext().getRouter());
          })
      }
      .width('78%')
      .padding({ left: 22, right: 22, top: 24, bottom: 22 })
      .backgroundColor(this.isNight ? '#D91A1E25' : '#EFFFFFFF')
      .border({ width: 1, color: this.lineColor() })
      .borderRadius(26)
      .alignItems(HorizontalAlign.Center)
      .shadow({ radius: 26, color: this.isNight ? '#AA000000' : '#33000000', offsetY: 12 })
    }
    .width('100%')
    .height('100%')
  }
}
