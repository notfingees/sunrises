import requests
import mysql.connector
from datetime import datetime, timedelta


#mydb = mysql.connector.connect(host="localhost", user="FAKE_USER", password="FAKE_PASSWORD", database="aurora")
mydb = mysql.connector.connect(host="127.0.0.1", user="test_user", password="test_user", database="aurora")
mycursor = mydb.cursor()

sql = "SELECT current_lft_index FROM helper"
mycursor.execute(sql)
myresult = mycursor.fetchall()
current_lft_index = myresult[0][0]

today = datetime.today()
todays_date = (datetime.now()).strftime('%d.%m.%y')
tomorrows_date = (datetime.now() + timedelta(1)).strftime('%d.%m.%y')

def get_most_recent_video(playlist_id):
    try:
        URL = "https://www.googleapis.com/youtube/v3/playlistItems?key=AIzaSyAOeoCldYRMOKpbc6rK5XP-ED_SB7ckl_I&playlistId=" + playlist_id + "&part=snippet"
        r = requests.get(url=URL)
        data = r.json()
        video = data['items'][0]['snippet']['title']
        return video
    except:
        print("get_most_recent_video failed with", playlist_id)
        return

sql = "SELECT interest_id, name, uploads_playlist_id, most_recent_video FROM youtube_helper"
mycursor.execute(sql)
myresult = mycursor.fetchall()
if len(myresult) > 0:
    for i in myresult:

        iid = i[0]
        name = i[1]
        uploads_playlist_id = i[2]
        most_recent_video = i[3]

        new_most_recent_video = get_most_recent_video(uploads_playlist_id)
        if new_most_recent_video != most_recent_video:

            try:
                desc = "a new " + name +  " Youtube video titled " + new_most_recent_video
                sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                val = (iid, desc, "entertainment", "2", todays_date, name)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "UPDATE youtube_helper SET most_recent_video = %s WHERE id = %s"
                val = (new_most_recent_video, iid)

                mycursor.execute(sql, val)

                mydb.commit()

            except:
                print("failed with", name, new_most_recent_video, "today")
            ignore = '''
            try:
                desc = "a new " + name + " Youtube video titled " + new_most_recent_video
                sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                val = (iid, desc, "entertainment", "2", tomorrows_date, name)
                mycursor.execute(sql, val)
                mydb.commit()
            except:
                print("failed with", name, new_most_recent_video, "tomorrow")
            '''


sql = "SELECT MAX(lft_id) AS maximum FROM look_forward_to"
mycursor.execute(sql)
myresult = mycursor.fetchall()
new_current_lft_index = myresult[0][0]

total_added = int(new_current_lft_index) - int(current_lft_index)

todays_date = (datetime.now()).strftime('%d.%m.%y')
sql = "INSERT INTO uploads_log (date, script, lfts_uploaded) VALUES (%s, %s, %s)"
val = (todays_date, "scrape_youtube.py", str(total_added))
mycursor.execute(sql, val)

mydb.commit()

sql = "UPDATE helper SET current_lft_index = '" + str(new_current_lft_index) + "' WHERE previous_interest_index = '0'"
mycursor.execute(sql)
mydb.commit()

