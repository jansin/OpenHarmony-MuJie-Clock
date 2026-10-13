import { ClockTheme, WorldClockItem } from './ClockModels'
import { ClockFace } from './ClockDial'
import { formatGmtLabel } from '../common/WorldTimeFormat'
import {
  MUJIE_CARD_RADIUS,
  MUJIE_FAB_PLUS_FONT,
  MUJIE_FAB_SIZE,
  MUJIE_SPACE_BELOW_DIAL
} from '../common/UiTokens'
import { SecondTicker } from '../common/SecondTicker'

@Component
export struct ClockPage {
  @Prop theme: ClockTheme = new ClockTheme()
  @Prop worldClocks: WorldClockItem[] = []
  onOpenTimeZone: () => void = () => {
  }
  onRemoveWorldClock: (city: string) => void = () => {
  }
  @Prop isPageActive: boolean = true
  @State private dateText: string = ''
  @State private tick: number = 0

  private updateClockData(): void {
    const now = new Date()
    const days: string[] = ['日', '一', '二', '三', '四', '五', '六']
    this.dateText = `${now.getMonth() + 1}月${now.getDate()}日 星期${days[now.getDay()]}`
    this.tick++
  }

  private formatOffsetTimeWithSeconds(offsetMinutes: number): string {
    const utcMs = new Date().getTime() + new Date().getTimezoneOffset() * 60000
    const target = new Date(utcMs + offsetMinutes * 60000)
    const hours = target.getHours()
    const minutes = target.getMinutes()
    const seconds = target.getSeconds()
    return `${hours < 10 ? '0' + hours : hours}:${minutes < 10 ? '0' + minutes : minutes}:${seconds < 10 ?
      '0' + seconds : seconds}`
  }

  private pad2(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }

  private localCalendarKey(): string {
    const n = new Date()
    return `${n.getFullYear()}-${this.pad2(n.getMonth() + 1)}-${this.pad2(n.getDate())}`
  }

  private zoneCalendarKey(offsetMinutes: number): string {
    const utcMs = new Date().getTime() + new Date().getTimezoneOffset() * 60000
    const t = new Date(utcMs + offsetMinutes * 60000)
    return `${t.getFullYear()}-${this.pad2(t.getMonth() + 1)}-${this.pad2(t.getDate())}`
  }

  /** 与本地日历相比，该固定偏移城市处于「上一日 / 下一日」时的短提示 */
  private relativeDayHint(offsetMinutes: number): string {
    const a = this.localCalendarKey()
    const b = this.zoneCalendarKey(offsetMinutes)
    if (a === b) {
      return ''
    }
    if (b > a) {
      return '当地已进入新一天'
    }
    return '当地仍为上一日'
  }

  build() {
    Column() {
      SecondTicker({
        isActive: this.isPageActive,
        onTick: () => {
          this.updateClockData()
        }
      })

      Column() {
        ClockFace({ diameter: 248, theme: this.theme })

        Text('本地时间')
          .fontColor(this.theme.text)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .margin({ top: MUJIE_SPACE_BELOW_DIAL })

        Text(this.dateText)
          .fontColor(this.theme.muted)
          .fontSize(12)
          .margin({ top: 6 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      if (this.worldClocks.length === 0) {
        Column() {
          Text('暂无其他城市时钟')
            .fontColor(this.theme.muted)
            .fontSize(15)
          Text('点击下方 + 添加世界城市')
            .fontColor(this.theme.muted)
            .fontSize(12)
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Column() {
          Text('左滑可删除城市')
            .fontColor(this.theme.muted)
            .fontSize(11)
            .width('100%')
            .margin({ top: 10, bottom: 6 })

          List({ space: 10 }) {
            ForEach(this.worldClocks, (item: WorldClockItem) => {
              ListItem() {
                this.WorldClockRow(item)
              }
              .swipeAction({
                end: {
                  builder: () => {
                    this.WorldSwipeDeleteStrip()
                  },
                  onAction: () => {
                    this.onRemoveWorldClock(item.city)
                  }
                },
                edgeEffect: SwipeEdgeEffect.Spring
              })
            }, (item: WorldClockItem) => `${item.city}_${item.offsetMinutes}`)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
          .edgeEffect(EdgeEffect.Spring)
        }
        .width('100%')
        .layoutWeight(1)
      }

      Stack() {
        Circle()
          .width(MUJIE_FAB_SIZE)
          .height(MUJIE_FAB_SIZE)
          .fill(this.theme.selectedNav)
        Image($r('app.media.flat_icon_globe'))
          .width(MUJIE_FAB_SIZE / 2)
          .height(MUJIE_FAB_SIZE / 2)
          .objectFit(ImageFit.Contain)
      }
      .width(MUJIE_FAB_SIZE)
      .height(MUJIE_FAB_SIZE)
      .margin({ bottom: 16 })
      .accessibilityText('添加世界城市')
      .onClick(() => {
        this.onOpenTimeZone()
      })
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  WorldSwipeDeleteStrip() {
    Row() {
      Text('删除')
        .fontColor('#FFFFFF')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
    }
    .width(72)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#E53935')
  }

  @Builder
  WorldClockRow(item: WorldClockItem) {
    Row() {
      Column() {
        Text(item.city)
          .fontColor(this.theme.text)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(formatGmtLabel(item.offsetMinutes))
          .fontColor(this.theme.muted)
          .fontSize(12)
          .margin({ top: 4 })
          .width('100%')
        if (this.relativeDayHint(item.offsetMinutes).length > 0) {
          Text(this.relativeDayHint(item.offsetMinutes))
            .fontColor(this.theme.selectedNav)
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 4 })
            .width('100%')
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(this.formatOffsetTimeWithSeconds(item.offsetMinutes))
        .fontColor(this.theme.text)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .visibility(this.tick >= 0 ? Visibility.Visible : Visibility.Hidden)
    }
    .width('100%')
    .constraintSize({ minHeight: 72 })
    .padding({
      left: 14,
      right: 14,
      top: 12,
      bottom: 12
    })
    .alignItems(VerticalAlign.Center)
    .borderRadius(MUJIE_CARD_RADIUS)
    .borderWidth(1)
    .borderColor(this.theme.cardBorder)
    .backgroundColor(this.theme.card)
  }
}
