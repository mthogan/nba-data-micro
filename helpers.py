import datetime


def timestamp_to_minutes(timestamp):
    return time_stamp_to_seconds(timestamp) / 60.0

def time_stamp_to_seconds(timestamp):
    if not timestamp or timestamp == '0':
        return 0
    minutes, seconds = timestamp.split(':')
    return int(minutes) * 60 + int(seconds)

def season_from_date(date):
    date = datetime.date.fromisoformat(date)
    if date.month < 8:
        return f'{(date.year-1) % 100}-{date.year % 100}'
    else:
        return f'{date.year % 100}-{(date.year+1) % 100}'
