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
export const LIVING_LIGHT_PAGE: DevicePageSpec = {
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
    };



