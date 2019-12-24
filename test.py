import helpers

from workers.sites.dfs.draftkings import gather_contest_info_date_by_date, gather_players_for_contest
from workers.sites.dfs.fanduel import load_slates_for_date

date='2019-12-14'
#load_slates_for_date(date)

for date in helpers.dates_in_season('19-20'):
    load_slates_for_date(date)