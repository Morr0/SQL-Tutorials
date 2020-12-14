Programs start very small and then start booming. On the way of booming complexity increases and performance becomes an important consideration. While it is always possible to do all data manipulation on the backend application and leave the RDBMS just for storage. You might want to leverage RDBMS's built-in features that offer data manipulation. Network traffic is precious and in the realm of cloud it may be more precious if it was billed. 

Stored procedures are SQL programs that run in a SQL script to execute SQL code and are what Triggers use. Triggers are data manipulation event that occur after something happening. [SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-2019) is very flexible with triggers, SQL Server will be the RDBMS of choice in this tutorial for the code T-SQL however concepts presented here apply to other RDBMS engines and maybe the same syntax works in others. 

Just before delving in, this topic of which side of the equation handling what is not the concern of this article, it is the system designer's choice, I mean whether to use the RDBMS for data manipulation or for just storage. Often when you want to run SQL scripts over night, you may let the RDBMS manipulate it's data or you are fully invested in a different language handling all logic. It does not matter, Only the SQL syntax is presented here.

### Stored procedures:

```sql
CREATE PROCEDURE dbo.FetchStudents
AS
BEGIN
SELECT FirstName, LastName FROM Student
WHERE Attendance > 0.95;
END;
```

Note that this is a stored procedure, it can further be simplified to one statement:
```sql
CREATE PROCEDURE dbo.FetchStudents
AS
SELECT FirstName, LastName FROM Student
WHERE Attendance > 0.95;
```

It is as simple as creating a function except use the word procedure. Now imagine putting another select statement within the `BEGIN/END` block, the stored procedure once executed as below will query all select statements and return all queried.
```sql
EXECUTE dbo.FetchStudents;
```

Now a discussion of procedures is incomplete if parameters were not involved and yes you can take in parameters.
```sql
CREATE OR ALTER PROCEDURE dbo.FetchStudents 
	@LastMark INT
AS
BEGIN
SELECT FirstName, LastName FROM Student
WHERE LastMark >= @LastMark;
END;

EXECUTE dbo.FetchStudents 90;
```

The last line does not include the name of the parameter to put, because SQL supports optional parameters. You can put in the name of the parameter in case you have another variable.
```sql
EXEC dbo.FetchStudents @LastMark = 90;
```

Now will use output variables which are outputs from the code as follows:
```sql
CREATE OR ALTER PROCEDURE dbo.FetchNumberOfStudents 
	@LastMark INT = 90,
	@Output INT OUTPUT
AS
BEGIN
SET @Output = (SELECT COUNT(*) FROM Student WHERE LastMark >= @LastMark)
END;

DECLARE @Num INT;
EXEC dbo.FetchNumberOfStudents @Output = @Num OUTPUT;
PRINT @Num;
```

Here we make the `@LastMark` variable to be optional because we provided a default value and then we declared `@Output` which assigned next to be the count of the table once a condition is met. Then executing the procedure. Note when executing, I declared a variable `@Num`, this is to hold the output. Notice how the `@Output` comes first when assigning to `@Num` and also notice how the `OUTPUT` constraint is used here and up above in procedure definition. This is just how the syntax is. Multiple parameters (regardless of input or output) can be in a stored procedures up to the current limit of 2100 which is plenty.

Dropping stored procedures is done as tables `DROP PROCEDURE dbo.FetchNumberOfStudents;`.

So stored procedures were examined, you might not want to use them but wait they are extremely useful. Especially for security reasons, here is why. When you call a procedure, you don't know how is the data backed, is it from a view from a table/s or is it directly from a table? More importantly, stored procedure regard input as data not as SQL statements which is huge against SQL injection attacks. Just passing SQL statements when querying has the chance for a SQL injection because normal statements can have statements within if not validated and cleaned, in fact stored procedures can't have SQL injection because input parameters don't regard any input as statements but as data. This last point might hard to grasp and so a better explanation is here: https://security.stackexchange.com/questions/25684/how-can-i-explain-sql-injection-without-technical-jargon/25710 .

Now what? They are secure, that is nice. Something else, since they are created then they are stored in the database and so the execution plan is stored and this is huge because each time normal SQL is queried SQL has to plan an execution plan and that takes time and is expensive in the realm of lots of requests.

Now what if the table/s underlying the data have changed, new/old indexes? The execution plan of the stored procedure is the same as before the change. This maybe problematic or not. To ensure the RDBMS uses the best available plan you can recompile the stored procedure using the system stored procedure below:
```sql
EXEC sp_recompile FetchNumberOfStudents;
```

Note `EXEC` is the same as `EXECUTE` and `PROCEDURE` is the same as `PROC`. You can also just redefine the stored procedure. Other options do exist in the RDBMS's documentation. The documentation for the above stored procedure is [here](https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-recompile-transact-sql?view=sql-server-ver15).

Another useful system procedure is when wanting to change DB object names as follows:
```sql
EXEC sp_rename FetchNumberOfStudents, 'FetchAll';
```

From the old name to the new name on the right. Here are the [docs](https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-rename-transact-sql?view=sql-server-ver15).