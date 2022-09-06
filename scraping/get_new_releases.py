# also need to find a way to update the like upcoming releases/album drops for the day before (thursday)

import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
from datetime import datetime, timedelta
from urllib.request import urlopen, Request
import re
import mysql.connector

cid = 'FAKE_CID'
secret = 'FAKE_SECRET'
client_credentials_manager = SpotifyClientCredentials(client_id=cid, client_secret=secret)
spotify = spotipy.Spotify(client_credentials_manager = client_credentials_manager)


mydb = mysql.connector.connect(host="localhost", user="FAKE_USER", password="FAKE_PASSWORD", database="aurora")
mycursor = mydb.cursor()

sql = "SELECT current_lft_index FROM helper"
mycursor.execute(sql)
myresult = mycursor.fetchall()
current_lft_index = myresult[0][0]


### FOR UPLOADING 'TODAYS' LFTS AT 12AM EST TO DATABASE
new_albums = []
for i in range(2):
    temp = spotify.new_releases(country="US", limit=10, offset=i*10)['albums']['items']
    for album in temp:
        new_albums.append(album)
    #new_albums.append(spotify.new_releases(country="US", limit=50, offset=i*50)['albums']['items']) # Need to make this so that it's like all the new releases
#print(new_albums['albums'])
print("new_albums has this many albums: ", len(new_albums))
todays_date = datetime.today().strftime('%d.%m.%y')

yesterdays_date = (datetime.now() - timedelta(1)).strftime('%d.%m.%y')

two_week_reminder = (datetime.today() + timedelta(10)).strftime('%d.%m.%y')

one_month_reminder = (datetime.today() + timedelta(27)).strftime('%d.%m.%y')


for i in new_albums:

    tempdate = i['release_date'].split("-")
    date = tempdate[2] + "." + tempdate[1] + "." + tempdate[0][2] + tempdate[0][3]

    if date != todays_date and date != yesterdays_date:
        print("PASSING", i['name'], date)
        pass

    track_name = i['name']

    print(i['name'], i['release_date'])
    for a in range(len(i['artists'])):
        artist = i['artists'][a]['name']

        sql = "SELECT interest_id FROM interests WHERE name = '" + artist + "'"
      #  val = (artist, )

        mycursor.execute(sql)

        myresult = mycursor.fetchall()

        if len(myresult) > 0:
            interest_id = myresult[0]
            description = ""
            twoweekdescription = ""
            onemonthdescription = ""
            if i['album_type'] == 'single':
                description = "listening to " + artist + "'s new single " + track_name
                twoweekdescription = "listening to " + artist + "'s recently released single " + track_name
                onemonthdescription = "catching up on " + artist + "'s recently released single " + track_name
            else:
                description = "listening to " + artist + "'s new album " + track_name
                twoweekdescription = "listening to " + artist + "'s recently released album " + track_name
                onemonthdescription = "catching up on " + artist + "'s recently released album " + track_name

            print('about to insert', description)
            try:
                sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                val = (interest_id[0], description, "music", "2", todays_date, artist)
                mycursor.execute(sql, val)
                print("just inserted", description)
            except:
                print("failed with", description)

            if i['album_type'] != 'single':
                try:

                    sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                    val = (interest_id[0], twoweekdescription, "music", "1", two_week_reminder, artist)
                    mycursor.execute(sql, val)
                except:
                    print("failed with", twoweekdescription)

                try:
                    sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                    val = (interest_id[0], onemonthdescription, "music", "0", one_month_reminder, artist)
                    mycursor.execute(sql, val)
                except:
                    print("failed with", onemonthdescription)

            # is it supposed to be interest_id[0] ? no way right



mydb.commit()
# if artist name exists in Interests, add the interest under their name to LFT
# also add it for in two weeks and in a month

sql = "SELECT MAX(lft_id) AS maximum FROM look_forward_to"
mycursor.execute(sql)
myresult = mycursor.fetchall()
new_current_lft_index = myresult[0][0]

total_added = int(new_current_lft_index) - int(current_lft_index)

todays_date = (datetime.now()).strftime('%d.%m.%y')
sql = "INSERT INTO uploads_log (date, script, lfts_uploaded) VALUES (%s, %s, %s)"
val = (todays_date, "get_new_releases.py", str(total_added))
mycursor.execute(sql, val)

mydb.commit()

sql = "UPDATE helper SET current_lft_index = '" + str(new_current_lft_index) + "' WHERE previous_interest_index = '0'"
mycursor.execute(sql)
mydb.commit()

