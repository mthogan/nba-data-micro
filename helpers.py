import datetime
import calendar


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

def iso_dates_in_month(year, month):
    '''
    Yields date in isoformat in a specific year and month
    '''
    num_days = calendar.monthrange(year, month)[1]
    days = [datetime.date(year, month, day) for day in range(1, num_days+1)]
    for day in days:
        yield day.isoformat()


def dates_in_season(season):
    '''
    Season is of format '18-19', or '19-20'.
    '''
    start_year, end_year = season.split('-')
    full_start_year = int('20' + start_year)
    full_end_year = int('20' + end_year)
    for month in range(10, 13):
        for day in iso_dates_in_month(full_start_year, month):
            yield day
    for month in range(1, 7):
        for day in iso_dates_in_month(full_end_year, month):
            yield day
