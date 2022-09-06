from bs4 import BeautifulSoup
import requests
from datetime import datetime, timedelta
import mysql.connector
import random
import re

mydb = mysql.connector.connect(host="localhost", user="FAKE_USER", password="FAKE_PASSWORD", database="aurora")
mycursor = mydb.cursor()

def date_formatter(date1):

    onemonth = False

    if "-" not in date1:
        d = date1.replace(' ', '')
        year_string = ""
        if d[5] == ",": #two digit date
            year_string = d[0]+d[1]+d[2]+"."+d[3]+d[4]+"."+d[6]+d[7]+d[8]+d[9]
        else:
            year_string = d[0] + d[1] + d[2] + ".0" + d[3] + "." + d[5] + d[6] + d[7] + d[8]
        ysd  = datetime.strptime(year_string, "%b.%d.%Y")
        return (ysd, ysd)



    d = date1.replace(' ', '')

    start_date = ""
    end_date = ""

    dates_length = len(d)

    year_string = ".2021"

    if d[dates_length-2] + d[dates_length-1] == "22":
        year_string = ".2022"
    elif  d[dates_length-2] + d[dates_length-1] == "21":
        year_string = ".2021"
    else:
        #print("returning False, False with", d)
        return((False, False))




    if d[5].isalpha() or d[6].isalpha():
        onemonth = False
    else:
        onemonth = True
    if onemonth:
        if d[4] == "-":
            start_date = d[0]+d[1]+d[2]+".0"+d[3]+year_string
        else:
            start_date = d[0]+d[1]+d[2]+"."+d[3]+d[4]+year_string
        if d[4] == "-":
            if d[6] == ",":
                end_date = d[0]+d[1]+d[2]+".0"+d[5]+year_string
            else:
                end_date = d[0] + d[1] + d[2] + "." + d[5] + d[6] + year_string
        else:
            if d[7] == ",":
                end_date = d[0]+d[1]+d[2]+".0"+d[6]+year_string
            else:
                end_date = d[0] + d[1] + d[2] + "." + d[6] + d[7] + year_string

    else:
        if d[4] == "-":
            start_date = d[0]+d[1]+d[2]+".0"+d[3]+year_string
        else:
            start_date = d[0]+d[1]+d[2]+"."+d[3]+d[4]+year_string
        if d[4] == "-":
            if d[9] == ",":
                end_date = d[5]+d[6]+d[7]+".0"+d[8]+year_string
            else:
                end_date = d[5] + d[6] + d[7] + "." + d[8] + d[9] + year_string
        else:
            if d[10] == ",":
                end_date = d[6]+d[7]+d[8]+".0"+d[9]+year_string
            else:
                end_date = d[6] + d[7] + d[8] + "." + d[9] + d[10] + year_string

    start_date_datetime = datetime.strptime(start_date, "%b.%d.%Y")
    end_date_datetime = datetime.strptime(end_date, "%b.%d.%Y")

    return ((start_date_datetime, end_date_datetime))


#URL = "https://liquipedia.net/overwatch/Major_Tournaments"
#URL = "https://liquipedia.net/leagueoflegends/Major_Tournaments"
#URL = "https://liquipedia.net/valorant/S-Tier_Tournaments"
#URL = "https://liquipedia.net/wildrift/A-Tier_Tournaments"
#URL = "https://liquipedia.net/rocketleague/A-Tier_Tournaments" ##ROCKET LEAGUE A LITTLE BROKEN FOR TEAMS - just pick the first 3 if game is rocket league
#URL = "https://liquipedia.net/rainbowsix/S-Tier_Tournaments" # Rainbow Six broken
#URL = "https://liquipedia.net/dota2/Tier_1_Tournaments"
#URL = "https://liquipedia.net/counterstrike/S-Tier_Tournaments"
#URL = "https://liquipedia.net/pubg/S-Tier_Tournaments" # PubG broken
#URL = "https://liquipedia.net/hearthstone/Portal:Tournaments" #Hearthstone broken
#URL = "https://liquipedia.net/apexlegends/A-Tier_Tournaments"
#URL = "https://liquipedia.net/smash/Major_Tournaments/Ultimate"
dota_urls = ["https://liquipedia.net/dota2/Tier_1_Tournaments",
        "https://liquipedia.net/dota2/Tier_2_Tournaments/2021-2020",
        "https://liquipedia.net/dota2/Tier_3_Tournaments/2021",
        "https://liquipedia.net/dota2/Tier_4_Tournaments",
        "https://liquipedia.net/dota2/Qualifier_Tournaments/2021"]
valorant_urls = ["https://liquipedia.net/valorant/S-Tier_Tournaments",
                 "https://liquipedia.net/valorant/A-Tier_Tournaments",
                 "https://liquipedia.net/valorant/B-Tier_Tournaments",
                 "https://liquipedia.net/valorant/C-Tier_Tournaments",
                 "https://liquipedia.net/valorant/Qualifier_Tournaments",
                 "https://liquipedia.net/valorant/Show_Match_Tournaments",
                 "https://liquipedia.net/valorant/Monthly_Tournaments",
                 "https://liquipedia.net/valorant/Weekly_Tournaments"]

rocketleague_urls = ["https://liquipedia.net/rocketleague/S-Tier_Tournaments",
                     "https://liquipedia.net/rocketleague/A-Tier_Tournaments",
                     "https://liquipedia.net/rocketleague/B-Tier_Tournaments",
                     "https://liquipedia.net/rocketleague/C-Tier_Tournaments",
                     "https://liquipedia.net/rocketleague/D-Tier_Tournaments",
                     "https://liquipedia.net/rocketleague/Monthly_Tournaments",
                     "https://liquipedia.net/rocketleague/Weekly_Tournaments/2021/2nd_Half",
                     "https://liquipedia.net/rocketleague/Show_Matches",
                     "https://liquipedia.net/rocketleague/Qualifier_Tournaments",
                     "https://liquipedia.net/rocketleague/School_Tournaments"]

league_urls = ["https://liquipedia.net/leagueoflegends/Premier_Tournaments",
               "https://liquipedia.net/leagueoflegends/Major_Tournaments",
               "https://liquipedia.net/leagueoflegends/Major_Tournaments",
               "https://liquipedia.net/leagueoflegends/Minor_Tournaments/2021",
               "https://liquipedia.net/leagueoflegends/Monthly_Tournaments",
               "https://liquipedia.net/leagueoflegends/Weekly_Tournaments",
               "https://liquipedia.net/leagueoflegends/Show_Matches",
               "https://liquipedia.net/leagueoflegends/Qualifier_Tournaments"]

csgo_urls = ["https://liquipedia.net/counterstrike/Valve_Tournaments",
             "https://liquipedia.net/counterstrike/S-Tier_Tournaments",
             "https://liquipedia.net/counterstrike/A-Tier_Tournaments",
             "https://liquipedia.net/counterstrike/B-Tier_Tournaments",
             "https://liquipedia.net/counterstrike/C-Tier_Tournaments",
             "https://liquipedia.net/counterstrike/Qualifier_Tournaments",
             "https://liquipedia.net/counterstrike/Monthly_Tournaments",
             "https://liquipedia.net/counterstrike/Weekly_Tournaments",
             "https://liquipedia.net/counterstrike/Show_Matches"]

apex_urls = ["https://liquipedia.net/apexlegends/S-Tier_Tournaments",
             "https://liquipedia.net/apexlegends/A-Tier_Tournaments",
             "https://liquipedia.net/apexlegends/B-Tier_Tournaments",
             "https://liquipedia.net/apexlegends/C-Tier_Tournaments",
             "https://liquipedia.net/apexlegends/Monthly_Tournaments",
             "https://liquipedia.net/apexlegends/Weekly_Tournaments",
             "https://liquipedia.net/apexlegends/Show_Matches",
             "https://liquipedia.net/apexlegends/Qualifier_Tournaments"]

overwatch_urls = ["https://liquipedia.net/overwatch/Premier_Tournaments",
                "https://liquipedia.net/overwatch/Major_Tournaments",
                "https://liquipedia.net/overwatch/Minor_Tournaments",
                "https://liquipedia.net/overwatch/Monthly_Tournaments",
                "https://liquipedia.net/overwatch/Weekly_Tournaments",
                  "https://liquipedia.net/overwatch/Qualifier_Tournaments",
                  "https://liquipedia.net/overwatch/Show_Matches_Tournaments"]

wildrift_urls = ["https://liquipedia.net/wildrift/S-Tier_Tournaments",
                 "https://liquipedia.net/wildrift/A-Tier_Tournaments",
                 "https://liquipedia.net/wildrift/B-Tier_Tournaments",
                 "https://liquipedia.net/wildrift/C-Tier_Tournaments",
                 "https://liquipedia.net/wildrift/Qualifier_Tournaments",
                 "https://liquipedia.net/wildrift/Monthly_Tournaments",
                 "https://liquipedia.net/wildrift/Weekly_Tournaments",
                 "https://liquipedia.net/wildrift/Show_Matches"]

smash_urls = ["https://liquipedia.net/smash/Major_Tournaments/Ultimate"]


ti2 = ["https://liquipedia.net/dota2/Tier_1_Tournaments", "https://liquipedia.net/valorant/S-Tier_Tournaments", "https://liquipedia.net/valorant/A-Tier_Tournaments", "https://liquipedia.net/rocketleague/S-Tier_Tournaments",
       "https://liquipedia.net/rocketleague/A-Tier_Tournaments",
       "https://liquipedia.net/leagueoflegends/Premier_Tournaments",
        "https://liquipedia.net/leagueoflegends/Major_Tournaments",
        "https://liquipedia.net/leagueoflegends/Show_Matches"
        "https://liquipedia.net/rocketleague/Show_Matches",
        "https://liquipedia.net/counterstrike/Valve_Tournaments",
             "https://liquipedia.net/counterstrike/S-Tier_Tournaments",
"https://liquipedia.net/counterstrike/A-Tier_Tournaments",
"https://liquipedia.net/apexlegends/S-Tier_Tournaments",
             "https://liquipedia.net/apexlegends/A-Tier_Tournaments",
"https://liquipedia.net/apexlegends/Show_Matches",
"https://liquipedia.net/overwatch/Show_Matches_Tournaments",
"https://liquipedia.net/overwatch/Premier_Tournaments",
"https://liquipedia.net/overwatch/Major_Tournaments",
       "https://liquipedia.net/wildrift/Show_Matches",
"https://liquipedia.net/wildrift/S-Tier_Tournaments",
                 "https://liquipedia.net/wildrift/A-Tier_Tournaments"


       ] # tournament importance of 2

ti0 = ["https://liquipedia.net/dota2/Tier_4_Tournaments", "https://liquipedia.net/valorant/C-Tier_Tournaments", "https://liquipedia.net/valorant/Weekly_Tournaments", "https://liquipedia.net/rocketleague/Weekly_Tournaments/2021/2nd_Half",
       "https://liquipedia.net/rocketleague/D-Tier_Tournaments", "https://liquipedia.net/leagueoflegends/Weekly_Tournaments",
       "https://liquipedia.net/counterstrike/Weekly_Tournaments",
"https://liquipedia.net/counterstrike/C-Tier_Tournaments", "https://liquipedia.net/apexlegends/Weekly_Tournaments",
"https://liquipedia.net/apexlegends/C-Tier_Tournaments", "https://liquipedia.net/overwatch/Minor_Tournaments", "https://liquipedia.net/overwatch/Weekly_Tournaments", "https://liquipedia.net/wildrift/C-Tier_Tournaments",
"https://liquipedia.net/wildrift/Weekly_Tournaments"
       ]

all_urls = [dota_urls, valorant_urls, rocketleague_urls, league_urls, csgo_urls, apex_urls, overwatch_urls, wildrift_urls]

index = 0
for game_url in all_urls:
    game_interest_id = 0
    game_interest_name = ""
    if index == 0: #DOTA2
        sql = "SELECT interest_id, name FROM interests WHERE name = 'Dota 2' AND category = 'gaming'"
        mycursor.execute(sql)
        myresult = mycursor.fetchall()
        game_interest_id = myresult[0][0]
        game_interest_name = "Dota 2"

    elif index == 1:
        sql = "SELECT interest_id, name FROM interests WHERE name = 'VALORANT' AND category = 'gaming'"
        mycursor.execute(sql)
        myresult = mycursor.fetchall()
        game_interest_id = myresult[0][0]
        game_interest_name = "VALORANT"
    elif index == 2:
        sql = "SELECT interest_id, name FROM interests WHERE name = 'Rocket League' AND category = 'gaming'"
        mycursor.execute(sql)
        myresult = mycursor.fetchall()
        game_interest_id = myresult[0][0]
        game_interest_name = "Rocket League"
    elif index == 3:
        sql = "SELECT interest_id, name FROM interests WHERE name = 'League of Legends' AND category = 'gaming'"
        mycursor.execute(sql)
        myresult = mycursor.fetchall()
        game_interest_id = myresult[0][0]
        game_interest_name = "League of Legends"
    elif index == 4:
        sql = "SELECT interest_id, name FROM interests WHERE name = 'Counter-Strike: Global Offensive' AND category = 'gaming'"
        mycursor.execute(sql)
        myresult = mycursor.fetchall()
        game_interest_id = myresult[0][0]
        game_interest_name = "Counter-Strike: Global Offensive"
    elif index == 5:
        sql = "SELECT interest_id, name FROM interests WHERE name = 'Apex Legends' AND category = 'gaming'"
        mycursor.execute(sql)
        myresult = mycursor.fetchall()
        game_interest_id = myresult[0][0]
        game_interest_name = "Apex Legends"
    elif index == 6:
        sql = "SELECT interest_id, name FROM interests WHERE name = 'Overwatch' AND category = 'gaming'"
        mycursor.execute(sql)
        myresult = mycursor.fetchall()
        game_interest_id = myresult[0][0]
        game_interest_name = "Overwatch"
    elif index == 7:
        sql = "SELECT interest_id, name FROM interests WHERE name = 'League of Legends: Wild Rift' AND category = 'gaming'"
        mycursor.execute(sql)
        myresult = mycursor.fetchall()
        game_interest_id = myresult[0][0]
        game_interest_name = "League of Legends: Wild Rift"

    for URL in game_url:

        tournament_importance = 1
        if URL in ti2:
            tournament_importance = 2
        elif URL in ti0:
            tournament_importance = 0

     #   print("in it with url", URL, "importance is", tournament_importance, "\n\n")


        try:

            page = requests.get(URL)

            soup = BeautifulSoup(page.content, 'html.parser')
            results = soup.find_all("div", {"class": "divRow"})
            for result in results:
                # print(result)

                try:
                   # tournament_name = result.find_all("div", {"class": "divCell Tournament Header"})[0].find_all("a", href=True)
                    regex = re.compile('divCell Tournament Header.*')
                    #tn = result.find_all("div", {"class": "divCell Tournament Header"})
                    tn = result.find_all("div", {"class": regex})



                    #if len(tn) > 0:
                    #    pass


                    #else:
                    #    tn = result.find_all("div", {"class": "divCell Tournament Header-Premier"})

                   # print(tn)

                    tournament_name = tn[0].find_all("a", href=True)
                    # print(result)
                    # for t in tournament_name:
                    #     print(t)
                    # print("TOURNAMENT NAME IS\n")
                    actual_tournament_name = ""
                    tournament_url = ""


                    if len(tournament_name) == 1:
                        actual_tournament_name = tournament_name[0].text
                        tournament_url = "https://liquipedia.net" + tournament_name[0]['href']
                    else:
                        actual_tournament_name = tournament_name[1].text
                        tournament_url = "https://liquipedia.net" + tournament_name[1]['href']

                    if actual_tournament_name == "":
                        actual_tournament_name = tournament_name[2].text
                        tournament_url = "https://liquipedia.net" + tournament_name[2]['href']
                  #  print("Tournament:", actual_tournament_name)



                    regex2 = re.compile('divCell EventDetails Date Header.*')

                    if URL == "https://liquipedia.net/smash/Major_Tournaments/Ultimate":

                        regex2 = re.compile('divCell EventDetails-Left-55 Header.*')
                        tournament_date = result.find_all("div", {"class": regex2})[0].text

                    else:
                        regex2 = re.compile('divCell EventDetails Date Header.*')
                        tournament_date = result.find_all("div", {"class": regex2})[0].text
                    # print(tournament_date)

                    dates = date_formatter(tournament_date)
                #    print("dates are", dates, "tournament_url is", tournament_url)
                    start_date = dates[0]
                    end_date = dates[1]
                except Exception as e:
                    print("in the except 1", e)
                    continue

               # print("Tournament starts on", start_date, " and ends on", end_date)

                if type(start_date) == bool:  # if date is in 2020 or otherwise invalid
                    continue

                if end_date < datetime.now():
                    pass
                else:

                    delta = end_date - start_date
                    full_time_list = []
                    for i in range(delta.days + 1):
                        day = start_date + timedelta(days=i)
                        full_time_list.append(day)

                    full_time_list_weekend = []
                    for time in full_time_list:
                        if time.weekday() in [4, 5, 6]:
                            full_time_list_weekend.append(time)

                   # print("Actual days of tournament:", full_time_list_weekend)

                    #  for t in tournament_name:
                    #      print(t)
                    # tournament_url = "https://liquipedia.net" + tournament_name[1]['href']

                    try:
                        page2 = requests.get(tournament_url)
                        soup2 = BeautifulSoup(page2.content, 'html.parser')
                        teams = soup2.find_all("div", {"class": "teamcard teamcardmix toggle-area toggle-area-1"})  # Overwatch
                        teams_list = []
                        for team in teams:
                            team_name = team.find_all("a", href=True)[0].text
                            teams_list.append(team_name)

                        if len(teams_list) == 0 or teams_list[0] == '':
                            teams = soup2.find_all("div", {"class": "teamcard toggle-area toggle-area-1"})  # League of Legends
                            for team in teams:
                                team_name = team.find_all("a", href=True)[0].text
                                teams_list.append(team_name)

                        if len(teams_list) == 0 or teams_list[0] == '':
                            teams = soup2.find_all("div", {"class": "teamcard"})  # Valorant
                            for team in teams:

                                team_name = team.find_all("a", href=True)[0].text

                                if team_name == '':
                                    team_name = team.find_all("a")[1].text
                                teams_list.append(team_name)

                       # print("Participating teams:", teams_list)
                        description = ""
                        if game_interest_name != "Rocket League":
                            random.shuffle(teams_list)
                            if tournament_importance == 2:
                                description = actual_tournament_name + ", a major " + game_interest_name + " tournament featuring " + teams_list[2] + ", " + teams_list[1] + ", " + teams_list[0] + ", and more!"
                            else:
                                description = actual_tournament_name + ", a " + game_interest_name + " tournament featuring " + \
                                              teams_list[2] + ", " + teams_list[1] + ", " + teams_list[
                                                  0] + ", and more!"

                        else:
                            if tournament_importance == 2:
                                description = actual_tournament_name + ", a major " + game_interest_name + " tournament featuring " + \
                                          teams_list[2] + ", " + teams_list[1] + ", " + teams_list[0] + ", and more!"
                            else:
                                description = actual_tournament_name + ", a " + game_interest_name + " tournament featuring " + \
                                              teams_list[2] + ", " + teams_list[1] + ", " + teams_list[
                                                  0] + ", and more!"


                        if len(full_time_list_weekend) < 4:
                            index = 1
                            for day in full_time_list_weekend:
                                tournament_day_date = day.strftime('%d.%m.%y')
                                new_description = "Day " + str(index) + " of " + description
                                print("Inserting", game_interest_id, new_description, "gaming", tournament_importance,
                                      tournament_day_date, game_interest_name)


                                try:
                                    sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                                    val = (game_interest_id, new_description, "gaming", tournament_importance, tournament_day_date, game_interest_name)
                                    mycursor.execute(sql, val)
                                    mydb.commit()
                                except:
                                    print("Failed to insert", new_description)

                                index += 1

                        else:

                            for day in full_time_list_weekend:
                                tournament_day_date = day.strftime('%d.%m.%y')
                                print("Inserting", game_interest_id, description, "gaming", tournament_importance, tournament_day_date, game_interest_name)
                                try:
                                    sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                                    val = (game_interest_id, description, "gaming", tournament_importance, tournament_day_date, game_interest_name)
                                    mycursor.execute(sql, val)
                                    mydb.commit()
                                except:
                                    print("Failed to insert", description)


                    except:

                        description = actual_tournament_name + ", a " + game_interest_name + " tournament"
                        if len(full_time_list_weekend) < 4:
                            index = 1
                            for day in full_time_list_weekend:
                                tournament_day_date = day.strftime('%d.%m.%y')
                                new_description = "Day " + str(index) + " of " + description
                                print("Inserting", game_interest_id, new_description, "gaming", tournament_importance, tournament_day_date, game_interest_name)


                                try:
                                    sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                                    val = (game_interest_id, new_description, "gaming", tournament_importance, tournament_day_date, game_interest_name)
                                    mycursor.execute(sql, val)
                                    mydb.commit()
                                except:
                                    print("Failed to insert", new_description)
                                index += 1
                        else:
                            for day in full_time_list_weekend:
                                tournament_day_date = day.strftime('%d.%m.%y')


                                print("Inserting", game_interest_id, description, "gaming", tournament_importance, tournament_day_date, game_interest_name)
                                try:
                                    sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                                    val = (game_interest_id, description, "gaming", tournament_importance, tournament_day_date, game_interest_name)
                                    mycursor.execute(sql, val)
                                    mydb.commit()
                                except:
                                    print("Failed to insert", description)


                     #sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                     #val = (game_interest_id, description, "gaming", tournament_importance,
                     #      tournament_day_date, game_interest_name)
                     #mycursor.execute(sql, val)


        except Exception as e:
            print("failed entirely with", URL)
            print("error was", e)

    index+=1

ignore = '''
page = requests.get(URL)

soup = BeautifulSoup(page.content, 'html.parser')
results = soup.find_all("div", {"class": "divRow"})
for result in results:
    #print(result)
    tournament_name = result.find_all("div", {"class": "divCell Tournament Header"})[0].find_all("a", href=True)

   # print(result)
   # for t in tournament_name:
   #     print(t)
    #print("TOURNAMENT NAME IS\n")
    actual_tournament_name = ""
    tournament_url = ""
    if len(tournament_name) == 1:
        actual_tournament_name = tournament_name[0].text
        tournament_url = "https://liquipedia.net" + tournament_name[0]['href']
    else:
        actual_tournament_name = tournament_name[1].text
        tournament_url = "https://liquipedia.net" + tournament_name[1]['href']

    if actual_tournament_name == "":
        actual_tournament_name = tournament_name[2].text
        tournament_url = "https://liquipedia.net" + tournament_name[2]['href']
    print("Tournament:", actual_tournament_name)


    tournament_date = result.find_all("div", {"class": "divCell EventDetails Date Header"})[0].text
    #print(tournament_date)

    dates = date_formatter(tournament_date)
    start_date = dates[0]
    end_date = dates[1]



    print("Tournament starts on", start_date, " and ends on", end_date)

    if type(start_date) == bool: # if date is in 2020 or otherwise invalid
        continue

    if end_date < datetime.now():
        pass
    else:

        delta = end_date - start_date
        full_time_list = []
        for i in range(delta.days + 1):
            day = start_date + timedelta(days=i)
            full_time_list.append(day)

        full_time_list_weekend = []
        for time in full_time_list:
            if time.weekday() in [4, 5, 6]:
                full_time_list_weekend.append(time)

        print("Actual days of tournament:", full_time_list_weekend)



      #  for t in tournament_name:
      #      print(t)
        #tournament_url = "https://liquipedia.net" + tournament_name[1]['href']
        page2 = requests.get(tournament_url)
        soup2 = BeautifulSoup(page2.content, 'html.parser')
        teams = soup2.find_all("div", {"class": "teamcard teamcardmix toggle-area toggle-area-1"}) # Overwatch
        teams_list = []
        for team in teams:
            team_name = team.find_all("a", href=True)[0].text
            teams_list.append(team_name)

        if len(teams_list) == 0 or teams_list[0] == '':
            teams = soup2.find_all("div", {"class": "teamcard toggle-area toggle-area-1"}) # League of Legends
            for team in teams:
                team_name = team.find_all("a", href=True)[0].text
                teams_list.append(team_name)

        if len(teams_list) == 0 or teams_list[0] == '':
            teams = soup2.find_all("div", {"class": "teamcard"}) # Valorant
            for team in teams:


                team_name = team.find_all("a", href=True)[0].text

                if team_name == '':
                    team_name = team.find_all("a")[1].text
                teams_list.append(team_name)



        print("Participating teams:", teams_list)
  #  print(result.find_all("div", ))


    #description =
    #game =

    #sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
    #val = (game_interest_id, description, "gaming", tournament_importance,
    #       tournament_day_date, game_interest_name)
    #mycursor.execute(sql, val)


'''