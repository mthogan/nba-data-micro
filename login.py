from workers.sites.fanduel import FanDuel


date = '2019-10-29'
fd = FanDuel()
fd.load_salaries_positions_for_date(date)
