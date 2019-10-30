from workers.sites.dfs.dfs_site import DfsSite


class DraftKings(DfsSite):

    def __init__(self):
        super().__init__('dk')


    def _name_from_row(self, row):
        return row[2].strip()


    def _position_salary_from_row(self, row):
        return (row[0], row[5])


    def _team_abbrv_from_row(self, row):
        return row[7]

    def _player_site_id_from_row(self, row):
        return row[3]
