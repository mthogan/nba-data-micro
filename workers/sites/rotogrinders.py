import requests
from lxml import html
import os
import csv
import json
import re

from db.finders import  session_add, session_commit, find_site, find_stat_line_for_player_on_date, find_player_by_name, find_projection_for_player_on_date

import requests
import csv

### GATHER

def gather_projections(site_name, site_abbrv, date):
    print(f'Getting projections for {date} from {site_name}')
    base_url = "https://rotogrinders.com/projected-stats/nba-player.csv?site={}&date={}"
    res = requests.get(base_url.format(site_name, date))
    reader = csv.reader(res.text.splitlines())
    filename = 'data/projections/roto/{}/{}.csv'.format(site_abbrv, date)
    with open(filename, 'w') as f:
        writer = csv.writer(f)
        for row in reader:
            writer.writerow(row)


def add_past_salaries(site_abbrv, date):
  '''
  TODO NOTE need to add the ability to do this for any site
  '''
  filename = 'data/projections/roto/fd/%s.csv' % date
  print(filename)
  with open(filename, 'r') as f:
    reader = csv.reader(f)
    for row in reader:
      name = row[0].strip()
      salary = int(row[1])
      player = find_player_by_name(name)
      if not player:
        print(f'not found {name}')
      #print 'player:', player.dk_name, player.dk_name, player.br_name
      if player:
        stat_line = find_stat_line_for_player_on_date(player, date)
        if stat_line:
          stat_line.fd_salary = salary
          session_add(stat_line)
    session_commit()

def add_projections(site_abbrv, date):
  site = find_site(site_abbrv)
  filename = 'data/projections/roto/{}/{}.csv'.format(site_abbrv, date)
  print(filename)
  with open(filename, 'r') as f:
    reader = csv.reader(f)
    for row in reader:
      name = row[0].strip()
      salary = int(row[1])
      ceil = float(row[5])
      floor = float(row[6])
      guess = float(row[7])
      player = find_player_by_name(name)
      if not player:
        print(f'not found {name}')
        continue
      stat_line = find_stat_line_for_player_on_date(player, date)
      #print player, stat_line
      if not stat_line:
        print(f'stat_line not found for {name}')
      else:
        if getattr(stat_line, '%s_salary' % site_abbrv) is None:
          print(f'Setting salary for site {site_abbrv} and player {name}')
          setattr(stat_line, '%s_salary' % site_abbrv, salary)
      projection = find_projection_for_player_on_date(player, date)
      if not projection:
        print(f'projection not found for {name}')
        projection = Projection(stat_line=stat_line, player=player)
      projection.rg_minutes = minutes
      setattr(projection, 'rg_%s_guess' % site_abbrv, guess)
      setattr(projection, 'rg_%s_ceil' % site_abbrv, ceil)
      setattr(projection, 'rg_%s_floor' % site_abbrv, floor)
      session_add(projection)
    session_commit()

def gather_projections_json(site_name, site_abbrv, date):
  print(f'Getting projections for {date} from {site_name}')
  base_url = "https://rotogrinders.com/projected-stats/nba-player?site={}&date={}"
  res = requests.get(base_url.format(site_name, date))
  filename = 'data/projections/roto/{}/{}.json'.format(site_abbrv, date)
  asdf = r'data = (.*?);'
  data_string = re.search(asdf, res.text).group(1)
  data = json.loads(data_string)
  with open(filename, 'w') as outfile:
    json.dump(data, outfile)

def add_projections_json(site_abbrv, date):
  site = find_site(site_abbrv)
  filename = 'data/projections/roto/%s/%s.json' % (site_abbrv, date)
  print(filename)
  with open(filename, 'r') as f:
    data = json.load(f)
    for player_info in data:
      minutes = float(player_info['pmin'])
      name = player_info['player_name'].strip()
      floor = player_info['floor']
      ceil = player_info['ceil']
      guess = player_info['points']
      player = find_player_by_name(name)
      positions = player_info['position']
      if not player:
        print(name)
        continue
      stat_line = find_stat_line_for_player_on_date(player, date)
      if not stat_line:
        print(f"No stat line for {name}")
        continue
      setattr(stat_line, '%s_positions' % site_abbrv, positions)
      session_add(stat_line)
      projection = find_projection_for_player_on_date(player, date)
      if not projection:
        print(f'projection not found for {name}')
        projection = Projection(stat_line=stat_line, player=player)
      projection.rg_minutes = minutes
      setattr(projection, 'rg_%s_guess' % site_abbrv, guess)
      setattr(projection, 'rg_%s_ceil' % site_abbrv, ceil)
      setattr(projection, 'rg_%s_floor' % site_abbrv, floor)
      session_add(projection)
      session_commit()