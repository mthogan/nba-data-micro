import os
import calendar
import datetime
import csv

import helpers

from db.db import actor


def ensure_directory_exists(directory):
    '''
    Called to ensure we can write to files in the dir structure we want
    '''
    if not os.path.exists(directory):
        os.makedirs(directory)


# Loading players


def perform_action_for_season(season, by_date_function, *args, **kwargs):
    for date in helpers.dates_in_season(season):
        by_date_function(date, *args, **kwargs)


def _add_player_to_column(site_name_column, player_id, name):
    print(f'Adding {name}')
    player = actor.update_player_name(site_name_column, player_id, name)
    return True


name_finding_functions = [actor.find_player_by_exact_name, actor.find_player_by_clean_name, actor.find_player_by_unaccented_name, actor.find_player_by_lowercase_name]


def load_players_by_name(site_abbrv, name, force=False):
    '''
    Loading player by name
    '''
    site_name_column = f'{site_abbrv}_name'
    # look for player with {site_abbrv}_name first, since if that matches
    # we're done.
    player = actor.find_player_by_site_abbrv_name(site_abbrv, name)
    if player:
        return player
    for nff in name_finding_functions:
        player = nff(name)
        if player:
            return _add_player_to_column(site_name_column, player['id'], name)
    print(f'No name match {name}')
    if force:
        print(f'Force creating player in {site_name_column}: {name}')
        actor.create_player_by_name(site_name_column, name)
    return None


def load_players_from_file(filepath, site_abbrv, name_in_row_fn, force=False):
    print(f'Loading players from file {filepath}')
    with open(filepath, 'r') as f:
        reader = csv.reader(f)
        next(reader, None)
        for row in reader:
            name = name_in_row_fn(row)
            player = load_players_by_name(site_abbrv, name, force=force)
            if not player:
                print(f'no player named {name}')




def get_json_filepath_from_date(date, base_directory):
    '''
    To make it easier to know where the data is going.
    data_type refers to whether it's the csv data or json
    since rg has both.
    '''
    season = helpers.season_from_date(date)
    directory = f'{base_directory}/json/{season}'
    ensure_directory_exists(directory)
    return f"{directory}/{date}.json"
