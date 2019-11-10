import datetime


from workers.sites.basketball_reference import gather_srape_load_for_date as gather_srape_load_br_for_date
from workers.sites.fantasycruncher import gather_load_results_for_date as gather_load_fc_results_for_date, load_past_results_on_date

from workers.sites.dfs.fanduel import FanDuel, gather_load_projections_for_date as gather_load_fd_projections_for_date
from workers.sites.dfs.draftkings import DraftKings

from workers.sites.fivethirtyeight import generate_runner as generate_fte_runner


from workers.sites.rotogrinders import gather_load_projections_for_date as gather_load_rg_projections_for_date
from workers.sites.dailyfantasynerd import generate_runner as generate_dfn_runner, load_json_projections_for_date, load_json_projections_for_month


# Dates currently strings, not using datetime today functions
yesterday = '2019-11-09'
today = '2019-11-10'



# work for yesterday is getting the box scores and updating the statlines
#gather_srape_load_br_for_date(yesterday)
# and then also getting the fantasy cruncher results from contests yesterday as well
#gather_load_fc_results_for_date(yesterday)


'''
fd = FanDuel()
fd.load_players_on_date(today)
fd.load_salaries_positions_for_date(today)
'''
#gather_load_fd_projections_for_date(today)
'''
dk = DraftKings()
dk.load_players_on_date(today)
dk.load_salaries_positions_for_date(today)
'''

# now to gather the projections ...
# 538 first



# FTE / 538
#gather_scrape_load_538_for_date(today)

#fte_runner = generate_fte_runner(today)
#fte_runner.run()

# RG next
#gather_load_rg_projections_for_date(today)

# DFN finally
'''
date = '2019-10-26'
month = 11
year = 2019
load_json_projections_for_month(year, month)
'''
'''
dfn_runner = generate_dfn_runner(today)
dfn_runner.run()
'''