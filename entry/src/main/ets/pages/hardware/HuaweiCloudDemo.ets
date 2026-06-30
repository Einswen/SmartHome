import router from '@ohos.router';
import { HuaweiCloudApi } from '../../common/HuaweiCloudApi';

interface CloudRouteParams {
  isNight?: boolean;
}

interface ShadowMetric {
  label: string;
  value: string;
  unit: string;
}

function extractShadowValue(raw: string, key: string): string {
  const keyToken = `"${key}"`;
  const keyIndex = raw.indexOf(keyToken);
  if (keyIndex < 0) {
    return '--';
  }
  const valueToken = '"value"';
  const valueIndex = raw.indexOf(valueToken, keyIndex + keyToken.length);
  if (valueIndex < 0) {
    return '--';
  }
  const colonIndex = raw.indexOf(':', valueIndex + valueToken.length);
  if (colonIndex < 0) {
    return '--';
  }
  const tail = raw.substring(colonIndex + 1).trim();
  if (tail.startsWith('"')) {
    const endIndex = tail.indexOf('"', 1);
    return endIndex > 0 ? tail.substring(1, endIndex) : '--';
  }
  let endIndex = tail.length;
  const commaIndex = tail.indexOf(',');
  const braceIndex = tail.indexOf('}');
  if (commaIndex >= 0) {
    endIndex = commaIndex;
  }
  if (braceIndex >= 0 && braceIndex < endIndex) {
    endIndex = braceIndex;
  }
  return tail.substring(0, endIndex).trim();
}

@Entry
@Component
struct HuaweiCloudDemoPage {
  @State isNight: boolean = false;
  @State loading: boolean = false;
  @State lightOn: boolean = false;
  @State motorOn: boolean = false;
  @State statusText: string = '未连接';
  @State rawShadow: string = '点击“刷新影子”读取华为云 IoTDA 设备影子。';
  @State temperature: string = '--';
  @State humidity: string = '--';
  @State luminance: string = '--';
  @State cloudLightStatus: string = '--';
  @State cloudMotorStatus: string = '--';

  aboutToAppear(): void {
    const params = router.getParams() as CloudRouteParams | undefined;
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
    return this.isNight ? '#D9151A22' : '#FFFFFF';
  }

  private lineColor(): string {
    return this.isNight ? '#24FFFFFF' : '#14000000';
  }

  private metrics(): ShadowMetric[] {
    return [
      { label: '温度', value: this.temperature, unit: 'C' },
      { label: '湿度', value: this.humidity, unit: '%' },
      { label: '亮度', value: this.luminance, unit: 'lx' },
      { label: '灯状态', value: this.cloudLightStatus, unit: '' },
      { label: '电机状态', value: this.cloudMotorStatus, unit: '' }
    ];
  }

  private syncParsedShadow(raw: string): void {
    this.temperature = extractShadowValue(raw, '温度');
    this.humidity = extractShadowValue(raw, '湿度');
    this.luminance = extractShadowValue(raw, '亮度');
    this.cloudLightStatus = extractShadowValue(raw, '紫光灯状态');
    this.cloudMotorStatus = extractShadowValue(raw, '电机状态');
  }

  private async refreshShadow(): Promise<void> {
    if (this.loading) {
      return;
    }
    this.loading = true;
    this.statusText = '正在读取设备影子...';
    try {
      const shadow = await HuaweiCloudApi.getDeviceData();
      this.rawShadow = shadow;
      this.syncParsedShadow(shadow);
      this.statusText = '设备影子读取成功';
    } catch (err) {
      this.statusText = '设备影子读取失败';
      this.rawShadow = JSON.stringify(err);
    } finally {
      this.loading = false;
    }
  }

  private async setLight(next: boolean): Promise<void> {
    if (this.loading) {
      return;
    }
    this.loading = true;
    this.statusText = next ? '正在打开 IA01 灯...' : '正在关闭 IA01 灯...';
    try {
      await HuaweiCloudApi.sendLightCommand(next ? 'ON' : 'OFF');
      this.lightOn = next;
      this.statusText = next ? '开灯命令已下发' : '关灯命令已下发';
    } catch (err) {
      this.statusText = '灯命令下发失败';
      this.rawShadow = JSON.stringify(err);
    } finally {
      this.loading = false;
    }
  }

  private async setMotor(next: boolean): Promise<void> {
    if (this.loading) {
      return;
    }
    this.loading = true;
    this.statusText = next ? '正在打开 IA01 电机...' : '正在关闭 IA01 电机...';
    try {
      await HuaweiCloudApi.sendMotorCommand(next ? 'ON' : 'OFF');
      this.motorOn = next;
      this.statusText = next ? '开电机命令已下发' : '关电机命令已下发';
    } catch (err) {
      this.statusText = '电机命令下发失败';
      this.rawShadow = JSON.stringify(err);
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      this.TopBar()

      Scroll() {
        Column() {
          this.StatusCard()
          this.MetricGrid()
          this.ControlCard()
          this.RawCard()
        }
        .width('100%')
        .padding({ left: 18, right: 18, bottom: 28 })
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
        .borderRadius(20)
        .onClick(() => {
          router.back();
        })

      Text('华为云硬件联调')
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
  StatusCard() {
    Column() {
      Text('IA01 环境与电机模块')
        .fontSize(13)
        .fontColor(this.secondaryText())
        .width('100%')

      Text(this.statusText)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
        .margin({ top: 8 })

      Text('App -> 华为云 IoTDA -> RK2206 -> E53 IA01')
        .fontSize(12)
        .fontColor(this.secondaryText())
        .width('100%')
        .margin({ top: 8 })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 22, bottom: 22 })
    .linearGradient({ angle: 135, colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#24332F', 1.0]] : [['#E6EEFF', 0.0], ['#FFFFFF', 0.62], ['#EAF8F4', 1.0]] })
    .borderRadius(24)
  }

  @Builder
  MetricGrid() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.metrics(), (item: ShadowMetric) => {
        Column() {
          Text(item.label)
            .fontSize(12)
            .fontColor(this.secondaryText())
            .width('100%')
          Text(`${item.value}${item.unit.length > 0 && item.value !== '--' ? ' ' + item.unit : ''}`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())
            .width('100%')
            .margin({ top: 6 })
        }
        .width('48%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .backgroundColor(this.cardColor())
        .border({ width: 1, color: this.lineColor() })
        .borderRadius(18)
        .margin({ right: 8, top: 10 })
      }, (item: ShadowMetric) => item.label)
    }
    .width('100%')
    .margin({ top: 8 })
  }

  @Builder
  ControlCard() {
    Column() {
      Text('控制命令')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')

      Button(this.loading ? '请求中...' : '刷新影子')
        .height(44)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#11151D')
        .borderRadius(18)
        .width('100%')
        .margin({ top: 14 })
        .enabled(!this.loading)
        .onClick(() => {
          this.refreshShadow();
        })

      Row() {
        this.CommandButton(this.lightOn ? '关闭灯' : '打开灯', '#35A77C', () => {
          this.setLight(!this.lightOn);
        })
        this.CommandButton(this.motorOn ? '关闭电机' : '打开电机', '#5E8CFF', () => {
          this.setMotor(!this.motorOn);
        })
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 16 })
  }

  @Builder
  CommandButton(label: string, color: string, handler: () => void) {
    Button(label)
      .layoutWeight(1)
      .height(44)
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .fontColor('#FFFFFF')
      .backgroundColor(color)
      .borderRadius(18)
      .margin({ right: 8 })
      .enabled(!this.loading)
      .onClick(handler)
  }

  @Builder
  RawCard() {
    Column() {
      Text('原始设备影子')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')

      Text(this.rawShadow)
        .fontSize(11)
        .lineHeight(17)
        .fontColor(this.secondaryText())
        .width('100%')
        .margin({ top: 12 })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 16 })
  }
}
