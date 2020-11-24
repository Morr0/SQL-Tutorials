So as you progress in SQL you need to build more and more complex scripts. Maybe you want to make a function that checks for forbidden words stored in a table before an insert/update operation. You may do that in the backend program or you may do it in your RDBMS engine. I will be using [SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-2019) for this article, the concepts carry on to different RDBMSs but syntax may differ. This article does not delve into design decisions, it is basically a SQL tutorial.

Since SQL is a programming language, it carries with it conditionals and functions, those include if/else statements and switch statements. loops do exists however they will not be covered here. What makes SQL different is the fact that the engine does the how, and you just do the what. That is, you say what you want with some procedural elements mentioned above (conditonals, loops and functions for code reuse and efficiency).

This article will cover functions and user-defined-functions (UDFs) then will go into conditionals and how you can use them then into views and what interesting things can views do that you may not know about.

### Functions:
A function is a set steps that are called as one unit. Functions can call other functions or themselves recursively. SQL server provides many types of functions found here: https://docs.microsoft.com/en-us/sql/t-sql/functions/functions?view=sql-server-ver15. Some of which are what is called a **deterministic** and others are **non-deterministic**. The difference is the predictability, that is, a deterministic function expects for a certain passed in value, it will have the same output every single item while a non-deterministic one is where a different output is returned every single item such a random number function as `RAND()` in SQL which you can call like below to fetch a random number:
```sql
SELECT RAND();
```

This will return a different value anytime is called.

A more useful function is when I want to know the count of a table (how many records do exist):
```sql
SELECT COUNT(*) AS 'No. of students' FROM Student;
```

Note how I used the `*` as a parameter for the function, in this case I passed in which columns to count, since each record holds all the columns, `COUNT()` does not worry about the given argument in this case. A reference of this function is here: https://docs.microsoft.com/en-us/sql/t-sql/functions/count-transact-sql?view=sql-server-ver15.

A more interesting function is the `AVG()` which computes an average of given values:
```sql
CREATE TABLE Numbers(
	Number INT NOT NULL
);

INSERT INTO Numbers VALUES(RAND() * 1000);
INSERT INTO Numbers VALUES(RAND() * 1000);
INSERT INTO Numbers VALUES(RAND() * 1000);
INSERT INTO Numbers VALUES(RAND() * 1000);
INSERT INTO Numbers VALUES(RAND() * 1000);
INSERT INTO Numbers VALUES(RAND() * 1000);

SELECT AVG(Number) FROM Numbers;
```

Here I call `RAND()` as a parameters timed by 1000 due to `RAND()` generating small decimals. The `AVG()` takes in the column we want to average over and averages it by going through all values.

Now I want to make a report of my numbers, I want the minimum, maximum and average, how will do that, you can build your own function for that but T-SQL has built-in functions for those operations as follows:
```sql
SELECT AVG(Number) AS Average, MIN(Number) AS Minimum, MAX(Number) As Maximum FROM Numbers;
```

### User Defined Functions (UDFs):
Creating your own function is simple as follows:
```sql
CREATE FUNCTION REPORT(@Number AS INT)
RETURNS INT
AS
BEGIN

RETURN @Number * 10

END;
```

Here I made a function that takes in an int and multiplies by and then is returned. Note the use of `@` sign, this is to show that the identifier after the sign is a variable name. In this case the variable name is an argument of a function. You can have more than one argument. Then there is the `RETURNS` which indicates the return value type. A function can return normal data types (scalar values) or a table. A table is the same thing returned by `SELECT`. Multiple lines can be within the function (between the `BEGIN` and `END`) but the last statement is to be a `RETURN` to return to the caller.

Now that we have made a function, how would I go about calling it?
```sql
SELECT dbo.REPORT(10);
```

That's it. The `dbo` is the [schema](https://docs.microsoft.com/en-us/sql/relational-databases/security/authentication-access/create-a-database-schema?view=sql-server-ver15).

Note that this function is called for every loop in a `SELECT`, that is for every value if we are going to use it on a table/s as below:
```sql
SELECT dbo.REPORT(Number) FROM Numbers;
```

However you notice now in this case, the amount of records is proportional to the amount of records including `WHERE` conditions if any. Why is that? Why when I called in the `AVG()` I only got back one record? Those `AVG()`, `MIN()` and others of this type are called [Aggregate functions](https://docs.microsoft.com/en-us/sql/t-sql/functions/aggregate-functions-transact-sql?view=sql-server-ver15). Not all built-in functions are aggregate.

To create an aggregate function in SQL Server is different to other RDBMS, in SQL Server, it requires the use of [CLR](https://docs.microsoft.com/en-us/dotnet/standard/clr) assemblies which are [.NET](https://docs.microsoft.com/en-us/dotnet/core/dotnet-five) specific constructs.

Now I want to delete the function as follows:
```sql
DROP FUNCTION dbo.REPORT;
```

Now you might say that is all nice, any drawbacks to using functions. Well the answer is yeah, there exists some things that are not allowed within functions. The first thing is that those functions are not supposed to be mutating data in any shape or form. In other words, you cannot insert/update/delete. Since they are used for `SELECT` calls, they were made to adhere to the [Single Responsibility Principle](https://en.wikipedia.org/wiki/Single-responsibility_principle) as well as for code reuse adhering to [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself). Moreover, UDFs cannot call non-deterministic functions nor can they call stored procedures which are another SQL construct similar to functions but on a grander scale.

### If statements:
To use if statements, you can use them outside 