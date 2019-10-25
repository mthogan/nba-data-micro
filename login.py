from workers.sites.fantasycruncher import gather_past_results_on_date, gather_past_results_for_month, load_past_results_on_date, load_past_results_for_month

date = '2019-01-02'
#load_past_results_on_date(date)


year = 2016
for month in [10,11,12]:
    load_past_results_for_month(year, month)
