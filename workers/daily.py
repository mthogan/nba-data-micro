import datetime


from workers.sites.basketball_reference import gather_srape_load_for_date as gather_srape_load_br_for_date
from workers.sites.fantasycruncher import gather_load_results_for_date as gather_load_fc_results_for_date, load_past_results_on_date

from workers.sites.dfs.fanduel import FanDuel, gather_load_projections_for_date as gather_load_fd_projections_for_date
from workers.sites.dfs.draftkings import DraftKings

from workers.sites.fivethirtyeight import generate_runner as generate_fte_runner
from workers.sites.rotogrinders import generate_runner as generate_rg_runner
from workers.sites.dailyfantasynerd import generate_runner as generate_dfn_runner, load_json_projections_for_date, load_json_projections_for_month
from workers.sites.vegasinsider import generate_runner as generate_vi_runner

def stat_lines(date):
    # work for yesterday is getting the box scores and updating the statlines
    gather_srape_load_br_for_date(date)
    # and then also getting the fantasy cruncher results from contests yesterday as well
    # gather_load_fc_results_for_date(date) # Don't want this now


def fantasy_sites(date):

    gather_load_fd_projections_for_date(date)

    fd = FanDuel()
    fd.load_players_on_date(date)
    fd.load_salaries_positions_for_date(date)

    dk = DraftKings()
    dk.load_players_on_date(date)
    dk.load_salaries_positions_for_date(date)


def outside_projections(date):

    # FTE / 538
    #gather_scrape_load_538_for_date(today)

    vi_runner = generate_vi_runner()
    vi_runner.call('gobd', date)


    fte_runner = generate_fte_runner()
    fte_runner.call('gp')


    # RG next
    rg_runner = generate_rg_runner()
    rg_runner.call('gcsvp', date)
    rg_runner.call('gjsonp', date)


    # DFN finally
    dfn_runner = generate_dfn_runner()
    dfn_runner.call('gpfd', date)
