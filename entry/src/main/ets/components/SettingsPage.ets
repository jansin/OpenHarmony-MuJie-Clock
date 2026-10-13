import { ClockTheme } from './ClockModels'
import { SecondaryTitleBar } from './SecondaryTitleBar'
import { MUJIE_CARD_RADIUS, MUJIE_SCREEN_PAD_H, MUJIE_SCREEN_PAD_TOP } from '../common/UiTokens'

@Component
export struct SettingsPage {
  /** 与 Index 的 @State 双向绑定，开关状态会立即随父状态刷新（@Prop 在部分场景下开关动画不及时） */
  @Prop theme: ClockTheme = new ClockTheme()
  @Link darkMode: boolean
  onBack: () => void = () => {}
  /** 切换深色模式后写回偏好（由 Index 传入 persistAppUiToStore） */
  onPersistAppUi: () => void = () => {}

  build() {
    Column() {
      SecondaryTitleBar({
        title: '设置',
        theme: this.theme,
        onLeft: () => {
          this.onBack()
        }
      })

      Column() {
        Row() {
          Column() {
            Text('深色模式')
              .fontColor(this.theme.text)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
            Text('降低夜间屏幕亮度与对比，界面使用深色主题')
              .fontColor(this.theme.muted)
              .fontSize(12)
              .lineHeight(17)
              .width('100%')
              .margin({ top: 6 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Blank()

          Row() {
            Row() {
              Circle()
                .width(18)
                .height(18)
                .fill('#F8F8F8')
            }
            .width(48)
            .height(22)
            .padding(2)
            .justifyContent(this.darkMode ? FlexAlign.End : FlexAlign.Start)
            .borderRadius(11)
            .backgroundColor(this.darkMode ? '#2E7BE6' : '#D7D7D7')
            .animation({ duration: 180, curve: Curve.FastOutSlowIn })
          }
          .onClick(() => {
            this.darkMode = !this.darkMode
            this.onPersistAppUi()
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })

        Divider()
          .width('100%')
          .height(1)
          .color(this.theme.cardBorder)
          .margin({ left: 16, right: 16 })

        Row() {
          Column() {
            Text('世界时钟')
              .fontColor(this.theme.text)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
            Text('在「世界时钟」中添加城市，最多保留 4 个，列表会自动保存')
              .fontColor(this.theme.muted)
              .fontSize(12)
              .lineHeight(17)
              .width('100%')
              .margin({ top: 6 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 14, bottom: 14 })
      }
      .margin({ top: 16 })
      .width('100%')
      .borderRadius(MUJIE_CARD_RADIUS)
      .borderWidth(1)
      .borderColor(this.theme.cardBorder)
      .backgroundColor(this.theme.card)
    }
    .width('100%')
    .height('100%')
    .padding({ left: MUJIE_SCREEN_PAD_H, right: MUJIE_SCREEN_PAD_H, top: MUJIE_SCREEN_PAD_TOP })
    .backgroundColor(this.theme.pageBg)
  }
}
