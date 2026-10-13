import { SnoozeTick } from './IndexSnoozeModels'

export function filterSnoozeTicksExcludingAlarm(ticks: SnoozeTick[], alarmId: number): SnoozeTick[] {
  const kept: SnoozeTick[] = []
  for (let i = 0; i < ticks.length; i++) {
    if (ticks[i].alarmId !== alarmId) {
      kept.push(ticks[i])
    }
  }
  return kept
}

export function appendSnoozeTick(ticks: SnoozeTick[], tick: SnoozeTick): SnoozeTick[] {
  return ticks.concat([tick])
}

export interface SnoozePartitionResult {
  kept: SnoozeTick[]
  due: SnoozeTick[]
}

export function partitionDueSnoozeTicks(ticks: SnoozeTick[], nowMs: number): SnoozePartitionResult {
  const kept: SnoozeTick[] = []
  const due: SnoozeTick[] = []
  for (let i = 0; i < ticks.length; i++) {
    const t = ticks[i]
    if (t.fireAt <= nowMs) {
      due.push(t)
    } else {
      kept.push(t)
    }
  }
  return { kept: kept, due: due }
}
