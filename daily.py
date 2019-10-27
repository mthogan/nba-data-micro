import datetime

from workers.sites.fivethirtyeight import gather_projections as gather_538_projections, scrape_projections_for_date as scrape_538_projections_for_date, load_projections_for_date as load_538_projections_for_date
from workers.sites.basketball_reference import gather_box_scores_by_date, scrape_box_scores_by_date, load_stat_lines_on_date, load_players_on_date as load_br_players_on_date
from workers.sites.fanduel import load_players_on_date as load_fd_players_on_date, load_salaries_positions_for_date as load_fd_salaries_positions_for_date
from workers.sites.draftkings import load_players_on_date as load_dk_players_on_date, load_salaries_positions_for_date as load_dk_salaries_positions_for_date
from workers.sites.rotogrinders import gather_json_projections_on_date as gather_rg_json_projections_on_date, gather_csv_projections_on_date as gather_rg_csv_projections_on_date, \
    load_json_projections_on_date as load_rg_json_projections_on_date
from workers.sites.fantasycruncher import gather_past_results_on_date as gather_fc_past_results_on_date, load_past_results_on_date as load_fc_past_results_on_date




# From yesterday
yesterday = '2019-10-26'
# this is for players who haven't been there before, but were added from the salaries the day before
'''
gather_box_scores_by_date(yesterday)
scrape_box_scores_by_date(yesterday)
load_br_players_on_date(yesterday)
load_stat_lines_on_date(yesterday)

gather_fc_past_results_on_date(yesterday)
load_fc_past_results_on_date(yesterday)
'''
# For today

today = '2019-10-27'

# after adding the salaries for the day, we want to load the players.


'''
load_fd_players_on_date(today, force=True)
load_dk_players_on_date(today)

load_fd_salaries_positions_for_date(today)
load_dk_salaries_positions_for_date(today)

'''
# now to gather the projections ...
gather_538_projections()
scrape_538_projections_for_date(today)
gather_rg_csv_projections_on_date(today)
gather_rg_json_projections_on_date(today)

# ... and then load them
load_538_projections_for_date(today)
load_rg_json_projections_on_date(today)
