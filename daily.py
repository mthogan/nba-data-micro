from workers.sites.fivethirtyeight import gather_projections as gather_538_projections
from workers.sites.basketball_reference import gather_box_scores_by_date, scrape_box_scores_by_date, load_stat_lines_on_date, load_players_on_date as load_br_players_on_date
from workers.sites.fanduel import load_players_on_date as load_fd_players_on_date, load_salaries_positions_for_date as load_fd_salaries_positions_for_date
from workers.sites.draftkings import load_players_on_date as load_dk_players_on_date, load_salaries_positions_for_date as load_dk_salaries_positions_for_date


# From yesterday
yesterday = '2019-10-22'
# this is for players who haven't been there before, but were added from the salaries the day before
# load_br_players_on_date(yesterday)
# gather_box_scores_by_date(yesterday)
# scrape_box_scores_by_date(yesterday)
# load_stat_lines_on_date(yesterday)

# For today

today = '2019-10-23'
# gather_538_projections()


# after adding the salaries for the day, we want to load the players.
# load_fd_players_on_date(today)
# load_dk_players_on_date(today)


# load_fd_salaries_positions_for_date(today)
# load_dk_salaries_positions_for_date(today)
