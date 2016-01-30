# weight-mov

R and Python scripts to scrape stats.nba.com for score differentials at every second. R does the scraping and Python is used for the final calculation and for input into a MySQL database.

The idea behind the WMOV statistic is that by only recording the score differential at the end of the 48th minute, we are losing a lot of information about how a game progresses in minutes 1-47. Of course, that final score is ultimately what matters to teams and fans, but it will be interesting to see the differences between how a team typically does throughout a game and how a team fares at the end of the game.