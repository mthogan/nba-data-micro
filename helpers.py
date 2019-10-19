import datetime

thirty_six_minutes_in_seconds = 36 * 60

def time_stamp_to_minutes(timestamp):
  return time_stamp_to_seconds(timestamp) / 60.0

def time_stamp_to_seconds(timestamp):
  if not timestamp or timestamp == '0':
    return 0
  minutes, seconds = timestamp.split(':')
  return int(minutes) * 60 + int(seconds)
