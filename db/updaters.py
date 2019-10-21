from db.db import conn, cursor

update_player_name_column_str = "update players set %s = %%s where id = %%s"

def update_player_name(column, player_id, name):
    update_player_name_str = update_player_name_column_str % column
    cursor.execute(update_player_name_str, (name, player_id,))
    return conn.commit()
