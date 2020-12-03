
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