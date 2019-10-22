from db.db import conn, cursor
from psycopg2.extensions import AsIs

select_game_count_str_str = "select count(*) from games"
select_game_by_date_and_team_str = "select * from games where date=%s and (home_team_id=%s or away_team_id=%s)"

select_all_teams = "select * from teams"
select_team_by_name_str = "select * from teams where name=%s"
select_team_by_abbrv_str = "select * from teams where abbrv=%s"
select_team_by_site_abbrv_column_str = "select * from teams where %s_abbrv=%%s"

select_player_by_rg_name_str = "select * from players where rg_name=%s"
select_player_by_br_name_str = "select * from players where br_name=%s"
select_player_by_site_abbrv_name_str = "select * from players where %s_name=%s"
select_all_player_rg_names_str = "select rg_name from players"
select_exact_player_names_str = "select * from compare_exact_name_columns(%s);"
select_player_names_like_str = "select id, dk_name, fd_name, br_name, rg_name from players where (dk_name like %(first_name_initial)s or dk_name like %(last_name_initial)s or fd_name like %(first_name_initial)s or fd_name like %(last_name_initial)s or br_name like %(first_name_initial)s or br_name like %(last_name_initial)s or rg_name like %(first_name_initial)s or rg_name like %(last_name_initial)s)"
select_clean_player_names_str = "select * from compare_exact_clean_name_columns(%s)"
select_lowercase_player_names_str = "select * from compare_lowercase_names(%s)"
select_unaccented_player_names_str = "select * from compare_unaccented_names(%s)"

select_stat_line_by_player_and_game_str = "select * from stat_lines where player_id=%s and game_id=%s"

team_columns = ['id', 'name', 'abbrv', 'rg_abbrv', 'br_abbrv']
player_columns = ['id', 'dk_name', 'fd_name',
                  'br_name', 'rg_name', 'current_team_id', 'fte_name']
player_name_columns = ['id', 'dk', 'fd', 'br', 'rg']
game_columns = ['id', 'date', 'home_team_id', 'away_team_id', 'season']
stat_line_columns = ['id', 'player_id', 'team_id', 'game_id', 'dk_positions',
                     'fd_positions', 'dk_salary', 'fd_salary', 'dk_points', 'fd_points', 'stats']


def find_game_by_date_and_team(date, team_id):
    cursor.execute(select_game_by_date_and_team_str, (date, team_id, team_id,))
    game_info = cursor.fetchone()
    if not game_info:
        return None
    return dict(zip(game_columns, game_info))


def find_all_teams():
    cursor.execute(select_all_teams)
    teams = cursor.fetchall()
    return [dict(zip(team_columns, team)) for team in teams]


def find_team_by_name(name):
    cursor.execute(select_team_by_name_str, (name,))
    team_info = cursor.fetchone()
    if not team_info:
        return None
    return dict(zip(team_columns, team_info))


def find_team_by_site_abbrv(site_abbrv, name_abbrv):
    select_team_by_site_abbrv_str = select_team_by_site_abbrv_column_str % site_abbrv
    cursor.execute(select_team_by_site_abbrv_str, (name_abbrv,))
    team_info = cursor.fetchone()
    if not team_info:
        return None
    return dict(zip(team_columns, team_info))


def find_player_by_site_abbrv_name(site_abbrv, name):
    cursor.execute(select_player_by_site_abbrv_name_str,
                   (AsIs(site_abbrv), name))
    player_info = cursor.fetchone()
    if not player_info:
        return None
    return dict(zip(player_columns, player_info))


def find_player_by_rg_name(name):
    cursor.execute(select_player_by_rg_name_str, (name,))
    player_info = cursor.fetchone()
    if not player_info:
        return None
    return dict(zip(player_columns, player_info))


def find_player_by_br_name(name):
    cursor.execute(select_player_by_br_name_str, (name,))
    player_info = cursor.fetchone()
    if not player_info:
        return None
    return dict(zip(player_columns, player_info))


def find_stat_line_by_player_and_game(player_id, game_id):
    cursor.execute(select_stat_line_by_player_and_game_str,
                   (player_id, game_id,))
    stat_line_info = cursor.fetchone()
    if not stat_line_info:
        return None
    return dict(zip(stat_line_columns, stat_line_info))


def find_all_player_rg_names():
    cursor.execute(select_all_player_rg_names_str)
    players = cursor.fetchall()
    return players


def find_player_by_exact_name(name):
    '''
    Goal here is to see if we can find a player where one of the name columns is an exact match.
    '''
    cursor.execute(select_exact_player_names_str, (name,))
    player_info = cursor.fetchone()
    if not player_info:
        return None
    return dict(zip(player_columns, player_info))


def find_player_by_clean_name(name):
    '''
    Trying to find a player by a clean name, meaning no Jr., Sr., III, or dots like J.J
    '''
    cursor.execute(select_clean_player_names_str, (name,))
    player_info = cursor.fetchone()
    if not player_info:
        return None
    return dict(zip(player_columns, player_info))


def find_player_by_unaccented_name(name):
    '''
    Trying to find a player by a clean name, meaning no Jr., Sr., III, or dots like J.J
    '''
    cursor.execute(select_unaccented_player_names_str, (name,))
    player_info = cursor.fetchone()
    if not player_info:
        return None
    return dict(zip(player_columns, player_info))


def find_player_by_lowercase_name(name):
    '''
    Trying to find a player by a lowercase name, so Mccaw isn't lost
    '''
    cursor.execute(select_lowercase_player_names_str, (name,))
    player_info = cursor.fetchone()
    if not player_info:
        return None
    return dict(zip(player_columns, player_info))
