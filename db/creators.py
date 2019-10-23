import json

from db.db import conn, cursor

create_game_str = "insert into games(date, home_team_id, away_team_id, season) values (%s, %s, %s, %s) on conflict do nothing"
create_team_str = "insert into teams(name, abbrv, rg_abbrv, br_abbrv) values (%s, %s, %s, %s) on conflict do nothing"
create_player_by_column_name_str = "insert into players(%s) values(%%s)"
create_or_update_stat_line_str = "insert into stat_lines(player_id, team_id, game_id, dk_points, fd_points, stats, minutes, active) values(%s, %s, %s, %s, %s, %s, %s, %s) on conflict (player_id, game_id) do update set dk_points = excluded.dk_points, fd_points = excluded.fd_points, stats = excluded.stats, minutes = excluded.minutes, active = excluded.active;"
create_stat_line_salary_position_str = "insert into stat_lines(player_id, team_id, game_id, %s_positions, %s_salary) values (%%s, %%s, %%s, %%s, %%s) on conflict do nothing"


def create_game(date, home_team_id, away_team_id, season):
    cursor.execute(create_game_str,
                   (date, home_team_id, away_team_id, season,))
    return conn.commit()


def create_team(name, abbrv, rb_abbrv, br_abbrv):
    cursor.execute(create_team_str, (name, abbrv, rb_abbrv, br_abbrv,))
    return conn.commit()


def create_player_by_name(column, name):
    create_player_by_name_str = create_player_by_column_name_str % column
    cursor.execute(create_player_by_name_str, (name,))
    return conn.commit()


def create_or_update_stat_line_with_stats(player_id, team_id, game_id, dk_points, fd_points, stats, minutes, active=True):
    cursor.execute(create_or_update_stat_line_str, (player_id, team_id, game_id,
                                          dk_points, fd_points, json.dumps(stats), minutes, active,))
    return conn.commit()

def create_stat_line_with_position_salary(site_abbrv, player_id, team_id, game_id, site_positions, site_salary):
    create_stat_line_str = create_stat_line_salary_position_str % (site_abbrv, site_abbrv)
    cursor.execute(create_stat_line_str, (player_id, team_id, game_id, site_positions, site_salary,))
    return conn.commit()