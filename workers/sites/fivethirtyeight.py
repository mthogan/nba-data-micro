import requests
from lxml import html
import datetime
import os

from db.finders import find_team_by_name
import utils

base_url = "https://projects.fivethirtyeight.com"
base_extention = '2020-nba-predictions/'
base_directory = "data2/fivethirtyeight"


def gather_predictions():
    '''
    Getting the main page and saving it as when it was updated.
    At the bottom of the page, there's a dropdown asking for
    predictions from the past, so we can use that in the future
    if this data goes away.
    Then we find the links of the teams, gather those, and save as well.
    Directory structure is for each team to have its own directory, and then
    save the files based on date. This way we can handle different update
    time per time.
    '''
    page = requests.get(f"{base_url}/{base_extention}")
    tree = html.fromstring(page.content)
    updated_at = tree.xpath('//*[@id="intro"]/div/div[2]/div[1]/p')[0]
    time_info = updated_at.text.split(' ', 1)[1]
    updated_at_time = datetime.datetime.strptime(time_info, "%b. %d, %Y, at %I:%M %p")
    time_string = updated_at_time.strftime('%Y-%m-%d')
    directory = f"data2/fivethirtyeight/base"
    utils.ensure_directory_exists(directory)
    filename= f'{time_string}.html'
    filepath = f"{directory}/{filename}"
    with open(filepath, 'w') as f:
        f.write(page.text)
    gather_team_pages(tree, time_string, directory)
    gather_base_page() #get the main page

def gather_team_pages(tree, time_string, directory):
    '''
    We can get team pages from the links in a dropdown of the main
    page that we've already saved.
    '''
    print('links')
    links = tree.xpath('//*[@id="standings-table"]/tbody//a/@href')
    for link in links:
        team_url = f"{base_url}{link}"
        print(team_url)
        page = requests.get(team_url)
        #find the team from the db so we have the abbrv
        tree = html.fromstring(page.content)
        team_name = tree.xpath('//*[@id="team"]/div/div[1]/h1/span[1]/text()')[0]
        print(team_name)
        team = find_team_by_name(team_name)
        directory = f"{base_directory}/{team['abbrv']}"
        utils.ensure_directory_exists(directory)
        filename = f"{time_string}.html"
        filepath = f"{directory}/{filename}"
        with open(filepath, 'w') as f:
            f.write(page.text)


