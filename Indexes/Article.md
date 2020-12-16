```sql
CREATE TABLE Student(
	Id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	FirstName CHAR(32),
	LastName CHAR(32),
	LastMark INT,
);
```
The primary key above has an index. This index is where all the table's data is stored. It is also called a **clustered index**. Due to it's name, it means that all data in one cluster. Now imagine you want to fetch the table for a particular `Id`, you can have a full table scan by going through each record which is fine for a small table of around 1000 records or less however is unbearable over that. If the element you were looking for was the first then you got lucky but the worst case the element your looking for will be the last. So this scanning from the start to the end is called a **forward** scan and is one option of scanning data. Obviously full table scans are not favored ever however sometimes they maybe the best query determined by the RDBMS.

Now even though this is a forward table scan it is really a forward clustered index scan, the reason being we have an index `Id`. Now we can do it backwards easily by the following:
```sql
SELECT * FROM Student WHERE LastMark = 100 ORDER BY Id DESC;
```

It may take some due to scanning each record. Making it forward scan may or may not help. My point is that the user of the database 99% of the time does not know if the record is closer to the end, to the front or in the middle. The best assumption here is in the middle.

Now let's see the size of the table to see how the bigger the clustered index maybe or the mor ..

https://www.c-sharpcorner.com/article/calculate-data-row-space-usage-in-sql-server/