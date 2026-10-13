import { ClockTheme } from './ClockModels'
import {
  MUJIE_DETAIL_BACK_BUTTON_BOX,
  MUJIE_DETAIL_BACK_ICON_SIZE,
  MUJIE_DETAIL_TITLE_BAR_HEIGHT,
  MUJIE_DETAIL_TITLE_FONT_SIZE,
  MUJIE_DETAIL_TITLE_SIDE_SLOT
} from '../common/UiTokens'

/**
 * 二级全屏页顶栏，布局与交互复刻 FlowDay：
 * `D:\person\FlowDay\entry\src\main\ets\component\FlowDayAppTitleBar.ets` 中的
 * `FlowDayAppTitleBarBackButton` + `FlowDayAppTitleBar`（有返回/左右槽位分支）。
 * 度量见 `UiTokens` 中 `MUJIE_DETAIL_*`（与 `FlowDayTitleBarTokens` 对应）。
 *
 * 请将页面根 `Column` 使用与主界面一致的内边距：
 * `padding({ left: MUJIE_SCREEN_PAD_H, right: MUJIE_SCREEN_PAD_H, top: MUJIE_SCREEN_PAD_TOP, ... })`。
 */
@Component
export struct SecondaryTitleBar {
  @Prop title: string = ''
  @Prop theme: ClockTheme = new ClockTheme()
  /** 非空时在右侧 48 槽内展示（如「✓」保存） */
  @Prop rightText: string = ''
  onLeft: () => void = () => {}
  onRight: () => void = () => {}

  build() {
    Row() {
      Column() {
        Column() {
          Image($r('app.media.flat_icon_back'))
            .width(MUJIE_DETAIL_BACK_ICON_SIZE)
            .height(MUJIE_DETAIL_BACK_ICON_SIZE)
            .objectFit(ImageFit.Contain)
            .fillColor(this.theme.text)
        }
        .width(MUJIE_DETAIL_BACK_BUTTON_BOX)
        .height(MUJIE_DETAIL_BACK_BUTTON_BOX)
        .justifyContent(FlexAlign.Center)
        .borderRadius(MUJIE_DETAIL_BACK_BUTTON_BOX / 2)
        .backgroundColor(this.theme.card)
        .borderWidth(1)
        .borderColor(this.theme.cardBorder)
        .stateStyles({
          pressed: {
            .opacity(0.88)
              .scale({ x: 0.94, y: 0.94 })
          },
          normal: {
            .opacity(1)
              .scale({ x: 1, y: 1 })
          }
        })
        .onClick(() => {
          this.onLeft()
        })
      }
      .width(MUJIE_DETAIL_TITLE_SIDE_SLOT)
      .height(MUJIE_DETAIL_TITLE_BAR_HEIGHT)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Column() {
        Text(this.title)
          .fontSize(MUJIE_DETAIL_TITLE_FONT_SIZE)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.theme.text)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .layoutWeight(1)
      .padding({ left: 6, right: 6 })
      .justifyContent(FlexAlign.Center)

      if (this.rightText.length > 0) {
        Column() {
          Text(this.rightText)
            .fontColor(this.theme.selectedNav)
            .fontSize(MUJIE_DETAIL_TITLE_FONT_SIZE)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
        }
        .width(MUJIE_DETAIL_TITLE_SIDE_SLOT)
        .height(MUJIE_DETAIL_TITLE_BAR_HEIGHT)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .stateStyles({
          pressed: {
            .opacity(0.75)
              .scale({ x: 0.92, y: 0.92 })
          },
          normal: {
            .opacity(1)
              .scale({ x: 1, y: 1 })
          }
        })
        .onClick(() => {
          this.onRight()
        })
      } else {
        Blank()
          .width(MUJIE_DETAIL_TITLE_SIDE_SLOT)
          .height(MUJIE_DETAIL_TITLE_BAR_HEIGHT)
      }
    }
    .width('100%')
    .height(MUJIE_DETAIL_TITLE_BAR_HEIGHT)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }
}
