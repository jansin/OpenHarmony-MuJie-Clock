import { NavItem } from '../components/ClockModels'

export const INDEX_NAV_ITEMS: NavItem[] = [
  { index: 0, title: '闹钟', icon: 'alarm' },
  { index: 1, title: '世界时钟', icon: 'world' },
  { index: 2, title: '秒表', icon: 'stop' },
  { index: 3, title: '计时器', icon: 'clock' }
]

export function indexNavTitle(tabIndex: number): string {
  const i = Math.floor(tabIndex)
  if (i < 0 || i >= INDEX_NAV_ITEMS.length) {
    return INDEX_NAV_ITEMS[0].title
  }
  return INDEX_NAV_ITEMS[i].title
}
