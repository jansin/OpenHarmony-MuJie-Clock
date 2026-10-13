import { AlarmItem, ClockTheme } from './ClockModels'
import { alarmListRepeatSummary, repeatMatches } from '../common/AlarmRepeat'
import { ClockFace } from './ClockDial'
import {
  MUJIE_CARD_RADIUS,
  MUJIE_FAB_PLUS_FONT,
  MUJIE_FAB_SIZE,
  MUJIE_SPACE_BELOW_DIAL
} from '../common/UiTokens'
import { SecondTicker } from '../common/SecondTicker'

@Component
export struct AlarmPage {
  @Prop theme: ClockTheme = new ClockTheme()
  @Prop alarms: AlarmItem[] = []
  @Prop isPageActive: boolean = true
  @State private tick: number = 0
  onToggleAlarm: (id: number) => void = () => {}
  onAddAlarm: () => void = () => {}
  onEditAlarm: (id: number) => void = () => {}
  onDeleteAlarm: (id: number) => void = () => {}

  private onTick(): void {
    this.tick++
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      SecondTicker({
        isActive: this.isPageActive,
        onTick: this.onTick
      })

      Column() {
        ClockFace({ diameter: 248, theme: this.theme })

        Text(this.nextAlarmText())
          .fontColor(this.theme.text)
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .margin({ top: MUJIE_SPACE_BELOW_DIAL, bottom: 8 })
          .visibility(this.tick >= 0 ? Visibility.Visible : Visibility.Hidden)

        if (this.alarms.length === 0) {
          Column() {
            Text($r('app.string.no_alarms'))
              .fontColor(this.theme.muted)
              .fontSize(15)
            Text($r('app.string.add_alarm_hint'))
              .fontColor(this.theme.muted)
              .fontSize(12)
              .margin({ top: 6 })
          }
          .width('100%')
          .constraintSize({ minHeight: 88 })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .borderRadius(MUJIE_CARD_RADIUS)
          .borderWidth(1)
          .borderColor(this.theme.cardBorder)
          .backgroundColor(this.theme.card)
        } else {
          Column() {
            Text($r('app.string.swipe_delete_hint'))
              .fontColor(this.theme.muted)
              .fontSize(11)
              .width('100%')
              .margin({ top: 4, bottom: 6 })

            List({ space: 10 }) {
              ForEach(this.alarms, (item: AlarmItem) => {
                ListItem() {
                  this.AlarmRowCard(item)
                }
                .swipeAction({
                  end: {
                    builder: () => {
                      this.AlarmSwipeDeleteStrip()
                    },
                    onAction: () => {
                      this.onDeleteAlarm(item.id)
                    }
                  },
                  edgeEffect: SwipeEdgeEffect.Spring
                })
              }, (item: AlarmItem) =>
                `${item.id}_${item.enabled}_${item.hour}_${item.minute}_${item.label}_${item.repeatMode}_${item.smartHolidaySkip}_${item.ringDurationMinutes}_${item.snoozeIntervalMinutes}_${item.snoozeMaxCount}_${item.ringtoneId}`)
            }
            .width('100%')
            .layoutWeight(1)
            .scrollBar(BarState.Auto)
            .edgeEffect(EdgeEffect.Spring)
          }
          .width('100%')
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .padding({ bottom: MUJIE_FAB_SIZE + 24 })

      Stack() {
        Circle()
          .width(MUJIE_FAB_SIZE)
          .height(MUJIE_FAB_SIZE)
          .fill(this.theme.selectedNav)
        Text('+')
          .fontColor(this.theme.iconBg)
          .fontSize(MUJIE_FAB_PLUS_FONT)
          .fontWeight(FontWeight.Medium)
      }
      .width(MUJIE_FAB_SIZE)
      .height(MUJIE_FAB_SIZE)
      .margin({ bottom: 16 })
      .accessibilityText($r('app.string.new_alarm'))
      .onClick(() => {
        this.onAddAlarm()
      })
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  AlarmRowCard(item: AlarmItem) {
    Row() {
      Column() {
        Text(this.formatAlarmTime(item.hour, item.minute))
          .fontColor(item.enabled ? this.theme.text : this.theme.navIdleColor)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Text(`${this.alarmLabel(item)} · ${alarmListRepeatSummary(item.repeatMode, item.smartHolidaySkip)}`)
          .fontColor(item.enabled ? this.theme.muted : this.theme.navIdleColor)
          .fontSize(12)
          .margin({ top: 4 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.rowNextHint(item))
          .fontColor(this.theme.navIdleColor)
          .fontSize(11)
          .margin({ top: 6 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .visibility(this.tick >= 0 ? Visibility.Visible : Visibility.Hidden)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .onClick(() => {
        this.onEditAlarm(item.id)
      })

      this.SmallSwitch(item)
    }
    .width('100%')
    .constraintSize({ minHeight: 76 })
    .padding({ left: 14, right: 12, top: 12, bottom: 12 })
    .alignItems(VerticalAlign.Center)
    .borderRadius(MUJIE_CARD_RADIUS)
    .borderWidth(1)
    .borderColor(this.theme.cardBorder)
    .backgroundColor(this.theme.card)
    .accessibilityText(`${this.formatAlarmTime(item.hour, item.minute)}，${this.alarmLabel(item)}`)
    .accessibilityDescription($r('app.string.tap_card_edit'))
  }

  @Builder
  AlarmSwipeDeleteStrip() {
    Row() {
      Text($r('app.string.alarm_delete'))
        .fontColor(this.theme.iconBg)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
    }
    .width(72)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.theme.deleteColor)
  }

  @Builder
  SmallSwitch(item: AlarmItem) {
    Row() {
      Circle()
        .width(24)
        .height(24)
        .fill(this.theme.card)
    }
    .width(52)
    .height(28)
    .padding(2)
    .justifyContent(item.enabled ? FlexAlign.End : FlexAlign.Start)
    .borderRadius(18)
    .backgroundColor(item.enabled ? this.theme.selectedNav : this.theme.switchOffBg)
    .animation({ duration: 160, curve: Curve.FastOutSlowIn })
    .onClick(() => {
      this.onToggleAlarm(item.id)
    })
  }

  private rowNextHint(item: AlarmItem): string {
    const ctx = getContext(this)
    const now = new Date()
    if (!item.enabled) {
      return ctx.resourceManager.getStringSync($r('app.string.alarm_off'))
    }
    const diff = this.nextRingOffsetMinutes(item, now)
    if (diff === null) {
      return ctx.resourceManager.getStringSync($r('app.string.no_upcoming_ring'))
    }
    return ctx.resourceManager.getStringSync($r('app.string.next_ring_prefix')) + this.formatCountdown(diff)
  }

  private formatCountdown(minutes: number): string {
    const ctx = getContext(this)
    if (minutes <= 0) {
      return ctx.resourceManager.getStringSync($r('app.string.about_to_ring'))
    }
    if (minutes < 60) {
      return ctx.resourceManager.getStringSync($r('app.string.minutes_later'), minutes)
    }
    const h = Math.floor(minutes / 60)
    const m = minutes % 60
    if (m === 0) {
      return ctx.resourceManager.getStringSync($r('app.string.hours_later'), h)
    }
    return ctx.resourceManager.getStringSync($r('app.string.hours_minutes_later'), h, m)
  }

  private nextAlarmText(): string {
    const ctx = getContext(this)
    let minDiff = -1
    const now = new Date()
    for (let i = 0; i < this.alarms.length; i++) {
      const item = this.alarms[i]
      const diff = this.nextRingOffsetMinutes(item, now)
      if (diff !== null && (minDiff === -1 || diff < minDiff)) {
        minDiff = diff
      }
    }
    if (minDiff === -1) {
      return ctx.resourceManager.getStringSync($r('app.string.no_active_alarm'))
    }
    if (minDiff === 0) {
      return ctx.resourceManager.getStringSync($r('app.string.about_to_ring'))
    }
    const hours = Math.floor(minDiff / 60)
    const minutes = minDiff % 60
    if (hours > 0) {
      return ctx.resourceManager.getStringSync($r('app.string.ring_hours_minutes_later'), hours, minutes)
    }
    return ctx.resourceManager.getStringSync($r('app.string.ring_minutes_later'), minutes)
  }

  private nextRingOffsetMinutes(item: AlarmItem, now: Date): number | null {
    if (!item.enabled) {
      return null
    }
    const nowMs = now.getTime()
    for (let addDays = 0; addDays < 14; addDays++) {
      const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() + addDays, item.hour, item.minute, 0, 0)
      if (d.getTime() <= nowMs) {
        continue
      }
      if (repeatMatches(item.repeatMode, d.getDay())) {
        return Math.floor((d.getTime() - nowMs) / 60000)
      }
    }
    return null
  }

  private alarmLabel(item: AlarmItem): string {
    const ctx = getContext(this)
    return item.label && item.label.trim().length > 0 ? item.label.trim() : ctx.resourceManager.getStringSync($r('app.string.default_alarm_label'))
  }

  private formatAlarmTime(hour: number, minute: number): string {
    return `${hour < 10 ? '0' + hour : hour}:${minute < 10 ? '0' + minute : minute}`
  }
}
