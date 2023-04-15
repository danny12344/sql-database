-- Answer to the 2nd Database Assignment 2019/20
--
-- CANDIDATE NUMBER: 203068
-- Please insert your candidate number in the line above.
-- Do NOT remove ANY lines of this template.


-- In each section below put your answer in a new line 
-- BELOW the corresponding comment.
-- Use ONE SQL statement ONLY per question.
-- If you don’t answer a question just leave 
-- the corresponding space blank. 
-- Anything that does not run in SQL you MUST put in comments.
-- Your code should never throw a syntax error.
-- Questions with syntax errors will receive zero marks.

-- DO NOT REMOVE ANY LINE FROM THIS FILE.

-- START OF ASSIGNMENT CODE


-- @@01
CREATE TABLE Hospital_MedicalRecord (
recNo SMALLINT UNSIGNED NOT NULL,
patient CHAR(9) NOT NULL,
doctor CHAR(9),
enteredOn DATETIME NOT NULL,
diagnosis MEDIUM TEXT(10) NOT NULL,
treatment VARCHAR(1000), PRIMARY KEY (recNo, patient), 
FOREIGN KEY (patient) REFERENCES Hospital_Patient(NINumber) ON DELETE CASCADE ON UPDATE RESTRICT, 
FOREIGN KEY (doctor) REFERENCES Hospital_Doctor(NINumber) ON UPDATE RESTRICT

);

 
-- @@02
ALTER TABLE Hospital_MedicalRecord 
ADD duration TIME;

-- @@03
UPDATE Hospital_Doctor SET salary = 0.9 * salary
WHERE FIND_IN_SET ('ear', expertise);

-- @@04
SELECT fname, lname, year(dateOfBirth) AS 'born' FROM Hospital_Patient WHERE INSTR(city, 'right') > 0 ORDER BY lname, fname ASC; 

-- @@05

SELECT NINumber, fname, lname, (weight/POWER((height/100),2)) AS 'BMI'FROM Hospital_Patient WHERE DATEDIFF(NOW(), dateOfBirth)/365.25 < 30;


-- @@06

SELECT COUNT(*) AS 'number' from Hospital_Doctor;

-- @@07

SELECT Hospital_Doctor.NINumber, Hospital_Doctor.lname, 
	(SELECT COUNT(*) FROM Hospital_CarriesOut WHERE Hospital_Doctor.NINumber = Hospital_CarriesOut.doctor AND year(Hospital_CarriesOut.startDateTime) = year(NOW())) AS operations
		FROM Hospital_Doctor;

-- @@08

SELECT doc1.NINumber, doc1.fname, doc1.lname FROM Hospital_Doctor AS doc1
WHERE doc1.mentored_by IS NULL
	AND (SELECT COUNT(*)
	FROM Hospital_Doctor
	WHERE Hospital_Doctor.mentored_by = doc1.NINumber) > 0;


-- @@09

SELECT theatre1.theatreNo, theatre1.startDateTime AS startTime1, theatre2.startDateTime AS startTime2
FROM Hospital_Operation AS theatre1 JOIN Hospital_Operation AS theatre2
WHERE theatre2.startDateTime <= ADDTIME(theatre1.startDateTime, theatre1.duration)
	AND theatre2.startDateTime >= theatre1.startDateTime
	AND theatre1.theatreNo = theatre2.theatreNo
	AND theatre1.startDateTime != theatre2.startDateTime;

-- @@10

SELECT theatreNo, MAX(frequency) AS nummOps, dom, mon, yr FROM(
SELECT theatreNo, COUNT(*) AS frequency, extract(DAY FROM startDateTime) AS dom, extract(MONTH FROM startDateTime) AS mon, EXTRACT(YEAR FROM startDateTime) AS yr
FROM Hospital_Operation GROUP BY
theatreNo, extract(DAY FROM startDateTime), extract(MONTH FROM startDateTime)) AS theatre2 GROUP BY theatreNo, dom, mon, yr;
)


-- @@11
SELECT theatres.theatreNo, currentYear.thisMay, lastYear.lastMay FROM
(SELECT DISTINCT theatreNo FROM Hospital_Operation) AS theatres
LEFT JOIN (SELECT theatreNo, COUNT(*) AS thisMay FROM Hospital_Operation
WHERE extract(MONTH FROM startDateTime) = 5 
	AND EXTRACT(YEAR FROM startDateTime) = YEAR(NOW()) GROUP BY theatreNo) AS currentYear on theatres.theatreNo = currentYear.theatreNo 
LEFT JOIN (SELECT theatreNo, COUNT(*) AS lastMay FROM Hospital_Operation 
WHERE extract(MONTH FROM startDateTime) = 5 
	AND EXTRACT(YEAR FROM startDateTime) = YEAR(NOW()) - 1 GROUP BY theatreNo) AS lastYear ON theatres.theatreNo = lastYear.theatreNo 
WHERE COALESCE(currentYear.thisMay, 0) > COALESCE(lastYear.lastMay, 0);


-- @@12

DROP FUNCTION theatre_usage;
CREATE FUNCTION theatre_usage(targetYear INT, targetTheatre INT) RETURNS INT
RETURN (SELECT SEC_TO_TIME(SUM(duration)) FROM Hospital_Operation 
WHERE theatreNo = targetTheatre 
	AND YEAR(startDateTime) = targetYear);
SELECT theatre_usage(2018, 1);

delimiter $$


-- END OF ASSIGNMENT CODE
