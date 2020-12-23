Most of the time people deal with structured data and structured data has reasons for being so. This data is typically queried regularly on the same columns most of the time and you think you can squeeze some performance out of it. Most of the time you can improve performance to levels unseen before. As structured data can be indexed and looked up like a book index has the ability to locate pages quickly based on words rather than going through the entire table each time.

This is a convincing argument for people and computers. Since less resources are used if a well indexed design is achieved however design is not the concern of this article, the basics and capabilities of SQL are presented here. The RDBMS that is used is [SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-2019) and be aware that some things covered here maybe the same concepts in other RDBMSs but have differing syntax.

### Without indexes:
So you create a table without a primary key and coast along. You then fill it up with lots of records and you see it is fast and then you fill more and more. Now you want to read something and that something maybe in the middle or the last and you notice it is taking forever even though you are filtering with an id column. Each read query is expensive because there is no structure in the way the data is stored on disk.

This is an example of a [heap table](https://docs.microsoft.com/en-us/sql/relational-databases/indexes/heaps-tables-without-clustered-indexes). There is no order, no anything advantageous for a read operation. There is one thing, you can write fast because no index is involved, you can use it to write logs. Now this is a design concern but logs should not be stored for a relational database, even though there is not much overhead, the system is not designed for logs. Other efficient means of log storage do exist that are of `O(1)` complexity in writing. 

### With indexes:

```sql
CREATE TABLE Student(
	Id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	FirstName CHAR(32),
	LastName CHAR(32),
	LastMark INT,
);
```
The primary key above has an index. This index is where all the table's data is stored. It is also called a **clustered index**. Due to it's name, it means that all data in one cluster.

Now imagine you want to fetch the table for a particular `Id`, you can have a full table scan by going through each record which is fine for a small table of around 1000 records or less however is unbearable over that. If the element you were looking for was the first then you got lucky but the worst case the element your looking for will be the last. So this scanning from the start to the end is called a **forward** scan and is one option of scanning data. Obviously full table scans are not favored ever however sometimes they maybe the best query determined by the RDBMS query planner.

```sql
SELECT * FROM Student WHERE LastMark = 100;
```

Now even though this is a forward table scan it is really a forward clustered index scan, the reason being we have an index `Id`. Now we can do it backwards easily as **backward** scan as the following:
```sql
SELECT * FROM Student WHERE LastMark = 100 ORDER BY Id DESC;
```

It may take some time due to scanning each record. Making it a forward scan may or may not help. My point is that the user of the database 99% of the time does not know if the record is closer to the end, to the front or in the middle.

The database engine does it's job by planning the best possible path of execution based on many statistics, constraints and indexes available.

### Why size of index matters:
Now let's see the size of the table to see how the bigger the clustered index maybe. Each table record has:
- Status bits
- Fixed length data
- Null bitmaps (number of NULLs in columns)
- Variable length data
  
### Indexing:
The above 4 things all correspond to one record, imagine a huge record. Just scanning the record to go to the next is a chore for the CPU. So other indexes are created just to hold a specific column/s as well as a pointer to the original record and that is way lighter. In the databases world, it does exactly the same things, it is for fast lookups. Most of the time, people don't just query the table by the primary key they may query by age, gender, date of birth and other things. So you would make an index for something that gets queired heavilly for faster performance or otherwise would cause a table scan.
```sql
CREATE NONCLUSTERED INDEX LastMarkIndex ON Student(LastMark);
```

Here an index is created, note that it is a non-clustered. There can be only one clustered index and many non-clustered indexes in SQL Server. Now it is on the `LastMark` column.

Since a non-clustered does not store the entire record, when using an index for reads, the RDBMS does a look up using the index and gets the address of the clustered record and then goes straight to the clustered record.

```sql
DROP INDEX LastMarkIndex ON Student;

CREATE NONCLUSTERED INDEX LastMarkIndex ON Student(LastMark)
INCLUDE (FirstName);
```

Now the above script first deletes an index (the syntax differs just a little bit from others `DROP`'s you have to say which table). Then we create the same index we did above except in this case I add a `Firstname` column to be stored along with this index so I don't have to look up the actual clustered index if I just need to know the `FirstName` based on the above index.

Now this seems like a nice thing, index everything. You can until you hit the hard limitations which is a lot for SQL Server. The more indexes you add the more the writes become slow. The reason is simple, every write operation needs to update all involved indexes. Even though the RDBMS optimizes this aspect to only update the needed indexes, at worst you write to all indexes when adding/deleting records.

### Filtered index:
```sql
ALTER TABLE Student ADD WasInvolvedInFight BIT DEFAULT 0;

CREATE NONCLUSTERED INDEX WasInvolvedInFightIndex ON Student(WasInvolvedInFight)
WHERE WasInvolvedInFight = 1;
```

Now we add a new column `WasInvolvedInFight` and make a new non-clustered index with a `WHERE` condition, whereby to only index the column where the value is equal to the condition. The condition can include other columns that are not indexed here. That is all a filtered index is.

### Include index:
This is a normal index that can include other columns with it, if you are certain you will lookup another column using this index then you can include it inside the index:
```sql
CREATE NONCLUSTERED INDEX WasInvolvedInFightIndex 
ON Student(WasInvolvedInFight)
INCLUDE (Id)
```

Above, instead of reading the `Id` column from the clustered record, it will be read here from the index and as such a performance improvment. Excitement does not stop there, look below you can also make an included index be **filtered**:
```sql
CREATE NONCLUSTERED INDEX WasInvolvedInFightIndex 
ON Student(WasInvolvedInFight)
INCLUDE (Id)
WHERE WasInvolvedInFight = 1 AND LastMark >= 98;
```

### Conclusion:
Now other types of indexes do exist in SQL Server such as a column store index which is a different way of storing data. These other types will not be covered in this article as their uses and applications are advanced.

Some references are (SQL Server specific):
- [Index design](https://docs.microsoft.com/en-us/sql/relational-databases/sql-server-index-design-guide?view=sql-server-ver15)
- [Heap tables](https://docs.microsoft.com/en-us/sql/relational-databases/indexes/heaps-tables-without-clustered-indexes?view=sql-server-ver15)
- [Record size](https://www.red-gate.com/simple-talk/sql/database-administration/sql-server-storage-internals-101/)


Here a great deal was covered on basics of indexes. Their use is essential in high performance relational database systems. Now how are indexes stored on disk was not covered because it is not the concern of this article nor is the same across RDBMSs.