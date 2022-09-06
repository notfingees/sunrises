from tmdbv3api import TMDb
from tmdbv3api import TV

from datetime import datetime, timedelta
from urllib.request import urlopen, Request
import re
import mysql.connector

tmdb = TMDb()
tmdb.api_key = 'FAKE_API_KEY'

mydb = mysql.connector.connect(host="localhost", user="FAKE_USER", password="FAKE_PASSWORD", database="aurora")
mycursor = mydb.cursor()

sql = "SELECT current_lft_index FROM helper"
mycursor.execute(sql)
myresult = mycursor.fetchall()
current_lft_index = myresult[0][0]

todays_date = (datetime.now()).strftime('%d.%m.%y')
tomorrows_date = (datetime.now() + timedelta(1)).strftime('%d.%m.%y')
tomorrows_date_tmdb = (datetime.now() + timedelta(1)).strftime('%Y-%m-%d')
catchup_date = (datetime.now() + timedelta(120)).strftime('%d.%m.%y')

tv = TV()
i = 1
while(True):
    shows = tv.on_the_air(i)
    if len(shows) == 0:
        break
    print("page", i)

    for show in shows:

        try:


            show_name = show.name
            show_overview = show.overview

            show_name_escaped = show_name.translate(str.maketrans({"'": r"''"}))
            show_overview_escaped = show_overview.translate(str.maketrans({"'": r"\''"}))

            if show_overview == "":
                pass
            else:

                if len(show_overview) > 400:
                    show_overview = show_overview.partition('.')[0] + '.'
                    show_overview_escaped = show_overview_escaped.partition('.')[0] + '.'

                show_details = tv.details(show.id)
                next_episode = show_details.next_episode_to_air
                print(next_episode)
                ne_release_date = next_episode.air_date
                ne_episode_number = next_episode.episode_number

                if ne_release_date == tomorrows_date_tmdb:

                    sql = "SELECT interest_id, name FROM interests WHERE name = '" + show_name_escaped + "' AND description = '" + show_overview_escaped + "'"

                    mycursor.execute(sql)
                    myresult = mycursor.fetchall()

                    print("myresult for ", show_name, myresult)

                    if len(myresult) > 0: # Show exists in database
                        interest_id = myresult[0][0]
                        interest_name = myresult[0][1]

                        if ne_episode_number == 1: # first episode in series, add look forward to catching up to and look forward to season premiere
                            description = "the season premiere of " + show_name


                            sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                            val = (interest_id, description, "entertainment", "2",
                                   tomorrows_date, interest_name)
                            mycursor.execute(sql, val)

                            sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                            val = (interest_id, "catching up on the new season of " + show_name, "entertainment", "1",
                                   catchup_date, interest_name)
                            mycursor.execute(sql, val)

                        else:
                            description = "a new episode of " + show_name

                            sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                            val = (interest_id, description, "entertainment", "2",
                                   tomorrows_date, interest_name)
                            mycursor.execute(sql, val)



                    else: # Show doesn't exist yet

                        print(show_name, "doesn't exist yet")

                        sql = "INSERT INTO interests (name, category, description, trending) VALUES (%s, %s, %s, %s)"
                        val = (show_name, "entertainment", show_overview, 0)
                        mycursor.execute(sql, val)
                        mydb.commit()

                        sql = "SELECT interest_id, name FROM interests WHERE name = '" + show_name_escaped + "' AND description = '" + show_overview_escaped + "'"
                        mycursor.execute(sql)
                        myresult = mycursor.fetchall()


                        if len(myresult) > 0:

                            print("in len(myresult) > 0")
                            interest_id = myresult[0][0]
                            interest_name = myresult[0][1]

                            # adding similarities:

                            similar = tv.similar(show.id)
                            for _s in similar:

                                in_production = tv.details(_s.id).in_production
                                if in_production:


                                    similar_name = _s.nameSkywars
                                    similar_description = _s.overview

                                    if similar_description == "":
                                        pass
                                    else:

                                        similar_name_escaped = similar_name.translate(str.maketrans({"'": r"''"}))
                                        similar_description_escaped = similar_description.translate(str.maketrans({"'": r"''"}))

                                        if len(similar_description) > 400:
                                            similar_description = similar_description.partition('.')[0] + "."
                                            similar_description_escaped = similar_description_escaped.partition('.')[0] + "."

                                        print("in similar once with", similar_name)

                                        _sql = "SELECT interest_id, name FROM interests WHERE name = '" + similar_name_escaped + "' AND description = '" + similar_description_escaped + "'"
                                        mycursor.execute(_sql)
                                        _myresult = mycursor.fetchall()

                                        if len(_myresult) > 0:  # Similar show exists in database
                                            rid = _myresult[0][0]

                                            sql = "INSERT INTO recommended_interests (interest_id, recommended_interest_id) VALUES (%s, %s)"
                                            val = (rid, interest_id)
                                            mycursor.execute(sql, val)

                                            sql = "INSERT INTO recommended_interests (interest_id, recommended_interest_id) VALUES (%s, %s)"
                                            val = (interest_id, rid)
                                            mycursor.execute(sql, val)

                                        else:

                                            sql = "INSERT INTO interests (name, category, description, trending) VALUES (%s, %s, %s, %s)"
                                            val = (similar_name, "entertainment", similar_description, 0)
                                            mycursor.execute(sql, val)
                                            mydb.commit()

                                            print("just inserted", similar_name)

                                            _sql = "SELECT interest_id, name FROM interests WHERE name = '" + similar_name_escaped + "' AND description = '" + similar_description_escaped + "'"
                                            mycursor.execute(_sql)
                                            _myresult = mycursor.fetchall()

                                            if len(_myresult) > 0:  # Similar show exists in database
                                                rid = _myresult[0][0]

                                                sql = "INSERT INTO recommended_interests (interest_id, recommended_interest_id) VALUES (%s, %s)"
                                                val = (rid, interest_id)
                                                mycursor.execute(sql, val)

                                                sql = "INSERT INTO recommended_interests (interest_id, recommended_interest_id) VALUES (%s, %s)"
                                                val = (interest_id, rid)
                                                mycursor.execute(sql, val)






                            if ne_episode_number == 1:  # first episode in series, add look forward to catching up to and look forward to season premiere
                                description = "the season premiere of " + show_name



                                sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                                val = (interest_id, description, "entertainment", "2",
                                       tomorrows_date, interest_name)
                                mycursor.execute(sql, val)

                                sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                                val = (interest_id, "catching up on the new season of " + show_name, "entertainment", "2",
                                       catchup_date, interest_name)
                                mycursor.execute(sql, val)

                            else:
                                description = "a new episode of " + show_name

                                sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                                val = (interest_id, description, "entertainment", "2",
                                       tomorrows_date, interest_name)
                                mycursor.execute(sql, val)

                        # Add when season ends too e.g. "look forward to the season finale of" - impossible?
                        # Add 'look forward to catching up on a season of ' add 16 weeks to start date






                mydb.commit()

        except:

            pass


    i = i + 1

sql = "SELECT MAX(lft_id) AS maximum FROM look_forward_to"
mycursor.execute(sql)
myresult = mycursor.fetchall()
new_current_lft_index = myresult[0][0]

total_added = int(new_current_lft_index) - int(current_lft_index)

todays_date = (datetime.now()).strftime('%d.%m.%y')
sql = "INSERT INTO uploads_log (date, script, lfts_uploaded) VALUES (%s, %s, %s)"
val = (todays_date, "get_all_tv_shows_tmdb.py", str(total_added))
mycursor.execute(sql, val)

mydb.commit()

sql = "UPDATE helper SET current_lft_index = '" + str(new_current_lft_index) + "' WHERE previous_interest_index = '0'"
mycursor.execute(sql)
mydb.commit()



