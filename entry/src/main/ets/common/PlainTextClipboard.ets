import pasteboard from '@ohos.pasteboard'
import { promptAction } from '@kit.ArkUI'

/** 将纯文本写入系统剪贴板；失败时静默忽略 */
export function copyPlainText(text: string): void {
  try {
    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
    pasteboard.getSystemPasteboard().setData(data)
  } catch (_e) {
  }
}

export function copyPlainTextWithToast(text: string, toastMessage: string): void {
  copyPlainText(text)
  try {
    promptAction.showToast({ message: toastMessage, duration: 2000 })
  } catch (_e) {
  }
}
