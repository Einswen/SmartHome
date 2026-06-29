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
export const LIVING_ROBOT_PAGE: DevicePageSpec = {
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
    };



