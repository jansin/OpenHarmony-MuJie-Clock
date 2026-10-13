import { AlarmItem, ClockTheme, formatRingtoneLabel } from './ClockModels'
import { SecondaryTitleBar } from './SecondaryTitleBar'
import { repeatPickerSummary } from '../common/AlarmRepeat'
import { MUJIE_CARD_RADIUS, MUJIE_SCREEN_PAD_H, MUJIE_SCREEN_PAD_TOP } from '../common/UiTokens'

function buildAlarmHourLabels(): string[] {
  const h: string[] = []
  for (let i = 0; i < 24; i++) {
    h.push(i < 10 ? `0${i}` : `${i}`)
  }
  return h
}

function buildAlarmMinuteLabels(): string[] {
  const m: string[] = []
  for (let i = 0; i < 60; i++) {
    m.push(i < 10 ? `0${i}` : `${i}`)
  }
  return m
}

const ALARM_HOUR_LABELS: string[] = buildAlarmHourLabels()
const ALARM_MINUTE_LABELS: string[] = buildAlarmMinuteLabels()

const SHEET_REPEAT_LABELS: string[] = ['不重复', '每天', '工作日', '周末']
const SHEET_REPEAT_MODES: string[] = ['Once', 'Every day', 'Weekdays', 'Weekends']
const SHEET_DURATION_LABELS: string[] = ['1 分钟', '3 分钟', '5 分钟', '10 分钟']

/** 闹钟编辑页时间滚轮：压低高度，为下方设置项留出空间 */
const ALARM_EDIT_PICKER_VIEW_HEIGHT: number = 118
const ALARM_EDIT_PICKER_ITEM_HEIGHT: number = 32

/** 底部选项表类型（与 handleSheetPick 分支一致） */
const ALARM_SHEET_NONE: number = -1
const ALARM_SHEET_REPEAT: number = 0
const ALARM_SHEET_RINGTONE: number = 1
const ALARM_SHEET_DURATION: number = 2
const ALARM_SHEET_SNOOZE: number = 3

@Component
export struct AlarmEditPage {
  @Prop theme: ClockTheme = new ClockTheme()
  nextId: number = 1
  @Prop @Watch('onInitialAlarmChanged') initialAlarm: AlarmItem | undefined = undefined
  onBack: () => void = () => {}
  onSave: (item: AlarmItem) => void = () => {}
  onDelete: (id: number) => void = () => {}
  @State private hour: number = 7
  @State private minute: number = 30
  @State private repeatMode: string = 'Once'
  @State private workdaySkip: boolean = false
  @State private alarmLabel: string = '闹钟'
  @State private ringtoneId: string = 'default'
  @State private ringDurationMinutes: number = 5
  @State private snoozeIntervalMinutes: number = 10
  @State private snoozeMaxCount: number = 3
  @State private initialized: boolean = false

  @State private sheetVisible: boolean = false
  @State private sheetTitle: string = ''
  @State private sheetKind: number = ALARM_SHEET_NONE
  @State private sheetOptionLabels: string[] = []
  /** 与 sheetOptionLabels 等长，ForEach 只遍历下标，避免字符串 ForEach 的 index 参数不可靠 */
  @State private sheetOptionIndices: number[] = []
  /** 底部 sheet 选择后强制设置卡片重建，保证右侧摘要立即更新 */
  @State private settingsDisplayEpoch: number = 0

  private readonly ringtoneIds: string[] = ['default', 'classic', 'soft', 'digital']
  private readonly ringDurations: number[] = [1, 3, 5, 10]
  private readonly snoozePresets: number[][] = [[5, 1], [5, 3], [10, 3], [10, 5], [15, 3]]

  aboutToAppear(): void {
    if (!this.initialized) {
      this.applyFromInitialSource()
      this.initialized = true
    }
  }

  private onInitialAlarmChanged(): void {
    this.applyFromInitialSource()
    this.initialized = true
  }

  private applyFromInitialSource(): void {
    if (this.initialAlarm !== undefined) {
      const src = this.initialAlarm
      const hh = Number(src.hour)
      const mm = Number(src.minute)
      this.hour = isNaN(hh) ? 0 : Math.min(23, Math.max(0, Math.floor(hh)))
      this.minute = isNaN(mm) ? 0 : Math.min(59, Math.max(0, Math.floor(mm)))
      this.repeatMode = src.repeatMode
      this.workdaySkip = src.smartHolidaySkip === true
      this.alarmLabel = src.label.length > 0 ? src.label : '闹钟'
      const rid = src.ringtoneId
      this.ringtoneId = rid !== undefined && rid.length > 0 ? rid : 'default'
      this.ringDurationMinutes = this.normalizeRingDuration(src.ringDurationMinutes)
      this.snoozeIntervalMinutes = src.snoozeIntervalMinutes > 0 ? src.snoozeIntervalMinutes : 10
      this.snoozeMaxCount = src.snoozeMaxCount >= 0 ? src.snoozeMaxCount : 3
    } else {
      const now = new Date()
      this.hour = now.getHours()
      this.minute = now.getMinutes()
      this.repeatMode = 'Once'
      this.workdaySkip = false
      this.alarmLabel = '闹钟'
      this.ringtoneId = 'default'
      this.ringDurationMinutes = 5
      this.snoozeIntervalMinutes = 10
      this.snoozeMaxCount = 3
    }
  }

  private normalizeRingDuration(v: number): number {
    if (v === 1 || v === 3 || v === 5 || v === 10) {
      return v
    }
    return 5
  }

  private saveAlarm(): void {
    const id = this.initialAlarm !== undefined ? this.initialAlarm.id : this.nextId
    const enabled = this.initialAlarm !== undefined ? this.initialAlarm.enabled : true
    const labelTrim = this.alarmLabel.trim()
    this.onSave({
      id: id,
      hour: this.hour,
      minute: this.minute,
      repeatMode: this.repeatMode,
      enabled: enabled,
      label: labelTrim.length > 0 ? labelTrim : '闹钟',
      ringtoneId: this.ringtoneId,
      ringDurationMinutes: this.ringDurationMinutes,
      snoozeIntervalMinutes: this.snoozeIntervalMinutes,
      snoozeMaxCount: this.snoozeMaxCount,
      smartHolidaySkip: this.repeatMode === 'Weekdays' && this.workdaySkip
    })
  }

  private confirmDelete(): void {
    if (this.initialAlarm === undefined) {
      return
    }
    AlertDialog.show({
      title: '删除闹钟',
      message: '确定删除该闹钟吗？',
      primaryButton: {
        value: '删除',
        action: () => {
          this.onDelete(this.initialAlarm!.id)
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {}
      }
    })
  }

  private snoozePresetLabel(interval: number, count: number): string {
    return `${interval} 分钟，${count} 次`
  }

  private snoozeSummary(): string {
    return this.snoozePresetLabel(this.snoozeIntervalMinutes, this.snoozeMaxCount)
  }

  private fillSheetIndices(count: number): void {
    const idx: number[] = []
    for (let i = 0; i < count; i++) {
      idx.push(i)
    }
    this.sheetOptionIndices = idx
  }

  private openRepeatSheet(): void {
    this.sheetKind = ALARM_SHEET_REPEAT
    this.sheetTitle = '重复'
    this.sheetOptionLabels = SHEET_REPEAT_LABELS.slice()
    this.fillSheetIndices(SHEET_REPEAT_LABELS.length)
    this.sheetVisible = true
  }

  private openRingtoneSheet(): void {
    const labels: string[] = []
    for (let i = 0; i < this.ringtoneIds.length; i++) {
      labels.push(formatRingtoneLabel(this.ringtoneIds[i]))
    }
    this.sheetKind = ALARM_SHEET_RINGTONE
    this.sheetTitle = '铃声'
    this.sheetOptionLabels = labels
    this.fillSheetIndices(labels.length)
    this.sheetVisible = true
  }

  private openRingDurationSheet(): void {
    this.sheetKind = ALARM_SHEET_DURATION
    this.sheetTitle = '响铃时长'
    this.sheetOptionLabels = SHEET_DURATION_LABELS.slice()
    this.fillSheetIndices(SHEET_DURATION_LABELS.length)
    this.sheetVisible = true
  }

  private openSnoozeSheet(): void {
    const labels: string[] = []
    for (let i = 0; i < this.snoozePresets.length; i++) {
      const p = this.snoozePresets[i]
      labels.push(this.snoozePresetLabel(p[0], p[1]))
    }
    this.sheetKind = ALARM_SHEET_SNOOZE
    this.sheetTitle = '稍后提醒'
    this.sheetOptionLabels = labels
    this.fillSheetIndices(labels.length)
    this.sheetVisible = true
  }

  private handleSheetPick(index: number): void {
    if (this.sheetKind === ALARM_SHEET_REPEAT) {
      if (index >= 0 && index < SHEET_REPEAT_MODES.length) {
        this.repeatMode = SHEET_REPEAT_MODES[index]
        if (this.repeatMode !== 'Weekdays') {
          this.workdaySkip = false
        }
      }
    } else if (this.sheetKind === ALARM_SHEET_RINGTONE) {
      if (index >= 0 && index < this.ringtoneIds.length) {
        this.ringtoneId = this.ringtoneIds[index]
      }
    } else if (this.sheetKind === ALARM_SHEET_DURATION) {
      if (index >= 0 && index < this.ringDurations.length) {
        this.ringDurationMinutes = this.ringDurations[index]
      }
    } else if (this.sheetKind === ALARM_SHEET_SNOOZE) {
      if (index >= 0 && index < this.snoozePresets.length) {
        this.snoozeIntervalMinutes = this.snoozePresets[index][0]
        this.snoozeMaxCount = this.snoozePresets[index][1]
      }
    }
    this.sheetVisible = false
    this.sheetKind = ALARM_SHEET_NONE
    this.settingsDisplayEpoch = this.settingsDisplayEpoch + 1
  }

  private closeSheetOnly(): void {
    this.sheetVisible = false
    this.sheetKind = ALARM_SHEET_NONE
    this.sheetOptionIndices = []
  }

  build() {
    Column() {
      SecondaryTitleBar({
        title: this.initialAlarm !== undefined ? '编辑闹钟' : '新建闹钟',
        theme: this.theme,
        rightText: '✓',
        onLeft: () => {
          this.onBack()
        },
        onRight: () => {
          this.saveAlarm()
        }
      })

      Scroll() {
        Column() {
          Row() {
            TextPicker({ range: ALARM_HOUR_LABELS, selected: this.hour })
              .layoutWeight(1)
              .height(ALARM_EDIT_PICKER_VIEW_HEIGHT)
              .defaultPickerItemHeight(ALARM_EDIT_PICKER_ITEM_HEIGHT)
              .canLoop(true)
              .onChange((value: string | string[], index: number | number[]) => {
                const idx = Array.isArray(index) ? index[0] : index
                if (typeof idx === 'number' && idx >= 0 && idx < 24) {
                  this.hour = idx
                }
              })
            Text(':')
              .fontColor(this.theme.text)
              .fontSize(22)
              .fontWeight(FontWeight.Medium)
              .margin({ left: 4, right: 4, bottom: 18 })
            TextPicker({ range: ALARM_MINUTE_LABELS, selected: this.minute })
              .layoutWeight(1)
              .height(ALARM_EDIT_PICKER_VIEW_HEIGHT)
              .defaultPickerItemHeight(ALARM_EDIT_PICKER_ITEM_HEIGHT)
              .canLoop(true)
              .onChange((value: string | string[], index: number | number[]) => {
                const idx = Array.isArray(index) ? index[0] : index
                if (typeof idx === 'number' && idx >= 0 && idx < 60) {
                  this.minute = idx
                }
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .margin({ top: 8, bottom: 4 })

          Column() {
            this.RepeatSettingRow()
            if (this.repeatMode === 'Weekdays') {
              Divider().color(this.theme.cardBorder).height(1).margin({ left: 20, right: 20 })
              this.WorkdayRow()
            }
            Divider().color(this.theme.cardBorder).height(1).margin({ left: 20, right: 20 })
            this.RingtoneSettingRow()
            Divider().color(this.theme.cardBorder).height(1).margin({ left: 20, right: 20 })
            this.NameRow()
            Divider().color(this.theme.cardBorder).height(1).margin({ left: 20, right: 20 })
            this.RingDurationSettingRow()
            Divider().color(this.theme.cardBorder).height(1).margin({ left: 20, right: 20 })
            this.SnoozeSettingRow()
          }
          .width('100%')
          .borderRadius(MUJIE_CARD_RADIUS)
          .borderWidth(1)
          .borderColor(this.theme.cardBorder)
          .backgroundColor(this.theme.card)
          .margin({ top: 8 })

          Text('说明：铃声为界面内标识，不响真实音频；稍后提醒在到点后通过弹窗再次提醒。')
            .fontColor(this.theme.muted)
            .fontSize(11)
            .width('100%')
            .lineHeight(16)
            .margin({ top: 12, left: 4, right: 4 })

          if (this.initialAlarm !== undefined) {
            Button('删除闹钟')
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#D32F2F')
              .backgroundColor('rgba(229, 57, 53, 0.10)')
              .borderColor('rgba(229, 57, 53, 0.32)')
              .borderWidth(1)
              .borderRadius(12)
              .type(ButtonType.Normal)
              .stateEffect(true)
              .margin({ top: 20 })
              .onClick(() => {
                this.confirmDelete()
              })
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ bottom: 28 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .padding({ left: MUJIE_SCREEN_PAD_H, right: MUJIE_SCREEN_PAD_H, top: MUJIE_SCREEN_PAD_TOP, bottom: 20 })
    .backgroundColor(this.theme.pageBg)
    .bindSheet(this.sheetVisible, this.sheetPickerBuilder(), {
      height: 380,
      dragBar: true,
      backgroundColor: this.theme.card,
      onDisappear: (): void => {
        this.closeSheetOnly()
      }
    })
  }

  @Builder
  sheetPickerBuilder() {
    Column() {
      Text(this.sheetTitle)
        .fontSize(18)
        .fontColor(this.theme.text)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ top: 18, bottom: 16, left: 20, right: 20 })

      Scroll() {
        Column({ space: 0 }) {
          ForEach(this.sheetOptionIndices, (idx: number) => {
            this.SheetOptionItem(idx)
          }, (idx: number) => `sheet-${this.sheetKind}-${idx}`)
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      Column() {
        Divider().color(this.theme.cardBorder).height(1)
        Text('取消')
          .width('100%')
          .height(52)
          .fontSize(17)
          .fontColor(this.theme.text)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.closeSheetOnly()
          })
      }
      .backgroundColor(this.theme.card)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.card)
  }

  @Builder
  SheetOptionItem(index: number) {
    Row() {
      Text(this.sheetOptionLabels[index])
        .fontSize(16)
        .fontColor(this.theme.text)

      Blank()

      if (this.isOptionSelected(index)) {
        Text('✓')
          .fontColor(this.theme.selectedNav)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
      }
    }
    .width('100%')
    .height(52)
    .padding({ left: 22, right: 22 })
    .backgroundColor(this.isOptionSelected(index) ? this.theme.navTabActiveBg : Color.Transparent)
    .borderWidth({ bottom: 1 })
    .borderColor(this.theme.cardBorder)
    .onClick(() => {
      this.handleSheetPick(index)
    })
  }

  private isOptionSelected(index: number): boolean {
    if (this.sheetKind === ALARM_SHEET_REPEAT) {
      const mode = SHEET_REPEAT_MODES[index]
      return this.repeatMode === mode
    } else if (this.sheetKind === ALARM_SHEET_RINGTONE) {
      return this.ringtoneId === this.ringtoneIds[index]
    } else if (this.sheetKind === ALARM_SHEET_DURATION) {
      return this.ringDurationMinutes === this.ringDurations[index]
    } else if (this.sheetKind === ALARM_SHEET_SNOOZE) {
      const p = this.snoozePresets[index]
      return this.snoozeIntervalMinutes === p[0] && this.snoozeMaxCount === p[1]
    }
    return false
  }

  @Builder
  NameRow() {
    Row() {
      Text('闹钟名')
        .fontColor(this.theme.text)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
      Blank()
      TextInput({ text: this.alarmLabel, placeholder: '闹钟' })
        .layoutWeight(1)
        .height(40)
        .fontSize(14)
        .fontColor(this.theme.text)
        .backgroundColor(this.theme.pageBg)
        .borderRadius(8)
        .padding({ left: 10, right: 10 })
        .onChange((v: string) => {
          this.alarmLabel = v
        })
    }
    .width('100%')
    .height(62)
    .padding({ left: 20, right: 18 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  PickSettingRow(title: string, summary: string, onPick: () => void) {
    Row() {
      Text(title)
        .fontColor(this.theme.text)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
      Blank()
      if (summary.length > 0) {
        Text(summary)
          .fontColor(this.theme.muted)
          .fontSize(12)
          .margin({ right: 8 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .constraintSize({ maxWidth: '52%' })
      }
      Text('›')
        .fontColor(this.theme.muted)
        .fontSize(22)
    }
    .width('100%')
    .height(62)
    .padding({ left: 20, right: 18 })
    .alignItems(VerticalAlign.Center)
    .stateStyles({
      pressed: {
        .opacity(0.55)
      },
      normal: {
        .opacity(1)
      }
    })
    .onClick(() => {
      onPick()
    })
  }

  @Builder
  WorkdayRow() {
    Row() {
      Column() {
        Text('法定工作日 (智能跳过节假日)')
          .fontColor(this.theme.text)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
        Text('通过移动网络或 WLAN 下载更新节假信息')
          .fontColor(this.theme.muted)
          .fontSize(12)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Row() {
        Circle()
          .width(32)
          .height(32)
          .fill('#FFFFFF')
      }
      .width(62)
      .height(36)
      .padding(2)
      .justifyContent(this.workdaySkip ? FlexAlign.End : FlexAlign.Start)
      .borderRadius(18)
      .backgroundColor(this.workdaySkip ? this.theme.selectedNav : '#E3E3E3')
      .animation({ duration: 160, curve: Curve.FastOutSlowIn })
    }
    .width('100%')
    .constraintSize({ minHeight: 72 })
    .padding({ left: 20, right: 20, top: 10, bottom: 10 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.workdaySkip = !this.workdaySkip
    })
  }

  @Builder
  RepeatSettingRow() {
    Row() {
      Text('重复')
        .fontColor(this.theme.text)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
      Blank()
      Text(repeatPickerSummary(this.repeatMode))
        .fontColor(this.theme.muted)
        .fontSize(12)
        .margin({ right: 8 })
      Text('›')
        .fontColor(this.theme.muted)
        .fontSize(22)
    }
    .width('100%')
    .height(62)
    .padding({ left: 20, right: 18 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.openRepeatSheet()
    })
  }

  @Builder
  RingtoneSettingRow() {
    Row() {
      Text('铃声')
        .fontColor(this.theme.text)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
      Blank()
      Text(formatRingtoneLabel(this.ringtoneId))
        .fontColor(this.theme.muted)
        .fontSize(12)
        .margin({ right: 8 })
      Text('›')
        .fontColor(this.theme.muted)
        .fontSize(22)
    }
    .width('100%')
    .height(62)
    .padding({ left: 20, right: 18 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.openRingtoneSheet()
    })
  }

  @Builder
  RingDurationSettingRow() {
    Row() {
      Text('响铃时长')
        .fontColor(this.theme.text)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
      Blank()
      Text(`${this.ringDurationMinutes} 分钟`)
        .fontColor(this.theme.muted)
        .fontSize(12)
        .margin({ right: 8 })
      Text('›')
        .fontColor(this.theme.muted)
        .fontSize(22)
    }
    .width('100%')
    .height(62)
    .padding({ left: 20, right: 18 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.openRingDurationSheet()
    })
  }

  @Builder
  SnoozeSettingRow() {
    Row() {
      Text('稍后提醒')
        .fontColor(this.theme.text)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
      Blank()
      Text(this.snoozeSummary())
        .fontColor(this.theme.muted)
        .fontSize(12)
        .margin({ right: 8 })
      Text('›')
        .fontColor(this.theme.muted)
        .fontSize(22)
    }
    .width('100%')
    .height(62)
    .padding({ left: 20, right: 18 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.openSnoozeSheet()
    })
  }

}
