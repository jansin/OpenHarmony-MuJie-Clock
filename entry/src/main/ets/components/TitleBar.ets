import { ClockTheme } from './ClockModels'
import {
  MUJIE_TITLE_BAR_HEIGHT,
  MUJIE_TITLE_FONT_SIZE,
  MUJIE_TITLE_SIDE_FONT_SIZE,
  MUJIE_TITLE_SIDE_WIDTH
} from '../common/UiTokens'

@Component
export struct TitleBar {
  @Prop title: string = ''
  @Prop theme: ClockTheme = new ClockTheme()
  leftText: string = ''
  rightText: string = ''
  showMenu: boolean = false
  onLeft: () => void = () => {}
  onRight: () => void = () => {}
  onMenu: () => void = () => {}

  build() {
    Row() {
      if (this.leftText.length > 0) {
        Text(this.leftText)
          .fontColor(this.theme.text)
          .fontSize(MUJIE_TITLE_SIDE_FONT_SIZE)
          .width(MUJIE_TITLE_SIDE_WIDTH)
          .height(MUJIE_TITLE_BAR_HEIGHT)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.onLeft()
          })
      }

      Text(this.title)
        .fontColor(this.theme.text)
        .fontSize(MUJIE_TITLE_FONT_SIZE)
        .fontWeight(FontWeight.Bold)

      Blank()

      if (this.showMenu) {
        this.MenuGrid()
      } else if (this.rightText.length > 0) {
        Text(this.rightText)
          .fontColor(this.theme.text)
          .fontSize(MUJIE_TITLE_SIDE_FONT_SIZE)
          .width(MUJIE_TITLE_SIDE_WIDTH)
          .height(MUJIE_TITLE_BAR_HEIGHT)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.onRight()
          })
      } else {
        Blank()
          .width(MUJIE_TITLE_SIDE_WIDTH)
          .height(MUJIE_TITLE_BAR_HEIGHT)
      }
    }
    .width('100%')
    .height(MUJIE_TITLE_BAR_HEIGHT)
    .alignItems(VerticalAlign.Center)
  }

  /** 与 FlowDay FlowDayAppTitleBarGridIcon 一致的 2×2 点阵 */
  @Builder
  MenuGrid() {
    Column({ space: 5 }) {
      Row({ space: 5 }) {
        Column()
          .width(6)
          .height(6)
          .borderRadius(3)
          .backgroundColor(this.theme.text)
        Column()
          .width(6)
          .height(6)
          .borderRadius(3)
          .backgroundColor(this.theme.text)
      }
      Row({ space: 5 }) {
        Column()
          .width(6)
          .height(6)
          .borderRadius(3)
          .backgroundColor(this.theme.text)
        Column()
          .width(6)
          .height(6)
          .borderRadius(3)
          .backgroundColor(this.theme.text)
      }
    }
    .width(MUJIE_TITLE_SIDE_WIDTH)
    .height(MUJIE_TITLE_BAR_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.onMenu()
    })
  }
}
