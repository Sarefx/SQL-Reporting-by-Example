-- How many students do they have at Jefferson Middle School?
SELECT COUNT(*) FROM STUDENTS

-- Generate a list of teachers sorted alphabetically by last name.
SELECT FIRST_NAME, LAST_NAME FROM TEACHERS ORDER BY LAST_NAME ASC

-- Which students have last names starting with 'A'?
SELECT * FROM STUDENTS WHERE LAST_NAME LIKE 'A%'

-- What's the total capacity of the school?
SELECT SUM(CAPACITY) FROM ROOMS

-- Which room has the largest capacity?
SELECT MAX(CAPACITY) FROM ROOMS

-- Which subject/s are taught in room 19?
SELECT DISTINCT NAME FROM CLASSES
JOIN SUBJECTS ON CLASSES.SUBJECT_ID = SUBJECTS.ID
WHERE ROOM_ID = 19

-- Which teachers teach only students in 8th grade?
SELECT DISTINCT TEACHERS.ID, FIRST_NAME, LAST_NAME FROM TEACHERS
JOIN CLASSES ON TEACHERS.ID = CLASSES.TEACHER_ID
JOIN SUBJECTS ON SUBJECTS.ID = CLASSES.SUBJECT_ID
WHERE GRADE = 8

-- Which teacher teaches 7th grade science?
SELECT * FROM SUBJECTS
JOIN CLASSES ON SUBJECTS.ID = CLASSES.SUBJECT_ID
JOIN TEACHERS ON TEACHERS.ID = CLASSES.TEACHER_ID
WHERE GRADE = 7 AND NAME = 'Science'

-- Which teachers teach elective subjects?
SELECT DISTINCT TEACHERS.ID, FIRST_NAME, LAST_NAME FROM TEACHERS
JOIN CLASSES ON TEACHERS.ID = CLASSES.TEACHER_ID
JOIN SUBJECTS ON SUBJECTS.ID = CLASSES.SUBJECT_ID
WHERE GRADE is NULL

-- Generate a schedule for Rex Rios.
SELECT * FROM STUDENTS
JOIN SCHEDULE ON STUDENTS.ID = SCHEDULE.STUDENT_ID
JOIN CLASSES ON CLASSES.ID = SCHEDULE.CLASS_ID
JOIN SUBJECTS ON SUBJECTS.ID = CLASSES.SUBJECT_ID
WHERE FIRST_NAME = 'Rex' AND LAST_NAME = 'Rios'

-- How many students have Physical Education during first period?
SELECT COUNT(*) FROM STUDENTS
JOIN SCHEDULE ON STUDENTS.ID = SCHEDULE.STUDENT_ID
JOIN CLASSES ON CLASSES.ID = SCHEDULE.CLASS_ID
JOIN SUBJECTS ON SUBJECTS.ID = CLASSES.SUBJECT_ID
WHERE PERIOD_ID = 1 AND NAME = 'Physical Education'

-- Generate a list of students with last names from A to M.
SELECT * FROM STUDENTS
-- WHERE LAST_NAME LIKE '[A-M]%' -- works in other databases, but not in SQLite
WHERE LAST_NAME >= 'A' AND LAST_NAME < 'N'
ORDER BY LAST_NAME ASC

-- How many students are in each grade? And how many 6th graders do you think they'll have next year?
SELECT GRADE, COUNT(1) FROM STUDENTS
GROUP BY GRADE

-- Do they have room for that many 6th graders?
SELECT MIN(CAPACITY) * 7 FROM CLASSES
JOIN SUBJECTS ON SUBJECTS.ID = CLASSES.SUBJECT_ID
JOIN ROOMS ON ROOMS.ID = CLASSES.ROOM_ID
WHERE GRADE = 6

-- Which teachers teach a class during all 7 periods?
SELECT TEACHERS.ID, FIRST_NAME, LAST_NAME, COUNT(1) FROM TEACHERS
JOIN CLASSES ON TEACHERS.ID = CLASSES.TEACHERS_ID
GROUP BY TEACHERS.ID HAVING COUNT(1) = 7

-- Do any teachers teach multiple subjects? If so, which teachers?
SELECT TEACHERS.* FROM TEACHERS
JOIN CLASSES ON TEACHERS.ID = CLASSES.TEACHERS_ID
GROUP BY TEACHERS.ID HAVING COUNT(DISTINCT SUBJECT_ID) > 1

-- What class does Janis Ambrose teach during each period? Be sure to include all 7 periods in your report!
WITH JANIS_CLASSES AS (SELECT PERIOD_ID, SUBJECTS.NAME FROM TEACHERS
JOIN CLASSES ON TEACHERS.ID = CLASSES.TEACHERS_ID
JOIN SUBJECTS ON SUBJECTS.ID = CLASSES.SUBJECT_ID
WHERE TEACHERS.ID = 391)
SELECT PERIODS.ID, JANIS_CLASSES.NAME FROM PERIODS
LEFT OUTER JOIN JANIES_CLASSES ON PERIODS.ID = PERIOD_ID

-- Which subject is the least popular, and how many students are taking it?
WITH SUBJECT_COUNTS AS (
    SELECT SUBJECTS.NAME, COUNT(1) FROM SUBJECTS
    JOIN CLASSES ON SUBJECTS.ID = CLASSES.SUBJECTS_ID
    JOIN SCHEDULE ON CLASSES.ID = SCHEDULE.CLASS_ID
    GROUP BY SUBJECT_ID
)
SELECT NAME, MIN(CT) FROM SUBJECT_COUNTS

-- Which students have 5th period science and 7th period art?
WITH FIFTH_SCIENCE AS (
    SELECT STUDENT_ID FROM STUDENTS
    JOIN SCHEDULE ON STUDENTS.ID = SCHEDULE.STUDENT_ID
    JOIN CLASSES ON CLASSES.ID = SCHEDULE.CLASS_ID
    JOIN SUBJECTS ON SUBJECTS.ID = CLASSES.SUBJECT_ID
    WHERE PERIOD_ID = 5 AND SUBJECTS.NAME = 'Science'
), SEVENTH_ART AS (
    SELECT STUDENT_ID FROM STUDENTS
    JOIN SCHEDULE ON STUDENTS.ID = SCHEDULE.STUDENT_ID
    JOIN CLASSES ON CLASSES.ID = SCHEDULE.CLASS_ID
    JOIN SUBJECTS ON SUBJECTS.ID = CLASSES.SUBJECT_ID
    WHERE PERIOD_ID = 7 AND SUBJECTS.NAME = 'Art'
)
SELECT C.* FROM FIFTH_SCIENCE A
JOIN SEVENTH_ART B ON A.STUDENT_ID = B.STUDENT_ID
JOIN STUDENTS C ON A.STUDENT_ID = C.ID

-- Which elective teacher is the most popular (teaches the most students)?
WITH ELECTIVE_TEACHERS AS (
    SELECT DISTINCT TEACHERS.ID
    FROM TEACHERS
    JOIN CLASSES ON TEACHERS.ID = CLASSES.TEACHER_ID
    JOIN SUBJECTS ON CLASSES.SUBJECT_ID = SUBJECTS.ID
    WHERE GRADE IS NULL
), STUDENT_COUNTS AS (
    SELECT ELECTIVE_TEACHERS.ID, COUNT(1) 'CT'
    FROM ELECTIVE_TEACHERS
    JOIN CLASSES ON ELECTIVE_TEACHERS.ID = CLASSES.TEACHER_ID
    JOIN SCHEDULE ON CLASSES.ID = SCHEDULE.CLASS_ID
    GROUP BY ELECTIVE_TEACHERS.ID
)
SELECT MAX(STUDENT_COUNTS.CT), TEACHERS.FIRST_NAME, TEACHERS.LAST_NAME 
FROM STUDENT_COUNTS
JOIN TEACHERS ON STUDENT_COUNTS.ID = TEACHERS.ID

-- Which teachers don't have a class during 1st period?
SELECT TEACHERS.* FROM TEACHERS

EXCEPT

SELECT TEACHERS.* FROM TEACHERS
JOIN CLASSES ON TEACHERS.ID = CLASSES.TEACHER_ID
WHERE PERIOD_ID = 1

