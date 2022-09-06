import mysql.connector

mydb = mysql.connector.connect(host="127.0.0.1", user="test_user", password="test_user", database="aurora")

mycursor = mydb.cursor()
sql = "INSERT INTO uploads_log (date, script, lfts_uploaded) VALUES (%s, %s, %s)"
val = ("27.10.21", "cron_test.py", "cron_test1")
mycursor.execute(sql, val)

mydb.commit()