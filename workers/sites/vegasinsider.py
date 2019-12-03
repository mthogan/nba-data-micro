
import datetime
import os

import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

import requests
from lxml import html


from db.db import actor
from workers.runner import Runner

import utils
import helpers

base_directory = 'data/vegasinsider'

base_url = 'https://www.vegasinsider.com'

odds_url = f'{base_url}/nba/scoreboard/scores.cfm/game_date/%s'


def gather_odds_by_season(season):
    utils.perform_action_for_season(season, gather_odds_by_date)

def gather_odds_by_month(year, month):
    for day in helpers.iso_dates_in_month(year, month):
        gather_odds_by_date(day)

def gather_odds_by_date(date):
    logger.info(f'Gathering odds for {date}')
    url = odds_url % date
    page = requests.get(url)
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/{season}'
    utils.ensure_directory_exists(directory)
    filename = f'{date}.html'
    filepath = f'{directory}/{filename}'
    with open(filepath, 'w') as f:
        f.write(page.text)
    return date


remove_none_vals = lambda x: x != None
remove_empty_vals = lambda x: x != b''
def _get_odds_info_from_cell(cell):
    spbl2 = cell.xpath('.//td[@class="sportPicksBorderL2"]')
    spbl2_texts = [v.text for v in spbl2]
    vals2 = list(filter(remove_none_vals, spbl2_texts))
    vals2 = [val.encode('ascii', 'ignore').strip() for val in vals2]
    vals2 = list(filter(remove_empty_vals, vals2))

    spbl = cell.xpath('.//td[@class="sportPicksBorderL"]')
    spbl_texts = [v.text for v in spbl]
    vals = list(filter(remove_none_vals, spbl_texts))
    vals = [val.encode('ascii', 'ignore').strip() for val in vals]
    vals = list(filter(remove_empty_vals, vals))

    if len(vals) < 2 or len(vals2) < 2:
        return None, None

    odds_or_ou1 = vals[1].strip()
    odds_or_ou2 = float(vals2[1].strip())

    if odds_or_ou1 == b'PK':
        odds = 0
        over_under = float(odds_or_ou2)
    elif odds_or_ou2 < 100:
        over_under = float(odds_or_ou1)
        odds = odds_or_ou2 * -1
    else:
        over_under = odds_or_ou2
        odds = float(odds_or_ou1)
    logger.debug(f'Odds: {odds}, Over/Under: {over_under}')

    return odds, over_under

def _get_game_from_date_and_cell(date, cell):
    home_team_abbrv = cell.xpath('.//a[@class="black"]')[3].text
    home_team = actor.find_team_by_site_abbrv('vi', home_team_abbrv)
    game = actor.find_game_by_date_and_team(date, home_team['id'])
    return game


def load_odds_by_season(season):
    utils.perform_action_for_season(season, load_odds_by_date)

def load_odds_by_month(year, month):
    for day in helpers.iso_dates_in_month(year, month):
        load_odds_by_date(day)

def load_odds_by_date(date):
    logger.info(f'Loading odds on {date}.')
    season = helpers.season_from_date(date)
    filepath = f'{base_directory}/{season}/{date}.html'
    if not os.path.exists(filepath):
        logger.warning(f'No VI file at {filepath}. Returning.')
        return
    load_odds_from_file(date, filepath)

def load_odds_from_file(date, filepath):
    logger.info(f'Loading odds from {filepath}')
    games = actor.find_games_by_date(date)
    if not games:
        logger.info(f'No regular season games for {date}. Returning.')
        return
    with open(filepath, 'r') as f:
        html_text = f.read()
        tree = html.fromstring(html_text)
        score_cells = tree.xpath('//*[@class="scoreBoardPanelCell" or @class="sportPicksBorder"]')
        for cell in score_cells:
            odds, over_under = _get_odds_info_from_cell(cell)
            if not odds or not over_under:
                logger.info(f'No odds found on {date}. Continuing')
            game = _get_game_from_date_and_cell(date, cell)
            if not game:
                logger.info(f'No game found on {date}. Continuing')
                continue
            logger.info(f'{game["id"]}, {odds}, {over_under}')
            actor.update_game_with_odds(game['id'], odds, over_under)
        pass


def generate_runner():
    runner = Runner()
    runner.add('gobd', gather_odds_by_date)
    runner.add('lobd', load_odds_by_date, parents=['gobd'])
    return runner
    