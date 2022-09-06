
# One time thing: Generate dict (interest id to lft desc) of 2-level lfts, 1 level-lfts, and 0-level lfts
# for today and tomorrow

schema = '''
Get each user 
Get each of the users interests, return as list 
Get list of recommended interests for users, return as list (no duplicates) 
For each of the users interests, check if the interest id has corresponding level-2 lft
If there are 3:
Exit, the notification is all 3 

Else:
Remember the one or two, and then check for recommended accordingly

For all recommended interests to the users interests, check if the interest id has a corresponding level-2 lft
If there are 

Check interests 2, recommended_interests 2, interests 1, recommended_interests 1, interests 0, recommended_interests 0 -
break whenever we hit 3 total and then generate the interest 

For each user (sql = 'SELECT user_id FROM users'):
    1. Get all of users interests (sql = 'SELECT interest_id FROM user_interests WHERE user_id= *user_id)
    2. Get all of recommended interests (for each of users interests, get recommended (sql = 'SELECT recommended_interest_id FROM recommended_interests WHERE interest_id= *interest_id)
    3. Probably combine them into a set or no-duplicates list or something [ALL_INTERESTS]
    4. Repeat following for today and tomorrow: For every interest in that list, check today2, today1, today0 for interests - stop at 2 if both 2-level and at 3 if not all 2-level



'''

# GENERATING LFT DICT FOR TODAY AND TOMORROW
import random
from datetime import datetime, timedelta
from urllib.request import urlopen, Request
import re
import mysql.connector

NOTIFICATION_CHAR_MAX = 150

#mydb = mysql.connector.connect(host="localhost", user="test_user", password="test_user", database="aurora", port = 8888, unix_socket='/Applications/MAMP/tmp/mysql/mysql.sock')

mydb = mysql.connector.connect(host="localhost", user="FAKE_USER", password="FAKE_PASSWORD", database="aurora")
mycursor = mydb.cursor()

todays_date = (datetime.now()).strftime('%d.%m.%y')
tomorrows_date = (datetime.now() + timedelta(1)).strftime('%d.%m.%y')
tomorrows_date_tmdb = (datetime.now() + timedelta(1)).strftime('%Y-%m-%d')
catchup_date = (datetime.now() + timedelta(120)).strftime('%d.%m.%y')
todays_date_datetime = datetime.now()

today2 = {}
today1 = {}
today0 = {}

sql = "SELECT * FROM look_forward_to WHERE date='" + todays_date + "'"

mycursor.execute(sql)
myresult = mycursor.fetchall()

def shorten_lft(lft_text):

    return_text = ""
    if "Youtube video" in lft_text:
        lft_split = lft_text.split()
        new = ""
        for word in lft_split:
            if word == "video":
                new += "video"
                break
            else:
                new += word + " "
        return_text = new
    else:
        return lft_text

    ignore = '''
    if "," in lft_text:
        lft_split = lft_text.split(",")
        return_text = lft_split[0]
    if len(return_text) <= 2:
        return_text = lft_text
        '''
    return return_text



if len(myresult) > 0:
    for lft in myresult:
        #print(lft)

        lft_desc = shorten_lft(lft[2])


        lft_importance = lft[4]
        if lft_importance == 2:
            today2[lft[0]] = lft_desc
        elif lft_importance == 1:
            today1[lft[0]] = lft_desc
        else:
            today0[lft[0]] = lft_desc

tomorrow2 = {}
tomorrow1 = {}
tomorrow0 = {}

sql = "SELECT * FROM look_forward_to WHERE date='" + tomorrows_date + "'"

mycursor.execute(sql)
myresult = mycursor.fetchall()

if len(myresult) > 0:
    for lft in myresult:
        #print(lft)
        lft_desc = shorten_lft(lft[2])

        lft_importance = lft[4]
        if lft_importance == 2:
            tomorrow2[lft[0]] = lft_desc
        elif lft_importance == 1:
            tomorrow1[lft[0]] = lft_desc
        else:
            tomorrow0[lft[0]] = lft_desc


# NOTIFICATION GENERATION

sql = "SELECT user_id FROM users"

mycursor.execute(sql)
myresult = mycursor.fetchall()

for user in myresult:
    user_id = user[0]
    actual_interests = []
    recommended_interests = []

    # = actual interest, r = recommended interest
    today2_interests_a = []
    today1_interests_a = []
    today0_interests_a = []
    today2_interests_r = []
    today1_interests_r = []
    today0_interests_r = []
    tomorrow2_interests_a = []
    tomorrow1_interests_a = []
    tomorrow0_interests_a = []
    tomorrow2_interests_r = []
    tomorrow1_interests_r = []
    tomorrow0_interests_r = []

    today_notification = ""
    tomorrow_notification = ""

    sql = "SELECT interest_id FROM user_interests WHERE user_id='" + str(user_id) + "'"
    mycursor.execute(sql)
    myresult = mycursor.fetchall()
    if len(myresult) > 0:
        for interest_id in myresult:
            if interest_id[0] in recommended_interests:
                pass
            else:
                actual_interests.append(interest_id[0])
            sql = "SELECT recommended_interest_id FROM recommended_interests WHERE interest_id='" + str(interest_id[0]) + "'"
            mycursor.execute(sql)
            myresult = mycursor.fetchall()
            if len(myresult) > 0:
                for r_iid in myresult:
                     if r_iid[0] in actual_interests:
                         pass
                     else:
                         recommended_interests.append(r_iid[0])

    # these _interests_ are acutally lfts lol my bad

    for iid in actual_interests:
        if iid in today2:
            today2_interests_a.append(today2[iid])
        if iid in today1:
            today1_interests_a.append(today1[iid])
        if iid in today0:
            today0_interests_a.append(today0[iid])
        if iid in tomorrow2:
            tomorrow2_interests_a.append(tomorrow2[iid])
        if iid in tomorrow1:
            tomorrow1_interests_a.append(tomorrow1[iid])
        if iid in tomorrow0:
            tomorrow0_interests_a.append(tomorrow0[iid])
    for iid in recommended_interests:
        if iid in today2:
            today2_interests_r.append(today2[iid])
        if iid in today1:
            today1_interests_r.append(today1[iid])
        if iid in today0:
            today0_interests_r.append(today0[iid])
        if iid in tomorrow2:
            tomorrow2_interests_r.append(tomorrow2[iid])
        if iid in tomorrow1:
            tomorrow1_interests_r.append(tomorrow1[iid])
        if iid in tomorrow0:
            tomorrow0_interests_r.append(tomorrow0[iid])

    today2_interests_a = list(set(today2_interests_a))
    today1_interests_a = list(set(today1_interests_a))
    today0_interests_a = list(set(today0_interests_a))
    today2_interests_r = list(set(today2_interests_r))
    today1_interests_r = list(set(today1_interests_r))
    today0_interests_r = list(set(today0_interests_r))

    tomorrow2_interests_a = list(set(tomorrow2_interests_a))
    tomorrow1_interests_a = list(set(tomorrow1_interests_a))
    tomorrow0_interests_a = list(set(tomorrow0_interests_a))
    tomorrow2_interests_r = list(set(tomorrow2_interests_r))
    tomorrow1_interests_r = list(set(tomorrow1_interests_r))
    tomorrow0_interests_r = list(set(tomorrow0_interests_r))

    list_of_today_lfts = [today2_interests_a, today2_interests_r, today1_interests_a, today1_interests_r, today0_interests_a, today0_interests_r]
    list_of_tomorrow_lfts = [tomorrow2_interests_a, tomorrow2_interests_r, tomorrow1_interests_a, tomorrow1_interests_r, tomorrow0_interests_a, tomorrow0_interests_r]


    c = 0
    for l in list_of_today_lfts:
        c = c + len(l)
    d = 0
    for l in list_of_tomorrow_lfts:
        d = d + len(l)

    # generating the TODAY notification

    if c == 0:
        pass
    elif c == 1:
        for l in list_of_today_lfts:
            if l:
                today_notification = today_notification + l[0]
    elif c == 2:
        for l in list_of_today_lfts:
            if len(l) == 1:
                today_notification = today_notification + l[0] + " "
            if len(l) == 2:
                today_notification = today_notification + l[0] + ", " + l[1] + ", "
    else:
        lft_descs = []

        if len(today2_interests_a) > 2:
            for lft in today2_interests_a:
                lft_descs.append(lft)
        elif len(today2_interests_r) > 2:
            for lft in today2_interests_a:
                lft_descs.append(lft)
            for lft in today2_interests_r:
                lft_descs.append(lft)
        else:
            for lfts in list_of_today_lfts:
                for lft in lfts:
                    lft_descs.append(lft)
                if len(lft_descs) > 3:
                    break

        random.shuffle(lft_descs)



        description_3_lfts = today_notification + lft_descs[0] + ", " + lft_descs[1] + ", " + lft_descs[2] + ", "
        description_2_lfts = today_notification + lft_descs[0] + ", " + lft_descs[1] + ", "

        if len(description_3_lfts) > NOTIFICATION_CHAR_MAX:
            today_notification = description_2_lfts
        else:
            today_notification = description_3_lfts

    # generating the TOMORROW notification

    if d == 0:
        pass
    elif d == 1:
        for l in list_of_tomorrow_lfts:
            if l:
                tomorrow_notification = tomorrow_notification + l[0]
    elif d == 2:
        for l in list_of_tomorrow_lfts:
            if len(l) == 1:
                tomorrow_notification = tomorrow_notification + l[0] + " "
            if len(l) == 2:
                tomorrow_notification = tomorrow_notification + l[0] + ", " + l[1] + ", "
    else:
        lft_descs = []

        if len(tomorrow2_interests_a) > 2:
            for lft in tomorrow2_interests_a:
                lft_descs.append(lft)
        elif len(tomorrow2_interests_r) > 2:
            for lft in tomorrow2_interests_a:
                lft_descs.append(lft)
            for lft in tomorrow2_interests_r:
                lft_descs.append(lft)
        else:
            for lfts in list_of_tomorrow_lfts:
                for lft in lfts:
                    lft_descs.append(lft)
                if len(lft_descs) > 3:
                    break

        random.shuffle(lft_descs)

        description_3_lfts = tomorrow_notification + lft_descs[0] + ", " + lft_descs[1] + ", " + lft_descs[2] + ", "
        description_2_lfts = tomorrow_notification + lft_descs[0] + ", " + lft_descs[1] + ", "

        if len(description_3_lfts) > NOTIFICATION_CHAR_MAX:
            tomorrow_notification = description_2_lfts
        else:
            tomorrow_notification = description_3_lfts

    today_notification += "and more!"
    tomorrow_notification += "and more!"

    # upload notifications for the user to server

    if today_notification == "and more!":

        # generating notifications from default (in the case that user had no viable interests of his own)
        lft_descs = []
        if len(today2) != 0:
            for key in today2:
                lft_descs.append(today2[key])
        elif len(today1) != 0:
            for key in today1:
                lft_descs.append(today1[key])
        else:
            for key in today0:
                lft_descs.append(today0[key])
        random.shuffle(lft_descs)

        if len(lft_descs) > 2:
            description_3_lfts = "" + lft_descs[0] + ", " + lft_descs[1] + ", " + lft_descs[2] + ", and more!"
            description_2_lfts = "" + lft_descs[0] + ", " + lft_descs[1] + ", and more!"

            if len(description_3_lfts) > NOTIFICATION_CHAR_MAX:
                today_notification = description_2_lfts
            else:
                today_notification = description_3_lfts
        elif len(lft_descs) > 1:
            today_notification = "" + lft_descs[0] + ", " + lft_descs[1] + ", and more!"
        elif len(lft_descs) == 1:
            today_notification = "" + lft_descs[0] + " and more!"
        else:
            today_notification = ""


    if tomorrow_notification == "and more!":

        # generating notifications from default (in the case that user had no viable interests of his own)
        lft_descs = []
        if len(tomorrow2) != 0:
            for key in tomorrow2:
                lft_descs.append(tomorrow2[key])
        elif len(tomorrow1) != 0:
            for key in tomorrow1:
                lft_descs.append(tomorrow1[key])
        else:
            for key in tomorrow0:
                lft_descs.append(tomorrow0[key])

        random.shuffle(lft_descs)

        if len(lft_descs) > 2:
            description_3_lfts = "" + lft_descs[0] + ", " + lft_descs[1] + ", " + lft_descs[2] + ", and more!"
            description_2_lfts = "" + lft_descs[0] + ", " + lft_descs[1] + ", and more!"

            if len(description_3_lfts) > NOTIFICATION_CHAR_MAX:
                tomorrow_notification = description_2_lfts
            else:
                tomorrow_notification = description_3_lfts
        elif len(lft_descs) > 1:
            tomorrow_notification = "" + lft_descs[0] + ", " + lft_descs[1] + ", and more!"
        elif len(lft_descs) == 1:
            tomorrow_notification = "" + lft_descs[0] + " and more!"
        else:
            tomorrow_notification = ""

    if tomorrow_notification == "" or today_notification == "":
        pass
    else:
        try:
            sql = "DELETE FROM user_notifications WHERE user_id = '" + str(user_id) + "'"
            mycursor.execute(sql)
            mydb.commit()


            sql = "INSERT INTO user_notifications (user_id, today_notification, tomorrow_notification) VALUES (%s, %s, %s)"
            val = (str(user_id), today_notification, tomorrow_notification)
            mycursor.execute(sql, val)
            print("SUCCEEDED with user_id", user_id, today_notification, tomorrow_notification)
            mydb.commit()
        except Exception as e:
            print("failed with user_id", e, user_id, today_notification, tomorrow_notification)













