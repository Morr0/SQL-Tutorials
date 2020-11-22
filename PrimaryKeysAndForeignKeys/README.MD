This lesson will delve into the concept of primary and foreign keys then ending up joining them to utilize the full power of relationships. A relationship is one whereby one table has a relationship with another, an example would be a student table has a relationship with a class table. That relationship may be **one to one** where one student can have one class and the inverse. It can also be a **one to many** where one student can have multiple classes and also many students having many classes as a **many to many** relationship. The choice of a relationship is a design concern where the SQL involved won't vary much. I will be using [Microsoft SQL Server](https://www.microsoft.com/en-au/sql-server/sql-server-2019).

To lay the ground for a relationship, a primary key must be involved. A primary key is where a column/s is identifying a unique record. A primary key involves structuring the data in an index where the way that index is RDBMS dependant. An index is not covered in this article. A primary key will allow fast lookup when using a `WHERE` on it. Not only that, but it identifies a unique record in the table.

A foreign key is a normal column that references a primary key/s in another table. That is all there is to it.

A join is a construct whereby a relationship of one primary key used to resolve a foreign key relationships with other table/s. In other words, you can use it to show relationships across tables with many conditions.

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
Let's say I have a table called `Pickle`, It does have an `Id` field that I want to make it a primary key. Let's add one.
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

Moving on to one-to-many relationships, the `UNIQUE` keyword does not make sense and by taking it out we would be able to have 1 student in many classes. That's all.

What if we want a many-to-many relationship, where many students can have many classes and vice versa, while this is the real life scenario, this is a design decison. The most effective way to tackle this with minimum data redundancy is to use a [Junction table](https://en.wikipedia.org/wiki/Associative_entity).

**Why bother with a foreign key now that we see how it works?** Becuase of the way it is used, RDBMSs have `relation` as their first word. Then let's say you just added a column without adding the constraint, how will you check for integrity. How can you be sure that a specific record exists? You would have to check it right? Well the engine does that for you when adding a foreign key constraint and won't allow the insertion of non-existent record Id in the foreign table. Cool right? It gets cooler, let's say the record in the primary table got deleted, what happens now? Without a foreign key constraint nothing will happen, with it you can specify a `ON DELETE` property to say whether to delete the foreign records, set them null or other options... Now think of the power that exists!

### Joining tables:
Here's the power of relational databases, you query for multiple tables using foreign key relationships to include or exclude what you want. Let's query all classes in my 1-to-many relationship where the student id is 1:
```sql
SELECT * FROM Class AS Class INNER JOIN Student ON Student.Id = Class.StudentId;
```

If you had more students entered, notice that those who did not have a class were not displayed. This is because we used an inner join. An inner join only gets what is common to both tables. Other join types do exist, the most popular is left join (or it's opposite a right join) these also result in showing the other record per side of the join. What is the side of the join you might say? It is which table we joined, if left join then in this case would be the student else if it was a right join it would be the class table. Other joins do exist and are way less popular here: https://en.wikipedia.org/wiki/Join_(SQL).

It is basically which side of the [Venn diagram](https://en.wikipedia.org/wiki/Venn_diagram) you're querying.

Now that we've joined, if you've followed my example you would see the column `Id` repeated in the join, that is because it is displayed once for the student table and other time for the class table, what if we want to know which is which, well by naming them, it is easy as follows:
```sql
SELECT c.Id AS ClassId, c.Name AS ClassName, c.StudentId, s.Name AS StudentName FROM Class AS c INNER JOIN Student AS s ON s.Id = c.StudentId;
```

Notice here we selected what to fetch and also used the `AS` keyword. `AS` is very useful to rename a column when displaying as well as for less typing.

### Conclusion:
A great deal has been covered showing how simple constructs has been evolved to make a powerful system that is used by most of the web for data querying.

Thanks for reading through.