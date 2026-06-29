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
export const LIVING_TV_PAGE: DevicePageSpec = {
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
    };



