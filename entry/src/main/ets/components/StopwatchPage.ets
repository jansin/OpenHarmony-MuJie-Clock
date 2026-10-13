import { ClockTheme } from './ClockModels'
import { StopwatchDial } from './ClockDial'
import { copyPlainTextWithToast } from '../common/PlainTextClipboard'
import { MUJIE_FAB_GHOST_FILL, MUJIE_FAB_PLUS_FONT, MUJIE_FAB_SIZE, MUJIE_SPACE_BELOW_DIAL } from '../common/UiTokens'

interface StopwatchLapRow {
  lapNo: number
  splitMs: number
  totalMs: number
}

interface LapRowVisual {
  splitColor: string
  rowBg: string
  splitWeight: FontWeight
}

@Component
export struct StopwatchPage {
  @Prop theme: ClockTheme = new ClockTheme()
  /** 主 Tab 可见时为 true；不可见时暂停高频 tick 并按墙钟补偿 */
  @Prop @Watch('onIsPageActiveChange') isPageActive: boolean = true
  @State private elapsedMs: number = 0
  @State private running: boolean = false
  @State private lapRows: StopwatchLapRow[] = []
  private timerId: number = -1
  private lastLapAtMs: number = 0
  private wallMsWhenBackgrounded: number = 0

  onIsPageActiveChange(): void {
    if (this.isPageActive) {
      this.resumeRunningTickIfNeeded()
    } else {
      this.pauseTickForTabSwitch()
    }
  }

  aboutToAppear(): void {
    if (this.isPageActive) {
      this.resumeRunningTickIfNeeded()
    }
  }

  aboutToDisappear(): void {
    this.pauseTickForTabSwitch()
  }

  private pauseTickForTabSwitch(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
    if (this.running) {
      this.wallMsWhenBackgrounded = new Date().getTime()
    }
  }

  private resumeRunningTickIfNeeded(): void {
    if (!this.running || this.timerId !== -1) {
      return
    }
    if (this.wallMsWhenBackgrounded > 0) {
      this.elapsedMs += new Date().getTime() - this.wallMsWhenBackgrounded
      this.wallMsWhenBackgrounded = 0
    }
    this.timerId = setInterval(() => {
      this.elapsedMs += 10
    }, 10)
  }

  private startTick(): void {
    if (this.timerId !== -1) {
      return
    }
    this.running = true
    this.wallMsWhenBackgrounded = 0
    this.timerId = setInterval(() => {
      this.elapsedMs += 10
    }, 10)
  }

  private stopTick(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
    this.running = false
    this.wallMsWhenBackgrounded = 0
  }

  private resetStopwatch(): void {
    this.stopTick()
    this.elapsedMs = 0
    this.lapRows = []
    this.lastLapAtMs = 0
  }

  /** 仅清空计次列表，主计时保留；下一圈从当前累计时间起算 */
  private clearLapsOnly(): void {
    this.lapRows = []
    this.lastLapAtMs = this.elapsedMs
  }

  private buildLapsExportText(): string {
    const lines: string[] = []
    lines.push(`主计时 ${this.formatTime(this.elapsedMs)}`)
    lines.push('计次\t单圈\t累计')
    for (let i = 0; i < this.lapRows.length; i++) {
      const r = this.lapRows[i]
      lines.push(`${r.lapNo}\t${this.formatTime(r.splitMs)}\t${this.formatTime(r.totalMs)}`)
    }
    return lines.join('\n')
  }

  private copyLapsToClipboard(): void {
    if (this.lapRows.length === 0) {
      return
    }
    copyPlainTextWithToast(this.buildLapsExportText(), getContext(this).resourceManager.getStringSync($r('app.string.laps_copied')))
  }

  private stopwatchStatusText(): string {
    const ctx = getContext(this)
    if (this.running) {
      return ctx.resourceManager.getStringSync($r('app.string.stopwatch_running'))
    }
    if (this.elapsedMs > 0) {
      return ctx.resourceManager.getStringSync($r('app.string.stopwatch_paused'))
    }
    return ctx.resourceManager.getStringSync($r('app.string.stopwatch_idle'))
  }

  private recordLap(): void {
    if (!this.running || this.elapsedMs <= 0) {
      return
    }
    const split: number = this.elapsedMs - this.lastLapAtMs
    if (split <= 0) {
      return
    }
    this.lastLapAtMs = this.elapsedMs
    const no: number = this.lapRows.length + 1
    const row: StopwatchLapRow = {
      lapNo: no,
      splitMs: split,
      totalMs: this.elapsedMs
    }
    this.lapRows = this.lapRows.concat([row])
  }

  private minSplitMsAmongLaps(): number {
    if (this.lapRows.length === 0) {
      return -1
    }
    let m: number = this.lapRows[0].splitMs
    for (let i = 1; i < this.lapRows.length; i++) {
      if (this.lapRows[i].splitMs < m) {
        m = this.lapRows[i].splitMs
      }
    }
    return m
  }

  private maxSplitMsAmongLaps(): number {
    if (this.lapRows.length === 0) {
      return -1
    }
    let m: number = this.lapRows[0].splitMs
    for (let i = 1; i < this.lapRows.length; i++) {
      if (this.lapRows[i].splitMs > m) {
        m = this.lapRows[i].splitMs
      }
    }
    return m
  }

  private isFastestSplitAt(idx: number): boolean {
    if (this.lapRows.length < 2) {
      return false
    }
    const minv: number = this.minSplitMsAmongLaps()
    return this.lapRows[idx].splitMs === minv
  }

  /** 单圈最慢（至少两圈且快慢不完全相同才标出） */
  private isSlowestSplitAt(idx: number): boolean {
    if (this.lapRows.length < 2) {
      return false
    }
    const minv: number = this.minSplitMsAmongLaps()
    const maxv: number = this.maxSplitMsAmongLaps()
    if (minv === maxv) {
      return false
    }
    return this.lapRows[idx].splitMs === maxv
  }

  private lapRowVisual(idx: number): LapRowVisual {
    const fastest: boolean = this.isFastestSplitAt(idx)
    const slowest: boolean = this.isSlowestSplitAt(idx)
    if (fastest) {
      const v: LapRowVisual = {
        splitColor: this.theme.selectedNav,
        rowBg: 'rgba(24, 119, 242, 0.14)',
        splitWeight: FontWeight.Bold
      }
      return v
    }
    if (slowest) {
      const v: LapRowVisual = {
        splitColor: '#B85C14',
        rowBg: 'rgba(184, 92, 20, 0.12)',
        splitWeight: FontWeight.Bold
      }
      return v
    }
    const v: LapRowVisual = {
      splitColor: this.theme.text,
      rowBg: this.theme.navTabActiveBg,
      splitWeight: FontWeight.Regular
    }
    return v
  }

  private reversedLapIndices(): number[] {
    const n: number = this.lapRows.length
    const out: number[] = []
    for (let i = n - 1; i >= 0; i--) {
      out.push(i)
    }
    return out
  }

  build() {
    Column() {
      StopwatchDial({ diameter: 248, theme: this.theme, elapsedMs: this.elapsedMs })

      Text(this.formatTime(this.elapsedMs))
        .fontColor(this.theme.text)
        .fontSize(30)
        .fontWeight(FontWeight.Medium)
        .fontFamily('monospace')
        .margin({ top: MUJIE_SPACE_BELOW_DIAL, bottom: 8 })

      Text(this.stopwatchStatusText())
        .fontColor(this.theme.muted)
        .fontSize(12)
        .margin({ bottom: 6 })

      if (this.lapRows.length > 0) {
        Row({ space: 20 }) {
          Text($r('app.string.clear_laps'))
            .fontColor(this.theme.selectedNav)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              this.clearLapsOnly()
            })
          Text($r('app.string.copy_laps'))
            .fontColor(this.theme.selectedNav)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              this.copyLapsToClipboard()
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 8 })
      }

      Scroll() {
        Column() {
          if (this.lapRows.length > 0) {
            Column() {
              Row() {
                Text($r('app.string.lap_no_header'))
                  .fontColor(this.theme.muted)
                  .fontSize(11)
                  .width('18%')
                Text($r('app.string.split_time_header'))
                  .fontColor(this.theme.muted)
                  .fontSize(11)
                  .width('38%')
                Text($r('app.string.total_time_header'))
                  .fontColor(this.theme.muted)
                  .fontSize(11)
                  .layoutWeight(1)
              }
              .width('100%')
              .padding({ left: 12, right: 12, bottom: 8 })

              ForEach(this.reversedLapIndices(), (idx: number) => {
                Row() {
                  Text(`${this.lapRows[idx].lapNo}`)
                    .fontColor(this.theme.text)
                    .fontSize(14)
                    .width('18%')
                  Text(this.formatTime(this.lapRows[idx].splitMs))
                    .fontColor(this.lapRowVisual(idx).splitColor)
                    .fontSize(14)
                    .fontWeight(this.lapRowVisual(idx).splitWeight)
                    .fontFamily('monospace')
                    .width('38%')
                  Text(this.formatTime(this.lapRows[idx].totalMs))
                    .fontColor(this.theme.muted)
                    .fontSize(14)
                    .fontFamily('monospace')
                    .layoutWeight(1)
                }
                .width('100%')
                .padding({ left: 12, right: 12, top: 10, bottom: 10 })
                .borderRadius(10)
                .backgroundColor(this.lapRowVisual(idx).rowBg)
                .margin({ bottom: 6 })
              }, (idx: number) => `lap-${idx}`)
            }
            .width('100%')
            .padding({ bottom: 8 })
          } else {
            Blank()
              .width('100%')
              .layoutWeight(1)
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)

      Row() {
        Stack() {
          Circle()
            .width(MUJIE_FAB_SIZE)
            .height(MUJIE_FAB_SIZE)
            .fill(MUJIE_FAB_GHOST_FILL)
          Text('↻')
            .fontColor(this.elapsedMs === 0 ? this.theme.muted : this.theme.text)
            .fontSize(MUJIE_FAB_PLUS_FONT)
        }
        .width(MUJIE_FAB_SIZE)
        .height(MUJIE_FAB_SIZE)
        .opacity(this.elapsedMs === 0 ? 0.45 : 1)
        .onClick(() => {
          this.resetStopwatch()
        })

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
        .accessibilityText(this.running ? $r('app.string.stopwatch_pause') : $r('app.string.stopwatch_start'))
        .onClick(() => {
          if (this.running) {
            this.stopTick()
          } else {
            this.startTick()
          }
        })

        Stack() {
          Circle()
            .width(MUJIE_FAB_SIZE)
            .height(MUJIE_FAB_SIZE)
            .fill(MUJIE_FAB_GHOST_FILL)
          Text('◷')
            .fontColor(this.elapsedMs === 0 ? this.theme.muted : this.theme.text)
            .fontSize(MUJIE_FAB_PLUS_FONT)
        }
        .width(MUJIE_FAB_SIZE)
        .height(MUJIE_FAB_SIZE)
        .opacity(this.elapsedMs === 0 ? 0.45 : 1)
        .accessibilityText($r('app.string.lap_no_header'))
        .onClick(() => {
          this.recordLap()
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

  private formatTime(ms: number): string {
    const totalSeconds = Math.floor(ms / 1000)
    const minutes = Math.floor(totalSeconds / 60)
    const seconds = totalSeconds % 60
    const centiseconds = Math.floor(ms % 1000 / 10)
    return `${this.pad(minutes)}:${this.pad(seconds)}.${this.pad(centiseconds)}`
  }

  private pad(value: number): string {
    return value < 10 ? `0${value}` : `${value}`
  }
}
