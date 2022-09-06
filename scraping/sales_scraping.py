from bs4 import BeautifulSoup
import requests
from multiprocessing import Process, Value
from datetime import datetime, timedelta
import mysql.connector

mydb = mysql.connector.connect(host="localhost", user="FAKE_USER", password="FAKE_PASSWORD", database="aurora")
mycursor = mydb.cursor()

sql = "SELECT current_lft_index FROM helper"
mycursor.execute(sql)
myresult = mycursor.fetchall()
current_lft_index = myresult[0][0]


#brlist = open("shopping_websites.txt", "r")
#lines = brlist.readlines()
headers = {"User-Agent": "Mozilla/5.0 (X11; CrOS x86_64 12871.102.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.141 Safari/537.36"}

sql = "SELECT interest_id FROM interests WHERE name = 'shopping' AND category = 'shopping'"
mycursor.execute(sql)
myresult = mycursor.fetchall()
shopping_iid = myresult[0][0]

tomorrows_date = (datetime.now() + timedelta(1)).strftime('%d.%m.%y')

def check_if_sales(link, ret_value):
    page = requests.get(link, headers=headers)
    #page = requests.get("https://www.enchantedlearning.com/wordlist/restaurant.shtml", headers=headers)
    soup = BeautifulSoup(page.text, 'html.parser')
    text = soup.get_text()
    #text = " ".join(line.strip() for line in text.split("\n"))
    discounts = []
    discounts.append(0)
    for line in text.split("\n"):
        if line != "":
            if "%" in line:
                split = line.split('%')[0]
                length = len(split)
                #print(split)
                #print(split[length-1])
                discount_string = split[length-2] + split[length-1]
                if discount_string.isdigit():
                    discount = int(discount_string)
                    discounts.append(discount)
                #print(line)

            #if "%" in line or "sale" in line.lower() or "discount" in line.lower() or "promotion" in line.lower() or "off" in line.lower():
            #    print(line)

    print("in check_if_sales", link, max(discounts))
    ret_value.value = max(discounts)
    #return max(discounts)

def sanitize(item):
    return item.translate(str.maketrans({"'": r"''"}))

with open("/home/bitnami/python/shopping_websites.txt") as links, open("/home/bitnami/python/shopping_names.txt") as names:
    for x, y in zip(links, names):
        x = x.strip()
        y = y.strip()
        link = sanitize(x)
        name = sanitize(y)

        significance = 0
        discount_percent = 0
        succeeded = False

        try:
            ret_value = Value("d", 0.0, lock=False)
            p1 = Process(target=check_if_sales, args=(x, ret_value))
            p1.start()
            p1.join(timeout=3)
            p1.terminate()

            if p1.exitcode is None:
                print("p1.exitCode is None, failed with", x)
                pass
            else:
                if ret_value.value > 0:
                    succeeded = True

                    discount_percent = ret_value.value
                    if discount_percent > 39:
                        significance = 1
                    else:
                        significance = 0
                    print("OUTSIDE", x, ret_value.value)

        except Exception as e:
            print("completely failed with", x)
            print(e)

        sql = "SELECT interest_id FROM interests WHERE name = '" + name + "'"
        mycursor.execute(sql)
        myresult = mycursor.fetchall()
        iid = myresult[0][0]

        if succeeded and discount_percent < 91:

            try:

                description = "up to " + str(discount_percent) + "% off from " + y
                sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                val = (shopping_iid, description, "shopping", str(significance),
                       tomorrows_date, "shopping")
                mycursor.execute(sql, val)

            except:
                print("failed with insert 1", tomorrows_date)
            try:

                sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name) VALUES (%s, %s, %s, %s, %s, %s)"
                val = (iid, description, "shopping", str(significance),
                       tomorrows_date, y)
                mycursor.execute(sql, val)

            except:
                print('failed with insert 2', description, iid, x, y, tomorrows_date)

            mydb.commit()

ignore = '''
for line in lines: # each line is a link
    new_line = line.strip()
    try:
        ret_value = Value("d", 0.0, lock=False)
        p1 = Process(target=check_if_sales, args=(new_line, ret_value))
        p1.start()
        p1.join(timeout=3)
        p1.terminate()

        if p1.exitcode is None:
            print("failed with", new_line)
            pass
        else:
            if ret_value.value > 0:

                discount_percent = ret_value.value
                if discount_percent > 39:
                    significance = 1
                else:
                    significance = 0
                print("OUTSIDE", new_line, ret_value.value)

    except Exception as e:
        print("completely failed with", new_line)
        print(e)
'''

sql = "SELECT MAX(lft_id) AS maximum FROM look_forward_to"
mycursor.execute(sql)
myresult = mycursor.fetchall()
new_current_lft_index = myresult[0][0]

total_added = int(new_current_lft_index) - int(current_lft_index)

todays_date = (datetime.now()).strftime('%d.%m.%y')
sql = "INSERT INTO uploads_log (date, script, lfts_uploaded) VALUES (%s, %s, %s)"
val = (todays_date, "sales_scraping.py", str(total_added))
mycursor.execute(sql, val)

mydb.commit()

sql = "UPDATE helper SET current_lft_index = '" + str(new_current_lft_index) + "' WHERE previous_interest_index = '0'"
mycursor.execute(sql)
mydb.commit()