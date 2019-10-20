from db.db import conn, cursor
from psycopg2.extensions import AsIs


select_game_count_str_str = "select count(*) from games"
select_game_by_date_and_team_str = "select * from games where date=%s and (home_team_id=%s or away_team_id=%s)"
select_team_by_name_str = "select * from teams where name=%s"
select_team_by_abbrv_str = "select * from teams where abbrv=%s"
select_team_by_rg_abbrv_str = "select * from teams where rg_abbrv=%s"
select_player_by_rg_name_str = "select * from players where rg_name=%s"
select_player_by_br_name_str = "select * from players where br_name=%s or br2_name=%s"
select_player_by_site_abbrv_name_str = "select * from players where %s_name=%s"
select_stat_line_by_player_and_game_str = "select * from stat_lines where player_id=%s and game_id=%s"
select_all_player_rg_names_str = "select rg_name from players"

select_exact_player_names_str = "select id, dk_name, fd_name, br_name, rg_name, fte_name from players where dk_name=%s or fd_name=%s or br_name=%s or rg_name=%s or br2_name=%s or fte_name=%s"
select_player_names_like_str = "select id, dk_name, fd_name, br_name, rg_name from players where (dk_name like %(first_name_initial)s or dk_name like %(last_name_initial)s or fd_name like %(first_name_initial)s or fd_name like %(last_name_initial)s or br_name like %(first_name_initial)s or br_name like %(last_name_initial)s or rg_name like %(first_name_initial)s or rg_name like %(last_name_initial)s)"

# and %(null_site_abbrv)s_name is null

team_columns = ['id', 'name', 'abbrv', 'rg_abbrv', 'br_abbrv']
player_columns = ['id', 'dk_name', 'fd_name', 'br_name', 'rg_name', 'current_team_id', 'fte_name']
game_columns = ['id', 'date', 'home_team_id', 'away_team_id', 'season']
stat_line_columns = ['id', 'player_id', 'team_id', 'game_id', 'dk_positions', 'fd_positions', 'dk_salary', 'fd_salary', 'dk_points', 'fd_points', 'stats']

player_name_columns = ['id', 'dk', 'fd', 'br', 'rg']

def find_game_by_date_and_team(date, team_id):
    cursor.execute(select_game_by_date_and_team_str, (date, team_id, team_id,))
    game_info = cursor.fetchone()
    if not game_info:
        return None
    return dict(zip(game_columns, game_info))

def find_team_by_name(name):
    cursor.execute(select_team_by_name_str, (name,))
    team_info = cursor.fetchone()
    if not team_info:
        return None
    return dict(zip(team_columns, team_info))

def find_team_by_rg_abbrv(rg_abbrv):
    cursor.execute(select_team_by_rg_abbrv_str, (rg_abbrv,))
    team_info = cursor.fetchone()
    if not team_info:
        return None
    return dict(zip(team_columns, team_info))

def find_player_by_site_abbrv_name(site_abbrv, name):
    cursor.execute(select_player_by_site_abbrv_name_str, (AsIs(site_abbrv), name))
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
    cursor.execute(select_player_by_br_name_str, (name, name,))
    player_info = cursor.fetchone()
    if not player_info:
        return None
    return dict(zip(player_columns, player_info))

def find_stat_line_by_player_and_game(player_id, game_id):
    cursor.execute(select_stat_line_by_player_and_game_str, (player_id, game_id,))
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
    name_tuple = tuple([name] * 5)
    cursor.execute(select_all_player_rg_names_str, name_tuple)
    player_info = cursor.fetchone()
    if not player_info:
        return None
    return dict(zip(player_columns, player_info))

def find_player_names_like_query(null_site_abbrv, name):
    '''
    Goal is to find players with names like the first initial or last name,
    where the name doesn't exist in the site_abbrv column.
    Will create error if name is None or no space, which is ok, unless it's Nene.
    '''
    first_name_initial = f"{name[0]}%"
    last_name_initial = f"{name.split(' ')[1][0]}%"
    cursor.execute(select_player_names_like_str, { 'first_name_initial': first_name_initial, 'last_name_initial': last_name_initial, 'null_site_abbrv': AsIs(null_site_abbrv) })
    return cursor.query
    players_info = cursor.fetchall()
    return [dict(zip(player_name_columns, player_info)) for player_info in players_info]
