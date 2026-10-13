import { AlarmPage } from '../components/AlarmPage'
import { BottomNavigation } from '../components/BottomNavigation'
import { ClockPage } from '../components/ClockPage'
import { AlarmItem, ClockTheme, WorldClockItem } from '../components/ClockModels'
import { StopwatchPage } from '../components/StopwatchPage'
import { TimerPage } from '../components/TimerPage'
import { TitleBar } from '../components/TitleBar'
import { INDEX_NAV_ITEMS, indexNavTitle } from '../home/IndexNavConfig'
import {
  MUJIE_NAV_HEIGHT,
  MUJIE_SCREEN_PAD_H,
  MUJIE_SCREEN_PAD_TOP
} from '../common/UiTokens'

/** 主界面：标题栏 + 当前 Tab 页面 + 底部导航（与 Index 中闹钟/世界时钟等逻辑解耦） */
@Component
export struct MainTabShell {
  @Prop theme: ClockTheme = new ClockTheme()
  @Prop activeIndex: number = 0
  @Prop alarms: AlarmItem[] = []
  @Prop worldClocks: WorldClockItem[] = []
  onOpenSettings: () => void = () => {}
  onTabChange: (index: number, title: string) => void = () => {}
  onToggleAlarm: (id: number) => void = () => {}
  onAddAlarm: () => void = () => {}
  onEditAlarm: (id: number) => void = () => {}
  onDeleteAlarm: (id: number) => void = () => {}
  onOpenTimeZone: () => void = () => {}
  onRemoveWorldClock: (city: string) => void = () => {}

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        TitleBar({
          title: indexNavTitle(this.activeIndex),
          theme: this.theme,
          showMenu: true,
          onMenu: () => {
            this.onOpenSettings()
          }
        })

        Stack() {
          AlarmPage({
            theme: this.theme,
            alarms: this.alarms,
            isPageActive: this.activeIndex === 0,
            onToggleAlarm: (id: number) => {
              this.onToggleAlarm(id)
            },
            onAddAlarm: () => {
              this.onAddAlarm()
            },
            onEditAlarm: (id: number) => {
              this.onEditAlarm(id)
            },
            onDeleteAlarm: (id: number) => {
              this.onDeleteAlarm(id)
            }
          })
            .width('100%')
            .height('100%')
            .visibility(this.activeIndex === 0 ? Visibility.Visible : Visibility.Hidden)
            .zIndex(this.activeIndex === 0 ? 1 : 0)

          ClockPage({
            theme: this.theme,
            worldClocks: this.worldClocks,
            isPageActive: this.activeIndex === 1,
            onOpenTimeZone: () => {
              this.onOpenTimeZone()
            },
            onRemoveWorldClock: (city: string) => {
              this.onRemoveWorldClock(city)
            }
          })
            .width('100%')
            .height('100%')
            .visibility(this.activeIndex === 1 ? Visibility.Visible : Visibility.Hidden)
            .zIndex(this.activeIndex === 1 ? 1 : 0)

          StopwatchPage({
            theme: this.theme,
            isPageActive: this.activeIndex === 2
          })
            .width('100%')
            .height('100%')
            .visibility(this.activeIndex === 2 ? Visibility.Visible : Visibility.Hidden)
            .zIndex(this.activeIndex === 2 ? 1 : 0)

          TimerPage({ theme: this.theme })
            .width('100%')
            .height('100%')
            .visibility(this.activeIndex === 3 ? Visibility.Visible : Visibility.Hidden)
            .zIndex(this.activeIndex === 3 ? 1 : 0)
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .padding({
        left: MUJIE_SCREEN_PAD_H,
        right: MUJIE_SCREEN_PAD_H,
        top: MUJIE_SCREEN_PAD_TOP,
        bottom: MUJIE_NAV_HEIGHT
      })
      .backgroundColor(this.theme.pageBg)

      BottomNavigation({
        items: INDEX_NAV_ITEMS,
        activeIndex: this.activeIndex,
        theme: this.theme,
        onChange: (index: number, title: string) => {
          this.onTabChange(index, title)
        }
      })
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}
