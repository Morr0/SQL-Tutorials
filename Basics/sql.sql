CREATE DATABASE LearningDB;

USE LearningDB;

CREATE TABLE Student(
    Name VARCHAR(32) NOT NULL,
    Age  TINYINT NOT NULL,
    Nickname VARCHAR NULL
);

SELECT * FROM "Student";

INSERT INTO "Student" VALUES ('John Doe', 12, 'Jo');
INSERT INTO "Student"(Name, Age) VALUES ('John Bay', 12);
INSERT INTO "Student"(Name, Age) VALUES ('Bill Wick', 13);

SELECT * FROM "Student";

SELECT Name, Age FROM "Student";

-- This will cause an error due to the age being null
INSERT INTO "Student"(Name) VALUES ('Mike');

-- This is a comment

SELECT * FROM "Student" WHERE Age = 12;

SELECT * FROM "Student" WHERE Age = 12 AND Nickname IS NOT NULL;

DELETE FROM "Student";
SELECT * FROM "Student";

-- Reinsert from above and then delete where age is 12
DELETE FROM "Student" WHERE Age = 12;

-- This does nothing even though there is no age 3 inserted
DELETE FROM "Student" WHERE Age = 3;