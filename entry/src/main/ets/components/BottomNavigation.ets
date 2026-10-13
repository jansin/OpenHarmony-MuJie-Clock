import { ClockTheme, NavItem } from './ClockModels'
import { IconButton } from './IconButton'
import {
  MUJIE_NAV_HEIGHT,
  MUJIE_NAV_ICON_LABEL_SPACE,
  MUJIE_NAV_LABEL_SIZE
} from '../common/UiTokens'

@Styles
function BottomNavTabNormal() {
  .opacity(1)
  .scale({ x: 1, y: 1 })
}

@Styles
function BottomNavTabPressed() {
  .opacity(0.88)
  .scale({ x: 0.98, y: 0.98 })
}

@Component
export struct BottomNavigation {
  items: NavItem[] = []
  @Prop activeIndex: number = 0
  @Prop theme: ClockTheme = new ClockTheme()
  onChange: (index: number, title: string) => void = () => {}

  build() {
    Row() {
      ForEach(this.items, (item: NavItem) => {
        this.NavButton(item)
      }, (item: NavItem) => `${item.index}`)
    }
    .width('100%')
    .height(MUJIE_NAV_HEIGHT)
    .padding({ top: 4, bottom: 4 })
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.theme.nav)
    .borderWidth({ top: 1 })
    .borderColor({ top: this.theme.navTopDivider })
  }

  @Builder
  NavButton(item: NavItem) {
    Column({ space: MUJIE_NAV_ICON_LABEL_SPACE }) {
      IconButton({
        icon: item.icon,
        buttonSize: 46,
        theme: this.theme,
        filled: false,
        active: this.activeIndex === item.index,
        navBarMode: true
      })

      Text(item.title)
        .fontColor(this.activeIndex === item.index ? this.theme.selectedNav : this.theme.navIdleColor)
        .fontSize(MUJIE_NAV_LABEL_SIZE)
        .fontWeight(this.activeIndex === item.index ? FontWeight.Medium : FontWeight.Regular)
        .maxLines(1)
    }
    .width('25%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .stateStyles({
      normal: BottomNavTabNormal,
      pressed: BottomNavTabPressed
    })
    .accessibilityText(item.title)
    .accessibilityDescription(`切换到${item.title}`)
    .accessibilitySelected(this.activeIndex === item.index)
    .onClick(() => {
      if (this.activeIndex !== item.index) {
        this.onChange(item.index, item.title)
      }
    })
  }
}
