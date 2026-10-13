/** 世界时钟固定偏移展示（与夏令时无关，与 ClockPage 逻辑一致） */
export function formatGmtLabel(offsetMinutes: number): string {
  const absTotal = Math.abs(offsetMinutes)
  const h = Math.floor(absTotal / 60)
  const m = absTotal % 60
  const sign = offsetMinutes >= 0 ? '+' : '-'
  if (m === 0) {
    return `GMT${sign}${h}`
  }
  return `GMT${sign}${h}:${m < 10 ? '0' + m : m}`
}
