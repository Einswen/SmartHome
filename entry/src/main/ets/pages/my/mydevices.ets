import router from '@ohos.router';

interface MyDevicesRouteParams {
  isNight?: boolean;
}

interface DeviceCenterSpec {
  id: string;
  name: string;
  room: string;
  type: string;
  detail: string;
  image: Resource;
  point: string;
  x: number;
  y: number;
  accent: string;
}

const DEVICE_CENTER_LIST: DeviceCenterSpec[] = [
  { id: 'living_air', name: '客厅空调', room: '客厅', type: '温控', detail: '首页北侧温控点，支持温度调节', image: $r('app.media.device_living_air'), point: '北侧温控点', x: 47, y: 14, accent: '#6CAEFF' },
  { id: 'living_curtain', name: '客厅窗帘', room: '客厅', type: '遮阳', detail: '首页窗边遮阳点，支持开合比例', image: $r('app.media.device_living_curtain'), point: '窗边遮阳点', x: 31, y: 34, accent: '#D6A96D' },
  { id: 'living_tv', name: '客厅电视', room: '客厅', type: '影音', detail: '首页影音点，联动观影场景', image: $r('app.media.device_living_tv'), point: '影音点', x: 73, y: 35, accent: '#7F9CFF' },
  { id: 'living_purifier', name: '空气净化器', room: '客厅', type: '空气', detail: '首页空气点，自动净化与滤芯提醒', image: $r('app.media.device_living_purifier'), point: '空气点', x: 89, y: 59, accent: '#58D0BE' },
  { id: 'living_robot', name: '扫地机器人', room: '客厅', type: '清洁', detail: '首页清洁点，支持开始和暂停清扫', image: $r('app.media.device_living_robot'), point: '清洁点', x: 18, y: 72, accent: '#8A96FF' },
  { id: 'living_light', name: '客厅灯', room: '客厅', type: '照明', detail: '首页灯光点，开关会同步切换首图灯光', image: $r('app.media.device_living_light'), point: '灯光点', x: 31, y: 80, accent: '#F3A33A' }
];

@Entry
@Component
struct MyDevicesPage {
  @State networkFailed: boolean = false;
  @State showEmpty: boolean = false;
  @State pressedKey: string = '';
  @State selectedDeviceId: string = 'living_light';
  @StorageLink('homeNightMode') isNight: boolean = false;
  @StorageLink('homeLivingAirInstalled') livingAirInstalled: boolean = true;
  @StorageLink('homeLivingCurtainInstalled') livingCurtainInstalled: boolean = true;
  @StorageLink('homeLivingTvInstalled') livingTvInstalled: boolean = true;
  @StorageLink('homeLivingPurifierInstalled') livingPurifierInstalled: boolean = true;
  @StorageLink('homeLivingRobotInstalled') livingRobotInstalled: boolean = true;
  @StorageLink('homeLivingLightInstalled') livingLightInstalled: boolean = true;
  @StorageLink('homeLivingLightOn') livingLightOn: boolean = false;
  @StorageLink('homeLivingTemperature') livingTemperature: number = 24;
  @StorageLink('homeLivingCurtain') livingCurtain: number = 46;
  @StorageLink('homeLivingTvOn') livingTvOn: boolean = false;
  @StorageLink('homeLivingPurifierOn') livingPurifierOn: boolean = true;
  @StorageLink('homeLivingRobotOn') livingRobotOn: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams() as MyDevicesRouteParams;
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

  private lineColor(): string {
    return this.isNight ? '#20FFFFFF' : '#10000000';
  }

  private percent(value: number): string {
    return `${value}%`;
  }

  private dotLeft(item: DeviceCenterSpec): string {
    return this.percent(Math.min(Math.max(item.x - 3.1, 0), 92));
  }

  private dotTop(item: DeviceCenterSpec): string {
    return this.percent(Math.min(Math.max(item.y - 3.8, 0), 90));
  }

  private roomStageColor(): string {
    return this.isNight ? '#14181F' : '#EEF1F6';
  }

  private roomStageInnerColor(): string {
    return this.isNight ? '#1B2028' : '#FAFBFD';
  }

  private dotPlateColor(): string {
    return this.isNight ? '#26222222' : '#66FFFFFF';
  }

  private dotOuterColor(id: string): string {
    if (this.selectedDeviceId === id) {
      return this.isNight ? '#CCFFFFFF' : '#66000000';
    }
    return this.isNight ? '#80FFFFFF' : '#33000000';
  }

  private dotInnerColor(id: string): string {
    if (this.selectedDeviceId === id) {
      return this.isNight ? '#F2FFFFFF' : '#80000000';
    }
    return this.isNight ? '#B3FFFFFF' : '#4D000000';
  }

  private dotCoreColor(id: string): string {
    if (this.selectedDeviceId === id) {
      return this.isNight ? '#E6FFFFFF' : '#A6000000';
    }
    return this.isNight ? '#B3FFFFFF' : '#66000000';
  }

  private isInstalled(id: string): boolean {
    if (id === 'living_air') {
      return this.livingAirInstalled;
    }
    if (id === 'living_curtain') {
      return this.livingCurtainInstalled;
    }
    if (id === 'living_tv') {
      return this.livingTvInstalled;
    }
    if (id === 'living_purifier') {
      return this.livingPurifierInstalled;
    }
    if (id === 'living_robot') {
      return this.livingRobotInstalled;
    }
    return this.livingLightInstalled;
  }

  private installedCount(): number {
    let count = 0;
    for (let i = 0; i < DEVICE_CENTER_LIST.length; i++) {
      if (this.isInstalled(DEVICE_CENTER_LIST[i].id)) {
        count++;
      }
    }
    return count;
  }

  private displayDevices(): DeviceCenterSpec[] {
    if (this.showEmpty) {
      return [];
    }
    return DEVICE_CENTER_LIST.filter((item: DeviceCenterSpec) => this.isInstalled(item.id));
  }

  private statusText(id: string): string {
    if (id === 'living_air') {
      return `${this.livingTemperature}°C`;
    }
    if (id === 'living_curtain') {
      return `${this.livingCurtain}%`;
    }
    if (id === 'living_tv') {
      return this.livingTvOn ? '播放中' : '待机';
    }
    if (id === 'living_purifier') {
      return this.livingPurifierOn ? '运行中' : '已关闭';
    }
    if (id === 'living_robot') {
      return this.livingRobotOn ? '清扫中' : '待命';
    }
    return this.livingLightOn ? '已开灯' : '已关灯';
  }

  private roomImage(): Resource {
    if (this.isNight) {
      return this.livingLightOn ? $r('app.media.room_living_night_lighton') : $r('app.media.room_living_night_lightoff');
    }
    return this.livingLightOn ? $r('app.media.room_living_day_lighton') : $r('app.media.room_living_day_lightoff');
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

  private removeDevice(id: string): void {
    if (id === 'living_air') {
      this.livingAirInstalled = false;
    } else if (id === 'living_curtain') {
      this.livingCurtainInstalled = false;
    } else if (id === 'living_tv') {
      this.livingTvInstalled = false;
    } else if (id === 'living_purifier') {
      this.livingPurifierInstalled = false;
    } else if (id === 'living_robot') {
      this.livingRobotInstalled = false;
    } else {
      this.livingLightInstalled = false;
    }
  }

  private restoreDevices(): void {
    this.showEmpty = false;
    this.livingAirInstalled = true;
    this.livingCurtainInstalled = true;
    this.livingTvInstalled = true;
    this.livingPurifierInstalled = true;
    this.livingRobotInstalled = true;
    this.livingLightInstalled = true;
  }

  private toggleDevice(id: string): void {
    if (id === 'living_light') {
      this.livingLightOn = !this.livingLightOn;
    } else if (id === 'living_tv') {
      this.livingTvOn = !this.livingTvOn;
    } else if (id === 'living_purifier') {
      this.livingPurifierOn = !this.livingPurifierOn;
    } else if (id === 'living_robot') {
      this.livingRobotOn = !this.livingRobotOn;
    }
  }

  private runPreviewControl(item: DeviceCenterSpec): void {
    this.selectedDeviceId = item.id;
    if (item.id === 'living_air') {
      this.livingTemperature = this.livingTemperature >= 30 ? 16 : this.livingTemperature + 1;
    } else if (item.id === 'living_curtain') {
      this.livingCurtain = this.livingCurtain >= 100 ? 0 : Math.min(this.livingCurtain + 10, 100);
    } else {
      this.toggleDevice(item.id);
    }
  }

  build() {
    Column() {
      this.TopBar()

      if (this.networkFailed) {
        this.NetworkErrorState()
      } else {
        Scroll() {
          Column() {
            this.RoomPreview()
            this.SummaryCard()
            this.FilterBar()

            if (this.displayDevices().length === 0) {
              this.EmptyState()
            } else {
              ForEach(this.displayDevices(), (item: DeviceCenterSpec) => {
                this.DeviceCard(item)
              }, (item: DeviceCenterSpec) => item.id)
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
          router.back();
        })

      Text('设备中心')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .margin({ left: 14 })
        .layoutWeight(1)

      Button(this.networkFailed ? '在线' : '断网')
        .height(34)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.networkFailed ? '#FFFFFF' : this.primaryText())
        .backgroundColor(this.networkFailed ? '#5E8CFF' : this.cardColor())
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
  RoomPreview() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width('92%')
          .height('82%')
          .backgroundColor(this.roomStageInnerColor())
          .borderRadius(18)

        Image(this.roomImage())
          .width('100%')
          .aspectRatio(1402 / 1122)
          .objectFit(ImageFit.Contain)
          .borderRadius(16)

        ForEach(DEVICE_CENTER_LIST, (item: DeviceCenterSpec) => {
          if (this.isInstalled(item.id)) {
            this.PointDot(item)
          }
        }, (item: DeviceCenterSpec) => item.id)
      }
      .width('100%')
      .aspectRatio(1402 / 1122)
      .padding(6)
      .backgroundColor(this.roomStageColor())
      .border({ width: 1, color: this.lineColor() })
      .borderRadius(20)
      .clip(true)

      Row() {
        Text(`${this.installedCount()} / 6`)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(this.softColor())
          .borderRadius(14)
        Text(this.selectedDeviceId.length > 0 ? this.statusText(this.selectedDeviceId) : '点击图上控制点')
          .fontSize(12)
          .fontColor(this.secondaryText())
          .margin({ left: 10 })
          .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
  }

  @Builder
  PointDot(item: DeviceCenterSpec) {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width(this.selectedDeviceId === item.id ? 30 : 26)
        .height(this.selectedDeviceId === item.id ? 30 : 26)
        .borderRadius(this.selectedDeviceId === item.id ? 15 : 13)
        .backgroundColor(this.dotPlateColor())
        .border({ width: 1, color: this.dotOuterColor(item.id) })

      Column()
        .width(this.selectedDeviceId === item.id ? 14 : 11)
        .height(this.selectedDeviceId === item.id ? 14 : 11)
        .borderRadius(this.selectedDeviceId === item.id ? 7 : 5.5)
        .backgroundColor('#00000000')
        .border({ width: 1, color: this.dotInnerColor(item.id) })

      Column()
        .width(this.selectedDeviceId === item.id ? 4 : 3)
        .height(this.selectedDeviceId === item.id ? 4 : 3)
        .borderRadius(this.selectedDeviceId === item.id ? 2 : 1.5)
        .backgroundColor(this.dotCoreColor(item.id))
    }
    .width(44)
    .height(44)
    .position({ x: this.dotLeft(item), y: this.dotTop(item) })
    .scale(this.buttonScale(`scene_point_${item.id}`))
    .opacity(this.pressedKey === `scene_point_${item.id}` ? 0.72 : 1)
    .animation({ duration: 120, curve: Curve.EaseOut })
    .onTouch((event: TouchEvent) => {
      this.handlePressState(`scene_point_${item.id}`, event);
    })
    .onClick(() => {
      this.runPreviewControl(item);
    })
  }

  @Builder
  SummaryCard() {
    Column() {
      Text(`客厅 ${this.installedCount()} 台设备运行中`)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')

      Text('这里和首页客厅首图使用同一组设备：删除会让点位从首图消失，开灯会切换首图灯光状态。')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(this.secondaryText())
        .margin({ top: 8 })
        .width('100%')

      Row() {
        this.MetricChip('温度', `${this.livingTemperature}°C`)
        this.MetricChip('窗帘', `${this.livingCurtain}%`)
        this.MetricChip('灯光', this.livingLightOn ? '已开' : '已关')
      }
      .width('100%')
      .margin({ top: 18 })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .linearGradient({ angle: 135, colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#23342D', 1.0]] : [['#E6EEFF', 0.0], ['#FFFFFF', 0.62], ['#E9F7F2', 1.0]] })
    .borderRadius(26)
    .margin({ top: 14 })
  }

  @Builder
  MetricChip(label: string, value: string) {
    Column() {
      Text(value).fontSize(19).fontWeight(FontWeight.Bold).fontColor(this.primaryText())
      Text(label).fontSize(11).fontColor(this.secondaryText()).margin({ top: 4 })
    }
    .layoutWeight(1)
    .height(68)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.isNight ? '#331E2530' : '#CCFFFFFF')
    .borderRadius(18)
    .margin({ right: 8 })
  }

  @Builder
  FilterBar() {
    Row() {
      Text('客厅设备')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .layoutWeight(1)

      Button(this.showEmpty || this.installedCount() < 6 ? '恢复设备' : '空数据')
        .height(32)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5E8CFF')
        .backgroundColor(this.isNight ? '#335E8CFF' : '#EAF0FF')
        .borderRadius(16)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          if (this.showEmpty || this.installedCount() < 6) {
            this.restoreDevices();
          } else {
            this.showEmpty = true;
          }
        })
    }
    .width('100%')
    .margin({ top: 22, bottom: 10 })
  }

  @Builder
  DeviceCard(item: DeviceCenterSpec) {
    Column() {
      Row() {
        Image(item.image)
          .width(68)
          .height(68)
          .objectFit(ImageFit.Contain)
          .backgroundColor(this.softColor())
          .borderRadius(20)

        Column() {
          Row() {
            Text(item.name)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.primaryText())
              .maxLines(1)
              .layoutWeight(1)
            Text(this.statusText(item.id))
              .fontSize(11)
              .fontWeight(FontWeight.Bold)
              .fontColor(item.accent)
          }
          .width('100%')

          Text(`${item.room} · ${item.type} · ${item.point}`)
            .fontSize(12)
            .fontColor(this.secondaryText())
            .margin({ top: 5 })
            .maxLines(1)

          Text(item.detail)
            .fontSize(12)
            .lineHeight(18)
            .fontColor(this.secondaryText())
            .margin({ top: 6 })
            .maxLines(2)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 14 })
      }
      .width('100%')

      this.DeviceControls(item)
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor(this.cardColor())
    .border({ width: 1, color: this.lineColor() })
    .borderRadius(22)
    .margin({ top: 10 })
    .scale(this.buttonScale(item.id))
    .animation({ duration: 120, curve: Curve.EaseOut })
    .onTouch((event: TouchEvent) => {
      this.handlePressState(item.id, event);
    })
  }

  @Builder
  DeviceControls(item: DeviceCenterSpec) {
    Column() {
      if (item.id === 'living_air') {
        Row() {
          this.SmallButton('-', item.accent, () => {
            this.livingTemperature = Math.max(this.livingTemperature - 1, 16);
          })
          Text(`${this.livingTemperature}°C`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          this.SmallButton('+', item.accent, () => {
            this.livingTemperature = Math.min(this.livingTemperature + 1, 30);
          })
        }
        .width('100%')
        .margin({ top: 14 })
      } else if (item.id === 'living_curtain') {
        Row() {
          Text('开合')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())
          Slider({ value: this.livingCurtain, min: 0, max: 100, step: 1 })
            .layoutWeight(1)
            .selectedColor(item.accent)
            .trackColor(this.isNight ? '#335E6470' : '#E5EAF2')
            .margin({ left: 12, right: 12 })
            .onChange((value: number) => {
              this.livingCurtain = Math.round(value);
            })
          Text(`${this.livingCurtain}%`)
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor(item.accent)
            .width(42)
        }
        .width('100%')
        .margin({ top: 14 })
      } else {
        Row() {
          Button(this.statusText(item.id))
            .height(36)
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .backgroundColor(item.accent)
            .borderRadius(18)
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              this.toggleDevice(item.id);
            })
        }
        .width('100%')
        .margin({ top: 14 })
      }

      Row() {
        Button('详情')
          .height(34)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .backgroundColor(this.softColor())
          .borderRadius(17)
          .padding({ left: 14, right: 14 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/my/mydevicedetail', params: { deviceId: item.id, isNight: this.isNight } });
          })
        Button('删除')
          .height(34)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#D35B4B')
          .backgroundColor(this.isNight ? '#33D35B4B' : '#FFF1EF')
          .borderRadius(17)
          .padding({ left: 14, right: 14 })
          .margin({ left: 8 })
          .onClick(() => {
            this.removeDevice(item.id);
          })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
  }

  @Builder
  SmallButton(label: string, color: string, action: () => void) {
    Button(label)
      .width(36)
      .height(36)
      .fontSize(18)
      .fontWeight(FontWeight.Bold)
      .fontColor('#FFFFFF')
      .backgroundColor(color)
      .borderRadius(18)
      .onClick(action)
  }

  @Builder
  EmptyState() {
    Column() {
      Text('暂无设备')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('当前家庭还没有绑定设备。恢复示例后会重新显示与首页首图匹配的 6 台客厅设备。')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(this.secondaryText())
        .textAlign(TextAlign.Center)
        .margin({ top: 8 })
      Button('恢复示例数据')
        .height(40)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#5E8CFF')
        .borderRadius(20)
        .padding({ left: 18, right: 18 })
        .margin({ top: 18 })
        .onClick(() => {
          this.restoreDevices();
        })
    }
    .width('100%')
    .padding({ left: 28, right: 28, top: 54, bottom: 54 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 10 })
  }

  @Builder
  NetworkErrorState() {
    Column() {
      Blank().height(78)
      Text('网络连接异常')
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('无法同步设备状态，请检查网络后重试。本地缓存仍可查看上次设备列表。')
        .fontSize(13)
        .lineHeight(21)
        .fontColor(this.secondaryText())
        .textAlign(TextAlign.Center)
        .margin({ left: 36, right: 36, top: 10 })
      Button('重新连接')
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
}

