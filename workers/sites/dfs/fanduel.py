from workers.sites.dfs.dfs_site import DfsSite


class FanDuel(DfsSite):

    def __init__(self):
        super().__init__('fd')

    def _name_from_row(self, row):
        name = row[3]
        if not name:
            name = f'{row[2]} {row[4]}'  # examples is 2019-01-25.csv
        return name


    def _position_salary_from_row(self, row):
        return (row[1], row[7])


    def _team_abbrv_from_row(self, row):
        return row[9]

    def _player_site_id_from_row(self, row):
        return row[0]
        