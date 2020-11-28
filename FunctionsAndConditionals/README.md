So as you progress in SQL you need to build more and more complex scripts. Maybe you want to make a function that checks for forbidden words stored in a table before an insert/update operation. You may do that in the backend program or you may do it in your RDBMS engine. I will be using [SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-2019) for this article, the concepts carry on to different RDBMSs but syntax may differ. This article does not delve into design decisions, it is basically a SQL tutorial.

Since SQL is a programming language, it carries with it conditionals and functions, those include if/else statements and switch statements. Loops do exist however they will not be covered here. What makes SQL different is the fact that the engine does the how, and you just do the what. That is, you say what you want with some procedural elements mentioned above (conditonals, loops and functions for code reuse and efficiency).

This article will cover functions and user-defined-functions (UDFs) then will go into conditionals and how you can use them.

### Functions:
A function is a set steps that are called as one unit. Functions can call other functions or themselves recursively. SQL server provides many types of functions found here: https://docs.microsoft.com/en-us/sql/t-sql/functions/functions?view=sql-server-ver15. 
Some of which are what is called a **deterministic** and others are **non-deterministic**. The difference is the predictability, that is, a deterministic function expects for a certain passed in value the same output while a non-deterministic one is where a different output is returned every single time such a random number function as `RAND()` in SQL which you can call like below to fetch a random number:
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

Here I call `RAND()` as a parameter timed by 1000 due to `RAND()` generating small decimals. The `AVG()` takes in the column we want to average over and averages it by going through all values.

Now I want to make a report of my numbers, I want the minimum, maximum and average, how will I do that, you can build your own function for that but T-SQL has built-in functions for those operations as follows:
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

Here I made a function that takes in an int and multiplies it by and then is returned. Note the use of `@` sign, this is to show that the identifier after the sign is a variable name. In this case the variable name is an argument of a function. You can have zero or more arguments. Then there is the `RETURNS` which indicates the return value type. A function can return normal data types (scalar values) or a table. A table is the same thing returned by `SELECT`. Multiple lines can be within the function (between the `BEGIN` and `END`) but the last statement is to be a `RETURN` to return to the caller.

Now that we have made a function, how would I go about calling it?
```sql
SELECT dbo.REPORT(10);
```

That's it. 

The `dbo` is the [schema](https://docs.microsoft.com/en-us/sql/relational-databases/security/authentication-access/create-a-database-schema?view=sql-server-ver15).

Note that this function is called for every loop in a `SELECT`, that is for every value if we are going to use it on a table/s as below:
```sql
SELECT dbo.REPORT(Number) FROM Numbers;
```

However you may have noticed now in this case, the amount of function calls is proportional to the amount of records including `WHERE` conditions if any. Why is that? Why when I called in the `AVG()` I only got back one record? Those `AVG()`, `MIN()` and others of this type are called [Aggregate functions](https://docs.microsoft.com/en-us/sql/t-sql/functions/aggregate-functions-transact-sql?view=sql-server-ver15). Not all built-in functions are aggregate.

To create an aggregate function in SQL Server is different to other RDBMS, in SQL Server, it requires the use of [CLR](https://docs.microsoft.com/en-us/dotnet/standard/clr) assemblies which are [.NET](https://docs.microsoft.com/en-us/dotnet/core/dotnet-five) specific constructs.

Now I want to delete the function as follows:
```sql
DROP FUNCTION dbo.REPORT;
```

Now you might say that is all nice, any drawbacks to using functions. Well the answer is yeah, there exists some things that are not allowed within functions. The first thing is that those functions are not supposed to be mutating data in any shape or form. In other words, you cannot insert/update/delete. Since they are used for `SELECT` calls which makes them **readonly**. Functions were made to adhere to the [Single Responsibility Principle](https://en.wikipedia.org/wiki/Single-responsibility_principle) as well as for code reuse adhering to [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself). Moreover, UDFs cannot call non-deterministic functions nor can they call stored procedures which are another SQL construct similar to functions but on a grander scale.

### If statements:
To use if statements, you can use them outside functions/stored procedures however their use like so is debatable. A good place is inside functions or stored procedures. Will create a function that will do some dummy logic, in this case will comment on each number.
```sql
CREATE FUNCTION dbo.COMMENT(@number AS INT)
RETURNS CHAR(16)
AS
BEGIN

DECLARE @Result CHAR(16);

IF (@number < 250)
	SET @Result = 'Too small';
ELSE IF (@number BETWEEN 250 AND 750)
	SET @Result = 'In the middle'
ELSE
	SET @Result = 'Big'

RETURN @Result;
END
```

And used as follows:
```sql
SELECT Number, dbo.COMMENT(Number) AS 'Comment' FROM dbo.Numbers;
```

Firstly, the function called `COMMENT` takes in an int and expects to return a `CHAR(16)`. It also declares a new variable bound to the function called `Result`. Now we use the if/else condituonals. An if statement first checks if number is less 250 then it will run the statement below it and then jump outside the loop. If the condition is not satisfied, will go to the else if, then check the condition, if true will execute the statement below, else go to the else statement as a last resort. Note that you can have 0 or more else ifs. Also you may have only an if statement.

The use of the `BETWEEN` clause is the same as below:
```sql
@number >= 250 AND @number <= 750
```

Note that `BETWEEN` is inclusive on both ends.

Now you could put in more logic in the function, however bear in mind this gets called for each `SELECT` iteration when used with a table. Not only that, all variables within the function block (from BEGIN to END) are different for each function.

### CASE statement:
A different way to acheive the same logic as above is by using the case statement:
```sql
CREATE FUNCTION dbo.COMMENT(@number AS INT)
RETURNS CHAR(16)
AS 
BEGIN RETURN CASE
	WHEN @number < 250 THEN 'Too small'
	WHEN @number BETWEEN 250 AND 750 THEN 'In the middle'
	ELSE 'Big'
END
END
```

The perspective here has changed. A case statement is more suited to a specific variable value than a range however T-SQL does allow for a range like the above. However, the purpose if and case statements serve is the same. If statements are more flexible all the time especially in SQL.

### Conclusion:
As SQL is a declarative language when you start learning it, when you advance you notice you need the use of a vocabulary that allows more freedom. The benefits of functions are huge generally in programming so long as you don't call them a lot. They incur some overhead that amounts to performance issues when many records are involved. An expert in SQL optimizations would be more knowledgable in such a thing as it is outside of the scope of SQL but in the scope of the specific RDBMS engine in use.

Thanks for reading through this.