-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 12, 2025 at 03:24 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `evaluation_system`
--

-- --------------------------------------------------------

--
-- Table structure for table `classes`
--

CREATE TABLE `classes` (
  `ClassID` int(11) NOT NULL,
  `CourseID` int(11) NOT NULL,
  `YearLevel` varchar(10) DEFAULT NULL,
  `Section` varchar(10) DEFAULT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `classes`
--

INSERT INTO `classes` (`ClassID`, `CourseID`, `YearLevel`, `Section`, `IsActive`) VALUES
(1, 1, '1ST', 'A', 1),
(2, 1, '1ST', 'B', 1),
(3, 1, '2ND', 'A', 1),
(4, 2, '1ST', 'A', 1),
(5, 3, '1ST', 'A', 1),
(6, 3, '2ND', 'A', 1),
(7, 4, '1ST', 'A', 1),
(8, 5, '1ST', 'A', 1);

-- --------------------------------------------------------

--
-- Table structure for table `courses`
--

CREATE TABLE `courses` (
  `CourseID` int(11) NOT NULL,
  `CourseName` varchar(100) NOT NULL,
  `DepartmentID` int(11) NOT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `courses`
--

INSERT INTO `courses` (`CourseID`, `CourseName`, `DepartmentID`, `IsActive`) VALUES
(1, 'Bachelor of Science in Information Technology', 1, 1),
(2, 'Bachelor of Science in Computer Science', 1, 1),
(3, 'Bachelor of Science in Criminology', 2, 1),
(4, 'Bachelor of Science in Business Administration', 3, 1),
(5, 'Bachelor of Elementary Education', 4, 1);

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE `departments` (
  `DepartmentID` int(11) NOT NULL,
  `DepartmentName` varchar(150) NOT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `departments`
--

INSERT INTO `departments` (`DepartmentID`, `DepartmentName`, `IsActive`) VALUES
(1, 'College of Information Technology', 1),
(2, 'College of Criminal Justice', 1),
(3, 'College of Business Administration', 1),
(4, 'College of Education', 1);

-- --------------------------------------------------------

--
-- Table structure for table `evaluationcycles`
--

CREATE TABLE `evaluationcycles` (
  `CycleID` int(11) NOT NULL,
  `Term` varchar(50) NOT NULL,
  `Status` enum('Active','Inactive') DEFAULT 'Inactive',
  `StartDate` date DEFAULT NULL,
  `EndDate` date DEFAULT NULL,
  `CycleName` varchar(100) NOT NULL,
  `IsActive` tinyint(11) NOT NULL DEFAULT 1,
  `Notified` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `evaluationcycles`
--

INSERT INTO `evaluationcycles` (`CycleID`, `Term`, `Status`, `StartDate`, `EndDate`, `CycleName`, `IsActive`, `Notified`) VALUES
(16, '1st Semester', 'Active', '2025-10-10', '2025-10-11', 'first try', 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `evaluationdomains`
--

CREATE TABLE `evaluationdomains` (
  `DomainID` int(11) NOT NULL,
  `DomainName` varchar(100) NOT NULL,
  `Weight` int(11) NOT NULL,
  `IsActive` bit(1) DEFAULT b'1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `evaluationdomains`
--

INSERT INTO `evaluationdomains` (`DomainID`, `DomainName`, `Weight`, `IsActive`) VALUES
(6, 'Teaching Effectiveness', 30, b'1'),
(7, 'Classroom Management', 20, b'1'),
(8, 'Student Engagement', 15, b'1'),
(9, 'Assessment & Feedback', 15, b'1'),
(10, 'Professional Qualities', 10, b'1'),
(11, 'Overall Perfomance', 10, b'1');

-- --------------------------------------------------------

--
-- Table structure for table `evaluationquestions`
--

CREATE TABLE `evaluationquestions` (
  `QuestionID` int(11) NOT NULL,
  `QuestionText` varchar(500) NOT NULL,
  `Scale` int(11) DEFAULT 5,
  `DomainID` int(11) DEFAULT NULL,
  `IsActive` bit(1) DEFAULT b'1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `evaluationquestions`
--

INSERT INTO `evaluationquestions` (`QuestionID`, `QuestionText`, `Scale`, `DomainID`, `IsActive`) VALUES
(10, 'The instructor begins and ends classes on time.', 5, 7, b'1'),
(11, 'The instructor maintains order and discipline respectfully.', 5, 7, b'1'),
(12, 'The instructor manages classroom activities effectively.', 5, 7, b'1'),
(13, 'The instructor encourages active participation.', 5, 8, b'1'),
(14, 'The instructor motivates students to learn.', 5, 8, b'1'),
(15, 'The instructor provides constructive feedback.', 5, 8, b'1'),
(16, 'The instructor gives fair and transparent grades.', 5, 9, b'1'),
(17, 'The instructor returns feedback on time.', 5, 9, b'1'),
(18, 'The assessments align with course objectives.', 5, 9, b'1'),
(19, 'Overall, the instructor is effective in teaching.', 5, 11, b'1'),
(20, 'I am satisfied with the instructor’s performance.', 5, 11, b'1'),
(21, 'I would recommend this instructor to other students.', 5, 11, b'1'),
(22, 'The teacher is approachable and responsive to student needs.', 5, 8, b'1'),
(23, 'I would recommend this teacher to other students.', 5, 11, b'1'),
(24, 'The teacher demonstrates professionalism and ethical conduct.', 5, 10, b'1'),
(25, 'The teacher is punctual and consistent in attendance.', 5, 10, b'1'),
(26, 'The teacher shows respect and fairness to all students.', 5, 10, b'1'),
(27, 'The teacher is open to feedback and suggestions.', 5, 10, b'1'),
(28, 'The teacher explains lessons clearly and effectively.', 5, 6, b'1'),
(29, 'The teacher demonstrates mastery of the subject matter.', 5, 6, b'1'),
(30, 'The teacher uses appropriate examples and teaching strategies.', 5, 6, b'1'),
(31, 'The teacher encourages critical thinking and problem-solving.', 5, 6, b'1'),
(33, 'The teacher evaluates student performance fairly and without bias.', 5, 9, b'1'),
(34, 'The teacher manages classroom resources effectively.', 5, 7, b'1');

-- --------------------------------------------------------

--
-- Table structure for table `evaluations`
--

CREATE TABLE `evaluations` (
  `EvalID` int(11) NOT NULL,
  `LoadID` int(11) DEFAULT NULL,
  `QuestionID` int(11) DEFAULT NULL,
  `Score` tinyint(4) NOT NULL CHECK (`Score` between 1 and 5),
  `SubmissionDate` timestamp NOT NULL DEFAULT current_timestamp(),
  `SubmissionID` int(11) NOT NULL,
  `CycleID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `evaluations`
--

INSERT INTO `evaluations` (`EvalID`, `LoadID`, `QuestionID`, `Score`, `SubmissionDate`, `SubmissionID`, `CycleID`) VALUES
(1980, 48, 28, 4, '2025-10-11 02:52:40', 88, 16),
(1981, 48, 29, 4, '2025-10-11 02:52:40', 88, 16),
(1982, 48, 30, 3, '2025-10-11 02:52:40', 88, 16),
(1983, 48, 31, 4, '2025-10-11 02:52:40', 88, 16),
(1984, 48, 10, 5, '2025-10-11 02:52:40', 88, 16),
(1985, 48, 11, 4, '2025-10-11 02:52:40', 88, 16),
(1986, 48, 12, 3, '2025-10-11 02:52:40', 88, 16),
(1987, 48, 34, 4, '2025-10-11 02:52:40', 88, 16),
(1988, 48, 13, 5, '2025-10-11 02:52:40', 88, 16),
(1989, 48, 14, 4, '2025-10-11 02:52:40', 88, 16),
(1990, 48, 15, 4, '2025-10-11 02:52:40', 88, 16),
(1991, 48, 22, 5, '2025-10-11 02:52:40', 88, 16),
(1992, 48, 16, 5, '2025-10-11 02:52:40', 88, 16),
(1993, 48, 17, 4, '2025-10-11 02:52:40', 88, 16),
(1994, 48, 18, 4, '2025-10-11 02:52:40', 88, 16),
(1995, 48, 33, 3, '2025-10-11 02:52:40', 88, 16),
(1996, 48, 24, 3, '2025-10-11 02:52:40', 88, 16),
(1997, 48, 25, 4, '2025-10-11 02:52:40', 88, 16),
(1998, 48, 26, 5, '2025-10-11 02:52:40', 88, 16),
(1999, 48, 27, 5, '2025-10-11 02:52:40', 88, 16),
(2000, 48, 19, 5, '2025-10-11 02:52:40', 88, 16),
(2001, 48, 20, 4, '2025-10-11 02:52:40', 88, 16),
(2002, 48, 21, 4, '2025-10-11 02:52:40', 88, 16),
(2003, 48, 23, 5, '2025-10-11 02:52:40', 88, 16);

-- --------------------------------------------------------

--
-- Table structure for table `evaluationsubmissions`
--

CREATE TABLE `evaluationsubmissions` (
  `SubmissionID` int(11) NOT NULL,
  `LoadID` int(11) DEFAULT NULL,
  `StudentID` int(11) DEFAULT NULL,
  `SubmissionDate` datetime NOT NULL,
  `Comments` text DEFAULT NULL,
  `CycleID` int(11) NOT NULL,
  `AverageScore` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `evaluationsubmissions`
--

INSERT INTO `evaluationsubmissions` (`SubmissionID`, `LoadID`, `StudentID`, `SubmissionDate`, `Comments`, `CycleID`, `AverageScore`) VALUES
(88, 48, 4, '2025-10-11 10:52:39', 'erereretertertert', 16, 81.50);

-- --------------------------------------------------------

--
-- Table structure for table `facultyload`
--

CREATE TABLE `facultyload` (
  `LoadID` int(11) NOT NULL,
  `FacultyID` int(11) NOT NULL,
  `DepartmentID` int(100) NOT NULL,
  `CourseID` int(11) NOT NULL,
  `SubjectID` int(11) NOT NULL,
  `ClassID` int(11) NOT NULL,
  `Term` varchar(50) DEFAULT NULL,
  `IsDeleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `facultyload`
--

INSERT INTO `facultyload` (`LoadID`, `FacultyID`, `DepartmentID`, `CourseID`, `SubjectID`, `ClassID`, `Term`, `IsDeleted`) VALUES
(48, 6, 1, 1, 2, 1, '1st Semester', 0),
(50, 6, 1, 1, 1, 1, '1st Semester', 1),
(52, 5, 1, 2, 1, 4, '1st Semester', 0),
(54, 8, 1, 2, 12, 4, '1st Semester', 0);

-- --------------------------------------------------------

--
-- Table structure for table `passwordresettokens`
--

CREATE TABLE `passwordresettokens` (
  `TokenID` int(11) NOT NULL,
  `SchoolID` varchar(50) NOT NULL,
  `Token` varchar(6) NOT NULL,
  `Expiration` datetime NOT NULL,
  `Used` tinyint(1) NOT NULL DEFAULT 0,
  `CreatedAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `passwordresettokens`
--

INSERT INTO `passwordresettokens` (`TokenID`, `SchoolID`, `Token`, `Expiration`, `Used`, `CreatedAt`) VALUES
(3, 'Student1', '978113', '2025-10-08 20:46:26', 0, '2025-10-08 12:31:26');

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `StudentID` int(11) NOT NULL,
  `FullName` varchar(150) NOT NULL,
  `SchoolID` varchar(50) NOT NULL,
  `Password` varchar(100) NOT NULL,
  `DepartmentID` int(11) NOT NULL,
  `CourseID` int(11) DEFAULT NULL,
  `Status` enum('Active','Inactive','Graduated') DEFAULT 'Active',
  `ClassID` int(11) DEFAULT NULL,
  `Email` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`StudentID`, `FullName`, `SchoolID`, `Password`, `DepartmentID`, `CourseID`, `Status`, `ClassID`, `Email`) VALUES
(1, 'John Michael Santos', '20241', 'ee79976c9380d5e337fc1c095ece8c8f22f91f306ceeb161fa51fecede2c4ba1', 1, 1, 'Active', 2, 'jm.santos@student.university.edu'),
(2, 'Maria Cristina Reyes', '20240002', 'ee79976c9380d5e337fc1c095ece8c8f22f91f306ceeb161fa51fecede2c4ba1', 1, 1, 'Active', 1, 'mc.reyes@student.university.edu'),
(3, 'Carlos Antonio Lim', '2024cs1', 'ee79976c9380d5e337fc1c095ece8c8f22f91f306ceeb161fa51fecede2c4ba1', 1, 1, 'Active', 1, 'ca.lim@student.university.edu'),
(4, 'Andrea Nicole Tan', '2024it2', 'ee79976c9380d5e337fc1c095ece8c8f22f91f306ceeb161fa51fecede2c4ba1', 1, 1, 'Active', 1, 'an.tan@student.university.edu'),
(5, 'Daniel Park', '2024it1', 'ee79976c9380d5e337fc1c095ece8c8f22f91f306ceeb161fa51fecede2c4ba1', 1, 2, 'Active', 4, 'd.park@student.university.edu'),
(6, 'Miguel Santiago', '20240006', 'ee79976c9380d5e337fc1c095ece8c8f22f91f306ceeb161fa51fecede2c4ba1', 2, 3, 'Active', 5, 'm.santiago@student.university.edu'),
(7, 'Elena Rodriguez', '20240007', 'ee79976c9380d5e337fc1c095ece8c8f22f91f306ceeb161fa51fecede2c4ba1', 1, 2, 'Active', 4, 'e.rodriguez@student.university.edu'),
(8, 'Kevin Smith', '20240008', 'ee79976c9380d5e337fc1c095ece8c8f22f91f306ceeb161fa51fecede2c4ba1', 3, 4, 'Active', 7, 'k.smith@student.university.edu'),
(9, 'Sophia Garcia', '20240009', 'ee79976c9380d5e337fc1c095ece8c8f22f91f306ceeb161fa51fecede2c4ba1', 4, 5, 'Active', 8, 's.garcia@student.university.edu'),
(41, 'Student1', 'Student1', 'ee79976c9380d5e337fc1c095ece8c8f22f91f306ceeb161fa51fecede2c4ba1', 1, 1, 'Active', 1, 'pularalphgabriel@gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `subjects`
--

CREATE TABLE `subjects` (
  `SubjectID` int(11) NOT NULL,
  `SubjectName` varchar(100) NOT NULL,
  `SubjectCode` varchar(20) NOT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `subjects`
--

INSERT INTO `subjects` (`SubjectID`, `SubjectName`, `SubjectCode`, `IsActive`) VALUES
(1, 'Introduction to Programming', 'PROG101', 1),
(2, 'Database Management Systems', 'DBMS101', 1),
(3, 'Web Development', 'WEB101', 1),
(4, 'Data Structures and Algorithms', 'DSA101', 1),
(5, 'Criminal Law', 'CRIM101', 1),
(6, 'Forensic Science', 'FORS101', 1),
(7, 'Business Mathematics', 'BMATH101', 1),
(8, 'Principles of Management', 'MGMT101', 1),
(9, 'Child Development', 'CDEV101', 1),
(10, 'Teaching Strategies', 'TSTR101', 1),
(11, 'Engineering Mechanics', 'EMECH101', 1),
(12, 'Calculus 1', 'CALC101', 1);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `UserID` int(11) NOT NULL,
  `FullName` varchar(100) NOT NULL,
  `SchoolID` varchar(50) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Role` enum('Student','Faculty','Dean','Admin') NOT NULL,
  `DepartmentID` int(100) DEFAULT NULL,
  `Status` enum('Active','Inactive') DEFAULT 'Active',
  `Email` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`UserID`, `FullName`, `SchoolID`, `Password`, `Role`, `DepartmentID`, `Status`, `Email`) VALUES
(1, 'Ralph Gabriel Pula', '123', 'ee79976c9380d5e337fc1c095ece8c8f22f91f306ceeb161fa51fecede2c4ba1', 'Admin', NULL, 'Active', ''),
(2, 'Dr. Sarah Johnson', 'DEAN1', 'ee79976c9380d5e337fc1c095ece8c8f22f91f306ceeb161fa51fecede2c4ba1', 'Dean', 1, 'Active', 's.johnson@university.edu'),
(3, 'Dr. Michael Chen', 'DEAN2', 'ee79976c9380d5e337fc1c095ece8c8f22f91f306ceeb161fa51fecede2c4ba1', 'Dean', 2, 'Active', 'm.chen@university.edu'),
(4, 'Dr. Robert Garcia', 'DEAN3', 'ee79976c9380d5e337fc1c095ece8c8f22f91f306ceeb161fa51fecede2c4ba1', 'Dean', 3, 'Active', 'r.garcia@university.edu'),
(5, 'Prof. Jennifer Martinez', 'FAC001', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Faculty', 1, 'Active', 'j.martinez@university.edu'),
(6, 'Prof. David Kim', 'FAC2', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Faculty', 1, 'Active', 'd.kim@university.edu'),
(7, 'Prof. Amanda Wilson', 'FAC3', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Faculty', 1, 'Active', 'a.wilson@university.edu'),
(8, 'Prof. James Rodriguez', 'FAC4', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Faculty', 2, 'Active', 'j.rodriguez@university.edu'),
(9, 'Prof. Lisa Thompson', 'FAC5', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Faculty', 3, 'Active', 'l.thompson@university.edu'),
(10, 'Prof. Mark Davis', 'FAC6', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Faculty', 4, 'Active', 'm.davis@university.edu'),
(12, 'System Administrator', 'ADMIN001', 'ee79976c9380d5e337fc1c095ece8c8f22f91f306ceeb161fa51fecede2c4ba1', 'Admin', NULL, 'Inactive', 'admin@university.edu');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `classes`
--
ALTER TABLE `classes`
  ADD PRIMARY KEY (`ClassID`),
  ADD KEY `classes_ibfk_1` (`CourseID`);

--
-- Indexes for table `courses`
--
ALTER TABLE `courses`
  ADD PRIMARY KEY (`CourseID`),
  ADD KEY `DeptID` (`DepartmentID`);

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`DepartmentID`),
  ADD UNIQUE KEY `Name` (`DepartmentName`);

--
-- Indexes for table `evaluationcycles`
--
ALTER TABLE `evaluationcycles`
  ADD PRIMARY KEY (`CycleID`);

--
-- Indexes for table `evaluationdomains`
--
ALTER TABLE `evaluationdomains`
  ADD PRIMARY KEY (`DomainID`),
  ADD UNIQUE KEY `DomainName` (`DomainName`);

--
-- Indexes for table `evaluationquestions`
--
ALTER TABLE `evaluationquestions`
  ADD PRIMARY KEY (`QuestionID`),
  ADD KEY `fk_eval_domain` (`DomainID`);

--
-- Indexes for table `evaluations`
--
ALTER TABLE `evaluations`
  ADD PRIMARY KEY (`EvalID`),
  ADD KEY `fk_eval_load` (`LoadID`),
  ADD KEY `fk_eval_question` (`QuestionID`),
  ADD KEY `idx_evaluations_LoadID` (`LoadID`),
  ADD KEY `idx_evaluations_QuestionID` (`QuestionID`),
  ADD KEY `evaluations_ibfk_1` (`SubmissionID`),
  ADD KEY `FK_evaluations_Cycle` (`CycleID`);

--
-- Indexes for table `evaluationsubmissions`
--
ALTER TABLE `evaluationsubmissions`
  ADD PRIMARY KEY (`SubmissionID`),
  ADD UNIQUE KEY `uq_evalsubmission` (`LoadID`,`StudentID`,`CycleID`),
  ADD KEY `fk_sub_student` (`StudentID`),
  ADD KEY `idx_evaluationsubmissions_LoadID` (`LoadID`),
  ADD KEY `FK_EvalSubmissions_Cycle` (`CycleID`);

--
-- Indexes for table `facultyload`
--
ALTER TABLE `facultyload`
  ADD PRIMARY KEY (`LoadID`),
  ADD KEY `facultyload_ibfk_1` (`FacultyID`),
  ADD KEY `facultyload_ibfk_2` (`CourseID`),
  ADD KEY `facultyload_ibfk_3` (`SubjectID`),
  ADD KEY `facultyload_ibfk_4` (`ClassID`),
  ADD KEY `fk_facultyload_department` (`DepartmentID`),
  ADD KEY `idx_facultyload_FacultyID` (`FacultyID`),
  ADD KEY `idx_facultyload_DepartmentID` (`DepartmentID`),
  ADD KEY `idx_facultyload_CourseID` (`CourseID`),
  ADD KEY `idx_facultyload_SubjectID` (`SubjectID`);

--
-- Indexes for table `passwordresettokens`
--
ALTER TABLE `passwordresettokens`
  ADD PRIMARY KEY (`TokenID`),
  ADD KEY `SchoolID` (`SchoolID`);

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`StudentID`),
  ADD UNIQUE KEY `SchoolID` (`SchoolID`),
  ADD KEY `FK_Students_Classes` (`ClassID`),
  ADD KEY `students_ibfk_2` (`CourseID`),
  ADD KEY `students_ibfk_1` (`DepartmentID`);

--
-- Indexes for table `subjects`
--
ALTER TABLE `subjects`
  ADD PRIMARY KEY (`SubjectID`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`UserID`),
  ADD UNIQUE KEY `SchoolID` (`SchoolID`),
  ADD KEY `fk_users_department` (`DepartmentID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `classes`
--
ALTER TABLE `classes`
  MODIFY `ClassID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT for table `courses`
--
ALTER TABLE `courses`
  MODIFY `CourseID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `DepartmentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `evaluationcycles`
--
ALTER TABLE `evaluationcycles`
  MODIFY `CycleID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `evaluationdomains`
--
ALTER TABLE `evaluationdomains`
  MODIFY `DomainID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `evaluationquestions`
--
ALTER TABLE `evaluationquestions`
  MODIFY `QuestionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `evaluations`
--
ALTER TABLE `evaluations`
  MODIFY `EvalID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2004;

--
-- AUTO_INCREMENT for table `evaluationsubmissions`
--
ALTER TABLE `evaluationsubmissions`
  MODIFY `SubmissionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=89;

--
-- AUTO_INCREMENT for table `facultyload`
--
ALTER TABLE `facultyload`
  MODIFY `LoadID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT for table `passwordresettokens`
--
ALTER TABLE `passwordresettokens`
  MODIFY `TokenID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `StudentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT for table `subjects`
--
ALTER TABLE `subjects`
  MODIFY `SubjectID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `classes`
--
ALTER TABLE `classes`
  ADD CONSTRAINT `classes_ibfk_1` FOREIGN KEY (`CourseID`) REFERENCES `courses` (`CourseID`) ON DELETE CASCADE;

--
-- Constraints for table `courses`
--
ALTER TABLE `courses`
  ADD CONSTRAINT `DeptID` FOREIGN KEY (`DepartmentID`) REFERENCES `departments` (`DepartmentID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `evaluationquestions`
--
ALTER TABLE `evaluationquestions`
  ADD CONSTRAINT `fk_eval_domain` FOREIGN KEY (`DomainID`) REFERENCES `evaluationdomains` (`DomainID`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `evaluations`
--
ALTER TABLE `evaluations`
  ADD CONSTRAINT `FK_evaluations_Cycle` FOREIGN KEY (`CycleID`) REFERENCES `evaluationcycles` (`CycleID`),
  ADD CONSTRAINT `evaluations_ibfk_1` FOREIGN KEY (`SubmissionID`) REFERENCES `evaluationsubmissions` (`SubmissionID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `evaluations_ibfk_2` FOREIGN KEY (`QuestionID`) REFERENCES `evaluationquestions` (`QuestionID`) ON DELETE SET NULL ON UPDATE SET NULL,
  ADD CONSTRAINT `fk_eval_load` FOREIGN KEY (`LoadID`) REFERENCES `facultyload` (`LoadID`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `evaluationsubmissions`
--
ALTER TABLE `evaluationsubmissions`
  ADD CONSTRAINT `FK_EvalSubmissions_Cycle` FOREIGN KEY (`CycleID`) REFERENCES `evaluationcycles` (`CycleID`),
  ADD CONSTRAINT `fk_evalsub_student` FOREIGN KEY (`StudentID`) REFERENCES `students` (`StudentID`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_sub_load` FOREIGN KEY (`LoadID`) REFERENCES `facultyload` (`LoadID`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `facultyload`
--
ALTER TABLE `facultyload`
  ADD CONSTRAINT `facultyload_ibfk_1` FOREIGN KEY (`FacultyID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `facultyload_ibfk_2` FOREIGN KEY (`CourseID`) REFERENCES `courses` (`CourseID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `facultyload_ibfk_3` FOREIGN KEY (`SubjectID`) REFERENCES `subjects` (`SubjectID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `facultyload_ibfk_4` FOREIGN KEY (`ClassID`) REFERENCES `classes` (`ClassID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_facultyload_department` FOREIGN KEY (`DepartmentID`) REFERENCES `departments` (`DepartmentID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `students`
--
ALTER TABLE `students`
  ADD CONSTRAINT `students_ibfk_1` FOREIGN KEY (`DepartmentID`) REFERENCES `departments` (`DepartmentID`) ON DELETE CASCADE,
  ADD CONSTRAINT `students_ibfk_2` FOREIGN KEY (`CourseID`) REFERENCES `courses` (`CourseID`) ON DELETE CASCADE,
  ADD CONSTRAINT `students_ibfk_3` FOREIGN KEY (`ClassID`) REFERENCES `classes` (`ClassID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_department` FOREIGN KEY (`DepartmentID`) REFERENCES `departments` (`DepartmentID`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
