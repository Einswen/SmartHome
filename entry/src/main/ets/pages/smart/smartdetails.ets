import router from '@ohos.router';
import {
  AgentMessageSpec,
  AutomationSpec,
  DEFAULT_AGENT_MESSAGES,
  DEFAULT_AUTOMATIONS
} from '../../smart/SmartModels';

interface SmartDetailRouteParams {
  mode?: string;
  isNight?: boolean;
  automations?: AutomationSpec[];
  chatMessages?: AgentMessageSpec[];
}

@Entry
@Component
struct SmartDetailsPage {
  @State mode: string = 'running';
  @State isNight: boolean = false;
  @State automations: AutomationSpec[] = DEFAULT_AUTOMATIONS;
  @State chatMessages: AgentMessageSpec[] = DEFAULT_AGENT_MESSAGES;

  aboutToAppear(): void {
    const params = router.getParams() as SmartDetailRouteParams | undefined;
    if (params) {
      if (params.mode !== undefined) {
        this.mode = params.mode;
      }
      if (params.isNight !== undefined) {
        this.isNight = params.isNight;
      }
      if (params.automations !== undefined) {
        this.automations = params.automations;
      }
      if (params.chatMessages !== undefined) {
        this.chatMessages = params.chatMessages;
      }
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
    return this.isNight ? '#20FFFFFF' : '#12000000';
  }

  private title(): string {
    if (this.mode === 'running') {
      return '运行脚本';
    }
    if (this.mode === 'chat') {
      return '对话记录';
    }
    return '全部脚本';
  }

  private subtitle(): string {
    if (this.mode === 'running') {
      return '当前正在启用的自动化脚本';
    }
    if (this.mode === 'chat') {
      return '智能助手的历史交流内容';
    }
    return '智能中枢内的全部自动化脚本';
  }

  private visibleAutomations(): AutomationSpec[] {
    if (this.mode !== 'running') {
      return this.automations;
    }
    const result: AutomationSpec[] = [];
    for (let i = 0; i < this.automations.length; i++) {
      if (this.automations[i].enabled) {
        result.push(this.automations[i]);
      }
    }
    return result;
  }

  build() {
    Column() {
      this.TopBar()

      Scroll() {
        Column() {
          if (this.mode === 'chat') {
            if (this.chatMessages.length === 0) {
              this.EmptyState('暂无对话记录', '在智能助手中发送问题或设备控制指令后，会显示在这里。')
            } else {
              ForEach(this.chatMessages, (message: AgentMessageSpec) => {
                this.ChatCard(message)
              }, (message: AgentMessageSpec) => message.id)
            }
          } else {
            if (this.visibleAutomations().length === 0) {
              this.EmptyState('暂无脚本', '可以返回智能页，通过新建或智能助手生成自动化脚本。')
            } else {
              ForEach(this.visibleAutomations(), (item: AutomationSpec) => {
                this.AutomationCard(item)
              }, (item: AutomationSpec) => item.id)
            }
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 30 })
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
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .backgroundColor(this.cardColor())
        .borderRadius(20)
        .padding({ left: 0, right: 0 })
        .onClick(() => {
          router.back();
        })

      Column() {
        Text(this.title())
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())

        Text(this.subtitle())
          .fontSize(12)
          .fontColor(this.secondaryText())
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 14 })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 34, bottom: 18 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  AutomationCard(item: AutomationSpec) {
    Column() {
      Row() {
        Text(item.enabled ? '运行中' : '已暂停')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor(item.enabled ? '#12B981' : this.secondaryText())
          .padding({ left: 9, right: 9, top: 5, bottom: 5 })
          .backgroundColor(item.enabled ? '#1812B981' : '#10000000')
          .borderRadius(12)

        Text(item.source === 'agent' ? '智能助手创建' : '手动创建')
          .fontSize(11)
          .fontColor(this.secondaryText())
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text(item.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .margin({ top: 14 })
        .maxLines(1)

      Text(item.trigger)
        .fontSize(13)
        .fontColor(this.secondaryText())
        .margin({ top: 8 })
        .maxLines(1)

      Text(item.action)
        .fontSize(13)
        .lineHeight(20)
        .fontColor(this.primaryText())
        .margin({ top: 10 })
        .maxLines(3)

      Text(`${item.actions.length} 个动作`)
        .fontSize(11)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor(this.isNight ? '#20FFFFFF' : '#F0F4FA')
        .borderRadius(12)
        .margin({ top: 12 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(this.cardColor())
    .border({
      width: 1,
      color: this.lineColor()
    })
    .borderRadius(22)
    .margin({ bottom: 12 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ChatCard(message: AgentMessageSpec) {
    Column() {
      Row() {
        Text(message.role === 'user' ? '用户' : '助手')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor(message.role === 'user' ? '#5E79FF' : '#12B981')
          .padding({ left: 9, right: 9, top: 5, bottom: 5 })
          .backgroundColor(message.role === 'user' ? '#185E79FF' : '#1812B981')
          .borderRadius(12)

        Text(message.meta)
          .fontSize(11)
          .fontColor(this.secondaryText())
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }
      .width('100%')

      Text(message.text)
        .fontSize(14)
        .lineHeight(22)
        .fontColor(this.primaryText())
        .margin({ top: 12 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(this.cardColor())
    .border({
      width: 1,
      color: this.lineColor()
    })
    .borderRadius(22)
    .margin({ bottom: 12 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  EmptyState(title: string, desc: string) {
    Column() {
      Text(title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())

      Text(desc)
        .fontSize(13)
        .lineHeight(21)
        .fontColor(this.secondaryText())
        .textAlign(TextAlign.Center)
        .margin({ top: 8 })
    }
    .width('100%')
    .padding({ left: 26, right: 26, top: 52, bottom: 52 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
  }
}
