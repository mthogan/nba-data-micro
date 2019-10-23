import json
import re
import datetime
import calendar
import os

import requests
from lxml import html

from db.finders import find_player_by_site_abbrv_name, find_player_by_exact_name, find_player_by_clean_name, \
    find_player_by_unaccented_name, find_player_by_lowercase_name

import utils
import helpers

base_directory = 'data2/swishanalytics'

base_url = 'https://swishanalytics.com/optimus/nba/daily-fantasy-salary-changes'

valid_sites = ['fd', 'dk']


def gather_salary_changes_for_season(season):
    utils.perform_action_for_season(season, gather_salary_changes_by_date)

def gather_salary_changes_for_month(year, month):
    for day in helpers.iso_dates_in_month(year, month):
        gather_salary_changes_by_date(day)


def gather_salary_changes_by_date(date):
    print(f'Getting salary differences from SA for {date}')
    page = requests.get(base_url, params={'date': date})
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/{season}/full'
    utils.ensure_directory_exists(directory)
    filename = f'{date}.html'
    filepath = f'{directory}/{filename}'
    with open(filepath, 'w') as f:
        f.write(page.text)


def _get_full_filepath_by_date(date):
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/{season}/full'
    return f'{directory}/{date}.html'


def _get_site_filepath_by_date(site_abbrv, date):
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/{season}/{site_abbrv}'
    utils.ensure_directory_exists(directory)
    return f'{directory}/{date}.json'


def scrape_salary_changes_for_season(season):
    utils.perform_action_for_season(season, scrape_salary_changes_by_date)


def scrape_salary_changes_for_month(year, month):
    for day in helpers.iso_dates_in_month(year, month):
        scrape_salary_changes_by_date(day)


def scrape_salary_changes_by_date(date):
    '''
    Read full.html and spit into json
    '''
    print(f'Scraping salary differences from SA for {date}')
    full_filepath = _get_full_filepath_by_date(date)
    if not os.path.exists(full_filepath):
        print(f'No full.html for {date}')
        return
    with open(full_filepath, 'r') as f:
        html_text = f.read()
        for site in valid_sites:
            json_re = r'this.players_' + re.escape(site) + ' = (.*?);'
            data_string = re.search(json_re, html_text).group(1)
            data = json.loads(data_string)
            filepath = _get_site_filepath_by_date(site, date)
            print(filepath)
            with open(filepath, 'w') as outfile:
                json.dump(data, outfile)


def swish_analytics_files_on_date(date):
    season = helpers.season_from_date(date)
    for site in valid_sites:
        directory = f'{base_directory}/{season}/{site}'
        filename = f'{date}.json'
        filepath = f'{directory}/{filename}'
        yield filepath


def load_salaries_on_date(date):
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/{season}/full'
    for site in valid_sites:
        filename = f'{date}.json'
        filepath = f'{directory}/{filename}'
        with open(filepath, 'r') as f:
            player_salaries = json.load(f)
            print(player_salaries)
            for player in player_salaries:
                player_name = player['player_name']
                salary = int(player['salary'].replace(',', ''))
                print(f'{player_name}: {salary}')


def load_players_in_month(year, month):
    for day in helpers.iso_dates_in_month(year, month):
        load_players_on_date(day)


def load_players_on_date(date):
    '''
    We're going through the names on the date specified. For the names, SA uses
    the names per site. So if the name is different in FD and DK, it's different here.
    This means no sa_name, and when loading here, we want to add them to fd and dk.
    '''
    for filepath in swish_analytics_files_on_date(date):
        print(filepath)
        site_abbrv = filepath.split('/')[-1].replace('.json', '')
        with open(filepath, 'r') as f:
            player_salaries = json.load(f)
            for player in player_salaries:
                name = player['player_name']
                utils.load_players_by_name(site_abbrv, name)
