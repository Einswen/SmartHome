interface RoomImageSet {
  dayLightOff: Resource;
  dayLightOn: Resource;
  nightLightOff: Resource;
  nightLightOn: Resource;
}

interface RoomSpec {
  id: string;
  name: string;
  subtitle: string;
  images?: RoomImageSet;
  preset: boolean;
}

interface PointSpec {
  id: string;
  roomId: string;
  name: string;
  type: string;
  x: number;
  y: number;
  detail: string;
  action: string;
}

interface NavSpec {
  id: string;
  label: string;
}

const ROOM_ASPECT: number = 1402 / 1122;
const NIGHT_START_HOUR: number = 18;
const NIGHT_END_HOUR: number = 6;

const NAV_ITEMS: NavSpec[] = [
  { id: 'home', label: '家' },
  { id: 'smart', label: '智能' },
  { id: 'store', label: '商场' },
  { id: 'profile', label: '我的' }
];

const ROOMS: RoomSpec[] = [
  {
    id: 'living',
    name: '客厅',
    subtitle: '会客、影音、空气联动',
    preset: true,
    images: {
      dayLightOff: $r('app.media.room_living_day_lightoff'),
      dayLightOn: $r('app.media.room_living_day_lighton'),
      nightLightOff: $r('app.media.room_living_night_lightoff'),
      nightLightOn: $r('app.media.room_living_night_lighton')
    }
  },
  {
    id: 'bedroom',
    name: '卧室',
    subtitle: '睡眠、温控、安防联动',
    preset: true,
    images: {
      dayLightOff: $r('app.media.room_bed_day_lightoff'),
      dayLightOn: $r('app.media.room_bed_day_lighton'),
      nightLightOff: $r('app.media.room_bed_night_lightoff'),
      nightLightOn: $r('app.media.room_bed_night_lighton')
    }
  },
  {
    id: 'balcony',
    name: '阳台',
    subtitle: '晾晒、通风、绿植',
    preset: true
  },
  {
    id: 'kitchen',
    name: '厨房',
    subtitle: '烹饪、照明、排风',
    preset: true
  },
  {
    id: 'bathroom',
    name: '洗手间',
    subtitle: '镜灯、热水、换气',
    preset: true
  }
];

// 点位用图片百分比坐标，后续人工微调只需要改 x/y。
const POINTS: PointSpec[] = [
  { id: 'living_air', roomId: 'living', name: '空调', type: '温控', x: 47, y: 14, detail: '24°C · 自动风 · 客厅北侧', action: 'temperature' },
  { id: 'living_curtain', roomId: 'living', name: '窗帘', type: '遮阳', x: 31, y: 34, detail: '半开 · 日照较强', action: 'curtain' },
  { id: 'living_tv', roomId: 'living', name: '电视', type: '影音', x: 73, y: 35, detail: '待机 · HDMI 1', action: 'toggle' },
  { id: 'living_purifier', roomId: 'living', name: '空气净化器', type: '空气', x: 89, y: 59, detail: '自动 · PM2.5 良好', action: 'toggle' },
  { id: 'living_robot', roomId: 'living', name: '扫地机器人', type: '清洁', x: 18, y: 72, detail: '待命 · 电量 86%', action: 'toggle' },
  { id: 'living_sofa', roomId: 'living', name: '沙发', type: '家具', x: 42, y: 62, detail: '空间主锚点', action: 'info' },
  { id: 'living_table', roomId: 'living', name: '茶几', type: '家具', x: 58, y: 56, detail: '客厅中心区域', action: 'info' },
  { id: 'living_light', roomId: 'living', name: '客厅灯', type: '照明', x: 31, y: 80, detail: '主灯与氛围灯联动', action: 'light' },
  { id: 'bedroom_air', roomId: 'bedroom', name: '卧室空调', type: '温控', x: 13, y: 39, detail: '23°C · 睡眠风', action: 'temperature' },
  { id: 'bedroom_curtain', roomId: 'bedroom', name: '窗帘', type: '遮阳', x: 20, y: 45, detail: '卧室西侧窗', action: 'curtain' },
  { id: 'bedroom_bed', roomId: 'bedroom', name: '双人床', type: '家具', x: 54, y: 49, detail: '睡眠中心区域', action: 'info' },
  { id: 'bedroom_left_light', roomId: 'bedroom', name: '左床头灯', type: '照明', x: 43, y: 36, detail: '夜灯 · 低亮度', action: 'light' },
  { id: 'bedroom_right_light', roomId: 'bedroom', name: '右床头灯', type: '照明', x: 65, y: 48, detail: '阅读灯 · 可调光', action: 'light' },
  { id: 'bedroom_wardrobe', roomId: 'bedroom', name: '衣柜', type: '家具', x: 79, y: 45, detail: '右侧整墙衣柜', action: 'info' },
  { id: 'bedroom_robot', roomId: 'bedroom', name: '扫地机器人', type: '清洁', x: 77, y: 73, detail: '待命 · 电量 91%', action: 'toggle' },
  { id: 'bedroom_door', roomId: 'bedroom', name: '房门', type: '安防', x: 91, y: 58, detail: '已关闭', action: 'toggle' }
];

const DEFAULT_POINT: PointSpec = POINTS[0];

@Entry
@Component
struct Index {
  @State activeTab: string = 'home';
  @State rooms: RoomSpec[] = ROOMS;
  @State activeRoomId: string = 'living';
  @State selectedPointId: string = '';
  @State detailPointId: string = '';
  @State selectionVersion: number = 0;
  @State pressedKey: string = '';
  @State addRoomPanelVisible: boolean = false;
  @State customRoomName: string = '';
  @State isNight: boolean = false;
  @State manualPeriod: boolean = false;
  @State livingLightOn: boolean = false;
  @State bedroomLightOn: boolean = false;
  @State livingTemperature: number = 24;
  @State bedroomTemperature: number = 23;
  @State livingCurtain: number = 46;
  @State bedroomCurtain: number = 58;
  @State livingLightLevel: number = 68;
  @State bedroomLightLevel: number = 22;
  @State livingTvOn: boolean = false;
  @State livingPurifierOn: boolean = true;
  @State livingRobotOn: boolean = false;
  @State bedroomRobotOn: boolean = false;
  @State bedroomDoorLocked: boolean = true;
  private clockTimer: number = -1;

  aboutToAppear(): void {
    this.applyAutoPeriod();
    this.clockTimer = setInterval(() => {
      if (!this.manualPeriod) {
        this.applyAutoPeriod();
      }
    }, 60000);
  }

  aboutToDisappear(): void {
    if (this.clockTimer >= 0) {
      clearInterval(this.clockTimer);
      this.clockTimer = -1;
    }
  }

  private applyAutoPeriod(): void {
    const hour = new Date().getHours();
    this.isNight = hour >= NIGHT_START_HOUR || hour < NIGHT_END_HOUR;
  }

  private activeRoom(): RoomSpec {
    for (let i = 0; i < this.rooms.length; i++) {
      if (this.rooms[i].id === this.activeRoomId) {
        return this.rooms[i];
      }
    }
    return this.rooms[0];
  }

  private hasRoomImage(roomId: string): boolean {
    const room = this.roomById(roomId);
    return room.images !== undefined;
  }

  private roomById(roomId: string): RoomSpec {
    for (let i = 0; i < this.rooms.length; i++) {
      if (this.rooms[i].id === roomId) {
        return this.rooms[i];
      }
    }
    return this.rooms[0];
  }

  private pointsForActiveRoom(): PointSpec[] {
    return POINTS.filter((point: PointSpec) => point.roomId === this.activeRoomId);
  }

  private pointById(pointId: string): PointSpec {
    for (let i = 0; i < POINTS.length; i++) {
      if (POINTS[i].id === pointId) {
        return POINTS[i];
      }
    }
    return DEFAULT_POINT;
  }

  private activeLightOn(): boolean {
    return this.activeRoomId === 'living' ? this.livingLightOn : this.bedroomLightOn;
  }

  private setActiveLight(value: boolean): void {
    if (this.activeRoomId === 'living') {
      this.livingLightOn = value;
    } else {
      this.bedroomLightOn = value;
    }
  }

  private roomImage(): Resource {
    const room = this.activeRoom();
    if (room.images === undefined) {
      return $r('app.media.room_living_day_lightoff');
    }
    const lightOn = this.activeLightOn();
    if (this.isNight) {
      return lightOn ? room.images!.nightLightOn : room.images!.nightLightOff;
    }
    return lightOn ? room.images!.dayLightOn : room.images!.dayLightOff;
  }

  private bgColor(): string {
    return this.isNight ? '#000000' : '#FFFFFF';
  }

  private panelColor(): string {
    return this.isNight ? '#101010' : '#FFFFFF';
  }

  private cardColor(): string {
    return this.isNight ? '#171717' : '#F7F7F7';
  }

  private primaryText(): string {
    return this.isNight ? '#FFFFFF' : '#000000';
  }

  private secondaryText(): string {
    return this.isNight ? '#BDBDBD' : '#555555';
  }

  private lineColor(): string {
    return this.isNight ? '#2A2A2A' : '#E6E6E6';
  }

  private inverseBg(): string {
    return this.isNight ? '#FFFFFF' : '#000000';
  }

  private translucentPanelColor(): string {
    return this.isNight ? '#D9101010' : '#E6FFFFFF';
  }

  private translucentCardColor(): string {
    return this.isNight ? '#B3171717' : '#CCFFFFFF';
  }

  private translucentInverseBg(): string {
    return this.isNight ? '#D9FFFFFF' : '#D9000000';
  }

  private dotPlateColor(): string {
    return this.isNight ? '#26222222' : '#66FFFFFF';
  }

  private dotOuterColor(pointId: string): string {
    if (this.selectedPointId === pointId) {
      return this.isNight ? '#CCFFFFFF' : '#66000000';
    }
    return this.isNight ? '#80FFFFFF' : '#33000000';
  }

  private dotInnerColor(pointId: string): string {
    if (this.selectedPointId === pointId) {
      return this.isNight ? '#F2FFFFFF' : '#80000000';
    }
    return this.isNight ? '#B3FFFFFF' : '#4D000000';
  }

  private dotCoreColor(pointId: string): string {
    if (this.selectedPointId === pointId) {
      return this.isNight ? '#E6FFFFFF' : '#A6000000';
    }
    return this.isNight ? '#B3FFFFFF' : '#66000000';
  }

  private inverseText(): string {
    return this.isNight ? '#000000' : '#FFFFFF';
  }

  private navTextColor(tabId: string): string {
    return this.activeTab === tabId ? this.primaryText() : this.secondaryText();
  }

  private navItemBg(tabId: string): string {
    return this.activeTab === tabId ? this.translucentCardColor() : '#00000000';
  }

  private navIconColor(tabId: string): string {
    return this.activeTab === tabId ? this.primaryText() : this.secondaryText();
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

  private iconScale(key: string): ScaleOptions {
    return this.pressedKey === key ? { x: 0.92, y: 0.92 } : { x: 1, y: 1 };
  }

  private buttonOpacity(key: string): number {
    return this.pressedKey === key ? 0.82 : 1;
  }

  private overlayTransition(): TransitionEffect {
    return TransitionEffect.opacity(0)
      .combine(TransitionEffect.translate({ y: 36 }))
      .combine(TransitionEffect.scale({ x: 0.98, y: 0.98, centerX: '50%', centerY: '100%' }))
      .animation({ duration: 220, curve: Curve.EaseOut });
  }

  private percent(value: number): string {
    return `${value}%`;
  }

  private pointStatus(point: PointSpec): string {
    if (point.action === 'light') {
      return this.activeLightOn() ? `已开 · ${this.activeRoomId === 'living' ? this.livingLightLevel : this.bedroomLightLevel}%` : '已关闭';
    }
    if (point.id === 'living_air') {
      return `${this.livingTemperature}°C`;
    }
    if (point.id === 'bedroom_air') {
      return `${this.bedroomTemperature}°C`;
    }
    if (point.id === 'living_curtain') {
      return `${this.livingCurtain}%`;
    }
    if (point.id === 'bedroom_curtain') {
      return `${this.bedroomCurtain}%`;
    }
    if (point.id === 'living_tv') {
      return this.livingTvOn ? '播放中' : '待机';
    }
    if (point.id === 'living_purifier') {
      return this.livingPurifierOn ? '运行中' : '已关闭';
    }
    if (point.id === 'living_robot') {
      return this.livingRobotOn ? '清扫中' : '待命';
    }
    if (point.id === 'bedroom_robot') {
      return this.bedroomRobotOn ? '清扫中' : '待命';
    }
    if (point.id === 'bedroom_door') {
      return this.bedroomDoorLocked ? '已上锁' : '未上锁';
    }
    return point.detail;
  }

  private selectRoom(roomId: string): void {
    this.activeRoomId = roomId;
    this.selectedPointId = '';
    this.detailPointId = '';
    this.addRoomPanelVisible = false;
    this.selectionVersion++;
  }

  private selectPoint(pointId: string): void {
    if (this.selectedPointId === pointId && this.detailPointId.length === 0) {
      this.selectedPointId = '';
    } else {
      this.selectedPointId = pointId;
    }
    this.detailPointId = '';
    this.addRoomPanelVisible = false;
    this.selectionVersion++;
  }

  private openAddRoomPanel(): void {
    this.selectedPointId = '';
    this.detailPointId = '';
    this.addRoomPanelVisible = true;
    this.selectionVersion++;
  }

  private closeOverlayPanel(): void {
    this.selectedPointId = '';
    this.detailPointId = '';
    this.addRoomPanelVisible = false;
    this.selectionVersion++;
  }

  private roomExists(roomId: string): boolean {
    for (let i = 0; i < this.rooms.length; i++) {
      if (this.rooms[i].id === roomId) {
        return true;
      }
    }
    return false;
  }

  private addPresetRoom(roomId: string): void {
    if (this.roomExists(roomId)) {
      this.activeRoomId = roomId;
      this.addRoomPanelVisible = false;
      return;
    }
    for (let i = 0; i < ROOMS.length; i++) {
      if (ROOMS[i].id === roomId) {
        this.rooms = [...this.rooms, ROOMS[i]];
        this.activeRoomId = roomId;
        this.addRoomPanelVisible = false;
        this.selectedPointId = '';
        this.detailPointId = '';
        this.selectionVersion++;
        return;
      }
    }
  }

  private addCustomRoom(): void {
    const roomName = this.customRoomName.trim();
    if (roomName.length === 0) {
      return;
    }
    const customId = `custom_${new Date().getTime()}`;
    this.rooms = [
      ...this.rooms,
      {
        id: customId,
        name: roomName,
        subtitle: '自定义空间',
        preset: false
      }
    ];
    this.activeRoomId = customId;
    this.customRoomName = '';
    this.addRoomPanelVisible = false;
    this.selectedPointId = '';
    this.detailPointId = '';
    this.selectionVersion++;
  }

  private togglePeriodForDebug(): void {
    this.manualPeriod = true;
    this.isNight = !this.isNight;
  }

  private togglePoint(pointId: string): void {
    const point = this.pointById(pointId);
    if (point.action === 'light') {
      this.setActiveLight(!this.activeLightOn());
      return;
    }
    if (point.id === 'living_tv') {
      this.livingTvOn = !this.livingTvOn;
      return;
    }
    if (point.id === 'living_purifier') {
      this.livingPurifierOn = !this.livingPurifierOn;
      return;
    }
    if (point.id === 'living_robot') {
      this.livingRobotOn = !this.livingRobotOn;
      return;
    }
    if (point.id === 'bedroom_robot') {
      this.bedroomRobotOn = !this.bedroomRobotOn;
      return;
    }
    if (point.id === 'bedroom_door') {
      this.bedroomDoorLocked = !this.bedroomDoorLocked;
    }
  }

  private adjustPoint(pointId: string, delta: number): void {
    const point = this.pointById(pointId);
    if (point.id === 'living_air') {
      this.livingTemperature = Math.min(Math.max(this.livingTemperature + delta, 16), 30);
      return;
    }
    if (point.id === 'bedroom_air') {
      this.bedroomTemperature = Math.min(Math.max(this.bedroomTemperature + delta, 16), 30);
      return;
    }
    if (point.id === 'living_curtain') {
      this.livingCurtain = Math.min(Math.max(this.livingCurtain + delta * 5, 0), 100);
      return;
    }
    if (point.id === 'bedroom_curtain') {
      this.bedroomCurtain = Math.min(Math.max(this.bedroomCurtain + delta * 5, 0), 100);
      return;
    }
    if (point.action === 'light') {
      if (!this.activeLightOn()) {
        this.setActiveLight(true);
      }
      if (this.activeRoomId === 'living') {
        this.livingLightLevel = Math.min(Math.max(this.livingLightLevel + delta * 10, 1), 100);
      } else {
        this.bedroomLightLevel = Math.min(Math.max(this.bedroomLightLevel + delta * 10, 1), 100);
      }
    }
  }

  private quickPrimaryLabel(point: PointSpec): string {
    if (point.action === 'light') {
      return this.activeLightOn() ? '关灯' : '开灯';
    }
    if (point.action === 'toggle') {
      return '切换';
    }
    if (point.action === 'info') {
      return '标记';
    }
    return '-';
  }

  private quickSecondaryLabel(point: PointSpec): string {
    if (point.action === 'temperature') {
      return '升温';
    }
    if (point.action === 'curtain') {
      return '打开';
    }
    if (point.action === 'light') {
      return '调亮';
    }
    return '详情';
  }

  private detailValue(point: PointSpec): number {
    if (point.id === 'living_air') {
      return this.livingTemperature;
    }
    if (point.id === 'bedroom_air') {
      return this.bedroomTemperature;
    }
    if (point.id === 'living_curtain') {
      return this.livingCurtain;
    }
    if (point.id === 'bedroom_curtain') {
      return this.bedroomCurtain;
    }
    if (point.action === 'light') {
      return this.activeRoomId === 'living' ? this.livingLightLevel : this.bedroomLightLevel;
    }
    return 0;
  }

  private detailUnit(point: PointSpec): string {
    if (point.action === 'temperature') {
      return '°C';
    }
    if (point.action === 'curtain' || point.action === 'light') {
      return '%';
    }
    return '';
  }

  private setDetailValue(point: PointSpec, value: number): void {
    if (point.id === 'living_air') {
      this.livingTemperature = Math.round(value);
      return;
    }
    if (point.id === 'bedroom_air') {
      this.bedroomTemperature = Math.round(value);
      return;
    }
    if (point.id === 'living_curtain') {
      this.livingCurtain = Math.round(value);
      return;
    }
    if (point.id === 'bedroom_curtain') {
      this.bedroomCurtain = Math.round(value);
      return;
    }
    if (point.action === 'light') {
      if (!this.activeLightOn()) {
        this.setActiveLight(true);
      }
      if (this.activeRoomId === 'living') {
        this.livingLightLevel = Math.round(value);
      } else {
        this.bedroomLightLevel = Math.round(value);
      }
    }
  }

  private detailMin(point: PointSpec): number {
    return point.action === 'temperature' ? 16 : 0;
  }

  private detailMax(point: PointSpec): number {
    return point.action === 'temperature' ? 30 : 100;
  }

  private dotLeft(point: PointSpec): string {
    return this.percent(Math.min(Math.max(point.x - 3.1, 0), 92));
  }

  private dotTop(point: PointSpec): string {
    return this.percent(Math.min(Math.max(point.y - 3.8, 0), 90));
  }

  private selectedBubblePoints(): PointSpec[] {
    if (this.selectedPointId.length === 0 || this.detailPointId.length > 0) {
      return [];
    }
    return [this.pointById(this.selectedPointId)];
  }

  private selectedBubbleKey(point: PointSpec): string {
    return `${point.id}_${this.selectionVersion}`;
  }

  private panelViewportHeight(): number {
    return 268;
  }

  private overlayVisible(): boolean {
    return this.addRoomPanelVisible || this.selectedPointId.length > 0 || this.detailPointId.length > 0;
  }

  private availablePresetRooms(): RoomSpec[] {
    return ROOMS.filter((room: RoomSpec) => !this.roomExists(room.id));
  }

  private controllablePoints(): PointSpec[] {
    return this.pointsForActiveRoom().filter((point: PointSpec) => point.action !== 'info');
  }

  private listPrimaryLabel(point: PointSpec): string {
    if (point.action === 'light') {
      return this.activeLightOn() ? '关闭' : '打开';
    }
    if (point.action === 'temperature' || point.action === 'curtain') {
      return '-';
    }
    return '切换';
  }

  private listSecondaryLabel(point: PointSpec): string {
    if (point.action === 'temperature' || point.action === 'curtain' || point.action === 'light') {
      return '设置';
    }
    return '详情';
  }

  @Builder
  TopBar() {
    Row() {
      Text(this.activeRoom().name)
        .fontSize(30)
        .fontColor(this.primaryText())
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)

      Button(this.isNight ? '夜间' : '日间')
        .height(40)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.inverseText())
        .backgroundColor(this.translucentInverseBg())
        .borderRadius(20)
        .scale(this.buttonScale('toggle_period'))
        .opacity(this.buttonOpacity('toggle_period'))
        .animation({ duration: 120, curve: Curve.EaseOut })
        .onTouch((event: TouchEvent) => {
          this.handlePressState('toggle_period', event);
        })
        .onClick(() => {
          this.togglePeriodForDebug();
        })
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  RoomTabs() {
    Scroll() {
      Row() {
        ForEach(this.rooms, (room: RoomSpec) => {
          Button(room.name)
            .height(44)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.activeRoomId === room.id ? this.inverseText() : this.primaryText())
            .backgroundColor(this.activeRoomId === room.id ? this.translucentInverseBg() : this.translucentCardColor())
            .borderRadius(22)
          .border({
            width: 1,
            color: this.lineColor()
          })
          .margin({ right: 10 })
          .padding({ left: 18, right: 18 })
          .scale(this.buttonScale(`room_${room.id}`))
          .opacity(this.buttonOpacity(`room_${room.id}`))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState(`room_${room.id}`, event);
          })
          .onClick(() => {
            this.selectRoom(room.id);
          })
        }, (room: RoomSpec) => room.id)

        Button('+ 房间')
          .height(44)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.primaryText())
          .backgroundColor(this.translucentCardColor())
          .borderRadius(22)
          .border({
            width: 1,
            color: this.lineColor()
          })
          .padding({ left: 18, right: 18 })
          .scale(this.buttonScale('add_room_entry'))
          .opacity(this.buttonOpacity('add_room_entry'))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState('add_room_entry', event);
          })
          .onClick(() => {
            this.openAddRoomPanel();
          })
      }
      .alignItems(VerticalAlign.Center)
      .padding({ right: 8 })
    }
    .width('100%')
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Horizontal)
    .margin({ top: 22 })
  }

  @Builder
  PointDot(point: PointSpec) {
    Stack() {
      Column()
        .width(44)
        .height(44)
        .borderRadius(22)
        .backgroundColor('#00000000')

      Column()
        .width(this.selectedPointId === point.id ? 30 : 26)
        .height(this.selectedPointId === point.id ? 30 : 26)
        .borderRadius(this.selectedPointId === point.id ? 15 : 13)
        .backgroundColor(this.dotPlateColor())
        .border({
          width: 1,
          color: this.dotOuterColor(point.id)
        })

      Column()
        .width(this.selectedPointId === point.id ? 14 : 11)
        .height(this.selectedPointId === point.id ? 14 : 11)
        .borderRadius(this.selectedPointId === point.id ? 7 : 5.5)
        .backgroundColor('#00000000')
        .border({
          width: 1,
          color: this.dotInnerColor(point.id)
        })

      Column()
        .width(this.selectedPointId === point.id ? 4 : 3)
        .height(this.selectedPointId === point.id ? 4 : 3)
        .borderRadius(this.selectedPointId === point.id ? 2 : 1.5)
        .backgroundColor(this.dotCoreColor(point.id))
    }
    .width(44)
    .height(44)
    .position({
      x: this.dotLeft(point),
      y: this.dotTop(point)
    })
    .scale(this.iconScale(`point_${point.id}`))
    .opacity(this.buttonOpacity(`point_${point.id}`))
    .animation({ duration: 120, curve: Curve.EaseOut })
    .onTouch((event: TouchEvent) => {
      this.handlePressState(`point_${point.id}`, event);
    })
    .onClick(() => {
      this.selectPoint(point.id);
    })
  }

  @Builder
  Bubble(point: PointSpec) {
    Column() {
      Row() {
        Column() {
          Text(point.name)
            .fontSize(15)
            .fontColor(this.primaryText())
            .fontWeight(FontWeight.Bold)
          Text(`${point.type} · ${this.pointStatus(point)}`)
            .fontSize(11)
            .fontColor(this.secondaryText())
            .margin({ top: 3 })
            .maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('+')
          .fontSize(20)
          .fontColor(this.primaryText())
          .fontWeight(FontWeight.Bold)
          .width(32)
          .height(32)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.translucentCardColor())
          .borderRadius(16)
          .scale(this.iconScale(`bubble_expand_${point.id}`))
          .opacity(this.buttonOpacity(`bubble_expand_${point.id}`))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState(`bubble_expand_${point.id}`, event);
          })
          .onClick(() => {
            this.detailPointId = point.id;
          })

        Text('×')
          .fontSize(16)
          .fontColor(this.secondaryText())
          .fontWeight(FontWeight.Medium)
          .width(32)
          .height(32)
          .textAlign(TextAlign.Center)
          .margin({ left: 6 })
          .scale(this.iconScale(`bubble_close_${point.id}`))
          .opacity(this.buttonOpacity(`bubble_close_${point.id}`))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState(`bubble_close_${point.id}`, event);
          })
          .onClick(() => {
            this.selectedPointId = '';
            this.detailPointId = '';
          })
      }
      .width('100%')

      Text(point.detail)
        .fontSize(12)
        .fontColor(this.secondaryText())
        .margin({ top: 8 })
        .maxLines(2)

      Row() {
        Button(this.quickPrimaryLabel(point))
          .height(34)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.inverseText())
          .backgroundColor(this.translucentInverseBg())
          .borderRadius(17)
          .layoutWeight(1)
          .scale(this.buttonScale(`bubble_primary_${point.id}`))
          .opacity(this.buttonOpacity(`bubble_primary_${point.id}`))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState(`bubble_primary_${point.id}`, event);
          })
          .onClick(() => {
            if (point.action === 'temperature' || point.action === 'curtain') {
              this.adjustPoint(point.id, -1);
            } else {
              this.togglePoint(point.id);
            }
          })

        Button(this.quickSecondaryLabel(point))
          .height(34)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .backgroundColor(this.translucentCardColor())
          .borderRadius(17)
          .border({
            width: 1,
            color: this.lineColor()
          })
          .layoutWeight(1)
          .margin({ left: 8 })
          .scale(this.buttonScale(`bubble_secondary_${point.id}`))
          .opacity(this.buttonOpacity(`bubble_secondary_${point.id}`))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState(`bubble_secondary_${point.id}`, event);
          })
          .onClick(() => {
            if (point.action === 'temperature' || point.action === 'curtain' || point.action === 'light') {
              this.adjustPoint(point.id, 1);
            } else {
              this.detailPointId = point.id;
            }
          })
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor(this.translucentPanelColor())
    .border({
      width: 1,
      color: this.lineColor()
    })
    .borderRadius(20)
    .margin({ top: 12 })
  }

  @Builder
  RoomMap() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.hasRoomImage(this.activeRoomId)) {
        Image(this.roomImage())
          .width('100%')
          .aspectRatio(ROOM_ASPECT)
          .objectFit(ImageFit.Contain)
          .borderRadius(24)

        ForEach(this.pointsForActiveRoom(), (point: PointSpec) => {
          this.PointDot(point)
        }, (point: PointSpec) => point.id)
      } else {
        Column() {
          Text(this.activeRoom().name)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())

          Text('当前房间暂未配置 2.5D 视角图')
            .fontSize(13)
            .fontColor(this.secondaryText())
            .margin({ top: 10 })
        }
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .aspectRatio(ROOM_ASPECT)
    .backgroundColor(this.cardColor())
    .border({
      width: 1,
      color: this.lineColor()
    })
    .borderRadius(24)
    .clip(true)
    .margin({ top: 18 })
  }

  @Builder
  DeviceControls() {
    Column() {
      Row() {
        Text('设备控制')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .layoutWeight(1)

        Text(`${this.controllablePoints().length} 个设备`)
          .fontSize(12)
          .fontColor(this.secondaryText())
      }
      .width('100%')

      if (this.controllablePoints().length > 0) {
        ForEach(this.controllablePoints(), (point: PointSpec) => {
          Row() {
            Column() {
              Text(point.name)
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.primaryText())

              Text(`${point.type} · ${this.pointStatus(point)}`)
                .fontSize(12)
                .fontColor(this.secondaryText())
                .margin({ top: 4 })
                .maxLines(1)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Button(this.listPrimaryLabel(point))
              .height(36)
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.inverseText())
              .backgroundColor(this.translucentInverseBg())
              .borderRadius(18)
              .padding({ left: 14, right: 14 })
              .scale(this.buttonScale(`list_primary_${point.id}`))
              .opacity(this.buttonOpacity(`list_primary_${point.id}`))
              .animation({ duration: 120, curve: Curve.EaseOut })
              .onTouch((event: TouchEvent) => {
                this.handlePressState(`list_primary_${point.id}`, event);
              })
              .onClick(() => {
                if (point.action === 'temperature' || point.action === 'curtain') {
                  this.adjustPoint(point.id, -1);
                } else {
                  this.togglePoint(point.id);
                }
              })

            Button(this.listSecondaryLabel(point))
              .height(36)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.primaryText())
              .backgroundColor(this.translucentCardColor())
              .borderRadius(18)
              .border({
                width: 1,
                color: this.lineColor()
              })
              .padding({ left: 14, right: 14 })
              .margin({ left: 8 })
              .scale(this.buttonScale(`list_secondary_${point.id}`))
              .opacity(this.buttonOpacity(`list_secondary_${point.id}`))
              .animation({ duration: 120, curve: Curve.EaseOut })
              .onTouch((event: TouchEvent) => {
                this.handlePressState(`list_secondary_${point.id}`, event);
              })
              .onClick(() => {
                this.selectedPointId = point.id;
                this.detailPointId = point.id;
                this.addRoomPanelVisible = false;
                this.selectionVersion++;
              })
          }
          .width('100%')
          .padding({ left: 14, right: 14, top: 14, bottom: 14 })
          .backgroundColor(this.translucentPanelColor())
          .border({
            width: 1,
            color: this.lineColor()
          })
          .borderRadius(20)
          .margin({ top: 10 })
        }, (point: PointSpec) => point.id)
      } else {
        Column() {
          Text('当前房间还没有可控制设备')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.primaryText())

          Text('后续可以在这里添加设备开关和快捷设置。')
            .fontSize(12)
            .fontColor(this.secondaryText())
            .margin({ top: 6 })
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 18, bottom: 18 })
        .backgroundColor(this.translucentPanelColor())
        .border({
          width: 1,
          color: this.lineColor()
        })
        .borderRadius(20)
        .margin({ top: 10 })
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
    .margin({ top: 18 })
  }

  @Builder
  DetailPanel(point: PointSpec) {
    Column() {
      Row() {
        Column() {
          Text(point.name)
            .fontSize(22)
            .fontColor(this.primaryText())
            .fontWeight(FontWeight.Bold)
          Text(`${point.type} · ${this.pointStatus(point)}`)
            .fontSize(12)
            .fontColor(this.secondaryText())
            .margin({ top: 5 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Button('收起')
          .height(34)
          .fontSize(12)
          .fontColor(this.primaryText())
          .backgroundColor(this.translucentCardColor())
          .borderRadius(17)
          .scale(this.buttonScale(`detail_collapse_${point.id}`))
          .opacity(this.buttonOpacity(`detail_collapse_${point.id}`))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState(`detail_collapse_${point.id}`, event);
          })
          .onClick(() => {
            this.detailPointId = '';
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Text(point.detail)
        .fontSize(14)
        .fontColor(this.secondaryText())
        .lineHeight(21)
        .margin({ top: 14 })

      if (point.action === 'light') {
        Column() {
          Row() {
            Text('亮度')
              .fontSize(13)
              .fontColor(this.secondaryText())
            Text(`${this.detailValue(point)}${this.detailUnit(point)}`)
              .fontSize(13)
              .fontColor(this.primaryText())
              .fontWeight(FontWeight.Bold)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Slider({
            value: this.detailValue(point),
            min: this.detailMin(point),
            max: this.detailMax(point),
            step: 1,
            style: SliderStyle.OutSet
          })
            .blockColor(this.inverseBg())
            .trackColor(this.lineColor())
            .selectedColor(this.primaryText())
            .margin({ top: 8 })
            .onChange((value: number) => {
              this.setDetailValue(point, value);
            })
        }
        .width('100%')
        .margin({ top: 18 })

        Row() {
          Button(this.activeLightOn() ? '关闭灯光' : '打开灯光')
            .layoutWeight(1)
            .height(46)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.inverseText())
            .backgroundColor(this.translucentInverseBg())
            .borderRadius(23)
            .scale(this.buttonScale(`detail_light_toggle_${point.id}`))
            .opacity(this.buttonOpacity(`detail_light_toggle_${point.id}`))
            .animation({ duration: 120, curve: Curve.EaseOut })
            .onTouch((event: TouchEvent) => {
              this.handlePressState(`detail_light_toggle_${point.id}`, event);
            })
            .onClick(() => {
              this.togglePoint(point.id);
            })
          Button('-')
            .width(54)
            .height(46)
            .fontSize(18)
            .fontColor(this.primaryText())
            .backgroundColor(this.translucentCardColor())
            .borderRadius(23)
            .margin({ left: 10 })
            .scale(this.buttonScale(`detail_light_minus_${point.id}`))
            .opacity(this.buttonOpacity(`detail_light_minus_${point.id}`))
            .animation({ duration: 120, curve: Curve.EaseOut })
            .onTouch((event: TouchEvent) => {
              this.handlePressState(`detail_light_minus_${point.id}`, event);
            })
            .onClick(() => {
              this.adjustPoint(point.id, -1);
            })
          Button('+')
            .width(54)
            .height(46)
            .fontSize(18)
            .fontColor(this.primaryText())
            .backgroundColor(this.translucentCardColor())
            .borderRadius(23)
            .margin({ left: 8 })
            .scale(this.buttonScale(`detail_light_plus_${point.id}`))
            .opacity(this.buttonOpacity(`detail_light_plus_${point.id}`))
            .animation({ duration: 120, curve: Curve.EaseOut })
            .onTouch((event: TouchEvent) => {
              this.handlePressState(`detail_light_plus_${point.id}`, event);
            })
            .onClick(() => {
              this.adjustPoint(point.id, 1);
            })
        }
        .width('100%')
        .margin({ top: 18 })
      } else if (point.action === 'temperature' || point.action === 'curtain') {
        Column() {
          Row() {
            Text(point.action === 'temperature' ? '目标温度' : '开合比例')
              .fontSize(13)
              .fontColor(this.secondaryText())
            Text(`${this.detailValue(point)}${this.detailUnit(point)}`)
              .fontSize(13)
              .fontColor(this.primaryText())
              .fontWeight(FontWeight.Bold)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Slider({
            value: this.detailValue(point),
            min: this.detailMin(point),
            max: this.detailMax(point),
            step: 1,
            style: SliderStyle.OutSet
          })
            .blockColor(this.inverseBg())
            .trackColor(this.lineColor())
            .selectedColor(this.primaryText())
            .margin({ top: 8 })
            .onChange((value: number) => {
              this.setDetailValue(point, value);
            })
        }
        .width('100%')
        .margin({ top: 18 })

        Row() {
          Button('-')
            .layoutWeight(1)
            .height(46)
            .fontSize(18)
            .fontColor(this.primaryText())
            .backgroundColor(this.translucentCardColor())
            .borderRadius(23)
            .scale(this.buttonScale(`detail_adjust_minus_${point.id}`))
            .opacity(this.buttonOpacity(`detail_adjust_minus_${point.id}`))
            .animation({ duration: 120, curve: Curve.EaseOut })
            .onTouch((event: TouchEvent) => {
              this.handlePressState(`detail_adjust_minus_${point.id}`, event);
            })
            .onClick(() => {
              this.adjustPoint(point.id, -1);
            })
          Button('+')
            .layoutWeight(1)
            .height(46)
            .fontSize(18)
            .fontColor(this.inverseText())
            .backgroundColor(this.translucentInverseBg())
            .borderRadius(23)
            .margin({ left: 10 })
            .scale(this.buttonScale(`detail_adjust_plus_${point.id}`))
            .opacity(this.buttonOpacity(`detail_adjust_plus_${point.id}`))
            .animation({ duration: 120, curve: Curve.EaseOut })
            .onTouch((event: TouchEvent) => {
              this.handlePressState(`detail_adjust_plus_${point.id}`, event);
            })
            .onClick(() => {
              this.adjustPoint(point.id, 1);
            })
        }
        .width('100%')
        .margin({ top: 18 })
      } else if (point.action === 'toggle') {
        Button('切换状态')
          .width('100%')
          .height(46)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.inverseText())
          .backgroundColor(this.translucentInverseBg())
          .borderRadius(23)
          .margin({ top: 18 })
          .scale(this.buttonScale(`detail_toggle_${point.id}`))
          .opacity(this.buttonOpacity(`detail_toggle_${point.id}`))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState(`detail_toggle_${point.id}`, event);
          })
          .onClick(() => {
            this.togglePoint(point.id);
          })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(this.translucentPanelColor())
    .border({
      width: 1,
      color: this.lineColor()
    })
    .borderRadius(24)
    .margin({ top: 16 })
  }

  @Builder
  AddRoomPanel() {
    Column() {
      Row() {
        Text('添加房间')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .layoutWeight(1)

        Button('关闭')
          .height(34)
          .fontSize(12)
          .fontColor(this.primaryText())
          .backgroundColor(this.translucentCardColor())
          .borderRadius(17)
          .scale(this.buttonScale('add_room_close'))
          .opacity(this.buttonOpacity('add_room_close'))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState('add_room_close', event);
          })
          .onClick(() => {
            this.closeOverlayPanel();
          })
      }
      .width('100%')

      Text('预设房间')
        .fontSize(12)
        .fontColor(this.secondaryText())
        .margin({ top: 16 })

      Scroll() {
        Row() {
          ForEach(this.availablePresetRooms(), (room: RoomSpec) => {
            Button(room.name)
              .height(40)
              .fontSize(13)
              .fontColor(this.primaryText())
              .backgroundColor(this.translucentCardColor())
              .borderRadius(20)
              .border({
                width: 1,
                color: this.lineColor()
              })
              .padding({ left: 16, right: 16 })
              .margin({ right: 10 })
              .scale(this.buttonScale(`preset_room_${room.id}`))
              .opacity(this.buttonOpacity(`preset_room_${room.id}`))
              .animation({ duration: 120, curve: Curve.EaseOut })
              .onTouch((event: TouchEvent) => {
                this.handlePressState(`preset_room_${room.id}`, event);
              })
              .onClick(() => {
                this.addPresetRoom(room.id);
              })
          }, (room: RoomSpec) => room.id)
        }
        .padding({ right: 8 })
      }
      .width('100%')
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
      .margin({ top: 10 })

      Text('自定义房间')
        .fontSize(12)
        .fontColor(this.secondaryText())
        .margin({ top: 18 })

      TextInput({ placeholder: '输入房间名称', text: this.customRoomName })
        .width('100%')
        .height(46)
        .fontSize(14)
        .fontColor(this.primaryText())
        .placeholderColor(this.secondaryText())
        .backgroundColor(this.translucentCardColor())
        .borderRadius(18)
        .border({
          width: 1,
          color: this.lineColor()
        })
        .padding({ left: 14, right: 14 })
        .margin({ top: 10 })
        .onChange((value: string) => {
          this.customRoomName = value;
        })

      Button('创建自定义房间')
        .width('100%')
        .height(44)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.inverseText())
        .backgroundColor(this.translucentInverseBg())
        .borderRadius(22)
        .margin({ top: 14 })
        .scale(this.buttonScale('create_custom_room'))
        .opacity(this.buttonOpacity('create_custom_room'))
        .animation({ duration: 120, curve: Curve.EaseOut })
        .onTouch((event: TouchEvent) => {
          this.handlePressState('create_custom_room', event);
        })
        .onClick(() => {
          this.addCustomRoom();
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(this.translucentPanelColor())
    .border({
      width: 1,
      color: this.lineColor()
    })
    .borderRadius(24)
    .transition(this.overlayTransition())
  }

  @Builder
  OverlayPanel() {
    if (this.overlayVisible()) {
      Column() {
        Scroll() {
          Column() {
            if (this.addRoomPanelVisible) {
              this.AddRoomPanel()
            } else if (this.detailPointId.length > 0) {
              this.DetailPanel(this.pointById(this.detailPointId))
            } else if (this.selectedPointId.length > 0) {
              this.Bubble(this.pointById(this.selectedPointId))
            }
          }
          .width('100%')
        }
        .width('100%')
        .height(this.panelViewportHeight() + 16)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .padding({ left: 18, right: 18, bottom: 92 })
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.End)
      .backgroundColor('#00000000')
      .transition(this.overlayTransition())
    }
  }

  @Builder
  HomePage() {
    Scroll() {
      Column() {
        this.TopBar()
        this.RoomTabs()
        this.RoomMap()
        this.DeviceControls()
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 28, bottom: 30 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  EmptyPage() {
    Column()
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(this.bgColor())
  }

  @Builder
  HomeNavIcon(tabId: string) {
    Stack() {
      Column()
        .width(14)
        .height(10)
        .borderRadius(3)
        .backgroundColor('#00000000')
        .border({
          width: 1,
          color: this.navIconColor(tabId)
        })
        .position({ x: 5, y: 11 })

      Line({ width: 22, height: 12 })
        .startPoint([3, 10])
        .endPoint([11, 2])
        .stroke(this.navIconColor(tabId))
        .strokeWidth(1.4)
        .position({ x: 1, y: 2 })

      Line({ width: 22, height: 12 })
        .startPoint([11, 2])
        .endPoint([19, 10])
        .stroke(this.navIconColor(tabId))
        .strokeWidth(1.4)
        .position({ x: 1, y: 2 })

      Column()
        .width(4)
        .height(5)
        .borderRadius(1)
        .backgroundColor('#00000000')
        .border({
          width: 1,
          color: this.navIconColor(tabId)
        })
        .position({ x: 10, y: 16 })
    }
    .width(24)
    .height(24)
  }

  @Builder
  SmartNavIcon(tabId: string) {
    Stack() {
      Line({ width: 18, height: 1 })
        .startPoint([0, 0.5])
        .endPoint([18, 0.5])
        .stroke(this.navIconColor(tabId))
        .strokeWidth(1.2)
        .position({ x: 3, y: 8 })

      Line({ width: 18, height: 1 })
        .startPoint([0, 0.5])
        .endPoint([18, 0.5])
        .stroke(this.navIconColor(tabId))
        .strokeWidth(1.2)
        .position({ x: 3, y: 16 })

      Line({ width: 1, height: 16 })
        .startPoint([0.5, 0])
        .endPoint([0.5, 16])
        .stroke(this.navIconColor(tabId))
        .strokeWidth(1.2)
        .position({ x: 8, y: 4 })

      Line({ width: 1, height: 16 })
        .startPoint([0.5, 0])
        .endPoint([0.5, 16])
        .stroke(this.navIconColor(tabId))
        .strokeWidth(1.2)
        .position({ x: 16, y: 4 })

      Column()
        .width(6)
        .height(6)
        .borderRadius(3)
        .backgroundColor(this.navItemBg(tabId))
        .border({ width: 1, color: this.navIconColor(tabId) })
        .position({ x: 5, y: 5 })

      Column()
        .width(6)
        .height(6)
        .borderRadius(3)
        .backgroundColor(this.navItemBg(tabId))
        .border({ width: 1, color: this.navIconColor(tabId) })
        .position({ x: 13, y: 5 })

      Column()
        .width(6)
        .height(6)
        .borderRadius(3)
        .backgroundColor(this.navItemBg(tabId))
        .border({ width: 1, color: this.navIconColor(tabId) })
        .position({ x: 5, y: 13 })

      Column()
        .width(6)
        .height(6)
        .borderRadius(3)
        .backgroundColor(this.navItemBg(tabId))
        .border({ width: 1, color: this.navIconColor(tabId) })
        .position({ x: 13, y: 13 })
    }
    .width(24)
    .height(24)
  }

  @Builder
  StoreNavIcon(tabId: string) {
    Stack() {
      Column()
        .width(8)
        .height(7)
        .borderRadius(4)
        .backgroundColor('#00000000')
        .border({
          width: 1,
          color: this.navIconColor(tabId)
        })
        .position({ x: 8, y: 4 })

      Column()
        .width(16)
        .height(13)
        .borderRadius(4)
        .backgroundColor('#00000000')
        .border({
          width: 1,
          color: this.navIconColor(tabId)
        })
        .position({ x: 4, y: 9 })

      Line({ width: 12, height: 1 })
        .startPoint([0, 0.5])
        .endPoint([12, 0.5])
        .stroke(this.navIconColor(tabId))
        .strokeWidth(1.1)
        .position({ x: 6, y: 13 })
    }
    .width(24)
    .height(24)
  }

  @Builder
  ProfileNavIcon(tabId: string) {
    Stack() {
      Column()
        .width(8)
        .height(8)
        .borderRadius(4)
        .backgroundColor('#00000000')
        .border({
          width: 1,
          color: this.navIconColor(tabId)
        })
        .position({ x: 8, y: 4 })

      Column()
        .width(16)
        .height(8)
        .borderRadius(8)
        .backgroundColor('#00000000')
        .border({
          width: 1,
          color: this.navIconColor(tabId)
        })
        .position({ x: 4, y: 14 })
    }
    .width(24)
    .height(24)
  }

  @Builder
  NavIcon(item: NavSpec) {
    if (item.id === 'home') {
      this.HomeNavIcon(item.id)
    } else if (item.id === 'smart') {
      this.SmartNavIcon(item.id)
    } else if (item.id === 'store') {
      this.StoreNavIcon(item.id)
    } else {
      this.ProfileNavIcon(item.id)
    }
  }

  @Builder
  BottomNav() {
    Row() {
      ForEach(NAV_ITEMS, (item: NavSpec) => {
        Column() {
          this.NavIcon(item)

          Text(item.label)
            .fontSize(12)
            .fontWeight(this.activeTab === item.id ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(this.navTextColor(item.id))
            .margin({ top: 3 })
        }
        .layoutWeight(1)
        .height(58)
        .justifyContent(FlexAlign.Center)
        .borderRadius(16)
        .backgroundColor(this.navItemBg(item.id))
        .scale(this.buttonScale(`nav_${item.id}`))
        .opacity(this.buttonOpacity(`nav_${item.id}`))
        .animation({ duration: 120, curve: Curve.EaseOut })
        .onTouch((event: TouchEvent) => {
          this.handlePressState(`nav_${item.id}`, event);
        })
        .onClick(() => {
          this.activeTab = item.id;
          if (item.id !== 'home') {
            this.selectedPointId = '';
            this.detailPointId = '';
          }
        })
      }, (item: NavSpec) => item.id)
    }
    .width('100%')
    .height(86)
    .padding({ left: 12, right: 12, top: 10, bottom: 14 })
    .backgroundColor(this.translucentPanelColor())
    .border({
      width: { top: 1 },
      color: this.lineColor()
    })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        if (this.activeTab === 'home') {
          this.HomePage()
        } else {
          this.EmptyPage()
        }
        this.BottomNav()
      }
      .width('100%')
      .height('100%')

      if (this.activeTab === 'home') {
        this.OverlayPanel()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor())
  }
}
