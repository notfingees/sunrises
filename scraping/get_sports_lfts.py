import urllib, urllib.request
import json
import requests
import mysql.connector
from datetime import datetime

#mydb = mysql.connector.connect(host="localhost", user="test_user", password="test_user", database="aurora", port = 8888, unix_socket='/Applications/MAMP/tmp/mysql/mysql.sock')
mydb = mysql.connector.connect(host="localhost", user="FAKE_USER", password="FAKE_PASSWORD", database="aurora")
mycursor = mydb.cursor()


sql = "SELECT current_lft_index FROM helper"
mycursor.execute(sql)
myresult = mycursor.fetchall()
current_lft_index = myresult[0][0]


def sanitize(item):
    return item.translate(str.maketrans({"'": r"''"}))


# ### NOTE: run code every WEEK

# run every week for next 15 events in every league
# if date is passed: don't add
# if lft with same description and date is added: don't add

### getting every league and sport

sport_to_id = {}
all_sports = requests.get("https://www.thesportsdb.com/api/v1/json/FAKE_ENDPOINT/all_sports.php").json()['sports']
for sport in all_sports:
    print(sport)

    name = sport['strSport']
    name = name.translate(str.maketrans({"'": r"''"}))
    desc = name + " (sport)"
    desc = desc.translate(str.maketrans({"'": r"''"}))

    sql = "SELECT interest_id FROM interests WHERE name = '" + name + "' AND description = '" + desc + "'"
    mycursor.execute(sql)
    myresult = mycursor.fetchall()
    if len(myresult) > 0:
        interest_id = myresult[0][0]
        sport_to_id[name] = interest_id

league_to_id = {}
league_info = {}

all_leagues_link = ("https://www.thesportsdb.com/api/v1/json/FAKE_API_KEY/all_leagues.php")
all_leagues = requests.get(all_leagues_link).json()
league_ids = []

countries_list = ["united states", "canada", "mexico", "brazil", "germany", "italy", "france", "argentina", "spain", "england", "uruguay", "belgium", "portugal", "netherlands", "denmark", "switzerland", "colombia", "sweden", "japan", "chile"]

for league in all_leagues['leagues']:
    #print(league['strSport'])
    #print(league['strLeague'])
    #print(league['idLeague'])
    #print()

    league_details_link = ("https://www.thesportsdb.com/api/v1/json/1/lookupleague.php?id=" + league['idLeague'])
    try:
        league_details = requests.get(league_details_link).json()
        if league_details['leagues'][0]['strCountry'].lower() in countries_list:
            league_ids.append(league['idLeague'])
            league_info[league['idLeague']] = league_details['leagues']
    except:
        print("skipping", league)

leagues_that_have_events = []
temp_break = False
for id in league_ids:

    link1 = ("https://www.thesportsdb.com/api/v1/json/FAKE_API_KEY/eventsnextleague.php?id=" + id)
    response = requests.get(link1).json()
    print(response)


    if ((response['events']) is not None):

        try:

            leagues_that_have_events.append(id)
           # link2 = ("https://www.thesportsdb.com/api/v1/json/FAKE_API_KEY/lookupleague.php?id=" + id)
           # r2 = requests.get(link2).json()['leagues']

            r2 = league_info[id]

            name = r2[0]['strLeague']
            name = name.translate(str.maketrans({"'": r"''"}))
            desc = (r2[0]['strDescriptionEN'].split('.'))[0]
            desc = desc.translate(str.maketrans({"'": r"''"}))

            sql = "SELECT interest_id FROM interests WHERE name = '" + name + "' AND description = '" + desc + "'"
            mycursor.execute(sql)
            myresult = mycursor.fetchall()
            if len(myresult) > 0:
                interest_id = myresult[0][0]
                league_to_id[name] = interest_id
        except:
            print("failed with", response['events'])


### Get events

print("after for id in league_ids")

for league_id in leagues_that_have_events:

    link = "https://www.thesportsdb.com/api/v1/json/FAKE_API_KEY/eventsnextleague.php?id=" + league_id
    events = requests.get(link).json()['events']

    for event in events:

        try:

            print(event)

            event_description = event['strEvent']
            event_description = event_description.translate(str.maketrans({"'": r"''"}))

            league_string = event['strLeague']
            league_string = league_string.translate(str.maketrans({"'": r"''"}))
            sport_string = event['strSport']
            sport_string = sport_string.translate(str.maketrans({"'": r"''"}))

            league_interest_id = league_to_id[league_string]
            sport_interest_id = sport_to_id[sport_string]

            event_date_string = event['dateEvent']
            event_date_time = datetime.strptime(event_date_string, "%Y-%m-%d")
            formatted_event_date_string = event_date_time.strftime('%d.%m.%y')

            today = datetime.today()

            if event_date_time < today: #event has already passed
                print("date has already passed")
                pass
            else: # event is today or in the future
                sql = "SELECT lft_id, description FROM look_forward_to WHERE description = '" + event_description + "' AND date = '" + formatted_event_date_string + "'"
                mycursor.execute(sql)
                myresult = mycursor.fetchall()
                if len(myresult) > 0:
                    pass
                else:

                    if event['idHomeTeam'] is not None:

                        try:
                            idHomeTeam = event['idHomeTeam']
                            home_link = "https://www.thesportsdb.com/api/v1/json/FAKE_API_KEY/lookupteam.php?id=" + idHomeTeam
                            home_team_name = sanitize(requests.get(home_link).json()['teams'][0]['strTeam'])
                            home_team_desc = requests.get(home_link).json()['teams'][0]['strDescriptionEN']
                            home_team_desc = sanitize(home_team_desc.split('.')[0])

                            home_team_id = 0

                            #sql = "SELECT interest_id FROM interests WHERE name = '" + home_team_name + "' AND description = '" + home_team_desc + "'"
                            sql = "SELECT interest_id FROM interests WHERE name = '" + home_team_name + "'"

                            mycursor.execute(sql)
                            myresult = mycursor.fetchall()
                            home_team_id = myresult[0][0]

                            sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                            val = (home_team_id, event_description, "sports", "2",
                                   formatted_event_date_string, home_team_name)
                            mycursor.execute(sql, val)

                            mydb.commit()
                        except:
                            print("failed to insert 1")
                            pass

                    if event['idAwayTeam'] is not None:

                        ## is a team sport, so have to add it to the team specific interest

                        try:

                            idAwayTeam = event['idAwayTeam']
                            away_link = "https://www.thesportsdb.com/api/v1/json/FAKE_API_KEY/lookupteam.php?id=" + idAwayTeam
                            away_team_name = sanitize(requests.get(away_link).json()['teams'][0]['strTeam'])
                            away_team_desc = requests.get(away_link).json()['teams'][0]['strDescriptionEN']
                            away_team_desc = sanitize(away_team_desc.split('.')[0])
                            away_team_id = 0

                            sql = "SELECT interest_id FROM interests WHERE name = '" + away_team_name + "'"
                            mycursor.execute(sql)
                            myresult = mycursor.fetchall()

                            away_team_id = myresult[0][0]

                            sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                            val = (away_team_id, event_description, "sports", '2',
                                   formatted_event_date_string, away_team_name)
                            mycursor.execute(sql, val)

                            mydb.commit()
                        except:
                            print("failed to insert 2")
                            pass


                    sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                    val = (league_interest_id, event_description, "sports", "1",
                           formatted_event_date_string, league_string)
                    mycursor.execute(sql, val)

                    sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                    val = (sport_interest_id, event_description, "sports", "1",
                           formatted_event_date_string, sport_string)
                    mycursor.execute(sql, val)

                    mydb.commit()
        except:
            print("failed with", event)



sql = "SELECT MAX(lft_id) AS maximum FROM look_forward_to"
mycursor.execute(sql)
myresult = mycursor.fetchall()
new_current_lft_index = myresult[0][0]

total_added = int(new_current_lft_index) - int(current_lft_index)

todays_date = (datetime.now()).strftime('%d.%m.%y')
sql = "INSERT INTO uploads_log (date, script, lfts_uploaded) VALUES (%s, %s, %s)"
val = (todays_date, "get_sports_lfts.py", str(total_added))
mycursor.execute(sql, val)

mydb.commit()

sql = "UPDATE helper SET current_lft_index = '" + str(new_current_lft_index) + "' WHERE previous_interest_index = '0'"
mycursor.execute(sql)
mydb.commit()