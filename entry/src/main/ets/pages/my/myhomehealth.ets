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

@Entry
@Component
struct MyHomeHealthPage {
  @StorageLink('homeNightMode') isNight: boolean = false;
  @StorageLink('lumiUserSignedIn') signedIn: boolean = false;
  @StorageLink('lumiAuthToken') authToken: string = '';
  @StorageLink('homeLivingAirInstalled') livingAirInstalled: boolean = false;
  @StorageLink('homeLivingCurtainInstalled') livingCurtainInstalled: boolean = false;
  @StorageLink('homeLivingTvInstalled') livingTvInstalled: boolean = false;
  @StorageLink('homeLivingPurifierInstalled') livingPurifierInstalled: boolean = false;
  @StorageLink('homeLivingRobotInstalled') livingRobotInstalled: boolean = false;
  @StorageLink('homeLivingLightInstalled') livingLightInstalled: boolean = false;
  @StorageLink('homeLivingDeviceCount') livingDeviceCount: number = 0;

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

  private hasAuthSession(): boolean {
    return this.signedIn && this.authToken.trim().length > 0;
  }

  private healthScore(): string {
    const count = this.installedCount();
    if (count === 0) {
      return '0';
    }
    if (count >= 6) {
      return '96';
    }
    if (count >= 4) {
      return '88';
    }
    return '72';
  }

  private healthTasks(): HealthTaskSpec[] {
    const count = this.installedCount();
    return [
      { title: '设备巡检', desc: `${count} 台设备已加入当前家庭，状态会跟随账号家庭同步。`, state: '已同步', color: '#35D27A' },
      { title: '自动化脚本', desc: '暂无自动化执行记录，添加场景后会显示最近状态。', state: '待配置', color: '#5E8CFF' },
      { title: '账号与权限', desc: '家庭成员由账号家庭同步，新账户默认没有额外成员。', state: '待添加', color: '#7F72F2' }
    ];
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

      if (this.hasAuthSession()) {
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
      } else {
        this.AuthRequiredState()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor())
  }

  @Builder
  AuthRequiredState() {
    Column() {
      Text('登录后查看健康报告')
        .fontSize(21)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())

      Text('健康度、巡检项目和家庭风险会从账号家庭同步生成。')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(this.secondaryText())
        .textAlign(TextAlign.Center)
        .width('78%')
        .margin({ top: 8 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ left: 28, right: 28, bottom: 40 })
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
        this.MetricChip('自动化', '0')
        this.MetricChip('风险', this.installedCount() >= 4 ? '低' : '待评估')
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

      if (this.installedCount() === 0) {
        Column() {
          Text('暂无巡检数据')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())

          Text('添加房间和设备后，系统会生成对应的健康状态。')
            .fontSize(12)
            .lineHeight(18)
            .fontColor(this.secondaryText())
            .textAlign(TextAlign.Center)
            .margin({ top: 8 })
        }
        .width('100%')
        .padding({ top: 28, bottom: 28 })
        .alignItems(HorizontalAlign.Center)
      } else {
        ForEach(this.healthTasks(), (item: HealthTaskSpec) => {
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
