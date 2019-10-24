import os
import csv

import utils

from db.finders import find_player_by_exact_name, find_team_by_abbrv, find_game_by_date_and_team, find_stat_line_by_player_and_game
from db.updaters import update_stat_line_position_salary
from db.creators import create_stat_line_with_position_salary

import helpers
import utils


base_directory = f'data2/salaries'


def _name_from_row(row):
    return row[2].strip()


def _position_salary_from_row(row):
    return (row[0], row[5])


def _team_abbrv_from_row(row):
    return row[7]


def loop_files_for_season(season):
    directory = f'{base_directory}/{season}/dk'
    for _, _, files in os.walk(directory):
        for filename in files:
            if filename.endswith(".csv"):
                filepath = f'{directory}/{filename}'
                yield filepath


def load_players_for_season(season):
    for filepath in loop_files_for_season(season):
        utils.load_players_from_file(
            filepath, 'dk', _name_from_row, force=False)


def load_players_on_date(date):
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/{season}/dk'
    filepath = f'{directory}/{date}.csv'
    utils.load_players_from_file(filepath, 'dk', _name_from_row, force=False)

def load_salaries_positions_for_month(year, month):
    for day in helpers.iso_dates_in_month(year, month):
        load_salaries_positions_for_date(day)


def load_salaries_positions_for_date(date):
    print(f'Loading DK salaries and positions for {date}')
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/{season}/dk'
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
                    'dk', stat_line['id'], pos, sal)
            else:
                print(f'No existing stat_line for {name}. Creating one now.')
                create_stat_line_with_position_salary(
                    'dk', player['id'], team['id'], game['id'], pos, sal)
