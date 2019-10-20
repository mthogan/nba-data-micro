from workers.sites.basketball_reference import gather_box_scores_by_month, gather_box_scores_by_date, scrape_box_scores, gather_games, seed_games

from workers.general import create_teams

#for month in range(10,13):
#    gather_box_scores_by_month(2015, month)
#gather_box_scores_by_month(2017, 12)
#scrape_box_scores(date)

#create_teams()
years = range(2014, 2021)
for year in years:
    #gather_games(year)
    seed_games(year)

