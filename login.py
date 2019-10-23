from workers.sites.rotogrinders import gather_json_projections_on_date, gather_csv_projections_on_date

from workers.sites.fanduel import load_players_for_season as fd_load_players_for_season, load_salaries_positions_for_date, load_stat_lines_for_month
from workers.sites.draftkings import load_players_for_season as dk_load_players_for_season

date = '2019-01-03'


season = '19-20'
#dk_load_players_for_season(season)
#fd_load_players_for_season(season)

#load_salaries_positions_for_date(date)

#gather_csv_projections_for_season(season)
#load_salaries_for_season(season)

#gather_json_projections_for_season(season)

date = '2019-10-23'
gather_json_projections_on_date(date)


'''
months = [4]
year = 2019
for month in months:
    load_stat_lines_for_month(year, month)
'''
