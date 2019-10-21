from workers.sites.basketball_reference import gather_box_scores_by_month, gather_box_scores_by_date, scrape_box_scores_by_date, scrape_box_scores_by_year, gather_games, seed_games
from workers.sites.basketball_reference import seed_players_by_date

from workers.general import create_teams

from workers.sites.fivethirtyeight import gather_predictions
from workers.sites.swish_analytics import gather_salary_changes_by_month, scrape_salary_changes_by_month, load_salaries_on_date

date='2019-01-01'

year = 2017
for month in range(1,7):
    #gather_salary_changes_by_month(year, month)
    scrape_salary_changes_by_month(year, month)

#load_salaries_on_date(date)

#gather_predictions()

for month in range(1,7):
    pass
    #scrape_box_scores_by_month(2019, month)
    #gather_box_scores_by_month(2015, month)

#scrape_box_scores_by_year(2019)

#seed_players_by_date(date)

#scrape_box_scores(date)

'''
#create_teams()
years = range(2014, 2021)
for year in years:
    #gather_games(year)
    seed_games(year)
'''