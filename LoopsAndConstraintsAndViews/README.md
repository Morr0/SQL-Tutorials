So often you increase your programming IQ in SQL and you find yourself not knowing how to repeat a thing multiple times or having to create the database as the source of truth where backend programmers may bug out the application. You turn to while loops for looping and constraints and views for sources of truths. This article will use [SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-2019) for demonstration however the concepts (and maybe syntax) apply to most other RDBMS engines.

The use of while loops is not that much needed in SQL from a developer's perspective given that SQL is a language that does what is needed not how it is needed but they are useful. Contraints are constraints the same way in english, they can be applied at a table/column level and are useful for validating data. Views are the beast of the article where you can set a table for your query needs.

### The while loop:
A loop is the third construct of an algorithm following sequence and conditionals. A while loop is a type of a loop that does the same thing as any other loops including a for loop. Note that T-SQL has only a while loop. As all loops loop there is no need to have different types. 

A while loop loops until a condition is met:
```sql
DECLARE @number INT = 1;

WHILE @number <= 10
BEGIN
	PRINT @number
	SET @number = @number + 1
END
```

Here a variable `number` is declared and set to 1. Then a loop is established with a condition of `number` smaller or equal to 10. Then the usual suspects which are `BEGIN` and `END` to enclose a block. The block has the logic where I increment the number to acheive the goal of the loop. You could not increment the number and the loop will run forever.

This is all fine, what if I want to loop through each item in a table, `SELECT`'s job is just to do that. You can use a while loop to acheive such a thing however you would have to introduce multiple variables to keep track of count. [Cursors](https://docs.microsoft.com/en-us/sql/t-sql/language-elements/cursors-transact-sql?view=sql-server-ver15) exist to do such things however their use is not within this tutorial. Thus, if you need to loop through a table, the best way in my opinion is to wrap your logic in a function and call it using `SELECT`.

Now let's say I am looping using the above SQL, if a number 8 is reached I want to exit the loop how would I do that?
```sql
DECLARE @number INT = 1;

WHILE @number <= 10
BEGIN
	PRINT @number

	IF @number = 8
		BREAK;
	SET @number = @number + 1
END
```

An if statement was just used to check the condition and a `BREAK` statement broke out. Now what if this `BREAK` keyword was in a loop (inner-loop) that is in another loop (outer-loop). Then this inner-loop will break to the outer-loop and not exit both or however many that exist.

To skip to the next loop iteration is very simple. Just the use `CONTINUE` keyword.

### Constraints:
`PRIMARY KEY` is an example of a constraint, a constraint is basically a feature of a table. This specific constraint makes a column the primary key of a table. Others do exist. 
The list is:
- PRIMARY KEY
- FORIEGN KEY
- CHECK
- UNIQUE
- NULL
- NOT NULL
- DEFAULT
- INDEX
- IDENTITY (SQL Server)
  
`INDEX` will not be covered in this article. `PRIMARY KEY` and `FORIEGN KEY` have been covered in a previous article of mine: https://www.ramihikmat.net/article/2020/sql:-primary-keys-through-to-foreign-ones-then-joining-tables

The `NULL` and `NOT NULL` constraints can be easily used as follows when defining a table:
```sql
CREATE TABLE Sample(
	SampleNum BIGINT NOT NULL,
	SecondNum BIGINT NULL
);
```

The `DEFAULT` constraint adds a default value if nothing was provided as follows:
```sql
CREATE TABLE Sample(
	SampleString CHAR(20) DEFAULT 'Default Value'
);
```

The more customized constraint and beloved one, `CHECK` is basically a [predicate](https://en.wikipedia.org/wiki/Predicate_(mathematical_logic)), if not true will cause an error. It is used as follows:
```sql
CREATE TABLE Sample(
	SampleNum INT CHECK(SampleNum > 2500)
);
```

This will make sure that the column `SampleNum`'s value is greater than 2500.

A more general constraint syntax is the one below where it is not specific to any column but is table wide:
```sql
CREATE TABLE Numbers(
	Number INT,
	Number2 INT,
	CONSTRAINT PassCriteria CHECK(Number > 50 AND Number2 = 10)
);
```

Now I present an interesting use, more often than not when designing, your system evolves with time and so you may want to add a new constraint. Adding a new constraint will involve applying it to all existing records, it will not add it when the predicate falls and an error is the result. You can either store the old data in another table or use the `NOCHECK` keyword.
```sql
CREATE TABLE Numbers(
	Number INT
);

-- Insert some

ALTER TABLE Numbers WITH NOCHECK ADD CONSTRAINT Condition CHECK(Number >= 100);
```

Note the `WITH NOCHECK` was placed at the front of the constraint due to SQL Server syntax however for you RDBMS it may be different. The same way `NOCHECK` was used, you can easily use `CHECK`. Although `CHECK` is the default on my system, you can configure it depending on the RDBMS.

### Views:
Now views may seem unnecessary when delved into however they are so useful in everyday design. A view a table that is not backed by anything. What is that you might say? Well it is a virtual table. It acts and behaves the same way as a table but it's underlying data maybe from more than one table. Just think of the word [view](https://www.dictionary.com/browse/view). It is better illustrated in an example, let's say we got 2 tables, People and Animal in a fictitious city council database. I will inner join on the tables and get back people who have animals:
```sql
SELECT * FROM People AS p INNER JOIN Animal AS a ON p.AnimalId = a.Id;
```

Now this is easy enough right? Yes. Let's say that I want all people who have registered cars as well as the above where the cars are unlicensed for an animal to be inside:
```sql
SELECT * FROM People AS p 
INNER JOIN Animal AS a ON p.AnimalId = a.Id
INNER JOIN Car AS c ON p.CarId = c.Id
WHERE c.LicensedForAnimal <> a.RequiredCarLicense;
```

Now it is getting complicated to track, maybe I want to simplify it. Or maybe the backend engineer in another language who queries the database forgets to include the condition. Or even a data scientist is looking for anamolies in the city council's data, here people problems arise. Views come to rescue as follows:
```sql
CREATE VIEW PeopleWithAnimalsWhoseCarsAreNotLicensedForAnimals
AS
SELECT * FROM People AS p 
INNER JOIN Animal AS a ON p.AnimalId = a.Id
INNER JOIN Car AS c ON p.CarId = c.Id
WHERE c.LicensedForAnimal <> a.RequiredCarLicense;
```

This view is now basically a virtual table that I can query. It is a stored `SELECT` statement and has database rights. Those database rights are of importance, maybe you don't want to let developers direct access to the tables involved by using different schemes and user permissions. So a view they can query to obtain only the needed data. It all boils down to design. 

One use of views is for internal privacy, imagine an order checker in a warehouse wants to check all orders are well boxed before dispatch. A view will only be designed for him/her to see the order Id and any comments by staff. The age of the order receiver is not important to him/her. That is what a view makes possible not to ever include the age by mistake.

Querying views is done the same way as tables as well as deleting them.

Now views are not stored on disk, a more capable view is a [materialized/indexed view](https://docs.microsoft.com/en-us/sql/t-sql/statements/create-materialized-view-as-select-transact-sql?view=azure-sqldw-latest) which is a view that is it's own table. This materialized view is potentially useful for multiple SQL joins where perhaps the join is done once and persisted to table.

These kinds of decisions are the designer's keeper at night and not the concern of this article.

### Conclusion:
Software is simply the use of the same of the same things over and over again for the better or worse. 

Thanks for reading.