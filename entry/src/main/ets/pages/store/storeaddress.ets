import { safeBack, safeGetParams } from '../../common/SafeRouter';
import {
  createStoreAddress,
  deleteStoreAddress,
  fetchStoreAddresses,
  setDefaultStoreAddress,
  SmartHomeApiResult,
  StoreAddress,
  StoreAddressRequest,
  updateStoreAddress
} from '../../common/SmartHomeApi';

interface StoreAddressRouteParams {
  isNight?: boolean;
}

@Entry
@Component
struct StoreAddressPage {
  @State isNight: boolean = false;
  @State editing: boolean = false;
  @State selectedAddressId: string = '';
  @State addresses: StoreAddress[] = [];
  @State addressLoading: boolean = false;
  @State addressSaving: boolean = false;
  @State addressMessage: string = '';
  @State editingAddressId: string = '';
  @State formName: string = '';
  @State formPhone: string = '';
  @State formRegion: string = '';
  @State formDetail: string = '';
  @State formTag: string = '家庭';
  @State formDefault: boolean = false;
  @StorageLink('lumiUserSignedIn') signedIn: boolean = false;
  @StorageLink('lumiAuthToken') authToken: string = '';

  aboutToAppear(): void {
    const params = safeGetParams(this.getUIContext().getRouter()) as StoreAddressRouteParams | undefined;
    if (params && params.isNight !== undefined) {
      this.isNight = params.isNight;
    }
    this.loadAddresses();
  }

  onPageShow(): void {
    this.loadAddresses();
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

  private hasAuthSession(): boolean {
    return this.signedIn && this.authToken.trim().length > 0;
  }

  private async loadAddresses(): Promise<void> {
    if (!this.hasAuthSession()) {
      this.addresses = [];
      this.selectedAddressId = '';
      this.addressMessage = '登录后可同步保存收货地址';
      return;
    }
    this.addressLoading = true;
    const result: SmartHomeApiResult<StoreAddress[]> = await fetchStoreAddresses(this.authToken);
    this.addressLoading = false;
    if (!result.ok || result.data === undefined) {
      this.addressMessage = result.error === undefined ? '地址读取失败，请稍后重试' : result.error;
      return;
    }
    this.addresses = result.data;
    this.addressMessage = result.data.length === 0 ? '还没有保存地址' : '';
    this.ensureSelectedAddress();
  }

  private ensureSelectedAddress(): void {
    if (this.addresses.length === 0) {
      this.selectedAddressId = '';
      return;
    }
    for (let i = 0; i < this.addresses.length; i++) {
      if (this.addresses[i].isDefault) {
        this.selectedAddressId = `${this.addresses[i].id}`;
        return;
      }
    }
    this.selectedAddressId = `${this.addresses[0].id}`;
  }

  private beginCreate(): void {
    this.editing = true;
    this.editingAddressId = '';
    this.formName = '';
    this.formPhone = '';
    this.formRegion = '';
    this.formDetail = '';
    this.formTag = '家庭';
    this.formDefault = this.addresses.length === 0;
    this.addressMessage = '';
  }

  private beginEdit(item: StoreAddress): void {
    this.editing = true;
    this.editingAddressId = `${item.id}`;
    this.formName = item.name;
    this.formPhone = item.phone;
    this.formRegion = item.region;
    this.formDetail = item.detail;
    this.formTag = item.tag;
    this.formDefault = item.isDefault;
    this.addressMessage = '';
  }

  private closeForm(): void {
    this.editing = false;
    this.editingAddressId = '';
    this.addressMessage = '';
  }

  private formTitle(): string {
    return this.editingAddressId.length > 0 ? '编辑地址' : '新增地址';
  }

  private canSaveAddress(): boolean {
    return this.hasAuthSession() &&
      !this.addressSaving &&
      this.formName.trim().length > 0 &&
      this.formPhone.trim().length > 0 &&
      this.formRegion.trim().length > 0 &&
      this.formDetail.trim().length > 0;
  }

  private buildAddressPayload(): StoreAddressRequest {
    return {
      name: this.formName.trim(),
      phone: this.formPhone.trim(),
      region: this.formRegion.trim(),
      detail: this.formDetail.trim(),
      tag: this.formTag.trim().length === 0 ? '家庭' : this.formTag.trim(),
      isDefault: this.formDefault
    };
  }

  private async saveAddress(): Promise<void> {
    if (!this.canSaveAddress()) {
      this.addressMessage = this.hasAuthSession() ? '请完整填写联系人、手机号、地区和详细地址' : '请先登录后再保存地址';
      return;
    }
    this.addressSaving = true;
    const payload = this.buildAddressPayload();
    const result = this.editingAddressId.length > 0
      ? await updateStoreAddress(this.authToken, Number(this.editingAddressId), payload)
      : await createStoreAddress(this.authToken, payload);
    this.addressSaving = false;
    if (!result.ok || result.data === undefined) {
      this.addressMessage = result.error === undefined ? '保存失败，请稍后重试' : result.error;
      return;
    }
    this.selectedAddressId = `${result.data.id}`;
    this.editing = false;
    this.editingAddressId = '';
    this.addressMessage = '地址已保存';
    await this.loadAddresses();
  }

  private async selectAddress(item: StoreAddress): Promise<void> {
    this.selectedAddressId = `${item.id}`;
    if (!this.hasAuthSession() || item.isDefault) {
      return;
    }
    const result = await setDefaultStoreAddress(this.authToken, item.id);
    this.applyAddressListResult(result, '默认地址已更新');
  }

  private async removeAddress(item: StoreAddress): Promise<void> {
    if (!this.hasAuthSession()) {
      this.addressMessage = '请先登录后再删除地址';
      return;
    }
    const result = await deleteStoreAddress(this.authToken, item.id);
    this.applyAddressListResult(result, '地址已删除');
    if (this.editingAddressId === `${item.id}`) {
      this.closeForm();
    }
  }

  private applyAddressListResult(result: SmartHomeApiResult<StoreAddress[]>, successMessage: string): void {
    if (!result.ok || result.data === undefined) {
      this.addressMessage = result.error === undefined ? '操作失败，请稍后重试' : result.error;
      return;
    }
    this.addresses = result.data;
    this.addressMessage = successMessage;
    this.ensureSelectedAddress();
  }

  private updateFormField(field: string, value: string): void {
    switch (field) {
      case 'name':
        this.formName = value;
        break;
      case 'phone':
        this.formPhone = value;
        break;
      case 'region':
        this.formRegion = value;
        break;
      case 'detail':
        this.formDetail = value;
        break;
      case 'tag':
        this.formTag = value;
        break;
      default:
        break;
    }
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
      Row() {
        Text('常用地址')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .layoutWeight(1)

        if (this.addressLoading) {
          Text('同步中')
            .fontSize(12)
            .fontColor(this.secondaryText())
        }
      }
      .width('100%')
      .margin({ bottom: 10 })

      if (this.addresses.length === 0) {
        Text(this.addressMessage.length > 0 ? this.addressMessage : '还没有保存地址')
          .fontSize(13)
          .lineHeight(20)
          .fontColor(this.secondaryText())
          .width('100%')
          .padding({ left: 16, right: 16, top: 18, bottom: 18 })
          .backgroundColor(this.cardColor())
          .border({ width: 1, color: this.lineColor() })
          .borderRadius(18)
      } else {
        ForEach(this.addresses, (item: StoreAddress) => {
          this.AddressCard(item)
        }, (item: StoreAddress) => `${item.id}`)
      }
    }
    .width('100%')
    .margin({ top: 22 })
  }

  @Builder
  AddressCard(item: StoreAddress) {
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

        Radio({ value: `${item.id}`, group: 'address' })
          .checked(this.selectedAddressId === `${item.id}`)
          .onChange((checked: boolean) => {
            if (checked) {
              this.selectAddress(item);
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

      Row() {
        Button('编辑')
          .height(32)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .backgroundColor(this.softColor())
          .borderRadius(16)
          .padding({ left: 14, right: 14 })
          .onClick(() => {
            this.beginEdit(item);
          })

        Button('删除')
          .height(32)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E14D4D')
          .backgroundColor(this.softColor())
          .borderRadius(16)
          .padding({ left: 14, right: 14 })
          .margin({ left: 10 })
          .onClick(() => {
            this.removeAddress(item);
          })
      }
      .width('100%')
      .margin({ top: 14 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(this.cardColor())
    .border({ width: 1, color: this.selectedAddressId === `${item.id}` ? '#F3A33A' : this.lineColor() })
    .borderRadius(22)
    .margin({ top: 10 })
    .onClick(() => {
      this.selectAddress(item);
    })
  }

  @Builder
  AddressForm() {
    Column() {
      Row() {
        Text(this.formTitle())
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
            if (this.editing) {
              this.closeForm();
            } else {
              this.beginCreate();
            }
          })
      }
      .width('100%')

      if (this.editing) {
        this.FormRow('联系人', '请输入收货人姓名', this.formName, 'name')
        this.FormRow('手机号', '请输入联系电话', this.formPhone, 'phone')
        this.FormRow('所在地区', '省 / 市 / 区', this.formRegion, 'region')
        this.FormRow('详细地址', '街道、门牌号、楼层', this.formDetail, 'detail')
        this.FormRow('标签', '家庭 / 工作 / 安装', this.formTag, 'tag')

        Row() {
          Checkbox()
            .select(this.formDefault)
            .onChange((checked: boolean) => {
              this.formDefault = checked;
            })

          Text('设为默认地址')
            .fontSize(13)
            .fontColor(this.secondaryText())
            .margin({ left: 8 })
        }
        .width('100%')
        .margin({ top: 14 })

        Button(this.addressSaving ? '保存中' : '保存地址')
          .width('100%')
          .height(44)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor(this.canSaveAddress() ? '#11151D' : '#7A818D')
          .borderRadius(22)
          .margin({ top: 14 })
          .onClick(() => {
            this.saveAddress();
          })
      }

      if (this.addressMessage.length > 0 && this.addresses.length > 0) {
        Text(this.addressMessage)
          .fontSize(12)
          .lineHeight(18)
          .fontColor(this.secondaryText())
          .width('100%')
          .margin({ top: 12 })
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
  FormRow(label: string, placeholder: string, value: string, field: string) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.secondaryText())
        .width('100%')

      TextInput({ placeholder: placeholder, text: value })
        .height(42)
        .fontSize(13)
        .fontColor(this.primaryText())
        .placeholderColor(this.secondaryText())
        .backgroundColor(this.softColor())
        .borderRadius(16)
        .margin({ top: 8 })
        .onChange((nextValue: string) => {
          this.updateFormField(field, nextValue);
        })
    }
    .width('100%')
    .margin({ top: 14 })
  }
}
