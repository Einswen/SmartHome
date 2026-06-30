import router from '@ohos.router';

interface PlanCenterRouteParams {
  isNight?: boolean;
}

interface ScenePlanSpec {
  id: string;
  title: string;
  desc: string;
  room: string;
  deviceCount: string;
  saving: string;
  accent: string;
}

interface ChecklistSpec {
  id: string;
  title: string;
  desc: string;
  value: string;
  accent: string;
}

const SCENE_PLANS: ScenePlanSpec[] = [
  {
    id: 'sleep',
    title: '安睡方案',
    desc: '卧室灯光渐暗，空调切到低噪模式，窗帘自动闭合。',
    room: '卧室',
    deviceCount: '4 个设备',
    saving: '预计 18 分钟完成',
    accent: '#5E8CFF'
  },
  {
    id: 'away',
    title: '离家节能',
    desc: '关闭客厅高功耗设备，保留门锁、传感器和必要安防。',
    room: '全屋',
    deviceCount: '7 个设备',
    saving: '预计节能 22%',
    accent: '#19B7A4'
  },
  {
    id: 'movie',
    title: '观影氛围',
    desc: '客厅灯光压低，电视与净化器联动，窗帘调整到遮光状态。',
    room: '客厅',
    deviceCount: '5 个设备',
    saving: '一键启用',
    accent: '#F3A33A'
  }
];

const CHECKLISTS: ChecklistSpec[] = [
  { id: 'light', title: '灯光分组', desc: '客厅主灯、氛围灯与卧室床头灯已纳入方案。', value: '3 组', accent: '#F3A33A' },
  { id: 'air', title: '空气策略', desc: '空调和净化器按房间状态自动切换。', value: '2 条', accent: '#5E8CFF' },
  { id: 'security', title: '安防联动', desc: '门锁、门窗传感器和夜间模式保持联动。', value: '已开启', accent: '#19B7A4' }
];

@Entry
@Component
struct PlanCenterPage {
  @StorageLink('homeNightMode') isNight: boolean = false;
  @State activePlanId: string = 'sleep';
  @State previewEnabled: boolean = true;
  @State pressedKey: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as PlanCenterRouteParams | undefined;
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
    return this.isNight ? '#D9151A22' : '#FFFFFFFF';
  }

  private softColor(): string {
    return this.isNight ? '#661F2632' : '#F0F4FA';
  }

  private lineColor(): string {
    return this.isNight ? '#20FFFFFF' : '#12000000';
  }

  private activePlan(): ScenePlanSpec {
    for (let index = 0; index < SCENE_PLANS.length; index++) {
      if (SCENE_PLANS[index].id === this.activePlanId) {
        return SCENE_PLANS[index];
      }
    }
    return SCENE_PLANS[0];
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

  build() {
    Column() {
      this.TopBar()

      Scroll() {
        Column() {
          this.Hero()
          this.PlanTabs()
          this.ActivePlanCard()
          this.ChecklistPanel()
          this.ActionPanel()
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
        .border({ width: 1, color: this.lineColor() })
        .borderRadius(20)
        .onClick(() => {
          router.back();
        })

      Text('方案中心')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .margin({ left: 14 })
        .layoutWeight(1)

      Button(this.previewEnabled ? '预览中' : '预览')
        .height(34)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.previewEnabled ? '#FFFFFF' : this.primaryText())
        .backgroundColor(this.previewEnabled ? '#5E8CFF' : this.cardColor())
        .border({ width: 1, color: this.previewEnabled ? '#5E8CFF' : this.lineColor() })
        .borderRadius(17)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          this.previewEnabled = !this.previewEnabled;
        })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 28, bottom: 14 })
  }

  @Builder
  Hero() {
    Row() {
      Column() {
        Text('把家变成可执行方案')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .maxLines(1)

        Text('选择生活场景后，系统会组合灯光、空调、窗帘和安防设备，生成可直接启用的全屋方案。')
          .fontSize(13)
          .lineHeight(21)
          .fontColor(this.secondaryText())
          .margin({ top: 8 })
          .maxLines(3)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Stack() {
        Circle()
          .width(104)
          .height(104)
          .fill(this.isNight ? '#243148' : '#E8F0FF')

        Image($r('app.media.home_core_scene'))
          .width(106)
          .height(106)
          .objectFit(ImageFit.Contain)
      }
      .width(112)
      .height(112)
      .margin({ left: 10 })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({ left: 20, right: 20, top: 22, bottom: 22 })
    .linearGradient({
      angle: 135,
      colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#23342D', 1.0]] : [['#EAF2FF', 0.0], ['#FFFFFF', 0.58], ['#EAF8F4', 1.0]]
    })
    .border({ width: 1, color: this.lineColor() })
    .borderRadius(26)
  }

  @Builder
  PlanTabs() {
    Scroll() {
      Row() {
        ForEach(SCENE_PLANS, (item: ScenePlanSpec) => {
          Text(item.title)
            .fontSize(13)
            .fontWeight(this.activePlanId === item.id ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(this.activePlanId === item.id ? (this.isNight ? '#11151D' : '#FFFFFF') : this.primaryText())
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(this.activePlanId === item.id ? (this.isNight ? '#F5F7FB' : '#11151D') : this.cardColor())
            .border({ width: 1, color: this.lineColor() })
            .borderRadius(18)
            .margin({ right: 8 })
            .onClick(() => {
              this.activePlanId = item.id;
            })
        }, (item: ScenePlanSpec) => item.id)
      }
      .padding({ right: 8 })
    }
    .width('100%')
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .margin({ top: 16 })
  }

  @Builder
  ActivePlanCard() {
    Column() {
      Row() {
        Column()
          .width(8)
          .height(58)
          .borderRadius(4)
          .backgroundColor(this.activePlan().accent)

        Column() {
          Text(this.activePlan().title)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())
            .maxLines(1)

          Text(this.activePlan().desc)
            .fontSize(13)
            .lineHeight(20)
            .fontColor(this.secondaryText())
            .margin({ top: 7 })
            .maxLines(2)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 14 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row() {
        this.PlanMetric('空间', this.activePlan().room)
        Blank().width(8)
        this.PlanMetric('联动', this.activePlan().deviceCount)
        Blank().width(8)
        this.PlanMetric('状态', this.activePlan().saving)
      }
      .width('100%')
      .margin({ top: 18 })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(this.cardColor())
    .border({ width: 1, color: this.lineColor() })
    .borderRadius(24)
    .margin({ top: 16 })
  }

  @Builder
  PlanMetric(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .maxLines(1)

      Text(label)
        .fontSize(11)
        .fontColor(this.secondaryText())
        .margin({ top: 5 })
    }
    .layoutWeight(1)
    .height(66)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.softColor())
    .borderRadius(18)
  }

  @Builder
  ChecklistPanel() {
    Column() {
      Text('方案配置')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
        .margin({ bottom: 10 })

      ForEach(CHECKLISTS, (item: ChecklistSpec) => {
        this.ChecklistItem(item)
      }, (item: ChecklistSpec) => item.id)
    }
    .width('100%')
    .margin({ top: 22 })
  }

  @Builder
  ChecklistItem(item: ChecklistSpec) {
    Row() {
      Column()
        .width(36)
        .height(36)
        .borderRadius(18)
        .backgroundColor(item.accent)

      Column() {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .maxLines(1)

        Text(item.desc)
          .fontSize(12)
          .fontColor(this.secondaryText())
          .margin({ top: 5 })
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      Text(item.value)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(item.accent)
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor(this.softColor())
        .borderRadius(13)
    }
    .width('100%')
    .height(70)
    .padding({ left: 14, right: 14 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.cardColor())
    .border({ width: 1, color: this.lineColor() })
    .borderRadius(20)
    .margin({ top: 10 })
  }

  @Builder
  ActionPanel() {
    Column() {
      Button('启用当前方案')
        .width('100%')
        .height(46)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isNight ? '#11151D' : '#FFFFFF')
        .backgroundColor(this.isNight ? '#F5F7FB' : '#11151D')
        .borderRadius(23)
        .scale(this.buttonScale('apply'))
        .animation({ duration: 120, curve: Curve.EaseOut })
        .onTouch((event: TouchEvent) => {
          this.handlePressState('apply', event);
        })

      Button('查看相关设备')
        .width('100%')
        .height(42)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .backgroundColor(this.softColor())
        .borderRadius(21)
        .margin({ top: 10 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/my/mydevices', params: { isNight: this.isNight } });
        })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(this.cardColor())
    .border({ width: 1, color: this.lineColor() })
    .borderRadius(24)
    .margin({ top: 22 })
  }
}
