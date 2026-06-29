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
export const LIVING_AIR_PAGE: DevicePageSpec = {
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
    };



