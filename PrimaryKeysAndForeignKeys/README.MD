This lesson will delve into the concept of primary and foreign keys then ending up joining them to utilize the full power of relationships. A relationship is one whereby one table has a relationship with another, an example would be a student table has a relationship with a class table. That relationship may be **one to one** where one student can have one class and the inverse. It can also be a **one to many** where one student can have multiple classes and also many students having many classes as a **many to many** relationship. The choice of a relationship is a design concern where the SQL involved won't vary much. I will be using [Microsoft SQL Server](https://www.microsoft.com/en-au/sql-server/sql-server-2019).

To lay the ground for a relationship, a primary key must be involved. A primary key is where a column/s is identifying a unique record. A primary key involves structuring the data in an index where the way that index is RDBMS dependant. An index is not covered in this article. A primary key will allow fast lookup when using a `WHERE`. Not only that, but it identifies a unique record in the table.

A foreign key is a normal column that references a primary key in another table. That is all there is to it.

A join is a construct whereby a relationship where one primary key is used to resolve foreign key relationships with other table/s. In other words, you can use it to show relationships across tables with many conditions.

### Creating tables with primary keys:
I will create Student and Class tables as follows with a primary key constraint:
```sql
CREATE TABLE Student(
	Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(32) NOT NULL
);

CREATE TABLE Class(
	Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(32) NOT NULL
);
```

Note the use of an `IDENTITY(1,1)` after the `INT` data type. It is a constraint that is not standard SQL. It automatically generates a new Id number starting from `1` then increments it by `1`. The first argument in the `IDENTITY` is the starting position of the index, the second is the increment or by how much to increment each record's Id from the last.

### Altering existing tables by adding a primary key:
Now that I have a table called `Pickle`, It does have an `Id` field that I want to make it a primary.
```sql
ALTER TABLE Pickle ADD PRIMARY KEY(Id);
```

Note it is this easy. The `Id` column is an `INT`. You cannot add an `IDENTITY` constraint by altering an existing column. You have to drop that column and then add a new column with `IDENTITY`. This is a SQL Server semantic.

Another thing is that by adding a primary key to an existing table, all the existing records must be unique on that column in value or else will fail.

### Adding foreign keys:
Will make a simple one-to-one relationship. Let's say a student can only have one class and one class can only have one student, that is a one to one. Since I have created the tables, I will just add new columns to one table. **Note here it is a design decison, I will not relate to each table from the other**. Will add the student id to the class table.
```sql
ALTER TABLE Class ADD StudentId INT UNIQUE FOREIGN KEY REFERENCES Student(Id);
```

Or for a new table like so:
```sql
CREATE TABLE Class(
	Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(32) NOT NULL,
	StudentId INT UNIQUE FOREIGN KEY REFERENCES Student(Id)
);
```

Now we can try adding new classes for the same student and will get an error because of the `UNIQUE` constraint. It makes sure that this is a true 1-to-1 relationship.

Moving on to one-to-many relationships, the `UNIQUE` keyword does not make sense and taking it out we would be able to have 1 student in many classes. That's all.

What if we want a many-to-many relationship, where many students can have many classes and vice versa, while this is the real life scenario, this is a design decison. The most effective way to tackle this with minimum data redundancy is to use a [Junction table](https://en.wikipedia.org/wiki/Associative_entity).

**Why bother with a foreign key now that we see how it works?** Becuase of the way it is used, RDBMSs have `relation` as their first word. Then let's say you just added a column without adding the constraint, how will you check for integrity. How can you be sure that a specific record exists? You would have to check right? Well the engine does that for you when adding a foreign key constraint and won't allow the insertion of non-existent record Id in the foreign table. Cool right? It gets cooler, let's say the record in the primary table got deleted, what happens now? Without a foreign key constraint nothing will happen, with it you can specify a `ON DELETE` property to say whether to delete the foreign records, set them null or other options... Now think of the power that exists!