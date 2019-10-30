
#from workers.sites.basketball_reference import load_stat_lines_on_date, gather_box_scores_by_date
from workers.sites.fivethirtyeight import gather_projections, load_projections_for_date

date = '2019-10-30'
#gather_box_scores_by_date(date)
#load_stat_lines_on_date(date)

#gather_projections()
load_projections_for_date(date)


'''
date = '2019-10-29'
fd = FanDuel()
fd.load_salaries_positions_for_date(date)
'''
'''
import requests

headers = {}
headers['Authroization'] = 'Basic '
headers['X-Auth-Token'] = '..fHoi_7iIa5L-Md1iXNllByB6FJp6gY8SZ7Gu5VpNIixd6qfa0HG31u6GTy5x26EhFuWZ4qlzRTo1qcAhECByqqkmxDa3xFCiDnrEeT6eq6f2gwqMuye4YnZal7uOLfIkArmS_tR_pzggGaeuo-_0taqcCfJFOu8O61I7cYAv07BraoDiXrui8TG5b37EexzOBN8uD3IDYgG4GWgn8Q3N0wRjiD8ztQdmiJx3GIbNiHr4b-_y02Lr6JVxyEDkMBx22sCifzf5NtXKECAiny4M6qN4-sHtXQveIjfg3oiMn7DDiS6JolJnk5g1ZWkUYZv7TjQVzECWH4NIwzWDOkYA5g'
headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36'
headers['Origin'] = 'https://www.fanduel.com'
headers['Referer'] = 'https://www.fanduel.com/games/31585/contests/31585-224295456/entries/1845186601/scoring'
headers['Accept'] = 'application/json, text/plain, */*'
headers['Sec-Fetch-Mode'] = 'cors'
headers['X-Currency'] = 'USD'

print(headers)
url = 'https://api.fanduel.com/contests/39723-230566585/entries?page=1&page_size=250&user=1882103'
#resp = requests.get(url, headers=headers)
#print(resp)
#print(resp.text)

data = {}
data['username'] = 'jackschultz23@gmail.com'

login_url = 'https://www.fanduel.com/login'
session = requests.session()
session.post(login_url, data=data)
print(session)

asdf = 'https://www.fanduel.com/games/39723/contests/39723-230566585/entries/1845186601/scoring'
qwer = session.get(asdf)
print(qwer)
print(qwer.text)

resp = session.get(url, headers=headers)
print(resp)
print(resp.text)
'''