import os
import calendar
import datetime
import csv
import logging

logger = logging.getLogger()

import helpers

from db.db import actor



def ensure_directory_exists(directory):
    '''
    Called to ensure we can write to files in the dir structure we want
    '''
    if not os.path.exists(directory):
        os.makedirs(directory)

def check_if_filepath_exists(filepath):
    return os.path.exists(filepath)

# Loading players


def perform_action_for_season(season, by_date_function, *args, **kwargs):
    for date in helpers.dates_in_season(season):
        by_date_function(date, *args, **kwargs)


def _add_player_to_column(site_name_column, player_id, name):
    logger.warning(f'Adding {name} to {site_name_column}')
    actor.update_player_name(site_name_column, player_id, name)
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
    logging.warning(f'Couldn\'t find player for {site_name_column} with name {name}. Checking other columns')
    for nff in name_finding_functions:
        player = nff(name)
        if player:
            return _add_player_to_column(site_name_column, player['id'], name)
    logger.error(f'No name match {name} in any of the columns')
    if force:
        logger.warning(f'Force adding player in {site_name_column}')
        actor.create_player_by_name(site_name_column, name)
    else:
        logger.warning(f'Not force updating, need to do by hand.')
    return None


def load_players_from_file(filepath, site_abbrv, name_in_row_fn, force=False):
    logger.info(f'Loading players from file {filepath}')
    with open(filepath, 'r') as f:
        reader = csv.reader(f)
        next(reader, None)
        for row in reader:
            name = name_in_row_fn(row)
            player = load_players_by_name(site_abbrv, name, force=force)
            if not player:
                logger.warning(f'No player named {name}')




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
