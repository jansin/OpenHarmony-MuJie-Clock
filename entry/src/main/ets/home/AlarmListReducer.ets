import { AlarmItem } from '../components/ClockModels'

export function sortAlarmsByTime(list: AlarmItem[]): AlarmItem[] {
  return list.slice().sort((a: AlarmItem, b: AlarmItem) => {
    const ma = a.hour * 60 + a.minute
    const mb = b.hour * 60 + b.minute
    return ma - mb
  })
}

export function toggleAlarmEnabled(list: AlarmItem[], id: number): AlarmItem[] {
  const updated: AlarmItem[] = []
  for (let i = 0; i < list.length; i++) {
    const item = list[i]
    const nextEnabled = item.id === id ? !item.enabled : item.enabled
    updated.push({
      id: item.id,
      hour: item.hour,
      minute: item.minute,
      repeatMode: item.repeatMode,
      enabled: nextEnabled,
      label: item.label,
      ringtoneId: item.ringtoneId,
      ringDurationMinutes: item.ringDurationMinutes,
      snoozeIntervalMinutes: item.snoozeIntervalMinutes,
      snoozeMaxCount: item.snoozeMaxCount,
      smartHolidaySkip: item.smartHolidaySkip
    })
  }
  return updated
}

export function disableAlarmById(list: AlarmItem[], id: number): AlarmItem[] {
  const updated: AlarmItem[] = []
  for (let i = 0; i < list.length; i++) {
    const item = list[i]
    updated.push({
      id: item.id,
      hour: item.hour,
      minute: item.minute,
      repeatMode: item.repeatMode,
      enabled: item.id === id ? false : item.enabled,
      label: item.label,
      ringtoneId: item.ringtoneId,
      ringDurationMinutes: item.ringDurationMinutes,
      snoozeIntervalMinutes: item.snoozeIntervalMinutes,
      snoozeMaxCount: item.snoozeMaxCount,
      smartHolidaySkip: item.smartHolidaySkip
    })
  }
  return updated
}

export function removeAlarmById(list: AlarmItem[], id: number): AlarmItem[] {
  const next: AlarmItem[] = []
  for (let i = 0; i < list.length; i++) {
    if (list[i].id !== id) {
      next.push(list[i])
    }
  }
  return next
}

export function snapshotAlarmForEditor(src: AlarmItem): AlarmItem {
  return {
    id: src.id,
    hour: src.hour,
    minute: src.minute,
    repeatMode: src.repeatMode,
    enabled: src.enabled,
    label: src.label,
    ringtoneId: src.ringtoneId,
    ringDurationMinutes: src.ringDurationMinutes,
    snoozeIntervalMinutes: src.snoozeIntervalMinutes,
    snoozeMaxCount: src.snoozeMaxCount,
    smartHolidaySkip: src.smartHolidaySkip
  }
}

export interface SaveAlarmMergeResult {
  alarms: AlarmItem[]
  nextId: number
}

export function mergeSavedAlarm(
  current: AlarmItem[],
  nextId: number,
  item: AlarmItem,
  labelClean: string
): SaveAlarmMergeResult {
  let found = false
  for (let i = 0; i < current.length; i++) {
    if (current[i].id === item.id) {
      found = true
      break
    }
  }

  let nextList: AlarmItem[] = []
  let outNextId = nextId
  if (found) {
    for (let i = 0; i < current.length; i++) {
      const cur = current[i]
      if (cur.id === item.id) {
        nextList.push({
          id: item.id,
          hour: item.hour,
          minute: item.minute,
          repeatMode: item.repeatMode,
          enabled: cur.enabled,
          label: labelClean,
          ringtoneId: item.ringtoneId,
          ringDurationMinutes: item.ringDurationMinutes,
          snoozeIntervalMinutes: item.snoozeIntervalMinutes,
          snoozeMaxCount: item.snoozeMaxCount,
          smartHolidaySkip: item.smartHolidaySkip
        })
      } else {
        nextList.push(cur)
      }
    }
  } else {
    const saved: AlarmItem = {
      id: item.id,
      hour: item.hour,
      minute: item.minute,
      repeatMode: item.repeatMode,
      enabled: true,
      label: labelClean,
      ringtoneId: item.ringtoneId,
      ringDurationMinutes: item.ringDurationMinutes,
      snoozeIntervalMinutes: item.snoozeIntervalMinutes,
      snoozeMaxCount: item.snoozeMaxCount,
      smartHolidaySkip: item.smartHolidaySkip
    }
    let inserted = false
    const savedMinutes = saved.hour * 60 + saved.minute
    for (let i = 0; i < current.length; i++) {
      const row = current[i]
      if (!inserted && savedMinutes < row.hour * 60 + row.minute) {
        nextList.push(saved)
        inserted = true
      }
      nextList.push(row)
    }
    if (!inserted) {
      nextList.push(saved)
    }
    outNextId = nextId + 1
  }
  return { alarms: sortAlarmsByTime(nextList), nextId: outNextId }
}
