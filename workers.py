from workers.sites.basketball_reference import gather_box_scores_for_month, gather_box_scores_for_season, \
                                                    scrape_box_scores_by_date, \
                                                    scrape_box_scores_for_season, gather_games_for_season, \
                                                    load_players_for_season as br_load_players_for_season, \
                                                    load_stat_lines_for_season, load_stat_lines_on_date,  \
                                                    load_stat_lines_for_month


from workers.sites.fivethirtyeight import gather_projections, scrape_projections
from workers.sites.swish_analytics import gather_salary_changes_for_month, scrape_salary_changes_for_month, load_salaries_on_date, \
                                            load_players_on_date as sa_load_players_on_date, \
                                                load_players_in_month as sa_load_players_in_month


date = '2019-01-03'
#load_stat_lines_on_date(date)
#scrape_box_scores_by_date(date)

#gather_projections()
#scrape_projections()

#for month in [1,2,3,4,5,6]:
#    load_stat_lines_for_month(2018, month)

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


