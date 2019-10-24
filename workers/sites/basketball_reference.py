import os
import csv
import calendar
import datetime

import requests
from lxml import html

from db.finders import find_team_by_name, find_game_by_date_and_team, find_player_by_br_name, \
    find_player_by_exact_name, \
    find_team_by_site_abbrv, find_stat_line_by_player_and_game

from db.creators import create_game, create_player_by_name, create_or_update_stat_line_with_stats
from db.updaters import update_player_name
import helpers
import utils

base_url = 'https://www.basketball-reference.com'

stat_keys = ['minutes', 'minutes_numeric', 'fg', 'fga', 'tp', 'tpa', 'ft',
             'fta', 'orb', 'drb', 'trb', 'ast', 'stl', 'blk', 'tov', 'pf', 'pts', 'pm']

stat_csv_keys = ['name', 'team', 'fd_points', 'dk_points', 'minutes', 'minutes_numeric', 'fg', 'fga', 'tp', 'tpa', 'ft',
                 'fta', 'orb', 'drb', 'trb', 'ast', 'stl', 'blk', 'tov', 'pf', 'pts', 'pm', 'active']


games_base_directory = 'data2/basketball_reference/games'
box_scores_base_directory = 'data2/basketball_reference/box_scores'


def box_scores_directory_from_date(date):
    _, month, _ = date.split('-')
    season = helpers.season_from_date(date)
    directory = f"{box_scores_base_directory}/{season}/{month}/{date}"
    utils.ensure_directory_exists(directory)
    return directory


# GATHERING

def gather_box_scores_for_season(season):
    for date in helpers.dates_in_season(season):
        gather_box_scores_by_date(date)


def gather_box_scores_for_month(year, month):
    for day in helpers.iso_dates_in_month(year, month):
        gather_box_scores_by_date(day)


def gather_box_scores_by_date(date):
    print("Gathering box scores for date %s" % date)
    year, month, day = date.split('-')
    main_url = base_url + \
        '/boxscores/index.cgi?month=%s&day=%s&year=%s' % (month, day, year)
    box_score_urls = get_box_score_urls(main_url)
    for box_score_url in box_score_urls:
        gather_box_score(date, box_score_url)


def get_box_score_urls(main_url):
    page = requests.get(main_url)
    tree = html.fromstring(page.content)
    links = tree.xpath(
        '//div[@class="game_summaries"]//p[@class="links"]/a[1]/@href')
    return links


def gather_box_score(date, box_score_url):
    print(box_score_url)
    directory = box_scores_directory_from_date(date)
    page = requests.get(base_url+box_score_url)

    tree = html.fromstring(page.content)
    teams = tree.xpath('//div[@itemprop="performer"]/strong/a')
    away_team_name = teams[0].text
    away_team = find_team_by_name(away_team_name)
    home_team_name = teams[1].text
    home_team = find_team_by_name(home_team_name)

    print(f"{away_team['br_abbrv']} vs {home_team['br_abbrv']}")

    # now save the page in the filepath
    filepath = directory + \
        '/%sv%s.html' % (away_team['abbrv'], home_team['abbrv'])
    with open(filepath, 'w') as f:
        f.write(page.text)
    return


def create_stat_dict(stat_html, active=True):
    try:
        name = stat_html.xpath('.//a')[0].text
        trs = stat_html.xpath('./td')
    except:
        pass
    if not active or len(trs) == 1:
        # did not play
        stat_vals = [0] * 18
    else:
        minutes = trs[0].text
        minutes_numeric = helpers.timestamp_to_minutes(minutes)
        fg = trs[1].text
        fga = trs[2].text
        tp = trs[4].text
        tpa = trs[5].text
        ft = trs[7].text
        fta = trs[8].text
        orb = trs[10].text
        drb = trs[11].text
        trb = trs[12].text
        ast = trs[13].text
        stl = trs[14].text
        blk = trs[15].text
        tov = trs[16].text
        pf = trs[17].text
        pts = trs[18].text
        pm = '0' if trs[19].text == None else trs[19].text

        stat_vals = [minutes, minutes_numeric] + [int(val) for val in [
            fg, fga, tp, tpa, ft, fta, orb, drb, trb, ast, stl, blk, tov, pf, pts, pm]]
    stat_dict = dict(zip(stat_keys, stat_vals))
    return name, stat_dict


def scrape_box_scores_for_season(season):
    for date in helpers.dates_in_season(season):
        scrape_box_scores_by_date(date)


def scrape_box_scores_for_month(year, month):
    for day in helpers.iso_dates_in_month(year, month):
        scrape_box_scores_by_date(day)


def scrape_box_scores_by_date(date):
    directory = box_scores_directory_from_date(date)
    for _, _, files in os.walk(directory):
        for filename in files:
            if filename.endswith(".html"):
                filepath = f'{directory}/{filename}'
                with open(filepath, 'r') as f:
                    html_text = f.read()
                    scrape_box_score(date, html_text)


def find_game_from_box_score(date, box_score_html):
    teams = box_score_html.xpath('//div[@itemprop="performer"]/strong/a')
    away_team_name = teams[0].text
    home_team_name = teams[1].text
    away_team = find_team_by_name(away_team_name)
    home_team = find_team_by_name(home_team_name)
    game = find_game_by_date_and_team(date, away_team['id'])
    return game, away_team, home_team


def scrape_box_score(date, html_text):
    tree = html.fromstring(html_text)
    _, away_team, home_team = find_game_from_box_score(date, tree)
    print('Scraping stats on %s for %s at %s' %
          (date, away_team['name'], home_team['name']))
    #tables = tree.xpath('//table[contains(., "Basic Box Score Stats")]')
    full_game_stats = []
    full_game_stats.extend(run_team_stats(home_team, tree))
    full_game_stats.extend(run_team_stats(away_team, tree))
    directory = box_scores_directory_from_date(date)
    filepath = directory + \
        '/%sv%s.csv' % (away_team['abbrv'], home_team['abbrv'])
    with open(filepath, 'w') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=stat_csv_keys)
        writer.writeheader()
        for data in full_game_stats:
            writer.writerow(data)
    return


def run_team_stats(team, tree):
    team_all_box_basic = "all_box-%s-game-basic" % team['br_abbrv']
    team_rows = tree.xpath(
        f"//div[@id=\"{team_all_box_basic}\" and contains(@class, 'table_wrapper')]//tbody/tr[not(@class)]")
    team_stats = []
    for stats in team_rows:
        name, stat_dict = create_stat_dict(stats)
        team_stats.append(save_stat_line(name, team, stat_dict))
    # now gotta find the inactive players for home and away
    inactives = tree.xpath(
        f"//*[@id='content']//strong[.=\"{team['br_abbrv']}\"]/..")[0]
    # we need to loop the siblings, and when either we hit another span, or we run out of siblings, then we stop
    for inactive in inactives.itersiblings():
        if inactive.tag == 'span':
            break  # this cuts it off from home and away players
        name = inactive.text
        # zipping info together like create_stat_dict does
        stat_dict = stat_dict = dict(zip(stat_keys, [0] * 18))
        team_stats.append(save_stat_line(name, team, stat_dict, active=False))
    return team_stats


def save_stat_line(name, team, stat_dict, active=True):
    # find player
    dk_points = calc_dk_points(stat_dict)
    fd_points = calc_fd_points(stat_dict)
    stat_dict['dk_points'] = dk_points
    stat_dict['fd_points'] = fd_points
    stat_dict['name'] = name
    stat_dict['team'] = team['br_abbrv']
    # only getting called here if has actual numbers.
    stat_dict['active'] = active
    return stat_dict


def calc_dk_points(sd):
    fpts = sd['pts'] + sd['tp'] * 0.5 + sd['trb'] * 1.25 + \
        sd['ast'] * 1.5 + sd['stl'] * 2 + sd['blk'] * 2 + sd['tov'] * -0.5
    doubles = [sd['pts'], sd['trb'], sd['ast'],
               sd['blk'], sd['stl']]  # , sd['tov'], sd['pts']]
    amounts = sum([1 if s >= 10 else 0 for s in doubles])
    if amounts >= 2:
        fpts += 1.5
    if amounts >= 3:
        fpts += 3
    return fpts


def calc_fd_points(sd):
    fpts = sd['pts'] + sd['trb'] * 1.2 + + sd['ast'] * 1.5 + + \
        sd['blk'] * 3 + sd['stl'] * 3 + sd['tov'] * -1.0
    return fpts


# Stat Lines

def loop_stat_lines_on_date(date):
    directory = box_scores_directory_from_date(date)
    for _, _, files in os.walk(directory):
        for filename in files:
            if filename.endswith(".csv"):
                filepath = directory+'/'+filename
                with open(filepath, 'r') as f:
                    reader = csv.reader(f)
                    next(reader, None)
                    for row in reader:
                        yield row
                    #load_players_from_reader(reader, force=force)


def load_stat_lines_for_season(season):
    for date in helpers.dates_in_season(season):
        load_stat_lines_on_date(date)


def load_stat_lines_for_month(year, month):
    for day in helpers.iso_dates_in_month(year, month):
        load_stat_lines_on_date(day)


def load_stat_lines_on_date(date):
    print(f'Loading stat_lines on {date}')
    for stat_line in loop_stat_lines_on_date(date):
        stat_dict = dict(zip(stat_csv_keys, stat_line))
        player_name = stat_dict.pop('name')
        player = find_player_by_br_name(player_name)
        team_abbrv = stat_dict.pop('team')
        team = find_team_by_site_abbrv('br', team_abbrv)
        minutes = stat_dict.pop('minutes_numeric')
        active = True if stat_dict.pop('active') == 'True' else False
        game = find_game_by_date_and_team(date, team['id'])
        if not player or not game:
            import pdb
            pdb.set_trace()
        stat_line = find_stat_line_by_player_and_game(player['id'], game['id'])
        dk_points = stat_dict.pop('dk_points')
        fd_points = stat_dict.pop('fd_points')
        create_or_update_stat_line_with_stats(
            player['id'], team['id'], game['id'], dk_points, fd_points, stat_dict, minutes, active=active)


# PLAYERS

def load_players_for_season(season, force=False):
    for date in helpers.dates_in_season(season):
        load_players_on_date(date, force=force)


def load_players_on_date(date, force=False):
    print(f'Seeing players by date {date}')
    for stat_line in loop_stat_lines_on_date(date):
        name = stat_line[0]
        utils.load_players_by_name('br', name, force=force)

# GAMES


def gather_games_for_season(season):
    '''
    Gathering games by seasons. '18-19', '19-20'. We're doing this because the year
    in the br url has to do with the year when the finals are played. We want the
    directories to be clear about that
    '''
    _, end_year = season.split('-')
    year = int(f'20{end_year}')
    directory = f"{games_base_directory}/{season}"
    utils.ensure_directory_exists(directory)
    for month_num in range(1, 13):
        month_name = calendar.month_name[month_num].lower()
        print(month_name)
        schedule_url = f"https://www.basketball-reference.com/leagues/NBA_{year}_games-{month_name}.html"
        print(schedule_url)
        page = requests.get(schedule_url)
        filepath = f"{directory}/{f'{month_num:02}'}.html"
        with open(filepath, 'w') as f:
            f.write(page.text)


def load_games_for_season(season):
    _, end_year = season.split('-')
    year = int(f'20{end_year}')
    directory = f"{games_base_directory}/{season}"
    for month_num in range(1, 13):
        filepath = f"{directory}/{f'{month_num:02}'}.html"
        with open(filepath, 'r') as f:
            page = f.read()
            tree = html.fromstring(page)
            game_infos = tree.xpath(
                '//table[@id="schedule"]//tbody//tr[not(contains(@class, "thead"))]')
            date_format = '%a, %b %d, %Y'
            for game_info in game_infos:
                date_string = game_info[0].xpath('./a')[0].text
                date = datetime.datetime.strptime(date_string, date_format)
                print(date)
                away_team_name = game_info[2].xpath('./a')[0].text
                home_team_name = game_info[4].xpath('./a')[0].text
                home_team = find_team_by_name(home_team_name)
                away_team = find_team_by_name(away_team_name)
                game = find_game_by_date_and_team(date, away_team['id'])
                if not game:
                    create_game(date, home_team['id'], away_team['id'], season)
