"""
Use margin of victory data from gameIDs.R to build weighted margin of victory.

Weighted margin of victory records the score differential at every second and
averages it out for the course of the game.

Jesse Vo
"""

#POSITIVE = Home Team Win
#NEGATIVE = Away Team Win
from datetime import datetime
import mysql.connector


def buildTimeMargin(fileName):
	#Build arrays for time and margin.
	times = []
	margins = []
	f = open(fileName, 'r')
	for line in f:
		line = line.rstrip('\n')
		a = line.split(',')
		times.append(a[0])
		margins.append(a[1])
	f.close()
	#Remove headers
	times.pop(0)
	margins.pop(0)
	f.close()
	return times, margins

def fixTimeMargin(times, margins):
	holdMargin = 0 #Dummy holds margin if it does not change at that second
	secondsPassed = [] #Keeps track of the length of the game (in case of OT)
	for i in range(0,len(margins)):
		if margins[i] == '"NA"':
			margins[i] = holdMargin #Hold the margin if margin is listed as NA
		elif margins[i] == '"TIE"':
			margins[i] = 0 #If margin is tie that means it is 0.
		else:
			margins[i] = int(margins[i][1:-1]) #Convert margin to integer, skipping first and last characters.
			holdMargin = margins[i] #Reset holdMargin to current margin.
		if times[i] == '"12:00"':
			secondsPassed.append(0)
		else:
			time1 = times[i-1][1:-1]
			time1min, time1sec = time1.split(':')
			time2 = times[i][1:-1]
			time2min, time2sec = time2.split(':')
			secondsPassed.append((int(time1min) * 60 + int(time1sec)) - (int(time2min) * 60 + int(time2sec)))
	return secondsPassed, margins

def getWMOV(secondsPassed, margins):
	totalMargin = 0
	totalMarginList = []
	qtr = 0
	for i in range(0, len(margins)):
		j = 0
		while(j < secondsPassed[i]):
			totalMargin += margins[i] #Get total margin of victory
			totalMarginList.append(margins[i])
			j += 1
	return(float(float(totalMargin)/float(len(totalMarginList)))) #Divide total margin by total seconds to get WMOV

def main(): #Putting data into database
	cnx = mysql.connector.connect(user = 'net', password = 'net',
								database = 'netpositive')

	teams = ['CHA', 'CHI', 'CLE', 'DAL', 'DEN', 'DET', 'GSW', 'HOU', 'IND', 'LAC', 'LAL', 'MEM', 'MIA', 'MIL', 'MIN', 'NOP', 'NYK', 'OKC', 'ORL', 'PHI', 'PHX', 'POR', 'SAC', 'SAS', 'TOR', 'UTA', 'WAS']

	for team in teams:
		gameListPath = '/Users/jessevo/Downloads/' + team + 'pbp1415/' + team + 'ID.csv'
		gameList = open(gameListPath) #Open directory containing pbp.csv's
		for line in gameList:
			q = 'INSERT INTO WMOV values('
			line = line.rstrip('\n')
			a = line.split(',')
			fileName = '/Users/jessevo/Downloads/' + team + 'pbp1415/' + a[0][1:-1] + '.csv'
			try:
				times, margins = buildTimeMargin(fileName)
				secsPass, margins = fixTimeMargin(times, margins)
				if fileName[-11:-9] == 'vs':
					q += '"' + fileName[-14:-11] + '","' + fileName[-9:-6] + '",' +  str(getWMOV(secsPass, margins)) + ',' + str(margins[-1])+')'
					cursor = cnx.cursor()
					cursor.execute(q)
					cnx.commit() #Insert WMOV and regular MOV into database
					print(q)
			except IOError:
				next
		gameList.close()

main()