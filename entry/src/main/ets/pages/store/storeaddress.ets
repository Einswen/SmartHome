import { safeBack, safeGetParams } from '../../common/SafeRouter';

interface StoreAddressRouteParams {
  isNight?: boolean;
}

interface AddressSpec {
  id: string;
  name: string;
  phone: string;
  region: string;
  detail: string;
  tag: string;
  isDefault: boolean;
}

const ADDRESS_LIST: AddressSpec[] = [
  {
    id: 'home',
    name: 'Lumi 用户',
    phone: '138 **** 8888',
    region: '上海市 浦东新区',
    detail: '智能家居体验中心 8 号楼 1201',
    tag: '家庭',
    isDefault: true
  },
  {
    id: 'office',
    name: '安装联系人',
    phone: '136 **** 6620',
    region: '上海市 徐汇区',
    detail: '漕河泾开发区 18 号 6 层',
    tag: '工作',
    isDefault: false
  }
];

@Entry
@Component
struct StoreAddressPage {
  @State isNight: boolean = false;
  @State editing: boolean = false;
  @State selectedAddressId: string = 'home';

  aboutToAppear(): void {
    const params = safeGetParams(this.getUIContext().getRouter()) as StoreAddressRouteParams | undefined;
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

  private lineColor(): string {
    return this.isNight ? '#20FFFFFF' : '#12000000';
  }

  build() {
    Column() {
      this.TopBar()

      Scroll() {
        Column() {
          this.SummaryCard()
          this.AddressList()
          this.AddressForm()
        }
        .width('100%')
        .padding({ left: 18, right: 18, bottom: 32 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
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

      Text('收货地址')
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
  SummaryCard() {
    Column() {
      Text('配送与安装地址')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')

      Text('商城订单、上门安装和售后服务会默认使用这里的地址。')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(this.secondaryText())
        .margin({ top: 8 })
        .width('100%')
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 22, bottom: 22 })
    .linearGradient({
      angle: 135,
      colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#332B1C', 1.0]] : [['#FFF2D7', 0.0], ['#FFFFFF', 0.62], ['#EAF2FF', 1.0]]
    })
    .border({ width: 1, color: this.lineColor() })
    .borderRadius(26)
  }

  @Builder
  AddressList() {
    Column() {
      Text('常用地址')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
        .margin({ bottom: 10 })

      ForEach(ADDRESS_LIST, (item: AddressSpec) => {
        this.AddressCard(item)
      }, (item: AddressSpec) => item.id)
    }
    .width('100%')
    .margin({ top: 22 })
  }

  @Builder
  AddressCard(item: AddressSpec) {
    Column() {
      Row() {
        Text(item.tag)
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(item.isDefault ? '#F3A33A' : '#5E8CFF')
          .borderRadius(14)

        Text(item.isDefault ? '默认地址' : '备用地址')
          .fontSize(12)
          .fontColor(this.secondaryText())
          .margin({ left: 10 })
          .layoutWeight(1)

        Radio({ value: item.id, group: 'address' })
          .checked(this.selectedAddressId === item.id)
          .onChange((checked: boolean) => {
            if (checked) {
              this.selectedAddressId = item.id;
            }
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text(`${item.name}  ${item.phone}`)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
        .margin({ top: 14 })

      Text(`${item.region} ${item.detail}`)
        .fontSize(13)
        .lineHeight(20)
        .fontColor(this.secondaryText())
        .width('100%')
        .margin({ top: 6 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(this.cardColor())
    .border({ width: 1, color: this.selectedAddressId === item.id ? '#F3A33A' : this.lineColor() })
    .borderRadius(22)
    .margin({ top: 10 })
    .onClick(() => {
      this.selectedAddressId = item.id;
    })
  }

  @Builder
  AddressForm() {
    Column() {
      Row() {
        Text('新增地址')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .layoutWeight(1)

        Button(this.editing ? '收起' : '添加')
          .height(34)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor('#F3A33A')
          .borderRadius(17)
          .padding({ left: 14, right: 14 })
          .onClick(() => {
            this.editing = !this.editing;
          })
      }
      .width('100%')

      if (this.editing) {
        this.FormRow('联系人', '请输入收货人姓名')
        this.FormRow('手机号', '请输入联系电话')
        this.FormRow('所在地区', '省 / 市 / 区')
        this.FormRow('详细地址', '街道、门牌号、楼层')

        Button('保存地址')
          .width('100%')
          .height(44)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor('#11151D')
          .borderRadius(22)
          .margin({ top: 14 })
          .onClick(() => {
            this.editing = false;
          })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(this.cardColor())
    .border({ width: 1, color: this.lineColor() })
    .borderRadius(22)
    .margin({ top: 22 })
  }

  @Builder
  FormRow(label: string, placeholder: string) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.secondaryText())
        .width('100%')

      TextInput({ placeholder: placeholder })
        .height(42)
        .fontSize(13)
        .fontColor(this.primaryText())
        .placeholderColor(this.secondaryText())
        .backgroundColor(this.softColor())
        .borderRadius(16)
        .margin({ top: 8 })
    }
    .width('100%')
    .margin({ top: 14 })
  }
}
