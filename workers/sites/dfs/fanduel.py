import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

from workers.sites.dfs.dfs_site import DfsSite
from db.db import actor

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
        

####################### Auto gathering, which gets its own code for now.

import requests
import json
import datetime
import os

import utils
import helpers

ep = 'https://api.fanduel.com/contests/40192-231105760'
ep = 'https://api.fanduel.com/fixture-lists/40192/players'
ep = 'https://graphql.fanduel.com/graphql'
ep = 'https://api.fanduel.com/fixture-lists'
SLATE_EP = 'fixture-lists?status=open'

api_client_id = 'ZWFmNzdmMTI3ZWEwMDNkNGUyNzVhM2VkMDdkNmY1Mjc6'

headers = {}
headers["Authorization"] = f'Basic {api_client_id}'
headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:71.0) Gecko/20100102 Firefox/71.0'
headers['Origin'] = 'https://www.fanduel.com'

base_url = 'https://api.fanduel.com'
base_directory = "data/fanduel"

fixture_list_base_url = f'{base_url}/fixture-lists'

def _ask_fd_api(ep):
    resp = requests.get(ep, headers=headers)
    return resp.json()

def _slate_info_filepath_for_date(date):
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/{season}/slates/{date}'
    utils.ensure_directory_exists(directory)
    return f'{directory}/slate_info.json'

def _slate_player_info_filepath_for_date(slate_id, date):
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/{season}/players/{date}'
    utils.ensure_directory_exists(directory)
    return f'{directory}/{slate_id}.json'

def gather_slates_for_date(date):
    ep = f'{base_url}/{SLATE_EP}'
    resp_json = _ask_fd_api(ep)
    filepath = _slate_info_filepath_for_date(date)
    with open(filepath, 'w') as f:
        json.dump(resp_json, f)

def _slate_info_for_date(date):
    filepath = _slate_info_filepath_for_date(date)
    if not os.path.exists(filepath):
        return {}
    with open(filepath, 'r') as f:
        return json.load(f)

def gather_players_for_slate(slate_id, start_date):
    ep = f'{fixture_list_base_url}/{slate_id}/players'
    player_json = _ask_fd_api(ep)
    filepath = _slate_player_info_filepath_for_date(slate_id, start_date)
    with open(filepath, 'w') as f:
        json.dump(player_json, f)

def gather_slate_info_for_date(date):
    slate_info = _slate_info_for_date(date)
    fixtures_list = slate_info['fixture_lists']
    nba_fixtures = [fixture for fixture in fixtures_list if fixture['sport'] == 'NBA']
    for fixture in nba_fixtures:
        slate_id = fixture['id']

        start_timestamp = fixture['start_date']
        utc_timestamp_str = start_timestamp[:-1] + ' UTC'
        start_date = helpers.date_from_utc_timestamp(utc_timestamp_str)

        logger.info(f'Getting players for slate {slate_id} which is on {start_date}')
        gather_players_for_slate(slate_id, start_date)


def _nba_fixtures_for_date(date):
    slate_info = _slate_info_for_date(date)
    if not slate_info:
        return []
    fixtures_list = slate_info['fixture_lists']
    return [fixture for fixture in fixtures_list if fixture['sport'] == 'NBA']


def _get_main_slate_id_for_date(date):
    """Need the main slate id for a date to get the player information after"""
    nba_fixtures = _nba_fixtures_for_date(date)
    for fixture in nba_fixtures:
        if fixture['label'] == 'Main':
            return fixture['id']
        
def _get_player_info_for_date(date):
    """Currently we need to get the main slate_id,
    and then find that slate_id player info file to get the
    names and salaries."""
    main_slate_id = _get_main_slate_id_for_date(date)
    logger.info(f'Main slate id: {main_slate_id}')
    filepath = _slate_player_info_filepath_for_date(main_slate_id, date)
    logger.info(f'Main slate player filepath: {filepath}')
    with open(filepath, 'r') as f:
        return json.load(f)
    
def _get_team_abbrvs_by_id(team_info):
    """FD does this weird thing where they include the team id instead of the abbrv
    for each player, and then have a different section for the teams. We need
    to use this to map them"""
    retval = {}
    for team in team_info:
        retval[team['id']] = team['code']
    return retval


def load_player_info_for_date(date):
    player_info = _get_player_info_for_date(date)
    # need the teams first
    team_info = player_info['teams']
    team_abbrvs = _get_team_abbrvs_by_id(team_info)
    players = player_info['players']
    for player_ in players:
        first_name = player_['first_name']
        last_name = player_['last_name']
        fullname = f'{first_name} {last_name}'.strip()
        sal = player_['salary']
        try:
            pos = player_['position']
        except:
            import pdb;pdb.set_trace()
            asdf = 5
        # find team
        player_slate_id = player_['id']
        team_id = player_['team']['_members'][0]
        team_abbrv = team_abbrvs[team_id]
        logger.info(f'{fullname}, {team_abbrv}, {pos}, {sal}')
        player = actor.find_player_by_exact_name(fullname)
        team = actor.find_team_by_abbrv(team_abbrv)
        game = actor.find_game_by_date_and_team(date, team['id'])
        if not player or not game:
            import pdb;pdb.set_trace()
            continue
        stat_line = actor.find_stat_line_by_player_and_game(
            player['id'], game['id'])
        if stat_line:
            actor.update_stat_line_position_salary('fd', stat_line['id'], pos, sal, player_slate_id)
        else:
            logger.info(f'No existing stat_line for {player["fd_name"]}. Creating one now.')
            actor.create_stat_line_with_position_salary('fd', player['id'], team['id'], game['id'], pos, sal, player_slate_id)
    asdf = 5


def load_slates_for_date(date):
    logger.info(f'Loading slates for date {date}')
    nba_fixtures = _nba_fixtures_for_date(date)
    for fixture in nba_fixtures:
        site_id = 2 # FanDuel trusting 2
        start_timestamp = fixture['start_date']
        start_time = helpers.datetime_from_utc_timeztamp(start_timestamp)
        start_date = helpers.date_from_utc_timestamp(start_timestamp)
        slate_id = fixture['id']
        label = fixture['label']
        bulk = fixture
        logger.info(f'{site_id}, {start_date}, {slate_id}, {start_time}, {label}')
        actor.create_or_update_slate(site_id=site_id, date=start_date, slate_id=slate_id, start_time=start_time, label=label, bulk=bulk)


def gather_load_slates_for_date(date):
    gather_slates_for_date(date)
    load_slates_for_date(date)
    gather_slate_info_for_date(date)
    load_player_info_for_date(date)



if __name__ == '__main__':
    date = '2019-11-06'
    get_slate_info_for_date(date)