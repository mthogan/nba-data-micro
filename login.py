from workers.sites.dfs.fanduel import load_player_info_for_date

date = '2019-11-06'
#load_player_info_for_date(date)

from workers.sites.dailyfantasynerd import gather_projections_for_date, load_json_projections_for_date

from workers.runner import Runner

date = '2019-11-06'
vals = ((gather_projections_for_date, date), (load_json_projections_for_date, date))

owr = Runner(vals)

owr.run()