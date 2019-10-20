import csv

from db.creators import create_team

def create_teams():
    with open('data2/teams.csv', 'r') as f:
        reader = csv.reader(f)
        next(reader, None)
        for row in reader:
            print(*row)
            create_team(*row[1:])
