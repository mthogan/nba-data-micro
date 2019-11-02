from workers.sites.basketball_reference import gather_box_scores_for_month, gather_box_scores_for_season, \
                                                    scrape_box_scores_by_date, \
                                                    scrape_box_scores_for_season, gather_games_for_season, \
                                                    load_players_for_season as br_load_players_for_season, \
                                                    load_stat_lines_for_season, load_stat_lines_on_date,  \
                                                    load_stat_lines_for_month, load_game_scores_for_date

from utils import perform_action_for_season

date = '2019-10-31'
#load_game_scores_for_date(date)
perform_action_for_season('14-15', load_game_scores_for_date)
