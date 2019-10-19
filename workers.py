from workers.sites.basketball_reference import gather_box_scores_by_month, gather_box_scores_by_date, scrape_box_scores

date = '2019-01-04'
for month in range(1,6):
    gather_box_scores_by_month(2019, month)
#scrape_box_scores(date)