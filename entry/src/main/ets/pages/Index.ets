import { common } from '@kit.AbilityKit'
import { AlarmEditPage } from '../components/AlarmEditPage'
import { AlarmItem, ClockTheme, DARK_THEME, LIGHT_THEME, WorldClockItem } from '../components/ClockModels'
import { SettingsPage } from '../components/SettingsPage'
import { TimeZonePage } from '../components/TimeZonePage'
import { AlarmPreferences } from '../common/AlarmPreferences'
import { AppUiPreferences } from '../common/AppUiPreferences'
import { repeatMatches } from '../common/AlarmRepeat'
import {
  disableAlarmById,
  mergeSavedAlarm,
  removeAlarmById,
  snapshotAlarmForEditor,
  sortAlarmsByTime,
  toggleAlarmEnabled
} from '../home/AlarmListReducer'
import { showAlarmRingDialog } from '../home/AlarmDialogHelper'
import { alarmMinuteKeyFromDate } from '../home/AlarmMinuteKey'
import { promptAction, window } from '@kit.ArkUI'
import {
  APP_NAV_ALARM_EDIT,
  APP_NAV_MAIN,
  APP_NAV_SETTINGS,
  APP_NAV_TIME_ZONE
} from '../home/AppNavRoutes'
import { indexSeedAlarms } from '../home/IndexDefaultAlarms'
import { SnoozeTick } from '../home/IndexSnoozeModels'
import { MainTabShell } from '../home/MainTabShell'
import {
  appendSnoozeTick,
  filterSnoozeTicksExcludingAlarm,
  partitionDueSnoozeTicks
} from '../home/SnoozeTickReducer'

@Entry
@Component
struct Index {
  /** 路由栈：仅栈顶全屏展示；首项固定为 Main（与 AppNavRoutes 中名称一致） */
  @State private navStack: string[] = [APP_NAV_MAIN]
  @State private activeIndex: number = 0
  @State @Watch('onDarkModeChange') private darkMode: boolean = false
  private previousIndex: number = 0
  @State private nextAlarmId: number = 4
  private alarmTimerId: number = -1
  private firedMinuteKey: string = ''
  private firedAlarmIdsInMinute: number[] = []
  @State private alarmEditInitial: AlarmItem | undefined = undefined
  @State private alarmEditSession: number = 0
  @State private snoozeTicks: SnoozeTick[] = []
  @State private alarms: AlarmItem[] = indexSeedAlarms()
  @State private selectedWorldClocks: WorldClockItem[] = []

  private navTop(): string {
    const s: string[] = this.navStack
    if (s.length === 0) {
      return APP_NAV_MAIN
    }
    const len: number = s.length
    return s[len - 1]
  }

  private navPush(name: string): void {
    this.navStack = this.navStack.concat([name])
  }

  private navPop(): void {
    if (this.navStack.length <= 1) {
      return
    }
    const nextLen: number = this.navStack.length - 1
    this.navStack = this.navStack.slice(0, nextLen)
  }

  aboutToAppear(): void {
    this.startAlarmChecker()
    this.hydrateAlarmsFromStore()
    this.hydrateAppUiFromStore()
  }

  private hydrateAppUiFromStore(): void {
    try {
      const host = getContext(this) as common.UIAbilityContext
      AppUiPreferences.load(host).then((pack) => {
        this.darkMode = pack.darkMode
        if (pack.worldClocks.length > 0) {
          this.selectedWorldClocks = pack.worldClocks
        }
        this.activeIndex = pack.activeTabIndex
      })
    } catch (_e) {
      console.error('hydrateAppUiFromStore failed', _e)
    }
  }

  private persistAppUiToStore(): void {
    try {
      const host = getContext(this) as common.UIAbilityContext
      AppUiPreferences.save(host, this.darkMode, this.selectedWorldClocks, this.activeIndex).catch((e: Error) => {
        console.error('persistAppUiToStore save failed', e)
      })
    } catch (_e) {
      console.error('persistAppUiToStore failed', _e)
    }
  }

  private hydrateAlarmsFromStore(): void {
    try {
      const host = getContext(this) as common.UIAbilityContext
      AlarmPreferences.load(host).then((pack) => {
        if (!pack.missing) {
          this.alarms = sortAlarmsByTime(pack.alarms)
          this.nextAlarmId = pack.nextId
        }
      })
    } catch (_e) {
      console.error('hydrateAlarmsFromStore failed', _e)
    }
  }

  private persistAlarmsToStore(): void {
    try {
      const host = getContext(this) as common.UIAbilityContext
      AlarmPreferences.save(host, this.alarms, this.nextAlarmId).catch((e: Error) => {
        console.error('persistAlarmsToStore save failed', e)
      })
    } catch (_e) {
      console.error('persistAlarmsToStore failed', _e)
    }
  }

  private closeAlarmEditor(): void {
    const top: string = this.navTop()
    if (top === APP_NAV_ALARM_EDIT) {
      this.navPop()
    }
    this.alarmEditInitial = undefined
  }

  aboutToDisappear(): void {
    if (this.alarmTimerId !== -1) {
      clearInterval(this.alarmTimerId)
      this.alarmTimerId = -1
    }
  }

  private theme(): ClockTheme {
    return this.darkMode ? DARK_THEME : LIGHT_THEME
  }

  private onDarkModeChange(): void {
    this.updateStatusBarStyle()
  }

  private updateStatusBarStyle(): void {
    try {
      const mainWindow = window.findWindow('main')
      mainWindow.setWindowSystemBarProperties({
        statusBarContentColor: this.darkMode ? '#F4F4F4' : '#111111'
      })
    } catch (_e) {
      console.error('updateStatusBarStyle failed', _e)
    }
  }

  private openSettings(): void {
    this.previousIndex = this.activeIndex
    this.navPush(APP_NAV_SETTINGS)
  }

  private addWorldClock(item: WorldClockItem): void {
    let exists = false
    for (let i = 0; i < this.selectedWorldClocks.length; i++) {
      if (this.selectedWorldClocks[i].city === item.city) {
        exists = true
        break
      }
    }
    if (exists) {
      try {
        promptAction.showToast({ message: getContext(this).resourceManager.getStringSync($r('app.string.city_already_exists')), duration: 2000 })
      } catch (_e) {
        console.error('addWorldClock toast failed', _e)
      }
      return
    }
    if (this.selectedWorldClocks.length >= 4) {
      try {
        promptAction.showToast({ message: getContext(this).resourceManager.getStringSync($r('app.string.max_4_cities_removed')), duration: 2500 })
      } catch (_e) {
        console.error('addWorldClock max city toast failed', _e)
      }
      this.selectedWorldClocks.shift()
    }
    this.selectedWorldClocks.push(item)
    this.selectedWorldClocks = this.selectedWorldClocks.slice()
    const top: string = this.navTop()
    if (top === APP_NAV_TIME_ZONE) {
      this.navPop()
    }
    this.persistAppUiToStore()
  }

  private removeWorldClock(city: string): void {
    const next: WorldClockItem[] = []
    for (let i = 0; i < this.selectedWorldClocks.length; i++) {
      if (this.selectedWorldClocks[i].city !== city) {
        next.push(this.selectedWorldClocks[i])
      }
    }
    this.selectedWorldClocks = next
    this.persistAppUiToStore()
  }

  private toggleAlarm(id: number): void {
    let wasOn = false
    for (let i = 0; i < this.alarms.length; i++) {
      if (this.alarms[i].id === id) {
        wasOn = this.alarms[i].enabled
        break
      }
    }
    const next = toggleAlarmEnabled(this.alarms, id)
    let nowOn = false
    for (let j = 0; j < next.length; j++) {
      if (next[j].id === id) {
        nowOn = next[j].enabled
        break
      }
    }
    if (wasOn && !nowOn) {
      this.snoozeTicks = filterSnoozeTicksExcludingAlarm(this.snoozeTicks, id)
    }
    this.alarms = next
    this.persistAlarmsToStore()
  }

  private saveAlarm(item: AlarmItem): void {
    const labelClean = item.label.trim().length > 0 ? item.label.trim() : '闹钟'
    const merged = mergeSavedAlarm(this.alarms, this.nextAlarmId, item, labelClean)
    this.alarms = merged.alarms
    this.nextAlarmId = merged.nextId
    this.firedMinuteKey = ''
    this.firedAlarmIdsInMinute = []
    this.snoozeTicks = filterSnoozeTicksExcludingAlarm(this.snoozeTicks, item.id)
    this.closeAlarmEditor()
    this.persistAlarmsToStore()
  }

  private deleteAlarm(id: number): void {
    this.alarms = sortAlarmsByTime(removeAlarmById(this.alarms, id))
    this.firedMinuteKey = ''
    this.firedAlarmIdsInMinute = []
    this.snoozeTicks = filterSnoozeTicksExcludingAlarm(this.snoozeTicks, id)
    if (this.alarmEditInitial !== undefined && this.alarmEditInitial.id === id) {
      this.closeAlarmEditor()
    }
    this.persistAlarmsToStore()
  }

  private startAlarmChecker(): void {
    if (this.alarmTimerId !== -1) {
      return
    }
    this.alarmTimerId = setInterval(() => {
      this.checkAlarms()
      this.checkSnoozes()
    }, 1000)
  }

  private checkAlarms(): void {
    const now = new Date()
    const currentKey = alarmMinuteKeyFromDate(now)
    if (this.firedMinuteKey !== currentKey) {
      this.firedMinuteKey = currentKey
      this.firedAlarmIdsInMinute = []
    }

    for (let i = 0; i < this.alarms.length; i++) {
      const item = this.alarms[i]
      if (!item.enabled) {
        continue
      }
      let already = false
      for (let j = 0; j < this.firedAlarmIdsInMinute.length; j++) {
        if (this.firedAlarmIdsInMinute[j] === item.id) {
          already = true
          break
        }
      }
      if (already) {
        continue
      }
      if (item.hour !== now.getHours() || item.minute !== now.getMinutes()) {
        continue
      }
      if (!repeatMatches(item.repeatMode, now.getDay())) {
        continue
      }

      this.firedAlarmIdsInMinute.push(item.id)
      this.showAlarmAlert(item)
      if (item.repeatMode === 'Once') {
        this.disableAlarm(item.id)
      }
    }
  }

  private disableAlarm(id: number): void {
    this.alarms = disableAlarmById(this.alarms, id)
    this.snoozeTicks = filterSnoozeTicksExcludingAlarm(this.snoozeTicks, id)
    this.persistAlarmsToStore()
  }

  private alarmById(id: number): AlarmItem | undefined {
    for (let i = 0; i < this.alarms.length; i++) {
      if (this.alarms[i].id === id) {
        return this.alarms[i]
      }
    }
    return undefined
  }

  private armSnooze(item: AlarmItem, nextTapsLeft: number): void {
    const tick: SnoozeTick = {
      alarmId: item.id,
      fireAt: Date.now() + item.snoozeIntervalMinutes * 60000,
      snoozeTapsLeft: nextTapsLeft
    }
    this.snoozeTicks = appendSnoozeTick(this.snoozeTicks, tick)
  }

  private checkSnoozes(): void {
    const part = partitionDueSnoozeTicks(this.snoozeTicks, Date.now())
    if (part.due.length === 0) {
      return
    }
    this.snoozeTicks = part.kept
    for (let j = 0; j < part.due.length; j++) {
      const tick = part.due[j]
      const item = this.alarmById(tick.alarmId)
      if (item !== undefined && item.enabled) {
        this.showAlarmAlert(item, tick.snoozeTapsLeft)
      }
    }
  }

  private showAlarmAlert(item: AlarmItem, snoozeTapsLeft?: number): void {
    const taps =
      snoozeTapsLeft !== undefined && snoozeTapsLeft >= 0 ? snoozeTapsLeft : item.snoozeMaxCount
    showAlarmRingDialog(item, snoozeTapsLeft, () => {
      this.armSnooze(item, taps - 1)
    })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      if (this.navTop() === APP_NAV_TIME_ZONE) {
        TimeZonePage({
          theme: this.theme(),
          onBack: () => {
            this.navPop()
          },
          onSelect: (item: WorldClockItem) => {
            this.addWorldClock(item)
          }
        })
      } else if (this.navTop() === APP_NAV_SETTINGS) {
        SettingsPage({
          theme: this.theme(),
          darkMode: $darkMode,
          onBack: () => {
            this.activeIndex = this.previousIndex
            this.navPop()
          },
          onPersistAppUi: () => {
            this.persistAppUiToStore()
          }
        })
      } else if (this.navTop() === APP_NAV_ALARM_EDIT) {
        AlarmEditPage({
          theme: this.theme(),
          nextId: this.nextAlarmId,
          initialAlarm: this.alarmEditInitial,
          onBack: () => {
            this.closeAlarmEditor()
          },
          onSave: (item: AlarmItem) => {
            this.saveAlarm(item)
          },
          onDelete: (id: number) => {
            this.deleteAlarm(id)
          }
        })
          .key(`alarm-edit-${this.alarmEditSession}`)
      } else {
        MainTabShell({
          theme: this.theme(),
          activeIndex: this.activeIndex,
          alarms: this.alarms,
          worldClocks: this.selectedWorldClocks,
          onOpenSettings: () => {
            this.openSettings()
          },
          onTabChange: (index: number, _title: string) => {
            if (this.activeIndex === index) {
              return
            }
            this.activeIndex = index
            this.persistAppUiToStore()
          },
          onToggleAlarm: (id: number) => {
            this.toggleAlarm(id)
          },
          onAddAlarm: () => {
            this.alarmEditInitial = undefined
            this.alarmEditSession++
            this.navPush(APP_NAV_ALARM_EDIT)
          },
          onEditAlarm: (id: number) => {
            for (let i = 0; i < this.alarms.length; i++) {
              if (this.alarms[i].id === id) {
                this.alarmEditInitial = snapshotAlarmForEditor(this.alarms[i])
                this.alarmEditSession++
                this.navPush(APP_NAV_ALARM_EDIT)
                break
              }
            }
          },
          onDeleteAlarm: (id: number) => {
            this.deleteAlarm(id)
          },
          onOpenTimeZone: () => {
            this.navPush(APP_NAV_TIME_ZONE)
          },
          onRemoveWorldClock: (city: string) => {
            this.removeWorldClock(city)
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme().pageBg)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}
