import { ClockTheme } from './ClockModels'
import {
  MUJIE_NAV_ICON_ACTIVE,
  MUJIE_NAV_ICON_IDLE
} from '../common/UiTokens'

function iconResource(name: string): Resource {
  if (name === 'gear') { return $r('app.media.flat_icon_settings') }
  if (name === 'back') { return $r('app.media.flat_icon_back') }
  if (name === 'moon') { return $r('app.media.flat_icon_moon') }
  if (name === 'sun') { return $r('app.media.flat_icon_sun') }
  if (name === 'plus') { return $r('app.media.flat_icon_plus') }
  if (name === 'play') { return $r('app.media.flat_icon_play') }
  if (name === 'pause') { return $r('app.media.flat_icon_pause') }
  if (name === 'world') { return $r('app.media.flat_icon_globe') }
  if (name === 'hour') { return $r('app.media.flat_icon_hourglass') }
  if (name === 'stop') { return $r('app.media.flat_icon_stopwatch') }
  if (name === 'clock') { return $r('app.media.flat_icon_clock') }
  return $r('app.media.flat_icon_alarm')
}

function iconRatio(name: string): number {
  if (name === 'plus') { return 0.5 }
  if (name === 'play' || name === 'pause') { return 0.46 }
  return 0.56
}

@Component
export struct IconButton {
  icon: string = 'alarm'
  buttonSize: number = 40
  @Prop theme: ClockTheme = new ClockTheme()
  filled: boolean = true
  active: boolean = false
  /** 底部 Tab：图标尺寸对齐 FlowDay（选中 29 / 未选中 27） */
  navBarMode: boolean = false

  build() {
    Stack() {
      if (this.filled && !this.navBarMode) {
        Stack() {}
          .width(this.buttonSize)
          .height(this.buttonSize)
          .borderRadius(this.buttonSize / 2)
          .backgroundColor('#00000000')
      }

      Stack() {
        this.IconImage()
      }
      .opacity(this.navBarOpacity())
    }
    .width(this.navBarMode ? 38 : this.buttonSize)
    .height(this.navBarMode ? 38 : this.buttonSize)
  }

  private navIconSize(): number {
    return this.active ? MUJIE_NAV_ICON_ACTIVE : MUJIE_NAV_ICON_IDLE
  }

  private iconDim(ratio: number): number {
    if (this.navBarMode) {
      return this.navIconSize()
    }
    return this.buttonSize * ratio
  }

  @Builder
  IconImage() {
    Image(iconResource(this.icon))
      .width(this.iconDim(iconRatio(this.icon)))
      .height(this.iconDim(iconRatio(this.icon)))
      .objectFit(ImageFit.Contain)
      .fillColor(this.iconColor())
      .clip(this.icon === 'play')
  }

  private navBarOpacity(): number {
    if (this.navBarMode) {
      return this.active ? 1 : 0.55
    }
    return this.filled || this.active ? 1 : 0.55
  }

  private iconColor(): string {
    if (this.navBarMode) {
      return this.active ? this.theme.selectedNav : this.theme.navIdleColor
    }
    if (this.filled) {
      return this.theme.text
    }
    return this.active ? this.theme.selectedNav : this.theme.muted
  }
}
