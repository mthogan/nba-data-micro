import requests
from lxml import html
import os
import csv
import json
import re
import calendar


import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

from db.db import actor

import utils
import helpers

import requests
import csv

sign_in_url = 'https://rotogrinders.com/sign-in'
username = 'jdsjds'
password = '!gxMwpXGY34dP97'
login_data = {'username': username, 'password': password}


base_url = "https://rotogrinders.com/projected-stats/nba-player.csv?site=%s&date=%s"
base_directory = 'data/rotogrinders'

base_json_url = 'https://d1qacz8ndd7avl.cloudfront.net/lineuphq/v1.00/%s/3/base/nba-player.json'

site_infos = [('fanduel', 'fd'), ('draftkings', 'dk')]

def _get_roto_session():
    with requests.Session() as session:
        post = session.post(sign_in_url, data=login_data)
        if post.status_code == 200:
            logger.info('Roto session success')
            return session
        else:
            logger.info(post.status_code)
            logger.info('Roto session error')
            return None


def _get_csv_filepath_from_date(date, site_abbrv):
    '''
    To make it easier to know where the data is going.
    data_type refers to whether it's the csv data or json
    since rg has both.
    '''
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/csvs/{season}/{site_abbrv}'
    utils.ensure_directory_exists(directory)
    return f"{directory}/{date}.csv"

def _get_json_filepath_from_date(date):
    '''
    To make it easier to know where the data is going.
    data_type refers to whether it's the csv data or json
    since rg has both.
    '''
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/json/{season}'
    utils.ensure_directory_exists(directory)
    return f"{directory}/{date}.json"

def gather_csv_projections_for_season(season):
    session = _get_roto_session()
    utils.perform_action_for_season(season, gather_csv_projections_on_date, session=session)


def gather_csv_projections_for_month(year, month, session=None):
    if not session:
        session = _get_roto_session()
    for date in helpers.iso_dates_in_month(year, month):
        gather_csv_projections_on_date(date, session=session)


def gather_csv_projections_on_date(date, session=False):
    if not session:
        session = _get_roto_session()
    for site_name, site_abbrv in site_infos:
        logger.info(f'Getting projections for {date} from {site_name}')
        url = base_url % (site_name, date)
        page = session.get(url)
        filepath = _get_csv_filepath_from_date(date, site_abbrv)
        with open(filepath, 'w') as f:
            f.write(page.text)  # throw the csv file there


def gather_json_projections_for_season(season):
    session = _get_roto_session()
    utils.perform_action_for_season(season, gather_json_projections_on_date, session=session)

def gather_json_projections_on_date(date, session=False):
    if not session:
        session = _get_roto_session()
    logger.info(f'Getting json RG projections for {date}')
    url = base_json_url % (date)
    page = session.get(url)
    filepath = _get_json_filepath_from_date(date)
    with open(filepath, 'w') as f:
        f.write(page.text)  # throw the csv file there



def load_players_for_season(season):
    utils.perform_action_for_season(season, load_players_on_date)


def load_players_for_month(year, month):
    for date in helpers.iso_dates_in_month(year, month):
        load_players_on_date(date)


def load_players_on_date(date):
    '''
    Looping through the csv files to get the player names added
    to the rg_name column.
    '''
    logger.info(f'Loading players on {date}')
    for _, site_abbrv in site_infos:
        filepath = _get_csv_filepath_from_date(date, site_abbrv)
        with open(filepath, 'r') as f:
            reader = csv.reader(f)
            for row in reader:
                name = row[0].strip()
                utils.load_players_by_name('rg', name)


def load_salaries_for_season(season):
    for date in helpers.dates_in_season(season):
        load_salaries_on_date(date)


def load_salaries_for_month(year, month):
    for date in helpers.iso_dates_in_month(year, month):
        load_salaries_on_date(date)


def load_salaries_on_date(date):
    logger.info(f'Loading salaries from RG on {date}')
    for _, site_abbrv in site_infos:
        filepath = _get_csv_filepath_from_date(date, site_abbrv)
        with open(filepath, 'r') as f:
            reader = csv.reader(f)
            for row in reader:
                update_stat_line(date, site_abbrv, row)


def update_stat_line(date, site_abbrv, row):
    name, sal, team_abbrv, pos = row[:4]
    player = actor.find_player_by_exact_name(name.strip())
    team = actor.find_team_by_site_abbrv('rg', team_abbrv)
    game = actor.find_game_by_date_and_team(date, team['id'])
    if not player or not game:
        logger.info(f'No player {name} or game on {date}')
        return
    stat_line = actor.find_stat_line_by_player_and_game(player['id'], game['id'])
    if stat_line:
        actor.update_stat_line_position_salary(site_abbrv, stat_line['id'], pos, sal)

def load_json_projections_for_month(year, month):
    for date in helpers.iso_dates_in_month(year, month):
        load_json_projections_on_date(date)

def load_json_projections_on_date(date):
    logger.info(f'Loading RG projections on {date}')
    filepath = _get_json_filepath_from_date(date)
    with open(filepath, 'r') as f:
        try:
            data = json.loads(f.read())
        except json.decoder.JSONDecodeError:
            logger.info(f'Failed reading in json for file. Returning.')
            return
        results = data['data']['results']
        for result_key in results:
            overall_info = results[result_key]
            load_json_projections(date, overall_info)

rg_site_numbers = {'dk': '20', 'fd': '2'}
source = 'rg'

def load_json_projections(date, overall_info):
    '''
    Takes player_info, which is the dict of player info from the rg json format,
    and takes out the data needed for projections
    '''
    player_info = overall_info['player']
    first_name = player_info['first_name']
    last_name = player_info['last_name']
    name = f'{first_name} {last_name}'.strip()
    #find the player
    player = actor.find_player_by_exact_name(name)
    if not player:
        logger.info(f'Player {name} not found')
        return

    #find the stat_line
    stat_line = actor.find_stat_line_by_player_and_date(player['id'], date)
    if not stat_line:
        logger.info(f'Stat line for {name} on {date} not found.')
        return


    minutes = overall_info['minutes']

    fpts_info = overall_info['fpts']
    fd_pts = fpts_info[rg_site_numbers['fd']]
    dk_pts = fpts_info[rg_site_numbers['dk']]

    bulk = {}
    try: # for celing
        ceiling_ratio = overall_info['ceiling']
        dk_pts_ceil = dk_pts * (1 + ceiling_ratio)
        fd_pts_ceil = fd_pts * (1 + ceiling_ratio)
        bulk['dk_pts_ceil'] = dk_pts_ceil
        bulk['fd_pts_ceil'] = fd_pts_ceil
    except KeyError:
        # Don't have ceiling, so we're continuing 
        pass

    try:
        floor_ratio = overall_info['floor']
        fd_pts_floor = fd_pts * (1 - floor_ratio)
        dk_pts_floor = dk_pts * (1 - floor_ratio)
        bulk['dk_pts_floor'] = dk_pts_floor
        bulk['fd_pts_floor'] = fd_pts_floor        
    except KeyError:
        # Don't have floor, so we're continuing 
        pass


    salary_info = overall_info['schedule']
    try:
        fd_salary = salary_info['salaries'][0]['salary']
        dk_salary = salary_info['salaries'][1]['salary']
    except IndexError:
        logger.info(f'No salaries for {name}')

    
    stat_line_id = stat_line['id']
    version = '0.1-rg'
    actor.create_or_update_projection(stat_line_id, source, bulk, minutes, dk_pts, fd_pts, version)


def gather_load_projections_for_date(date):
    logger.info(f'Gathering and loading RG projections for {date}')
    gather_csv_projections_on_date(date)
    gather_json_projections_on_date(date)
    load_json_projections_on_date(date)
    