import { common } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { WorldClockItem } from '../components/ClockModels'

const PREF_NAME: string = 'mujie_app_ui'
const KEY_DARK: string = 'dark_mode'
const KEY_WORLD: string = 'world_clocks_json'
const KEY_TAB: string = 'main_tab_index'
const KEY_VERSION: string = 'data_version'
const CURRENT_VERSION: number = 1
const UNSET: string = '__unset__'

interface WorldClockJsonRow {
  city?: string
  offsetMinutes?: number
}

export interface AppUiLoadResult {
  darkMode: boolean
  worldClocks: WorldClockItem[]
  /** 底部主标签 0–3，非法或缺失时为 0 */
  activeTabIndex: number
}

function parseWorldClockList(raw: string): WorldClockItem[] {
  const out: WorldClockItem[] = []
  try {
    const parsedValue: Object = JSON.parse(raw) as Object
    if (!Array.isArray(parsedValue)) {
      return out
    }
    const list: Object[] = parsedValue as Object[]
    for (let i = 0; i < list.length; i++) {
      const row: Object = list[i]
      if (typeof row !== 'object' || row === null) {
        continue
      }
      const rec: WorldClockJsonRow = row as WorldClockJsonRow
      const city = rec.city
      const off = rec.offsetMinutes
      if (typeof city !== 'string' || city.length === 0) {
        continue
      }
      if (typeof off !== 'number' || Number.isNaN(off)) {
        continue
      }
      out.push({ city: city, offsetMinutes: off })
    }
  } catch (_e) {
    return []
  }
  return out
}

export class AppUiPreferences {
  static async load(context: common.UIAbilityContext): Promise<AppUiLoadResult> {
    const pref = await preferences.getPreferences(context, PREF_NAME)
    const darkRaw = await pref.get(KEY_DARK, UNSET) as string
    let darkMode = false
    if (darkRaw !== UNSET && darkRaw === '1') {
      darkMode = true
    }
    const worldRaw = await pref.get(KEY_WORLD, UNSET) as string
    let worldClocks: WorldClockItem[] = []
    if (worldRaw !== UNSET && worldRaw.length > 0) {
      worldClocks = parseWorldClockList(worldRaw)
    }
    const tabRaw = await pref.get(KEY_TAB, UNSET) as string
    let activeTabIndex = 0
    if (tabRaw !== UNSET && tabRaw.length > 0) {
      const parsed = Number(tabRaw)
      if (!Number.isNaN(parsed) && parsed >= 0 && parsed <= 3) {
        activeTabIndex = Math.floor(parsed)
      }
    }
    migrateAppUiDataIfNeeded(pref)
    const result: AppUiLoadResult = {
      darkMode: darkMode,
      worldClocks: worldClocks,
      activeTabIndex: activeTabIndex
    }
    return result
  }

  static async save(
    context: common.UIAbilityContext,
    darkMode: boolean,
    worldClocks: WorldClockItem[],
    activeTabIndex: number
  ): Promise<void> {
    const pref = await preferences.getPreferences(context, PREF_NAME)
    await pref.put(KEY_DARK, darkMode ? '1' : '0')
    await pref.put(KEY_WORLD, JSON.stringify(worldClocks))
    const tab = activeTabIndex >= 0 && activeTabIndex <= 3 ? activeTabIndex : 0
    await pref.put(KEY_TAB, `${tab}`)
    await pref.put(KEY_VERSION, `${CURRENT_VERSION}`)
    await pref.flush()
  }
}

function migrateAppUiDataIfNeeded(pref: preferences.Preferences): void {
  const verRaw = pref.getSync(KEY_VERSION, '0') as string
  const version = Number(verRaw)
  if (Number.isNaN(version) || version < CURRENT_VERSION) {
    pref.put(KEY_VERSION, `${CURRENT_VERSION}`)
    pref.flush()
  }
}
