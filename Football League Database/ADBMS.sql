-- CREATING A DATABASE
Drop DATABASE Football;
CREATE DATABASE Football;


-- SELECTING THE DATABASE

USE Football;


-- CREATING TABLES
drop table users;
CREATE TABLE users (
id INTEGER PRIMARY KEY IDENTITY(1,1),
username VARCHAR(100),
password_hash VARCHAR(MAX)
);

CREATE TABLE history (
id INTEGER,
dateofchange DATETIME,
matchday INTEGER,
FOREIGN KEY (id) REFERENCES users (id)
);

CREATE TABLE Team (
Team_ID INTEGER PRIMARY KEY,
Name VARCHAR(10),
Year_Established INTEGER
);

CREATE TABLE Coach (
Coach_ID INTEGER PRIMARY KEY,
F_Name VARCHAR(20),
L_Name VARCHAR(20),
Age INTEGER,
Salary NUMERIC(8,0),
Year_Hired NUMERIC(4,0),
Team_ID INTEGER,
FOREIGN KEY (Team_ID) REFERENCES Team (Team_ID)
);

--select * from Coach;
--SELECT @@SERVERNAME
--SELECT HOST_NAME()
CREATE TABLE Player (
Player_ID INTEGER PRIMARY KEY,
F_Name VARCHAR(20),
L_Name VARCHAR(20),
Age INTEGER,
Salary NUMERIC(8,0),
Position VARCHAR(20),
Team_ID INTEGER,
FOREIGN KEY (Team_ID) REFERENCES Team (Team_ID)
);

CREATE TABLE Stadium (
Stadium_ID INTEGER PRIMARY KEY,
Team_ID INTEGER,
Name VARCHAR(15),
Location VARCHAR(15),
Stadium_Population NUMERIC(8,0),
FOREIGN KEY (Team_ID) REFERENCES Team (Team_ID)
);

CREATE TABLE Fixtures (
Matchday INTEGER IDENTITY(1,1),
Home_Team_ID INTEGER,
Home_Team VARCHAR(20),
Away_Team_ID INTEGER,
Away_Team VARCHAR(20),
PRIMARY KEY (Matchday, Home_Team_ID, Away_Team_ID),
FOREIGN KEY (Home_Team_ID) REFERENCES Team (Team_ID),
FOREIGN KEY (Away_Team_ID) REFERENCES Team (Team_ID)
);

CREATE TABLE Scores (
Matchday INTEGER,
Home_Team_ID INTEGER,
Home_Score INTEGER CHECK(Home_Score >= 0) ,
Away_Team_ID INTEGER,
Away_Score INTEGER CHECK(Away_Score >= 0),
FOREIGN KEY (Matchday, Home_Team_ID, Away_Team_ID) REFERENCES Fixtures (Matchday, Home_Team_ID, Away_Team_ID)
);

CREATE TABLE Points_Table (
Team_ID INTEGER,
Team_Name VARCHAR(20),
Points INTEGER,
FOREIGN KEY (Team_ID) REFERENCES Team (Team_ID)
);


-- CREATING A TRIGGER ON FIXTURES TABLE

CREATE TRIGGER Fixtures_Trigger
ON Team
AFTER INSERT
AS
DELETE FROM Fixtures
DBCC CHECKIDENT ('Fixtures', RESEED, 1);
INSERT INTO Fixtures
SELECT T1.Team_ID AS Home_Team_ID, T1.Name AS Home_Team, T2.Team_ID As Away_Team_ID, T2.Name AS Away_Team
FROM Team AS T1
CROSS JOIN Team AS T2
WHERE T1.Name <> T2.Name;



-- CREATING PROCEDURE FOR UPDATING SCORE

CREATE PROCEDURE Update_Score @MATCHDAY INTEGER, @HOME_ID INTEGER, @HOME INTEGER, @AWAY_ID INTEGER, @AWAY INTEGER
AS
IF @HOME > @AWAY
BEGIN
UPDATE Points_Table
SET Points = Points + 3
WHERE Team_ID = @HOME_ID;
END

IF @HOME < @AWAY
BEGIN
UPDATE Points_Table
SET Points = Points + 3
WHERE Team_ID = @AWAY_ID;
END

IF @HOME = @AWAY
BEGIN
UPDATE Points_Table
SET Points = Points + 1
WHERE Team_ID = @HOME_ID;
UPDATE Points_Table
SET Points = Points + 1
WHERE Team_ID = @AWAY_ID;
END

INSERT INTO Scores VALUES (@MATCHDAY, @HOME_ID, @HOME, @AWAY_ID, @AWAY)

RETURN SCOPE_IDENTITY();



--Create Procedure for changing score

CREATE PROCEDURE Edit_Score @MATCHDAY INTEGER, @HOME_ID INTEGER, @HOME INTEGER, @AWAY_ID INTEGER, @AWAY INTEGER
AS
DECLARE @homescore INT;
DECLARE @awayscore INT;
SELECT @homescore = Home_Score FROM Scores WHERE Matchday = @MATCHDAY;
SELECT @awayscore = Away_Score FROM Scores where Matchday = @MATCHDAY;

IF @homescore > @awayscore
BEGIN
UPDATE Points_Table
SET Points = Points - 3
WHERE Team_ID = @HOME_ID;
END

IF @homescore < @awayscore
BEGIN
UPDATE Points_Table
SET Points = Points - 3
WHERE Team_ID = @AWAY_ID;
END

IF @homescore = @awayscore
BEGIN
UPDATE Points_Table
SET Points = Points - 1
WHERE Team_ID = @HOME_ID;
UPDATE Points_Table
SET Points = Points - 1
WHERE Team_ID = @AWAY_ID;
END

DELETE FROM Scores WHERE Matchday = @MATCHDAY;
EXEC Update_Score @MATCHDAY,@HOME_ID,@HOME,@AWAY_ID,@AWAY;
RETURN SCOPE_IDENTITY();


-- INSERT STATEMENTS


INSERT INTO Team VALUES (1001, 'Arsenal', 1886), (1002, 'Man City', 1880), (1003, 'Liverpool', 1892), (1004, 'Man United', 1878);

INSERT INTO Coach VALUES (2001,'Mikel', 'Arteta', 45, 64000, 2019, 1001);
INSERT INTO Coach VALUES (2002, 'Pep', 'Guardiola', 47, 75300, 2016, 1002);
INSERT INTO Coach VALUES (2003, 'Jurgen', 'Klopp', 50, 80000, 2015, 1003);
INSERT INTO Coach VALUES (2004, 'Ole', 'Gunnar Solskjaer', 55, 95000, 2016, 1004);

INSERT INTO Player VALUES (3001, 'Hector', 'Bellerin', 23, 58000, 'Defender', 1001);
INSERT INTO Player VALUES (3002, 'Greanit', 'Xhaka', 27, 68000, 'Midfielder',1001);
INSERT INTO Player VALUES (3003, 'Mezut', 'Ozil', 29, 98000, 'Midfielder', 1001);
INSERT INTO Player VALUES (3004, 'Pierre', 'Aubameyang', 27, 89000, 'Forward', 1001);
INSERT INTO Player VALUES (3005, 'Bernd', 'Leno', 35, 95000, 'Goalkeeper', 1001);
INSERT INTO Player VALUES (3006, 'Aymeric', 'Laporte', 27, 60000, 'Defender', 1002);
INSERT INTO Player VALUES (3007, 'Kevin', 'De Bruyne', 26, 80000, 'Midfielder', 1002);
INSERT INTO Player VALUES (3008, 'Bernardo', 'Silva', 32, 78000, 'Midfielder', 1002);
INSERT INTO Player VALUES (3009, 'Sergio', 'Aguero', 29, 87000, 'Forward', 1002);
INSERT INTO Player VALUES (3010, 'Ederson', 'Moraes', 24, 82000, 'Goalkeeper', 1002);
INSERT INTO Player VALUES (3011, 'Virgil', 'Van Dijk', 26, 90000, 'Defender', 1003);
INSERT INTO Player VALUES (3012, 'Alex', 'Chamberlin', 24, 66000, 'Midfielder', 1003);
INSERT INTO Player VALUES (3013, 'Thiago', 'Alcantara', 29, 82000, 'Midfielder', 1003);
INSERT INTO Player VALUES (3014, 'Mohammed', 'Salah', 25, 74000, 'Forward', 1003);
INSERT INTO Player VALUES (3015, 'Allison', 'Becker', 24, 81000, 'Goalkeeper', 1003);
INSERT INTO Player VALUES (3016, 'Luke', 'Shaw', 32, 90000, 'Defender', 1004);
INSERT INTO Player VALUES (3017, 'Paul', 'Pogba', 25, 99000, 'Midfielder', 1004);
INSERT INTO Player VALUES (3018, 'Marcus', 'Rashford', 29, 85000, 'Midfielder', 1004);
INSERT INTO Player VALUES (3019, 'Jesse', 'Lingard', 25, 65000,'Forward', 1004);
INSERT INTO Player VALUES (3020, 'David', 'De Gea', 27, 82000, 'Goalkeeper', 1004);

INSERT INTO Stadium VALUES (4001, 1001, 'Emirates', 'London', 40000);
INSERT INTO Stadium VALUES (4002, 1002, 'Etihad', 'Manchester', 50000);
INSERT INTO Stadium VALUES (4003, 1003, 'Anfield', 'Liverpool', 60000);
INSERT INTO Stadium VALUES (4004, 1004, 'Old Trafford', 'Manchester', 70000);

INSERT INTO Points_Table (Team_ID, Team_Name, Points)
VALUES (1001, 'Arsenal', 0), (1002, 'Man City', 0), (1003, 'Liverpool', 0), (1004, 'Man United', 0);


-- to be done through front end application


select * from Points_Table;
EXEC Edit_Score 1,1002,0,1001,6;

EXEC Update_Score 1,1002,2,1001,0;
EXEC Update_Score 2,1003,0,1001,4;
EXEC Update_Score 3,1004,2,1001,6;
EXEC Update_Score 4,1001,1,1002,0;
EXEC Update_Score 5,1003,2,1002,2;
EXEC Update_Score 6,1004,2,1002,4;
EXEC Update_Score 7,1001,6,1003,0;
EXEC Update_Score 8,1002,2,1003,2;
EXEC Update_Score 9,1004,6,1003,6;
EXEC Update_Score 10,1001,1,1004,0;
EXEC Update_Score 11,1002,2,1004,5;
EXEC Update_Score 12,1003,2,1004,2;


-- SELECT STATEMENT FOR VIEWING TABLES

SELECT *
FROM Team;

SELECT *
FROM Coach;

SELECT *
FROM Player;

SELECT *
FROM Stadium;

SELECT *
FROM Fixtures;

SELECT *
FROM Scores;

SELECT *
FROM Points_Table
ORDER BY Points DESC;


-- CREATING LOGIN

CREATE LOGIN Developer_Login WITH PASSWORD = 'Ashish@12345';

CREATE LOGIN User_Login WITH PASSWORD = 'Kabir@12345';

CREATE LOGIN Admin_Login WITH PASSWORD = 'Param@12345';


-- CREATING USERS

CREATE USER Developer FOR LOGIN Developer_Login;

CREATE USER End_User FOR LOGIN User_Login;

CREATE USER Admin_1 FOR LOGIN Admin_Login;


-- CREATING VIEWS FOR DEVELOPER

CREATE VIEW Dev_Fixtures_View AS
SELECT *
FROM Fixtures;

CREATE VIEW Dev_Score_View AS
SELECT *
FROM Scores;

CREATE VIEW Dev_Points_View AS
SELECT TOP 20 Team_ID, Team_Name, Points
FROM Points_Table
ORDER BY Points DESC;

CREATE VIEW Dev_Team_View AS
SELECT *
FROM Team;

CREATE VIEW Dev_Player_View AS
SELECT *
FROM Player;

CREATE VIEW Dev_Coach_View AS
SELECT *
FROM Coach;

CREATE VIEW Dev_Stadium_View AS
SELECT *
FROM Stadium;


-- SELECTING VIEWS FOR DEVELOPER

SELECT *
FROM Dev_Fixtures_View;

SELECT *
FROM Dev_Score_View;

SELECT *
FROM Dev_Points_View;

SELECT *
FROM Dev_Team_View;

SELECT *
FROM Dev_Player_View;

SELECT *
FROM Dev_Coach_View;

SELECT *
FROM Dev_Stadium_View;


-- CREATING VIEWS FOR END USER

CREATE VIEW User_Fixtures_View AS
SELECT Matchday, Home_Team, Away_Team
FROM Fixtures;

CREATE VIEW User_Points_View AS
SELECT TOP 20 Team_Name, Points
FROM Points_Table
ORDER BY Points DESC;

CREATE VIEW User_Team_View AS
SELECT Name, Year_Established
FROM Team;

CREATE VIEW User_Player_View AS
SELECT F_Name, L_Name, Age, Positon
FROM Player;

CREATE VIEW User_Coach_View AS
SELECT F_Name, L_Name, Age, Year_Hired
FROM Coach;

CREATE VIEW User_Stadium_View AS
SELECT Name, Location, Stadium_Population
FROM Stadium;


-- SELECTING VIEWS FOR END USER

SELECT *
FROM User_Fixtures_View;

SELECT *
FROM User_Points_View;

SELECT *
FROM User_Team_View;

SELECT *
FROM User_Player_View;

SELECT *
FROM User_Coach_View;

SELECT *
FROM User_Stadium_View;


-- GRANT FOR DEVELOPER

GRANT SELECT ON Dev_Fixtures_View TO Developer;
GRANT SELECT ON Dev_Score_View TO Developer;
GRANT SELECT ON Dev_Points_View TO Developer;
GRANT SELECT ON Dev_Stadium_View TO Developer;
GRANT SELECT ON Dev_Team_View TO Developer;
GRANT SELECT ON Dev_Player_View TO Developer;
GRANT SELECT ON Dev_Coach_View TO Developer;
GRANT EXECUTE ON Update_Score TO Developer;


-- GRANT FOR END USERS

GRANT SELECT ON User_Fixtures_View TO End_User;
GRANT SELECT ON User_Points_View TO End_User;
GRANT SELECT ON User_Stadium_View TO End_User;
GRANT SELECT ON User_Team_View TO End_User;
GRANT SELECT ON User_Coach_View TO End_User;
GRANT SELECT ON User_Player_View TO End_User;


-- GRANT FOR ADMIN

GRANT ALL TO Admin_1;
