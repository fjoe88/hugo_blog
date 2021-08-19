---
title: '[Python|SQL] Using Python context managers + sqlite3? Python contextlib module
  can offer some help.'
author: zhoufang
date: '2021-08-19'
slug: python-sql-using-python-context-managers-sqlite3-python-contextlib-module-can-offer-some-help
categories:
  - Python
  - SQL
tags:
  - python
  - sqlite
  - sqlite3
  - contextlib
  - context managers
description: ~
featured_image: ~
---

**Context managers** allow one to allocate and release resources precisely when needed. The most widely used example of context managers is the `with` statement. The below code opens the file, writes some data to it and then closes it. If an error occurs while writing the data to the file, it tries to close it. 

```Python
# Use context manager
with open('ciao.txt', 'w') as text_file:
    text_file.write('Ciao!')
```

The above code is equivalent to:

```Python
file = open('ciao.txt', 'w')
try:
    file.write('Ciao!')
finally:
    file.close()
```

The main issue with the above code is that there's a real possibility that while executing the lines in between opening and closing of the file, an error could be raised, and as a result the file is not being properly closed and data could get corrupted that may leads to bigger issues. One way to tackle the problem is to write a try-except block and try catch the error while having the ability to close the file explicitly, but using context-manager will be a cleaner and more 'Pythonic' way to go at this problem - the `with` statement takes care of the closing of the file without one explicitly writing such.

Python **sqlite3** module provides access to the most deployed database engine in the world - SQLite . A simple workflow example to get started with using sqlite3 can go as follows (here I am using nba_api module to pull players data and write to a local SQLite database)

```Python
import pandas as pd
import sqlite3
from nba_api.stats.static import players

players_dict = players.get_players()

# establish connection and create the database
conn = sqlite3.connect('./db/static.db')

# execute SQL query commands to write to database
pd.DataFrame(players_dict).to_sql('players', conn, if_exists='replace', index=False)

# execute SQL query commands to read from database
pd.read_sql('select * from players', conn)

# closing connection
conn.close()

# Returns an error since now that the connection is closed 
# 'ProgrammingError: Cannot operate on a closed database'.
pd.read_sql('select * from players', conn)
```

Now, following the same logic we can obviously try use context-manager together with sqlite3 module to create database, establish connection, execute query and close out the connection. Following the [official document](https://docs.python.org/2/library/sqlite3.html#using-the-connection-as-a-context-manager) we can use the connection as a context manager and write as follows:

```Python
with sqlite3.connect('./db/static.db') as conn:
  pd.DataFrame(players_dict).to_sql('players', conn, if_exists='replace', index=False)

# connection is not closed - we can still read from the database!
pd.read_sql('select * from players', conn)
```

I was not expecting this behavior and did some research online where I found some people pointing out the same issue - where the context manager unexpectedly did not close the connection and left it open.

Fortunately, the standard python library includes [contextlib](https://docs.python.org/3/library/contextlib.html) module that provides utilities for common tasks involving the `with` statement, in which the `contextlib.closing` method is exactly what we are looking for.

> ...`contextlib.closing(thing)` return a context manager that closes thing upon completion of the block.

That is equivalent to:

```python

from contextlib import contextmanager

@contextmanager
def closing(thing):
    try:
        yield thing
    finally:
        thing.close()
        
```

Now, instead of using `sqlite3.connect` we will be using `contextlib.closing` to generate our context-manager.

```python

with closing(sqlite3.connect('./db/static.db')) as conn:
  pd.DataFrame(players_dict).to_sql('players', conn, if_exists='replace', index=False)
  
# sqlite3.ProgrammingError: Cannot operate on a closed database.
pd.read_sql('select * from players', conn)
```

Now that outside of the `with` statement block we have our database connection being properly closed.

On a side note, I found the above way using `pandas.DataFrame.to_sql(df)` a much simpler approach, if one is to use `sqlite3` module alone, he/she should be aware that sqlite3 module implicitly opens a transaction before every SQL statements such as INSERT, UPDATE, DELETE, REPLACE, and it automatically commits before a non-query statement, e.g. CREATE TABLE. This allows the database to be isolated from any exceptions and error that could be raised during insertion of data, but one should always remember to commit changes through `db.commit()`, ommiting it would results in all the changes being rolled back at `db.close()` and have data be lost since the user did not commit the data. Example as below:

```python
db = sqlite3.connect('static.db')

db.execute("CREATE TABLE IF NOT EXISTS players(id int, data text)")
db.execute("INSERT INTO players(id, data) VALUES(1, 'Lebron James')")
# db.commit()
db.close()

db = sqlite3.connect('static.db')

# returns an empty list - data insertion was rolled back since user did not call db.commit method
db.execute("SELECT * FROM players").fetchall()
db.close()
```



