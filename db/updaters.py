import json

from db.db import conn, cursor

update_player_name_column_str = "update players set %s = %%s where id = %%s"
update_stat_line_position_salary_str = "update stat_lines set %s_positions = %%s, %s_salary = %%s where id = %s"
update_stat_line_with_stats_str = "update stat_lines stat_lines set dk_points = %s, fd_points = %s, stats = %s, minutes = %s, active = %s"
update_game_str = "update games set date = %s, home_team_id = %s, away_team_id = %s, season = %s, start_time = %s where id = %s"


def update_player_name(column, player_id, name):
    update_command = update_player_name_column_str % column
    cursor.execute(update_command, (name, player_id,))
    return conn.commit()


def update_stat_line_position_salary(site_abbrv, stat_line_id, pos, sal):
    update_command = update_stat_line_position_salary_str % (
        site_abbrv, site_abbrv, stat_line_id)
    print(update_command)
    cursor.execute(update_command, (pos, sal,))
    return conn.commit()


def update_stat_line_with_stats(dk_points, fd_points, stats, minutes, active=True):
    cursor.execute(update_stat_line_with_stats_str, (dk_points, fd_points, json.dumps(stats), minutes, active,))
    return conn.commit()


def update_game(game_id, date, home_team_id, away_team_id, season, start_time):
    cursor.execute(update_game_str,
                   (date, home_team_id, away_team_id, season, start_time, game_id,))
    return conn.commit()
