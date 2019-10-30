from ndba import NDBA

actor = NDBA(database="nba", user="nbauser", password="nbapassword", host="localhost", port="5432")
#cursor = actor.cursor
#conn = actor.conn

#conn, cursor = ndba.connect(database="nba", user="nbauser", password="nbapassword", host="localhost", port="5432")