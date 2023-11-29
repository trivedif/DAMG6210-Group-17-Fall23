CREATE DATABASE GROUP17;
GO
USE GROUP17
GO
--DROP DATABASE GROUP17

----------------------------------------------------------------------------------TABLES------------------------------------------------------------------------
CREATE TABLE Account
(
	AccountID INT IDENTITY(1,1) not null,
	FullName NVARCHAR(100),
	Username VARCHAR(200) not null,
	[Password] VARCHAR(200) not null,
	Email VARCHAR(50) CHECK (Email LIKE '%_@__%.__%'), -- CHECK Constraint 1--
	DateCreated DATE,
	PhoneNumber BIGINT,
	AccountType VARCHAR(10) CHECK (AccountType IN ('Student', 'Advisor', 'Instructor')), -- CHECK Constraint 2--
	CONSTRAINT Account_PK PRIMARY KEY (AccountID)
);

CREATE TABLE Community
(
	CommunityID INT IDENTITY(101,1) not null,
	CommunityName NVARCHAR(100),
	CommunityType VARCHAR(10),
	[Owner] VARCHAR(20),
	CONSTRAINT Community_PK PRIMARY KEY (CommunityID)
);

CREATE TABLE CommunityAccount
(
	CommunityID INT not null,
    AccountID INT not null,
	CONSTRAINT CommunityAccount_PK PRIMARY KEY (CommunityID, AccountID),
	CONSTRAINT CommunityAccount_FK1 FOREIGN KEY (CommunityID) 
		REFERENCES Community(CommunityID),
	CONSTRAINT CommunityAccount_FK2 FOREIGN KEY(AccountID) 
		REFERENCES Account(AccountID)
);

CREATE TABLE Post
(
	PostID INT IDENTITY(201,1) not null,
	PostTitle NVARCHAR(100),
	PostContent TEXT,
	TimePosted DATETIME DEFAULT (GETDATE()),
	CommunityID INT not null,
    AccountID INT not null,
	ReplyID INT,
	CONSTRAINT Post_PK PRIMARY KEY (PostID),
	CONSTRAINT Post_FK1 FOREIGN KEY (CommunityID) 
		REFERENCES Community(CommunityID),
	CONSTRAINT Post_FK2 FOREIGN KEY(AccountID) 
		REFERENCES Account(AccountID),
	CONSTRAINT Post_FK3 FOREIGN KEY(ReplyID) 
		REFERENCES Post(PostID)
);

CREATE TABLE Instructor
(
	InstructorID INT IDENTITY(1,1) not null,
	Experience VARCHAR(200),
	CONSTRAINT Instructor_PK PRIMARY KEY (InstructorID),
	CONSTRAINT Instructor_FK FOREIGN KEY (InstructorID) 
		REFERENCES Account(AccountID)
);

CREATE TABLE Advisor
(
	AdvisorID INT IDENTITY(1,1) not null,
	WorkingHours FLOAT,
	CONSTRAINT Advisor_PK PRIMARY KEY (AdvisorID),
	CONSTRAINT Advisor_FK FOREIGN KEY (AdvisorID) 
		REFERENCES Account(AccountID)
);

CREATE TABLE Student
(
	StudentID INT IDENTITY(1,1) not null,
	Major VARCHAR(50),
    Degree VARCHAR(40),
    AdvisorID INT not null,
	CONSTRAINT Student_PK PRIMARY KEY (StudentID),
	CONSTRAINT Student_FK FOREIGN KEY (StudentID) 
		REFERENCES Student(StudentID),
	CONSTRAINT  Student_FK2 FOREIGN KEY(AdvisorID) 
		REFERENCES Advisor(AdvisorID)
);

CREATE TABLE StudentSkill
(
	StudentID INT not null,
	SkillName VARCHAR(50) not null,
	CONSTRAINT StudentSkill_PK PRIMARY KEY (StudentID, Skillname),
	CONSTRAINT StudentSkill_FK FOREIGN KEY (StudentID)
		REFERENCES Student(StudentID)
);

CREATE TABLE Feedback
(
    FeedbackID INT IDENTITY(301,1) NOT NULL,
    Rating FLOAT CHECK (Rating >= 0 AND Rating <= 5), -- CHECK Constraint 3--
    FeedbackDescription VARCHAR(100),
    FeedbackTime DATETIME DEFAULT (GETDATE()),
    SentTo INT NOT NULL,
    SentBy INT NOT NULL,
    CONSTRAINT Feedback_PK PRIMARY KEY (FeedbackID),
    CONSTRAINT Feedback_FK_SentTo FOREIGN KEY (SentTo) REFERENCES Account(AccountID),
    CONSTRAINT Feedback_FK_SentBy FOREIGN KEY (SentBy) REFERENCES Account(AccountID)
);

CREATE TABLE Organization
(	
	OrganizationID INT IDENTITY(401,1) not null,
	OrganizationName NVARCHAR(100)  not null,
	OrganizationType VARCHAR(200),
	OrganizationWebsite VARCHAR(200),
	CONSTRAINT Organization_PK PRIMARY KEY (OrganizationID)
);

CREATE TABLE CourseCatalog
(
	CatalogID INT IDENTITY(501,1) not null,
	CatalogName NVARCHAR(100) not null,
	CatalogType VARCHAR(200),
	OrganizationID INT not null,
	CONSTRAINT CourseCatalog_PK PRIMARY KEY (CatalogID),
	CONSTRAINT CourseCatalog_FK FOREIGN KEY (OrganizationID)
		REFERENCES Organization(OrganizationID)
);

CREATE TABLE Course
(
	CourseID INT IDENTITY(601,1) not null,
	CourseTitle NVARCHAR(100)  not null,
	CourseRatings FLOAT,
	CourseDescription NVARCHAR(100),
	TotalPoints INT,
	CatalogID INT not null,
	CONSTRAINT Course_PK PRIMARY KEY (CourseID),
	CONSTRAINT Course_FK FOREIGN KEY (CatalogID)
		REFERENCES CourseCatalog(CatalogID)
);

CREATE TABLE CourseInstructor
(
	CourseID INT not null,
    InstructorID INT not null,
	CONSTRAINT CourseInstructor_PK PRIMARY KEY (CourseID, InstructorID),
	CONSTRAINT CourseInstructor_FK1 FOREIGN KEY (CourseID) 
		REFERENCES Course(CourseID),
	CONSTRAINT CourseInstructor_FK2 FOREIGN KEY(InstructorID) 
		REFERENCES Instructor(InstructorID)
);

CREATE TABLE Assessment
(
	AssessmentID INT IDENTITY(701,1) not null,
	TopicName VARCHAR(100),
	TotalPoints INT not null,
	PointsScored INT not null,
	AssessmentType VARCHAR(200) not null,
	AssessmentLevel VARCHAR(50),
	TimeLimit VARCHAR(10),
	PassingScore INT,
	CourseID INT not null,
	CONSTRAINT Assessment_PK PRIMARY KEY (AssessmentID),
	CONSTRAINT Assessment_FK FOREIGN KEY (CourseID)
		REFERENCES Course(CourseID),
	CONSTRAINT PointsScored_Check CHECK (PointsScored <= TotalPoints)
);

CREATE TABLE StudentAssessment
(
	StudentID int not null,
	AssessmentID int not null,
	CONSTRAINT StudentAssesment_PK PRIMARY KEY (StudentID, AssessmentID),
	CONSTRAINT StudentAssesment_FK1 FOREIGN KEY (StudentID)
		REFERENCES Student(StudentID),
	CONSTRAINT StudentAssesment_FK2 FOREIGN KEY (AssessmentID)
		REFERENCES Assessment(AssessmentID)
);

CREATE TABLE RewardPoints
(
	RewardID INT IDENTITY(801,1) not null,
	PointsEarned INT not null,
	RedeemablePoints INT,
	TotalAssessments INT,
	StudentID INT not null,
	CONSTRAINT RewardPoints_PK PRIMARY KEY (RewardID),
	CONSTRAINT RewardPoints_FK FOREIGN KEY (StudentID)
		REFERENCES Student(StudentID)
);

CREATE TABLE AssessmentPoints
(
	RewardID INT not null,
	AssessmentID INT not null,
	CONSTRAINT AssessmentPoints_PK PRIMARY KEY (RewardID, AssessmentID),
	CONSTRAINT AssessmentPoints_FK1 FOREIGN KEY (RewardID)
		REFERENCES RewardPoints (RewardID),
	CONSTRAINT AssesmentPoints_FK2 FOREIGN KEY (AssessmentID)
		REFERENCES Assessment(AssessmentID)
);

CREATE TABLE Payment
(
	PaymentID INT IDENTITY(901,1) not null,
	PaymentMethod VARCHAR(50) not null CHECK (PaymentMethod IN ('Credit Card', 'Debit Card', 'PayPal', 'Bank Transfer', 'Cash', 'Reward Points')), -- CHECK Constraint 4--
	Amount DECIMAL(10, 2),
	PaymentDate DATETIME,
	StudentID INT not null,
	CourseID INT not null,
	CONSTRAINT Payment_PK PRIMARY KEY (PaymentID),
	CONSTRAINT Payment_FK1 FOREIGN KEY (StudentID)
		REFERENCES Student(StudentID),
	CONSTRAINT Payment_FK2 FOREIGN KEY (CourseID)
		REFERENCES Course(CourseID)
);

CREATE TABLE CourseEnrollment
(
	EnrollmentID INT IDENTITY(1001,1) not null,
	EnrollmentDate DATE DEFAULT (GETDATE()) not null,
	CompletionDate DATE,
	CertificationStatus VARCHAR(20)	CHECK (CertificationStatus IN ('Enrolled', 'Completed', 'Not Completed', 'In Progress', 'Pending Assessment', 'Withdrawn', 'Suspended')), -- CHECK Constraint 5--
	StudentID INT not null,
	CourseID INT not null,
	PaymentID INT not null,
	CONSTRAINT CourseEnrollment_PK PRIMARY KEY (EnrollmentID),
	CONSTRAINT CourseEnrollment_FK1 FOREIGN KEY (StudentID)
		REFERENCES Student (StudentID),
	CONSTRAINT CourseEnrollment_FK2 FOREIGN KEY (CourseID)
		REFERENCES Course (CourseID),
	CONSTRAINT CourseEnrollment_FK3 FOREIGN KEY (PaymentID)
		REFERENCES Payment (PaymentID)
);

CREATE TABLE Wishlist
(
	WishlistID INT IDENTITY(1101,1) not null,
	DateAdded DATE not null,
	DateUpdated DATE not null,
	CourseID INT not null,
	CONSTRAINT Wishlist_PK PRIMARY KEY (WishlistID, CourseID),
	CONSTRAINT Wishlist_FK FOREIGN KEY (CourseID)
	    REFERENCES Course (CourseID)
);

------------------------------------------------------------------STORED PROCEDURES----------------------------------------------------------------------------------------------

--PROCEDURE 1: Get Average Rating For Instructor--

CREATE PROCEDURE GetAverageRatingForInstructor
    @InstructorID INT,
    @AverageRating FLOAT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
	SELECT @AverageRating = AVG(F.Rating)
    FROM Feedback F
    WHERE F.SentTo = @InstructorID AND F.SentBy IN (SELECT StudentID FROM Student);

    IF @AverageRating IS NULL
        SET @AverageRating = 5;
END


DECLARE @InstructorID INT = 5; 
DECLARE @AverageRating FLOAT;
EXEC GetAverageRatingForInstructor
    @InstructorID = @InstructorID,
    @AverageRating = @AverageRating OUTPUT;
SELECT @AverageRating AS 'AverageRating';


--PROCEDURE 2 : Enroll By Rewards--
CREATE PROCEDURE EnrollByRewards
    @CourseID INT,
    @StudentID INT,
    @Message NVARCHAR(100) OUTPUT
AS
BEGIN
    DECLARE @TotalPoints INT
    DECLARE @RedeemablePoints INT
    DECLARE @PaymentID INT
    DECLARE @EnrollmentID INT

    IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseID = @CourseID)
    BEGIN
        SET @Message = 'Invalid CourseID'
        RETURN
    END

    IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = @StudentID)
    BEGIN
        SET @Message = 'Invalid StudentID'
        RETURN
    END

    SELECT @TotalPoints = TotalPoints FROM Course WHERE CourseID = @CourseID
	SELECT @RedeemablePoints = RedeemablePoints FROM RewardPoints WHERE StudentID = @StudentID

    IF @TotalPoints > @RedeemablePoints
    BEGIN
        SET @Message = 'Student (ID: ' + CAST(@StudentID AS NVARCHAR(10)) + ') does not have enough Reward Points to enroll in the Course (ID: ' + CAST(@CourseID AS NVARCHAR(10)) + ')'
        RETURN
    END

    INSERT INTO Payment (PaymentMethod, Amount, PaymentDate, StudentID, CourseID)
    VALUES ('Reward Points', 0, GETDATE(), @StudentID, @CourseID)
	SELECT @PaymentID = MAX(PaymentID) FROM Payment
    INSERT INTO CourseEnrollment (EnrollmentDate, CertificationStatus, StudentID, CourseID, PaymentID)
    VALUES (GETDATE(), 'Enrolled', @StudentID, @CourseID, @PaymentID)

    UPDATE RewardPoints
    SET RedeemablePoints = RedeemablePoints - @TotalPoints
    WHERE StudentID = @StudentID

    SET @Message = 'Student (ID: ' + CAST(@StudentID AS NVARCHAR(10)) + ') successfully enrolled in the course (ID: ' + CAST(@CourseID AS NVARCHAR(10)) + ') using Reward Points'
END

DECLARE @Message1 NVARCHAR(100)
EXEC EnrollByRewards @CourseID = 605, @StudentID = 7, @Message = @Message1 OUTPUT;
PRINT @Message1;

--PROCEDURE 3: PostInformation--
CREATE PROCEDURE PostInformation
    @PostID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Post WHERE PostID = @PostID)
    BEGIN
        PRINT 'Invalid PostID'
        RETURN
    END
	SELECT 
        Reply.PostID,
        Reply.PostTitle,
        Reply.PostContent,
        Reply.TimePosted,
        Reply.CommunityID,
        Reply.AccountID,
        Reply.ReplyID
    FROM 
        Post AS Reply
    WHERE 
        Reply.ReplyID = @PostID;
END

DECLARE @PostID INT
SET @PostID = 208

EXEC PostInformation @PostID

--------------------------------------------------------------------VIEWS------------------------------------------------------------------------------------------

--VIEW 1 : STUDENT DETAILS--
CREATE VIEW StudentDetails AS
SELECT 
    A.AccountID,
    A.FullName,
    S.StudentID,
    S.Major,
    S.Degree,
    CE.CourseID,
    C.CourseTitle,
    CE.CertificationStatus,
    ASSESS.TotalPoints,
    ASSESS.PointsScored
FROM Account A
JOIN Student S ON A.AccountID = S.StudentID
LEFT JOIN CourseEnrollment CE ON S.StudentID = CE.StudentID
LEFT JOIN Course C ON CE.CourseID = C.CourseID
LEFT JOIN (
    SELECT 
        SA.StudentID,
        ASMT.CourseID,
        SUM(ASMT.TotalPoints) AS TotalPoints,
        SUM(ASMT.PointsScored) AS PointsScored
    FROM StudentAssessment SA
    JOIN Assessment ASMT ON SA.AssessmentID = ASMT.AssessmentID
    GROUP BY SA.StudentID, ASMT.CourseID
) AS ASSESS ON S.StudentID = ASSESS.StudentID AND CE.CourseID = ASSESS.CourseID;

-- To retrieve information from the StudentDetails view
SELECT * FROM StudentDetails;

--VIEW 2 : INSTRUCTOR RATINGS--
CREATE VIEW InstructorRatings AS
SELECT 
    I.InstructorID,
    A.FullName AS InstructorName,
    I.Experience,
    AVG(F.Rating) AS AverageRating
FROM Instructor I
JOIN Account A ON I.InstructorID = A.AccountID
LEFT JOIN Feedback F ON F.SentTo = I.InstructorID
GROUP BY I.InstructorID, A.FullName, I.Experience;

-- To retrieve information from the InstructorRatings view
SELECT * FROM InstructorRatings;

--VIEW 3 : COMMUNITY POSTS--
CREATE VIEW CommunityPosts AS
SELECT 
    P.PostID,
    P.PostTitle,
    P.PostContent,
    P.TimePosted,
    P.CommunityID,
    P.AccountID AS PostedByAccountID,
    A.FullName AS PostedByFullName,
    A.AccountType,
    C.CommunityName
FROM Post P
JOIN Account A ON P.AccountID = A.AccountID
JOIN Community C ON P.CommunityID = C.CommunityID;

-- To retrieve information from the CommunityPosts view
SELECT * FROM CommunityPosts;

-------------------------------------------------------------------------TRIGGER------------------------------------------------------------------------------------
CREATE TRIGGER trg_CheckSentToSentBy
ON Feedback
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE NOT EXISTS (
            SELECT 1
            FROM (
                SELECT InstructorID AS AccountID FROM Instructor
                UNION ALL
                SELECT StudentID AS AccountID FROM Student
            ) AS Accounts
            WHERE Accounts.AccountID = i.SentTo
        )
    )
    BEGIN
        THROW 50001, 'Invalid SentTo value', 1;
    END

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE NOT EXISTS (
            SELECT 1
            FROM (
                SELECT InstructorID AS AccountID FROM Instructor
                UNION ALL
                SELECT StudentID AS AccountID FROM Student
            ) AS Accounts
            WHERE Accounts.AccountID = i.SentBy
        )
    )
    BEGIN
        THROW 50001, 'Invalid SentBy value', 1;
    END
END;

------------------------------------------------------------------------USER DEFINED FUNCTION-------------------------------------------------------------------------
--COURSE COMPLETION TIME TAKEN BY STUDENTS-- 
CREATE FUNCTION fn_completiondate (@enrollid INT)
RETURNS INT  
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @completiontime INT;
    SELECT @completiontime = DATEDIFF(day, [EnrollmentDate], [CompletionDate])
    FROM [dbo].[CourseEnrollment]
    WHERE EnrollmentID = @enrollid;
    RETURN @completiontime;
END

ALTER TABLE [dbo].[CourseEnrollment]
ADD [CompletionTime] AS dbo.fn_completiondate([EnrollmentID])

SELECT * FROM CourseEnrollment;

------------------------------------------------------------------------COLUMN DATA ENCRYPTION-------------------------------------------------------------------------
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'GROUP17';
CREATE CERTIFICATE PasswordEncryptionCertificate
    WITH SUBJECT = 'Password Encryption';
CREATE SYMMETRIC KEY PasswordKey
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE PasswordEncryptionCertificate;

ALTER TABLE Account
ADD PasswordEncrypted VARBINARY(MAX);
OPEN SYMMETRIC KEY PasswordKey
    DECRYPTION BY CERTIFICATE PasswordEncryptionCertificate;

UPDATE Account
SET PasswordEncrypted = EncryptByKey(Key_GUID('PasswordKey'), [Password]);

CLOSE SYMMETRIC KEY PasswordKey;

SELECT * FROM Account;

--COLUMN DATA DECRYPTION--
OPEN SYMMETRIC KEY PasswordKey
    DECRYPTION BY CERTIFICATE PasswordEncryptionCertificate;

-- Example of an insert statement
INSERT INTO Account (FullName, Username, PasswordEncrypted, Email, DateCreated, PhoneNumber, AccountType)
VALUES ('Full Name', 'username', EncryptByKey(Key_GUID('PasswordKey'), 'password'), 'email@example.com', GETDATE(), 1234567890, 'Student');

CLOSE SYMMETRIC KEY PasswordKey;
OPEN SYMMETRIC KEY PasswordKey
    DECRYPTION BY CERTIFICATE PasswordEncryptionCertificate;

SELECT AccountID, FullName, Username, CONVERT(VARCHAR, DecryptByKey(PasswordEncrypted)) AS DecryptedPassword
FROM Account
-- Add any WHERE clause or other conditions needed

CLOSE SYMMETRIC KEY PasswordKey;


------------------------------------------------------------------------NONCLUSTERED INDEXES-------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IDX_Feedback_Rating ON Feedback (Rating);
CREATE NONCLUSTERED INDEX IDX_Assessment_CourseID ON Assessment (CourseID);
CREATE NONCLUSTERED INDEX IDX_Course_CourseTitle ON Course (CourseTitle);