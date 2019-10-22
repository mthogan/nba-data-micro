from workers.sites.basketball_reference import gather_box_scores_for_month, gather_box_scores_for_season, \
                                                    scrape_box_scores_by_date, \
                                                    scrape_box_scores_for_season, gather_games_for_season, \
                                                    load_players_for_season as br_load_players_for_season, \
                                                    load_stat_lines_for_season

from workers.general import create_teams

from workers.sites.fivethirtyeight import gather_predictions, scrape_predictions
from workers.sites.swish_analytics import gather_salary_changes_for_month, scrape_salary_changes_for_month, load_salaries_on_date, \
                                            load_players_on_date as sa_load_players_on_date, \
                                                load_players_in_month as sa_load_players_in_month

gather_predictions()
scrape_predictions()

#stat lines
#gather_box_scores_for_season('14-15')
#scrape_box_scores_for_season('14-15')
#load_stat_lines_for_season('14-15')


#players
#br_load_players_for_season('18-19', force=True)
#sa_load_players_on_date(date)
#sa_load_players_in_month(2019, 4)

#gather_salary_changes_for_month(year, month)
#scrape_salary_changes_for_month(year, month)


