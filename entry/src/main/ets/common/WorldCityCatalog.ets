import { WorldClockItem } from '../components/ClockModels'

/** 世界城市条目：含区域，用于「添加城市」筛选 */
export interface WorldCityRow extends WorldClockItem {
  /** 1 亚太 2 欧洲 3 美洲 4 中东与非洲 */
  region: number
}

const _RAW: WorldCityRow[] = [
  { city: '帕果帕果（美属萨摩亚）', offsetMinutes: -11 * 60, region: 1 },
  { city: '檀香山（美国）', offsetMinutes: -10 * 60, region: 3 },
  { city: '安克雷奇（美国）', offsetMinutes: -9 * 60, region: 3 },
  { city: '洛杉矶（美国）', offsetMinutes: -8 * 60, region: 3 },
  { city: '丹佛（美国）', offsetMinutes: -7 * 60, region: 3 },
  { city: '芝加哥（美国）', offsetMinutes: -6 * 60, region: 3 },
  { city: '墨西哥城（墨西哥）', offsetMinutes: -6 * 60, region: 3 },
  { city: '纽约（美国）', offsetMinutes: -5 * 60, region: 3 },
  { city: '多伦多（加拿大）', offsetMinutes: -5 * 60, region: 3 },
  { city: '利马（秘鲁）', offsetMinutes: -5 * 60, region: 3 },
  { city: '波哥大（哥伦比亚）', offsetMinutes: -5 * 60, region: 3 },
  { city: '加拉加斯（委内瑞拉）', offsetMinutes: -4 * 60, region: 3 },
  { city: '哈利法克斯（加拿大）', offsetMinutes: -4 * 60, region: 3 },
  { city: '拉巴斯（玻利维亚）', offsetMinutes: -4 * 60, region: 3 },
  { city: '圣保罗（巴西）', offsetMinutes: -3 * 60, region: 3 },
  { city: '布宜诺斯艾利斯（阿根廷）', offsetMinutes: -3 * 60, region: 3 },
  { city: '蒙得维的亚（乌拉圭）', offsetMinutes: -3 * 60, region: 3 },
  { city: '亚松森（巴拉圭）', offsetMinutes: -3 * 60, region: 3 },
  { city: '圣地亚哥（智利）', offsetMinutes: -3 * 60, region: 3 },
  { city: '努克（格陵兰）', offsetMinutes: -3 * 60, region: 2 },
  { city: '蓬塔阿雷纳斯（智利）', offsetMinutes: -3 * 60, region: 3 },
  { city: '圣约翰斯（加拿大）', offsetMinutes: -3 * 60 + 30, region: 3 },
  { city: '费尔南多-迪诺罗尼亚（巴西）', offsetMinutes: -2 * 60, region: 3 },
  { city: '普拉亚（佛得角）', offsetMinutes: -1 * 60, region: 4 },
  { city: '伦敦（英国）', offsetMinutes: 0, region: 2 },
  { city: '里斯本（葡萄牙）', offsetMinutes: 0, region: 2 },
  { city: '都柏林（爱尔兰）', offsetMinutes: 0, region: 2 },
  { city: '阿比让（科特迪瓦）', offsetMinutes: 0, region: 4 },
  { city: '卡萨布兰卡（摩洛哥）', offsetMinutes: 1 * 60, region: 4 },
  { city: '柏林（德国）', offsetMinutes: 1 * 60, region: 2 },
  { city: '巴黎（法国）', offsetMinutes: 1 * 60, region: 2 },
  { city: '罗马（意大利）', offsetMinutes: 1 * 60, region: 2 },
  { city: '马德里（西班牙）', offsetMinutes: 1 * 60, region: 2 },
  { city: '阿姆斯特丹（荷兰）', offsetMinutes: 1 * 60, region: 2 },
  { city: '布鲁塞尔（比利时）', offsetMinutes: 1 * 60, region: 2 },
  { city: '维也纳（奥地利）', offsetMinutes: 1 * 60, region: 2 },
  { city: '华沙（波兰）', offsetMinutes: 1 * 60, region: 2 },
  { city: '拉各斯（尼日利亚）', offsetMinutes: 1 * 60, region: 4 },
  { city: '开罗（埃及）', offsetMinutes: 2 * 60, region: 4 },
  { city: '雅典（希腊）', offsetMinutes: 2 * 60, region: 2 },
  { city: '赫尔辛基（芬兰）', offsetMinutes: 2 * 60, region: 2 },
  { city: '基辅（乌克兰）', offsetMinutes: 2 * 60, region: 2 },
  { city: '约翰内斯堡（南非）', offsetMinutes: 2 * 60, region: 4 },
  { city: '耶路撒冷（以色列）', offsetMinutes: 2 * 60, region: 4 },
  { city: '莫斯科（俄罗斯）', offsetMinutes: 3 * 60, region: 2 },
  { city: '伊斯坦布尔（土耳其）', offsetMinutes: 3 * 60, region: 4 },
  { city: '内罗毕（肯尼亚）', offsetMinutes: 3 * 60, region: 4 },
  { city: '利雅得（沙特阿拉伯）', offsetMinutes: 3 * 60, region: 4 },
  { city: '巴格达（伊拉克）', offsetMinutes: 3 * 60, region: 4 },
  { city: '德黑兰（伊朗）', offsetMinutes: 3 * 60 + 30, region: 4 },
  { city: '迪拜（阿联酋）', offsetMinutes: 4 * 60, region: 4 },
  { city: '巴库（阿塞拜疆）', offsetMinutes: 4 * 60, region: 4 },
  { city: '第比利斯（格鲁吉亚）', offsetMinutes: 4 * 60, region: 4 },
  { city: '喀布尔（阿富汗）', offsetMinutes: 4 * 60 + 30, region: 1 },
  { city: '卡拉奇（巴基斯坦）', offsetMinutes: 5 * 60, region: 1 },
  { city: '塔什干（乌兹别克斯坦）', offsetMinutes: 5 * 60, region: 1 },
  { city: '新德里（印度）', offsetMinutes: 5 * 60 + 30, region: 1 },
  { city: '加德满都（尼泊尔）', offsetMinutes: 5 * 60 + 45, region: 1 },
  { city: '达卡（孟加拉国）', offsetMinutes: 6 * 60, region: 1 },
  { city: '仰光（缅甸）', offsetMinutes: 6 * 60 + 30, region: 1 },
  { city: '曼谷（泰国）', offsetMinutes: 7 * 60, region: 1 },
  { city: '雅加达（印度尼西亚）', offsetMinutes: 7 * 60, region: 1 },
  { city: '胡志明市（越南）', offsetMinutes: 7 * 60, region: 1 },
  { city: '北京（中国）', offsetMinutes: 8 * 60, region: 1 },
  { city: '上海（中国）', offsetMinutes: 8 * 60, region: 1 },
  { city: '香港（中国）', offsetMinutes: 8 * 60, region: 1 },
  { city: '台北（中国）', offsetMinutes: 8 * 60, region: 1 },
  { city: '新加坡', offsetMinutes: 8 * 60, region: 1 },
  { city: '吉隆坡（马来西亚）', offsetMinutes: 8 * 60, region: 1 },
  { city: '马尼拉（菲律宾）', offsetMinutes: 8 * 60, region: 1 },
  { city: '珀斯（澳大利亚）', offsetMinutes: 8 * 60, region: 1 },
  { city: '东京（日本）', offsetMinutes: 9 * 60, region: 1 },
  { city: '首尔（韩国）', offsetMinutes: 9 * 60, region: 1 },
  { city: '阿德莱德（澳大利亚）', offsetMinutes: 9 * 60 + 30, region: 1 },
  { city: '达尔文（澳大利亚）', offsetMinutes: 9 * 60 + 30, region: 1 },
  { city: '悉尼（澳大利亚）', offsetMinutes: 10 * 60, region: 1 },
  { city: '莫尔兹比港（巴布亚新几内亚）', offsetMinutes: 10 * 60, region: 1 },
  { city: '关岛', offsetMinutes: 10 * 60, region: 1 },
  { city: '努美阿（新喀里多尼亚）', offsetMinutes: 11 * 60, region: 1 },
  { city: '奥克兰（新西兰）', offsetMinutes: 12 * 60, region: 1 },
  { city: '斐济苏瓦', offsetMinutes: 12 * 60, region: 1 },
  { city: '汤加努库阿洛法', offsetMinutes: 13 * 60, region: 1 }
]

function compareRows(a: WorldCityRow, b: WorldCityRow): number {
  if (a.offsetMinutes !== b.offsetMinutes) {
    return a.offsetMinutes - b.offsetMinutes
  }
  if (a.city < b.city) {
    return -1
  }
  if (a.city > b.city) {
    return 1
  }
  return 0
}

function buildSorted(rows: WorldCityRow[]): WorldCityRow[] {
  const out: WorldCityRow[] = []
  for (let i = 0; i < rows.length; i++) {
    out.push(rows[i])
  }
  out.sort(compareRows)
  return out
}

/** 按 UTC 偏移、城市名排序后的内置城市库 */
export const SORTED_WORLD_CITIES: WorldCityRow[] = buildSorted(_RAW)
