import requests
import json
import re
import datetime
import calendar
import os

from lxml import html

import utils
import helpers

base_directory = 'data2/salaries/swishanalytics'

base_url = 'https://swishanalytics.com/optimus/nba/daily-fantasy-salary-changes'

valid_sites = ['fd', 'dk']

def gather_salary_changes_by_season(season):
    for date in utils.dates_in_season(season):
        gather_salary_changes_by_date(date)


def gather_salary_changes_by_month(year, month):
    for day in utils.iso_dates_in_month(year, month):
        gather_salary_changes_by_date(day)


def gather_salary_changes_by_date(date):
    print(f'Getting salary differences from SA for {date}')
    page = requests.get(base_url, params={'date': date})
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/{season}/{date}'
    utils.ensure_directory_exists(directory)
    filename = 'full.html'
    filepath = f'{directory}/{filename}'
    with open(filepath, 'w') as f:
        f.write(page.text)


def scrape_salary_changes_by_month(year, month):
    for day in utils.iso_dates_in_month(year, month):
        scrape_salary_changes_by_date(day)


def scrape_salary_changes_by_date(date):
    '''
    Read full.html and spit into json
    '''
    print(f'Scraping salary differences from SA for {date}')
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/{season}/{date}'
    full_filename = 'full.html'
    full_filepath = f'{directory}/{full_filename}'
    if not os.path.exists(full_filepath):
        print(f'No full.html for {date}')
        return
    with open(full_filepath, 'r') as f:
        html_text = f.read()
        for site in valid_sites:
            json_re = r'this.players_' + re.escape(site) + ' = (.*?);'
            data_string = re.search(json_re, html_text).group(1)
            data = json.loads(data_string)
            filename = f'{site}.json'
            filepath = f'{directory}/{filename}'
            print(filename)
            with open(filepath, 'w') as outfile:
                json.dump(data, outfile)


def load_salaries_on_date(date):
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/{season}/{date}'
    for site in valid_sites:
            filename = f'{site}.json'
            filepath = f'{directory}/{filename}'
            with open(filepath, 'r') as f:
                player_salaries = json.load(f)
                print(player_salaries)
                for player in player_salaries:
                    player_name = player['player_name']
                    salary = int(player['salary'].replace(',',''))
                    print(f'{player_name}: {salary}')
