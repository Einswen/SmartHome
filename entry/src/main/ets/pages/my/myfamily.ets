import { safeBack, safeGetParams, safePushUrl } from '../../common/SafeRouter';
import { fetchHomeState, SmartHomeApiResult, SmartHomeState, updateHomeSection } from '../../common/SmartHomeApi';

interface MyFamilyRouteParams {
  isNight?: boolean;
}

interface FamilyMemberSpec {
  id: string;
  name: string;
  role: string;
  status: string;
  accent: string;
}

interface FamilyMemberPreference {
  id: string;
  name: string;
  role: string;
}

interface FamilyPreferences {
  hideGuest?: boolean;
  hasCustomMember?: boolean;
  customMemberName?: string;
  customMemberRole?: string;
  customMembers?: FamilyMemberPreference[];
}

interface FamilyRoomPayload {
  id?: string;
  name?: string;
}

interface FamilyRoomDevicesPayload {
  roomId?: string;
  pointIds?: string[];
}

@Entry
@Component
struct MyFamilyPage {
  @State showEmpty: boolean = false;
  @State inviteVisible: boolean = true;
  @State inviteFailed: boolean = false;
  @State activeHome: string = '我的家庭';
  @State isNight: boolean = false;
  @State hideGuest: boolean = false;
  @State hasCustomMember: boolean = false;
  @State customMemberName: string = '新成员';
  @State customMemberRole: string = '普通成员';
  @State customMembers: FamilyMemberPreference[] = [];
  @State showNewMember: boolean = false;
  @State selectedMemberName: string = '新成员';
  @State selectedMemberRole: string = '普通成员';
  @State syncedRoomCount: number = 0;
  @State syncedDeviceCount: number = 0;
  @State syncedRoomNames: string[] = [];
  @StorageLink('lumiUserSignedIn') signedIn: boolean = false;
  @StorageLink('lumiAuthToken') authToken: string = '';
  @StorageLink('lumiHomeState') homeStateText: string = '';
  private appliedHomeStateText: string = '';
  private familyMutationVersion: number = 0;

  aboutToAppear(): void {
    const params = safeGetParams(this.getUIContext().getRouter()) as MyFamilyRouteParams | undefined;
    if (params && params.isNight !== undefined) {
      this.isNight = params.isNight;
    }
    this.loadFamilyState();
  }

  onPageShow(): void {
    this.loadFamilyState();
  }

  private loadFamilyState(): void {
    if (!this.hasAuthSession()) {
      this.appliedHomeStateText = '';
      this.resetFamilySummary();
      return;
    }
    this.applyStoredHomeState();
    this.loadBackendState();
  }

  private async loadBackendState(): Promise<void> {
    if (this.authToken.trim().length === 0) {
      return;
    }
    const requestVersion = this.familyMutationVersion;
    const result = await fetchHomeState(this.authToken);
    if (!result.ok || result.data === undefined) {
      return;
    }
    this.applyHomeSummary(result.data);
    if (requestVersion !== this.familyMutationVersion) {
      return;
    }
    this.rememberHomeState(result.data);
    this.applyFamilyPreferences(result.data.preferences as FamilyPreferences);
  }

  private applyStoredHomeState(): void {
    if (this.homeStateText.length === 0 || this.homeStateText === this.appliedHomeStateText) {
      return;
    }
    try {
      const state = JSON.parse(this.homeStateText) as SmartHomeState;
      this.appliedHomeStateText = this.homeStateText;
      this.applyHomeSummary(state);
      this.applyFamilyPreferences(state.preferences as FamilyPreferences);
    } catch {
    }
  }

  private rememberHomeState(state: SmartHomeState): void {
    const stateText = JSON.stringify(state);
    this.appliedHomeStateText = stateText;
    this.homeStateText = stateText;
  }

  private rememberSyncedState(result: SmartHomeApiResult<SmartHomeState>): void {
    if (result.ok && result.data !== undefined) {
      this.rememberHomeState(result.data);
    }
  }

  private applyFamilyPreferences(preferences: FamilyPreferences): void {
    this.hideGuest = preferences.hideGuest === undefined ? false : preferences.hideGuest;
    this.hasCustomMember = preferences.hasCustomMember === undefined ? false : preferences.hasCustomMember;
    this.customMemberName = preferences.customMemberName === undefined ? '新成员' : preferences.customMemberName;
    this.customMemberRole = preferences.customMemberRole === undefined ? '普通成员' : preferences.customMemberRole;
    if (preferences.customMembers !== undefined) {
      this.customMembers = this.validMemberPreferences(preferences.customMembers);
    } else if (this.hasCustomMember) {
      this.customMembers = [{
        id: 'legacy_member',
        name: this.customMemberName,
        role: this.customMemberRole
      }];
    } else {
      this.customMembers = [];
    }
  }

  private resetFamilySummary(): void {
    this.syncedRoomCount = 0;
    this.syncedDeviceCount = 0;
    this.syncedRoomNames = [];
  }

  private applyHomeSummary(state: SmartHomeState): void {
    this.syncedRoomCount = this.validRooms(state.rooms).length;
    this.syncedDeviceCount = this.countRoomDevices(state.roomDevices);
    this.syncedRoomNames = this.validRooms(state.rooms).map((room: FamilyRoomPayload) => room.name as string);
  }

  private validRooms(payload: Object[]): FamilyRoomPayload[] {
    const rooms: FamilyRoomPayload[] = [];
    for (let i = 0; i < payload.length; i++) {
      const room = payload[i] as FamilyRoomPayload;
      if (room.id !== undefined && room.name !== undefined && room.name.length > 0) {
        rooms.push(room);
      }
    }
    return rooms;
  }

  private countRoomDevices(payload: Object[]): number {
    let count = 0;
    for (let i = 0; i < payload.length; i++) {
      const item = payload[i] as FamilyRoomDevicesPayload;
      if (item.pointIds !== undefined) {
        count += item.pointIds.length;
      }
    }
    return count;
  }

  private currentPreferences(): FamilyPreferences {
    let preferences: FamilyPreferences = {};
    if (this.homeStateText.length > 0) {
      try {
        const state = JSON.parse(this.homeStateText) as SmartHomeState;
        preferences = state.preferences as FamilyPreferences;
      } catch {
        preferences = {};
      }
    }
    preferences.hideGuest = this.hideGuest;
    preferences.customMembers = this.customMembers;
    preferences.hasCustomMember = this.customMembers.length > 0;
    preferences.customMemberName = this.customMembers.length > 0 ? this.customMembers[0].name : '新成员';
    preferences.customMemberRole = this.customMembers.length > 0 ? this.customMembers[0].role : '普通成员';
    return preferences;
  }

  private syncFamilyPreferences(): void {
    if (!this.hasAuthSession()) {
      return;
    }
    this.familyMutationVersion++;
    this.syncFamilyPreferencesAsync(this.familyMutationVersion);
  }

  private async syncFamilyPreferencesAsync(version: number): Promise<void> {
    const result = await updateHomeSection(this.authToken, 'preferences', this.currentPreferences());
    if (version !== this.familyMutationVersion) {
      return;
    }
    this.rememberSyncedState(result);
    if (result.ok && result.data !== undefined) {
      this.applyFamilyPreferences(result.data.preferences as FamilyPreferences);
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

  private hasAuthSession(): boolean {
    return this.signedIn && this.authToken.trim().length > 0;
  }

  private members(): FamilyMemberSpec[] {
    if (this.showEmpty) {
      return [];
    }
    const nextMembers: FamilyMemberSpec[] = [];
    for (let i = 0; i < this.customMembers.length; i++) {
      nextMembers.push({
        id: this.customMembers[i].id,
        name: this.customMembers[i].name,
        role: this.customMembers[i].role,
        status: '已加入家庭',
        accent: this.memberAccent(i)
      });
    }
    return nextMembers;
  }

  private validMemberPreferences(payload: FamilyMemberPreference[]): FamilyMemberPreference[] {
    const members: FamilyMemberPreference[] = [];
    for (let i = 0; i < payload.length; i++) {
      if (payload[i].id.length > 0 && payload[i].name.length > 0 && payload[i].role.length > 0) {
        members.push(payload[i]);
      }
    }
    return members;
  }

  private memberAccent(index: number): string {
    const colors: string[] = ['#7F72F2', '#19B7A4', '#F3A33A', '#5E8CFF'];
    return colors[index % colors.length];
  }

  private upsertSelectedMember(): void {
    const nextMember: FamilyMemberPreference = {
      id: `member_${new Date().getTime()}_${this.customMembers.length}`,
      name: this.selectedMemberName,
      role: this.selectedMemberRole
    };
    const nextMembers: FamilyMemberPreference[] = [];
    let updated = false;
    for (let i = 0; i < this.customMembers.length; i++) {
      if (this.customMembers[i].name === nextMember.name) {
        nextMembers.push({
          id: this.customMembers[i].id,
          name: nextMember.name,
          role: nextMember.role
        });
        updated = true;
      } else {
        nextMembers.push(this.customMembers[i]);
      }
    }
    if (!updated) {
      nextMembers.push(nextMember);
    }
    this.customMembers = nextMembers;
    this.hasCustomMember = this.customMembers.length > 0;
    this.customMemberName = nextMember.name;
    this.customMemberRole = nextMember.role;
  }

  private removeMember(memberId: string): void {
    this.customMembers = this.customMembers.filter((member: FamilyMemberPreference) => member.id !== memberId);
    this.hasCustomMember = this.customMembers.length > 0;
    this.customMemberName = this.customMembers.length > 0 ? this.customMembers[0].name : '新成员';
    this.customMemberRole = this.customMembers.length > 0 ? this.customMembers[0].role : '普通成员';
  }

  private memberSummaryText(): string {
    const count = this.members().length;
    return count > 0 ? `${count} 位成员` : '待添加成员';
  }

  private homeSummaryText(): string {
    return `${this.syncedRoomCount} 个房间 · ${this.syncedDeviceCount} 台设备 · ${this.memberSummaryText()}`;
  }

  private homeStatusText(): string {
    return this.syncedRoomCount > 0 || this.syncedDeviceCount > 0 ? '已配置' : '待配置';
  }

  private homeStatusColor(): string {
    return this.syncedRoomCount > 0 || this.syncedDeviceCount > 0 ? '#35D27A' : '#F3A33A';
  }

  build() {
    Column() {
      this.TopBar()
      if (this.hasAuthSession()) {
        Scroll() {
          Column() {
            this.HomeCard()
            this.InviteCard()
            this.PermissionCard()
            this.MemberHeader()
            if (this.showNewMember) {
              this.AddMemberPanel()
            }

            if (this.members().length === 0) {
              this.EmptyMemberState()
            } else {
              ForEach(this.members(), (member: FamilyMemberSpec) => {
                this.MemberRow(member)
              }, (member: FamilyMemberSpec) => member.id)
            }
          }
          .width('100%')
          .padding({ left: 18, right: 18, bottom: 28 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      } else {
        this.AuthRequiredState()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor())
  }

  @Builder
  AuthRequiredState() {
    Column() {
      Text('登录后管理家庭')
        .fontSize(21)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())

      Text('家庭成员、权限和共享空间会从账号同步，未登录时不显示示例家庭。')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(this.secondaryText())
        .textAlign(TextAlign.Center)
        .width('78%')
        .margin({ top: 8 })

      Button('去登录')
        .height(40)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#11151D')
        .borderRadius(20)
        .padding({ left: 20, right: 20 })
        .margin({ top: 18 })
        .onClick(() => {
          safePushUrl(this.getUIContext().getRouter(), { url: 'pages/my/mylogin', params: { isNight: this.isNight } });
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ left: 28, right: 28, bottom: 40 })
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

      Text('家庭管理')
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
  HomeCard() {
    Column() {
      Row() {
        Column() {
          Text(this.activeHome)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())
          Text(this.homeSummaryText())
            .fontSize(13)
            .fontColor(this.secondaryText())
            .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.homeStatusText())
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .padding({ left: 12, right: 12, top: 7, bottom: 7 })
          .backgroundColor(this.homeStatusColor())
          .borderRadius(16)
      }
      .width('100%')

      Row() {
        this.HomeChip('我的家庭')
        ForEach(this.syncedRoomNames.slice(0, 3), (name: string) => {
          this.HomeChip(name)
        }, (name: string) => name)
      }
      .width('100%')
      .margin({ top: 18 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 20, right: 20, top: 22, bottom: 22 })
    .linearGradient({ angle: 135, colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#23342D', 1.0]] : [['#E6EEFF', 0.0], ['#B8FFFFFF', 0.58], ['#EAF8F4', 1.0]] })
    .borderRadius(26)
  }

  @Builder
  HomeChip(name: string) {
    Text(name)
      .fontSize(12)
      .fontWeight(this.activeHome === name ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(this.activeHome === name ? (this.isNight ? '#11151D' : '#FFFFFF') : this.primaryText())
      .padding({ left: 13, right: 13, top: 9, bottom: 9 })
      .backgroundColor(this.activeHome === name ? (this.isNight ? '#F5F7FB' : '#11151D') : this.softColor())
      .borderRadius(17)
      .margin({ right: 8 })
      .onClick(() => {
        this.activeHome = name;
      })
  }

  @Builder
  InviteCard() {
    Column() {
      Row() {
        Column() {
          Text('邀请家庭成员')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())
          Text(this.inviteFailed ? '二维码生成失败，请重试。' : '二维码 10 分钟内有效，扫码后需拥有者确认。')
            .fontSize(12)
            .fontColor(this.inviteFailed ? '#D35B4B' : this.secondaryText())
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Button(this.inviteFailed ? '重试' : this.inviteVisible ? '隐藏' : '生成')
          .height(36)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isNight ? '#11151D' : '#FFFFFF')
          .backgroundColor(this.inviteFailed ? '#D35B4B' : (this.isNight ? '#F5F7FB' : '#11151D'))
          .borderRadius(18)
          .padding({ left: 14, right: 14 })
          .onClick(() => {
            if (this.inviteFailed) {
              this.inviteFailed = false;
              this.inviteVisible = true;
            } else {
              this.inviteVisible = !this.inviteVisible;
            }
          })
      }
      .width('100%')

      if (this.inviteVisible && !this.inviteFailed) {
        Row() {
          this.QrMock()
          Column() {
            Text('LUMI-FAMILY-0428')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.primaryText())
            Text(`扫码后加入“${this.activeHome}”，默认访客权限，可由拥有者调整。`)
              .fontSize(12)
              .lineHeight(19)
              .fontColor(this.secondaryText())
              .margin({ top: 8 })
            Button('模拟失败')
              .height(32)
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor('#D35B4B')
              .backgroundColor(this.isNight ? '#33D35B4B' : '#FFF1EF')
              .borderRadius(16)
              .padding({ left: 12, right: 12 })
              .margin({ top: 12 })
              .onClick(() => {
                this.inviteFailed = true;
              })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 14 })
        }
        .width('100%')
        .margin({ top: 16 })
      }
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 14 })
  }

  @Builder
  QrMock() {
    Column() {
      Row() {
        this.QrCell(true)
        this.QrCell(false)
        this.QrCell(true)
        this.QrCell(true)
        this.QrCell(false)
      }
      Row() {
        this.QrCell(true)
        this.QrCell(false)
        this.QrCell(true)
        this.QrCell(false)
        this.QrCell(true)
      }
      Row() {
        this.QrCell(false)
        this.QrCell(true)
        this.QrCell(true)
        this.QrCell(false)
        this.QrCell(true)
      }
      Row() {
        this.QrCell(true)
        this.QrCell(true)
        this.QrCell(false)
        this.QrCell(false)
        this.QrCell(true)
      }
      Row() {
        this.QrCell(false)
        this.QrCell(true)
        this.QrCell(true)
        this.QrCell(false)
        this.QrCell(true)
      }
    }
    .width(86)
    .height(86)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: '#16000000' })
    .borderRadius(18)
  }

  @Builder
  QrCell(filled: boolean) {
    Column()
      .width(10)
      .height(10)
      .backgroundColor(filled ? '#11151D' : '#FFFFFF')
      .margin({ left: 2, right: 2, top: 2, bottom: 2 })
  }

  @Builder
  PermissionCard() {
    Row() {
      this.PermissionItem('远程控制', '管理员可用')
      this.PermissionItem('设备新增', '拥有者确认')
      this.PermissionItem('访客模式', '限时开放')
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 12, bottom: 12 })
    .backgroundColor(this.cardColor())
    .borderRadius(22)
    .margin({ top: 14 })
  }

  @Builder
  PermissionItem(title: string, desc: string) {
    Column() {
      Text(title)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .maxLines(1)
      Text(desc)
        .fontSize(11)
        .fontColor(this.secondaryText())
        .margin({ top: 5 })
        .maxLines(1)
    }
    .layoutWeight(1)
    .height(58)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  MemberHeader() {
    Row() {
      Text('成员与权限')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .layoutWeight(1)

      Button(this.showEmpty ? '恢复' : '添加成员')
        .height(32)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5E8CFF')
        .backgroundColor(this.isNight ? '#335E8CFF' : '#EAF0FF')
        .borderRadius(16)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          this.showEmpty = false;
          this.showNewMember = !this.showNewMember;
        })
    }
    .width('100%')
    .margin({ top: 22, bottom: 10 })
  }

  @Builder
  AddMemberPanel() {
    Column() {
      Text('选择成员')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
      Row() {
        this.MemberOptionChip('妈妈', 'name')
        this.MemberOptionChip('爸爸', 'name')
        this.MemberOptionChip('孩子', 'name')
      }
      .width('100%')
      .margin({ top: 12 })
      Row() {
        this.MemberOptionChip('管理员', 'role')
        this.MemberOptionChip('普通成员', 'role')
        this.MemberOptionChip('访客', 'role')
      }
      .width('100%')
      .margin({ top: 10 })
      Row() {
        Button('取消')
          .layoutWeight(1)
          .height(38)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .backgroundColor(this.softColor())
          .borderRadius(19)
          .margin({ right: 8 })
          .onClick(() => {
            this.showNewMember = false;
          })
        Button('确认添加')
          .layoutWeight(1)
          .height(38)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isNight ? '#11151D' : '#FFFFFF')
          .backgroundColor(this.isNight ? '#F5F7FB' : '#11151D')
          .borderRadius(19)
          .margin({ left: 8 })
          .onClick(() => {
            this.upsertSelectedMember();
            this.showNewMember = false;
            this.showEmpty = false;
            this.syncFamilyPreferences();
          })
      }
      .width('100%')
      .margin({ top: 14 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(this.cardColor())
    .borderRadius(22)
    .margin({ top: 10 })
  }

  @Builder
  MemberOptionChip(label: string, type: string) {
    Text(label)
      .fontSize(12)
      .fontWeight(((type === 'name' && this.selectedMemberName === label) || (type === 'role' && this.selectedMemberRole === label)) ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(((type === 'name' && this.selectedMemberName === label) || (type === 'role' && this.selectedMemberRole === label)) ? (this.isNight ? '#11151D' : '#FFFFFF') : this.primaryText())
      .padding({ left: 13, right: 13, top: 9, bottom: 9 })
      .backgroundColor(((type === 'name' && this.selectedMemberName === label) || (type === 'role' && this.selectedMemberRole === label)) ? (this.isNight ? '#F5F7FB' : '#11151D') : this.softColor())
      .borderRadius(17)
      .margin({ right: 8 })
      .onClick(() => {
        if (type === 'name') {
          this.selectedMemberName = label;
        } else {
          this.selectedMemberRole = label;
        }
      })
  }

  @Builder
  MemberRow(member: FamilyMemberSpec) {
    Row() {
      Text(member.name.substring(0, 1))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width(46)
        .height(46)
        .textAlign(TextAlign.Center)
        .backgroundColor(member.accent)
        .borderRadius(17)

      Column() {
        Text(member.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
        Text(`${member.role} · ${member.status}`)
          .fontSize(12)
          .fontColor(this.secondaryText())
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 14 })

      if (member.id === 'owner') {
        Text('拥有者')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5E8CFF')
      } else {
        Button('移除')
          .height(32)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#D35B4B')
          .backgroundColor(this.isNight ? '#33D35B4B' : '#FFF1EF')
          .borderRadius(16)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.removeMember(member.id);
            this.showNewMember = false;
            this.syncFamilyPreferences();
          })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(this.cardColor())
    .borderRadius(22)
    .margin({ top: 10 })
  }

  @Builder
  EmptyMemberState() {
    Column() {
      Text('暂无家庭成员')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('创建家庭后，可通过二维码、手机号或近场发现邀请成员。')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(this.secondaryText())
        .textAlign(TextAlign.Center)
        .margin({ top: 8 })
    }
    .width('100%')
    .padding({ left: 28, right: 28, top: 54, bottom: 54 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
  }
}
