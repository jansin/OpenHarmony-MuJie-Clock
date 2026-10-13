import { promptAction } from '@kit.ArkUI'

@Component
export struct SecondTicker {
  @Prop isActive: boolean = true
  onTick: () => void = () => {}
  private timerId: number = -1

  aboutToAppear(): void {
    this.syncTicker()
  }

  aboutToDisappear(): void {
    this.clearTicker()
  }

  syncTicker(): void {
    if (this.isActive) {
      this.ensureTicker()
    } else {
      this.clearTicker()
    }
  }

  private ensureTicker(): void {
    if (this.timerId !== -1) {
      return
    }
    this.onTick()
    this.timerId = setInterval(() => {
      this.onTick()
    }, 1000)
  }

  private clearTicker(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
  }

  build() {
  }
}