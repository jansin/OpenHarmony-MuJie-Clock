import { common } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { AlarmItem } from '../components/ClockModels'

const PREF_NAME: string = 'mujie_alarm_store'
const KEY_ALARMS: string = 'alarms_json'
const KEY_NEXT_ID: string = 'next_alarm_id'
const KEY_VERSION: string = 'data_version'
const CURRENT_VERSION: number = 1
const UNSET: string = '__unset__'

/** 持久化 JSON 中的单条闹钟结构（字段可选，解析时再校验） */
interface AlarmJsonFields {
  id?: number
  hour?: number
  minute?: number
  repeatMode?: string
  enabled?: boolean
  label?: string
  ringtoneId?: string
  ringDurationMinutes?: number
  snoozeIntervalMinutes?: number
  snoozeMaxCount?: number
  smartHolidaySkip?: boolean
}

export interface AlarmLoadResult {
  missing: boolean
  alarms: AlarmItem[]
  nextId: number
}

function parseAlarmList(raw: string): AlarmItem[] {
  const out: AlarmItem[] = []
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
      const rec: AlarmJsonFields = row as AlarmJsonFields
      const id = rec.id
      const hour = rec.hour
      const minute = rec.minute
      const repeatMode = rec.repeatMode
      const enabled = rec.enabled
      if (typeof id !== 'number' || typeof hour !== 'number' || typeof minute !== 'number') {
        continue
      }
      if (typeof repeatMode !== 'string' || typeof enabled !== 'boolean') {
        continue
      }
      const lv = rec.label
      const label: string = typeof lv === 'string' && lv.length > 0 ? lv : '闹钟'
      const rt = rec.ringtoneId
      const ringtoneId: string = typeof rt === 'string' && rt.length > 0 ? rt : 'default'
      let ringDuration = rec.ringDurationMinutes
      if (typeof ringDuration !== 'number' || ringDuration < 1) {
        ringDuration = 5
      }
      if (ringDuration !== 1 && ringDuration !== 3 && ringDuration !== 5 && ringDuration !== 10) {
        ringDuration = 5
      }
      let snoozeMin = rec.snoozeIntervalMinutes
      if (typeof snoozeMin !== 'number' || snoozeMin < 1) {
        snoozeMin = 10
      }
      let snoozeCnt = rec.snoozeMaxCount
      if (typeof snoozeCnt !== 'number' || snoozeCnt < 0) {
        snoozeCnt = 3
      }
      const shRaw = rec.smartHolidaySkip
      const smartHolidaySkip = shRaw === true
      const item: AlarmItem = {
        id: id,
        hour: hour,
        minute: minute,
        repeatMode: repeatMode,
        enabled: enabled,
        label: label,
        ringtoneId: ringtoneId,
        ringDurationMinutes: ringDuration,
        snoozeIntervalMinutes: snoozeMin,
        snoozeMaxCount: snoozeCnt,
        smartHolidaySkip: smartHolidaySkip
      }
      out.push(item)
    }
  } catch (_e) {
    return []
  }
  return out
}

export class AlarmPreferences {
  /** missing=true 表示从未持久化过，由页面保留默认示例数据 */
  static async load(context: common.UIAbilityContext): Promise<AlarmLoadResult> {
    const pref = await preferences.getPreferences(context, PREF_NAME)
    const raw = await pref.get(KEY_ALARMS, UNSET) as string
    if (raw === UNSET) {
      const empty: AlarmLoadResult = { missing: true, alarms: [], nextId: 4 }
      return empty
    }
    const alarms = parseAlarmList(raw)
    const nextRaw = await pref.get(KEY_NEXT_ID, '0') as string
    let nextId = Number(nextRaw)
    if (Number.isNaN(nextId) || nextId < 1) {
      nextId = 1
      for (let j = 0; j < alarms.length; j++) {
        if (alarms[j].id >= nextId) {
          nextId = alarms[j].id + 1
        }
      }
    }
    migrateAlarmDataIfNeeded(pref, alarms)
    const result: AlarmLoadResult = { missing: false, alarms: alarms, nextId: nextId }
    return result
  }

  static async save(context: common.UIAbilityContext, alarms: AlarmItem[], nextId: number): Promise<void> {
    const pref = await preferences.getPreferences(context, PREF_NAME)
    await pref.put(KEY_ALARMS, JSON.stringify(alarms))
    await pref.put(KEY_NEXT_ID, `${nextId}`)
    await pref.put(KEY_VERSION, `${CURRENT_VERSION}`)
    await pref.flush()
  }
}

function migrateAlarmDataIfNeeded(pref: preferences.Preferences, alarms: AlarmItem[]): void {
  const verRaw = pref.getSync(KEY_VERSION, '0') as string
  const version = Number(verRaw)
  if (Number.isNaN(version) || version < CURRENT_VERSION) {
    performAlarmMigration(alarms)
    pref.put(KEY_VERSION, `${CURRENT_VERSION}`)
    pref.flush()
  }
}

function performAlarmMigration(alarms: AlarmItem[]): void {
    for (let i = 0; i < alarms.length; i++) {
      const item = alarms[i]
      if (item.ringDurationMinutes === undefined) {
        item.ringDurationMinutes = 5
      }
      if (item.snoozeIntervalMinutes === undefined) {
        item.snoozeIntervalMinutes = 10
      }
      if (item.snoozeMaxCount === undefined) {
        item.snoozeMaxCount = 3
      }
    }
  }
