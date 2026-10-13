import { ClockTheme } from './ClockModels'

@Component
export struct ClockFace {
  diameter: number = 300
  @Prop @Watch('onClockFaceThemeChange') theme: ClockTheme = new ClockTheme()
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private renderContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private timerId: number = -1

  private onClockFaceThemeChange(): void {
    if (this.timerId !== -1) {
      this.drawClock()
    }
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
  }

  private startDrawTask(): void {
    if (this.timerId !== -1) {
      return
    }
    this.drawClock()
    this.timerId = setInterval(() => {
      this.drawClock()
    }, 1000)
  }

  private drawClock(): void {
    const ctx = this.renderContext
    const center = this.diameter / 2
    const radius = this.diameter * 0.45
    const numberRadius = this.diameter * 0.35
    const now = new Date()
    const hour = now.getHours()
    const minute = now.getMinutes()
    const second = now.getSeconds()

    ctx.clearRect(0, 0, this.diameter, this.diameter)
    ctx.shadowColor = 'rgba(0, 0, 0, 0.14)'
    ctx.shadowBlur = 28
    ctx.shadowOffsetX = 0
    ctx.shadowOffsetY = 10
    this.drawCircle(center, center, radius, this.theme.inner)
    ctx.shadowBlur = 0
    ctx.shadowOffsetY = 0
    ctx.strokeStyle = 'rgba(0, 0, 0, 0.06)'
    ctx.lineWidth = 1
    ctx.beginPath()
    ctx.arc(center, center, radius, 0, Math.PI * 2)
    ctx.stroke()

    this.drawTicks(center, radius)
    this.drawNumbers(center, numberRadius)

    this.drawHand(center, (hour % 12) * 30 + minute * 0.5, this.diameter * 0.22, 8, '#000000')
    this.drawHand(center, minute * 6 + second * 0.1, this.diameter * 0.33, 6, '#000000')
    this.drawHand(center, second * 6, this.diameter * 0.36, 1.5, '#FF4D00')
    this.drawCircle(center, center, 7, '#FF4D00')
    this.drawCircle(center, center, 3, '#FFFFFF')
  }

  private drawCircle(x: number, y: number, radius: number, color: string): void {
    const ctx = this.renderContext
    ctx.beginPath()
    ctx.fillStyle = color
    ctx.arc(x, y, radius, 0, Math.PI * 2)
    ctx.fill()
  }

  private drawTicks(center: number, radius: number): void {
    const ctx = this.renderContext
    ctx.lineCap = 'round'
    for (let i = 0; i < 60; i++) {
      const angle = i * Math.PI / 30
      const major = i % 5 === 0
      if (major) {
        ctx.strokeStyle = '#8E8E8E'
        ctx.lineWidth = 3.5
      } else {
        ctx.strokeStyle = '#C8C8C8'
        ctx.lineWidth = 1.5
      }
      const start = major ? 0.86 : 0.92
      ctx.beginPath()
      ctx.moveTo(center + Math.sin(angle) * radius * start, center - Math.cos(angle) * radius * start)
      ctx.lineTo(center + Math.sin(angle) * radius * 0.98, center - Math.cos(angle) * radius * 0.98)
      ctx.stroke()
    }
  }

  private drawNumbers(center: number, radius: number): void {
    const ctx = this.renderContext
    ctx.fillStyle = '#000000'
    ctx.font = '28px sans-serif'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    for (let i = 1; i <= 12; i++) {
      const angle = i % 12 * Math.PI / 6
      ctx.fillText(`${i}`, center + Math.sin(angle) * radius, center - Math.cos(angle) * radius)
    }
  }

  private drawHand(center: number, degrees: number, length: number, width: number, color: string): void {
    const angle = degrees * Math.PI / 180
    const ctx = this.renderContext
    ctx.beginPath()
    ctx.strokeStyle = color
    ctx.lineWidth = width
    ctx.lineCap = 'round'
    ctx.moveTo(center, center)
    ctx.lineTo(center + Math.sin(angle) * length, center - Math.cos(angle) * length)
    ctx.stroke()
  }

  build() {
    Canvas(this.renderContext)
      .width(this.diameter)
      .height(this.diameter)
      .onReady(() => {
        this.startDrawTask()
      })
      .onAppear(() => {
        this.startDrawTask()
      })
  }
}

@Component
export struct TimerDial {
  diameter: number = 248
  @Prop @Watch('onTimerDialThemeChange') theme: ClockTheme = new ClockTheme()
  @Prop @Watch('onProgressDegreesChange') progressDegrees: number = 0
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private renderContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private canvasReady: boolean = false

  private onTimerDialThemeChange(): void {
    if (this.canvasReady) {
      this.draw()
    }
  }

  private onProgressDegreesChange(): void {
    if (this.canvasReady) {
      this.draw()
    }
  }

  private draw(): void {
    const ctx = this.renderContext
    const center = this.diameter / 2
    const radius = this.diameter * 0.45
    ctx.clearRect(0, 0, this.diameter, this.diameter)
    ctx.shadowColor = 'rgba(0, 0, 0, 0.14)'
    ctx.shadowBlur = 28
    ctx.shadowOffsetX = 0
    ctx.shadowOffsetY = 10
    this.drawCircle(center, center, radius, this.theme.inner)
    ctx.shadowBlur = 0
    ctx.shadowOffsetY = 0
    ctx.strokeStyle = 'rgba(0, 0, 0, 0.06)'
    ctx.lineWidth = 1
    ctx.beginPath()
    ctx.arc(center, center, radius, 0, Math.PI * 2)
    ctx.stroke()

    this.drawTicksTimer(center, radius)

    const handLen = radius * 0.8
    this.drawHandTimer(center, this.progressDegrees, handLen, 1.5, '#FF4D00')
    this.drawCircle(center, center, 7, '#FF4D00')
    this.drawCircle(center, center, 3, '#FFFFFF')
  }

  /** 计时器表盘：60 格等长刻度，无数字 */
  private drawTicksTimer(center: number, radius: number): void {
    const ctx = this.renderContext
    ctx.lineCap = 'round'
    ctx.strokeStyle = '#C8C8C8'
    ctx.lineWidth = 2
    const start: number = 0.88
    const end: number = 0.98
    for (let i = 0; i < 60; i++) {
      const angle = i * Math.PI / 30
      ctx.beginPath()
      ctx.moveTo(center + Math.sin(angle) * radius * start, center - Math.cos(angle) * radius * start)
      ctx.lineTo(center + Math.sin(angle) * radius * end, center - Math.cos(angle) * radius * end)
      ctx.stroke()
    }
  }

  private drawCircle(x: number, y: number, radius: number, color: string): void {
    const ctx = this.renderContext
    ctx.beginPath()
    ctx.fillStyle = color
    ctx.arc(x, y, radius, 0, Math.PI * 2)
    ctx.fill()
  }

  private drawHandTimer(center: number, degrees: number, length: number, width: number, color: string): void {
    const angle = degrees * Math.PI / 180
    const ctx = this.renderContext
    ctx.beginPath()
    ctx.strokeStyle = color
    ctx.lineWidth = width
    ctx.lineCap = 'round'
    ctx.moveTo(center, center)
    ctx.lineTo(center + Math.sin(angle) * length, center - Math.cos(angle) * length)
    ctx.stroke()
  }

  build() {
    Canvas(this.renderContext)
      .width(this.diameter)
      .height(this.diameter)
      .onReady(() => {
        this.canvasReady = true
        this.draw()
      })
      .onAppear(() => {
        if (this.canvasReady) {
          this.draw()
        }
      })
  }
}

@Component
export struct StopwatchDial {
  diameter: number = 248
  @Prop @Watch('onStopwatchDialThemeChange') theme: ClockTheme = new ClockTheme()
  /** 已计毫秒数；外圈一圈 = 60 秒，指针连续扫过 */
  @Prop @Watch('onElapsedMsChange') elapsedMs: number = 0
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private renderContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private canvasReady: boolean = false

  private onStopwatchDialThemeChange(): void {
    if (this.canvasReady) {
      this.draw()
    }
  }

  private onElapsedMsChange(): void {
    if (this.canvasReady) {
      this.draw()
    }
  }

  private handDegreesFromElapsed(): number {
    const msInMinute: number = this.elapsedMs % 60000
    return msInMinute / 60000 * 360
  }

  private draw(): void {
    const ctx = this.renderContext
    const center = this.diameter / 2
    const radius = this.diameter * 0.45
    const fontOuter = `${Math.round(this.diameter * 28 / 300)}px sans-serif`
    const fontInner = `${Math.round(this.diameter * 14 / 300)}px sans-serif`
    ctx.clearRect(0, 0, this.diameter, this.diameter)
    ctx.shadowColor = 'rgba(0, 0, 0, 0.14)'
    ctx.shadowBlur = 28
    ctx.shadowOffsetX = 0
    ctx.shadowOffsetY = 10
    this.drawCircle(center, center, radius, this.theme.inner)
    ctx.shadowBlur = 0
    ctx.shadowOffsetY = 0
    ctx.strokeStyle = 'rgba(0, 0, 0, 0.06)'
    ctx.lineWidth = 1
    ctx.beginPath()
    ctx.arc(center, center, radius, 0, Math.PI * 2)
    ctx.stroke()

    this.drawTicksStopwatch(center, radius)

    ctx.fillStyle = '#000000'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    ctx.font = fontOuter
    for (let i = 5; i <= 60; i += 5) {
      const angle = i % 60 * Math.PI / 30
      ctx.fillText(`${i}`, center + Math.sin(angle) * radius * 0.72, center - Math.cos(angle) * radius * 0.72)
    }
    ctx.font = fontInner
    for (let i = 5; i <= 30; i += 5) {
      const angle = i % 30 * Math.PI / 15
      ctx.fillText(`${i}`, center + Math.sin(angle) * radius * 0.28, center - Math.cos(angle) * radius * 0.28)
    }

    this.drawHandStopwatch(center, this.handDegreesFromElapsed(), radius * 0.36, 1.5, '#FF4D00')
    this.drawCircle(center, center, 7, '#FF4D00')
    this.drawCircle(center, center, 3, '#FFFFFF')
  }

  /** 与 ClockFace.drawTicks 一致 */
  private drawTicksStopwatch(center: number, radius: number): void {
    const ctx = this.renderContext
    ctx.lineCap = 'round'
    for (let i = 0; i < 60; i++) {
      const angle = i * Math.PI / 30
      const major = i % 5 === 0
      if (major) {
        ctx.strokeStyle = '#8E8E8E'
        ctx.lineWidth = 3.5
      } else {
        ctx.strokeStyle = '#C8C8C8'
        ctx.lineWidth = 1.5
      }
      const start = major ? 0.86 : 0.92
      ctx.beginPath()
      ctx.moveTo(center + Math.sin(angle) * radius * start, center - Math.cos(angle) * radius * start)
      ctx.lineTo(center + Math.sin(angle) * radius * 0.98, center - Math.cos(angle) * radius * 0.98)
      ctx.stroke()
    }
  }

  private drawCircle(x: number, y: number, radius: number, color: string): void {
    const ctx = this.renderContext
    ctx.beginPath()
    ctx.fillStyle = color
    ctx.arc(x, y, radius, 0, Math.PI * 2)
    ctx.fill()
  }

  private drawHandStopwatch(center: number, degrees: number, length: number, width: number, color: string): void {
    const angle = degrees * Math.PI / 180
    const ctx = this.renderContext
    ctx.beginPath()
    ctx.strokeStyle = color
    ctx.lineWidth = width
    ctx.lineCap = 'round'
    ctx.moveTo(center, center)
    ctx.lineTo(center + Math.sin(angle) * length, center - Math.cos(angle) * length)
    ctx.stroke()
  }

  build() {
    Canvas(this.renderContext)
      .width(this.diameter)
      .height(this.diameter)
      .onReady(() => {
        this.canvasReady = true
        this.draw()
      })
      .onAppear(() => {
        if (this.canvasReady) {
          this.draw()
        }
      })
  }
}
