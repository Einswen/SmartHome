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
    name: '商城用户',
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
  @State customAddresses: AddressSpec[] = [];
  @State contactName: string = '';
  @State contactPhone: string = '';
  @State contactRegion: string = '';
  @State contactDetail: string = '';
  @State phoneError: string = '';
  @StorageLink('storeAddressPayload') addressPayload: string = '';
  @StorageLink('storeDeletedAddressIds') deletedAddressIdsText: string = '';

  aboutToAppear(): void {
    const params = safeGetParams(this.getUIContext().getRouter()) as StoreAddressRouteParams | undefined;
    if (params && params.isNight !== undefined) {
      this.isNight = params.isNight;
    }
    this.loadCustomAddresses();
    this.ensureSelectedAddress();
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

  private addresses(): AddressSpec[] {
    const baseAddresses: AddressSpec[] = [];
    for (let i = 0; i < ADDRESS_LIST.length; i++) {
      if (!this.isDeletedAddress(ADDRESS_LIST[i].id)) {
        baseAddresses.push(ADDRESS_LIST[i]);
      }
    }
    return [...baseAddresses, ...this.customAddresses];
  }

  private deletedAddressIds(): string[] {
    return this.deletedAddressIdsText.length > 0 ? this.deletedAddressIdsText.split('|').filter((id: string) => id.length > 0) : [];
  }

  private isDeletedAddress(addressId: string): boolean {
    return this.deletedAddressIds().indexOf(addressId) >= 0;
  }

  private isCustomAddress(addressId: string): boolean {
    return addressId.indexOf('custom_') === 0;
  }

  private ensureSelectedAddress(): void {
    const currentAddresses: AddressSpec[] = this.addresses();
    if (currentAddresses.length === 0) {
      this.selectedAddressId = '';
      return;
    }
    for (let i = 0; i < currentAddresses.length; i++) {
      if (currentAddresses[i].id === this.selectedAddressId) {
        return;
      }
    }
    this.selectedAddressId = currentAddresses[0].id;
  }

  private loadCustomAddresses(): void {
    if (this.addressPayload.length === 0) {
      return;
    }
    const lines: string[] = this.addressPayload.split('\n');
    const addresses: AddressSpec[] = [];
    for (let i = 0; i < lines.length; i++) {
      const parts: string[] = lines[i].split('|');
      if (parts.length !== 6 || parts[0].length === 0) {
        continue;
      }
      addresses.push({
        id: parts[0],
        name: parts[1],
        phone: parts[2],
        region: parts[3],
        detail: parts[4],
        tag: parts[5],
        isDefault: false
      });
    }
    this.customAddresses = addresses;
  }

  private syncCustomAddresses(): void {
    const lines: string[] = [];
    for (let i = 0; i < this.customAddresses.length; i++) {
      const item = this.customAddresses[i];
      lines.push(`${item.id}|${item.name}|${item.phone}|${item.region}|${item.detail}|${item.tag}`);
    }
    this.addressPayload = lines.join('\n');
  }

  private validPhone(phone: string): boolean {
    return /^1[3-9]\d{9}$/.test(phone.trim());
  }

  private saveAddress(): void {
    const phone: string = this.contactPhone.trim();
    if (phone.length === 0) {
      this.phoneError = '请输入手机号';
      return;
    }
    if (!this.validPhone(phone)) {
      this.phoneError = '请输入 11 位有效手机号';
      return;
    }
    const nextIndex = this.customAddresses.length + 1;
    const nextAddress: AddressSpec = {
      id: `custom_${new Date().getTime()}`,
      name: this.contactName.trim().length > 0 ? this.contactName.trim() : `新增联系人 ${nextIndex}`,
      phone: phone,
      region: this.contactRegion.trim().length > 0 ? this.contactRegion.trim() : '未填写地区',
      detail: this.contactDetail.trim().length > 0 ? this.contactDetail.trim() : '未填写详细地址',
      tag: '新增',
      isDefault: false
    };
    this.customAddresses = [...this.customAddresses, nextAddress];
    this.syncCustomAddresses();
    this.selectedAddressId = nextAddress.id;
    this.contactName = '';
    this.contactPhone = '';
    this.contactRegion = '';
    this.contactDetail = '';
    this.phoneError = '';
    this.editing = false;
  }

  private deleteAddress(addressId: string): void {
    if (this.isCustomAddress(addressId)) {
      this.customAddresses = this.customAddresses.filter((item: AddressSpec) => item.id !== addressId);
      this.syncCustomAddresses();
    } else {
      const deletedIds: string[] = this.deletedAddressIds();
      if (deletedIds.indexOf(addressId) < 0) {
        deletedIds.push(addressId);
        this.deletedAddressIdsText = deletedIds.join('|');
      }
    }
    if (this.selectedAddressId === addressId) {
      this.selectedAddressId = '';
    }
    this.ensureSelectedAddress();
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
      colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#332B1C', 1.0]] : [['#FFF2D7', 0.0], ['#B8FFFFFF', 0.62], ['#EAF2FF', 1.0]]
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

      if (this.addresses().length === 0) {
        Text('暂无地址，请添加新的配送地址。')
          .fontSize(13)
          .fontColor(this.secondaryText())
          .width('100%')
          .padding({ left: 16, right: 16, top: 24, bottom: 24 })
          .backgroundColor(this.cardColor())
          .border({ width: 1, color: this.lineColor() })
          .borderRadius(22)
      } else {
        ForEach(this.addresses(), (item: AddressSpec) => {
          this.AddressCard(item)
        }, (item: AddressSpec) => item.id)
      }
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

      Button('删除')
        .height(32)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#D35B4B')
        .backgroundColor(this.isNight ? '#33D35B4B' : '#FFF1EF')
        .borderRadius(16)
        .padding({ left: 14, right: 14 })
        .margin({ top: 12 })
        .onClick(() => {
          this.deleteAddress(item.id);
        })
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
        this.FormRow('联系人', '请输入收货人姓名', 'name')
        this.FormRow('手机号', '请输入联系电话', 'phone')
        if (this.phoneError.length > 0) {
          Text(this.phoneError)
            .fontSize(12)
            .fontColor('#D35B4B')
            .width('100%')
            .margin({ top: 6 })
        }
        this.FormRow('所在地区', '省 / 市 / 区', 'region')
        this.FormRow('详细地址', '街道、门牌号、楼层', 'detail')

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
            this.saveAddress();
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
  FormRow(label: string, placeholder: string, field: string) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.secondaryText())
        .width('100%')

      TextInput({
        placeholder: placeholder,
        text: field === 'name' ? this.contactName : (field === 'phone' ? this.contactPhone : (field === 'region' ? this.contactRegion : this.contactDetail))
      })
        .height(42)
        .fontSize(13)
        .fontColor(this.primaryText())
        .placeholderColor(this.secondaryText())
        .backgroundColor(this.softColor())
        .borderRadius(16)
        .margin({ top: 8 })
        .onChange((value: string) => {
          if (field === 'name') {
            this.contactName = value;
          } else if (field === 'phone') {
            this.contactPhone = value;
            if (this.phoneError.length > 0 && this.validPhone(value)) {
              this.phoneError = '';
            }
          } else if (field === 'region') {
            this.contactRegion = value;
          } else {
            this.contactDetail = value;
          }
        })
    }
    .width('100%')
    .margin({ top: 14 })
  }
}
