from workers.sites.basketball_reference import gather_box_scores_by_month, gather_box_scores_by_season, \
                                                    scrape_box_scores_by_date, \
                                                    scrape_box_scores_by_season, gather_games_by_season, \
                                                    load_players_by_season as br_load_players_by_season

from workers.general import create_teams

from workers.sites.fivethirtyeight import gather_predictions
from workers.sites.swish_analytics import gather_salary_changes_by_month, scrape_salary_changes_by_month, load_salaries_on_date, \
                                            load_players_on_date as sa_load_players_on_date, \
                                                load_players_in_month as sa_load_players_in_month

date = '2019-01-08'

#sa_load_players_on_date(date)

sa_load_players_in_month(2019, 4)


#gather_box_scores_by_season('14-15')
#scrape_box_scores_by_season('14-15')
#br_load_players_by_season('18-19', force=True)

#gather_salary_changes_by_month(year, month)
#scrape_salary_changes_by_month(year, month)

# load_salaries_on_date(date)

# gather_predictions()

for month in range(1, 7):
    pass
    #scrape_box_scores_by_month(2019, month)
    #gather_box_scores_by_month(2015, month)



# scrape_box_scores(date)

