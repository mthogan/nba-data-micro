import requests
import datetime
import os
import json

import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

from collections import defaultdict

from db.db import actor

import utils
import helpers

base_url = 'https://www.fantasycruncher.com'
base_directory = "data/fantasycruncher"

get_contests_endpoint = 'funcs/tournament-analyzer/get-contests.php'

contest_keys = ['id', 'site', 'league', 'slate', 'site_id', 'name', 'period', 'max_entries', 'max_entrants', 'cost', 'prizepool', 'places_paid',
                'total_entrants', 'winning_score', 'mincash_score', 'startdate', 'winning_payout', 'mincash_payout', 'DateTime', 'Title', 'game_cnt', 'winner', 'has_lineups']


def gather_past_results_for_month(year, month):
    for date in helpers.iso_dates_in_month(year, month):
        gather_past_results_on_date(date)


def gather_past_results_on_date(date):
    logger.info(f'Gathering FC past results on {date}.')
    params = {}
    params['periods'] = [date]
    params['leagues'] = ['NBA']
    params['sites'] = ['draftkings', 'draftkings_pickem', 'draftkings_showdown',
                       'fanduel', 'fanduel_single', 'fanduel_super', 'fantasydraft', 'yahoo']
    url = f'{base_url}/{get_contests_endpoint}'
    resp = requests.post(url, json=params)

    if not resp.status_code == 200:
        logger.info(f'Failed gather response for {date}. Returning.')
    filepath = utils.get_json_filepath_from_date(date, base_directory)
    logger.info(f'Saving FD results to {filepath}')
    with open(filepath, 'w') as f:
        f.write(resp.text)
    return filepath


def load_past_results_for_month(year, month):
    for date in helpers.iso_dates_in_month(year, month):
        load_past_results_on_date(date)


def load_past_results_on_date(date):
    logger.info(f'Loading FC past results on {date}.')
    filepath = utils.get_json_filepath_from_date(date, base_directory)
    if not os.path.exists(filepath):
        logger.info(f'No file for {date}. Returning.')
        return
    load_past_results_from_filepath(filepath)

def load_past_results_from_filepath(filepath):
    contest_counts = defaultdict(int)
    with open(filepath, 'r') as f:
        contests = json.loads(f.read())
        for contest in contests:
            split_site = contest['site'].split('_')
            lowcase_name = split_site[0]
            style = split_site[1] if len(split_site) > 1 else 'classic'
            site = actor.find_site_by_lowcase_name(lowcase_name)
            name = contest['name']
            bulk = contest
            date = contest['period']
            num_games = contest['game_cnt']
            min_cash_score = contest['mincash_score']
            min_cash_payout = contest['mincash_payout']
            start_time = datetime.datetime.fromtimestamp(contest['startdate'])
            entry_fee = contest['cost']
            places_paid = contest['places_paid']
            max_entrants = contest['max_entrants']
            total_entrants = contest['total_entrants']
            max_entries = contest['max_entries']
            prize_pool = contest['prizepool']
            winning_score = contest['winning_score']
            slate_num = contest['slate']
            actor.create_or_update_contest(site['id'], name, date, bulk=bulk, num_games=num_games, min_cash_score=min_cash_score, start_time=start_time, entry_fee=entry_fee, places_paid=places_paid,
                                     max_entrants=max_entrants, total_entrants=total_entrants, min_cash_payout=min_cash_payout, prize_pool=prize_pool, winning_score=winning_score, slate_num=slate_num, max_entries=max_entries, style=style)
            contest_counts[site['abbrv']] += 1
    logger.info(contest_counts)

def gather_load_results_for_date(date):
    gather_past_results_on_date(date)
    load_past_results_on_date(date)