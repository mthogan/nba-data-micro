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


##########################################
##
## Auto get players
##
##########################################



import requests
import re
import datetime
import json
import os

import utils
import helpers

from db.db import actor

headers = {}
#eaders["Authorization"] = f'Basic {api_client_id}'
headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:71.0) Gecko/20100102 Firefox/71.0'
headers['Origin'] = 'https://www.draftkings.com'

base_api_url = 'https://api.draftkings.com'
base_url = 'https://www.draftkings.com'
base_directory = "data/draftkings"

contest_info_endpoint = 'lineup/getupcomingcontestinfo'
draftgroups_endpoint = 'draftgroups/v1/draftgroups/%s/draftables?format=json'

"https://www.draftkings.com/lineup/getupcomingcontestinfo"

def _contest_info_filepath_for_date(date):
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/{season}/contests/{date}'
    utils.ensure_directory_exists(directory)
    return f'{directory}/contest_info.json'

def _contest_draftgroup_filepath_for_date(date, dgid):
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/{season}/contests/{date}'
    utils.ensure_directory_exists(directory)
    return f'{directory}/{dgid}.json'

def _contest_info_for_date(date):
    filepath = _contest_info_filepath_for_date(date)
    if not os.path.exists(filepath):
        return {}
    with open(filepath, 'r') as f:
        return json.load(f)

def _nba_contest_info_for_date(date):
    full_contest_info = _contest_info_for_date(date)
    for ci in full_contest_info:
        sport = ci['Sport']
        if sport == 'NBA':
            yield ci


def gather_contest_info_date_by_date(date):
    info_url = f'{base_url}/{contest_info_endpoint}'
    resp = requests.post(info_url, headers=headers)
    resp_json = resp.json()
    filepath = _contest_info_filepath_for_date(date)
    with open(filepath, 'w') as f:
        json.dump(resp_json, f)

def _get_draftgroup(date, dgid):
    asdf = draftgroups_endpoint % dgid
    url = f'{base_api_url}/{asdf}'
    resp = requests.get(url)
    resp_json = resp.json()
    filepath = _contest_draftgroup_filepath_for_date(date, dgid)
    print(filepath)
    with open(filepath, 'w') as f:
        json.dump(resp_json, f)

def _start_date_from_start_date_string(sds):
    start_timestamp = int(re.search(r'\d+', sds).group()[:-3]) # includes microseconds, so chopping off the remaining 0s
    start_datetime = datetime.datetime.fromtimestamp(start_timestamp)
    start_date = start_datetime.date()
    return start_date, start_datetime

def gather_players_for_contest(date):
    for vals in _nba_contest_info_for_date(date):
        game_style_name = vals['GameType']['GameStyle']['Name']
        if game_style_name == 'Classic':
            print(vals)
            start_date_string = vals['StartDateEdt']
            start_date, _ = _start_date_from_start_date_string(start_date_string)
            print(start_date)
            print(vals['ContestStartTimeSuffix'])
            dgid = vals['DraftGroupId']
            print(dgid)
            #possibly should save the contests....
            _get_draftgroup(date, dgid)

#create_or_update_slate(self, site_id=None, date=None, slate_id=None, start_time=None, label=None, bulk=None)
def load_slates_for_date(date):
    for fixture in _nba_contest_info_for_date(date):
        print(fixture)
        site_id = 1 # DraftKings trusting 2
        start_date_string = fixture['StartDateEdt']
        start_date, start_time = _start_date_from_start_date_string(start_date_string)
        slate_id = fixture['DraftGroupId']
        label = fixture['GameType']['GameStyle']['Name']
        bulk = fixture
        print(site_id, start_date, slate_id, start_time, label)
        actor.create_or_update_slate(site_id=site_id, date=start_date, slate_id=slate_id, start_time=start_time, label=label, bulk=bulk)


def get_draftgroups_by_id(id):
    pass

def gather_load_contests_for_date(date):
    gather_contest_info_date_by_date(date)
    load_slates_for_date(date)
    gather_players_for_contest(date)


