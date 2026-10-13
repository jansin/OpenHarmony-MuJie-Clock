export function alarmMinuteKeyFromDate(now: Date): string {
  return `${now.getFullYear()}-${now.getMonth()}-${now.getDate()}-${now.getHours()}-${now.getMinutes()}`
}
