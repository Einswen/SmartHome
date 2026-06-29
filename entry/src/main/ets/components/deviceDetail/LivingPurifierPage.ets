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
export const LIVING_PURIFIER_PAGE: DevicePageSpec = {
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
    };



