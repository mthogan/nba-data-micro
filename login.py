from workers.sites.basketball_reference import gather_box_scores_by_date#, gather_past_results_for_month, load_past_results_on_date, load_past_results_for_month

date = '2019-02-15'
#load_past_results_on_date(date)

gather_box_scores_by_date(date)
'''
year = 2019
for month in [2]:
    
    load_past_results_for_month(year, month)

'''