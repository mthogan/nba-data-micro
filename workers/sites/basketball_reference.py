import requests
from lxml import html
import os
import csv
import calendar
import datetime

from db.finders import find_team_by_name, find_game_by_date_and_team, find_player_by_br_name, find_stat_line_by_player_and_game, find_team_by_name, find_player_by_br_name
from db.creators import create_game
from helpers import time_stamp_to_minutes

base_url = 'https://www.basketball-reference.com'

stat_keys = ['minutes', 'minutes_numeric', 'fg', 'fga', 'tp', 'tpa', 'ft',
             'fta', 'orb', 'drb', 'trb', 'ast', 'stl', 'blk', 'tov', 'pf', 'pts', 'pm']

stat_csv_keys = ['name', 'team', 'fd_points', 'dk_points', 'minutes', 'minutes_numeric', 'fg', 'fga', 'tp', 'tpa', 'ft',
                 'fta', 'orb', 'drb', 'trb', 'ast', 'stl', 'blk', 'tov', 'pf', 'pts', 'pm']


def directory_from_date(date):
    year, month, _ = date.split('-')
    return f"data2/box_scores/{year}/{month}/{date}"

# GATHERING


def gather_box_scores_by_year(year):
    for i in range(1, 13):
        gather_box_scores_by_month(year, i)


def gather_box_scores_by_month(year, month):
    num_days = calendar.monthrange(year, month)[1]
    days = [datetime.date(year, month, day) for day in range(1, num_days+1)]
    for day in days:
        gather_box_scores_by_date(day.isoformat())


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

    directory = directory_from_date(date)
    if not os.path.exists(directory):
        os.makedirs(directory)
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


# SCRAPING


def create_stat_dict(stat_html):
    name = stat_html.xpath('.//a')[0].text
    trs = stat_html.xpath('./td')
    if len(trs) == 1:
        # did not play
        stat_vals = [0] * 18
    else:
        minutes = trs[0].text
        minutes_numeric = time_stamp_to_minutes(minutes)
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

        #print [fg, fga, tp, tpa, ft, fta, orb, drb, trb, ast, stl, blk, tov, pf, pts, pm]
        stat_vals = [minutes, minutes_numeric] + [int(val) for val in [
            fg, fga, tp, tpa, ft, fta, orb, drb, trb, ast, stl, blk, tov, pf, pts, pm]]
    stat_dict = dict(zip(stat_keys, stat_vals))
    return name, stat_dict

def scrape_box_scores_by_year(year):
    for i in range(1, 13):
        scrape_box_scores_by_month(year, i)

def scrape_box_scores_by_month(year, month):
    num_days = calendar.monthrange(year, month)[1]
    days = [datetime.date(year, month, day) for day in range(1, num_days+1)]
    for day in days:
        scrape_box_scores_by_date(day.isoformat())

def scrape_box_scores_by_date(date):
    directory = directory_from_date(date)
    for _, _, files in os.walk(directory):
        for filename in files:
            if filename.endswith(".html"):
                filepath = directory+'/'+filename
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
    game, away_team, home_team = find_game_from_box_score(date, tree)
    print('Scraping stats on %s for %s at %s' %
          (date, away_team['name'], home_team['name']))
    #tables = tree.xpath('//table[contains(., "Basic Box Score Stats")]')
    full_game_stats = []
    full_game_stats.extend(run_team_stats(home_team, game, tree))
    full_game_stats.extend(run_team_stats(away_team, game, tree))
    directory = directory_from_date(date)
    filepath = directory + \
        '/%sv%s.csv' % (away_team['abbrv'], home_team['abbrv'])
    with open(filepath, 'w') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=stat_csv_keys)
        writer.writeheader()
        for data in full_game_stats:
            writer.writerow(data)
    return


def run_team_stats(team, game, tree):
    team_all_box_basic = "all_box-%s-game-basic" % team['br_abbrv']
    home_team_rows = tree.xpath(
        f"//div[@id=\"{team_all_box_basic}\" and contains(@class, 'table_wrapper')]//tbody/tr[not(@class)]")
    team_stats = []
    for stats in home_team_rows:
        name, stat_dict = create_stat_dict(stats)
        team_stats.append(save_stat_line(name, team, stat_dict))
    return team_stats


def save_stat_line(name, team, stat_dict):
    # find player
    dk_points = calc_dk_points(stat_dict)
    fd_points = calc_fd_points(stat_dict)
    stat_dict['dk_points'] = dk_points
    stat_dict['fd_points'] = fd_points
    stat_dict['name'] = name
    stat_dict['team'] = team['br_abbrv']
    return stat_dict
    # print(stat_dict)
    #player = find_player_by_br_name(name)
    #print("Adding stats for", player['br_name'])
    #stat_line = find_stat_line_by_player_and_game(player['id'], game['id'])
    # print(stat_line)
    # if not stat_line:
    #    print('No stat_line')
    #stat_line.stats = stat_dict
    #stat_line.dk_points = dk_points
    #stat_line.fd_points = fd_points
    # session.add(stat_line)
    # session.commit()


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

def seed_players_by_date(date):
    directory = directory_from_date(date)
    for _, _, files in os.walk(directory):
        for filename in files:
            if filename.endswith(".csv"):
                filepath = directory+'/'+filename
                print(filepath)
                with open(filepath, 'r') as f:
                    reader = csv.reader(f)
                    next(reader, None)
                    seed_players_from_reader(reader)


def seed_players_from_reader(reader):
    for row in reader:
        name = row[0]
        player = find_player_by_br_name(name)
        if player:
            return
        # now we want to determine if we can find it in another name column
        print(name)


def gather_games(year):
    directory = f"data2/games/{year}"
    if not os.path.exists(directory):
        os.makedirs(directory)
    for month_num in range(1, 13):
        month_name = calendar.month_name[month_num].lower()
        print(month_name)
        schedule_url = f"https://www.basketball-reference.com/leagues/NBA_{year}_games-{month_name}.html"
        print(schedule_url)
        page = requests.get(schedule_url)
        filepath = f"{directory}/{f'{month_num:02}'}.html"
        with open(filepath, 'w') as f:
            f.write(page.text)


def seed_games(year):
    directory = f"data2/games/{year}"
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
                season = f"{str(year-1)[2:]}-{str(year)[2:]}"
                print(date)
                away_team_name = game_info[2].xpath('./a')[0].text
                home_team_name = game_info[4].xpath('./a')[0].text
                home_team = find_team_by_name(home_team_name)
                away_team = find_team_by_name(away_team_name)
                game = find_game_by_date_and_team(date, away_team['id'])
                if not game:
                    create_game(date, home_team['id'], away_team['id'], season)
