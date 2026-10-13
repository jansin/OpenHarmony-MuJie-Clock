import { AlarmItem } from '../components/ClockModels'

export function indexSeedAlarms(): AlarmItem[] {
  return [
    {
      id: 1,
      hour: 6,
      minute: 50,
      repeatMode: 'Weekdays',
      enabled: true,
      label: '起床',
      ringtoneId: 'default',
      ringDurationMinutes: 5,
      snoozeIntervalMinutes: 10,
      snoozeMaxCount: 3,
      smartHolidaySkip: true
    },
    {
      id: 2,
      hour: 7,
      minute: 30,
      repeatMode: 'Every day',
      enabled: false,
      label: '闹钟',
      ringtoneId: 'default',
      ringDurationMinutes: 5,
      snoozeIntervalMinutes: 10,
      snoozeMaxCount: 3,
      smartHolidaySkip: false
    },
    {
      id: 3,
      hour: 8,
      minute: 0,
      repeatMode: 'Once',
      enabled: false,
      label: '闹钟',
      ringtoneId: 'default',
      ringDurationMinutes: 5,
      snoozeIntervalMinutes: 10,
      snoozeMaxCount: 3,
      smartHolidaySkip: false
    }
  ]
}
