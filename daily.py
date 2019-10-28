import datetime


from workers.sites.basketball_reference import gather_srape_load_for_date as gather_srape_load_br_for_date
from workers.sites.fantasycruncher import gather_load_results_for_date as gather_load_fc_results_for_date

from workers.sites.fanduel import load_players_on_date as load_fd_players_on_date, load_salaries_positions_for_date as load_fd_salaries_positions_for_date
from workers.sites.draftkings import load_players_on_date as load_dk_players_on_date, load_salaries_positions_for_date as load_dk_salaries_positions_for_date

from workers.sites.fivethirtyeight import gather_scrape_load_for_date as gather_scrape_load_538_for_date
from workers.sites.rotogrinders import gather_load_projections_for_date as gather_load_rg_projections_for_date


# Dates currently strings, not using datetime today functions
yesterday = '2019-10-27'
today = '2019-10-28'


# work for yesterday is getting the box scores and updating the statlines
#gather_srape_load_br_for_date(yesterday)
# and then also getting the fantasy cruncher results from contests yesterday as well
#gather_load_fc_results_for_date(yesterday)

'''
load_fd_players_on_date(today, force=True)
load_dk_players_on_date(today)

load_fd_salaries_positions_for_date(today)
load_dk_salaries_positions_for_date(today)
'''

# now to gather the projections ...
# 538 first
gather_scrape_load_538_for_date(today)

#RG next
gather_load_rg_projections_for_date(today)

