--  DROP TABLES IF EXISTING
DROP TABLE IF EXISTS Allotments;
DROP TABLE IF EXISTS UnallotedStudents;
DROP TABLE IF EXISTS StudentPreference;
DROP TABLE IF EXISTS SubjectDetails;
DROP TABLE IF EXISTS StudentDetails;
GO

--  TABLE: StudentDetails
CREATE TABLE StudentDetails (
    StudentId VARCHAR(20) PRIMARY KEY,
    StudentName VARCHAR(100),
    GPA FLOAT,
    Branch VARCHAR(10),
    Section CHAR(1)
);
GO

--  TABLE: SubjectDetails
CREATE TABLE SubjectDetails (
    SubjectId VARCHAR(10) PRIMARY KEY,
    SubjectName VARCHAR(100),
    MaxSeats INT,
    RemainingSeats INT
);
GO

--  TABLE: StudentPreference
CREATE TABLE StudentPreference (
    StudentId VARCHAR(20),
    SubjectId VARCHAR(10),
    Preference INT,
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId),
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId)
);
GO

--  TABLE: Allotments
CREATE TABLE Allotments (
    SubjectId VARCHAR(10),
    StudentId VARCHAR(20),
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId),
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId)
);
GO

--  TABLE: UnallotedStudents
CREATE TABLE UnallotedStudents (
    StudentId VARCHAR(20),
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
);
GO

--  INSERT SAMPLE DATA
INSERT INTO StudentDetails VALUES 
('159103041', 'Arjun Tehlan', 9.2, 'CSE', 'A'),
('159103036', 'Mohit Agarwal', 8.9, 'CSE', 'A'),
('159103039', 'Mrinal Malhotra', 7.9, 'CSE', 'A'),
('159103038', 'Shohit Garg', 7.1, 'CSE', 'A'),
('159103040', 'Mehreet Singh', 5.6, 'CSE', 'A'),
('159103037', 'Rohit Agarwal', 5.2, 'CSE', 'A');

INSERT INTO SubjectDetails VALUES
('PO1491', 'Basics of Political Science', 60, 2),
('PO1492', 'Basics of Accounting', 120, 119),
('PO1493', 'Basics of Financial Markets', 90, 90),
('PO1494', 'Eco Philosophy', 60, 50),
('PO1495', 'Automotive Trends', 60, 60);

--  INSERT PREFERENCES (same for all for demo)
INSERT INTO StudentPreference VALUES
('159103036', 'PO1491', 1), ('159103036', 'PO1492', 2), ('159103036', 'PO1493', 3), ('159103036', 'PO1494', 4), ('159103036', 'PO1495', 5),
('159103037', 'PO1491', 1), ('159103037', 'PO1492', 2), ('159103037', 'PO1493', 3), ('159103037', 'PO1494', 4), ('159103037', 'PO1495', 5),
('159103038', 'PO1491', 1), ('159103038', 'PO1492', 2), ('159103038', 'PO1493', 3), ('159103038', 'PO1494', 4), ('159103038', 'PO1495', 5),
('159103039', 'PO1491', 1), ('159103039', 'PO1492', 2), ('159103039', 'PO1493', 3), ('159103039', 'PO1494', 4), ('159103039', 'PO1495', 5),
('159103040', 'PO1491', 1), ('159103040', 'PO1492', 2), ('159103040', 'PO1493', 3), ('159103040', 'PO1494', 4), ('159103040', 'PO1495', 5),
('159103041', 'PO1491', 1), ('159103041', 'PO1492', 2), ('159103041', 'PO1493', 3), ('159103041', 'PO1494', 4), ('159103041', 'PO1495', 5);
GO

--  DROP PROCEDURE IF EXISTS
DROP PROCEDURE IF EXISTS AllocateSubjects;
GO

--  CREATE PROCEDURE 
CREATE PROCEDURE AllocateSubjects
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Allotments;
    DELETE FROM UnallotedStudents;

    CREATE TABLE #TempRemainingSeats (
        SubjectId VARCHAR(10) PRIMARY KEY,
        RemainingSeats INT
    );

    INSERT INTO #TempRemainingSeats (SubjectId, RemainingSeats)
    SELECT SubjectId, RemainingSeats FROM SubjectDetails;

    DECLARE student_cursor CURSOR FOR
    SELECT StudentId FROM StudentDetails ORDER BY GPA DESC;

    DECLARE @StudentId VARCHAR(20);
    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @StudentId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @Allocated BIT = 0;

        IF EXISTS (
            SELECT 1 FROM StudentPreference WHERE StudentId = @StudentId
        )
        BEGIN
            DECLARE pref_cursor CURSOR FOR
            SELECT SubjectId
            FROM StudentPreference
            WHERE StudentId = @StudentId
            ORDER BY Preference;

            DECLARE @SubjectId VARCHAR(10);
            OPEN pref_cursor;
            FETCH NEXT FROM pref_cursor INTO @SubjectId;

            WHILE @@FETCH_STATUS = 0 AND @Allocated = 0
            BEGIN
                DECLARE @Remaining INT;
                SELECT @Remaining = RemainingSeats
                FROM #TempRemainingSeats
                WHERE SubjectId = @SubjectId;

                IF @Remaining > 0
                BEGIN
                    INSERT INTO Allotments (SubjectId, StudentId)
                    VALUES (@SubjectId, @StudentId);

                    UPDATE #TempRemainingSeats
                    SET RemainingSeats = RemainingSeats - 1
                    WHERE SubjectId = @SubjectId;

                    SET @Allocated = 1;
                END

                FETCH NEXT FROM pref_cursor INTO @SubjectId;
            END

            CLOSE pref_cursor;
            DEALLOCATE pref_cursor;
        END

        IF @Allocated = 0
        BEGIN
            INSERT INTO UnallotedStudents (StudentId)
            VALUES (@StudentId);
        END

        FETCH NEXT FROM student_cursor INTO @StudentId;
    END

    CLOSE student_cursor;
    DEALLOCATE student_cursor;

    DROP TABLE #TempRemainingSeats;

    -- Output results
PRINT 'Final Resultant Table if the student has been allotted to a subject:';
SELECT * FROM Allotments;

PRINT 'Final Resultant Table if the student is unallotted:';
SELECT * FROM UnallotedStudents;


END;
GO

-- EXECUTE PROCEDURE
EXEC AllocateSubjects;