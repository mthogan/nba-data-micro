import requests
import datetime
import os
import csv
import json

from db.finders import find_team_by_name, find_all_teams, find_player_by_exact_name, find_stat_line_by_player_and_date, find_teams_playing_on_date
from db.creators import create_or_update_projection
import utils


base_url = 'https://stats.nba.com'
lineups_endpoint = 'stats/leaguedashlineups'


base_directory = "data/nba"

asdf = {
    'DateFrom': 'date_to'

}


'https://stats.nba.com/stats/leaguedashlineups?Conference=&DateFrom=&DateTo=&Division=&GameID=&GameSegment=&GroupQuantity=2&LastNGames=2&LeagueID=00&Location=&MeasureType=Advanced&Month=0&OpponentTeamID=0&Outcome=&PORound=0&PaceAdjust=N&PerMode=PerGame&Period=0&PlusMinus=N&Rank=N&Season=2019-20&SeasonSegment=&SeasonType=Regular+Season&ShotClockRange=&TeamID=0&VsConference=&VsDivision='

def gather_advanced_lineups(season, **kwargs)# date_from=None, date_to=None):
    url = f'{base_url}/{lineups_endpoint}'
    for key, value in kwargs:
        print(key, value)
    '''
    params = {}
    params['DateFrom'] = date_from
    params['DateTo'] = date_to
    '''


teams_url = 'https://data.nba.net/prod/v2/2019/teams.json'

games_url = 'https://data.nba.net/prod/v2/%s/scoreboard.json'

box_score_url = 'https://data.nba.net/prod/v1/20181028/0021800083_boxscore.json' # first parram is date without '-', second number is game_id

date = '2019-10-29'

print(base_url_games % date.replace('-', ''))

# Gather: Download the game json info

# Find the teams, date, and then game. Load the nba_game_id to games table.

# to gether boxscores, get the date and game id and format that for the box score url

# then parse out the data and get it to format that br has to be able to add that.