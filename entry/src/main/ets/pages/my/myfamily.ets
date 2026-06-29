import router from '@ohos.router';

interface MyFamilyRouteParams {
  isNight?: boolean;
}

interface FamilyMemberSpec {
  id: string;
  name: string;
  role: string;
  status: string;
  accent: string;
}

const FAMILY_MEMBERS: FamilyMemberSpec[] = [
  { id: 'owner', name: 'Lumi 用户', role: '家庭拥有者', status: '在线', accent: '#5E8CFF' },
  { id: 'mom', name: '妈妈', role: '管理员', status: '远程控制已启用', accent: '#19B7A4' },
  { id: 'guest', name: '访客', role: '临时成员', status: '今晚 22:00 失效', accent: '#F3A33A' }
];

@Entry
@Component
struct MyFamilyPage {
  @State showEmpty: boolean = false;
  @State inviteVisible: boolean = true;
  @State inviteFailed: boolean = false;
  @State activeHome: string = '幸福之家';
  @State isNight: boolean = false;
  @StorageLink('familyHideGuest') hideGuest: boolean = false;
  @StorageLink('familyHasCustomMember') hasCustomMember: boolean = false;
  @StorageLink('familyCustomMemberName') customMemberName: string = '新成员';
  @StorageLink('familyCustomMemberRole') customMemberRole: string = '普通成员';
  @State showNewMember: boolean = false;
  @State selectedMemberName: string = '妈妈';
  @State selectedMemberRole: string = '普通成员';

  aboutToAppear(): void {
    const params = router.getParams() as MyFamilyRouteParams | undefined;
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

  private softColor(): string {
    return this.isNight ? '#661F2632' : '#F0F4FA';
  }

  private members(): FamilyMemberSpec[] {
    if (this.showEmpty) {
      return [];
    }
    const nextMembers: FamilyMemberSpec[] = [];
    for (let i = 0; i < FAMILY_MEMBERS.length; i++) {
      if (FAMILY_MEMBERS[i].id !== 'guest' || !this.hideGuest) {
        nextMembers.push(FAMILY_MEMBERS[i]);
      }
    }
    if (this.hasCustomMember) {
      const newMember: FamilyMemberSpec = { id: 'new_member', name: this.customMemberName, role: this.customMemberRole, status: '已加入家庭', accent: '#7F72F2' };
      nextMembers.push(newMember);
    }
    return nextMembers;
  }

  build() {
    Column() {
      this.TopBar()
      Scroll() {
        Column() {
          this.HomeCard()
          this.InviteCard()
          this.PermissionCard()
          this.MemberHeader()
          if (this.showNewMember) {
            this.AddMemberPanel()
          }

          if (this.members().length === 0) {
            this.EmptyMemberState()
          } else {
            ForEach(this.members(), (member: FamilyMemberSpec) => {
              this.MemberRow(member)
            }, (member: FamilyMemberSpec) => member.id)
          }
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

      Text('家庭管理')
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
  HomeCard() {
    Column() {
      Row() {
        Column() {
          Text(this.activeHome)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())
          Text('2 个房间 · 6 台设备 · 3 位成员共享')
            .fontSize(13)
            .fontColor(this.secondaryText())
            .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('96% 健康')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .padding({ left: 12, right: 12, top: 7, bottom: 7 })
          .backgroundColor('#35D27A')
          .borderRadius(16)
      }
      .width('100%')

      Row() {
        this.HomeChip('幸福之家')
        this.HomeChip('父母家')
        this.HomeChip('工作室')
      }
      .width('100%')
      .margin({ top: 18 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 20, right: 20, top: 22, bottom: 22 })
    .linearGradient({ angle: 135, colors: this.isNight ? [['#1B2432', 0.0], ['#111820', 0.62], ['#23342D', 1.0]] : [['#E6EEFF', 0.0], ['#FFFFFF', 0.58], ['#EAF8F4', 1.0]] })
    .borderRadius(26)
  }

  @Builder
  HomeChip(name: string) {
    Text(name)
      .fontSize(12)
      .fontWeight(this.activeHome === name ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(this.activeHome === name ? (this.isNight ? '#11151D' : '#FFFFFF') : this.primaryText())
      .padding({ left: 13, right: 13, top: 9, bottom: 9 })
      .backgroundColor(this.activeHome === name ? (this.isNight ? '#F5F7FB' : '#11151D') : this.softColor())
      .borderRadius(17)
      .margin({ right: 8 })
      .onClick(() => {
        this.activeHome = name;
      })
  }

  @Builder
  InviteCard() {
    Column() {
      Row() {
        Column() {
          Text('邀请家庭成员')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryText())
          Text(this.inviteFailed ? '二维码生成失败，请重试。' : '二维码 10 分钟内有效，扫码后需拥有者确认。')
            .fontSize(12)
            .fontColor(this.inviteFailed ? '#D35B4B' : this.secondaryText())
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Button(this.inviteFailed ? '重试' : this.inviteVisible ? '隐藏' : '生成')
          .height(36)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isNight ? '#11151D' : '#FFFFFF')
          .backgroundColor(this.inviteFailed ? '#D35B4B' : (this.isNight ? '#F5F7FB' : '#11151D'))
          .borderRadius(18)
          .padding({ left: 14, right: 14 })
          .onClick(() => {
            if (this.inviteFailed) {
              this.inviteFailed = false;
              this.inviteVisible = true;
            } else {
              this.inviteVisible = !this.inviteVisible;
            }
          })
      }
      .width('100%')

      if (this.inviteVisible && !this.inviteFailed) {
        Row() {
          this.QrMock()
          Column() {
            Text('LUMI-FAMILY-0428')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.primaryText())
            Text('扫码后加入“幸福之家”，默认访客权限，可由拥有者调整。')
              .fontSize(12)
              .lineHeight(19)
              .fontColor(this.secondaryText())
              .margin({ top: 8 })
            Button('模拟失败')
              .height(32)
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor('#D35B4B')
              .backgroundColor(this.isNight ? '#33D35B4B' : '#FFF1EF')
              .borderRadius(16)
              .padding({ left: 12, right: 12 })
              .margin({ top: 12 })
              .onClick(() => {
                this.inviteFailed = true;
              })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 14 })
        }
        .width('100%')
        .margin({ top: 16 })
      }
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
    .margin({ top: 14 })
  }

  @Builder
  QrMock() {
    Column() {
      Row() {
        this.QrCell(true)
        this.QrCell(false)
        this.QrCell(true)
        this.QrCell(true)
        this.QrCell(false)
      }
      Row() {
        this.QrCell(true)
        this.QrCell(false)
        this.QrCell(true)
        this.QrCell(false)
        this.QrCell(true)
      }
      Row() {
        this.QrCell(false)
        this.QrCell(true)
        this.QrCell(true)
        this.QrCell(false)
        this.QrCell(true)
      }
      Row() {
        this.QrCell(true)
        this.QrCell(true)
        this.QrCell(false)
        this.QrCell(false)
        this.QrCell(true)
      }
      Row() {
        this.QrCell(false)
        this.QrCell(true)
        this.QrCell(true)
        this.QrCell(false)
        this.QrCell(true)
      }
    }
    .width(86)
    .height(86)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: '#16000000' })
    .borderRadius(18)
  }

  @Builder
  QrCell(filled: boolean) {
    Column()
      .width(10)
      .height(10)
      .backgroundColor(filled ? '#11151D' : '#FFFFFF')
      .margin({ left: 2, right: 2, top: 2, bottom: 2 })
  }

  @Builder
  PermissionCard() {
    Row() {
      this.PermissionItem('远程控制', '管理员可用')
      this.PermissionItem('设备新增', '拥有者确认')
      this.PermissionItem('访客模式', '限时开放')
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 12, bottom: 12 })
    .backgroundColor(this.cardColor())
    .borderRadius(22)
    .margin({ top: 14 })
  }

  @Builder
  PermissionItem(title: string, desc: string) {
    Column() {
      Text(title)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .maxLines(1)
      Text(desc)
        .fontSize(11)
        .fontColor(this.secondaryText())
        .margin({ top: 5 })
        .maxLines(1)
    }
    .layoutWeight(1)
    .height(58)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  MemberHeader() {
    Row() {
      Text('成员与权限')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .layoutWeight(1)

      Button(this.showEmpty ? '恢复' : '添加成员')
        .height(32)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5E8CFF')
        .backgroundColor(this.isNight ? '#335E8CFF' : '#EAF0FF')
        .borderRadius(16)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          if (this.showEmpty) {
            this.showEmpty = false;
          } else {
            this.showNewMember = !this.showNewMember;
          }
        })
    }
    .width('100%')
    .margin({ top: 22, bottom: 10 })
  }

  @Builder
  AddMemberPanel() {
    Column() {
      Text('选择成员')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
        .width('100%')
      Row() {
        this.MemberOptionChip('妈妈', 'name')
        this.MemberOptionChip('爸爸', 'name')
        this.MemberOptionChip('孩子', 'name')
      }
      .width('100%')
      .margin({ top: 12 })
      Row() {
        this.MemberOptionChip('管理员', 'role')
        this.MemberOptionChip('普通成员', 'role')
        this.MemberOptionChip('访客', 'role')
      }
      .width('100%')
      .margin({ top: 10 })
      Row() {
        Button('取消')
          .layoutWeight(1)
          .height(38)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
          .backgroundColor(this.softColor())
          .borderRadius(19)
          .margin({ right: 8 })
          .onClick(() => {
            this.showNewMember = false;
          })
        Button(this.hasCustomMember ? '更新成员' : '确认添加')
          .layoutWeight(1)
          .height(38)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isNight ? '#11151D' : '#FFFFFF')
          .backgroundColor(this.isNight ? '#F5F7FB' : '#11151D')
          .borderRadius(19)
          .margin({ left: 8 })
          .onClick(() => {
            this.customMemberName = this.selectedMemberName;
            this.customMemberRole = this.selectedMemberRole;
            this.hasCustomMember = true;
            this.showNewMember = false;
            this.showEmpty = false;
          })
      }
      .width('100%')
      .margin({ top: 14 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(this.cardColor())
    .borderRadius(22)
    .margin({ top: 10 })
  }

  @Builder
  MemberOptionChip(label: string, type: string) {
    Text(label)
      .fontSize(12)
      .fontWeight(((type === 'name' && this.selectedMemberName === label) || (type === 'role' && this.selectedMemberRole === label)) ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(((type === 'name' && this.selectedMemberName === label) || (type === 'role' && this.selectedMemberRole === label)) ? (this.isNight ? '#11151D' : '#FFFFFF') : this.primaryText())
      .padding({ left: 13, right: 13, top: 9, bottom: 9 })
      .backgroundColor(((type === 'name' && this.selectedMemberName === label) || (type === 'role' && this.selectedMemberRole === label)) ? (this.isNight ? '#F5F7FB' : '#11151D') : this.softColor())
      .borderRadius(17)
      .margin({ right: 8 })
      .onClick(() => {
        if (type === 'name') {
          this.selectedMemberName = label;
        } else {
          this.selectedMemberRole = label;
        }
      })
  }

  @Builder
  MemberRow(member: FamilyMemberSpec) {
    Row() {
      Text(member.name.substring(0, 1))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width(46)
        .height(46)
        .textAlign(TextAlign.Center)
        .backgroundColor(member.accent)
        .borderRadius(17)

      Column() {
        Text(member.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryText())
        Text(`${member.role} · ${member.status}`)
          .fontSize(12)
          .fontColor(this.secondaryText())
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 14 })

      if (member.id === 'owner') {
        Text('拥有者')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5E8CFF')
      } else {
        Button('移除')
          .height(32)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#D35B4B')
          .backgroundColor(this.isNight ? '#33D35B4B' : '#FFF1EF')
          .borderRadius(16)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            if (member.id === 'guest') {
              this.hideGuest = true;
            } else if (member.id === 'new_member') {
              this.hasCustomMember = false;
              this.showNewMember = false;
            }
          })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(this.cardColor())
    .borderRadius(22)
    .margin({ top: 10 })
  }

  @Builder
  EmptyMemberState() {
    Column() {
      Text('暂无家庭成员')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.primaryText())
      Text('创建家庭后，可通过二维码、手机号或近场发现邀请成员。')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(this.secondaryText())
        .textAlign(TextAlign.Center)
        .margin({ top: 8 })
      Button('恢复成员示例')
        .height(40)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#5E8CFF')
        .borderRadius(20)
        .padding({ left: 18, right: 18 })
        .margin({ top: 18 })
        .onClick(() => {
          this.showEmpty = false;
        })
    }
    .width('100%')
    .padding({ left: 28, right: 28, top: 54, bottom: 54 })
    .backgroundColor(this.cardColor())
    .borderRadius(24)
  }
}
