import os
import csv

from db.db import actor

import utils
import helpers

class DfsSite():

    base_directory = f'data/salaries'

    def __init__(self, site_abbrv):
        if not site_abbrv:
            raise ValueError('Need site_abbrv when creating DFS Site object')
        self.site_abbrv = site_abbrv

    def _name_from_row(self, row):
        raise NameError('_name_from_row is not defined')


    def _position_salary_from_row(self, row):
        raise NameError('_position_salary_from_row is not defined')


    def _team_abbrv_from_row(self, row):
        raise NameError('_team_abbrv_from_row is not defined')

    def _player_site_id_from_row(self, row):
        raise NameError('_player_site_id_from_row is not defined')


    def loop_files_for_season(self, season):
        directory = f'{DfsSite.base_directory}/{season}/{self.site_abbrv}'
        for _, _, files in os.walk(directory):
            for filename in files:
                if filename.endswith(".csv"):
                    filepath = f'{directory}/{filename}'
                    yield filepath


    def load_players_for_season(self, season):
        for filepath in self.loop_files_for_season(season):
            utils.load_players_from_file(
                filepath, self.site_abbrv, self._name_from_row, force=False)


    def load_players_on_date(self, date, force=False):
        season = helpers.season_from_date(date)
        directory = f'{self.base_directory}/{season}/{self.site_abbrv}'
        filepath = f'{directory}/{date}.csv'
        utils.load_players_from_file(filepath, self.site_abbrv, self._name_from_row, force=force)


    def load_salaries_positions_for_month(self, year, month):
        for date in helpers.iso_dates_in_month(year, month):
            self.load_salaries_positions_for_date(date)


    def load_salaries_positions_for_date(self, date):
        print(f'Loading {self.site_abbrv} salaries and positions for {date}')
        season = helpers.season_from_date(date)
        directory = f'{self.base_directory}/{season}/{self.site_abbrv}'
        for fn in os.listdir(directory):
            if fn.startswith(date):
                filepath = f'{directory}/{fn}'
                self.load_salaries_positions_for_date_with_filepath(date, filepath)

    def load_salaries_positions_for_date_with_filepath(self, date, filepath):
        print(f'Filepath {filepath}')
        with open(filepath, 'r') as f:
            reader = csv.reader(f)
            next(reader, None)
            for row in reader:
                name = self._name_from_row(row)
                pos, sal = self._position_salary_from_row(row)
                team_abbrv = self._team_abbrv_from_row(row)
                player_site_id = self._player_site_id_from_row(row)
                player = actor.find_player_by_exact_name(name)
                team = actor.find_team_by_abbrv(team_abbrv)
                game = actor.find_game_by_date_and_team(date, team['id'])
                if not player or not game:
                    import pdb
                    pdb.set_trace()
                stat_line = actor.find_stat_line_by_player_and_game(
                    player['id'], game['id'])
                if stat_line:
                    actor.update_stat_line_position_salary(
                        self.site_abbrv, stat_line['id'], pos, sal, player_site_id)
                else:
                    print(f'No existing stat_line for {name}. Creating one now.')
                    actor.create_stat_line_with_position_salary(
                        self.site_abbrv, player['id'], team['id'], game['id'], pos, sal, player_site_id)
