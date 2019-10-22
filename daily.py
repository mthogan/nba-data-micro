from workers.sites.fivethirtyeight import gather_predictions
from workers.sites.basketball_reference import gather_box_scores_by_date


# From yesterday
yesterday = '2019-10-22'
gather_box_scores_by_date(yesterday)

# For today

gather_predictions()
