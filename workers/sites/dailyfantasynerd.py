import requests
import datetime
import os
import csv
import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

from db.db import actor
from workers.runner import Runner

import utils
import helpers

base_url = 'https://dailyfantasynerd.com'
base_directory = "data/dailyfantasynerd"
valid_sites = ['fd', 'dk']
source = 'dfn'




from requests import Session
import json
import random
import string
import datetime



rand_range = 8
rand_string = ''.join(random.choice(string.ascii_letters + string.digits) for x in range(rand_range)) # used for random string according to js file
server_num = 453 # I think this can be random as well, but keeping for now

XHR_URI = f'https://dailyfantasynerd.com/sockjs/{server_num}/{rand_string}/xhr'
XHR_SEND_URI = f'https://dailyfantasynerd.com/sockjs/{server_num}/{rand_string}/xhr_send'


site_abbrv = 'fd'

PROJ_MESSAGE = "{\"msg\":\"method\",\"method\":\"initProjAndDailyPlayers\",\"params\":[{\"si\":\"%s\",\"sp\":\"nba\",\"se\":\"19-20\",\"d\":\"%s\",\"week\":10}],\"id\":\"2\"}"
INITIAL_CONNECT_COMMAND = ["{\"msg\":\"connect\",\"version\":\"1\",\"support\":[\"1\",\"pre2\",\"pre1\"]}"]


def _get_session_and_headers():
    session = Session()
    headers = {}
    headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:71.0) Gecko/20100102 Firefox/71.0'
    headers['Content-Type'] = 'text/plain;charset=UTF-8'
    headers['Origin'] = 'https://dailyfantasynerd.com'
    headers['Referer'] = 'https://dailyfantasynerd.com/optimizer/draftkings/nba'
    headers['Connection'] = 'keep-alive'
    headers['Host'] = 'dailyfantasynerd.com'
    headers['Accept-Encoding'] = 'gzip, deflate, br'
    headers['Content-Length'] = '0'
    return session, headers

def _get_projection_msg(date_str, site_abbrv):
    dt = datetime.datetime.fromisoformat(date_str)
    pds = dt.strftime('%a %b %d %Y')
    return PROJ_MESSAGE % (site_abbrv, pds)

def _get_json_file_for_date_and_site(date, site_abbrv):
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/{season}/json/{site_abbrv}'
    utils.ensure_directory_exists(directory)
    filepath = f'{directory}/{date}.json'
    return filepath
    

def _write_projections_to_file(date, site_abbrv, proj_json):
    filepath = _get_json_file_for_date_and_site(date, site_abbrv)
    logger.info(f'Writing DFN projections for {site_abbrv} on {date} to {filepath}')
    with open(filepath, 'w') as f:
        json.dump(proj_json, f)


def gather_projections_for_date(date):
    logger.info(f'Gathering DFN json projections for {date}')

    session, headers = _get_session_and_headers()

    logger.info(f'Posting initial first connection post with no data.')
    initial_res = session.post(XHR_URI, headers=headers)

    logger.debug(initial_res)
    logger.debug(f'{initial_res.text}\n')

    logger.info(f'Posting initial connect command with data.')
    connect_sent_res = session.post(XHR_SEND_URI, headers=headers, json=INITIAL_CONNECT_COMMAND)
    logger.info(connect_sent_res)
    logger.debug(connect_sent_res.text)

    logger.info(f'Posting to get the connect message')
    connect_res = session.post(XHR_URI, headers=headers)
    logger.info(connect_res)
    logger.debug(connect_res.text)

    for site_abbrv in valid_sites:
        full_proj_message = [_get_projection_msg(date, site_abbrv)]
        logger.info(f'Posting the give projection message for {site_abbrv}')
        fpmr = session.post(XHR_SEND_URI, headers=headers, json=full_proj_message)
        logger.info(fpmr)

        logger.info(f'Attempting to get the projection response.')
        fpr = session.post(XHR_URI, headers=headers)
        logger.info(fpr)
        jres = json.loads(fpr.text[1:])
        proj_json = json.loads(jres[1])
        _write_projections_to_file(date, site_abbrv, proj_json)

    return date #returning for the next call in runner


def load_json_projections_for_date(date):
    logger.info(f'Loading DFN json projections on {date}.')
    for site_abbrv in valid_sites:
        _load_json_projections_for_date_and_site(date, site_abbrv)


def _get_player_information_from_dict(pinfo, date, site_abbrv):
    player_name = pinfo['n']
    team_abbrv = pinfo['t']
    proj_minutes = pinfo['dfnMin']
    proj_points = pinfo['dfn']
    status = pinfo['is'] if 'is' in pinfo else None
    bulk = pinfo
    player = actor.find_player_by_exact_name(player_name)
    team = actor.find_team_by_site_abbrv('dfn', team_abbrv)
    game = actor.find_game_by_date_and_team(date, team['id'])
    if not player or not game:
        import pdb
        pdb.set_trace()
        logging.warning(f'No player found by DFN with name {player_name}. Continuing')
        return
    stat_line = actor.find_stat_line_by_player_and_game(player['id'], game['id'])
    if not stat_line:
        logger.warning(f'No stat_line found by DFN for {player_name} on {date}')
        return
    version = '0.1-dfn'
    
    logger.debug(f'Creating or updating DFN projection for {player_name}')
    if site_abbrv == 'fd':
        fd_points = proj_points
        fdpp36 = None
        actor.create_or_update_fd_projection(stat_line['id'], source, bulk=bulk, minutes=proj_minutes, fd_points=fd_points, fdpp36=fdpp36, version=version, status=status)
    else:
        dk_points = proj_points
        dkpp36 = None
        actor.create_or_update_dk_projection(stat_line['id'], source, bulk=bulk, minutes=proj_minutes, dk_points=dk_points, dkpp36=dkpp36, version=version, status=status)
    

    #actor.create_or_update_projection(stat_line['id'], source, bulk, proj_minutes, dk_points, fd_points, version)

def _load_json_projections_for_date_and_site(date, site_abbrv):
    logger.info(f'Loading DFN json projections on {date} for site {site_abbrv}.')
    filepath = _get_json_file_for_date_and_site(date, site_abbrv)
    if not utils.check_if_filepath_exists(filepath):
        logger.debug(f'DFN filepath {filepath} for date {date} and site {site_abbrv} does not exist. Returning.')
        return
    with open(filepath, 'r') as f:
        proj_data = json.load(f)
        results = proj_data['result']
        dps = results['dailyPlayer']
        players = dps['p']
        for pinfo in players:
            _get_player_information_from_dict(pinfo, date, site_abbrv)



def load_json_projections_for_month(year, month):
    logger.info(f'Loading DFN projections for {month}, {year}')
    for date in helpers.iso_dates_in_month(year, month):
        load_json_projections_for_date(date)


def load_projections_for_month(year, month):
    logger.info(f'Loading DFN projections for {month}, {year}')
    for date in helpers.iso_dates_in_month(year, month):
        load_projections_for_date(date)


def load_projections_for_date(date):
    logger.info(f'Loading DFN projections on {date}.')
    season = helpers.season_from_date(date)
    for site_abbrv in valid_sites:
        filepath = f'{base_directory}/{season}/{site_abbrv}/{date}.csv'
        if not os.path.exists(filepath):
            logger.warning(f'No DFN file at {filepath}. Returning.')
            return
        load_projections_from_file(site_abbrv, date, filepath)

create_or_update_projection_str = "insert into projections(stat_line_id, source, bulk, minutes, dk_points, fd_points, version) values(%s, %s, %s, %s, %s, %s, %s) on conflict (source, stat_line_id, version) do update set bulk = excluded.bulk, minutes = excluded.minutes, dk_points = excluded.dk_points, fd_points = excluded.fd_points;"
def load_projections_from_file(site_abbrv, date, filepath):
    logger.info(f'Loading projections from {filepath}')
    with open(filepath, 'r') as f:
        rows = csv.DictReader(f)
        for row in rows:
            name = row['Player Name']
            logger.debug(f'Player Name: {name}')
            team_abbrv = row['Team']
            player = actor.find_player_by_exact_name(name)
            team = actor.find_team_by_site_abbrv('dfn', team_abbrv)
            game = actor.find_game_by_date_and_team(date, team['id'])
            logger.debug(f"DFN Projection -- Name: {name}; Team: {team['dfn_abbrv']}")
            bulk = {}
            if not player or not game:
                import pdb
                pdb.set_trace()
                logging.warning(f'No player found for DFN with name {name}. Continuing')
                continue
            stat_line = actor.find_stat_line_by_player_and_game(
                player['id'], game['id'])
            if not stat_line:
                logger.warning(f'No stat_line for {name} on {date}')
                continue
            minutes = row['Proj Min']
            version = '0.1-dfn'
            if site_abbrv == 'fd':
                fd_points = row['S FP']
                fdpp36 = None
                actor.create_or_update_fd_projection(stat_line['id'], source, bulk=bulk, minutes=minutes, fd_points=fd_points, fdpp36=fdpp36, version=version)
            else:
                dk_points = row['S FP']
                dkpp36 = None
                actor.create_or_update_dk_projection(stat_line['id'], source, bulk=bulk, minutes=minutes, dk_points=dk_points, dkpp36=dkpp36, version=version)


def generate_runner():
    runner = Runner()
    runner.add('gpfd', gather_projections_for_date)
    runner.add('ljpfd', load_json_projections_for_date, parents=['gpfd'])
    return runner
    