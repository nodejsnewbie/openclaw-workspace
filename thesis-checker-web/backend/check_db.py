import sqlite3
import pandas as pd

conn = sqlite3.connect('thesis_checker.db')
print("--- theses ---")
df = pd.read_sql_query("SELECT id, title, filename, file_type, status, created_at, owner_id FROM theses", conn)
print(df.to_string())
print("\nData types:")
print(df.dtypes)
conn.close()
