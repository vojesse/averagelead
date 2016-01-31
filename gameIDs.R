"""
Scrapes play by play JSON data from stats.nba.com

Jesse Vo
"""

library(rjson)

url = "http://stats.nba.com/stats/teamgamelog?LeagueID=00&Season=2014-15&SeasonType=Regular+Season&TeamID=1610612764"
#Change teamID to change teams.
data = fromJSON(file=url)
#Convert JSON into R data frame.

gameIDVector = vector("list", length(data$resultSets[[1]]$rowSet))
gameNameVector = vector("list", length(data$resultSets[[1]]$rowSet))
for(i in 1:length(data$resultSets[[1]]$rowSet))
{
	gameIDVector[[i]] = data$resultSets[[1]]$rowSet[[i]][[2]]
	gameNameVector[[i]] = data$resultSets[[1]]$rowSet[[i]][[4]]
}
#Create vector equal to the size of the JSON data for gameIDs and game names then populate.

gameNameID = data.frame(unlist(gameNameVector), unlist(gameIDVector))
#Data frame with just game names and IDs. This is easier to work with than entire JSON dataset.
colnames(gameNameID) = c('gameName','gameID')
gameNameID$gameURL = paste("http://stats.nba.com/stats/playbyplayv2?GameId=", gameNameID$gameID, "&StartPeriod=0&EndPeriod=0&RangeType=2&StartRange=0&EndRange=0", sep = "")
#Create gameURL column with URLs of all games.
gameNameID$gameName = gsub(" ", "", gameNameID$gameName)
gameNameID$gameName = gsub("@", "at", gameNameID$gameName)
gameNameID$gameName = gsub("vs.", "vs", gameNameID$gameName)
#Rename games to format HOMvsAWY or AWYatHOM
gameNum = c("82","81","80","79","78","77","76","75","74","73","72","71","70","69","68","67","66","65","64","63","62","61","60","59","58","57","56","55","54","53","52","51","50","49","48","47","46","45","44","43","42","41","40","39","38","37","36","35","34","33","32","31","30","29","28","27","26","25","24","23","22","21","20","19","18","17","16","15","14","13","12","11","10","09","08","07","06","05","04","03","02","01")
gameNameID$gameName = paste(gameNameID$gameName, gameNum, sep = '')
setwd('/users/jessevo/downloads/WASpbp1415')
write.table(gameNameID, file = 'wasID.csv', sep = ',', row.names = FALSE)
#Write csv to directory

for (i in 1:length(gameNameID$gameName))
#For each game played.
{
	print(i)
	fileName = paste(gameNameID$gameName[[i]], '.csv', sep ='')
	url = gameNameID$gameURL[[i]]
	gID = gameNameID$gameID[[i]]
	json_data = fromJSON(file=url)

	times = vector("list", length(json_data$resultSets[[1]]$rowSet))
	margins = vector("list", length(json_data$resultSets[[1]]$rowSet))
	#Extract time and margin at that time for each game
	for(j in 1:length(json_data$resultSets[[1]]$rowSet))
	{
		times[[j]] = json_data$resultSets[[1]]$rowSet[[j]][[7]][[1]]
		if(!is.null(json_data$resultSets[[1]]$rowSet[[j]][[12]]))
		{
			margins[[j]] = json_data$resultSets[[1]]$rowSet[[j]][[12]][[1]]
		}
		else{margins[[j]] = "NA"}
	}

	WMOVdf = data.frame(unlist(times), unlist(margins))
	colnames(WMOVdf) = c("times", "margins")
	write.table(WMOVdf, file = fileName, sep = ',', row.names = FALSE)
	#Data frame with just times and margins written to csv
}
Sys.time()