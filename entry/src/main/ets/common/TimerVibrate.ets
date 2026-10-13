import vibrator from '@ohos.vibrator'

/** 计时结束短振；无权限或设备不支持时静默失败 */
export function vibrateTimerFinished(): void {
  try {
    vibrator.vibrate(400)
  } catch (_e) {
  }
}
