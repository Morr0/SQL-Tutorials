CREATE TABLE Student(
	Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(32) NOT NULL
);

CREATE TABLE Class(
	Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(32) NOT NULL
);

-- An example for adding a primary key constraint for when a table doesn't have
ALTER TABLE Pickle ADD PRIMARY KEY(Id);

ALTER TABLE Class ADD StudentId INT UNIQUE FOREIGN KEY REFERENCES Student(Id);
-- Or
CREATE TABLE Class(
	Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(32) NOT NULL,
	StudentId INT UNIQUE FOREIGN KEY REFERENCES Student(Id)
);

SELECT * FROM Class AS Class INNER JOIN Student ON Student.Id = Class.StudentId;

SELECT c.Id AS ClassId, c.Name AS ClassName, c.StudentId, s.Name AS StudentName FROM Class AS c INNER JOIN Student AS s ON s.Id = c.StudentId;