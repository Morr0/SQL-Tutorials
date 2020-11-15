[SQL](https://en.wikipedia.org/wiki/SQL) is the industry's standard on querying databases. It has been alive since the 1970s. It is used all throughout the software spectrum from banks to social media to small blogs. It is a standard that is adopted by relational database management systems (RDBMS) such as [Microsoft SQL Server](https://www.microsoft.com/en-au/sql-server/sql-server-2019), [MySQL](https://www.mysql.com/), [PostgreSQL](https://www.postgresql.org/) and more... Note that RDBMS don't have to use SQL but since it has been for so long, it is accepted as the standard. Other query languages exist and other database technologies exist as well. This article will be concerned with SQL using Microsoft SQL Server. The basics presented here will work on most popular systems.

Microsoft SQL Server's SQL implementation is not fully SQL standard compliant nor any other SQL RDBMS is fully compliant. This flavour is called Transact-SQL (T-SQL). It contains SQL Server specific constructs in-addition to SQL implementations.

Installing and running the server will not be the concern of this article. Installing it is walkedthrough here: https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server?view=sql-server-ver15 

I will be using the developer edition which will be limited for non-production environment. Other licenses do exist depending on your needs. The medium of which you communicate with the server is to your preference, I will use [Microsoft SSMS](https://docs.microsoft.com/en-us/sql/ssms/sql-server-management-studio-ssms?view=sql-server-ver15). You may use Visual Studio Code or your any SQL editor, even using the MS-SQL CLI is fine.

### Creating a database:
After connecting to the server, let's create the database. A **database** is a concept whereby it has one or more tables that involve relationships. An example maybe a school database where it may have a table for students, exams, roles, reports and more. Designing a database is dependent on the problem that is to be solved. 

So let's create one called `LearningDB`:
```sql
CREATE DATABASE LearningDB;
```

Now a database is created. Note the command `CREATE` is self-explanatory as well as the `DATABASE` command this is due to the nature of SQL as a **declarative** language. A **declaritive** language is one where you specify what you want and the RDBMS works towards the output, in other words you only specify what you need and the SQL engine will take care of doing it.

Now that the database is made, we cannot create another database with the same name unless it is deleted using the following command:
```sql
DROP DATABASE LearningDB;
```

Will now recreate the database. Will use it now using the following:
```sql
USE LearningDB;
```

Now we can do all database related operations here, such as creating tables.

### Creating the table:
A table is a layout of data stored. It contains columns that define data and rows that are individual records of data. A table can have one or more columns.

Let's create a student table with the following attributes:
- Name: which is the full name of a student
- Age: an age
- Nickname: nickname
  
```sql
CREATE TABLE Student(
    Name VARCHAR(32) NOT NULL,
    Age  TINYINT NOT NULL,
    Nickname VARCHAR NULL
);
```

Note the syntax, all columns of a table go within brackets, the name is the first thing then the data type to be used then any constraint then a comma for the next column. For the `Name` column, I have used A `VARCHAR(32)` Which is a variable character that can hold up to 32 [ASCII](https://en.wikipedia.org/wiki/Ascii) characters, A `NVARCHAR` May be used to hold [Unicode](https://en.wikipedia.org/wiki/Unicode) characters however a Unicode character will use 2 bytes instead of 1 byte of ASCII. Other types do exist, the discussion of which types to choose is not the concern of this article. The `NOT NULL` constraint says that one a new record is input to this column it must have a value. I Used `SMALLINT` for the `Age` column as it is capable of holding values from 0 to 255 which is enough for an age and also uses 1 byte. Notice the `Nickname` column's constraint is just `NULL`, this will default the value of this attribute to nothing if nothing is provided

A complete SQL guide and reference can be found here: https://docs.microsoft.com/en-us/sql/sql-server/?view=sql-server-ver15

### Basic operations:
Let's view the current records available (currently none):
```sql
SELECT * FROM "Student";
```

The `*` above indicates to bring all records back if any. The `SELECT` command is used for selecting specific data. While the `FROM` command specifies which table to query.

Let's now insert some stuff:
```sql
INSERT INTO "Student" VALUES ('John Doe', 12, 'Jo');
INSERT INTO "Student"(Name, Age) VALUES ('John Bay', 12);
INSERT INTO "Student"(Name, Age) VALUES ('Bill Wick', 13);
```

Here we insert 3 records to the table. The first line, we insert all 3 attributes. While the next 2 inserts, we specify after the table name within the brackets which columns to insert into. This will specify which columns are we writing to, without specifiying which columns, an error will occur since the SQL engine does not know which columns to choose by it's own unless all columns are inputted. 

Now will see what is stored using:
```sql
SELECT * FROM "Student";
```

Will display all. Let's say now I don't want to view the `Nickname` column, hence I will not select it using the below:
```sql
SELECT Name, Age FROM "Student";
```

What if I now try to only input in the `Name` column as follows:
```sql
INSERT INTO "Student"(Name) VALUES ('Mike');
```

An error will occur, saying `Age` cannot be `NULL` and so here is where the RDBMS does it's checkings.

By now we may want to comment on the code we've written, it is very easy just as below:
```sql
-- This is a comment
```

What if now that I want to list only students where their age is 12:
```sql
SELECT * FROM "Student" WHERE 'Age' = 12;
```
The `WHERE` command is like an `if` statement where you specify which value to look for over all present records.

Maybe I want all students as above as well as where they have a `Nickname`. Let's see how:
```sql
SELECT * FROM "Student" WHERE Age = 12 AND Nickname IS NOT NULL;
```

Here the `AND` keyword adds another condtion which in this case is `NOT NULL` ore in other words, has a value.

Now I want to delete everything I inserted for whatever reason:
```sql
DELETE FROM "Student";
SELECT * FROM "Student";
```

Ooh, nothing is left, it deletes everything, which is dangerous, maybe I want students with let's say of age 12. I need to first re-insert some data to then delete.
```sql
DELETE FROM "Student" WHERE Age = 12;
```

What if I delete with a condition of age 3. Nothing will happen as the database engine will look through the table until it finds it else nothing happens.

What if I want to delete the table due to a design flaw, I may be able to edit it using the `ALTER` command which is not covered in this article. The same way I deleted a database above, I will be able to delete a table just like below:
```sql
DROP TABLE Student;
```

### Conclusion:
This has been a basic look on SQL, it is a rich language that keeps evolving, multiple months of study will not fulfill the combinations of using it. Just like any other programming language, learning never stops. 

Most SQL commands are self-explanatory due to historical reasons.