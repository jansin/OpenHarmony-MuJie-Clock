import { ClockTheme } from './ClockModels'
import { TimerDial } from './ClockDial'
import { vibrateTimerFinished } from '../common/TimerVibrate'
import { MUJIE_FAB_GHOST_FILL, MUJIE_FAB_PLUS_FONT, MUJIE_FAB_SIZE, MUJIE_SPACE_BELOW_DIAL } from '../common/UiTokens'

const SECONDS_PER_HOUR = 3600
const SECONDS_PER_MINUTE = 60
const MAX_TIMER_HOURS = 99
const CIRCLE_DEGREES = 360
const HOUR_PICKER_RANGE = 100
const MINUTE_PICKER_RANGE = 60

function buildTimerHourLabels(): string[] {
  const h: string[] = []
  for (let i = 0; i < HOUR_PICKER_RANGE; i++) {
    h.push(i < 10 ? `0${i}` : `${i}`)
  }
  return h
}

function buildTimerMinSecLabels(): string[] {
  const m: string[] = []
  for (let i = 0; i < MINUTE_PICKER_RANGE; i++) {
    m.push(i < 10 ? `0${i}` : `${i}`)
  }
  return m
}

const TIMER_HOUR_LABELS: string[] = buildTimerHourLabels()
const TIMER_MIN_SEC_LABELS: string[] = buildTimerMinSecLabels()
/** 计时器页滚轮区不宜过高，避免挤占底部播放/重置与 Tab */
const TIMER_PICKER_VIEW_HEIGHT: number = 108
const TIMER_PICKER_ITEM_HEIGHT: number = 30

@Component
export struct TimerPage {
  @Prop theme: ClockTheme = new ClockTheme()
  @State private selectedHours: number = 0
  @State private selectedMinutes: number = 3
  @State private selectedSeconds: number = 0
  @State private remainingSeconds: number = 0
  @State private running: boolean = false
  @State private presetIndex: number = 0
  private timerId: number = -1
  private readonly presetSeconds: number[] = [60, 180, 300, 600, 900, 1800]
  private readonly presetChipLabels: Resource[] = [
    $r('app.string.preset_1m'), $r('app.string.preset_3m'), $r('app.string.preset_5m'),
    $r('app.string.preset_10m'), $r('app.string.preset_15m'), $r('app.string.preset_30m')
  ]

  aboutToDisappear(): void {
    this.stopTick()
  }

  private startTick(): void {
    if (this.timerId !== -1) {
      return
    }
    if (this.remainingSeconds === 0) {
      this.remainingSeconds = this.selectedHours * SECONDS_PER_HOUR + this.selectedMinutes * SECONDS_PER_MINUTE + this.selectedSeconds
    }
    if (this.remainingSeconds === 0) {
      return
    }
    this.running = true
    this.timerId = setInterval(() => {
      if (this.remainingSeconds <= 1) {
        this.remainingSeconds = 0
        this.stopTick()
        this.showFinishedDialog()
      } else {
        this.remainingSeconds--
      }
    }, 1000)
  }

  private showFinishedDialog(): void {
    vibrateTimerFinished()
    const ctx = getContext(this)
    AlertDialog.show({
      title: ctx.resourceManager.getStringSync($r('app.string.timer_finished_title')),
      message: ctx.resourceManager.getStringSync($r('app.string.timer_finished_msg')),
      primaryButton: {
        value: ctx.resourceManager.getStringSync($r('app.string.timer_confirm')),
        action: () => {}
      }
    })
  }

  /**
   * @param syncPickersFromRemaining 暂停计时时为 true，将滚轮同步为当前剩余时间；
   * 自然结束、重置等场景传 false，避免覆盖用户设定的时长。
   */
  private stopTick(syncPickersFromRemaining: boolean = true): void {
    const rem = this.remainingSeconds
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
    this.running = false
    if (syncPickersFromRemaining && rem > 0) {
      this.selectedHours = Math.floor(rem / SECONDS_PER_HOUR)
      this.selectedMinutes = Math.floor((rem % SECONDS_PER_HOUR) / SECONDS_PER_MINUTE)
      this.selectedSeconds = rem % SECONDS_PER_MINUTE
    }
  }

  private resetTimer(): void {
    this.stopTick(false)
    this.remainingSeconds = 0
  }

  private displaySeconds(): number {
    if (this.remainingSeconds > 0 || this.running) {
      return this.remainingSeconds
    }
    return this.selectedHours * SECONDS_PER_HOUR + this.selectedMinutes * SECONDS_PER_MINUTE + this.selectedSeconds
  }

  private totalPresetSeconds(): number {
    return this.selectedHours * SECONDS_PER_HOUR + this.selectedMinutes * SECONDS_PER_MINUTE + this.selectedSeconds
  }

  /** 未在运行且没有可恢复的剩余秒数时，若预设总时长为 0 则无法开始 */
  private cannotStartCountdown(): boolean {
    if (this.running) {
      return false
    }
    if (this.remainingSeconds > 0) {
      return false
    }
    return this.totalPresetSeconds() <= 0
  }

  private dialProgressDegrees(): number {
    const total = this.totalPresetSeconds()
    if (total <= 0) {
      return 0
    }
    const rem = this.displaySeconds()
    return CIRCLE_DEGREES * rem / total
  }

  private applyNextPreset(): void {
    if (this.running) {
      return
    }
    const sec = this.presetSeconds[this.presetIndex % this.presetSeconds.length]
    this.presetIndex = this.presetIndex + 1
    this.setDurationFromTotalSeconds(sec)
  }

  private applyPresetAtIndex(idx: number): void {
    if (this.running) {
      return
    }
    if (idx < 0 || idx >= this.presetSeconds.length) {
      return
    }
    this.presetIndex = idx
    this.setDurationFromTotalSeconds(this.presetSeconds[idx])
  }

  private isPresetChipActive(idx: number): boolean {
    if (this.running) {
      return false
    }
    return this.totalPresetSeconds() === this.presetSeconds[idx]
  }

  private setDurationFromTotalSeconds(sec: number): void {
    const s = Math.max(0, Math.min(sec, MAX_TIMER_HOURS * SECONDS_PER_HOUR + (SECONDS_PER_MINUTE - 1) * SECONDS_PER_MINUTE + (SECONDS_PER_MINUTE - 1)))
    this.selectedHours = Math.floor(s / SECONDS_PER_HOUR)
    this.selectedMinutes = Math.floor((s % SECONDS_PER_HOUR) / SECONDS_PER_MINUTE)
    this.selectedSeconds = s % SECONDS_PER_MINUTE
    this.remainingSeconds = 0
  }

  private presetHintStr(): string {
    const ctx = getContext(this)
    return ctx.resourceManager.getStringSync(
      this.presetChipLabels[this.presetIndex % this.presetChipLabels.length]
    )
  }

  build() {
    Column() {
      TimerDial({
        diameter: 248,
        theme: this.theme,
        progressDegrees: this.dialProgressDegrees()
      })

      Text(this.formatTime(this.displaySeconds()))
        .fontColor(this.theme.text)
        .fontSize(30)
        .fontWeight(FontWeight.Medium)
        .fontFamily('monospace')
        .margin({ top: MUJIE_SPACE_BELOW_DIAL, bottom: 6 })

      Text(this.running ? $r('app.string.timer_running') :
        (this.cannotStartCountdown() ? $r('app.string.timer_set_hint') : this.presetHintStr()))
        .fontColor(this.theme.muted)
        .fontSize(11)
        .margin({ bottom: 8 })

      Scroll() {
        Row({ space: 8 }) {
          ForEach([0, 1, 2, 3, 4, 5], (idx: number) => {
            Text(this.presetChipLabels[idx])
              .fontColor(this.isPresetChipActive(idx) ? this.theme.selectedNav : this.theme.text)
              .fontSize(12)
              .fontWeight(this.isPresetChipActive(idx) ? FontWeight.Medium : FontWeight.Regular)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .borderRadius(16)
              .backgroundColor(this.isPresetChipActive(idx) ? this.theme.navTabActiveBg : MUJIE_FAB_GHOST_FILL)
              .borderWidth(1)
              .borderColor(this.isPresetChipActive(idx) ? this.theme.selectedNav : this.theme.cardBorder)
              .onClick(() => {
                this.applyPresetAtIndex(idx)
              })
          }, (idx: number) => `preset-chip-${idx}`)
        }
        .padding({ left: 4, right: 4 })
      }
      .width('100%')
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .opacity(this.running ? 0.45 : 1)
      .margin({ bottom: 8 })

      Row() {
        Column() {
          TextPicker({ range: TIMER_HOUR_LABELS, selected: this.selectedHours })
            .width('100%')
            .height(TIMER_PICKER_VIEW_HEIGHT)
            .defaultPickerItemHeight(TIMER_PICKER_ITEM_HEIGHT)
            .canLoop(true)
            .enabled(!this.running)
            .onChange((value: string | string[], index: number | number[]) => {
              const idx = Array.isArray(index) ? index[0] : index
              if (typeof idx === 'number' && idx >= 0 && idx < HOUR_PICKER_RANGE) {
                this.selectedHours = idx
                this.remainingSeconds = 0
              }
            })
          Text($r('app.string.time_hour'))
            .fontColor(this.theme.muted)
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Text(':')
          .fontColor(this.theme.text)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)

        Column() {
          TextPicker({ range: TIMER_MIN_SEC_LABELS, selected: this.selectedMinutes })
            .width('100%')
            .height(TIMER_PICKER_VIEW_HEIGHT)
            .defaultPickerItemHeight(TIMER_PICKER_ITEM_HEIGHT)
            .canLoop(true)
            .enabled(!this.running)
            .onChange((value: string | string[], index: number | number[]) => {
              const idx = Array.isArray(index) ? index[0] : index
              if (typeof idx === 'number' && idx >= 0 && idx < 60) {
                this.selectedMinutes = idx
                this.remainingSeconds = 0
              }
            })
          Text($r('app.string.time_minute'))
            .fontColor(this.theme.muted)
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Text(':')
          .fontColor(this.theme.text)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)

        Column() {
          TextPicker({ range: TIMER_MIN_SEC_LABELS, selected: this.selectedSeconds })
            .width('100%')
            .height(TIMER_PICKER_VIEW_HEIGHT)
            .defaultPickerItemHeight(TIMER_PICKER_ITEM_HEIGHT)
            .canLoop(true)
            .enabled(!this.running)
            .onChange((value: string | string[], index: number | number[]) => {
              const idx = Array.isArray(index) ? index[0] : index
              if (typeof idx === 'number' && idx >= 0 && idx < 60) {
                this.selectedSeconds = idx
                this.remainingSeconds = 0
              }
            })
          Text($r('app.string.time_second'))
            .fontColor(this.theme.muted)
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .opacity(this.running ? 0.5 : 1)
      .margin({ bottom: 4 })

      Blank()
        .layoutWeight(1)

      Row() {
        Stack() {
          Circle()
            .width(MUJIE_FAB_SIZE)
            .height(MUJIE_FAB_SIZE)
            .fill(MUJIE_FAB_GHOST_FILL)
          Text('↻')
            .fontColor(this.theme.text)
            .fontSize(MUJIE_FAB_PLUS_FONT)
        }
        .width(MUJIE_FAB_SIZE)
        .height(MUJIE_FAB_SIZE)
        .onClick(() => {
          this.resetTimer()
        })

        this.PlayAction()

        Stack() {
          Circle()
            .width(MUJIE_FAB_SIZE)
            .height(MUJIE_FAB_SIZE)
            .fill(MUJIE_FAB_GHOST_FILL)
          Text('♢')
            .fontColor(this.running ? this.theme.muted : this.theme.text)
            .fontSize(MUJIE_FAB_PLUS_FONT)
        }
        .width(MUJIE_FAB_SIZE)
        .height(MUJIE_FAB_SIZE)
        .opacity(this.running ? 0.45 : 1)
        .accessibilityText($r('app.string.timer_switch_preset'))
        .onClick(() => {
          this.applyNextPreset()
        })
      }
      .width('100%')
      .padding({ left: 32, right: 32 })
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 24 })
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  PlayAction() {
    Stack() {
      Circle()
        .width(MUJIE_FAB_SIZE)
        .height(MUJIE_FAB_SIZE)
        .fill(this.theme.selectedNav)
      Image(this.running ? $r('app.media.flat_icon_pause') : $r('app.media.flat_icon_play'))
        .width(22)
        .height(22)
        .objectFit(ImageFit.Contain)
        .fillColor(this.theme.text)
    }
    .width(MUJIE_FAB_SIZE)
    .height(MUJIE_FAB_SIZE)
    .opacity(this.cannotStartCountdown() ? 0.42 : 1)
    .onClick(() => {
      if (this.running) {
        this.stopTick(true)
      } else {
        if (this.cannotStartCountdown()) {
          AlertDialog.show({
            title: getContext(this).resourceManager.getStringSync($r('app.string.timer_cannot_start_title')),
            message: getContext(this).resourceManager.getStringSync($r('app.string.timer_cannot_start_msg')),
            primaryButton: {
              value: getContext(this).resourceManager.getStringSync($r('app.string.timer_got_it')),
              action: () => {}
            }
          })
          return
        }
        this.startTick()
      }
    })
  }

  private formatTime(seconds: number): string {
    const hours = Math.floor(seconds / SECONDS_PER_HOUR)
    const minutes = Math.floor(seconds % SECONDS_PER_HOUR / SECONDS_PER_MINUTE)
    const rest = seconds % SECONDS_PER_MINUTE
    return `${this.pad(hours)}:${this.pad(minutes)}:${this.pad(rest)}`
  }

  private pad(value: number): string {
    return value < 10 ? `0${value}` : `${value}`
  }
}
