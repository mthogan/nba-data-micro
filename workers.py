import argparse
import datetime

from workers.daily import stat_lines, fantasy_sites, outside_projections


#fantasy_sites(today)
#outside_projections(today)


ap = argparse.ArgumentParser()
ap.add_argument("-a", "--all", action='store_true' ,help="Run all workers")
ap.add_argument("-s", "--stat-lines", action='store_true', help="Gather stat lines from date")
ap.add_argument("-p", "--projs", action='store_true', help="Gather and load outside projections")
ap.add_argument("-f", "--fantasy-sites", action='store_true', help="Load the information from the different fantasy sites")
ap.add_argument("-d", "--date", default=datetime.date.today().isoformat(), help="Date that we should run the worker with")

if __name__ == '__main__':
    args = vars(ap.parse_args())
    print(args)
    date = args['date']


    if args['stat_lines']:
        stat_lines(date)
    elif args['projs']:
        outside_projections(date)
    elif args['fantasy_sites']:
        fantasy_sites(date)
        