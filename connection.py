import mysql.connector as sql


def get_connection():
    
    conn = sql.connect(
    host="localhost",
    user="root",
    password="Arshath07!!@@!!",
    database="sales_management"
    )

    return conn
