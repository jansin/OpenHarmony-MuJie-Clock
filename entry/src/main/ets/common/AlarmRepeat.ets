/** 与 Index.checkAlarms 一致的重复规则判断 */
export function repeatMatches(repeatMode: string, day: number): boolean {
  if (repeatMode === 'Once' || repeatMode === 'Every day') {
    return true
  }
  if (repeatMode === 'Weekdays') {
    return day >= 1 && day <= 5
  }
  if (repeatMode === 'Weekends') {
    return day === 0 || day === 6
  }
  return false
}

export function repeatSummary(mode: string): string {
  if (mode === 'Every day') {
    return '每天'
  }
  if (mode === 'Weekdays') {
    return '法定工作日 (智能跳过节假日)'
  }
  if (mode === 'Weekends') {
    return '周末'
  }
  return '不重复'
}

/** 编辑页「重复」一行用的简短文案 */
export function repeatPickerSummary(mode: string): string {
  if (mode === 'Every day') {
    return '每天'
  }
  if (mode === 'Weekdays') {
    return '工作日'
  }
  if (mode === 'Weekends') {
    return '周末'
  }
  return '不重复'
}

/** 闹钟列表副标题：区分普通工作日与「智能跳过节假日」 */
export function alarmListRepeatSummary(repeatMode: string, smartHolidaySkip: boolean): string {
  if (repeatMode === 'Weekdays' && smartHolidaySkip) {
    return '工作日 · 智能跳过节假日'
  }
  return repeatPickerSummary(repeatMode)
}
