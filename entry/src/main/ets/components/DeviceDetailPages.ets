import { LIVING_AIR_PAGE } from './deviceDetail/LivingAirPage';
import { LIVING_CURTAIN_PAGE } from './deviceDetail/LivingCurtainPage';
import { LIVING_TV_PAGE } from './deviceDetail/LivingTvPage';
import { LIVING_PURIFIER_PAGE } from './deviceDetail/LivingPurifierPage';
import { LIVING_ROBOT_PAGE } from './deviceDetail/LivingRobotPage';
import { LIVING_LIGHT_PAGE } from './deviceDetail/LivingLightPage';

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
  LIVING_AIR_PAGE,
  LIVING_CURTAIN_PAGE,
  LIVING_TV_PAGE,
  LIVING_PURIFIER_PAGE,
  LIVING_ROBOT_PAGE,
  LIVING_LIGHT_PAGE,
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
  ,
  {
      id: 'balcony_light',
      title: '阳台灯',
      subtitle: '照明 | 晾晒区顶灯',
      hero: $r('app.media.preview_lamp_square_ceiling'),
      accent: '#F4C94A',
      mode: '晾晒补光',
      headline: '灯光柔和覆盖阳台晾晒区',
      description: '夜间取物和晾晒时自动补光，也可跟随回家、早安场景联动开启。',
      sliderLabel: '亮度',
      sliderUnit: '%',
      sliderValue: 62,
      metrics: [
        { id: 'bright', label: '亮度', value: '62%', hint: '适中' },
        { id: 'color', label: '色温', value: '4000K', hint: '自然' },
        { id: 'scene', label: '场景', value: '晾晒', hint: '当前' }
      ],
      actions: [
        { id: 'night', label: '夜间取物', value: '45% 柔光' },
        { id: 'group', label: '联动灯组', value: '阳台单灯' },
        { id: 'schedule', label: '定时关闭', value: '23:30' }
      ]
    },
  {
      id: 'balcony_washer',
      title: '洗衣机',
      subtitle: '清洁 | 阳台洗护',
      hero: $r('app.media.preview_washer'),
      accent: '#7EA0FF',
      mode: '洗护托管',
      headline: '待机中，快洗与夜间静音可用',
      description: '支持快洗、筒自洁和完成提醒，洗护结束后可联动阳台灯和晾衣架。',
      sliderLabel: '洗涤强度',
      sliderUnit: '%',
      sliderValue: 48,
      metrics: [
        { id: 'clean', label: '程序', value: '快洗', hint: '可用' },
        { id: 'battery', label: '剩余水位', value: '76%', hint: '充足' },
        { id: 'noise', label: '运行噪声', value: '36 dB', hint: '安静' }
      ],
      actions: [
        { id: 'quick', label: '快洗程序', value: '28 分钟' },
        { id: 'dry', label: '筒自洁', value: '本周未执行' },
        { id: 'notify', label: '完成提醒', value: '推送通知' }
      ]
    },
  {
      id: 'balcony_airer',
      title: '晾衣架',
      subtitle: '晾晒 | 升降与烘干',
      hero: $r('app.media.device_living_curtain'),
      accent: '#A5AC8B',
      mode: '智能晾晒',
      headline: '晾衣架已待命，支持升降和风干',
      description: '根据天气、湿度和洗衣机完成状态，建议升降高度并开启辅助风干。',
      sliderLabel: '升降高度',
      sliderUnit: '%',
      sliderValue: 58,
      metrics: [
        { id: 'open', label: '高度', value: '58%', hint: '顺手' },
        { id: 'humidity', label: '湿度', value: '52%', hint: '适合' },
        { id: 'timer', label: '风干', value: '2h', hint: '建议' }
      ],
      actions: [
        { id: 'lift', label: '一键升降', value: '中位' },
        { id: 'dry', label: '辅助风干', value: '2 小时' },
        { id: 'light', label: '照明联动', value: '已开启' }
      ]
    },
  {
      id: 'balcony_sensor',
      title: '环境传感器',
      subtitle: '空气 | 温湿度监测',
      hero: $r('app.media.device_environment_sensor'),
      accent: '#58D0BE',
      mode: '环境监测',
      headline: '阳台温湿度在线，晾晒建议已更新',
      description: '持续监测温度、湿度和光照，辅助判断晾衣架、窗帘和通风策略。',
      sliderLabel: '灵敏度',
      sliderUnit: '%',
      sliderValue: 70,
      metrics: [
        { id: 'temp', label: '温度', value: '24.1°C', hint: '舒适' },
        { id: 'humidity', label: '湿度', value: '52%', hint: '适合' },
        { id: 'light', label: '光照', value: '强', hint: '晾晒' }
      ],
      actions: [
        { id: 'alert', label: '潮湿提醒', value: '65% 触发' },
        { id: 'dry', label: '晾晒建议', value: '适合' },
        { id: 'history', label: '环境记录', value: '查看 24h' }
      ]
    },
  {
      id: 'kitchen_light',
      title: '厨房灯',
      subtitle: '照明 | 烹饪操作台',
      hero: $r('app.media.preview_lamp_square_ceiling'),
      accent: '#F4C94A',
      mode: '烹饪照明',
      headline: '厨房顶灯明亮，覆盖备餐区域',
      description: '烹饪时提高亮度，夜间取水时切换低亮度，避免刺眼。',
      sliderLabel: '亮度',
      sliderUnit: '%',
      sliderValue: 72,
      metrics: [
        { id: 'bright', label: '亮度', value: '72%', hint: '明亮' },
        { id: 'color', label: '色温', value: '4300K', hint: '清晰' },
        { id: 'scene', label: '场景', value: '烹饪', hint: '当前' }
      ],
      actions: [
        { id: 'cook', label: '烹饪模式', value: '高亮' },
        { id: 'night', label: '夜间取水', value: '18% 柔光' },
        { id: 'schedule', label: '离家关闭', value: '已加入' }
      ]
    },
  {
      id: 'kitchen_fridge',
      title: '冰箱',
      subtitle: '厨房 | 冷藏冷冻',
      hero: $r('app.media.preview_kitchen_fridge_small'),
      accent: '#6CAEFF',
      mode: '食材保鲜',
      headline: '冷藏室运行正常，温度稳定',
      description: '监测冷藏、冷冻温度和开门时长，异常时会提醒并建议节能模式。',
      sliderLabel: '冷藏温度',
      sliderUnit: '°C',
      sliderValue: 4,
      metrics: [
        { id: 'temp', label: '冷藏', value: '4.1°C', hint: '稳定' },
        { id: 'freezer', label: '冷冻', value: '-18°C', hint: '正常' },
        { id: 'door', label: '门状态', value: '已关闭', hint: '安全' }
      ],
      actions: [
        { id: 'eco', label: '节能模式', value: '夜间开启' },
        { id: 'fresh', label: '保鲜提醒', value: '3 项临期' },
        { id: 'history', label: '开门记录', value: '今日 6 次' }
      ]
    },
  {
      id: 'kitchen_hood',
      title: '油烟机',
      subtitle: '空气 | 排风净味',
      hero: $r('app.media.device_living_purifier'),
      accent: '#58D0BE',
      mode: '烹饪排风',
      headline: '排风待机，油烟浓度正常',
      description: '烹饪时根据灶台火源和空气质量自动调节风量，结束后延时净味。',
      sliderLabel: '排风强度',
      sliderUnit: '%',
      sliderValue: 44,
      metrics: [
        { id: 'wind', label: '风量', value: '自动', hint: '待机' },
        { id: 'pm', label: '油烟', value: '低', hint: '正常' },
        { id: 'filter', label: '滤网', value: '86%', hint: '良好' }
      ],
      actions: [
        { id: 'boost', label: '爆炒模式', value: '大风量' },
        { id: 'delay', label: '延时净味', value: '8 分钟' },
        { id: 'clean', label: '滤网清洁', value: '12 天后' }
      ]
    },
  {
      id: 'kitchen_stove',
      title: '灶台',
      subtitle: '安防 | 火源监测',
      hero: $r('app.media.device_gesture_sensor'),
      accent: '#F3A33A',
      mode: '厨房安全',
      headline: '火源监测正常，离人提醒已开启',
      description: '结合灶台温度、人员活动和油烟机状态，及时提醒干烧和忘关火风险。',
      sliderLabel: '提醒灵敏度',
      sliderUnit: '%',
      sliderValue: 76,
      metrics: [
        { id: 'temp', label: '台面温度', value: '35.1°C', hint: '正常' },
        { id: 'safe', label: '安全状态', value: '在线', hint: '守护' },
        { id: 'event', label: '今日提醒', value: '0 次', hint: '正常' }
      ],
      actions: [
        { id: 'alert', label: '离人提醒', value: '90 秒' },
        { id: 'hood', label: '油烟机联动', value: '已开启' },
        { id: 'history', label: '安全记录', value: '查看 7 天' }
      ]
    },
  {
      id: 'bathroom_light',
      title: '洗手间灯',
      subtitle: '照明 | 柔和顶灯',
      hero: $r('app.media.preview_lamp_round_floor'),
      accent: '#F4C94A',
      mode: '夜间柔光',
      headline: '洗手间灯光柔和，夜间不刺眼',
      description: '支持人体感应和夜间低亮模式，进入洗手间自动点亮。',
      sliderLabel: '亮度',
      sliderUnit: '%',
      sliderValue: 54,
      metrics: [
        { id: 'bright', label: '亮度', value: '54%', hint: '柔和' },
        { id: 'color', label: '色温', value: '3500K', hint: '暖白' },
        { id: 'scene', label: '夜间', value: '12%', hint: '低亮' }
      ],
      actions: [
        { id: 'sensor', label: '人体感应', value: '已开启' },
        { id: 'night', label: '夜间模式', value: '12% 微光' },
        { id: 'delay', label: '延时关闭', value: '90 秒' }
      ]
    },
  {
      id: 'bathroom_vent',
      title: '换气扇',
      subtitle: '空气 | 湿度联动',
      hero: $r('app.media.device_living_purifier'),
      accent: '#58D0BE',
      mode: '除湿换气',
      headline: '换气扇待机，湿度联动已开启',
      description: '洗浴后自动提高排风，湿度下降到舒适范围后延时关闭。',
      sliderLabel: '换气强度',
      sliderUnit: '%',
      sliderValue: 52,
      metrics: [
        { id: 'humidity', label: '湿度', value: '58%', hint: '正常' },
        { id: 'wind', label: '风量', value: '自动', hint: '联动' },
        { id: 'noise', label: '噪声', value: '32 dB', hint: '安静' }
      ],
      actions: [
        { id: 'dry', label: '洗浴除湿', value: '15 分钟' },
        { id: 'auto', label: '湿度联动', value: '65% 触发' },
        { id: 'clean', label: '滤网检查', value: '正常' }
      ]
    },
  {
      id: 'bathroom_heater',
      title: '热水器',
      subtitle: '温控 | 恒温热水',
      hero: $r('app.media.device_living_air'),
      accent: '#F3A33A',
      mode: '恒温供水',
      headline: '热水器恒温待机，洗浴温度稳定',
      description: '根据用水时间和家庭习惯提前保温，离家时自动进入节能状态。',
      sliderLabel: '目标水温',
      sliderUnit: '°C',
      sliderValue: 42,
      metrics: [
        { id: 'temp', label: '水温', value: '42.1°C', hint: '稳定' },
        { id: 'battery', label: '热水量', value: '78%', hint: '充足' },
        { id: 'safe', label: '安全阀', value: '正常', hint: '在线' }
      ],
      actions: [
        { id: 'eco', label: '节能保温', value: '夜间降低' },
        { id: 'schedule', label: '预约洗浴', value: '21:30' },
        { id: 'safe', label: '防烫保护', value: '已开启' }
      ]
    },
  {
      id: 'bathroom_shower',
      title: '淋浴区',
      subtitle: '安防 | 玻璃门监测',
      hero: $r('app.media.device_bedroom_door'),
      accent: '#7EA0FF',
      mode: '浴室安全',
      headline: '淋浴区监测在线，防滑提醒已开启',
      description: '监测玻璃门、湿滑时间和用水状态，异常停留时提醒家人关注。',
      sliderLabel: '提醒灵敏度',
      sliderUnit: '%',
      sliderValue: 68,
      metrics: [
        { id: 'door', label: '玻璃门', value: '已关闭', hint: '正常' },
        { id: 'humidity', label: '湿度', value: '58%', hint: '正常' },
        { id: 'event', label: '安全提醒', value: '0 次', hint: '安全' }
      ],
      actions: [
        { id: 'alert', label: '久留提醒', value: '20 分钟' },
        { id: 'dry', label: '联动换气', value: '洗后开启' },
        { id: 'light', label: '夜间照明', value: '柔光' }
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
    const basePointId = this.pointBaseId(this.pointId);
    if (basePointId === 'living_tv' || basePointId === 'bedroom_door') {
      this.powerOn = false;
    }
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

  private page(): DevicePageSpec {
    const basePointId = this.pointBaseId(this.pointId);
    for (let i = 0; i < DEVICE_PAGES.length; i++) {
      if (DEVICE_PAGES[i].id === basePointId) {
        return DEVICE_PAGES[i];
      }
    }
    return this.fallbackPage(basePointId);
  }

  private fallbackAccent(): string {
    if (this.pointType === '温控') {
      return '#6CAEFF';
    }
    if (this.pointType === '照明') {
      return '#F4C94A';
    }
    if (this.pointType === '安防') {
      return '#58D0BE';
    }
    if (this.pointType === '清洁') {
      return '#7EA0FF';
    }
    if (this.pointType === '空气') {
      return '#58D0BE';
    }
    if (this.pointType === '遮阳') {
      return '#A5AC8B';
    }
    return '#8FA7C7';
  }

  private fallbackSliderLabel(): string {
    if (this.pointType === '温控') {
      return '目标温度';
    }
    if (this.pointType === '照明') {
      return '亮度';
    }
    if (this.pointType === '遮阳') {
      return '开合比例';
    }
    if (this.pointType === '安防') {
      return '提醒灵敏度';
    }
    return '运行强度';
  }

  private fallbackSliderUnit(): string {
    return this.pointType === '温控' ? '°C' : '%';
  }

  private fallbackSliderValue(): number {
    return this.pointType === '温控' ? 24 : 60;
  }

  private fallbackPage(basePointId: string): DevicePageSpec {
    const title = this.pointName.length > 0 ? this.pointName : '设备详情';
    const detail = this.pointDetail.length > 0 ? this.pointDetail : '设备能力已接入当前房间';
    return {
      id: basePointId,
      title: title,
      subtitle: `${this.pointType} | 当前房间`,
      hero: $r('app.media.device_lumi_gateway'),
      accent: this.fallbackAccent(),
      mode: '智能设备',
      headline: `${title} 已接入房间控制`,
      description: detail,
      sliderLabel: this.fallbackSliderLabel(),
      sliderUnit: this.fallbackSliderUnit(),
      sliderValue: this.fallbackSliderValue(),
      metrics: [
        { id: 'state', label: '状态', value: this.pointStatus, hint: '同步' },
        { id: 'scene', label: '场景', value: '可联动', hint: '已接入' },
        { id: 'online', label: '连接', value: '在线', hint: '稳定' }
      ],
      actions: [
        { id: 'auto', label: '智能托管', value: '可开启' },
        { id: 'schedule', label: '定时任务', value: '可设置' },
        { id: 'scene', label: '场景联动', value: '可加入' }
      ]
    };
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
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .padding({ left: 8, right: 8 })
    .backgroundColor(this.card())
    .border({ width: 1, color: this.line() })
    .borderRadius(14)
  }

  @Builder
  Metrics(page: DevicePageSpec) {
    Row({ space: 8 }) {
      ForEach(page.metrics, (metric: DetailMetricSpec) => {
        Column() {
          this.MetricTile(metric, page.accent)
        }
        .height(76)
        .layoutWeight(1)
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

          if (this.pointBaseId(this.pointId) === 'living_purifier') {
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


