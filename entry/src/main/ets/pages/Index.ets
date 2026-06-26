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

interface SummaryChipSpec {
  id: string;
  label: string;
  value: string;
  badge: string;
}

interface SceneSpec {
  id: string;
  label: string;
  detail: string;
  badge: string;
}

interface AgentSuggestionSpec {
  id: string;
  label: string;
  prompt: string;
}

interface AgentRecordSpec {
  id: string;
  title: string;
  detail: string;
  time: string;
  status: string;
}

interface SmartTriggerSpec {
  type: string;
  label: string;
  time?: string;
  weekday?: string;
  sceneId?: string;
  roomId?: string;
}

interface SmartActionSpec {
  pointId: string;
  command: string;
  label: string;
  value?: number;
}

interface AutomationSpec {
  id: string;
  title: string;
  trigger: string;
  action: string;
  source: string;
  enabled: boolean;
  triggerSpec: SmartTriggerSpec;
  actions: SmartActionSpec[];
}

interface AgentMessageSpec {
  id: string;
  role: string;
  text: string;
  meta: string;
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

const SCENES: SceneSpec[] = [
  { id: 'morning', label: '早安', detail: '开帘与日间', badge: '晨' },
  { id: 'arrive', label: '回家', detail: '灯光与空气', badge: '家' },
  { id: 'movie', label: '观影', detail: '客厅联动', badge: '影' },
  { id: 'sleep', label: '睡眠', detail: '夜间静音', badge: '夜' }
];

const SMART_SUGGESTIONS: AgentSuggestionSpec[] = [
  { id: 'leave', label: '离家断电', prompt: '当我出门时，关闭客厅电视、空气净化器和主灯，并开启安防提醒' },
  { id: 'night', label: '夜间入睡', prompt: '每天晚上十点半关闭客厅灯，拉上卧室窗帘并把卧室空调调到23度' },
  { id: 'return', label: '回家模式', prompt: '我回家后打开客厅灯到70%，启动空气净化器并让电视进入待机' },
  { id: 'clean', label: '周末清洁', prompt: '每周六上午十点启动客厅和卧室扫地机器人，清洁完成后提醒我' }
];

const DEFAULT_AGENT_RECORDS: AgentRecordSpec[] = [
  {
    id: 'record_seed_1',
    title: '智能助手已整理晨间场景',
    detail: '建议把窗帘、空调和照明联动成一个一键场景。',
    time: '09:12',
    status: '建议'
  },
  {
    id: 'record_seed_2',
    title: '离家脚本已同步',
    detail: '关闭高功率设备，并保留必要的安防提醒。',
    time: '08:46',
    status: '已执行'
  }
];

const DEFAULT_AUTOMATIONS: AutomationSpec[] = [
  {
    id: 'auto_leave',
    title: '离家断电',
    trigger: '离家定位或手动点击离家场景',
    action: '关闭客厅电视、空气净化器和主灯',
    source: 'agent',
    enabled: true,
    triggerSpec: {
      type: 'presence',
      label: '离家定位或手动点击离家场景'
    },
    actions: [
      { pointId: 'living_tv', command: 'off', label: '关闭客厅电视' },
      { pointId: 'living_purifier', command: 'off', label: '关闭空气净化器' },
      { pointId: 'living_light', command: 'off', label: '关闭客厅主灯' }
    ]
  },
  {
    id: 'auto_sleep',
    title: '睡眠安静模式',
    trigger: '每天 22:30',
    action: '拉上卧室窗帘，客厅灯关闭，卧室空调调至 23°C',
    source: 'manual',
    enabled: true,
    triggerSpec: {
      type: 'time',
      label: '每天 22:30',
      time: '22:30'
    },
    actions: [
      { pointId: 'bedroom_curtain', command: 'set', label: '拉上卧室窗帘', value: 100 },
      { pointId: 'living_light', command: 'off', label: '关闭客厅灯' },
      { pointId: 'bedroom_air', command: 'set', label: '卧室空调调至 23°C', value: 23 }
    ]
  }
];

const DEFAULT_AGENT_MESSAGES: AgentMessageSpec[] = [];

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

const INITIAL_ROOMS: RoomSpec[] = [
  ROOMS[0],
  ROOMS[1]
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
  @State rooms: RoomSpec[] = INITIAL_ROOMS;
  @State activeRoomId: string = 'living';
  @State homeRoomSwiperIndex: number = 0;
  @State activeSceneId: string = 'morning';
  @State agentPrompt: string = '';
  @State agentListening: boolean = false;
  @State automationComposerVisible: boolean = false;
  @State automationTitle: string = '';
  @State automationTrigger: string = '';
  @State automationAction: string = '';
  @State expandedAutomationId: string = '';
  @State agentRecords: AgentRecordSpec[] = DEFAULT_AGENT_RECORDS;
  @State automations: AutomationSpec[] = DEFAULT_AUTOMATIONS;
  @State chatMessages: AgentMessageSpec[] = DEFAULT_AGENT_MESSAGES;
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

  private pointsForRoom(roomId: string): PointSpec[] {
    return POINTS.filter((point: PointSpec) => point.roomId === roomId);
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
    if (this.activeRoomId === 'living') {
      return this.livingLightOn;
    }
    if (this.activeRoomId === 'bedroom') {
      return this.bedroomLightOn;
    }
    return false;
  }

  private setActiveLight(value: boolean): void {
    if (this.activeRoomId === 'living') {
      this.livingLightOn = value;
      return;
    }
    if (this.activeRoomId === 'bedroom') {
      this.bedroomLightOn = value;
    }
  }

  private lightOnForRoom(roomId: string): boolean {
    if (roomId === 'living') {
      return this.livingLightOn;
    }
    if (roomId === 'bedroom') {
      return this.bedroomLightOn;
    }
    return false;
  }

  private roomImageById(roomId: string): Resource {
    const room = this.roomById(roomId);
    if (room.images === undefined) {
      return $r('app.media.room_living_day_lightoff');
    }
    const lightOn = this.lightOnForRoom(roomId);
    if (this.isNight) {
      return lightOn ? room.images!.nightLightOn : room.images!.nightLightOff;
    }
    return lightOn ? room.images!.dayLightOn : room.images!.dayLightOff;
  }

  private bgColor(): string {
    return this.isNight ? '#060709' : '#F2F4F8';
  }

  private panelColor(): string {
    return this.isNight ? '#121417' : '#FFFFFF';
  }

  private cardColor(): string {
    return this.isNight ? '#171A1F' : '#F8F9FC';
  }

  private primaryText(): string {
    return this.isNight ? '#F5F7FB' : '#111317';
  }

  private secondaryText(): string {
    return this.isNight ? '#A9AFBC' : '#69707A';
  }

  private lineColor(): string {
    return this.isNight ? '#20FFFFFF' : '#12000000';
  }

  private inverseBg(): string {
    return this.isNight ? '#F5F7FB' : '#111317';
  }

  private translucentPanelColor(): string {
    return this.isNight ? '#8C171A1F' : '#BFEFF2F7';
  }

  private translucentCardColor(): string {
    return this.isNight ? '#661F232A' : '#B8FFFFFF';
  }

  private translucentInverseBg(): string {
    return this.isNight ? '#D9F5F7FB' : '#D9111317';
  }

  private glassShellColor(): string {
    return this.isNight ? '#73161A20' : '#A6FFFFFF';
  }

  private glassStrongColor(): string {
    return this.isNight ? '#A61A1E25' : '#D9FFFFFF';
  }

  private glassBorderColor(): string {
    return this.isNight ? '#20FFFFFF' : '#73FFFFFF';
  }

  private softDividerColor(): string {
    return this.isNight ? '#14FFFFFF' : '#08000000';
  }

  private atmosphereCoolColor(): string {
    return this.isNight ? '#224D7A' : '#D9E5F5';
  }

  private atmosphereWarmColor(): string {
    return this.isNight ? '#4C372A' : '#F3E3D0';
  }

  private tintColor(type: string): string {
    if (type === '温控') {
      return '#6CAEFF';
    }
    if (type === '照明') {
      return '#F4C94A';
    }
    if (type === '安防') {
      return '#58D0BE';
    }
    if (type === '清洁') {
      return '#7EA0FF';
    }
    if (type === '空气') {
      return '#6CC8C3';
    }
    if (type === '影音') {
      return '#8D93A3';
    }
    if (type === '遮阳') {
      return '#A5AC8B';
    }
    return this.isNight ? '#D3D7DE' : '#4D5561';
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
    this.homeRoomSwiperIndex = this.roomIndexById(roomId);
    this.selectedPointId = '';
    this.detailPointId = '';
    this.addRoomPanelVisible = false;
    this.selectionVersion++;
  }

  private roomIndexById(roomId: string): number {
    for (let i = 0; i < this.rooms.length; i++) {
      if (this.rooms[i].id === roomId) {
        return i;
      }
    }
    return 0;
  }

  private handleRoomSwiperChange(index: number): void {
    if (index >= this.rooms.length) {
      this.homeRoomSwiperIndex = index;
      this.selectedPointId = '';
      this.detailPointId = '';
      this.addRoomPanelVisible = false;
      return;
    }
    this.selectRoom(this.rooms[index].id);
  }

  private onAddRoomSwiperPage(): boolean {
    return this.homeRoomSwiperIndex >= this.rooms.length;
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
      this.selectRoom(roomId);
      return;
    }
    for (let i = 0; i < ROOMS.length; i++) {
      if (ROOMS[i].id === roomId) {
        const nextIndex = this.rooms.length;
        this.rooms = [...this.rooms, ROOMS[i]];
        this.activeRoomId = roomId;
        this.homeRoomSwiperIndex = nextIndex;
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
    const nextIndex = this.rooms.length;
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
    this.homeRoomSwiperIndex = nextIndex;
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

  private openPointDetail(pointId: string): void {
    this.selectedPointId = pointId;
    this.detailPointId = pointId;
    this.addRoomPanelVisible = false;
    this.selectionVersion++;
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
    if (point.action === 'curtain') {
      return this.detailValue(point) > 0 ? '关闭' : '打开';
    }
    if (point.id === 'living_tv') {
      return this.livingTvOn ? '关机' : '开机';
    }
    if (point.id === 'living_purifier') {
      return this.livingPurifierOn ? '关闭' : '开启';
    }
    if (point.id === 'living_robot') {
      return this.livingRobotOn ? '暂停' : '开始';
    }
    if (point.id === 'bedroom_robot') {
      return this.bedroomRobotOn ? '暂停' : '开始';
    }
    if (point.id === 'bedroom_door') {
      return this.bedroomDoorLocked ? '解锁' : '上锁';
    }
    if (point.action === 'toggle') {
      return '开关';
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
      return this.detailValue(point) >= 100 ? '关闭' : '打开';
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

  private currentLightLevel(): number {
    if (this.activeRoomId === 'living') {
      return this.livingLightLevel;
    }
    if (this.activeRoomId === 'bedroom') {
      return this.bedroomLightLevel;
    }
    return 0;
  }

  private hasActionInActiveRoom(action: string): boolean {
    const points = this.pointsForActiveRoom();
    for (let i = 0; i < points.length; i++) {
      if (points[i].action === action) {
        return true;
      }
    }
    return false;
  }

  private temperatureSummary(): string {
    if (this.activeRoomId === 'living') {
      return `${this.livingTemperature}°C`;
    }
    if (this.activeRoomId === 'bedroom') {
      return `${this.bedroomTemperature}°C`;
    }
    return '未配置';
  }

  private lightingSummary(): string {
    if (!this.hasActionInActiveRoom('light')) {
      return '未配置';
    }
    return this.activeLightOn() ? `已开 · ${this.currentLightLevel()}%` : '全部关闭';
  }

  private securitySummary(): string {
    if (this.activeRoomId === 'bedroom') {
      return this.bedroomDoorLocked ? '已上锁' : '未上锁';
    }
    return this.controllablePoints().length > 0 ? '状态正常' : '未配置';
  }

  private devicesSummary(): string {
    const count = this.controllablePoints().length;
    return count > 0 ? `${count} 台在线` : '可添加';
  }

  private summaryChips(): SummaryChipSpec[] {
    return [
      { id: 'climate', label: '温控', value: this.temperatureSummary(), badge: '温' },
      { id: 'lights', label: '灯光', value: this.lightingSummary(), badge: '灯' },
      { id: 'security', label: '安防', value: this.securitySummary(), badge: '安' },
      { id: 'devices', label: '设备', value: this.devicesSummary(), badge: '设' }
    ];
  }

  private sceneTint(sceneId: string): string {
    if (sceneId === 'morning') {
      return '#F4C94A';
    }
    if (sceneId === 'arrive') {
      return '#D6A96D';
    }
    if (sceneId === 'movie') {
      return '#7F9CFF';
    }
    return '#78A9FF';
  }

  private chipTint(chipId: string): string {
    if (chipId === 'climate') {
      return this.tintColor('温控');
    }
    if (chipId === 'lights') {
      return this.tintColor('照明');
    }
    if (chipId === 'security') {
      return this.tintColor('安防');
    }
    return this.isNight ? '#D3D7DE' : '#67707C';
  }

  private applyScene(sceneId: string): void {
    this.activeSceneId = sceneId;
    this.manualPeriod = true;
    if (sceneId === 'morning') {
      this.isNight = false;
      this.livingCurtain = 82;
      this.bedroomCurtain = 68;
      this.livingLightOn = false;
      this.bedroomLightOn = false;
      this.livingTvOn = false;
      this.bedroomDoorLocked = true;
      return;
    }
    if (sceneId === 'arrive') {
      this.isNight = false;
      this.livingLightOn = true;
      this.livingLightLevel = 76;
      this.livingPurifierOn = true;
      this.bedroomDoorLocked = false;
      return;
    }
    if (sceneId === 'movie') {
      this.isNight = true;
      this.livingTvOn = true;
      this.livingLightOn = true;
      this.livingLightLevel = 22;
      this.livingCurtain = 16;
      return;
    }
    this.isNight = true;
    this.livingLightOn = false;
    this.livingTvOn = false;
    this.bedroomLightOn = true;
    this.bedroomLightLevel = 12;
    this.bedroomCurtain = 100;
    this.bedroomDoorLocked = true;
  }

  private pointBadge(point: PointSpec): string {
    if (point.action === 'temperature') {
      return '温';
    }
    if (point.action === 'curtain') {
      return '帘';
    }
    if (point.action === 'light') {
      return '灯';
    }
    if (point.id.indexOf('door') >= 0) {
      return '门';
    }
    if (point.id.indexOf('robot') >= 0) {
      return '扫';
    }
    if (point.id.indexOf('purifier') >= 0) {
      return '净';
    }
    if (point.id.indexOf('tv') >= 0) {
      return '影';
    }
    return point.name.substring(0, 1);
  }

  private deviceActionLabel(point: PointSpec): string {
    if (point.action === 'temperature') {
      return '升温';
    }
    if (point.action === 'curtain') {
      return this.detailValue(point) >= 100 ? '关闭' : '打开';
    }
    if (point.action === 'light') {
      return this.activeLightOn() ? '关灯' : '开灯';
    }
    if (point.id === 'living_tv') {
      return this.livingTvOn ? '关机' : '开机';
    }
    if (point.id === 'living_purifier') {
      return this.livingPurifierOn ? '关闭' : '开启';
    }
    if (point.id === 'living_robot') {
      return this.livingRobotOn ? '暂停' : '开始';
    }
    if (point.id === 'bedroom_robot') {
      return this.bedroomRobotOn ? '暂停' : '开始';
    }
    if (point.id === 'bedroom_door') {
      return this.bedroomDoorLocked ? '解锁' : '上锁';
    }
    if (point.action === 'toggle') {
      return '开关';
    }
    return '查看';
  }

  private runDeviceAction(pointId: string): void {
    const point = this.pointById(pointId);
    if (point.action === 'temperature') {
      this.adjustPoint(point.id, 1);
      return;
    }
    if (point.action === 'curtain') {
      this.setDetailValue(point, this.detailValue(point) >= 100 ? 0 : 100);
      return;
    }
    if (point.action === 'light' || point.action === 'toggle') {
      this.togglePoint(point.id);
      return;
    }
    this.openPointDetail(point.id);
  }

  private mapSummary(): string {
    const count = this.controllablePoints().length;
    return count > 0 ? `${count} 台设备在线` : '暂未配置设备';
  }

  private mapSummaryForRoom(roomId: string): string {
    const count = this.pointsForRoom(roomId).filter((point: PointSpec) => point.action !== 'info').length;
    return count > 0 ? `${count} 台设备在线` : '暂未配置设备';
  }

  private sidePoints(): PointSpec[] {
    return this.controllablePoints().slice(1, 3);
  }

  private extraPoints(): PointSpec[] {
    return this.controllablePoints().slice(3);
  }

  private dotLeft(point: PointSpec): string {
    return this.percent(Math.min(Math.max(point.x - 3.1, 0), 92));
  }

  private dotTop(point: PointSpec): string {
    return this.percent(Math.min(Math.max(point.y - 3.8, 0), 90));
  }

  private roomCardScaleByIndex(index: number): ScaleOptions {
    if (this.homeRoomSwiperIndex === index) {
      return { x: 1, y: 1 };
    }
    return { x: 0.94, y: 0.94 };
  }

  private roomCardOpacityByIndex(index: number): number {
    return this.homeRoomSwiperIndex === index ? 1 : 0.76;
  }

  private roomStageColor(): string {
    return this.isNight ? '#14181F' : '#EEF1F6';
  }

  private roomStageInnerColor(): string {
    return this.isNight ? '#1B2028' : '#FAFBFD';
  }

  private roomPageHint(roomId: string): string {
    const count = this.pointsForRoom(roomId).filter((point: PointSpec) => point.action !== 'info').length;
    return count > 0 ? '滑动切换后，下方设备会同步更新' : '这个房间还没有关联设备';
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
    if (point.action === 'temperature') {
      return '-';
    }
    if (point.action === 'curtain') {
      return this.detailValue(point) >= 100 ? '关闭' : '打开';
    }
    return this.deviceActionLabel(point);
  }

  private listSecondaryLabel(point: PointSpec): string {
    if (point.action === 'temperature' || point.action === 'curtain' || point.action === 'light') {
      return '设置';
    }
    return '详情';
  }

  private previewPromptText(): string {
    const value = this.agentPrompt.trim();
    if (value.length > 0) {
      return value;
    }
    return '例如：帮我创建一个出门后自动关闭高功率设备的脚本';
  }

  private pushChatMessage(role: string, text: string, meta: string): void {
    this.chatMessages = [
      ...this.chatMessages,
      {
        id: `${role}_${new Date().getTime()}`,
        role: role,
        text: text,
        meta: meta
      }
    ];
  }

  private buildAgentResponse(prompt: string): string {
    if (prompt.indexOf('自动') >= 0 || prompt.indexOf('脚本') >= 0 || prompt.indexOf('每天') >= 0 || prompt.indexOf('每周') >= 0) {
      return `我已经把你的需求整理成自动化草稿，并放到上方脚本板块。接下来你可以继续补充触发条件，或者直接启用它。`;
    }
    return `我已经理解你的控制需求。当前可以先按这个方案执行，并且如果你愿意，我也可以进一步把它沉淀成一个自动化脚本。`;
  }

  private createManualTriggerSpec(trigger: string): SmartTriggerSpec {
    if (trigger.indexOf('每天') >= 0 || trigger.indexOf(':') >= 0 || trigger.indexOf('点') >= 0) {
      return {
        type: 'time',
        label: trigger
      };
    }
    if (trigger.indexOf('每周') >= 0 || trigger.indexOf('周') >= 0) {
      return {
        type: 'weekly',
        label: trigger
      };
    }
    if (trigger.indexOf('离家') >= 0 || trigger.indexOf('回家') >= 0) {
      return {
        type: 'presence',
        label: trigger
      };
    }
    return {
      type: 'manual',
      label: trigger
    };
  }

  private createDraftActions(action: string): SmartActionSpec[] {
    return [
      {
        pointId: '',
        command: 'draft',
        label: action
      }
    ];
  }

  private appendAgentRecord(title: string, detail: string, status: string): void {
    const now = new Date();
    const time = `${`${now.getHours()}`.padStart(2, '0')}:${`${now.getMinutes()}`.padStart(2, '0')}`;
    this.agentRecords = [
      {
        id: `record_${now.getTime()}`,
        title: title,
        detail: detail,
        time: time,
        status: status
      },
      ...this.agentRecords
    ];
  }

  private applyAgentSuggestion(prompt: string): void {
    this.agentPrompt = prompt;
    this.appendAgentRecord('智能助手已载入指令草稿', prompt, '草稿');
    this.pushChatMessage('agent', `已将“${prompt}”带入输入框，你可以直接发送，或继续调整细节。`, '建议');
  }

  private toggleListening(): void {
    this.agentListening = !this.agentListening;
    this.appendAgentRecord(
      this.agentListening ? '语音输入已开启' : '语音输入已关闭',
      this.agentListening ? '现在可以通过语音描述想执行的指令。' : '你可以继续用文字调整脚本细节。',
      '建议'
    );
    this.pushChatMessage(
      'agent',
      this.agentListening ? '语音输入已开启，你现在可以直接描述需求。' : '语音输入已关闭，你可以继续通过文字给我下达指令。',
      this.agentListening ? '语音中' : '语音结束'
    );
  }

  private runAgentPrompt(): void {
    const prompt = this.agentPrompt.trim();
    if (prompt.length === 0) {
      this.appendAgentRecord('请输入指令', '智能助手需要明确的文字或语音指令才能生成执行方案。', '建议');
      this.pushChatMessage('agent', '先告诉我你想执行什么，我再帮你生成动作或脚本。', '等待指令');
      return;
    }
    this.pushChatMessage('user', prompt, '刚刚');
    const title = prompt.indexOf('自动') >= 0 || prompt.indexOf('脚本') >= 0 ? '智能助手已生成自动化草稿' : '智能助手已生成执行方案';
    this.appendAgentRecord(title, prompt, '已执行');
    if (prompt.indexOf('自动') >= 0 || prompt.indexOf('脚本') >= 0 || prompt.indexOf('每天') >= 0 || prompt.indexOf('每周') >= 0) {
      this.automations = [
        {
          id: `auto_${new Date().getTime()}`,
          title: '智能助手新建自动化',
          trigger: '等待你补充触发条件',
          action: prompt,
          source: 'agent',
          enabled: true,
          triggerSpec: {
            type: 'draft',
            label: '等待你补充触发条件'
          },
          actions: this.createDraftActions(prompt)
        },
        ...this.automations
      ];
    }
    this.pushChatMessage('agent', this.buildAgentResponse(prompt), title);
    this.agentPrompt = '';
  }

  private openAutomationComposer(): void {
    this.expandedAutomationId = '';
    this.automationComposerVisible = true;
  }

  private toggleAutomationDetail(automationId: string): void {
    this.automationComposerVisible = false;
    if (this.expandedAutomationId === automationId) {
      this.expandedAutomationId = '';
      return;
    }
    this.expandedAutomationId = automationId;
  }

  private addManualAutomation(): void {
    const title = this.automationTitle.trim();
    const trigger = this.automationTrigger.trim();
    const action = this.automationAction.trim();
    if (title.length === 0 || trigger.length === 0 || action.length === 0) {
      this.appendAgentRecord('自动化信息不完整', '请补全名称、触发条件和执行动作。', '建议');
      return;
    }
    const automationId = `manual_${new Date().getTime()}`;
    this.automations = [
      {
        id: automationId,
        title: title,
        trigger: trigger,
        action: action,
        source: 'manual',
        enabled: true,
        triggerSpec: this.createManualTriggerSpec(trigger),
        actions: this.createDraftActions(action)
      },
      ...this.automations
    ];
    this.appendAgentRecord('手动自动化已创建', `${title} · ${trigger}`, '已执行');
    this.pushChatMessage('agent', `已创建脚本“${title}”，触发条件是“${trigger}”。你现在可以在上方脚本板块里继续启用或调整它。`, '脚本已保存');
    this.automationTitle = '';
    this.automationTrigger = '';
    this.automationAction = '';
    this.expandedAutomationId = automationId;
    this.automationComposerVisible = false;
  }

  private toggleAutomation(automationId: string): void {
    const nextAutomations: AutomationSpec[] = [];
    for (let i = 0; i < this.automations.length; i++) {
      const item = this.automations[i];
      if (item.id === automationId) {
        nextAutomations.push({
          id: item.id,
          title: item.title,
          trigger: item.trigger,
          action: item.action,
          source: item.source,
          enabled: !item.enabled,
          triggerSpec: item.triggerSpec,
          actions: item.actions
        });
      } else {
        nextAutomations.push(item);
      }
    }
    this.automations = nextAutomations;
  }

  @Builder
  TopBar() {
    Row() {
      Text('我的家')
        .fontSize(34)
        .fontColor(this.primaryText())
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)

      Button(this.isNight ? '夜间' : '日间')
        .height(42)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.inverseText())
        .backgroundColor(this.translucentInverseBg())
        .border({
          width: 1,
          color: this.glassBorderColor()
        })
        .borderRadius(21)
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
    .alignItems(VerticalAlign.Center)
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
    .backgroundColor(this.glassStrongColor())
    .border({
      width: 1,
      color: this.glassBorderColor()
    })
    .borderRadius(18)
    .margin({ top: 12 })
  }

  @Builder
  RoomScenePage(room: RoomSpec) {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width('92%')
          .height('82%')
          .backgroundColor(this.roomStageInnerColor())
          .borderRadius(18)

        if (room.images !== undefined) {
          Image(this.roomImageById(room.id))
            .width('100%')
            .aspectRatio(ROOM_ASPECT)
            .objectFit(ImageFit.Contain)
            .borderRadius(16)

          ForEach(this.pointsForRoom(room.id), (point: PointSpec) => {
            if (this.activeRoomId === room.id) {
              this.PointDot(point)
            }
          }, (point: PointSpec) => point.id)
        } else {
          Column() {
            Text(room.name)
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.primaryText())

            Text('当前房间暂未配置 2.5D 视角图')
              .fontSize(13)
              .fontColor(this.secondaryText())
              .margin({ top: 10 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
      .aspectRatio(ROOM_ASPECT)
      .padding(6)
      .backgroundColor(this.roomStageColor())
      .border({
        width: 1,
        color: this.glassBorderColor()
      })
      .borderRadius(20)
      .clip(true)
    }
    .width('100%')
  }

  @Builder
  AddRoomScenePage() {
    Column() {
      Column() {
        Text('+')
          .fontSize(44)
          .fontWeight(FontWeight.Lighter)
          .fontColor(this.primaryText())

        Text('添加房间')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .margin({ top: 12 })

        Text('滑到最右侧后从这里继续添加空间')
          .fontSize(12)
          .fontColor(this.secondaryText())
          .margin({ top: 8 })

        Button('开始添加')
          .height(40)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .backgroundColor(this.glassShellColor())
          .border({
            width: 1,
            color: this.glassBorderColor()
          })
          .borderRadius(20)
          .padding({ left: 18, right: 18 })
          .margin({ top: 20 })
          .scale(this.buttonScale('room_swiper_add'))
          .opacity(this.buttonOpacity('room_swiper_add'))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState('room_swiper_add', event);
          })
          .onClick(() => {
            this.openAddRoomPanel();
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(this.roomStageColor())
      .border({
        width: 1,
        color: this.glassBorderColor()
      })
      .borderRadius(20)
    }
    .width('100%')
    .aspectRatio(ROOM_ASPECT)
  }

  @Builder
  RoomMap() {
    Column() {
      Swiper() {
        ForEach(this.rooms, (room: RoomSpec) => {
          Column() {
            this.RoomScenePage(room)
          }
          .scale(this.roomCardScaleByIndex(this.roomIndexById(room.id)))
          .opacity(this.roomCardOpacityByIndex(this.roomIndexById(room.id)))
          .animation({ duration: 180, curve: Curve.EaseOut })
        }, (room: RoomSpec) => room.id)

        Column() {
          this.AddRoomScenePage()
        }
        .scale(this.roomCardScaleByIndex(this.rooms.length))
        .opacity(this.roomCardOpacityByIndex(this.rooms.length))
        .animation({ duration: 180, curve: Curve.EaseOut })
      }
      .index(this.homeRoomSwiperIndex)
      .indicator(true)
      .loop(false)
      .cachedCount(1)
      .onChange((index: number) => {
        this.handleRoomSwiperChange(index);
      })
      .width('100%')
      .aspectRatio(ROOM_ASPECT)

      Row() {
        if (this.onAddRoomSwiperPage()) {
          Column() {
            Text('添加房间')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.primaryText())

            Text('预设房间与自定义房间都可以从这里继续添加')
              .fontSize(11)
              .fontColor(this.secondaryText())
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        } else {
          Column() {
            Text(this.activeRoom().name)
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.primaryText())

            Text(this.roomPageHint(this.activeRoomId))
              .fontSize(11)
              .fontColor(this.secondaryText())
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }

        Text(this.onAddRoomSwiperPage() ? '末尾' : this.mapSummaryForRoom(this.activeRoomId))
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .padding({ left: 12, right: 12, top: 7, bottom: 7 })
          .backgroundColor(this.glassShellColor())
          .border({
            width: 1,
            color: this.glassBorderColor()
          })
          .borderRadius(16)
      }
      .width('100%')
      .margin({ top: 10 })
      .padding({ left: 4, right: 4 })
    }
    .width('100%')
    .padding(8)
    .backgroundColor(this.glassStrongColor())
    .border({
      width: 1,
      color: this.glassBorderColor()
    })
    .borderRadius(18)
    .margin({ top: 18 })
  }

  @Builder
  ToneBadge(label: string, tint: string, size: number) {
    Stack() {
      Column()
        .width(size)
        .height(size)
        .borderRadius(size / 2)
        .backgroundColor(this.translucentCardColor())
        .border({
          width: 1,
          color: this.glassBorderColor()
        })

      Text(label)
        .fontSize(size * 0.38)
        .fontWeight(FontWeight.Bold)
        .fontColor(tint)
    }
    .width(size)
    .height(size)
  }

  @Builder
  SummaryOverview() {
    Scroll() {
      Row() {
        ForEach(this.summaryChips(), (chip: SummaryChipSpec) => {
          Column() {
            Row() {
              this.ToneBadge(chip.badge, this.chipTint(chip.id), 30)

              Column() {
                Text(chip.label)
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.secondaryText())

                Text(chip.value)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.primaryText())
                  .margin({ top: 3 })
                  .maxLines(1)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 10 })
            }
            .width('100%')
          }
          .width(150)
          .height(76)
          .padding({ left: 14, right: 14, top: 12, bottom: 12 })
          .backgroundColor(this.glassShellColor())
          .border({
            width: 1,
            color: this.glassBorderColor()
          })
          .borderRadius(16)
          .margin({ right: 10 })
        }, (chip: SummaryChipSpec) => chip.id)
      }
      .padding({ right: 8 })
    }
    .width('100%')
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Horizontal)
    .margin({ top: 18 })
  }

  @Builder
  SceneStrip() {
    Column() {
      Row() {
        Text('场景')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .layoutWeight(1)

        Text('轻点执行')
          .fontSize(12)
          .fontColor(this.secondaryText())
      }
      .width('100%')

      Scroll() {
        Row() {
          ForEach(SCENES, (scene: SceneSpec) => {
            Row() {
              this.ToneBadge(scene.badge, this.sceneTint(scene.id), 32)

              Column() {
                Text(scene.label)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.activeSceneId === scene.id ? this.inverseText() : this.primaryText())

                Text(scene.detail)
                  .fontSize(11)
                  .fontColor(this.activeSceneId === scene.id ? '#B0FFFFFF' : this.secondaryText())
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 10, right: 10 })

              Text('+')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.activeSceneId === scene.id ? this.inverseText() : this.primaryText())
            }
            .padding({ left: 12, right: 14, top: 12, bottom: 12 })
            .backgroundColor(this.activeSceneId === scene.id ? this.translucentInverseBg() : this.glassShellColor())
            .border({
              width: 1,
              color: this.activeSceneId === scene.id ? this.glassBorderColor() : this.lineColor()
            })
            .borderRadius(18)
            .margin({ right: 10 })
            .scale(this.buttonScale(`scene_${scene.id}`))
            .opacity(this.buttonOpacity(`scene_${scene.id}`))
            .animation({ duration: 120, curve: Curve.EaseOut })
            .onTouch((event: TouchEvent) => {
              this.handlePressState(`scene_${scene.id}`, event);
            })
            .onClick(() => {
              this.applyScene(scene.id);
            })
          }, (scene: SceneSpec) => scene.id)
        }
        .padding({ right: 8 })
      }
      .width('100%')
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
      .margin({ top: 12 })
    }
    .width('100%')
    .margin({ top: 24 })
  }

  @Builder
  FeaturedDeviceCard(point: PointSpec) {
    Column() {
      Column() {
        Row() {
          Row() {
            this.ToneBadge(this.pointBadge(point), this.tintColor(point.type), 34)

            Column() {
              Text(point.name)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.primaryText())

              Text(point.type)
                .fontSize(11)
                .fontColor(this.secondaryText())
                .margin({ top: 2 })
            }
            .margin({ left: 10 })
            .alignItems(HorizontalAlign.Start)
          }
          .layoutWeight(1)

          Text('+')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())
            .width(34)
            .height(34)
            .textAlign(TextAlign.Center)
            .backgroundColor(this.translucentCardColor())
            .border({
              width: 1,
              color: this.glassBorderColor()
            })
            .borderRadius(17)
            .scale(this.iconScale(`feature_detail_${point.id}`))
            .opacity(this.buttonOpacity(`feature_detail_${point.id}`))
            .animation({ duration: 120, curve: Curve.EaseOut })
            .onTouch((event: TouchEvent) => {
              this.handlePressState(`feature_detail_${point.id}`, event);
            })
            .onClick(() => {
              this.openPointDetail(point.id);
            })
        }
        .width('100%')

        Text(this.pointStatus(point))
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .margin({ top: 18 })

        Text(point.detail)
          .fontSize(12)
          .lineHeight(18)
          .fontColor(this.secondaryText())
          .margin({ top: 8 })
          .maxLines(2)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Column()
        .layoutWeight(1)

      Button(this.deviceActionLabel(point))
        .width('100%')
        .height(42)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.inverseText())
        .backgroundColor(this.translucentInverseBg())
        .borderRadius(15)
        .scale(this.buttonScale(`feature_action_${point.id}`))
        .opacity(this.buttonOpacity(`feature_action_${point.id}`))
        .animation({ duration: 120, curve: Curve.EaseOut })
        .onTouch((event: TouchEvent) => {
          this.handlePressState(`feature_action_${point.id}`, event);
        })
        .onClick(() => {
          this.runDeviceAction(point.id);
        })
    }
    .height(220)
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(this.glassStrongColor())
    .border({
      width: 1,
      color: this.glassBorderColor()
    })
    .borderRadius(18)
  }

  @Builder
  MiniDeviceCard(point: PointSpec) {
    Column() {
      Row() {
        Row() {
          this.ToneBadge(this.pointBadge(point), this.tintColor(point.type), 28)

          Column() {
            Text(point.name)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.primaryText())
              .maxLines(1)

            Text(this.pointStatus(point))
              .fontSize(11)
              .fontColor(this.secondaryText())
              .margin({ top: 4 })
              .maxLines(1)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 10 })
        }
        .layoutWeight(1)

        Text('+')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .width(30)
          .height(30)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.translucentCardColor())
          .border({
            width: 1,
            color: this.glassBorderColor()
          })
          .borderRadius(15)
          .scale(this.iconScale(`mini_detail_${point.id}`))
          .opacity(this.buttonOpacity(`mini_detail_${point.id}`))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState(`mini_detail_${point.id}`, event);
          })
          .onClick(() => {
            this.openPointDetail(point.id);
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Button(this.deviceActionLabel(point))
        .width('100%')
        .height(36)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .backgroundColor(this.glassShellColor())
        .border({
          width: 1,
          color: this.lineColor()
        })
        .borderRadius(14)
        .scale(this.buttonScale(`mini_action_${point.id}`))
        .opacity(this.buttonOpacity(`mini_action_${point.id}`))
        .animation({ duration: 120, curve: Curve.EaseOut })
        .onTouch((event: TouchEvent) => {
          this.handlePressState(`mini_action_${point.id}`, event);
        })
        .onClick(() => {
          this.runDeviceAction(point.id);
        })
    }
    .height(105)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor(this.glassShellColor())
    .border({
      width: 1,
      color: this.glassBorderColor()
    })
    .borderRadius(18)
  }

  @Builder
  CompactDeviceCard(point: PointSpec) {
    Column() {
      Row() {
        this.ToneBadge(this.pointBadge(point), this.tintColor(point.type), 28)

        Column() {
          Text(point.name)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())

          Text(this.pointStatus(point))
            .fontSize(11)
            .fontColor(this.secondaryText())
            .margin({ top: 4 })
            .maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 10 })
      }
      .width('100%')

      Column()
        .layoutWeight(1)

      Row() {
        Button(this.deviceActionLabel(point))
          .layoutWeight(1)
          .height(34)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .backgroundColor(this.glassShellColor())
          .border({
            width: 1,
            color: this.lineColor()
          })
          .borderRadius(14)
          .scale(this.buttonScale(`compact_action_${point.id}`))
          .opacity(this.buttonOpacity(`compact_action_${point.id}`))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState(`compact_action_${point.id}`, event);
          })
          .onClick(() => {
            this.runDeviceAction(point.id);
          })

        Text('+')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .width(34)
          .height(34)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.translucentCardColor())
          .border({
            width: 1,
            color: this.glassBorderColor()
          })
          .borderRadius(17)
          .margin({ left: 8 })
          .scale(this.iconScale(`compact_detail_${point.id}`))
          .opacity(this.buttonOpacity(`compact_detail_${point.id}`))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState(`compact_detail_${point.id}`, event);
          })
          .onClick(() => {
            this.openPointDetail(point.id);
          })
      }
      .width('100%')
    }
    .height(116)
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor(this.glassShellColor())
    .border({
      width: 1,
      color: this.glassBorderColor()
    })
    .borderRadius(18)
  }

  @Builder
  WideDeviceCard(point: PointSpec) {
    Row() {
      Row() {
        this.ToneBadge(this.pointBadge(point), this.tintColor(point.type), 30)

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
        .margin({ left: 10 })
      }
      .layoutWeight(1)

      Button(this.deviceActionLabel(point))
        .height(38)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.inverseText())
        .backgroundColor(this.translucentInverseBg())
        .borderRadius(15)
        .padding({ left: 14, right: 14 })
        .scale(this.buttonScale(`wide_action_${point.id}`))
        .opacity(this.buttonOpacity(`wide_action_${point.id}`))
        .animation({ duration: 120, curve: Curve.EaseOut })
        .onTouch((event: TouchEvent) => {
          this.handlePressState(`wide_action_${point.id}`, event);
        })
        .onClick(() => {
          this.runDeviceAction(point.id);
        })

      Text('+')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width(34)
        .height(34)
        .textAlign(TextAlign.Center)
        .backgroundColor(this.translucentCardColor())
        .border({
          width: 1,
          color: this.glassBorderColor()
        })
        .borderRadius(17)
        .margin({ left: 8 })
        .scale(this.iconScale(`wide_detail_${point.id}`))
        .opacity(this.buttonOpacity(`wide_detail_${point.id}`))
        .animation({ duration: 120, curve: Curve.EaseOut })
        .onTouch((event: TouchEvent) => {
          this.handlePressState(`wide_detail_${point.id}`, event);
        })
        .onClick(() => {
          this.openPointDetail(point.id);
        })
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor(this.glassStrongColor())
    .border({
      width: 1,
      color: this.glassBorderColor()
    })
    .borderRadius(18)
  }

  @Builder
  DeviceControls() {
    Column() {
      this.SummaryOverview()
      this.SceneStrip()

      Row() {
        Text(`${this.activeRoom().name} 设备`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .layoutWeight(1)

        Text(this.devicesSummary())
          .fontSize(12)
          .fontColor(this.secondaryText())
      }
      .width('100%')
      .margin({ top: 24, bottom: 12 })

      if (this.controllablePoints().length > 0) {
        if (this.sidePoints().length > 0) {
          Row() {
            Column() {
              this.FeaturedDeviceCard(this.controllablePoints()[0])
            }
            .layoutWeight(11)

            Column() {
              if (this.sidePoints().length > 0) {
                this.MiniDeviceCard(this.sidePoints()[0])
              }
              if (this.sidePoints().length > 1) {
                Column() {
                  this.MiniDeviceCard(this.sidePoints()[1])
                }
                .margin({ top: 10 })
              }
            }
            .layoutWeight(9)
            .margin({ left: 10 })
          }
          .width('100%')
        } else {
          this.FeaturedDeviceCard(this.controllablePoints()[0])
        }

        if (this.extraPoints().length > 0) {
          Row() {
            Column() {
              this.CompactDeviceCard(this.extraPoints()[0])
            }
            .layoutWeight(1)

            if (this.extraPoints().length > 1) {
              Column() {
                this.CompactDeviceCard(this.extraPoints()[1])
              }
              .layoutWeight(1)
              .margin({ left: 10 })
            }
          }
          .width('100%')
          .margin({ top: 10 })
        }

        if (this.extraPoints().length > 2) {
          Column() {
            this.WideDeviceCard(this.extraPoints()[2])
          }
          .margin({ top: 10 })
        }
      } else {
        Column() {
          Text('当前房间还没有可控制设备')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())

          Text('先添加设备或继续为这个房间配置 2.5D 图与点位。')
            .fontSize(12)
            .fontColor(this.secondaryText())
            .margin({ top: 8 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 18, bottom: 18 })
        .backgroundColor(this.glassShellColor())
        .border({
          width: 1,
          color: this.glassBorderColor()
        })
        .borderRadius(18)
      }
    }
    .width('100%')
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
        Button(this.deviceActionLabel(point))
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
    .backgroundColor(this.glassStrongColor())
    .border({
      width: 1,
      color: this.glassBorderColor()
    })
    .borderRadius(20)
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
    .backgroundColor(this.glassStrongColor())
    .border({
      width: 1,
      color: this.glassBorderColor()
    })
    .borderRadius(20)
    .transition(this.overlayTransition())
  }

  @Builder
  OverlayPanel() {
    if (this.overlayVisible()) {
      Stack({ alignContent: Alignment.Bottom }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(this.isNight ? '#8C000000' : '#59000000')
          .transition(TransitionEffect.opacity(0).animation({ duration: 180, curve: Curve.EaseOut }))
          .onClick(() => {
            this.closeOverlayPanel();
          })

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
        .padding({ left: 18, right: 18, bottom: 118 })
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.End)
        .backgroundColor('#00000000')
        .transition(this.overlayTransition())
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  HomePage() {
    Scroll() {
      Column() {
        this.TopBar()
        this.RoomMap()
        if (!this.onAddRoomSwiperPage()) {
          this.DeviceControls()
        }
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 28, bottom: 132 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  ScriptHeaderCard() {
    Column() {
      Row() {
        Text('脚本')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .margin({ right: 10 })

        Scroll() {
          Row() {
            if (this.automations.length === 0) {
              Text('暂无脚本')
                .fontSize(11)
                .fontColor(this.secondaryText())
                .padding({ left: 14, right: 14, top: 10, bottom: 10 })
                .backgroundColor(this.glassShellColor())
                .border({
                  width: 1,
                  color: this.lineColor()
                })
                .borderRadius(16)
            } else {
              ForEach(this.automations.slice(0, 5), (item: AutomationSpec) => {
                Row() {
                  Column()
                    .width(6)
                    .height(6)
                    .borderRadius(3)
                    .backgroundColor(item.enabled ? this.primaryText() : this.secondaryText())

                  Text(item.title)
                    .fontSize(12)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.primaryText())
                    .maxLines(1)
                    .margin({ left: 8 })

                  Text('+')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.primaryText())
                    .width(18)
                    .textAlign(TextAlign.Center)
                    .margin({ left: 8 })
                }
                .padding({ left: 12, right: 12, top: 10, bottom: 10 })
                .backgroundColor(this.expandedAutomationId === item.id ? this.translucentCardColor() : this.glassShellColor())
                .border({
                  width: 1,
                  color: this.expandedAutomationId === item.id ? this.glassBorderColor() : this.lineColor()
                })
                .borderRadius(16)
                .margin({ right: 8 })
                .scale(this.buttonScale(`script_detail_${item.id}`))
                .opacity(this.buttonOpacity(`script_detail_${item.id}`))
                .animation({ duration: 120, curve: Curve.EaseOut })
                .onTouch((event: TouchEvent) => {
                  this.handlePressState(`script_detail_${item.id}`, event);
                })
                .onClick(() => {
                  this.toggleAutomationDetail(item.id);
                })
              }, (item: AutomationSpec) => item.id)
            }
          }
          .alignItems(VerticalAlign.Center)
          .padding({ right: 4 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Horizontal)

        Button('新建')
          .height(34)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .backgroundColor(this.glassShellColor())
          .border({
            width: 1,
            color: this.glassBorderColor()
          })
          .borderRadius(17)
          .padding({ left: 14, right: 14 })
          .margin({ left: 10 })
          .scale(this.buttonScale('script_add_top'))
          .opacity(this.buttonOpacity('script_add_top'))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState('script_add_top', event);
          })
          .onClick(() => {
            this.openAutomationComposer();
          })
      }
      .width('100%')
      .height(54)
      .alignItems(VerticalAlign.Center)

      if (this.expandedAutomationId.length > 0) {
        ForEach(this.automations, (item: AutomationSpec) => {
          if (item.id === this.expandedAutomationId) {
            Column() {
              Row() {
                Text(item.title)
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.primaryText())
                  .layoutWeight(1)

                Text(item.enabled ? '运行中' : '已暂停')
                  .fontSize(10)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.primaryText())
                  .padding({ left: 8, right: 8, top: 5, bottom: 5 })
                  .backgroundColor(this.translucentCardColor())
                  .border({
                    width: 1,
                    color: this.glassBorderColor()
                  })
                  .borderRadius(12)
              }
              .width('100%')

              Text(item.trigger)
                .fontSize(12)
                .fontColor(this.secondaryText())
                .margin({ top: 10 })

              Text(item.action)
                .fontSize(12)
                .lineHeight(18)
                .fontColor(this.primaryText())
                .margin({ top: 8 })

              Row() {
                Text(item.source === 'agent' ? '智能助手创建' : '手动创建')
                  .fontSize(11)
                  .fontColor(this.secondaryText())
                  .layoutWeight(1)

                Button(item.enabled ? '暂停' : '启用')
                  .height(32)
                  .fontSize(12)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.primaryText())
                  .backgroundColor(this.glassShellColor())
                  .border({
                    width: 1,
                    color: this.glassBorderColor()
                  })
                  .borderRadius(16)
                  .padding({ left: 14, right: 14 })
                  .scale(this.buttonScale(`script_toggle_${item.id}`))
                  .opacity(this.buttonOpacity(`script_toggle_${item.id}`))
                  .animation({ duration: 120, curve: Curve.EaseOut })
                  .onTouch((event: TouchEvent) => {
                    this.handlePressState(`script_toggle_${item.id}`, event);
                  })
                  .onClick(() => {
                    this.toggleAutomation(item.id);
                  })

                Button('收起')
                  .height(32)
                  .fontSize(12)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.primaryText())
                  .backgroundColor('#00000000')
                  .border({
                    width: 1,
                    color: this.lineColor()
                  })
                  .borderRadius(16)
                  .padding({ left: 14, right: 14 })
                  .margin({ left: 8 })
                  .scale(this.buttonScale(`script_collapse_${item.id}`))
                  .opacity(this.buttonOpacity(`script_collapse_${item.id}`))
                  .animation({ duration: 120, curve: Curve.EaseOut })
                  .onTouch((event: TouchEvent) => {
                    this.handlePressState(`script_collapse_${item.id}`, event);
                  })
                  .onClick(() => {
                    this.expandedAutomationId = '';
                  })
              }
              .width('100%')
              .margin({ top: 14 })
              .alignItems(VerticalAlign.Center)
            }
            .width('100%')
            .padding({ left: 14, right: 14, top: 14, bottom: 14 })
            .backgroundColor(this.glassShellColor())
            .border({
              width: 1,
              color: this.glassBorderColor()
            })
            .borderRadius(18)
            .margin({ top: 10 })
          }
        }, (item: AutomationSpec) => item.id)
      }
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor(this.glassStrongColor())
    .border({
      width: 1,
      color: this.glassBorderColor()
    })
    .borderRadius(22)
  }

  @Builder
  ChatMessageBubble(message: AgentMessageSpec) {
    Column() {
      Text(message.role === 'user' ? `你 · ${message.meta}` : message.meta)
        .fontSize(10)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.secondaryText())
        .margin({ bottom: 6 })
        .maxLines(1)

      Text(message.text)
        .fontSize(14)
        .lineHeight(21)
        .fontColor(message.role === 'user' ? this.inverseText() : this.primaryText())
    }
    .padding({ left: 15, right: 15, top: 13, bottom: 13 })
    .backgroundColor(message.role === 'user' ? this.translucentInverseBg() : this.translucentCardColor())
    .border({
      width: 1,
      color: message.role === 'user' ? this.glassBorderColor() : this.lineColor()
    })
    .borderRadius(20)
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ChatSurface() {
    Scroll() {
      Column() {
        if (this.chatMessages.length === 0) {
          Column() {
            Text('智能助手')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.primaryText())

            Scroll() {
              Row() {
                ForEach(SMART_SUGGESTIONS, (item: AgentSuggestionSpec) => {
                  Text(item.label)
                    .fontSize(12)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.primaryText())
                    .padding({ left: 14, right: 14, top: 10, bottom: 10 })
                    .backgroundColor(this.glassShellColor())
                    .border({
                      width: 1,
                      color: this.glassBorderColor()
                    })
                    .borderRadius(17)
                    .margin({ right: 8, top: 16 })
                    .scale(this.buttonScale(`chat_suggestion_${item.id}`))
                    .opacity(this.buttonOpacity(`chat_suggestion_${item.id}`))
                    .animation({ duration: 120, curve: Curve.EaseOut })
                    .onTouch((event: TouchEvent) => {
                      this.handlePressState(`chat_suggestion_${item.id}`, event);
                    })
                    .onClick(() => {
                      this.applyAgentSuggestion(item.prompt);
                    })
                }, (item: AgentSuggestionSpec) => item.id)
              }
              .padding({ right: 6 })
            }
            .width('100%')
            .scrollBar(BarState.Off)
            .scrollable(ScrollDirection.Horizontal)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ top: 96, bottom: 12 })
        }

        ForEach(this.chatMessages, (message: AgentMessageSpec) => {
          Row() {
            Column() {
              this.ChatMessageBubble(message)
            }
            .width(message.role === 'user' ? '78%' : '88%')
          }
          .width('100%')
          .justifyContent(message.role === 'user' ? FlexAlign.End : FlexAlign.Start)
          .margin({ top: 12 })
        }, (message: AgentMessageSpec) => message.id)
      }
      .width('100%')
      .padding({
        left: 18,
        right: 18,
        top: 18,
        bottom: 18
      })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  ChatComposer() {
    Column() {
      if (this.agentPrompt.trim().length > 0) {
        Row() {
          Text('草稿')
            .fontSize(10)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(this.glassShellColor())
            .border({
              width: 1,
              color: this.glassBorderColor()
            })
            .borderRadius(10)

          Text(this.previewPromptText())
            .fontSize(11)
            .fontColor(this.secondaryText())
            .margin({ left: 8 })
            .layoutWeight(1)
            .maxLines(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ bottom: 12 })
      }

      Row() {
        Button(this.agentListening ? '停止语音' : '语音')
          .height(40)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .backgroundColor(this.glassShellColor())
          .border({
            width: 1,
            color: this.glassBorderColor()
          })
          .borderRadius(19)
          .padding({ left: 14, right: 14 })
          .scale(this.buttonScale('agent_voice'))
          .opacity(this.buttonOpacity('agent_voice'))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState('agent_voice', event);
          })
          .onClick(() => {
            this.toggleListening();
          })

        TextInput({ placeholder: '输入设备控制指令或自动化需求', text: this.agentPrompt })
          .layoutWeight(1)
          .height(50)
          .fontSize(14)
          .fontColor(this.primaryText())
          .placeholderColor(this.secondaryText())
          .backgroundColor(this.glassShellColor())
          .border({
            width: 1,
            color: this.glassBorderColor()
          })
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .margin({ left: 10 })
          .onChange((value: string) => {
            this.agentPrompt = value;
          })

        Button('发送')
          .height(40)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.inverseText())
          .backgroundColor(this.translucentInverseBg())
          .borderRadius(19)
          .padding({ left: 16, right: 16 })
          .margin({ left: 10 })
          .scale(this.buttonScale('agent_run'))
          .opacity(this.buttonOpacity('agent_run'))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState('agent_run', event);
          })
          .onClick(() => {
            this.runAgentPrompt();
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor(this.glassStrongColor())
    .border({
      width: 1,
      color: this.glassBorderColor()
    })
    .borderRadius(24)
  }

  @Builder
  AutomationComposerCard() {
    Column() {
      Row() {
        Text('脚本草稿')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .layoutWeight(1)

        Button('收起')
          .height(34)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .backgroundColor(this.glassShellColor())
          .border({
            width: 1,
            color: this.glassBorderColor()
          })
          .borderRadius(17)
          .padding({ left: 14, right: 14 })
          .scale(this.buttonScale('composer_close'))
          .opacity(this.buttonOpacity('composer_close'))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState('composer_close', event);
          })
          .onClick(() => {
            this.automationComposerVisible = false;
          })
      }
      .width('100%')

      TextInput({ placeholder: '自动化名称，例如：出门断电', text: this.automationTitle })
        .width('100%')
        .height(44)
        .fontSize(14)
        .fontColor(this.primaryText())
        .placeholderColor(this.secondaryText())
        .backgroundColor(this.glassShellColor())
        .border({
          width: 1,
          color: this.glassBorderColor()
        })
        .borderRadius(18)
        .padding({ left: 16, right: 16 })
        .margin({ top: 14 })
        .onChange((value: string) => {
          this.automationTitle = value;
        })

      TextInput({ placeholder: '触发条件，例如：每天 22:30 或离家定位', text: this.automationTrigger })
        .width('100%')
        .height(44)
        .fontSize(14)
        .fontColor(this.primaryText())
        .placeholderColor(this.secondaryText())
        .backgroundColor(this.glassShellColor())
        .border({
          width: 1,
          color: this.glassBorderColor()
        })
        .borderRadius(18)
        .padding({ left: 16, right: 16 })
        .margin({ top: 10 })
        .onChange((value: string) => {
          this.automationTrigger = value;
        })

      TextInput({ placeholder: '执行动作，例如：关闭客厅电视与空气净化器', text: this.automationAction })
        .width('100%')
        .height(44)
        .fontSize(14)
        .fontColor(this.primaryText())
        .placeholderColor(this.secondaryText())
        .backgroundColor(this.glassShellColor())
        .border({
          width: 1,
          color: this.glassBorderColor()
        })
        .borderRadius(18)
        .padding({ left: 16, right: 16 })
        .margin({ top: 10 })
        .onChange((value: string) => {
          this.automationAction = value;
        })

      Button('保存自动化')
        .width('100%')
        .height(42)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.inverseText())
        .backgroundColor(this.translucentInverseBg())
        .borderRadius(16)
        .margin({ top: 14 })
        .scale(this.buttonScale('automation_save'))
        .opacity(this.buttonOpacity('automation_save'))
        .animation({ duration: 120, curve: Curve.EaseOut })
        .onTouch((event: TouchEvent) => {
          this.handlePressState('automation_save', event);
        })
        .onClick(() => {
          this.addManualAutomation();
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(this.glassShellColor())
    .border({
      width: 1,
      color: this.lineColor()
    })
    .borderRadius(18)
    .margin({ bottom: 10 })
  }

  @Builder
  SmartPage() {
    Column() {
      this.ScriptHeaderCard()
      this.ChatSurface()

      if (this.automationComposerVisible) {
        this.AutomationComposerCard()
      }

      this.ChatComposer()
    }
    .width('100%')
    .height('100%')
    .padding({ left: 14, right: 14, top: 8, bottom: 102 })
  }

  @Builder
  EmptyPage() {
    Column() {
      Text(this.activeTab === 'store' ? '商场页面建设中' : '我的页面建设中')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())

      Text('当前先保留空白页，后续可以继续扩展完整功能。')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(this.secondaryText())
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ left: 28, right: 28, bottom: 90 })
  }

  @Builder
  PageAtmosphere() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.bgColor())

      Column()
        .width(460)
        .height(280)
        .borderRadius(160)
        .backgroundColor(this.atmosphereCoolColor())
        .opacity(this.isNight ? 0.22 : 0.94)
        .position({ x: -80, y: -50 })

      Column()
        .width(560)
        .height(340)
        .borderRadius(200)
        .backgroundColor(this.atmosphereWarmColor())
        .opacity(this.isNight ? 0.18 : 0.78)
        .position({ x: 24, y: 520 })
    }
    .width('100%')
    .height('100%')
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
    Column() {
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
          .height(54)
          .justifyContent(FlexAlign.Center)
          .borderRadius(18)
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
      .height(74)
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })
      .backgroundColor(this.glassStrongColor())
      .border({
        width: 1,
        color: this.glassBorderColor()
      })
      .borderRadius(30)
    }
    .width('100%')
    .padding({ left: 18, right: 18, bottom: 18 })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      this.PageAtmosphere()

      if (this.activeTab === 'home') {
        this.HomePage()
      } else if (this.activeTab === 'smart') {
        this.SmartPage()
      } else {
        this.EmptyPage()
      }

      this.BottomNav()

      if (this.activeTab === 'home') {
        this.OverlayPanel()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#00000000')
  }
}
