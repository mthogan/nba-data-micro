from workers.sites.rotogrinders import load_player_for_month


date = '2019-01-01'


year = 2018
months = [10,11,12]
for month in months:
    load_player_for_month(year, month)