# Services for gathering, scraping, and loading data

In here we have actions for getting necessary information from online, cleaning it, and being able to load it into the db.

## Daily tasks:

- Gather, scrape, load stat_lines from the day before from basketball_reference

 - Get site csv salary data
 	- Download manually

 - Load the players from the FD and DK csvs
 	- `load_player_for_date(date)`

 - Load the new stat_lines from FD and DK csvs by adding the salary and positions


- Gather 538 rotation information
	- `gather_projections()` 
	- Needs to be run daily since it gets updated daily and no history


- Rotogrinders projections
	 - Can download the csv daily, but not premium yet, so no past data


## One time tasks

- Adding the teams
	- Using `teams.csv`, we add the teams with the relative abbrvs

- Adding the games
	- We have the game files from br, and we can add them all at once.
	- For a new season, we need to gather the games as well first.