import router from '@ohos.router';
import { DeviceDetailPages } from '../components/DeviceDetailPages';
import { P31_StoreHome } from './store/storehome';
import { P21_MyProfile } from './my/myprofile';
import {
  AgentMessageSpec,
  AgentRecordSpec,
  AutomationSpec,
  DEFAULT_AGENT_MESSAGES,
  DEFAULT_AGENT_RECORDS,
  DEFAULT_AUTOMATIONS
} from '../smart/SmartModels';
import {
  createDraftActions,
  createManualTriggerSpec
} from '../smart/SmartPromptParser';
import { resolveSmartAssistantPrompt } from '../smart/SmartAssistantService';

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
  templateId?: string;
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
  baseId?: string;
}

interface RoomDeviceState {
  roomId: string;
  pointIds: string[];
}

interface IndexRouteParams {
  activeTab?: string;
  isNight?: boolean;
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

const SCENE_TEMPLATES: SceneSpec[] = [
  { id: 'morning', label: '早安', detail: '开帘与日间', badge: '晨', baseId: 'morning' },
  { id: 'arrive', label: '回家', detail: '灯光与空气', badge: '家', baseId: 'arrive' },
  { id: 'movie', label: '观影', detail: '客厅联动', badge: '影', baseId: 'movie' },
  { id: 'sleep', label: '睡眠', detail: '夜间静音', badge: '夜', baseId: 'sleep' }
];

const INITIAL_SCENES: SceneSpec[] = SCENE_TEMPLATES;

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

const INITIAL_ROOM_DEVICES: RoomDeviceState[] = [
  {
    roomId: 'living',
    pointIds: ['living_air', 'living_curtain', 'living_tv', 'living_purifier', 'living_robot', 'living_light']
  },
  {
    roomId: 'bedroom',
    pointIds: ['bedroom_air', 'bedroom_curtain', 'bedroom_left_light', 'bedroom_right_light', 'bedroom_robot', 'bedroom_door']
  }
];

@Entry
@Component
struct Index {
  @State activeTab: string = 'home';
  @State rooms: RoomSpec[] = INITIAL_ROOMS;
  @State activeRoomId: string = 'living';
  @State homeRoomSwiperIndex: number = 0;
  @State scenes: SceneSpec[] = INITIAL_SCENES;
  @State activeSceneId: string = 'morning';
  @State agentPrompt: string = '';
  @State agentListening: boolean = false;
  @State agentThinking: boolean = false;
  @State smartHubExpanded: boolean = false;
  @State smartFloatX: number = 232;
  @State smartFloatY: number = 128;
  @State smartFloatStartX: number = 232;
  @State smartFloatStartY: number = 128;
  @State smartFloatMoved: boolean = false;
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
  @State addScenePanelVisible: boolean = false;
  @State devicePanelMode: string = '';
  @State customRoomName: string = '';
  @State customSceneName: string = '';
  @State customSceneDetail: string = '';
  @State selectedSceneTemplateId: string = 'morning';
  @State roomDevices: RoomDeviceState[] = INITIAL_ROOM_DEVICES;
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
    const params = router.getParams() as IndexRouteParams;
    if (params.activeTab !== undefined) {
      this.activeTab = params.activeTab;
    }
    if (params.isNight !== undefined) {
      this.isNight = params.isNight;
      this.manualPeriod = true;
    } else {
      this.applyAutoPeriod();
    }
    try {
      this.clockTimer = setInterval(() => {
        if (!this.manualPeriod) {
          this.applyAutoPeriod();
        }
      }, 60000);
    } catch {
      this.clockTimer = -1;
    }
  }

  aboutToDisappear(): void {
    if (this.clockTimer >= 0) {
      try {
        clearInterval(this.clockTimer);
      } catch {
      }
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

  private roomTemplateId(roomId: string): string {
    const room = this.roomById(roomId);
    return room.templateId !== undefined ? room.templateId : room.id;
  }

  private activeTemplateRoomId(): string {
    return this.roomTemplateId(this.activeRoomId);
  }

  private templateControllablePoints(roomId: string): PointSpec[] {
    const templateId = this.roomTemplateId(roomId);
    return POINTS.filter((point: PointSpec) => point.roomId === templateId && point.action !== 'info');
  }

  private installedPointIds(roomId: string): string[] {
    for (let i = 0; i < this.roomDevices.length; i++) {
      if (this.roomDevices[i].roomId === roomId) {
        return this.roomDevices[i].pointIds;
      }
    }
    return [];
  }

  private setInstalledPointIds(roomId: string, pointIds: string[]): void {
    let matched = false;
    const nextRoomDevices: RoomDeviceState[] = this.roomDevices.map((item: RoomDeviceState) => {
      if (item.roomId === roomId) {
        matched = true;
        return {
          roomId: item.roomId,
          pointIds: pointIds
        };
      }
      return item;
    });
    this.roomDevices = matched ? nextRoomDevices : [...nextRoomDevices, { roomId: roomId, pointIds: pointIds }];
  }

  private pointsForActiveRoom(): PointSpec[] {
    return this.pointsForRoom(this.activeRoomId);
  }

  private pointsForRoom(roomId: string): PointSpec[] {
    const installedIds = this.installedPointIds(roomId);
    return this.templateControllablePoints(roomId).filter((point: PointSpec) => installedIds.indexOf(point.id) >= 0);
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
    const templateId = this.activeTemplateRoomId();
    if (templateId === 'living') {
      return this.livingLightOn;
    }
    if (templateId === 'bedroom') {
      return this.bedroomLightOn;
    }
    return false;
  }

  private setActiveLight(value: boolean): void {
    const templateId = this.activeTemplateRoomId();
    if (templateId === 'living') {
      this.livingLightOn = value;
      return;
    }
    if (templateId === 'bedroom') {
      this.bedroomLightOn = value;
    }
  }

  private lightOnForRoom(roomId: string): boolean {
    const templateId = this.roomTemplateId(roomId);
    if (templateId === 'living') {
      return this.livingLightOn;
    }
    if (templateId === 'bedroom') {
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
    // 只调整白天主按钮高亮，夜间颜色保持组长已定的原样。
    return this.isNight ? '#324763' : '#5F7DFF';
  }

  private translucentPanelColor(): string {
    return this.isNight ? '#8C171A1F' : '#BFEFF2F7';
  }

  private translucentCardColor(): string {
    return this.isNight ? '#661F232A' : '#B8FFFFFF';
  }

  private translucentInverseBg(): string {
    // 只调整白天浮层主按钮高亮，夜间颜色保持组长已定的原样。
    return this.isNight ? '#D9324763' : '#E05F7DFF';
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
    return this.isNight ? '#EEF4FF' : '#F8FAFF';
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

  private clampSmartFloatX(value: number): number {
    if (value < 12) {
      return 12;
    }
    if (value > 252) {
      return 252;
    }
    return value;
  }

  private clampSmartFloatY(value: number): number {
    if (value < 86) {
      return 86;
    }
    if (value > 520) {
      return 520;
    }
    return value;
  }

  private snapSmartFloat(): void {
    this.smartFloatX = this.smartFloatX < 132 ? 12 : 252;
    this.smartFloatY = this.clampSmartFloatY(this.smartFloatY);
  }

  private overlayPanelHeight(): number {
    // 设备详情页比普通气泡高，外层 Scroll 需要单独放大，否则底部会被裁掉。
    if (this.detailPointId.length > 0) {
      return 536;
    }
    return this.panelViewportHeight();
  }

  private percent(value: number): string {
    return `${value}%`;
  }

  private pointStatus(point: PointSpec): string {
    if (point.action === 'light') {
      return this.activeLightOn() ? `已开 · ${this.activeTemplateRoomId() === 'living' ? this.livingLightLevel : this.bedroomLightLevel}%` : '已关闭';
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
    this.addScenePanelVisible = false;
    this.devicePanelMode = '';
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
      this.addScenePanelVisible = false;
      this.devicePanelMode = '';
      return;
    }
    this.selectRoom(this.rooms[index].id);
  }

  private onAddRoomSwiperPage(): boolean {
    return this.homeRoomSwiperIndex >= this.rooms.length;
  }

  private selectPoint(pointId: string): void {
    this.selectedPointId = pointId;
    this.detailPointId = pointId;
    this.addRoomPanelVisible = false;
    this.addScenePanelVisible = false;
    this.devicePanelMode = '';
    this.selectionVersion++;
  }

  private openAddRoomPanel(): void {
    this.selectedPointId = '';
    this.detailPointId = '';
    this.devicePanelMode = '';
    this.addScenePanelVisible = false;
    this.addRoomPanelVisible = true;
    this.selectionVersion++;
  }

  private openAddScenePanel(): void {
    this.selectedPointId = '';
    this.detailPointId = '';
    this.addRoomPanelVisible = false;
    this.devicePanelMode = '';
    this.addScenePanelVisible = true;
    this.customSceneName = '';
    this.customSceneDetail = '';
    this.selectedSceneTemplateId = this.sceneBaseId(this.activeSceneId);
    this.selectionVersion++;
  }

  private openDevicePanel(mode: string): void {
    this.selectedPointId = '';
    this.detailPointId = '';
    this.addRoomPanelVisible = false;
    this.addScenePanelVisible = false;
    this.devicePanelMode = mode;
    this.selectionVersion++;
  }

  private closeOverlayPanel(): void {
    this.selectedPointId = '';
    this.detailPointId = '';
    this.addRoomPanelVisible = false;
    this.addScenePanelVisible = false;
    this.devicePanelMode = '';
    this.selectionVersion++;
  }

  private addPresetScene(sceneId: string): void {
    const template = this.sceneTemplateById(sceneId);
    const nextScene: SceneSpec = {
      id: `${sceneId}_${new Date().getTime()}`,
      label: this.nextSceneLabel(sceneId),
      detail: template.detail,
      badge: template.badge,
      baseId: sceneId
    };
    this.scenes = [...this.scenes, nextScene];
    this.activeSceneId = nextScene.id;
    this.applyScene(nextScene.id);
    this.addScenePanelVisible = false;
  }

  private addCustomScene(): void {
    const name = this.customSceneName.trim();
    if (name.length === 0) {
      return;
    }
    const template = this.selectedSceneTemplate();
    const nextScene: SceneSpec = {
      id: `custom_scene_${new Date().getTime()}`,
      label: name,
      detail: this.sceneDraftDetailValue(),
      badge: template.badge,
      baseId: template.id
    };
    this.scenes = [...this.scenes, nextScene];
    this.activeSceneId = nextScene.id;
    this.applyScene(nextScene.id);
    this.customSceneName = '';
    this.customSceneDetail = '';
    this.addScenePanelVisible = false;
  }

  private presetRoomCount(templateId: string): number {
    let count = 0;
    for (let i = 0; i < this.rooms.length; i++) {
      if (this.roomTemplateId(this.rooms[i].id) === templateId) {
        count++;
      }
    }
    return count;
  }

  private nextPresetRoomName(room: RoomSpec): string {
    const count = this.presetRoomCount(room.id);
    return count > 0 ? `${room.name} ${count + 1}` : room.name;
  }

  private addPresetRoom(roomId: string): void {
    for (let i = 0; i < ROOMS.length; i++) {
      if (ROOMS[i].id === roomId) {
        const room = ROOMS[i];
        const nextIndex = this.rooms.length;
        const instanceId = `${room.id}_${new Date().getTime()}`;
        const newRoom: RoomSpec = {
          id: instanceId,
          name: this.nextPresetRoomName(room),
          subtitle: room.subtitle,
          templateId: room.id,
          images: room.images,
          preset: room.preset
        };
        this.rooms = [...this.rooms, newRoom];
        this.roomDevices = [...this.roomDevices, { roomId: instanceId, pointIds: [] }];
        this.activeRoomId = instanceId;
        this.homeRoomSwiperIndex = nextIndex;
        this.addRoomPanelVisible = false;
        this.addScenePanelVisible = false;
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
    this.roomDevices = [...this.roomDevices, { roomId: customId, pointIds: [] }];
    this.activeRoomId = customId;
    this.homeRoomSwiperIndex = nextIndex;
    this.customRoomName = '';
    this.addRoomPanelVisible = false;
    this.addScenePanelVisible = false;
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
    this.addScenePanelVisible = false;
    this.devicePanelMode = '';
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
      if (this.activeTemplateRoomId() === 'living') {
        this.livingLightLevel = Math.min(Math.max(this.livingLightLevel + delta * 10, 1), 100);
      } else {
        this.bedroomLightLevel = Math.min(Math.max(this.bedroomLightLevel + delta * 10, 1), 100);
      }
    }
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
      return this.activeTemplateRoomId() === 'living' ? this.livingLightLevel : this.bedroomLightLevel;
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
      if (this.activeTemplateRoomId() === 'living') {
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
    const templateId = this.activeTemplateRoomId();
    if (templateId === 'living') {
      return this.livingLightLevel;
    }
    if (templateId === 'bedroom') {
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
    const templateId = this.activeTemplateRoomId();
    if (templateId === 'living') {
      return `${this.livingTemperature}°C`;
    }
    if (templateId === 'bedroom') {
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
    if (this.activeTemplateRoomId() === 'bedroom') {
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

  private sceneById(sceneId: string): SceneSpec {
    for (let i = 0; i < this.scenes.length; i++) {
      if (this.scenes[i].id === sceneId) {
        return this.scenes[i];
      }
    }
    return this.scenes[0];
  }

  private sceneBaseId(sceneId: string): string {
    const scene = this.sceneById(sceneId);
    return scene.baseId !== undefined ? scene.baseId : scene.id;
  }

  private sceneTemplateById(sceneId: string): SceneSpec {
    for (let i = 0; i < SCENE_TEMPLATES.length; i++) {
      if (SCENE_TEMPLATES[i].id === sceneId) {
        return SCENE_TEMPLATES[i];
      }
    }
    return SCENE_TEMPLATES[0];
  }

  private sceneTemplateCount(sceneId: string): number {
    let count = 0;
    for (let i = 0; i < this.scenes.length; i++) {
      if (this.sceneBaseId(this.scenes[i].id) === sceneId) {
        count++;
      }
    }
    return count;
  }

  private nextSceneLabel(sceneId: string): string {
    const template = this.sceneTemplateById(sceneId);
    const count = this.sceneTemplateCount(sceneId);
    return count > 0 ? `${template.label} ${count + 1}` : template.label;
  }

  private sceneTint(sceneId: string): string {
    const baseId = this.sceneBaseId(sceneId);
    if (baseId === 'morning') {
      return '#F4C94A';
    }
    if (baseId === 'arrive') {
      return '#D6A96D';
    }
    if (baseId === 'movie') {
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
    const baseId = this.sceneBaseId(sceneId);
    if (baseId === 'morning') {
      this.isNight = false;
      this.livingCurtain = 82;
      this.bedroomCurtain = 68;
      this.livingLightOn = false;
      this.bedroomLightOn = false;
      this.livingTvOn = false;
      this.bedroomDoorLocked = true;
      return;
    }
    if (baseId === 'arrive') {
      this.isNight = false;
      this.livingLightOn = true;
      this.livingLightLevel = 76;
      this.livingPurifierOn = true;
      this.bedroomDoorLocked = false;
      return;
    }
    if (baseId === 'movie') {
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
    const count = this.pointsForRoom(roomId).length;
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
    const count = this.pointsForRoom(roomId).length;
    return count > 0 ? '滑动来切换房间' : '这个房间还没有关联设备';
  }

  private selectedSceneTemplate(): SceneSpec {
    return this.sceneTemplateById(this.selectedSceneTemplateId);
  }

  private sceneDraftDetailValue(): string {
    const value = this.customSceneDetail.trim();
    if (value.length > 0) {
      return value;
    }
    return this.selectedSceneTemplate().detail;
  }

  private panelViewportHeight(): number {
    return 268;
  }

  private overlayVisible(): boolean {
    // selectedPointId 只保留地图点高亮，不再触发快捷气泡弹层。
    return this.addRoomPanelVisible || this.addScenePanelVisible || this.devicePanelMode.length > 0 || this.detailPointId.length > 0;
  }

  private availablePresetRooms(): RoomSpec[] {
    return ROOMS;
  }

  private controllablePoints(): PointSpec[] {
    return this.pointsForActiveRoom();
  }

  private availableDevicesForActiveRoom(): PointSpec[] {
    const installedIds = this.installedPointIds(this.activeRoomId);
    return this.templateControllablePoints(this.activeRoomId).filter((point: PointSpec) => installedIds.indexOf(point.id) < 0);
  }

  private canAddDeviceInActiveRoom(): boolean {
    return this.availableDevicesForActiveRoom().length > 0;
  }

  private canRemoveDeviceInActiveRoom(): boolean {
    return this.controllablePoints().length > 0;
  }

  private addDeviceToActiveRoom(pointId: string): void {
    const installedIds = this.installedPointIds(this.activeRoomId);
    if (installedIds.indexOf(pointId) >= 0) {
      return;
    }
    this.setInstalledPointIds(this.activeRoomId, [...installedIds, pointId]);
    this.selectionVersion++;
  }

  private removeDeviceFromActiveRoom(pointId: string): void {
    const nextInstalledIds = this.installedPointIds(this.activeRoomId).filter((id: string) => id !== pointId);
    this.setInstalledPointIds(this.activeRoomId, nextInstalledIds);
    if (this.selectedPointId === pointId) {
      this.selectedPointId = '';
    }
    if (this.detailPointId === pointId) {
      this.detailPointId = '';
    }
    this.selectionVersion++;
  }

  private devicePanelPoints(): PointSpec[] {
    return this.devicePanelMode === 'add' ? this.availableDevicesForActiveRoom() : this.controllablePoints();
  }

  private devicePanelTitle(): string {
    return this.devicePanelMode === 'add' ? '添加设备' : '删除设备';
  }

  private devicePanelHint(): string {
    return this.devicePanelMode === 'add' ? '添加后会同步出现在 2.5D 图里' : '删除后会同时从设备区和 2.5D 图中移除';
  }

  private devicePanelEmptyText(): string {
    return this.devicePanelMode === 'add' ? '当前房间没有可继续添加的设备' : '当前房间还没有可删除的设备';
  }

  private devicePanelActionLabel(): string {
    return this.devicePanelMode === 'add' ? '添加' : '删除';
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

  private async runAgentPrompt(): Promise<void> {
    const prompt = this.agentPrompt.trim();
    if (prompt.length === 0) {
      this.appendAgentRecord('请输入指令', '智能助手需要明确的文字或语音指令才能生成执行方案。', '建议');
      this.pushChatMessage('agent', '先告诉我你想执行什么，我再帮你生成动作或脚本。', '等待指令');
      return;
    }
    this.pushChatMessage('user', prompt, '刚刚');
    this.agentPrompt = '';
    this.agentThinking = true;
    try {
      const reply = await resolveSmartAssistantPrompt(prompt);
      if (reply.draft !== undefined && reply.draft.shouldCreateAutomation) {
        const draft = reply.draft;
        this.automations = [
          {
            id: `auto_${new Date().getTime()}`,
            title: draft.title,
            trigger: draft.trigger,
            action: draft.action,
            source: 'agent',
            enabled: true,
            triggerSpec: draft.triggerSpec,
            actions: draft.actions
          },
          ...this.automations
        ];
      }
      const recordDetail = reply.draft !== undefined ? reply.draft.action : reply.detail;
      const recordStatus = reply.ok ? (reply.mode === 'llm' ? '回答' : '已执行') : '未连接';
      this.appendAgentRecord(reply.title, recordDetail, recordStatus);
      this.pushChatMessage('agent', reply.detail, reply.title);
    } catch {
      this.appendAgentRecord('助手请求失败', '请检查网络连接、DeepSeek API Key 或稍后再试。', '错误');
      this.pushChatMessage('agent', '请求失败：请检查网络连接、DeepSeek API Key 或稍后再试。', '错误');
    } finally {
      this.agentThinking = false;
    }
  }

  private openAutomationComposer(): void {
    this.expandedAutomationId = '';
    this.automationTitle = '';
    this.automationTrigger = '';
    this.automationAction = '';
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
        triggerSpec: createManualTriggerSpec(trigger),
        actions: createDraftActions(action)
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

  private enabledAutomationCount(): number {
    let count = 0;
    for (let i = 0; i < this.automations.length; i++) {
      if (this.automations[i].enabled) {
        count++;
      }
    }
    return count;
  }

  private automationActionCount(item: AutomationSpec): number {
    if (item.actions.length === 1 && item.actions[0].command === 'draft') {
      return 0;
    }
    return item.actions.length;
  }

  private smartHeaderStatus(): string {
    if (this.agentRecords.length > 0) {
      return this.agentRecords[0].title;
    }
    return '智能中枢运行中';
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
              this.ToneBadge(chip.badge, this.chipTint(chip.id), 28)

              Column() {
                Text(chip.label)
                  .fontSize(11)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.secondaryText())

                Text(chip.value)
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.primaryText())
                  .margin({ top: 2 })
                  .maxLines(1)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 8 })
            }
            .width('100%')
          }
          .width(138)
          .height(68)
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .backgroundColor(this.glassShellColor())
          .border({
            width: 1,
            color: this.glassBorderColor()
          })
          .borderRadius(15)
          .margin({ right: 8 })
        }, (chip: SummaryChipSpec) => chip.id)
      }
      .padding({ right: 8 })
    }
    .width('100%')
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Horizontal)
    .margin({ top: 14 })
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
          ForEach(this.scenes, (scene: SceneSpec) => {
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
            .width(154)
            .height(88)
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

          Row() {
            this.ToneBadge('+', this.chipTint('devices'), 32)

            Column() {
              Text('添加场景')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.primaryText())

              Text('继续扩展')
                .fontSize(11)
                .fontColor(this.secondaryText())
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 10, right: 10 })

            Text('+')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.primaryText())
          }
          .padding({ left: 12, right: 14, top: 12, bottom: 12 })
          .backgroundColor(this.glassShellColor())
          .border({
            width: 1,
            color: this.glassBorderColor()
          })
          .borderRadius(18)
          .margin({ right: 10 })
          .width(154)
          .height(88)
          .scale(this.buttonScale('scene_add_entry'))
          .opacity(this.buttonOpacity('scene_add_entry'))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState('scene_add_entry', event);
          })
          .onClick(() => {
            this.openAddScenePanel();
          })
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

      Row() {
        Button('添加设备')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .backgroundColor(this.glassShellColor())
          .border({
            width: 1,
            color: this.glassBorderColor()
          })
          .borderRadius(22)
          .opacity(this.canAddDeviceInActiveRoom() ? this.buttonOpacity('device_add_entry') : 0.36)
          .scale(this.canAddDeviceInActiveRoom() ? this.buttonScale('device_add_entry') : { x: 1, y: 1 })
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            if (this.canAddDeviceInActiveRoom()) {
              this.handlePressState('device_add_entry', event);
            }
          })
          .onClick(() => {
            if (this.canAddDeviceInActiveRoom()) {
              this.openDevicePanel('add');
            }
          })

        Button('删除设备')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.inverseText())
          .backgroundColor(this.translucentInverseBg())
          .borderRadius(22)
          .margin({ left: 10 })
          .opacity(this.canRemoveDeviceInActiveRoom() ? this.buttonOpacity('device_remove_entry') : 0.36)
          .scale(this.canRemoveDeviceInActiveRoom() ? this.buttonScale('device_remove_entry') : { x: 1, y: 1 })
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            if (this.canRemoveDeviceInActiveRoom()) {
              this.handlePressState('device_remove_entry', event);
            }
          })
          .onClick(() => {
            if (this.canRemoveDeviceInActiveRoom()) {
              this.openDevicePanel('remove');
            }
          })
      }
      .width('100%')
      .margin({ top: 16 })

      Text(this.canAddDeviceInActiveRoom() || this.canRemoveDeviceInActiveRoom() ? '设备白点会和这里的增删保持同步' : '当前房间还没有预设可管理设备')
        .fontSize(12)
        .fontColor(this.secondaryText())
        .margin({ top: 10 })
    }
    .width('100%')
  }


  @Builder
  DeviceManagePanel() {
    Column() {
      Row() {
        Column() {
          Text(this.devicePanelTitle())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())

          Text(this.devicePanelHint())
            .fontSize(12)
            .fontColor(this.secondaryText())
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Button('关闭')
          .height(34)
          .fontSize(12)
          .fontColor(this.primaryText())
          .backgroundColor(this.translucentCardColor())
          .borderRadius(17)
          .scale(this.buttonScale('device_panel_close'))
          .opacity(this.buttonOpacity('device_panel_close'))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState('device_panel_close', event);
          })
          .onClick(() => {
            this.closeOverlayPanel();
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      if (this.devicePanelPoints().length > 0) {
        Column() {
          ForEach(this.devicePanelPoints(), (point: PointSpec) => {
            Row() {
              Column() {
                Text(point.name)
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.primaryText())

                Text(point.type)
                  .fontSize(11)
                  .fontColor(this.secondaryText())
                  .margin({ top: 3 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Button(this.devicePanelActionLabel())
                .height(36)
                .fontSize(12)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.devicePanelMode === 'add' ? this.inverseText() : this.primaryText())
                .backgroundColor(this.devicePanelMode === 'add' ? this.translucentInverseBg() : this.translucentCardColor())
                .border({
                  width: 1,
                  color: this.devicePanelMode === 'add' ? this.glassBorderColor() : this.lineColor()
                })
                .borderRadius(18)
                .padding({ left: 16, right: 16 })
                .scale(this.buttonScale(`${this.devicePanelMode}_${point.id}`))
                .opacity(this.buttonOpacity(`${this.devicePanelMode}_${point.id}`))
                .animation({ duration: 120, curve: Curve.EaseOut })
                .onTouch((event: TouchEvent) => {
                  this.handlePressState(`${this.devicePanelMode}_${point.id}`, event);
                })
                .onClick(() => {
                  if (this.devicePanelMode === 'add') {
                    this.addDeviceToActiveRoom(point.id);
                  } else {
                    this.removeDeviceFromActiveRoom(point.id);
                  }
                })
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
          }, (point: PointSpec) => point.id)
        }
        .width('100%')
        .margin({ top: 10 })
      } else {
        Column() {
          Text(this.devicePanelEmptyText())
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())

          Text('切换房间后可以继续管理当前空间里的设备。')
            .fontSize(12)
            .fontColor(this.secondaryText())
            .margin({ top: 8 })
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 18, bottom: 18 })
        .backgroundColor(this.glassShellColor())
        .border({
          width: 1,
          color: this.glassBorderColor()
        })
        .borderRadius(18)
        .margin({ top: 14 })
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
    .transition(this.overlayTransition())
  }

  @Builder
  DetailPanel(point: PointSpec) {
    DeviceDetailPages({
      detailPointId: $detailPointId,
      pointId: point.id,
      pointName: point.name,
      pointType: point.type,
      pointStatus: this.pointStatus(point),
      pointDetail: point.detail,
      isNight: this.isNight
    })
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
  AddScenePanel() {
    Column() {
      Row() {
        Column() {
          Text('添加场景')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())

          Text('新增后的场景会出现在右侧滑动列表里，并且可以直接执行。')
            .fontSize(12)
            .fontColor(this.secondaryText())
            .margin({ top: 6 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Button('关闭')
          .height(36)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .backgroundColor(this.translucentCardColor())
          .borderRadius(18)
          .scale(this.buttonScale('add_scene_close'))
          .opacity(this.buttonOpacity('add_scene_close'))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.handlePressState('add_scene_close', event);
          })
          .onClick(() => {
            this.closeOverlayPanel();
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 18, bottom: 12 })

      Scroll() {
        Column() {
          Text('快速添加')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())

          Text('选一个场景模板，马上复制出一个同风格场景。')
            .fontSize(12)
            .fontColor(this.secondaryText())
            .margin({ top: 4 })

          Scroll() {
            Row() {
              ForEach(SCENE_TEMPLATES, (scene: SceneSpec) => {
                Column() {
                  this.ToneBadge(scene.badge, this.sceneTint(scene.id), 36)

                  Text(scene.label)
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.primaryText())
                    .margin({ top: 10 })

                  Text(scene.detail)
                    .fontSize(11)
                    .fontColor(this.secondaryText())
                    .margin({ top: 4 })
                    .maxLines(2)

                  Button('添加')
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
                    .padding({ left: 16, right: 16 })
                    .margin({ top: 14 })
                    .scale(this.buttonScale(`scene_preset_${scene.id}`))
                    .opacity(this.buttonOpacity(`scene_preset_${scene.id}`))
                    .animation({ duration: 120, curve: Curve.EaseOut })
                    .onTouch((event: TouchEvent) => {
                      this.handlePressState(`scene_preset_${scene.id}`, event);
                    })
                    .onClick(() => {
                      this.addPresetScene(scene.id);
                    })
                }
                .width(170)
                .height(190)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .padding({ left: 16, right: 16, top: 18, bottom: 18 })
                .backgroundColor(this.glassShellColor())
                .border({
                  width: 1,
                  color: this.glassBorderColor()
                })
                .borderRadius(22)
                .margin({ right: 12 })
              }, (scene: SceneSpec) => scene.id)
            }
            .padding({ right: 8 })
          }
          .width('100%')
          .scrollBar(BarState.Off)
          .scrollable(ScrollDirection.Horizontal)
          .margin({ top: 14 })

          Column() {
            Text('自定义场景')
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.primaryText())

            Text('自己命名，并借用一种现成场景的执行逻辑。')
              .fontSize(12)
              .fontColor(this.secondaryText())
              .margin({ top: 4 })

            Scroll() {
              Row() {
                ForEach(SCENE_TEMPLATES, (scene: SceneSpec) => {
                  Column() {
                    this.ToneBadge(scene.badge, this.sceneTint(scene.id), 30)

                    Text(scene.label)
                      .fontSize(12)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.selectedSceneTemplateId === scene.id ? this.inverseText() : this.primaryText())
                      .margin({ top: 8 })
                  }
                  .width(96)
                  .height(86)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .backgroundColor(this.selectedSceneTemplateId === scene.id ? this.translucentInverseBg() : this.glassShellColor())
                  .border({
                    width: 1,
                    color: this.selectedSceneTemplateId === scene.id ? this.glassBorderColor() : this.lineColor()
                  })
                  .borderRadius(18)
                  .margin({ right: 10 })
                  .scale(this.buttonScale(`scene_template_${scene.id}`))
                  .opacity(this.buttonOpacity(`scene_template_${scene.id}`))
                  .animation({ duration: 120, curve: Curve.EaseOut })
                  .onTouch((event: TouchEvent) => {
                    this.handlePressState(`scene_template_${scene.id}`, event);
                  })
                  .onClick(() => {
                    this.selectedSceneTemplateId = scene.id;
                  })
                }, (scene: SceneSpec) => scene.id)
              }
              .padding({ right: 8 })
            }
            .width('100%')
            .scrollBar(BarState.Off)
            .scrollable(ScrollDirection.Horizontal)
            .margin({ top: 14 })

            TextInput({ placeholder: '场景名称，例如：晚餐模式', text: this.customSceneName })
              .width('100%')
              .height(52)
              .fontSize(15)
              .fontColor(this.primaryText())
              .placeholderColor(this.secondaryText())
              .backgroundColor(this.translucentCardColor())
              .border({
                width: 1,
                color: this.lineColor()
              })
              .borderRadius(18)
              .padding({ left: 16, right: 16 })
              .margin({ top: 16 })
              .onChange((value: string) => {
                this.customSceneName = value;
              })

            TextInput({ placeholder: '补充说明，可为空', text: this.customSceneDetail })
              .width('100%')
              .height(52)
              .fontSize(14)
              .fontColor(this.primaryText())
              .placeholderColor(this.secondaryText())
              .backgroundColor(this.translucentCardColor())
              .border({
                width: 1,
                color: this.lineColor()
              })
              .borderRadius(18)
              .padding({ left: 16, right: 16 })
              .margin({ top: 12 })
              .onChange((value: string) => {
                this.customSceneDetail = value;
              })

            Column() {
              Row() {
                this.ToneBadge(this.selectedSceneTemplate().badge, this.sceneTint(this.selectedSceneTemplateId), 34)

                Column() {
                  Text(this.customSceneName.trim().length > 0 ? this.customSceneName.trim() : '新场景预览')
                    .fontSize(15)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.primaryText())

                  Text(this.sceneDraftDetailValue())
                    .fontSize(12)
                    .fontColor(this.secondaryText())
                    .margin({ top: 4 })
                    .maxLines(2)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })
              }
              .width('100%')
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })
            .backgroundColor(this.glassShellColor())
            .border({
              width: 1,
              color: this.glassBorderColor()
            })
            .borderRadius(20)
            .margin({ top: 16 })

            Button('创建场景')
              .width('100%')
              .height(50)
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.inverseText())
              .backgroundColor(this.translucentInverseBg())
              .borderRadius(22)
              .margin({ top: 18, bottom: 22 })
              .opacity(this.customSceneName.trim().length > 0 ? this.buttonOpacity('create_scene') : 0.36)
              .scale(this.customSceneName.trim().length > 0 ? this.buttonScale('create_scene') : { x: 1, y: 1 })
              .animation({ duration: 120, curve: Curve.EaseOut })
              .onTouch((event: TouchEvent) => {
                if (this.customSceneName.trim().length > 0) {
                  this.handlePressState('create_scene', event);
                }
              })
              .onClick(() => {
                if (this.customSceneName.trim().length > 0) {
                  this.addCustomScene();
                }
              })
          }
          .width('100%')
          .padding({ top: 24 })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 8, bottom: 18 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('92%')
    .backgroundColor(this.panelColor())
    .border({
      width: 1,
      color: this.glassBorderColor()
    })
    .borderRadius({
      topLeft: 30,
      topRight: 30,
      bottomLeft: 0,
      bottomRight: 0
    })
    .clip(true)
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

        if (this.addScenePanelVisible) {
          Column() {
            this.AddScenePanel()
          }
          .width('100%')
          .height('100%')
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.End)
          .backgroundColor('#00000000')
        } else {
          Column() {
            if (this.detailPointId.length > 0) {
              this.DetailPanel(this.pointById(this.detailPointId))
            } else if (this.addRoomPanelVisible) {
              this.AddRoomPanel()
            } else if (this.devicePanelMode.length > 0) {
              this.DeviceManagePanel()
            } else {
              Column()
                .width('100%')
            }
          }
          .width('100%')
          .padding({
            left: 18,
            right: 18,
            bottom: this.detailPointId.length > 0 ? 18 : 118
          })
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.End)
          .backgroundColor('#00000000')
          .transition(this.overlayTransition())
        }
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  HomePage() {
    List() {
      ListItem() {
        Column() {
          this.TopBar()
          this.RoomMap()
        }
        .width('100%')
        .padding({ left: 18, right: 18, top: 28 })
      }

      ListItem() {
        Column() {
          if (!this.onAddRoomSwiperPage()) {
            this.DeviceControls()
          } else {
            Column()
              .width('100%')
              .height(132)
          }
        }
        .width('100%')
        .padding({ left: 18, right: 18, top: 16, bottom: 132 })
      }
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  ScriptHeaderCard() {
    Column() {
      Row() {
        Column() {
          Text('智能中枢')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())

          Text(this.smartHeaderStatus())
            .fontSize(12)
            .fontColor(this.secondaryText())
            .maxLines(1)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Button('新建')
          .height(38)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.inverseText())
          .backgroundColor(this.translucentInverseBg())
          .border({
            width: 1,
            color: this.glassBorderColor()
          })
          .borderRadius(19)
          .padding({ left: 16, right: 16 })
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
      .alignItems(VerticalAlign.Center)

      Row() {
        Column() {
          Text(`${this.enabledAutomationCount()}`)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())

          Text('运行脚本')
            .fontSize(11)
            .fontColor(this.secondaryText())
            .margin({ top: 3 })
        }
        .layoutWeight(1)
        .height(70)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 14, right: 12 })
        .backgroundColor(this.glassShellColor())
        .border({
          width: 1,
          color: this.lineColor()
        })
        .borderRadius(18)

        Column() {
          Text(`${this.automations.length}`)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())

          Text('全部脚本')
            .fontSize(11)
            .fontColor(this.secondaryText())
            .margin({ top: 3 })
        }
        .layoutWeight(1)
        .height(70)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 14, right: 12 })
        .backgroundColor(this.glassShellColor())
        .border({
          width: 1,
          color: this.lineColor()
        })
        .borderRadius(18)
        .margin({ left: 10 })

        Column() {
          Text(`${this.chatMessages.length}`)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())

          Text('对话记录')
            .fontSize(11)
            .fontColor(this.secondaryText())
            .margin({ top: 3 })
        }
        .layoutWeight(1)
        .height(70)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 14, right: 12 })
        .backgroundColor(this.glassShellColor())
        .border({
          width: 1,
          color: this.lineColor()
        })
        .borderRadius(18)
        .margin({ left: 10 })
      }
      .width('100%')
      .margin({ top: 16 })

      Scroll() {
        Row() {
          if (this.automations.length === 0) {
            Column() {
              Text('暂无脚本')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.primaryText())

              Text('可以通过新建或智能助手生成自动化')
                .fontSize(11)
                .fontColor(this.secondaryText())
                .maxLines(1)
                .margin({ top: 6 })
            }
            .width(214)
            .height(112)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Start)
            .padding({ left: 16, right: 16 })
              .backgroundColor(this.glassShellColor())
              .border({
                width: 1,
                color: this.lineColor()
              })
              .borderRadius(18)
          } else {
            ForEach(this.automations.slice(0, 5), (item: AutomationSpec) => {
              Column() {
                Row() {
                  Row() {
                    Column()
                      .width(7)
                      .height(7)
                      .borderRadius(4)
                      .backgroundColor(item.enabled ? this.primaryText() : this.secondaryText())

                    Text(item.enabled ? '运行中' : '已暂停')
                      .fontSize(10)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.primaryText())
                      .margin({ left: 6 })
                  }
                  .height(24)
                  .padding({ left: 9, right: 9 })
                  .backgroundColor(this.translucentCardColor())
                  .border({
                    width: 1,
                    color: this.lineColor()
                  })
                  .borderRadius(12)

                  Text(item.source === 'agent' ? '助手' : '手动')
                    .fontSize(10)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.secondaryText())
                    .layoutWeight(1)
                    .textAlign(TextAlign.End)
                    .maxLines(1)
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)

                Text(item.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.primaryText())
                  .maxLines(1)
                  .margin({ top: 14 })

                Text(item.trigger)
                  .fontSize(12)
                  .fontColor(this.secondaryText())
                  .maxLines(1)
                  .margin({ top: 6 })

                Row() {
                  Text(`${this.automationActionCount(item)} 个动作`)
                    .fontSize(11)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.primaryText())
                    .padding({ left: 9, right: 9, top: 5, bottom: 5 })
                    .backgroundColor(this.glassShellColor())
                    .border({
                      width: 1,
                      color: this.lineColor()
                    })
                    .borderRadius(12)

                  Text('+')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.primaryText())
                    .layoutWeight(1)
                    .textAlign(TextAlign.End)
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)
                .margin({ top: 12 })
              }
              .width(214)
              .height(134)
              .padding({ left: 14, right: 14, top: 14, bottom: 14 })
              .backgroundColor(this.expandedAutomationId === item.id ? this.translucentCardColor() : this.glassShellColor())
              .border({
                width: 1,
                color: this.expandedAutomationId === item.id ? this.glassBorderColor() : this.lineColor()
              })
              .borderRadius(20)
              .margin({ right: 10 })
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
      .width('100%')
      .margin({ top: 12 })
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)

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
  SmartNoticeItem(title: string, detail: string, time: string, tone: string, actionKey: string) {
    Row() {
      Column() {
        Text(tone)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width(36)
      .height(36)
      .borderRadius(18)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(title === '智能助手' ? '#6C86FF' : '#FF9F43')

      Column() {
        Row() {
          Text(title)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())
            .layoutWeight(1)

          Text(time)
            .fontSize(10)
            .fontColor(this.secondaryText())
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Text(detail)
          .fontSize(11)
          .fontColor(this.secondaryText())
          .maxLines(1)
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(58)
    .padding({ left: 12, right: 12 })
    .backgroundColor(this.panelColor())
    .border({
      width: 1,
      color: title === '智能助手' ? '#336C86FF' : '#10000000'
    })
    .borderRadius(18)
    .margin({ top: 8 })
    .scale(this.buttonScale(`notice_${actionKey}`))
    .opacity(this.buttonOpacity(`notice_${actionKey}`))
    .animation({ duration: 120, curve: Curve.EaseOut })
    .onTouch((event: TouchEvent) => {
      this.handlePressState(`notice_${actionKey}`, event);
    })
    .onClick(() => {
      if (actionKey === 'assistant') {
        this.activeTab = 'smart';
      }
    })
  }

  @Builder
  SmartNoticeCenter() {
    Column() {
      Row() {
        Text('消息通知')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .layoutWeight(1)

        Text('全部')
          .fontSize(11)
          .fontColor('#6C86FF')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      this.SmartNoticeItem('智能助手', this.agentThinking ? '正在为你组织回复' : '点击进入智能助手对话', '现在', 'AI', 'assistant')
      this.SmartNoticeItem('场景执行', '智能场景执行记录已同步', '20:15', '场', 'scene')
      this.SmartNoticeItem('设备提醒', '客厅设备状态保持正常', '18:45', '设', 'device')
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor('#E8FFFFFF')
    .border({
      width: 1,
      color: this.glassBorderColor()
    })
    .borderRadius(24)
  }

  @Builder
  ChatMessageBubble(message: AgentMessageSpec) {
    Column() {
      Row() {
        Text(message.role === 'user' ? '你' : '助手')
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .fontColor(message.role === 'user' ? '#F7FAFF' : this.primaryText())
          .padding({ left: 9, right: 9, top: 4, bottom: 4 })
          .backgroundColor(message.role === 'user' ? '#22FFFFFF' : '#F7F9FC')
          .border({
            width: 1,
            color: message.role === 'user' ? '#30FFFFFF' : '#10000000'
          })
          .borderRadius(12)

        Text(message.meta)
          .fontSize(10)
          .fontWeight(FontWeight.Medium)
          .fontColor(message.role === 'user' ? '#DDE6FF' : this.secondaryText())
          .maxLines(1)
          .margin({ left: 8 })
          .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 8 })

      Text(message.text)
        .fontSize(14)
        .lineHeight(23)
        .fontColor(message.role === 'user' ? '#FFFFFF' : this.primaryText())
    }
    .padding({ left: 15, right: 15, top: 13, bottom: 13 })
    .backgroundColor(message.role === 'user' ? '#6C86FF' : this.panelColor())
    .border({
      width: 1,
      color: message.role === 'user' ? '#6680FF' : '#12000000'
    })
    .borderRadius(16)
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ChatSurface() {
    Scroll() {
      Column() {
        if (this.chatMessages.length === 0) {
          Column() {
            Text('开始对话')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.primaryText())

            Text('在下方输入问题或设备控制指令')
              .fontSize(12)
              .fontColor(this.secondaryText())
              .margin({ top: 6 })
          }
          .width('100%')
          .height(160)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }

        ForEach(this.chatMessages, (message: AgentMessageSpec) => {
          Row() {
            Column() {
              this.ChatMessageBubble(message)
            }
            .width(message.role === 'user' ? '72%' : '82%')
          }
          .width('100%')
          .justifyContent(message.role === 'user' ? FlexAlign.End : FlexAlign.Start)
          .margin({ top: 16 })
        }, (message: AgentMessageSpec) => message.id)
      }
      .width('100%')
      .padding({
        left: 10,
        right: 10,
        top: 10,
        bottom: 20
      })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  ChatComposer() {
    Column() {
      if (this.agentThinking) {
        Text('助手正在思考...')
          .fontSize(11)
          .fontColor(this.secondaryText())
          .maxLines(1)
          .width('100%')
          .margin({ bottom: 8, left: 4 })
      }

      Row() {
        Button(this.agentListening ? '停止语音' : '语音')
          .height(40)
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .backgroundColor(this.panelColor())
          .border({
            width: 1,
            color: '#12000000'
          })
          .borderRadius(20)
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

        TextArea({ placeholder: '', text: this.agentPrompt })
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .fontColor(this.primaryText())
          .placeholderColor(this.secondaryText())
          .backgroundColor(this.panelColor())
          .borderRadius(20)
          .padding({ left: 14, right: 14 })
          .margin({ left: 8 })
          .onChange((value: string) => {
            this.agentPrompt = value;
          })

        Button('发送')
          .height(40)
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.inverseText())
          .backgroundColor('#6C86FF')
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .margin({ left: 8 })
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
      .height(58)
      .padding({ left: 8, right: 8 })
      .backgroundColor('#FDFEFF')
      .border({
        width: 1,
        color: '#14000000'
      })
      .borderRadius(29)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 8, bottom: 8 })
    .backgroundColor('#EFFFFFFF')
    .border({
      width: 1,
      color: this.glassBorderColor()
    })
    .borderRadius(30)
  }

  @Builder
  SmartPageTitle() {
    Row() {
      Column() {
        Text('消息中心')
          .fontSize(25)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())

        Text('智能消息与助手入口')
          .fontSize(11)
          .fontColor(this.secondaryText())
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column()
        .width(8)
        .height(8)
        .borderRadius(4)
        .backgroundColor(this.agentThinking ? '#F5A524' : '#31C48D')
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({ left: 4, right: 8, top: 4, bottom: 10 })
  }

  @Builder
  AssistantPageTitle() {
    Row() {
      Button('<')
        .width(36)
        .height(36)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .backgroundColor(this.panelColor())
        .border({
          width: 1,
          color: '#12000000'
        })
        .borderRadius(18)
        .padding({ left: 0, right: 0 })
        .onClick(() => {
          this.activeTab = 'home';
        })

      Column() {
        Text('智能助手')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())

        Text(this.agentThinking ? '正在组织回复' : 'DeepSeek 在线对话')
          .fontSize(11)
          .fontColor(this.secondaryText())
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 10 })

      Column()
        .width(8)
        .height(8)
        .borderRadius(4)
        .backgroundColor(this.agentThinking ? '#F5A524' : '#31C48D')
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({ left: 4, right: 8, top: 4, bottom: 10 })
  }

  @Builder
  SmartHubPanel() {
    Column() {
      this.ScriptHeaderCard()
    }
    .width(288)
    .position({ x: 14, y: 72 })
  }

  @Builder
  SmartHubFloat() {
    Column() {
      Text('AI')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.inverseText())

      Text(`${this.enabledAutomationCount()}/${this.automations.length}`)
        .fontSize(9)
        .fontColor('#CCFFFFFF')
        .margin({ top: 1 })
    }
    .width(56)
    .height(56)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.translucentInverseBg())
    .border({
      width: 1,
      color: this.glassBorderColor()
    })
    .borderRadius(28)
    .scale(this.buttonScale('smart_hub_float'))
    .opacity(this.buttonOpacity('smart_hub_float'))
    .animation({ duration: 120, curve: Curve.EaseOut })
    .position({ x: this.smartFloatX, y: this.smartFloatY })
    .gesture(
      PanGesture()
        .onActionStart(() => {
          this.smartFloatStartX = this.smartFloatX;
          this.smartFloatStartY = this.smartFloatY;
          this.smartFloatMoved = false;
          this.pressedKey = 'smart_hub_float';
        })
        .onActionUpdate((event: GestureEvent) => {
          this.smartFloatX = this.clampSmartFloatX(this.smartFloatStartX + event.offsetX);
          this.smartFloatY = this.clampSmartFloatY(this.smartFloatStartY + event.offsetY);
          if (event.offsetX > 3 || event.offsetX < -3 || event.offsetY > 3 || event.offsetY < -3) {
            this.smartFloatMoved = true;
          }
        })
        .onActionEnd(() => {
          this.snapSmartFloat();
          this.pressedKey = '';
        })
        .onActionCancel(() => {
          this.snapSmartFloat();
          this.pressedKey = '';
        })
    )
    .onClick(() => {
      if (!this.smartFloatMoved) {
        this.smartHubExpanded = !this.smartHubExpanded;
      }
      this.smartFloatMoved = false;
    })
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
      Column() {
        this.AssistantPageTitle()
      }
      .width('100%')
      .margin({ bottom: 8 })

      Column() {
        this.ScriptHeaderCard()
      }
      .width('100%')
      .margin({ bottom: 10 })

      if (this.automationComposerVisible) {
        this.AutomationComposerCard()
      }

      this.ChatSurface()

      this.ChatComposer()
    }
    .width('100%')
    .height('100%')
    .padding({ left: 14, right: 14, top: 14, bottom: 102 })
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
      } else if (this.activeTab === 'store') {
        P31_StoreHome({ isNight: this.isNight })
      } else if (this.activeTab === 'profile') {
        P21_MyProfile({ isNight: this.isNight })
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
