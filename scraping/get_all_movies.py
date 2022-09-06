from tmdbv3api import TMDb
from tmdbv3api import Movie
from tmdbv3api import Genre


from datetime import datetime, timedelta
from urllib.request import urlopen, Request
import re
import mysql.connector

tmdb = TMDb()
tmdb.api_key = 'FAKE_API_KEY'

mydb = mysql.connector.connect(host="localhost", user="FAKE_USER", password="FAKE_PASSWORD", database="aurora")
mycursor = mydb.cursor()

todays_date = (datetime.now()).strftime('%d.%m.%y')
tomorrows_date = (datetime.now() + timedelta(1)).strftime('%d.%m.%y')
tomorrows_date_tmdb = (datetime.now() + timedelta(1)).strftime('%Y-%m-%d')
catchup_date = (datetime.now() + timedelta(120)).strftime('%d.%m.%y')
todays_date_datetime = datetime.now()

sql = "SELECT current_lft_index FROM helper"
mycursor.execute(sql)
myresult = mycursor.fetchall()
current_lft_index = myresult[0][0]


g = Genre()
genres = g.movie_list()
print(genres)

def get_genre(genre_id, genres):
    for g in genres:
        if g['id'] == genre_id:
            return g['name']


'''
print("length of shows is", len(shows))
for show in shows:
    print(show.title)
    print(show.release_date)
   # print(show.genre_ids)
    genre = show.genre_ids[0]
    print(get_genre(genre, genres))
'''


sql = "SELECT interest_id FROM interests WHERE name='entertainment' and category='entertainment'"

mycursor.execute(sql)
myresult = mycursor.fetchall()

entertainment_iid = 0

if len(myresult) > 0: # Show exists in database
    entertainment_iid = myresult[0][0]
    print("entertainment_iid is", entertainment_iid)

movie = Movie()

for i in range(1):
    print("in this loop once")
    importance = 0
    if i+1 < 3:
        importance = 2
    elif i+1 < 5:
        importance = 1
    else:
        importance = 0


    shows = movie.upcoming(page=i+1)
    if len(shows) < 1:
        break
    else:


        for show in shows:

          #  print(show.title)
            print(show.release_date)
            show_release_date_datetime = datetime.strptime(show.release_date, '%Y-%m-%d')
          #  print(type(show_release_date_datetime), type(datetime.now()))


            if show_release_date_datetime > todays_date_datetime:
                # Insert
                try:

                    movie_id = show.id
                    movie_credits = movie.credits(movie_id)
                    most_popular_actor = ""
                    most_popular_votes = 0
                    second_most_popular_actor = ""
                    second_most_popular_votes = 0

                    for actor in movie_credits.cast:
                        if actor.popularity > most_popular_votes:
                            second_most_popular_actor = most_popular_actor
                            most_popular_votes = actor.popularity
                            most_popular_actor = actor.name






                    genre = get_genre(show.genre_ids[0], genres)
                    description = ""
                   # print(get_genre(genre, genres))

                    if most_popular_actor == "" and second_most_popular_actor == "":
                        description = genre.lower() + " movie " + show.title + " premiering in theaters"
                    elif second_most_popular_actor == "":
                        description = genre.lower() + " movie " + show.title + " starring " + most_popular_actor + " premiering in theaters"
                    else:
                        description = genre.lower() + " movie " + show.title + " starring " + most_popular_actor + " and " + second_most_popular_actor + " premiering in theaters"

                    #description = description.translate(str.maketrans({"'": r"''"}))
                    show_release_date_string = show_release_date_datetime.strftime('%d.%m.%y')
                    sql2 = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                    val2 = (entertainment_iid, description, "entertainment", importance,
                           show_release_date_string, "Movie Release")
                    mycursor.execute(sql2, val2)
                  #  mydb.commit()
                    print("inserted", description, show_release_date_string)
                except:
                    print("failed with", show.title)

        #print(show_release_date_datetime, datetime.now())


# Just need to add all-encompassing 'entertainment' interest and interest_id to add all movies too (movie releases are huge so)

sql = "SELECT MAX(lft_id) AS maximum FROM look_forward_to"
mycursor.execute(sql)
myresult = mycursor.fetchall()
new_current_lft_index = myresult[0][0]

total_added = int(new_current_lft_index) - int(current_lft_index)

todays_date = (datetime.now()).strftime('%d.%m.%y')
sql = "INSERT INTO uploads_log (date, script, lfts_uploaded) VALUES (%s, %s, %s)"
val = (todays_date, "get_all_movies.py", str(total_added))
mycursor.execute(sql, val)

mydb.commit()

sql = "UPDATE helper SET current_lft_index = '" + str(new_current_lft_index) + "' WHERE previous_interest_index = '0'"
mycursor.execute(sql)
mydb.commit()
