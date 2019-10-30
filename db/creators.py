import json

from db.db import conn, cursor

create_game_str = "insert into games(date, home_team_id, away_team_id, season, start_time) values (%s, %s, %s, %s, %s) on conflict do nothing"
create_team_str = "insert into teams(name, abbrv, rg_abbrv, br_abbrv) values (%s, %s, %s, %s) on conflict do nothing"
create_player_by_column_name_str = "insert into players(%s) values(%%s)"
create_or_update_stat_line_str = "insert into stat_lines(player_id, team_id, game_id, dk_points, fd_points, stats, minutes, active) values(%s, %s, %s, %s, %s, %s, %s, %s) on conflict (player_id, game_id) do update set dk_points = excluded.dk_points, fd_points = excluded.fd_points, stats = excluded.stats, minutes = excluded.minutes, active = excluded.active;"
create_stat_line_salary_position_str = "insert into stat_lines(player_id, team_id, game_id, %s_positions, %s_salary) values (%%s, %%s, %%s, %%s, %%s) on conflict do nothing"
create_or_update_projection_str = "insert into projections(stat_line_id, source, bulk, minutes, dk_points, fd_points) values(%s, %s, %s, %s, %s, %s) on conflict (stat_line_id, source, version) do update set bulk = excluded.bulk, minutes = excluded.minutes, dk_points = excluded.dk_points, fd_points = excluded.fd_points;"

create_or_update_contest_str = "insert into contests (site_id, name, date, num_games, min_cash_score, start_time, entry_fee, places_paid, max_entrants, total_entrants, min_cash_payout, prize_pool, winning_score, slate, bulk, max_entries, style) \
                        values(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) \
 on conflict (site_id, name, date) do update \
                        set num_games = excluded.num_games, min_cash_score = excluded.min_cash_score, start_time = excluded.start_time, \
                            entry_fee = excluded.entry_fee, places_paid = excluded.places_paid, max_entrants = excluded.max_entrants, total_entrants = excluded.total_entrants, \
                            min_cash_payout = excluded.min_cash_payout, prize_pool = excluded.prize_pool, winning_score = excluded.winning_score, slate = excluded.slate, \
                            bulk = excluded.bulk, max_entries = excluded.max_entries, style = excluded.style;"


def create_game(date, home_team_id, away_team_id, season, start_time):
    cursor.execute(create_game_str,
                   (date, home_team_id, away_team_id, season, start_time,))
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

def create_or_update_projection(stat_line_id, source, bulk, minutes, dk_points, fd_points):
    cursor.execute(create_or_update_projection_str, (stat_line_id, source, json.dumps(bulk), minutes, dk_points, fd_points,))
    return conn.commit()

def create_or_update_contest(site_id, name, date, bulk=None, num_games=None, min_cash_score=None, start_time=None, entry_fee=None, places_paid=None, max_entrants=None, total_entrants=None, min_cash_payout=None, prize_pool=None, winning_score=None, slate=None, max_entries=None, style=None):
    cursor.execute(create_or_update_contest_str, (site_id, name, date, num_games, min_cash_score, start_time, entry_fee, places_paid, max_entrants, total_entrants, min_cash_payout, prize_pool, winning_score, slate, json.dumps(bulk), max_entries, style,))
    return conn.commit()
