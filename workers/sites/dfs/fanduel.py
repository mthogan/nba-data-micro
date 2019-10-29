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


'''
def loop_files_for_season(season):
    directory = f'{base_directory}/{season}/fd'
    for _, _, files in os.walk(directory):
        for filename in files:
            if filename.endswith(".csv"):
                filepath = f'{directory}/{filename}'
                yield filepath


def load_players_for_season(season):
    for filepath in loop_files_for_season(season):
        utils.load_players_from_file(
            filepath, 'fd', _name_from_row, force=False)


def load_players_on_date(date, force=False):
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/{season}/fd'
    filepath = f'{directory}/{date}.csv'
    utils.load_players_from_file(filepath, 'fd', _name_from_row, force=force)


def load_salaries_positions_for_month(year, month):
    for day in helpers.iso_dates_in_month(year, month):
        load_salaries_positions_for_date(day)


def load_salaries_positions_for_date(date):
    print(f'Loading FD salaries and positions for {date}')
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/{season}/fd'
    for fn in os.listdir(directory):
        if fn.startswith(date):
            filepath = f'{directory}/{fn}'
            load_salaries_positions_for_date_with_filepath(date, filepath)

def load_salaries_positions_for_date_with_filepath(date, filepath):
    with open(filepath, 'r') as f:
        reader = csv.reader(f)
        next(reader, None)
        for row in reader:
            name = _name_from_row(row)
            pos, sal = _position_salary_from_row(row)
            team_abbrv = _team_abbrv_from_row(row)
            player = find_player_by_exact_name(name)
            team = find_team_by_abbrv(team_abbrv)
            game = find_game_by_date_and_team(date, team['id'])
            if not player or not game:
                import pdb
                pdb.set_trace()
            stat_line = find_stat_line_by_player_and_game(
                player['id'], game['id'])
            if stat_line:
                update_stat_line_position_salary(
                    'fd', stat_line['id'], pos, sal)
            else:
                print(f'No existing stat_line for {name}. Creating one now.')
                create_stat_line_with_position_salary(
                    'fd', player['id'], team['id'], game['id'], pos, sal)
'''
