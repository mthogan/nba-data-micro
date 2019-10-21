from db.db import conn, cursor

create_game_str = "insert into games(date, home_team_id, away_team_id, season) values (%s, %s, %s, %s) on conflict do nothing"
create_team_str = "insert into teams(name, abbrv, rg_abbrv, br_abbrv) values (%s, %s, %s, %s) on conflict do nothing"
create_player_by_column_name_str = "insert into players(%s) values(%%s)"


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
