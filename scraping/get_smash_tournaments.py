# token: 2279611149abdddc4bb03c64b15f4b76

import requests
import json
import time
import sys
import random
import mysql.connector
from datetime import datetime, timedelta

mydb = mysql.connector.connect(host="127.0.0.1", user="test_user", password="test_user", database="aurora")
mycursor = mydb.cursor()


sql = "SELECT current_lft_index FROM helper"
mycursor.execute(sql)
myresult = mycursor.fetchall()
current_lft_index = myresult[0][0]



sql = "SELECT interest_id FROM interests WHERE name = 'Smash Ultimate'"
mycursor.execute(sql)
myresult = mycursor.fetchall()


SMASH_IID = 0
if len(myresult) > 0:
    for i in range(len(myresult)):
        SMASH_IID = myresult[i][0]


today = datetime.today()
tomorrow = datetime.now() + timedelta(1)
day_after_tomorrow = datetime.now() + timedelta(2)
next_midnight = datetime.combine(tomorrow, datetime.min.time())
next_midnight_after_tomorrow = datetime.combine(day_after_tomorrow, datetime.min.time())
next_midnight_timestamp = next_midnight.timestamp()
next_midnight_after_tomorrow_timestamp = next_midnight_after_tomorrow.timestamp()
todays_date = (datetime.now()).strftime('%d.%m.%y')
tomorrows_date = (datetime.now() + timedelta(1)).strftime('%d.%m.%y')

accessToken = "FAKE_TOKEN"
endpoint = f"https://api.smash.gg/gql/alpha"
headers = {"Authorization": f"Bearer {accessToken}"}
query = """query TournamentsByVideogame($perPage: Int = 150, $videogameId: ID = 1386) {
  tournaments(query: {
    perPage: $perPage
    page: 1
    sortBy: "startAt asc"
    filter: {
      afterDate: """ + str(int(time.time())) + """
      #past: false
      videogameIds: [
        $videogameId
      ]
      
    }
  }) {
    nodes {
      
      startAt
      id
      name
      slug
      events{
        id
        numEntrants
        videogame{
          id
        }
        
      }
    }
  }
}
"""

pgr_players = []
f = open("/home/bitnami/python/smash_players.txt", "r")
for name in f:
    pgr_players.append(name.lower())

r = requests.post(endpoint, json={"query": query}, headers=headers)
print(r.json())
tournaments = r.json()['data']['tournaments']['nodes']
#tid_to_tevents = {}

for tournament in tournaments:
    #print(tournament)
    #print()

    #try:
    try:
        max_numEntrants = 0
        max_numEntrants_event_id = 0
        for event in tournament['events']:
            if event['videogame']['id'] == 1386 and event['numEntrants'] is not None: #and event['id'] not in [627924, 322128]:
                #print(event)

                if int(event['numEntrants']) > max_numEntrants:
                    max_numEntrants = int(event['numEntrants'])
                    max_numEntrants_event_id = event['id']

        #print("in", tournament, "max_numEntrants and event_id are", max_numEntrants, max_numEntrants_event_id)

        #if max_numEntrants > 50:
        if max_numEntrants > 25: #and max_numEntrants_event_id not in [627924, 322128]:
            #print("event", tournament['events'], max_numEntrants_event_id, "has more than 50 entrants")

            query = """query EventEntrants($eventId: ID = """ + str(max_numEntrants_event_id) + """){
          event(id: $eventId) {
            id
            name
            entrants(query: {
              page: 1
              perPage: 500
             # sortBy: "seeds asc"
        
            }) {
              pageInfo {
                total
                totalPages
              }
              nodes {
                id
                participants {
                  id
                  gamerTag
                }
                seeds{
                  id
                  seedNum
                }
              }
            }
          }
        }"""
            r2 = requests.post(endpoint, json={"query": query}, headers=headers)


            if r2.status_code == 200:
                entrants = r2.json()
                #print(entrants)
                entrants_count = entrants['data']['event']['entrants']['pageInfo']
                all_participants = []

                seed1 = ""
                seed2 = ""
                seed3 = ""

                # not 'name' == 'ultimate singles' - have to do the one with most entrants

                for i in range(entrants_count['totalPages']):

                    if seed1!="" and seed2!="" and seed3!="":
                        break

                    page = str(i + 1)
                    #print("in page", page)
                    query = """query EventEntrants($eventId: ID = """ + str(event['id']) + """){
                      event(id: $eventId) {
                        id
                        name
                        entrants(query: {
                          page: """ + page +"""
                          perPage: 500
                         # sortBy: "seeds asc"
        
                        }) {
                          pageInfo {
                            total
                            totalPages
                          }
                          nodes {
                            id
                            participants {
                              id
                              gamerTag
                            }
                            seeds{
                              id
                              seedNum
                            }
                          }
                        }
                      }
                    }"""
                    r3 = requests.post(endpoint, json={"query": query}, headers=headers)

                    if r3.status_code == 200:
                        entrants = r3.json()
                       # print(entrants)
                        participants = entrants['data']['event']['entrants']['nodes']

                        #print(participants)
                        #print(len(participants))
                        for participant in participants:


                            all_participants.append(participant)
                           # print("appending", participant, "seed:", participant['seeds'][0]['seedNum'])
                            if participant['seeds'] is None:
                                pass
                            elif participant['seeds'][0]['seedNum'] is None:
                                #break
                                pass
                            else:
                                if int(participant['seeds'][0]['seedNum']) == 1:
                                    seed1 = participant['participants'][0]['gamerTag']
                                if int(participant['seeds'][0]['seedNum']) == 2:
                                    seed2 = participant['participants'][0]['gamerTag']
                                if int(participant['seeds'][0]['seedNum']) == 3:
                                    seed3 = participant['participants'][0]['gamerTag']
                                if seed1 != "" and seed2 != "" and seed3 != "":
                                    break



              #  for i in range(entrants_count['totalPages']):


                #print("length of all_participants is", len(all_participants))
                #for participant in all_participants:
                #    print(participant, "seed:", participant['seeds'][0]['seedNum'])
                #print("======TOURNAMENT", tournament['name'], "======")
                #print("all participants is", all_participants)
                desc = ""
                pgr_players_attending = []
                if seed1 == "":
                    for p in all_participants:
                        name = participant['participants'][0]['gamerTag']
                        if name.lower() in pgr_players:
                            pgr_players_attending.append(name)
                else:
                    desc = "Look forward to Smash tournament " + tournament['name'] + " featuring " + seed1 + ", " + seed2 + ", " + seed3 + ", and more!"

                if len(pgr_players_attending) > 0:
                    random.shuffle(pgr_players_attending)
                    if len(pgr_players_attending) == 1:
                        desc = "Look forward to Smash tournament " + tournament[
                        'name'] + " featuring " + pgr_players_attending[0] + " and more!"
                    elif len(pgr_players_attending) == 2:
                        desc = "Look forward to Smash tournament " + tournament[
                            'name'] + " featuring " + pgr_players_attending[0] + ", " + pgr_players_attending[1] + ", and more!"
                    else:
                        desc = "Look forward to Smash tournament " + tournament[
                            'name'] + " featuring " + pgr_players_attending[0] + ", " + pgr_players_attending[1] + ", " + pgr_players_attending[2] + ", and more!"

                else:
                    desc = "Look forward to Smash tournament " + tournament['name']

                print(desc)
                importance = 0
                if max_numEntrants > 50:
                    importance = 1
                if max_numEntrants > 100:
                    importance = 2
                #print(seed1, seed2, seed3, tournament)

                date = ""
                if tournament['startAt'] < next_midnight_timestamp:
                    date = todays_date
                elif tournament['startAt'] < next_midnight_after_tomorrow_timestamp:

                    date = tomorrows_date
                else:
                    date = "IGNORE"

                if date != "IGNORE":
                    try:
                        sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                        val = (SMASH_IID, desc, "gaming", importance, date, "Smash Ultimate")
                        mycursor.execute(sql, val)
                        mydb.commit()
                    except:
                        print("failed with", desc, importance, date)


    except:
        print("failed with", tournament, sys.exc_info())

#if r.status_code == 200:
 #   print(data)

   # print(json.dumps(r.json(), indent=2))
sql = "SELECT MAX(lft_id) AS maximum FROM look_forward_to"
mycursor.execute(sql)
myresult = mycursor.fetchall()
new_current_lft_index = myresult[0][0]

total_added = int(new_current_lft_index) - int(current_lft_index)

todays_date = (datetime.now()).strftime('%d.%m.%y')
sql = "INSERT INTO uploads_log (date, script, lfts_uploaded) VALUES (%s, %s, %s)"
val = (todays_date, "get_smash_tournaments.py", str(total_added))
mycursor.execute(sql, val)

mydb.commit()

sql = "UPDATE helper SET current_lft_index = '" + str(new_current_lft_index) + "' WHERE previous_interest_index = '0'"
mycursor.execute(sql)
mydb.commit()