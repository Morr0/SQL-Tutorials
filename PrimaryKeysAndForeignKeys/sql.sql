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