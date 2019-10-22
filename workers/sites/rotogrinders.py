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

# GATHER

sign_in_url = 'https://rotogrinders.com/sign-in'
username = 'jdsjds'
password = '!gxMwpXGY34dP97'
login_data = {'username': username, 'password': password}


base_url = "https://rotogrinders.com/projected-stats/nba-player.csv?site=%s&date=%s"
base_directory = 'data2/projections/roto'

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


def _get_filepath_from_date(date, site_abbrv):
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/{season}/{site_abbrv}'
    utils.ensure_directory_exists(directory)
    return f"{directory}/{date}.csv"


def gather_projections_for_season(season):
    session = _get_roto_session()
    for date in utils.dates_in_season(season):
        gather_projections_on_date(date, session=session)


def gather_projections_for_month(year, month, session=None):
    if not session:
        session = _get_roto_session()
    for date in utils.iso_dates_in_month(year, month):
        gather_projections_on_date(date, session=session)


def gather_projections_on_date(date, session=False):
    if not session:
        session = _get_roto_session()
    for site_name, site_abbrv in site_infos:
        print(f'Getting projections for {date} from {site_name}')
        url = base_url % (site_name, date)
        page = session.get(url)
        filepath = _get_filepath_from_date(date, site_abbrv)
        with open(filepath, 'w') as f:
            f.write(page.text)  # throw the csv file there


def load_players_for_season(season):
    for date in utils.dates_in_season(season):
        load_players_on_date(date)


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
        import pdb
        pdb.set_trace()
    stat_line = find_stat_line_by_player_and_game(player['id'], game['id'])
    if stat_line:
        update_stat_line_position_salary(site_abbrv, stat_line['id'], pos, sal)


def add_past_salaries(site_abbrv, date):
    '''
    TODO NOTE need to add the ability to do this for any site
    '''
    filename = 'data/projections/roto/fd/%s.csv' % date
    print(filename)
    with open(filename, 'r') as f:
        reader = csv.reader(f)
        for row in reader:
            name = row[0].strip()
            salary = int(row[1])
            player = find_player_by_name(name)
            if not player:
                print(f'not found {name}')
            # print 'player:', player.dk_name, player.dk_name, player.br_name
            if player:
                stat_line = find_stat_line_for_player_on_date(player, date)
                if stat_line:
                    stat_line.fd_salary = salary
                    session_add(stat_line)
        session_commit()


def add_projections(site_abbrv, date):
    site = find_site(site_abbrv)
    filename = 'data/projections/roto/{}/{}.csv'.format(site_abbrv, date)
    print(filename)
    with open(filename, 'r') as f:
        reader = csv.reader(f)
        for row in reader:
            name = row[0].strip()
            salary = int(row[1])
            ceil = float(row[5])
            floor = float(row[6])
            guess = float(row[7])
            player = find_player_by_name(name)
            if not player:
                print(f'not found {name}')
                continue
            stat_line = find_stat_line_for_player_on_date(player, date)
            # print player, stat_line
            if not stat_line:
                print(f'stat_line not found for {name}')
            else:
                if getattr(stat_line, '%s_salary' % site_abbrv) is None:
                    print(
                        f'Setting salary for site {site_abbrv} and player {name}')
                    setattr(stat_line, '%s_salary' % site_abbrv, salary)
            projection = find_projection_for_player_on_date(player, date)
            if not projection:
                print(f'projection not found for {name}')
                projection = Projection(stat_line=stat_line, player=player)
            projection.rg_minutes = minutes
            setattr(projection, 'rg_%s_guess' % site_abbrv, guess)
            setattr(projection, 'rg_%s_ceil' % site_abbrv, ceil)
            setattr(projection, 'rg_%s_floor' % site_abbrv, floor)
            session_add(projection)
        session_commit()


def gather_projections_json(site_name, site_abbrv, date):
    print(f'Getting projections for {date} from {site_name}')
    base_url = "https://rotogrinders.com/projected-stats/nba-player?site={}&date={}"
    res = requests.get(base_url.format(site_name, date))
    filename = 'data/projections/roto/{}/{}.json'.format(site_abbrv, date)
    asdf = r'data = (.*?);'
    data_string = re.search(asdf, res.text).group(1)
    data = json.loads(data_string)
    with open(filename, 'w') as outfile:
        json.dump(data, outfile)


def add_projections_json(site_abbrv, date):
    site = find_site(site_abbrv)
    filename = 'data/projections/roto/%s/%s.json' % (site_abbrv, date)
    print(filename)
    with open(filename, 'r') as f:
        data = json.load(f)
        for player_info in data:
            minutes = float(player_info['pmin'])
            name = player_info['player_name'].strip()
            floor = player_info['floor']
            ceil = player_info['ceil']
            guess = player_info['points']
            player = find_player_by_name(name)
            positions = player_info['position']
            if not player:
                print(name)
                continue
            stat_line = find_stat_line_for_player_on_date(player, date)
            if not stat_line:
                print(f"No stat line for {name}")
                continue
            setattr(stat_line, '%s_positions' % site_abbrv, positions)
            session_add(stat_line)
            projection = find_projection_for_player_on_date(player, date)
            if not projection:
                print(f'projection not found for {name}')
                projection = Projection(stat_line=stat_line, player=player)
            projection.rg_minutes = minutes
            setattr(projection, 'rg_%s_guess' % site_abbrv, guess)
            setattr(projection, 'rg_%s_ceil' % site_abbrv, ceil)
            setattr(projection, 'rg_%s_floor' % site_abbrv, floor)
            session_add(projection)
            session_commit()
