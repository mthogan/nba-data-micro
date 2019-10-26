import requests
from lxml import html
import datetime
import os
import csv
from collections import defaultdict
# sometimes not the best because of the overhead, but here it's ok
from copy import deepcopy
import json

from db.finders import find_team_by_name, find_all_teams, find_player_by_exact_name, find_stat_line_by_player_and_date, find_teams_playing_on_date
from db.creators import create_or_update_projection
import utils

base_url = "https://projects.fivethirtyeight.com"
base_extention = '2020-nba-predictions/'
base_directory = "data/fivethirtyeight"

table_headings = ['full_name', 'small_name', 'min_pg', 'min_sg', 'min_sf',
                  'min_pf', 'min_c', 'total_min', 'vs_full_strength', 'rtg_off', 'rtg_def']

source = 'fte'

def gather_projections():
    '''
    Getting the main page and saving it as when it was updated.
    At the bottom of the page, there's a dropdown asking for
    predictions from the past, so we can use that in the future
    if this data goes away.
    Then we find the links of the teams, gather those, and save as well.
    Directory structure is for each team to have its own directory, and then
    save the files based on date. This way we can handle different update
    time per time.
    '''
    page = requests.get(f"{base_url}/{base_extention}")
    tree = html.fromstring(page.content)
    updated_at = tree.xpath('//*[@id="intro"]/div/div[2]/div[1]/p')[0]
    time_info = updated_at.text.split(' ', 1)[1]
    updated_at_time = datetime.datetime.strptime(
        time_info, "%b. %d, %Y, at %I:%M %p")
    time_string = updated_at_time.strftime('%Y-%m-%d')
    directory = f"data/fivethirtyeight/base"
    utils.ensure_directory_exists(directory)
    filename = f'{time_string}.html'
    filepath = f"{directory}/{filename}"
    with open(filepath, 'w') as f:
        f.write(page.text)
    gather_team_pages(tree, time_string, directory)


def gather_team_pages(tree, time_string, directory):
    '''
    We can get team pages from the links in a dropdown of the main
    page that we've already saved.
    '''
    print('links')
    links = tree.xpath('//*[@id="standings-table"]/tbody//a/@href')
    for link in links:
        team_url = f"{base_url}{link}"
        print(team_url)
        page = requests.get(team_url)
        # find the team from the db so we have the abbrv
        tree = html.fromstring(page.content)
        team_name = tree.xpath(
            '//*[@id="team"]/div/div[1]/h1/span[1]/text()')[0]
        print(team_name)
        team = find_team_by_name(team_name)
        directory = f"{base_directory}/{team['abbrv']}"
        utils.ensure_directory_exists(directory)
        filename = f"{time_string}.html"
        filepath = f"{directory}/{filename}"
        with open(filepath, 'w') as f:
            f.write(page.text)


def scrape_projections_for_date(date):
    '''
    There are three tables in the page. Current rotation, Full strength rotation, and full strength playoff rotation.
    For this, we want to include all of them, but in different places in the csv file.
    Name, mgp_current, mgp_full, mgp_full_playoff, opm, dpm
    where mgp_* are json
    '''
    print(f'Scraping 538 projections for {date}')
    for filepath in _loop_all_team_files_for_date(date):
        team_abbrv = filepath.split('/')[2]
        print(f'Scraping {team_abbrv} projs')
        with open(filepath, 'r') as f:
            tree = html.fromstring(f.read())
            scrape_player_information_from_tree(tree, filepath)


csv_headers = ['label', 'name', 'pg_min', 'sg_min', 'sf_min',
               'pf_min', 'c_min', 'tot_min', 'off_rtg', 'def_rtg']

# The following isused to convert the text to values before putting in the jsonb column.
# This doesn't include label or name because those are strings, but also because they're popped from the dict
csv_conversions = [str, str, int, int, int, int, int, int, float, float]
conversion_helper = dict(zip(csv_headers, csv_conversions))


def _loop_all_team_files_for_date(date, extension='html'):
    teams = find_teams_playing_on_date(date)
    for team in teams:
        directory = f"{base_directory}/{team['abbrv']}"
        filepath = f'{directory}/{date}.{extension}'
        yield filepath


def scrape_player_information_from_tree(tree, filepath):
    csv_filepath = filepath.replace('.html', '.csv')
    labels = ['current', 'fs-reg', 'fs-playoff']
    full_player_values = []
    for label in labels:
        player_rows = tree.xpath(
            f'//*[@id="{label}"]/table/tbody/tr[not(contains(@class, "overall"))]')
        for row in player_rows:
            player_values = [label]
            for td in row.xpath('td[not(contains(@class, "bar")) and @class and not(contains(@class, "diff")) and not(contains(@class, "mobile-only"))]'):
                player_values.append(td.text_content())
            full_player_values.append(deepcopy(player_values))
    with open(csv_filepath, 'w') as f:
        writer = csv.writer(f)
        writer.writerow(csv_headers)
        for value_row in full_player_values:
            writer.writerow(value_row)


def load_players_on_date(date):
    '''
    Looping through the csv files to get the player names added
    to the fte_name column.
    '''
    print(f'Loading fte players on {date}')
    for filepath in _loop_all_team_files_for_date(date, extension='csv'):
        with open(filepath, 'r') as f:
            reader = csv.reader(f)
            next(reader) #ditche the headers like usual
            for row in reader:
                name = row[1].replace('*', '')
                utils.load_players_by_name('fte', name)


def load_projections_for_date(date):
    print(f'Scraping 538 projections for {date}')
    for filepath in _loop_all_team_files_for_date(date, extension='csv'):
        print(filepath)
        full_team_info = defaultdict(lambda: defaultdict(list))
        with open(filepath, 'r') as f:
            reader = csv.reader(f)
            next(reader)
            for row in reader:
                zipped_info = dict(zip(csv_headers, row))
                name = zipped_info.pop('name').replace('*', '')
                label = zipped_info.pop('label')
                full_team_info[name][label] = zipped_info

        for name, bulk in full_team_info.items():
            print(name)
            player = find_player_by_exact_name(name)
            if not player:
                print(f'No {name}. Continuing')
                continue
            # this is a main column on projections, so we want this specifically.
            minutes = int(bulk['current']['tot_min'])
            # ok confusing time. This looks through everything and converts them from strings to ints or floats. You can read the
            # comment above defining conversion_helper
            for key, vals in bulk.items():
                for valkey, valval in vals.items():
                    vals[valkey] = conversion_helper[valkey](valval)
            # Now we can know that the bulk dict has the correct info for the player.
            # We need to get the stat_line from player and date. Continue if that doesn't
            # exist, and if it does exist, create or update the associated projection.
            stat_line = find_stat_line_by_player_and_date(player['id'], date)
            if not stat_line:
                print(f'No stat_line for {name} on {date}')
                continue
            # projection time
            stat_line_id = stat_line['id']
            create_or_update_projection(stat_line_id, source, bulk, minutes, None, None)
            
