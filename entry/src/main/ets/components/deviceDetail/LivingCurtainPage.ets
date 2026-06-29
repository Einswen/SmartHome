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
export const LIVING_CURTAIN_PAGE: DevicePageSpec = {
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
    };



