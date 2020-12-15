Programs start very small and then start booming. On the way of booming complexity increases and performance becomes an important consideration. While it is always possible to do all data manipulation on the backend application and leave the RDBMS just for storage. You might want to leverage RDBMS's built-in features that offer data manipulation. Network traffic is precious and in the realm of cloud it may be more precious if it was billed. 

Stored procedures are SQL programs that run in a SQL script to execute SQL code and are what Triggers use. Triggers are events that occur after something happens in the RDBMS. [SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-2019) is very flexible with triggers, SQL Server will be the RDBMS of choice in this tutorial for the code T-SQL however concepts presented here apply to other RDBMS engines and maybe the same syntax works in others. 

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

A stored procedure is way more powerful and is basically a function/method as in other programming languages.

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

The last line does not include the name of the parameter to put, because SQL infers them. You can put in the name of the parameter in case you have another variable or your order passing them differs.
```sql
EXEC dbo.FetchStudents @LastMark = 90;
```

Stored procedures support default values for parameters if you assign them one at the definition.

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

Dropping stored procedures is done same as tables `DROP PROCEDURE dbo.FetchNumberOfStudents;`.

So stored procedures were examined, you might not want to use them but wait they are extremely useful! Especially for security reasons, here is why. When you call a procedure, you don't know how is the data backed, is it from a view from a table/s or is it directly from a table? More importantly, stored procedure regard input as data not as SQL statements which is huge against SQL injection attacks. Just passing SQL statements when querying has the chance for a SQL injection because normal statements can have statements within if not validated and sanitized, in fact stored procedures can't have SQL injection because input parameters don't regard any input as statements but as data. This last point might hard to grasp and so a better explanation is here: https://security.stackexchange.com/questions/25684/how-can-i-explain-sql-injection-without-technical-jargon/25710 .

Now what? They are secure, that is nice. Something else, since they are created then they are stored in the database and so the execution plan is stored and this is huge because each time normal SQL is queried SQL has to plan an execution plan and that takes time and is expensive in the realm of lots of requests.

Now what if the table/s underlying data definition have changed, new/old indexes? The execution plan of the stored procedure is the same as before the change. This maybe problematic or not. To ensure the RDBMS uses the best available plan you can recompile the stored procedure using a system stored procedure below:
```sql
EXEC sp_recompile FetchNumberOfStudents;
```

Note `EXEC` is the same as `EXECUTE` and `PROCEDURE` is the same as `PROC`. You can also just redefine the stored procedure. Other options do exist in the RDBMS's documentation. The documentation for the above stored procedure is [here](https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-recompile-transact-sql?view=sql-server-ver15).

Another useful system procedure is when wanting to change DB object names as follows:
```sql
EXEC sp_rename FetchNumberOfStudents, 'FetchAll';
```

From the old name to the new name on the right. Here are the [docs](https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-rename-transact-sql?view=sql-server-ver15). Notice that you can also change a column/table's name this way.

Note that you can call stored procedures from stored procedures.

### Triggers:
Are just events that occur when some of the following things happens (note these things are now specific to SQL Server and may differ for your RDBMS but the concept is the same):
- `LOGON` (user logging into DB)
- DDL (Data Definition Language) on database level calls such as on `CREATE`, `ALTER`, `GRANT`(grants user permissions), `DENY`, `REVOKE` qnd `UPDATE STATISTICS`.
- DML (Data Manipulation Language) corresponding to `INSERT`, `UPDATE` and `DELETE`.

Just by looking at the range of things you can do you see how powerful triggers
are. A `FOREIGN KEY` or a `PRIMARY KEY` constraint is done as a trigger internally where after data is manipulated (refer to the 3rd item above), it is then triggered to check for condition, if condition is false will throw an error and the operation will fail else will continue to next constraints and triggers until no more defined.

So a chain of triggers is invoked once any of the events listed above occur which can cause another trigger to occur indirectly. A trigger can be fired at the start of a chain using an `INSTEAD OF` trigger or after the RDBMS does the initial checks as an `AFTER` trigger. Note that orders of a trigger matter, imagine you are making 4 triggers on the same table on the `INSERT` event, then the way these triggers are defined matters.

Triggers are just special stored procedures:
```sql
CREATE TRIGGER StudentChanged
ON Student
AFTER INSERT, DELETE
AS
BEGIN

PRINT 'Hello world';

END;
```

Here I got a trigger that fires after `INSERT` and `UPDATE`, it is an `AFTER` triggers which means gets executed after all RDBMS checks first then any other user defined triggers and this one and continues the chain if there is any other triggers left. 

Note that triggers in SQL Server capture batches not single record changes. That is if a bunch of changes occur at once and are under a trigger then they will all be called on the same trigger call and not get handled individually.

More discussion of triggers needs a flip through the [documentation](https://docs.microsoft.com/en-us/sql/t-sql/statements/create-trigger-transact-sql?view=sql-server-ver15). Triggers are a vast topic especially when moving into DDL and LOGON triggers where these cannot be implemented on an application backend and are database specific. DML triggers are a design choice.

One last thing to note is that `INSTEAD OF` types are only applicable to DML events in SQL Server.

### Conclusion
Here is where the article ends, triggers gives the sense of event-driven-development (EDD) to SQL. They are made possible due stored procedures which are what runs the data handling of many of the secure sites outthere. They can cause more complexity and confusion if not handled correctly, bugs do come out when the developer on an application doesn't know of trigger's existence.

Thanks for reading.