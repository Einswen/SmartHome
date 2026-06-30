import { safeBack, safeGetParams, safePushUrl } from '../../common/SafeRouter';

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
  { id: 'living_air', name: '客厅空调', room: '客厅', type: '温控', detail: '首页北侧温控点，支持温度调节。', image: $r('app.media.device_living_air'), point: '北侧温控点', x: 47, y: 14, accent: '#6CAEFF' },
  { id: 'living_curtain', name: '客厅窗帘', room: '客厅', type: '遮阳', detail: '首页窗边遮阳点，支持开合比例。', image: $r('app.media.device_living_curtain'), point: '窗边遮阳点', x: 31, y: 34, accent: '#D6A96D' },
  { id: 'living_tv', name: '客厅电视', room: '客厅', type: '影音', detail: '首页影音点，联动观影场景。', image: $r('app.media.device_living_tv'), point: '影音点', x: 73, y: 35, accent: '#7F9CFF' },
  { id: 'living_purifier', name: '空气净化器', room: '客厅', type: '空气', detail: '首页空气点，自动净化与滤芯提醒。', image: $r('app.media.device_living_purifier'), point: '空气点', x: 89, y: 59, accent: '#58D0BE' },
  { id: 'living_robot', name: '扫地机器人', room: '客厅', type: '清洁', detail: '首页清洁点，支持开始和暂停清扫。', image: $r('app.media.device_living_robot'), point: '清洁点', x: 18, y: 72, accent: '#8A96FF' },
  { id: 'living_light', name: '客厅灯', room: '客厅', type: '照明', detail: '首页灯光点，开关会同步切换首图灯光。', image: $r('app.media.device_living_light'), point: '灯光点', x: 31, y: 80, accent: '#F3A33A' }
];

@Entry
@Component
struct MyDevicesPage {
  @State showEmpty: boolean = false;
  @State pressedKey: string = '';
  @State selectedDeviceId: string = 'living_light';
  @State isNight: boolean = false;
  @StorageLink('homeLivingPointIds') livingPointIdsText: string = 'living_air|living_curtain|living_tv|living_purifier|living_robot|living_light';
  @StorageLink('homeLivingDeviceCount') livingDeviceCount: number = 6;
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
    const params = safeGetParams(this.getUIContext().getRouter()) as MyDevicesRouteParams | undefined;
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

  private livingPointIds(): string[] {
    if (this.livingPointIdsText.length <= 0) {
      return [];
    }
    return this.livingPointIdsText.split('|').filter((id: string) => id.length > 0);
  }

  private pointBaseId(pointId: string): string {
    const markerIndex = pointId.indexOf('@');
    if (markerIndex >= 0) {
      const nextMarkerIndex = pointId.indexOf('@', markerIndex + 1);
      if (nextMarkerIndex >= 0) {
        return pointId.substring(markerIndex + 1, nextMarkerIndex);
      }
      return pointId.substring(markerIndex + 1);
    }
    return pointId;
  }

  private specById(id: string): DeviceCenterSpec {
    const baseId = this.pointBaseId(id);
    for (let i = 0; i < DEVICE_CENTER_LIST.length; i++) {
      if (DEVICE_CENTER_LIST[i].id === baseId) {
        return DEVICE_CENTER_LIST[i];
      }
    }
    return DEVICE_CENTER_LIST[0];
  }

  private deviceSpecForPointId(pointId: string, index: number): DeviceCenterSpec {
    const base = this.specById(pointId);
    if (pointId === base.id) {
      return base;
    }
    return {
      id: pointId,
      name: `${base.name} ${index + 1}`,
      room: base.room,
      type: base.type,
      detail: `来自首页添加的扩展设备，继承${base.name}的控制能力。`,
      image: base.image,
      point: `扩展点位 ${index + 1}`,
      x: Math.min(base.x + index * 4, 92),
      y: Math.min(base.y + index * 3, 88),
      accent: base.accent
    };
  }

  private installedCount(): number {
    const ids = this.livingPointIds();
    return ids.length > 0 ? ids.length : this.livingDeviceCount;
  }

  private displayDevices(): DeviceCenterSpec[] {
    if (this.showEmpty) {
      return [];
    }
    const ids = this.livingPointIds();
    if (ids.length > 0) {
      const items: DeviceCenterSpec[] = [];
      for (let i = 0; i < ids.length; i++) {
        const item = this.deviceSpecForPointId(ids[i], i);
        if (this.isInstalled(this.pointBaseId(item.id))) {
          items.push(item);
        }
      }
      return items;
    }
    return DEVICE_CENTER_LIST.filter((item: DeviceCenterSpec) => this.isInstalled(item.id));
  }

  private statusText(id: string): string {
    const baseId = this.pointBaseId(id);
    if (baseId === 'living_air') {
      return `${this.livingTemperature}°C`;
    }
    if (baseId === 'living_curtain') {
      return `${this.livingCurtain}%`;
    }
    if (baseId === 'living_tv') {
      return this.livingTvOn ? '播放中' : '待机';
    }
    if (baseId === 'living_purifier') {
      return this.livingPurifierOn ? '运行中' : '已关闭';
    }
    if (baseId === 'living_robot') {
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
    const ids = this.livingPointIds().filter((pointId: string) => pointId !== id);
    const baseId = this.pointBaseId(id);
    const remainingBaseIds = ids.map((pointId: string) => this.pointBaseId(pointId));
    this.livingPointIdsText = ids.join('|');
    this.livingDeviceCount = ids.length;
    if (baseId === 'living_air' && remainingBaseIds.indexOf('living_air') < 0) {
      this.livingAirInstalled = false;
    } else if (baseId === 'living_curtain' && remainingBaseIds.indexOf('living_curtain') < 0) {
      this.livingCurtainInstalled = false;
    } else if (baseId === 'living_tv' && remainingBaseIds.indexOf('living_tv') < 0) {
      this.livingTvInstalled = false;
    } else if (baseId === 'living_purifier' && remainingBaseIds.indexOf('living_purifier') < 0) {
      this.livingPurifierInstalled = false;
    } else if (baseId === 'living_robot' && remainingBaseIds.indexOf('living_robot') < 0) {
      this.livingRobotInstalled = false;
    } else if (baseId === 'living_light' && remainingBaseIds.indexOf('living_light') < 0) {
      this.livingLightInstalled = false;
    }
  }

  private restoreDevices(): void {
    this.showEmpty = false;
    this.livingPointIdsText = 'living_air|living_curtain|living_tv|living_purifier|living_robot|living_light';
    this.livingDeviceCount = 6;
    this.livingAirInstalled = true;
    this.livingCurtainInstalled = true;
    this.livingTvInstalled = true;
    this.livingPurifierInstalled = true;
    this.livingRobotInstalled = true;
    this.livingLightInstalled = true;
  }

  private toggleDevice(id: string): void {
    const baseId = this.pointBaseId(id);
    if (baseId === 'living_light') {
      this.livingLightOn = !this.livingLightOn;
    } else if (baseId === 'living_tv') {
      this.livingTvOn = !this.livingTvOn;
    } else if (baseId === 'living_purifier') {
      this.livingPurifierOn = !this.livingPurifierOn;
    } else if (baseId === 'living_robot') {
      this.livingRobotOn = !this.livingRobotOn;
    }
  }

  private runPreviewControl(item: DeviceCenterSpec): void {
    this.selectedDeviceId = item.id;
    const baseId = this.pointBaseId(item.id);
    if (baseId === 'living_air') {
      this.livingTemperature = this.livingTemperature >= 30 ? 16 : this.livingTemperature + 1;
    } else if (baseId === 'living_curtain') {
      this.livingCurtain = this.livingCurtain >= 100 ? 0 : Math.min(this.livingCurtain + 10, 100);
    } else {
      this.toggleDevice(item.id);
    }
  }

  build() {
    Column() {
      this.TopBar()

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

      Text('设备中心')
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

        ForEach(this.displayDevices(), (item: DeviceCenterSpec) => {
          this.PointDot(item)
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
        Text(`${this.installedCount()} 台`)
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

      Text('这里和首页客厅首图使用同一组设备；首页添加第 7 台设备后，这里会同步显示扩展设备。')
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
    .linearGradient({ angle: 135, colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#23342D', 1.0]] : [['#E6EEFF', 0.0], ['#B8FFFFFF', 0.62], ['#E9F7F2', 1.0]] })
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
      if (this.pointBaseId(item.id) === 'living_air') {
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
      } else if (this.pointBaseId(item.id) === 'living_curtain') {
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
            safePushUrl(this.getUIContext().getRouter(), { url: 'pages/my/mydevicedetail', params: { deviceId: item.id, isNight: this.isNight } });
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
      Text('当前家庭还没有绑定设备。恢复示例后会重新显示与首页首图匹配的客厅设备。')
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

}
