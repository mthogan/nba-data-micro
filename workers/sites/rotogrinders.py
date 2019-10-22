import requests
from lxml import html
import os
import csv
import json
import re

from db.finders import find_stat_line_by_player_and_game, find_player_by_exact_name, \
    find_team_by_site_abbrv, find_game_by_date_and_team
from db.updaters import update_stat_line_position_salary
import utils
import helpers

import requests
import csv

sign_in_url = 'https://rotogrinders.com/sign-in'
username = 'jdsjds'
password = '!gxMwpXGY34dP97'
login_data = {'username': username, 'password': password}


base_url = "https://rotogrinders.com/projected-stats/nba-player.csv?site=%s&date=%s"
base_directory = 'data2/rotogrinders'

site_infos = [('fanduel', 'fd'), ('draftkings', 'dk')]

def _get_roto_session():
    with requests.Session() as session:
        post = session.post(sign_in_url, data=login_data)
        if post.status_code == 200:
            print('Roto session success')
            return session
        else:
            print(post.status_code)
            print('Roto session error')
            return None


def _get_filepath_from_date(date, data_type, site_abbrv):
    '''
    To make it easier to know where the data is going.
    data_type refers to whether it's the csv data or json
    since rg has both.
    '''
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/{data_type}/{season}/{site_abbrv}'
    utils.ensure_directory_exists(directory)
    return f"{directory}/{date}.csv"


def gather_csv_projections_for_season(season):
    session = _get_roto_session()
    utils.perform_action_for_season(season, gather_csv_projections_on_date, session=session)


def gather_csv_projections_for_month(year, month, session=None):
    if not session:
        session = _get_roto_session()
    for date in utils.iso_dates_in_month(year, month):
        gather_projections_on_date(date, session=session)


def gather_csv_projections_on_date(date, session=False):
    if not session:
        session = _get_roto_session()
    for site_name, site_abbrv in site_infos:
        print(f'Getting projections for {date} from {site_name}')
        url = base_url % (site_name, date)
        page = session.get(url)
        filepath = _get_filepath_from_date(date, 'csvs', site_abbrv)
        with open(filepath, 'w') as f:
            f.write(page.text)  # throw the csv file there


def load_players_for_season(season):
    utils.perform_action_for_season(season, load_players_on_date)


def load_players_for_month(year, month):
    for date in utils.iso_dates_in_month(year, month):
        load_players_on_date(date)


def load_players_on_date(date):
    '''
    Looping through the csv files to get the player names added
    to the rg_name column.
    '''
    print(f'Loading players on {date}')
    for _, site_abbrv in site_infos:
        filepath = _get_filepath_from_date(date, site_abbrv)
        with open(filepath, 'r') as f:
            reader = csv.reader(f)
            for row in reader:
                name = row[0].strip()
                utils.load_players_by_name('rg', name)


def load_salaries_for_season(season):
    for date in utils.dates_in_season(season):
        load_salaries_on_date(date)


def load_salaries_for_month(year, month):
    for date in utils.iso_dates_in_month(year, month):
        load_salaries_on_date(date)


def load_salaries_on_date(date):
    print(f'Loading salaries from RG on {date}')
    for _, site_abbrv in site_infos:
        filepath = _get_filepath_from_date(date, site_abbrv)
        with open(filepath, 'r') as f:
            reader = csv.reader(f)
            for row in reader:
                update_stat_line(date, site_abbrv, row)


def update_stat_line(date, site_abbrv, row):
    name, sal, team_abbrv, pos = row[:4]
    player = find_player_by_exact_name(name.strip())
    team = find_team_by_site_abbrv('rg', team_abbrv)
    game = find_game_by_date_and_team(date, team['id'])
    if not player or not game:
        print(f'No player {name} or game on {date}')
        return
    stat_line = find_stat_line_by_player_and_game(player['id'], game['id'])
    if stat_line:
        update_stat_line_position_salary(site_abbrv, stat_line['id'], pos, sal)
