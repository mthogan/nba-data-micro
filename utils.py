import os
import calendar
import datetime

from db.finders import find_player_by_site_abbrv_name, find_player_by_exact_name, \
    find_player_by_clean_name, find_player_by_unaccented_name, \
    find_player_by_lowercase_name

from db.creators import create_player_by_name
from db.updaters import update_player_name


def ensure_directory_exists(directory):
    '''
    Called to ensure we can write to files in the dir structure we want
    '''
    if not os.path.exists(directory):
        os.makedirs(directory)


def iso_dates_in_month(year, month):
    '''
    Yields date in isoformat in a specific year and month
    '''
    num_days = calendar.monthrange(year, month)[1]
    days = [datetime.date(year, month, day) for day in range(1, num_days+1)]
    for day in days:
        yield day.isoformat()


def dates_in_season(season):
    '''
    Season is of format '18-19', or '19-20'.
    '''
    start_year, end_year = season.split('-')
    full_start_year = int('20' + start_year)
    full_end_year = int('20' + end_year)
    for month in range(10, 13):
        for day in iso_dates_in_month(full_start_year, month):
            yield day
    for month in range(1, 7):
        for day in iso_dates_in_month(full_end_year, month):
            yield day

# Loading players

def perform_action_for_season(season, by_date_function, *args, **kwargs):
    for date in dates_in_season(season):
        by_date_function(date, *args, **kwargs)


def load_players_by_name(site_abbrv, name, force=False):
    '''
    Loading player by name
    '''
    site_name_column = f'{site_abbrv}_name'
    # look for player with sa_name
    player = find_player_by_site_abbrv_name(site_abbrv, name)
    if player:
        return
    # next look for exact match
    player = find_player_by_exact_name(name)
    if player:
        # set this as br_name then continue
        update_player_name(site_name_column, player['id'], name)
        return
    # continuing, we want to clean the data
    player = find_player_by_clean_name(name)
    if player:
        update_player_name(site_name_column, player['id'], name)
        return
    player = find_player_by_unaccented_name(name)
    if player:
        update_player_name(site_name_column, player['id'], name)
        return
    player = find_player_by_lowercase_name(name)
    if player:
        update_player_name(site_name_column, player['id'], name)
        return
    print(f'No name match {name}')
    if force:
        print(f'Force creating player in {site_name_column}: {name}')
        create_player_by_name(site_name_column, name)
    return
