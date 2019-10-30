from workers.sites.fantasycruncher import load_past_results_for_month


year = 2019
months = [10]

for month in months:
    load_past_results_for_month(year, month)
