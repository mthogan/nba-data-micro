import os
import calendar
import datetime

def ensure_directory_exists(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)

def iso_days_for_month(year, month):
    num_days = calendar.monthrange(year, month)[1]
    days = [datetime.date(year, month, day) for day in range(1, num_days+1)]
    for day in days:
        yield day.isoformat()
