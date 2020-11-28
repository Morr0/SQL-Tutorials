SELECT RAND();

SELECT COUNT(*) AS 'No. of students' FROM Student;

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

SELECT AVG(Number) AS Average, MIN(Number) AS Minimum, MAX(Number) As Maximum FROM Numbers;
GO

CREATE FUNCTION REPORT(@Number AS INT)
RETURNS INT
AS
BEGIN

RETURN @Number * 10

END;
GO

SELECT dbo.REPORT(10);

SELECT dbo.REPORT(Number) FROM Numbers;

DROP FUNCTION dbo.REPORT;

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

SELECT Number, dbo.COMMENT(Number) AS 'Comment' FROM dbo.Numbers;

CREATE FUNCTION dbo.COMMENT(@number AS INT)
RETURNS CHAR(16)
AS 
BEGIN RETURN CASE
	WHEN @number < 250 THEN 'Too small'
	WHEN @number BETWEEN 250 AND 750 THEN 'In the middle'
	ELSE 'Big'
END
END