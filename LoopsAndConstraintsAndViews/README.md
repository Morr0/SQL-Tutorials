
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
`PRIMARY KEY` is an example of a constraint, a constraint is basically a feature to column. This specific constraint makes a column the primary key of a table. Others do exist. The list is:
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

Now I present an interesting use, more often than not when designing your system evolves with time and so you may want to add a new constraint. Adding a new constraint will involve applying it to all existing records, it will not add it when the predicate falls and an error is the result. You can either store the old data in another table or use the `NOCHECK` keyword.
```sql
CREATE TABLE Numbers(
	Number INT
);

-- Insert some

ALTER TABLE Numbers WITH NOCHECK ADD CONSTRAINT Condition CHECK(Number >= 100);
```

Note the `WITH NOCHECK` was placed at the front of the constraint due to SQL Server syntax however for you RDBMS it may be different. The same way `NOCHECK` was used, you can easily use `CHECK`. Although `CHECK` is the default on my system, you can configure it depending on the RDBMS.