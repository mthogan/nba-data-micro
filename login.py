from workers.sites.rotogrinders import gather_json_projections_on_date, gather_csv_projections_on_date, load_json_projections_on_date, load_json_projections_for_month

from workers.sites.fanduel import load_players_for_season as fd_load_players_for_season, load_salaries_positions_for_date as load_fd_salaries_positions_for_date, load_salaries_positions_for_month as load_fd_salaries_positions_for_month
from workers.sites.draftkings import load_players_for_season as dk_load_players_for_season, load_salaries_positions_for_date as load_dk_salaries_positions_for_date, load_salaries_positions_for_month as load_dk_salaries_positions_for_month


from workers.sites.fivethirtyeight import scrape_projections_for_date, load_projections_for_date, load_players_on_date as load_fte_players_on_date

date = '2019-01-01'
#load_fte_players_on_date(date)
#load_projections_for_date(date)

load_fd_salaries_positions_for_date(date)

season = '19-20'
#dk_load_players_for_season(season)
#fd_load_players_for_season(season)

#load_fd_salaries_positions_for_date(date)
#load_dk_salaries_positions_for_date(date)


#gather_csv_projections_for_season(season)
#load_salaries_for_season(season)

#gather_json_projections_for_season(season)

date = '2019-01-03'
#gather_json_projections_on_date(date)
#load_json_projections_on_date(date)



months = [10,11,12]
year = 2018
for month in months:
    #load_fd_salaries_positions_for_month(year, month)
    load_dk_salaries_positions_for_month(year, month)

#load_json_projections_on_date(date)
