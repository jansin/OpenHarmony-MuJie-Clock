export interface WorldClockItem {
  city: string
  offsetMinutes: number
}

export interface AlarmItem {
  id: number
  hour: number
  minute: number
  repeatMode: string
  enabled: boolean
  /** 列表与响铃提示中展示的名称 */
  label: string
  /** 铃声标识：default | classic | soft | digital */
  ringtoneId: string
  /** 单次提醒说明用（分钟），可选 1/3/5/10 */
  ringDurationMinutes: number
  /** 稍后提醒间隔（分钟） */
  snoozeIntervalMinutes: number
  /** 可稍后提醒次数（每次响铃周期内） */
  snoozeMaxCount: number
  /**
   * 仅当 repeatMode 为工作日类时有效：是否启用「法定工作日 / 智能跳过节假日」意图。
   * 响铃仍按 repeatMode + repeatMatches 判断（节假日数据未接入时与工作日相同）。
   */
  smartHolidaySkip: boolean
}

export interface NavItem {
  index: number
  title: string
  icon: string
}

export class ClockTheme {
  pageBg: string = '#F7F7F7'
  card: string = '#FFFFFF'
  cardBorder: string = '#ECF0FF'
  nav: string = '#EDEDED'
  /** 底部 Tab 选中项背景（胶囊） */
  navTabActiveBg: string = 'rgba(24, 119, 242, 0.12)'
  ring: string = '#E8E8E8'
  inner: string = '#FFFFFF'
  text: string = '#000000'
  muted: string = '#8A8A8A'
  iconBg: string = '#FFFFFF'
  selectedNav: string = '#1877F2'
  /** 底部 Tab 未选中图标与文字（与 selectedNav 拉开对比） */
  navIdleColor: string = '#8E9093'
  navTopDivider: string = '#E6E6E6'
  /** 滑动删除条背景 */
  deleteColor: string = '#E53935'
  /** 开关关闭态背景 */
  switchOffBg: string = '#E3E3E3'
}

export const LIGHT_THEME: ClockTheme = {
  pageBg: '#F7F7F7',
  card: '#FFFFFF',
  cardBorder: '#ECF0FF',
  nav: '#FFFFFF',
  navTabActiveBg: 'rgba(24, 119, 242, 0.10)',
  ring: '#E8E8E8',
  inner: '#FFFFFF',
  text: '#000000',
  muted: '#8A8A8A',
  iconBg: '#FFFFFF',
  selectedNav: '#1877F2',
  navIdleColor: '#9E9E9E',
  navTopDivider: '#EEEEEE',
  deleteColor: '#E53935',
  switchOffBg: '#E3E3E3'
}

export const DARK_THEME: ClockTheme = {
  pageBg: '#101010',
  card: '#343434',
  cardBorder: '#4A4A4A',
  nav: '#1A1A1A',
  navTabActiveBg: 'rgba(255, 255, 255, 0.08)',
  ring: '#454545',
  inner: '#171717',
  text: '#F4F4F4',
  muted: '#C7C7C7',
  iconBg: '#D9D9D9',
  selectedNav: '#4DA3FF',
  navIdleColor: '#757575',
  navTopDivider: '#252525',
  deleteColor: '#D32F2F',
  switchOffBg: '#555555'
}

export function formatRingtoneLabel(ringtoneId: string): string {
  if (ringtoneId === 'classic') {
    return '经典'
  }
  if (ringtoneId === 'soft') {
    return '轻快'
  }
  if (ringtoneId === 'digital') {
    return '电子'
  }
  return '默认'
}
