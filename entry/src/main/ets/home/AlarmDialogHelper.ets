import { AlarmItem, formatRingtoneLabel } from '../components/ClockModels'
import { repeatSummary } from '../common/AlarmRepeat'

export function formatAlarmTimeDigits(hour: number, minute: number): string {
  return `${hour < 10 ? '0' + hour : hour}:${minute < 10 ? '0' + minute : minute}`
}

export function showAlarmRingDialog(
  item: AlarmItem,
  snoozeTapsLeft: number | undefined,
  onSnooze: () => void
): void {
  const name = item.label.trim().length > 0 ? item.label : '闹钟'
  const tone = formatRingtoneLabel(item.ringtoneId)
  const taps =
    snoozeTapsLeft !== undefined && snoozeTapsLeft >= 0 ? snoozeTapsLeft : item.snoozeMaxCount
  const showSnooze = taps > 0 && item.snoozeIntervalMinutes > 0
  const msg =
    `${name} · ${formatAlarmTimeDigits(item.hour, item.minute)}\n${repeatSummary(item.repeatMode)}\n铃声：${tone}\n单次提醒时长：${item.ringDurationMinutes} 分钟`

  if (showSnooze) {
    AlertDialog.show({
      title: '闹钟',
      message: msg,
      primaryButton: {
        value: '关闭',
        action: () => {}
      },
      secondaryButton: {
        value: `稍后 ${item.snoozeIntervalMinutes} 分钟（剩余 ${taps} 次）`,
        action: () => {
          onSnooze()
        }
      }
    })
  } else {
    AlertDialog.show({
      title: '闹钟',
      message: msg,
      primaryButton: {
        value: '关闭',
        action: () => {}
      }
    })
  }
}
