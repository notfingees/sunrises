# adds look forward tos for the next week (e.g. if you run it on sunday, it will start with monday
# and add all the way through next sunday
import mysql.connector
from datetime import datetime, timedelta

print("before mydb")
mydb = mysql.connector.connect(host="localhost", user="FAKE_USER", password="FAKE_PASSWORD", database="aurora")
#mydb = mysql.connector.connect(host="127.0.0.1", user="test_user", password="test_user", database="aurora")

                               #, port = 8888, unix_socket='/Applications/MAMP/tmp/mysql/mysql.sock')
mycursor = mydb.cursor()
print("after mycursor")

sql = "SELECT current_lft_index FROM helper"
mycursor.execute(sql)
myresult = mycursor.fetchall()
current_lft_index = myresult[0][0]

today = datetime.today()
next_week = []
for i in range(7):
    next_week.append(today + timedelta(days=(i+1)))
print(next_week)

next_week_weekday = []
for i in next_week:
    next_week_weekday.append(i.weekday())

next_week_strings = []
for i in next_week:
    next_week_strings.append(i.strftime('%d.%m.%y'))

number_to_day = {}
number_to_day[0] = "monday"
number_to_day[1] = "tuesday"
number_to_day[2] = "wednesday"
number_to_day[3] = "thursday"
number_to_day[4] = "friday"
number_to_day[5] = "saturday"
number_to_day[6] = "sunday"

day_index = 0
for weekday in next_week_weekday:


    sql = "SELECT id, streamer_name FROM twitch_helper WHERE " + str(number_to_day[weekday]) + "= '1'"
    mycursor.execute(sql)
    myresult = mycursor.fetchall()
    if len(myresult) > 0:
        for i in range(len(myresult)):
            streamer_id = myresult[i][0]
            streamer_name = myresult[i][1]

            desc = streamer_name + "'s Twitch stream"
            try:
                sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                val = (streamer_id, desc, "entertainment", "1", next_week_strings[day_index], streamer_name)
                mycursor.execute(sql, val)
                mydb.commit()
            except:
                print("failed with", streamer_id, desc, next_week_strings[day_index], streamer_name)

    day_index += 1

sql = "SELECT MAX(lft_id) AS maximum FROM look_forward_to"
mycursor.execute(sql)
myresult = mycursor.fetchall()
new_current_lft_index = myresult[0][0]

total_added = int(new_current_lft_index) - int(current_lft_index)

todays_date = (datetime.now()).strftime('%d.%m.%y')
sql = "INSERT INTO uploads_log (date, script, lfts_uploaded) VALUES (%s, %s, %s)"
val = (todays_date, "add_twitch_lfts.py", str(total_added))
mycursor.execute(sql, val)

mydb.commit()

sql = "UPDATE helper SET current_lft_index = '" + str(new_current_lft_index) + "' WHERE previous_interest_index = '0'"
mycursor.execute(sql)
mydb.commit()