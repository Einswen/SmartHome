interface DetailMetricSpec {
  id: string;
  label: string;
  value: string;
  hint: string;
}

interface DetailActionSpec {
  id: string;
  label: string;
  value: string;
}

interface DevicePageSpec {
  id: string;
  title: string;
  subtitle: string;
  hero: Resource;
  accent: string;
  mode: string;
  headline: string;
  description: string;
  sliderLabel: string;
  sliderUnit: string;
  sliderValue: number;
  metrics: DetailMetricSpec[];
  actions: DetailActionSpec[];
}

const DEVICE_PAGES: DevicePageSpec[] = [
  {
    id: 'living_air',
    title: '客厅空调',
    subtitle: '温控 | 北侧出风',
    hero: $r('app.media.device_living_air'),
    accent: '#6CAEFF',
    mode: '柔风恒温',
    headline: '24°C 自动风，客厅体感稳定',
    description: '根据室内温差、日照和人员活动调节送风角度，优先保持沙发区域舒适。',
    sliderLabel: '目标温度',
    sliderUnit: '°C',
    sliderValue: 24,
    metrics: [
      { id: 'temp', label: '当前温度', value: '24.2°C', hint: '接近设定' },
      { id: 'humidity', label: '湿度', value: '46%', hint: '舒适' },
      { id: 'wind', label: '风速', value: '自动', hint: '柔风' }
    ],
    actions: [
      { id: 'eco', label: '节能模式', value: '预计省电 12%' },
      { id: 'swing', label: '扫风角度', value: '向上 18°' },
      { id: 'schedule', label: '定时', value: '22:30 降噪' }
    ]
  },
  {
    id: 'living_curtain',
    title: '客厅窗帘',
    subtitle: '遮阳 | 西侧窗',
    hero: $r('app.media.device_living_curtain'),
    accent: '#D6A96D',
    mode: '日照跟随',
    headline: '当前半开，降低西晒眩光',
    description: '根据光照强度和观影状态自动调整开合比例，保留自然采光。',
    sliderLabel: '开合比例',
    sliderUnit: '%',
    sliderValue: 46,
    metrics: [
      { id: 'open', label: '开合', value: '46%', hint: '半开' },
      { id: 'lux', label: '窗边光照', value: '612 lx', hint: '偏亮' },
      { id: 'motor', label: '电机负载', value: '低', hint: '正常' }
    ],
    actions: [
      { id: 'sun', label: '防晒联动', value: '14:00-17:30' },
      { id: 'quiet', label: '静音运行', value: '已开启' },
      { id: 'calibrate', label: '行程校准', value: '上次 09:16' }
    ]
  },
  {
    id: 'living_tv',
    title: '客厅电视',
    subtitle: '影音 | HDMI 1',
    hero: $r('app.media.device_living_tv'),
    accent: '#7F9CFF',
    mode: '影院准备',
    headline: '待机中，可一键进入观影场景',
    description: '联动窗帘、主灯和音响输入源，自动切换到低眩光观看环境。',
    sliderLabel: '音量',
    sliderUnit: '%',
    sliderValue: 32,
    metrics: [
      { id: 'source', label: '输入源', value: 'HDMI 1', hint: '电视盒子' },
      { id: 'net', label: '网络', value: '5 GHz', hint: '稳定' },
      { id: 'power', label: '功耗', value: '0.8 W', hint: '待机' }
    ],
    actions: [
      { id: 'movie', label: '观影联动', value: '窗帘 16% / 灯光 22%' },
      { id: 'cast', label: '投屏', value: '客厅可发现' },
      { id: 'sound', label: '音频输出', value: '回音壁' }
    ]
  },
  {
    id: 'living_purifier',
    title: '空气净化器',
    subtitle: '空气 | PM2.5 良好',
    hero: $r('app.media.device_living_purifier'),
    accent: '#58D0BE',
    mode: '空气管家',
    headline: '自动净化中，客厅空气质量良好',
    description: '净化器联动主能网关、手势传感器、环境传感器和照明模块，按空气和活动状态调整策略。',
    sliderLabel: '净化风量',
    sliderUnit: '%',
    sliderValue: 64,
    metrics: [
      { id: 'pm', label: 'PM2.5', value: '12', hint: '良好' },
      { id: 'filter', label: '滤芯寿命', value: '82%', hint: '约 96 天' },
      { id: 'noise', label: '噪声', value: '31 dB', hint: '安静' }
    ],
    actions: [
      { id: 'gateway', label: 'Lumi 主能网关', value: '4 个子设备在线' },
      { id: 'gesture', label: '手势传感器', value: '识别率 96%' },
      { id: 'env', label: '环境传感器', value: '温湿光同步' }
    ]
  },
  {
    id: 'living_robot',
    title: '客厅扫地机器人',
    subtitle: '清洁 | 电量 86%',
    hero: $r('app.media.device_living_robot'),
    accent: '#8A96FF',
    mode: '区域清洁',
    headline: '待命中，客厅地面地图已更新',
    description: '识别沙发、茶几和电视柜边缘，自动绕开地毯高阻区域。',
    sliderLabel: '吸力',
    sliderUnit: '%',
    sliderValue: 58,
    metrics: [
      { id: 'battery', label: '电量', value: '86%', hint: '可清扫 54 分钟' },
      { id: 'area', label: '已建图', value: '32 m²', hint: '客厅' },
      { id: 'dust', label: '尘盒', value: '24%', hint: '无需清理' }
    ],
    actions: [
      { id: 'zone', label: '重点区域', value: '茶几周围' },
      { id: 'mop', label: '拖地水量', value: '中' },
      { id: 'dock', label: '回充路径', value: '畅通' }
    ]
  },
  {
    id: 'living_sofa',
    title: '客厅沙发',
    subtitle: '家具 | 会客中心',
    hero: $r('app.media.device_living_sofa'),
    accent: '#9AAFC3',
    mode: '空间锚点',
    headline: '沙发区域是客厅自动化的核心坐标',
    description: '会客、观影和阅读场景都会围绕沙发位置调整灯光、窗帘和电视方向。',
    sliderLabel: '舒适度',
    sliderUnit: '%',
    sliderValue: 82,
    metrics: [
      { id: 'seat', label: '就坐区域', value: '3 人', hint: '常用' },
      { id: 'light', label: '阅读光', value: '68%', hint: '覆盖' },
      { id: 'air', label: '送风避让', value: '开启', hint: '舒适' }
    ],
    actions: [
      { id: 'movie', label: '观影位置', value: '电视正向' },
      { id: 'guest', label: '会客灯光', value: '3600K 暖白' },
      { id: 'clean', label: '清洁避让', value: '沙发前 30cm' }
    ]
  },
  {
    id: 'living_table',
    title: '客厅茶几',
    subtitle: '家具 | 中心区域',
    hero: $r('app.media.device_living_table'),
    accent: '#C59A63',
    mode: '桌面监测',
    headline: '茶几区域联动清洁与会客场景',
    description: '系统将茶几周围识别为高频活动区，扫地机器人会优先清理边缘碎屑。',
    sliderLabel: '清洁优先级',
    sliderUnit: '%',
    sliderValue: 76,
    metrics: [
      { id: 'zone', label: '活动热区', value: '高', hint: '常用' },
      { id: 'clean', label: '清洁频率', value: '每日', hint: '推荐' },
      { id: 'safe', label: '避障半径', value: '12cm', hint: '稳定' }
    ],
    actions: [
      { id: 'robot', label: '机器人重点清洁', value: '已加入' },
      { id: 'light', label: '桌面补光', value: '客厅灯 68%' },
      { id: 'scene', label: '会客场景', value: '茶几周边保留' }
    ]
  },
  {
    id: 'living_light',
    title: '客厅灯',
    subtitle: '照明 | 主灯与氛围灯',
    hero: $r('app.media.device_living_light'),
    accent: '#F4C94A',
    mode: '温暖会客',
    headline: '亮度 68%，适合会客与阅读',
    description: '支持与电视、窗帘联动，自动切换观影、回家和夜间路径灯光。',
    sliderLabel: '亮度',
    sliderUnit: '%',
    sliderValue: 68,
    metrics: [
      { id: 'bright', label: '亮度', value: '68%', hint: '明亮' },
      { id: 'color', label: '色温', value: '3600K', hint: '暖白' },
      { id: 'scene', label: '场景', value: '会客', hint: '当前' }
    ],
    actions: [
      { id: 'movie', label: '观影灯光', value: '22% 暖光' },
      { id: 'path', label: '夜间路径', value: '自动' },
      { id: 'group', label: '灯组', value: '3 盏在线' }
    ]
  },
  {
    id: 'bedroom_air',
    title: '卧室空调',
    subtitle: '温控 | 睡眠风',
    hero: $r('app.media.device_bedroom_air'),
    accent: '#78A9FF',
    mode: '睡眠守护',
    headline: '23°C 睡眠风，夜间自动降噪',
    description: '结合睡眠时间和门窗状态，逐步降低风速，减少温差刺激。',
    sliderLabel: '睡眠温度',
    sliderUnit: '°C',
    sliderValue: 23,
    metrics: [
      { id: 'temp', label: '当前温度', value: '23.1°C', hint: '稳定' },
      { id: 'noise', label: '运行噪声', value: '24 dB', hint: '安静' },
      { id: 'wind', label: '风向', value: '避人', hint: '睡眠' }
    ],
    actions: [
      { id: 'sleep', label: '睡眠曲线', value: '02:00 +1°C' },
      { id: 'door', label: '门窗联动', value: '已开启' },
      { id: 'dry', label: '防霉干燥', value: '关机后 8 分钟' }
    ]
  },
  {
    id: 'bedroom_curtain',
    title: '卧室窗帘',
    subtitle: '遮阳 | 西侧窗',
    hero: $r('app.media.device_bedroom_curtain'),
    accent: '#A5AC8B',
    mode: '晨醒唤光',
    headline: '开合 58%，保留柔和自然光',
    description: '根据闹钟和睡眠场景缓慢开帘，避免突然强光打扰。',
    sliderLabel: '开合比例',
    sliderUnit: '%',
    sliderValue: 58,
    metrics: [
      { id: 'open', label: '开合', value: '58%', hint: '柔光' },
      { id: 'timer', label: '晨醒', value: '07:20', hint: '渐开' },
      { id: 'shade', label: '遮光', value: '72%', hint: '适中' }
    ],
    actions: [
      { id: 'sleep', label: '睡眠关闭', value: '22:30 全关' },
      { id: 'wake', label: '唤醒曲线', value: '20 分钟' },
      { id: 'manual', label: '手拉检测', value: '灵敏' }
    ]
  },
  {
    id: 'bedroom_bed',
    title: '双人床',
    subtitle: '家具 | 睡眠中心',
    hero: $r('app.media.device_bedroom_bed'),
    accent: '#8FA7C7',
    mode: '睡眠核心',
    headline: '睡眠场景围绕床位温度与光线展开',
    description: '床位区域用于决定空调睡眠风、床头灯亮度和夜间路径灯触发。',
    sliderLabel: '睡眠舒适度',
    sliderUnit: '%',
    sliderValue: 88,
    metrics: [
      { id: 'temp', label: '床边温度', value: '23.1°C', hint: '舒适' },
      { id: 'light', label: '床头光', value: '22%', hint: '柔和' },
      { id: 'quiet', label: '夜间噪声', value: '低', hint: '安静' }
    ],
    actions: [
      { id: 'sleep', label: '睡眠场景', value: '22:30 开启' },
      { id: 'wake', label: '晨醒联动', value: '窗帘渐开' },
      { id: 'path', label: '起夜路径', value: '右侧微光' }
    ]
  },
  {
    id: 'bedroom_left_light',
    title: '左床头灯',
    subtitle: '照明 | 夜灯',
    hero: $r('app.media.device_bedroom_left_light'),
    accent: '#F0BD5D',
    mode: '夜读柔光',
    headline: '低亮暖光，适合睡前阅读',
    description: '左侧床头灯支持轻触唤醒和夜间延时关闭，减少影响另一侧休息。',
    sliderLabel: '亮度',
    sliderUnit: '%',
    sliderValue: 22,
    metrics: [
      { id: 'bright', label: '亮度', value: '22%', hint: '夜读' },
      { id: 'color', label: '色温', value: '2700K', hint: '暖光' },
      { id: 'timer', label: '延时', value: '18 分钟', hint: '自动关' }
    ],
    actions: [
      { id: 'read', label: '阅读模式', value: '已准备' },
      { id: 'night', label: '起夜模式', value: '8% 微光' },
      { id: 'touch', label: '触摸灵敏度', value: '中' }
    ]
  },
  {
    id: 'bedroom_right_light',
    title: '右床头灯',
    subtitle: '照明 | 阅读灯',
    hero: $r('app.media.device_bedroom_right_light'),
    accent: '#F4A45F',
    mode: '阅读专注',
    headline: '右侧阅读灯独立调光',
    description: '偏向书页区域补光，保留低眩光边界，适合长时间阅读。',
    sliderLabel: '亮度',
    sliderUnit: '%',
    sliderValue: 36,
    metrics: [
      { id: 'bright', label: '亮度', value: '36%', hint: '阅读' },
      { id: 'angle', label: '照射角', value: '42°', hint: '书页' },
      { id: 'scene', label: '场景', value: '独立', hint: '不联动' }
    ],
    actions: [
      { id: 'focus', label: '专注阅读', value: '45 分钟' },
      { id: 'dim', label: '渐暗关闭', value: '10 分钟' },
      { id: 'pair', label: '双灯同步', value: '未开启' }
    ]
  },
  {
    id: 'bedroom_robot',
    title: '卧室扫地机器人',
    subtitle: '清洁 | 电量 91%',
    hero: $r('app.media.device_bedroom_robot'),
    accent: '#8A96FF',
    mode: '安静清扫',
    headline: '待命中，床底区域已标记',
    description: '卧室模式优先降低噪声，避开床边拖鞋和衣物高概率区域。',
    sliderLabel: '吸力',
    sliderUnit: '%',
    sliderValue: 42,
    metrics: [
      { id: 'battery', label: '电量', value: '91%', hint: '充足' },
      { id: 'bed', label: '床底覆盖', value: '83%', hint: '可达' },
      { id: 'noise', label: '噪声', value: '39 dB', hint: '安静' }
    ],
    actions: [
      { id: 'quiet', label: '静音清扫', value: '已开启' },
      { id: 'forbid', label: '禁区', value: '衣柜前' },
      { id: 'schedule', label: '计划', value: '周六 10:00' }
    ]
  },
  {
    id: 'bedroom_wardrobe',
    title: '卧室衣柜',
    subtitle: '家具 | 右侧整墙',
    hero: $r('app.media.device_bedroom_wardrobe'),
    accent: '#B69D7C',
    mode: '收纳区域',
    headline: '衣柜前方已设为清洁慢行区域',
    description: '识别衣柜开门范围，避免机器人碰撞，同时联动床头灯补光。',
    sliderLabel: '避让范围',
    sliderUnit: 'cm',
    sliderValue: 28,
    metrics: [
      { id: 'space', label: '开门余量', value: '42cm', hint: '可用' },
      { id: 'clean', label: '慢行清洁', value: '开启', hint: '防撞' },
      { id: 'light', label: '取物补光', value: '36%', hint: '右灯' }
    ],
    actions: [
      { id: 'robot', label: '机器人避让', value: '衣柜前 28cm' },
      { id: 'light', label: '取衣补光', value: '右床头灯' },
      { id: 'night', label: '夜间勿扰', value: '23:00 后关闭' }
    ]
  },
  {
    id: 'bedroom_door',
    title: '卧室门锁',
    subtitle: '安防 | 已关闭',
    hero: $r('app.media.device_bedroom_door'),
    accent: '#58D0BE',
    mode: '安防监测',
    headline: '门已关闭，夜间提醒已开启',
    description: '检测门磁、停留时间和夜间开门事件，可联动床头灯微亮提示。',
    sliderLabel: '提醒灵敏度',
    sliderUnit: '%',
    sliderValue: 72,
    metrics: [
      { id: 'door', label: '门状态', value: '已关闭', hint: '正常' },
      { id: 'lock', label: '门磁', value: '在线', hint: '低功耗' },
      { id: 'event', label: '今日事件', value: '2 次', hint: '正常' }
    ],
    actions: [
      { id: 'night', label: '夜间提醒', value: '22:30 后开启' },
      { id: 'light', label: '开门亮灯', value: '8% 微光' },
      { id: 'history', label: '安全记录', value: '查看 7 天' }
    ]
  }
];

@Component
export struct DeviceDetailPages {
  @Link detailPointId: string;
  @Prop pointId: string = '';
  @Prop pointName: string = '';
  @Prop pointType: string = '';
  @Prop pointStatus: string = '';
  @Prop pointDetail: string = '';
  @Prop isNight: boolean = false;
  @State pressedKey: string = '';
  @State currentValue: number = 0;
  @State powerOn: boolean = true;
  @State autoManaged: boolean = false;
  @State selectedActionId: string = '';
  @State activeSubDevice: string = 'gateway';

  aboutToAppear(): void {
    this.currentValue = this.page().sliderValue;
    if (this.pointId === 'living_tv' || this.pointId === 'bedroom_door') {
      this.powerOn = false;
    }
  }

  private page(): DevicePageSpec {
    for (let i = 0; i < DEVICE_PAGES.length; i++) {
      if (DEVICE_PAGES[i].id === this.pointId) {
        return DEVICE_PAGES[i];
      }
    }
    return DEVICE_PAGES[0];
  }

  private bg(): string {
    return this.isNight ? '#A61A1E25' : '#EFFFFFFF';
  }

  private card(): string {
    return this.isNight ? '#661F232A' : '#B8FFFFFF';
  }

  private shell(): string {
    return this.isNight ? '#73161A20' : '#A6FFFFFF';
  }

  private line(): string {
    return this.isNight ? '#20FFFFFF' : '#12000000';
  }

  private primary(): string {
    return this.isNight ? '#F5F7FB' : '#111317';
  }

  private secondary(): string {
    return this.isNight ? '#A9AFBC' : '#69707A';
  }

  private inverse(): string {
    return this.isNight ? '#000000' : '#FFFFFF';
  }

  private inverseBg(): string {
    // 只调整白天详情页主按钮，夜间颜色保持组长已定的原样。
    return this.isNight ? '#D9F5F7FB' : '#E05F7DFF';
  }

  private press(key: string, event: TouchEvent): void {
    if (event.type === TouchType.Down) {
      this.pressedKey = key;
    } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      if (this.pressedKey === key) {
        this.pressedKey = '';
      }
    }
  }

  private scaleFor(key: string): ScaleOptions {
    return this.pressedKey === key ? { x: 0.97, y: 0.97 } : { x: 1, y: 1 };
  }

  private opacityFor(key: string): number {
    return this.pressedKey === key ? 0.82 : 1;
  }

  private sliderMin(page: DevicePageSpec): number {
    return page.sliderUnit.indexOf('C') >= 0 ? 16 : 0;
  }

  private sliderMax(page: DevicePageSpec): number {
    if (page.sliderUnit.indexOf('C') >= 0) {
      return 30;
    }
    if (page.sliderUnit === 'cm') {
      return 60;
    }
    return 100;
  }

  private dynamicMetricValue(metric: DetailMetricSpec): string {
    if (metric.id === 'temp') {
      return `${this.currentValue}.1°C`;
    }
    if (metric.id === 'open' || metric.id === 'bright') {
      return `${this.currentValue}%`;
    }
    if (metric.id === 'battery') {
      return `${Math.max(12, Math.min(100, this.currentValue + 28))}%`;
    }
    if (metric.id === 'noise') {
      return this.powerOn ? `${Math.round(22 + this.currentValue * 0.28)} dB` : '0 dB';
    }
    if (metric.id === 'pm') {
      return `${Math.max(5, Math.round(34 - this.currentValue * 0.32))}`;
    }
    if (metric.id === 'filter') {
      return `${Math.max(20, 92 - Math.round(this.currentValue / 6))}%`;
    }
    if (metric.id === 'shade') {
      return `${Math.max(10, 100 - this.currentValue)}%`;
    }
    if (metric.id === 'space') {
      return `${Math.max(20, this.currentValue + 14)}cm`;
    }
    if (metric.id === 'event') {
      return this.powerOn ? '2 次' : '暂停';
    }
    return metric.value;
  }

  private dynamicMetricHint(metric: DetailMetricSpec): string {
    if (!this.powerOn) {
      return metric.id === 'battery' || metric.id === 'filter' ? metric.hint : '已暂停';
    }
    if (this.autoManaged) {
      return '托管中';
    }
    return metric.hint;
  }

  private dynamicActionValue(action: DetailActionSpec): string {
    if (action.id === 'quiet' || action.id === 'eco' || action.id === 'sleep' || action.id === 'night') {
      return this.autoManaged ? '托管中' : action.value;
    }
    if (action.id === 'mop') {
      return this.currentValue > 70 ? '高' : this.currentValue > 38 ? '中' : '低';
    }
    if (action.id === 'swing') {
      return this.currentValue > 25 ? '向上 24°' : '向上 18°';
    }
    if (action.id === 'robot') {
      return this.currentValue > 35 ? `避让 ${this.currentValue}cm` : action.value;
    }
    if (action.id === 'gateway') {
      return this.activeSubDevice === 'gateway' ? '当前查看' : action.value;
    }
    if (action.id === 'gesture') {
      return this.activeSubDevice === 'gesture' ? '当前查看' : action.value;
    }
    if (action.id === 'env') {
      return this.activeSubDevice === 'environment' ? '当前查看' : action.value;
    }
    return action.value;
  }

  @Builder
  Header(page: DevicePageSpec) {
    Row() {
      Button('<')
        .width(36)
        .height(36)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primary())
        .backgroundColor(this.card())
        .borderRadius(18)
        .padding(0)
        .scale(this.scaleFor('detail_back'))
        .opacity(this.opacityFor('detail_back'))
        .animation({ duration: 120, curve: Curve.EaseOut })
        .onTouch((event: TouchEvent) => {
          this.press('detail_back', event);
        })
        .onClick(() => {
          this.detailPointId = '';
        })

      Column() {
        Text(page.title)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primary())
          .maxLines(1)

        Row() {
          Column()
            .width(6)
            .height(6)
            .borderRadius(3)
            .backgroundColor(this.powerOn ? '#25C06D' : '#A9AFBC')

          Text(`${page.subtitle} | ${this.pointStatus}`)
            .fontSize(11)
            .fontColor(this.secondary())
            .margin({ left: 6 })
            .maxLines(1)
        }
        .margin({ top: 5 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 10 })

      Text(page.mode)
        .fontSize(11)
        .fontWeight(FontWeight.Bold)
        .fontColor(page.accent)
        .height(30)
        .padding({ left: 12, right: 12 })
        .textAlign(TextAlign.Center)
        .backgroundColor(this.card())
        .border({ width: 1, color: this.line() })
        .borderRadius(15)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  Hero(page: DevicePageSpec) {
    Row() {
      Column() {
        Text(page.headline)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primary())
          .lineHeight(24)
          .maxLines(2)

        Text(page.description)
          .fontSize(12)
          .fontColor(this.secondary())
          .lineHeight(18)
          .margin({ top: 8 })
          .maxLines(3)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Image(page.hero)
        .width(118)
        .height(94)
        .objectFit(ImageFit.Contain)
        .margin({ left: 8 })
    }
    .width('100%')
    .padding({ left: 12, right: 10, top: 12, bottom: 10 })
    .backgroundColor(this.shell())
    .border({ width: 1, color: this.line() })
    .borderRadius(16)
    .margin({ top: 10 })
  }

  @Builder
  MetricTile(metric: DetailMetricSpec, accent: string) {
    Column() {
      Text(this.dynamicMetricValue(metric))
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(accent)
        .maxLines(1)

      Text(metric.label)
        .fontSize(11)
        .fontColor(this.primary())
        .fontWeight(FontWeight.Medium)
        .margin({ top: 5 })
        .maxLines(1)

      Text(this.dynamicMetricHint(metric))
        .fontSize(10)
        .fontColor(this.secondary())
        .margin({ top: 4 })
        .maxLines(1)
    }
    .height(76)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .padding({ left: 8, right: 8 })
    .backgroundColor(this.card())
    .border({ width: 1, color: this.line() })
    .borderRadius(14)
  }

  @Builder
  Metrics(page: DevicePageSpec) {
    Row() {
      ForEach(page.metrics, (metric: DetailMetricSpec) => {
        Column() {
          this.MetricTile(metric, page.accent)
        }
        .height(76)
        .layoutWeight(1)
        .margin({ right: metric.id === page.metrics[page.metrics.length - 1].id ? 0 : 8 })
      }, (metric: DetailMetricSpec) => metric.id)
    }
    .width('100%')
    .margin({ top: 10 })
  }

  @Builder
  ControlDeck(page: DevicePageSpec) {
    Column() {
      Row() {
        Text(page.sliderLabel)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primary())
          .layoutWeight(1)

        Text(`${this.currentValue}${page.sliderUnit}`)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(page.accent)
      }
      .width('100%')

      Slider({
        value: this.currentValue,
        min: this.sliderMin(page),
        max: this.sliderMax(page),
        step: 1,
        style: SliderStyle.OutSet
      })
        .blockColor('#FFFFFF')
        .trackColor(this.line())
        .selectedColor(page.accent)
        .margin({ top: 8 })
        .onChange((value: number) => {
          this.currentValue = Math.round(value);
        })

      Row() {
        Button(this.powerOn ? '关闭设备' : '开启设备')
          .layoutWeight(1)
          .height(42)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.inverse())
          .backgroundColor(this.inverseBg())
          .borderRadius(18)
          .scale(this.scaleFor('detail_power'))
          .opacity(this.opacityFor('detail_power'))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.press('detail_power', event);
          })
          .onClick(() => {
            this.powerOn = !this.powerOn;
          })

        Button(this.autoManaged ? '退出托管' : '智能托管')
          .layoutWeight(1)
          .height(42)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primary())
          .backgroundColor(this.card())
          .border({ width: 1, color: this.line() })
          .borderRadius(18)
          .margin({ left: 10 })
          .scale(this.scaleFor('detail_auto'))
          .opacity(this.opacityFor('detail_auto'))
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onTouch((event: TouchEvent) => {
            this.press('detail_auto', event);
          })
          .onClick(() => {
            this.autoManaged = !this.autoManaged;
          })
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
    .backgroundColor(this.shell())
    .border({ width: 1, color: this.line() })
    .borderRadius(16)
    .margin({ top: 8 })
  }

  @Builder
  ActionRow(action: DetailActionSpec, accent: string) {
    Row() {
      Column()
        .width(8)
        .height(8)
        .borderRadius(4)
        .backgroundColor(accent)

      Text(action.label)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.primary())
        .layoutWeight(1)
        .margin({ left: 10 })

      Text(this.dynamicActionValue(action))
        .fontSize(12)
        .fontColor(this.selectedActionId === action.id ? accent : this.secondary())
        .maxLines(1)

      Text('>')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.secondary())
        .margin({ left: 8 })
    }
    .width('100%')
    .height(40)
    .padding({ left: 14, right: 12 })
    .backgroundColor(this.selectedActionId === action.id ? this.shell() : this.card())
    .border({ width: 1, color: this.selectedActionId === action.id ? accent : this.line() })
    .borderRadius(14)
    .margin({ top: 7 })
    .scale(this.scaleFor(`action_${action.id}`))
    .opacity(this.opacityFor(`action_${action.id}`))
    .animation({ duration: 120, curve: Curve.EaseOut })
    .onTouch((event: TouchEvent) => {
      this.press(`action_${action.id}`, event);
    })
    .onClick(() => {
      this.selectedActionId = action.id;
    })
  }

  @Builder
  PurifierSubDevice(id: string, name: string, value: string, image: Resource, accent: string) {
    Column() {
      Image(image)
        .width('100%')
        .height(42)
        .objectFit(ImageFit.Contain)

      Text(name)
        .fontSize(11)
        .fontWeight(this.activeSubDevice === id ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.activeSubDevice === id ? this.primary() : this.secondary())
        .maxLines(1)
        .margin({ top: 4 })

      Text(value)
        .fontSize(10)
        .fontColor(accent)
        .maxLines(1)
        .margin({ top: 3 })
    }
    .width(92)
    .height(96)
    .justifyContent(FlexAlign.Center)
    .padding({ left: 8, right: 8, top: 7, bottom: 7 })
    .backgroundColor(this.activeSubDevice === id ? this.shell() : this.card())
    .border({ width: 1, color: this.activeSubDevice === id ? accent : this.line() })
    .borderRadius(14)
    .margin({ right: 8, top: 4, bottom: 4 })
    .scale(this.scaleFor(`sub_${id}`))
    .opacity(this.opacityFor(`sub_${id}`))
    .animation({ duration: 120, curve: Curve.EaseOut })
    .onTouch((event: TouchEvent) => {
      this.press(`sub_${id}`, event);
    })
    .onClick(() => {
      this.activeSubDevice = id;
    })
  }

  @Builder
  PurifierLinkedDevices() {
    Column() {
      Row() {
        Text('联动设备')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primary())
          .layoutWeight(1)

        Text('4 台在线')
          .fontSize(11)
          .fontColor('#58D0BE')
      }
      .width('100%')

      Scroll() {
        Row() {
          this.PurifierSubDevice('gateway', '主能网关', '正常', $r('app.media.device_lumi_gateway'), '#58D0BE')
          this.PurifierSubDevice('gesture', '手势传感器', '96%', $r('app.media.device_gesture_sensor'), '#7EA0FF')
          this.PurifierSubDevice('environment', '环境传感器', '24.8°C', $r('app.media.device_environment_sensor'), '#F4A45F')
          this.PurifierSubDevice('lighting', '照明模块', '80%', $r('app.media.device_lighting_module'), '#F5A742')
        }
        .padding({ right: 8 })
      }
      .width('100%')
      .height(112)
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
      .margin({ top: 6 })
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor(this.shell())
    .border({ width: 1, color: this.line() })
    .borderRadius(16)
    .margin({ top: 8 })
  }

  @Builder
  ActionList(page: DevicePageSpec) {
    Column() {
      Text('设备能力')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primary())
        .width('100%')

      ForEach(page.actions, (action: DetailActionSpec) => {
        this.ActionRow(action, page.accent)
      }, (action: DetailActionSpec) => action.id)
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor(this.shell())
    .border({ width: 1, color: this.line() })
    .borderRadius(16)
    .margin({ top: 8 })
  }

  build() {
    Column() {
      this.Header(this.page())

      Scroll() {
        Column() {
          this.Hero(this.page())
          this.ControlDeck(this.page())
          this.Metrics(this.page())

          if (this.pointId === 'living_purifier') {
            this.PurifierLinkedDevices()
          }

          this.ActionList(this.page())
        }
        .width('100%')
        .padding({ bottom: 8 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('88%')
    .padding({ left: 14, right: 14, top: 16, bottom: 16 })
    .backgroundColor(this.bg())
    .border({ width: 1, color: this.isNight ? '#20FFFFFF' : '#73FFFFFF' })
    .borderRadius(24)
  }
}
