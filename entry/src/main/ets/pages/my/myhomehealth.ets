import router from '@ohos.router';

interface MyHomeHealthRouteParams {
  isNight?: boolean;
}

interface HealthTaskSpec {
  title: string;
  desc: string;
  state: string;
  color: string;
}

const HEALTH_TASKS: HealthTaskSpec[] = [
  { title: '客厅设备巡检', desc: '客厅点位响应正常，灯光和窗帘状态已同步首页', state: '正常', color: '#35D27A' },
  { title: '自动化脚本', desc: '回家、观影、睡眠场景最近 24 小时执行 26 次', state: '稳定', color: '#5E8CFF' },
  { title: '账号与权限', desc: '3 位家庭成员，访客权限未发现越权操作', state: '安全', color: '#7F72F2' },
  { title: '商城服务', desc: '1 个物流订单、1 个耗材订阅和 1 个售后保障记录', state: '跟进中', color: '#F3A33A' }
];

@Entry
@Component
struct MyHomeHealthPage {
  @StorageLink('homeNightMode') isNight: boolean = false;
  @StorageLink('homeLivingAirInstalled') livingAirInstalled: boolean = true;
  @StorageLink('homeLivingCurtainInstalled') livingCurtainInstalled: boolean = true;
  @StorageLink('homeLivingTvInstalled') livingTvInstalled: boolean = true;
  @StorageLink('homeLivingPurifierInstalled') livingPurifierInstalled: boolean = true;
  @StorageLink('homeLivingRobotInstalled') livingRobotInstalled: boolean = true;
  @StorageLink('homeLivingLightInstalled') livingLightInstalled: boolean = true;
  @StorageLink('homeLivingDeviceCount') livingDeviceCount: number = 6;

  aboutToAppear(): void {
    const params = router.getParams() as MyHomeHealthRouteParams;
    if (params.isNight !== undefined) {
      this.isNight = params.isNight;
    }
  }

  private installedCount(): number {
    if (this.livingDeviceCount > 0) {
      return this.livingDeviceCount;
    }
    let count = 0;
    if (this.livingAirInstalled) {
      count++;
    }
    if (this.livingCurtainInstalled) {
      count++;
    }
    if (this.livingTvInstalled) {
      count++;
    }
    if (this.livingPurifierInstalled) {
      count++;
    }
    if (this.livingRobotInstalled) {
      count++;
    }
    if (this.livingLightInstalled) {
      count++;
    }
    return count;
  }

  private healthScore(): string {
    const count = this.installedCount();
    if (count >= 6) {
      return '96';
    }
    if (count >= 4) {
      return '88';
    }
    return '72';
  }

  private primaryText(): string {
    return this.isNight ? '#F6F8FC' : '#11151D';
  }

  private secondaryText(): string {
    return this.isNight ? '#A7AFBD' : '#657083';
  }

  private bgColor(): string {
    return this.isNight ? '#060709' : '#F2F4F8';
  }

  private cardColor(): string {
    return this.isNight ? '#731F232A' : '#B8FFFFFF';
  }

  private softColor(): string {
    return this.isNight ? '#73161A20' : '#B8EFF2F7';
  }

  private lineColor(): string {
    return this.isNight ? '#24FFFFFF' : '#5CFFFFFF';
  }

  build() {
    Column() {
      this.TopBar()

      Scroll() {
        Column() {
          this.ScoreCard()
          this.TaskList()
          this.ActionCard()
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

      Text('家庭健康报告')
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
  ScoreCard() {
    Column() {
      Text(`${this.healthScore()}%`)
        .fontSize(48)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')

      Text(`当前家庭已绑定 ${this.installedCount()} 台客厅设备。首页添加或设备中心移除设备后，这里和首页点位会同步更新。`)
        .fontSize(13)
        .lineHeight(21)
        .fontColor(this.secondaryText())
        .margin({ top: 8 })
        .width('100%')

      Row() {
        this.MetricChip('在线率', this.installedCount() >= 5 ? '高' : '待补齐')
        this.MetricChip('自动化', '26')
        this.MetricChip('风险', this.installedCount() >= 4 ? '低' : '中')
      }
      .width('100%')
      .margin({ top: 18 })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 22, bottom: 20 })
    .linearGradient({ angle: 135, colors: this.isNight ? [['#192332', 0.0], ['#10151E', 0.66], ['#1A2D2B', 1.0]] : [['#E6EEFF', 0.0], ['#B8FFFFFF', 0.56], ['#EAF8F4', 1.0]] })
    .borderRadius(26)
  }

  @Builder
  MetricChip(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text(label)
        .fontSize(11)
        .fontColor(this.secondaryText())
        .margin({ top: 5 })
    }
    .layoutWeight(1)
    .height(66)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.isNight ? '#331E2530' : '#CCFFFFFF')
    .borderRadius(18)
    .margin({ right: 8 })
  }

  @Builder
  TaskList() {
    Column() {
      Text('巡检项目')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
        .margin({ bottom: 10 })

      ForEach(HEALTH_TASKS, (item: HealthTaskSpec) => {
        Row() {
          Column()
            .width(10)
            .height(10)
            .borderRadius(5)
            .backgroundColor(item.color)
            .margin({ right: 12 })

          Column() {
            Row() {
              Text(item.title)
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.primaryText())
                .layoutWeight(1)
              Text(item.state)
                .fontSize(11)
                .fontWeight(FontWeight.Bold)
                .fontColor(item.color)
            }
            .width('100%')

            Text(item.desc)
              .fontSize(12)
              .lineHeight(18)
              .fontColor(this.secondaryText())
              .margin({ top: 5 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ top: 13, bottom: 13 })
        .border({ width: { bottom: 1 }, color: this.lineColor() })
      }, (item: HealthTaskSpec) => item.title)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 8 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 16 })
  }

  @Builder
  ActionCard() {
    Column() {
      Text('建议操作')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
        .margin({ bottom: 12 })

      Button('打开设备中心')
        .width('100%')
        .height(44)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#5E8CFF')
        .borderRadius(22)
        .onClick(() => {
          router.pushUrl({ url: 'pages/my/mydevices', params: { isNight: this.isNight } });
        })

      Button('查看方案中心')
        .width('100%')
        .height(42)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .backgroundColor(this.softColor())
        .borderRadius(21)
        .margin({ top: 10 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/plancenter/plancenter', params: { isNight: this.isNight } });
        })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 16 })
  }

}
