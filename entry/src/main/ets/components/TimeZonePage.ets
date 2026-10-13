import { ClockTheme, WorldClockItem } from './ClockModels'
import { SecondaryTitleBar } from './SecondaryTitleBar'
import { SORTED_WORLD_CITIES, WorldCityRow } from '../common/WorldCityCatalog'
import { formatGmtLabel } from '../common/WorldTimeFormat'
import { MUJIE_CARD_RADIUS, MUJIE_SCREEN_PAD_H, MUJIE_SCREEN_PAD_TOP } from '../common/UiTokens'

@Component
export struct TimeZonePage {
  @Prop theme: ClockTheme = new ClockTheme()
  onBack: () => void = () => {}
  onSelect: (item: WorldClockItem) => void = () => {}
  @State private keyword: string = ''
  @State private regionFilter: number = 0
  @State private tick: number = 0
  @State private filteredList: WorldCityRow[] = []
  private listScroller: Scroller = new Scroller()
  private timerId: number = -1
  private readonly regionChipLabels: string[] = ['全部', '亚太', '欧洲', '美洲', '中东与非洲']

  aboutToAppear(): void {
    this.recomputeFilteredList()
    this.timerId = setInterval(() => {
      this.tick++
    }, 1000)
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
  }

  private normalizedKeyword(): string {
    return this.keyword.trim()
  }

  private cityMatchesKeyword(city: string, kw: string): boolean {
    if (kw.length === 0) {
      return true
    }
    if (city.indexOf(kw) >= 0) {
      return true
    }
    const lower = kw.toLowerCase()
    const cityLower = city.toLowerCase()
    return cityLower.indexOf(lower) >= 0
  }

  private rowMatchesRegion(row: WorldCityRow): boolean {
    if (this.regionFilter === 0) {
      return true
    }
    return row.region === this.regionFilter
  }

  private recomputeFilteredList(): void {
    const kw = this.normalizedKeyword()
    const out: WorldCityRow[] = []
    for (let i = 0; i < SORTED_WORLD_CITIES.length; i++) {
      const row = SORTED_WORLD_CITIES[i]
      if (!this.rowMatchesRegion(row)) {
        continue
      }
      if (!this.cityMatchesKeyword(row.city, kw)) {
        continue
      }
      out.push(row)
    }
    this.filteredList = out
  }

  private hasVisibleZones(): boolean {
    return this.filteredList.length > 0
  }

  private indexLetter(city: string): string {
    if (city.length === 0) {
      return '#'
    }
    const c = city.charAt(0)
    const code = c.charCodeAt(0)
    if ((code >= 65 && code <= 90) || (code >= 97 && code <= 122)) {
      return c.toUpperCase()
    }
    return '#'
  }

  private sidebarLetters(): string[] {
    const list = this.filteredList
    const letters: string[] = []
    for (let i = 0; i < list.length; i++) {
      const L = this.indexLetter(list[i].city)
      let found = false
      for (let j = 0; j < letters.length; j++) {
        if (letters[j] === L) {
          found = true
          break
        }
      }
      if (!found) {
        letters.push(L)
      }
    }
    letters.sort((a: string, b: string) => {
      if (a === '#') {
        return 1
      }
      if (b === '#') {
        return -1
      }
      if (a < b) {
        return -1
      }
      if (a > b) {
        return 1
      }
      return 0
    })
    return letters
  }

  private firstIndexForLetter(letter: string): number {
    const list = this.filteredList
    for (let i = 0; i < list.length; i++) {
      if (this.indexLetter(list[i].city) === letter) {
        return i
      }
    }
    return -1
  }

  private scrollToLetter(letter: string): void {
    const idx = this.firstIndexForLetter(letter)
    if (idx < 0) {
      return
    }
    try {
      this.listScroller.scrollToIndex(idx, true, ScrollAlign.START)
    } catch (_e) {
    }
  }

  build() {
    Stack({ alignContent: Alignment.End }) {
      Column() {
        SecondaryTitleBar({
          title: '添加城市',
          theme: this.theme,
          onLeft: () => {
            this.onBack()
          }
        })

        Row() {
          Text('⌕')
            .fontColor(this.theme.muted)
            .fontSize(22)
            .margin({ left: 16, right: 10 })
          TextInput({ placeholder: '搜索城市或国家', text: this.keyword })
            .fontSize(16)
            .fontColor(this.theme.text)
            .placeholderColor(this.theme.muted)
            .backgroundColor('#00000000')
            .layoutWeight(1)
            .onChange((value: string) => {
              this.keyword = value
              this.recomputeFilteredList()
            })
          if (this.keyword.length > 0) {
            Text('清除')
              .fontColor(this.theme.selectedNav)
              .fontSize(14)
              .margin({ left: 8, right: 14 })
              .onClick(() => {
                this.keyword = ''
                this.recomputeFilteredList()
              })
          }
        }
        .width('100%')
        .height(56)
        .borderRadius(MUJIE_CARD_RADIUS)
        .borderWidth(1)
        .borderColor(this.theme.cardBorder)
        .backgroundColor(this.theme.card)
        .margin({ top: 16, bottom: 10 })

        Scroll() {
          Row({ space: 8 }) {
            this.RegionChip(0)
            this.RegionChip(1)
            this.RegionChip(2)
            this.RegionChip(3)
            this.RegionChip(4)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .margin({ bottom: 12 })

        if (this.normalizedKeyword().length > 0 && !this.hasVisibleZones()) {
          Column() {
            Text('未找到匹配城市')
              .fontColor(this.theme.text)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Text('试试其它关键词，或切换到「全部」区域')
              .fontColor(this.theme.muted)
              .fontSize(13)
              .margin({ top: 8 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .padding({ left: 24, right: 24 })
        } else {
          List({ scroller: this.listScroller }) {
            ForEach(this.filteredList, (item: WorldCityRow) => {
              ListItem() {
                this.ZoneRow(item)
              }
              .onClick(() => {
                this.onSelect(item)
              })
            }, (item: WorldCityRow) => item.city)
          }
          .width('100%')
          .layoutWeight(1)
          .borderRadius(MUJIE_CARD_RADIUS)
          .borderWidth(1)
          .borderColor(this.theme.cardBorder)
          .backgroundColor(this.theme.card)
          .padding({ left: 18, right: 18, top: 16, bottom: 16 })
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: MUJIE_SCREEN_PAD_H, right: MUJIE_SCREEN_PAD_H, top: MUJIE_SCREEN_PAD_TOP, bottom: 20 })

      if (this.hasVisibleZones()) {
        Column() {
          Text('#')
            .fontColor(this.theme.muted)
            .fontSize(11)
            .margin({ bottom: 4 })
          ForEach(this.sidebarLetters(), (letter: string) => {
            Text(letter)
              .fontColor(this.theme.muted)
              .fontSize(12)
              .width(22)
              .height(18)
              .textAlign(TextAlign.Center)
              .onClick(() => {
                this.scrollToLetter(letter)
              })
          }, (letter: string) => `tz-letter-${letter}`)
        }
        .margin({ right: 4, top: 120, bottom: 40 })
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.pageBg)
  }

  @Builder
  ZoneRow(item: WorldCityRow) {
    Column() {
      Text(item.city)
        .fontColor(this.theme.text)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .width('100%')
      Text(`${formatGmtLabel(item.offsetMinutes)} · ${this.currentTime(item.offsetMinutes)}`)
        .fontColor(this.theme.muted)
        .fontSize(12)
        .margin({ top: 6 })
        .width('100%')
        .visibility(this.tick >= 0 ? Visibility.Visible : Visibility.Hidden)
      Divider()
        .height(1)
        .color(this.theme.cardBorder)
        .margin({ top: 12 })
    }
    .width('100%')
    .constraintSize({ minHeight: 66 })
    .padding({ top: 8, bottom: 8 })
  }

  @Builder
  RegionChip(idx: number) {
    Text(this.regionChipLabels[idx])
      .fontSize(13)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.regionFilter === idx ? '#FFFFFF' : this.theme.text)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .borderRadius(20)
      .backgroundColor(this.regionFilter === idx ? this.theme.selectedNav : this.theme.cardBorder)
      .onClick(() => {
        this.regionFilter = idx
        this.recomputeFilteredList()
      })
  }

  private currentTime(offsetMinutes: number): string {
    const utcMs = new Date().getTime() + new Date().getTimezoneOffset() * 60000
    const target = new Date(utcMs + offsetMinutes * 60000)
    const hours = target.getHours()
    const minutes = target.getMinutes()
    const seconds = target.getSeconds()
    const pad = (n: number): string => (n < 10 ? `0${n}` : `${n}`)
    return `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`
  }
}
