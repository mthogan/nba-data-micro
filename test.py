from workers.sites.dfs.fanduel import FanDuel
from workers.sites.dfs.draftkings import DraftKings

date='2019-11-16'
fd = FanDuel()
fd.load_salaries_positions_for_date(date)
dk = DraftKings()
dk.load_salaries_positions_for_date(date)