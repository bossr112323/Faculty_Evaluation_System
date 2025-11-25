-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 25, 2025 at 10:35 AM
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
-- Database: `evaluation_systemdb`
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
(3, 1, '2ND', 'A', 1),
(4, 2, '1ST', 'A', 1),
(8, 5, '1ST', 'B', 1),
(48, 2, '2ND', 'A', 1),
(50, 5, '2ND', 'A', 1),
(58, 1, '3RD', 'A', 1),
(60, 1, '4TH', 'B', 1),
(66, 37, '1ST', 'A', 1),
(72, 5, '3RD', 'D', 1),
(73, 2, '1ST', 'B', 1),
(74, 2, '1ST', 'C', 1),
(75, 2, '1ST', 'D', 1),
(76, 2, '1ST', 'E', 1),
(77, 2, '1ST', 'F', 1),
(78, 2, '1ST', 'G', 1),
(79, 2, '1ST', 'H', 1),
(80, 2, '1ST', 'I', 1),
(81, 2, '1ST', 'J', 1),
(82, 2, '1ST', 'K', 1),
(83, 2, '1ST', 'L', 1),
(84, 2, '1ST', 'M', 1),
(85, 2, '1ST', 'N', 1),
(86, 2, '1ST', 'O', 1),
(87, 2, '1ST', 'P', 1),
(88, 2, '1ST', 'Q', 1),
(89, 2, '1ST', 'R', 1),
(90, 2, '1ST', 'S', 1),
(91, 5, '1ST', 'A', 1),
(92, 4, '1ST', 'A', 1),
(93, 4, '1ST', 'B', 1),
(94, 4, '1ST', 'C', 1),
(95, 4, '1ST', 'D', 1),
(96, 4, '1ST', 'E', 1),
(97, 4, '1ST', 'F', 1),
(98, 4, '1ST', 'G', 1),
(99, 1, '1ST', 'B', 1);

-- --------------------------------------------------------

--
-- Table structure for table `courses`
--

CREATE TABLE `courses` (
  `CourseID` int(11) NOT NULL,
  `CourseName` varchar(100) NOT NULL,
  `DepartmentID` int(11) NOT NULL,
  `YearLevels` int(11) NOT NULL DEFAULT 4,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `courses`
--

INSERT INTO `courses` (`CourseID`, `CourseName`, `DepartmentID`, `YearLevels`, `IsActive`) VALUES
(1, 'Bachelor of Science in Information Technology', 1, 4, 1),
(2, 'Bachelor of Science in Computer Science', 1, 4, 1),
(4, 'Bachelor of Science in Business Administration', 3, 4, 1),
(5, 'Bachelor of Elementary Education', 4, 4, 1),
(36, 'Bachelor of Education Major in English', 4, 4, 1),
(37, 'Associate in Computer Science', 1, 2, 1);

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
(1, 'College of Information Technology Education', 1),
(3, 'College of Business Administration', 1),
(4, 'College of Education', 1),
(14, 'College of Criminology', 1);

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
(18, '1st Semester', 'Inactive', '2025-10-22', '2025-11-06', 'S.Y. 2025-2026', 1, 1),
(25, '2nd Semester', 'Inactive', '2025-11-16', '2025-11-19', 'S.Y 2025-2026', 1, 1);

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
(17, 'Classroom and Student Management', 25, b'1'),
(18, 'Instructional Competence', 25, b'1'),
(19, 'Professionalism and Ethics', 25, b'1'),
(20, 'Spiritual and Values Integration and Leadership', 25, b'1');

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
(36, 'Models biblical/ servant leadership.', 5, 20, b'1'),
(37, 'Demonstrate ethical decision-making in his/ her approach to teaching.', 5, 20, b'1'),
(38, 'Models and promote the Core Values of GWC - integrity, godliness, diligence, excellence, compassion, accessibility, Cristian virtue and transformation.', 5, 20, b'1'),
(39, 'Encourage moral and spiritual formation among students.', 5, 20, b'1'),
(40, 'Integrates Vision, Mission and Core Values of GWC in teaching where applicable.', 5, 20, b'1'),
(41, 'Comes to class with well-prepared lessons.', 5, 18, b'1'),
(42, 'Presents lessons clearly and understandably.', 5, 18, b'1'),
(43, 'Demonstrates mastery of the subject matter.', 5, 18, b'1'),
(44, 'Uses appropriate teaching strategies and instructional materials.', 5, 18, b'1'),
(45, 'Encourages critical thinking and active participation.', 5, 18, b'1'),
(46, 'Assesses student performance fairly and regularly.', 5, 18, b'1'),
(47, 'Utilizes multiple assessment strategies and tools.', 5, 18, b'1'),
(48, 'Provides prompt and meaningful feedback about performance and progress.', 5, 18, b'1'),
(49, 'Displays interest on the subject matter, encourages and supports your effort to learn and improve.', 5, 18, b'1'),
(50, 'Maintains discipline and a respectful classroom environment regardless of beliefs, value systems and lifestyles.', 5, 17, b'1'),
(51, 'Addresses student concerns appropriately.', 5, 17, b'1'),
(52, 'Starts and ends classes on time.', 5, 17, b'1'),
(53, 'Implements and promotes stewardship of properties and materials being used.', 5, 17, b'1'),
(54, 'Conducts himself/herself in the classroom professionally, creating a respectful environment.', 5, 17, b'1'),
(55, 'Demonstrates punctuality and regular attendance.', 5, 19, b'1'),
(56, 'Dresses appropriately and professionally.', 5, 19, b'1'),
(57, 'Observes confidentiality and integrity.', 5, 19, b'1'),
(58, 'Shows respect to colleagues, students, and administrators.', 5, 19, b'1'),
(59, 'Exemplifies teamwork and support to the institutional ways and processes to help deliver quality education to stakeholders', 5, 19, b'1'),
(60, 'Displays hard work, discipline, perseveres to deliver high-quality education to students.', 5, 19, b'1'),
(61, 'Actively seeks and responds to feedback to improve his/her teaching methods.', 5, 19, b'1');

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
  `CycleID` int(11) NOT NULL,
  `IsReleased` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `evaluationsubmissions`
--

CREATE TABLE `evaluationsubmissions` (
  `SubmissionID` int(11) NOT NULL,
  `LoadID` int(11) DEFAULT NULL,
  `StudentID` int(11) DEFAULT NULL,
  `SubmissionDate` datetime NOT NULL,
  `CycleID` int(11) NOT NULL,
  `AverageScore` decimal(5,2) DEFAULT NULL,
  `Strengths` text DEFAULT NULL,
  `Weaknesses` text DEFAULT NULL,
  `AdditionalMessage` text DEFAULT NULL,
  `IsReleased` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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

-- --------------------------------------------------------

--
-- Table structure for table `gradefiles`
--

CREATE TABLE `gradefiles` (
  `FileID` int(11) NOT NULL,
  `LoadID` int(11) NOT NULL,
  `CycleID` int(11) NOT NULL,
  `FileName` varchar(255) NOT NULL,
  `FilePath` varchar(500) NOT NULL,
  `FileSize` int(11) NOT NULL,
  `MimeType` varchar(100) NOT NULL,
  `SubmissionDate` datetime NOT NULL DEFAULT current_timestamp(),
  `Status` enum('Pending','Approved','Rejected') DEFAULT 'Pending',
  `Remarks` text DEFAULT NULL,
  `ReviewedBy` int(11) DEFAULT NULL,
  `ReviewedDate` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `gradesubmissions`
--

CREATE TABLE `gradesubmissions` (
  `SubmissionID` int(11) NOT NULL,
  `LoadID` int(11) NOT NULL,
  `CycleID` int(11) NOT NULL,
  `SubmissionDate` datetime NOT NULL DEFAULT current_timestamp(),
  `Status` enum('Submitted','Confirmed','Rejected') NOT NULL DEFAULT 'Submitted',
  `SubmittedBy` int(11) DEFAULT NULL,
  `FileID` int(11) DEFAULT NULL,
  `Remarks` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `irregular_student_enrollments`
--

CREATE TABLE `irregular_student_enrollments` (
  `EnrollmentID` int(11) NOT NULL,
  `StudentID` int(11) NOT NULL,
  `LoadID` int(11) NOT NULL,
  `CycleID` int(11) NOT NULL,
  `EnrollmentDate` datetime DEFAULT current_timestamp(),
  `IsApproved` tinyint(1) DEFAULT 0 COMMENT '0=Pending, 1=Approved, 2=Rejected',
  `ApprovedBy` int(11) DEFAULT NULL,
  `ApprovalDate` datetime DEFAULT NULL,
  `Remarks` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `StudentID` int(11) NOT NULL,
  `LastName` varchar(100) NOT NULL,
  `MiddleInitial` varchar(20) DEFAULT NULL,
  `FirstName` varchar(100) NOT NULL,
  `Suffix` varchar(15) DEFAULT NULL,
  `Email` varchar(100) NOT NULL,
  `SchoolID` varchar(50) NOT NULL,
  `Password` varchar(100) NOT NULL,
  `DepartmentID` int(11) NOT NULL,
  `CourseID` int(11) DEFAULT NULL,
  `Status` enum('Active','Inactive','Graduated') DEFAULT 'Active',
  `ClassID` int(11) DEFAULT NULL,
  `StudentType` enum('Regular','Irregular') DEFAULT 'Regular',
  `IsApprovedForEvaluation` tinyint(1) DEFAULT 1,
  `FirstLogin` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
(1, 'Introduction to Computing', 'CC101', 1),
(2, 'Fundamentals of Programing', 'CC102', 1),
(3, 'Understanding the Self', 'PSYCH1', 1),
(4, 'Data Structures and Algorithms', 'DSA101', 1),
(8, 'Intermediate Programming', 'CC103', 1),
(9, 'Ethics', 'PHILO1', 1),
(10, 'Purposive Communication', 'ENGL1', 1),
(11, 'Filipino sa iba\'t-ibang disiplina', 'Fil2', 1),
(12, 'Kontekstwalisadong Komunikasyon sa Filipino', 'Fil1', 1),
(14, 'Movement Enhancement', 'PE1', 1),
(17, 'Fitness Exercise', 'PE2', 1),
(18, 'Data Structure and Algorithms', 'CC104', 1);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `UserID` int(11) NOT NULL,
  `LastName` varchar(100) NOT NULL,
  `FirstName` varchar(100) NOT NULL,
  `MiddleInitial` varchar(20) NOT NULL,
  `Suffix` varchar(15) DEFAULT NULL,
  `SchoolID` varchar(50) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Role` enum('Student','Faculty','Dean','Admin','Registrar') NOT NULL,
  `DepartmentID` int(100) DEFAULT NULL,
  `Status` enum('Active','Inactive') DEFAULT 'Active',
  `Email` varchar(100) DEFAULT NULL,
  `FirstLogin` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`UserID`, `LastName`, `FirstName`, `MiddleInitial`, `Suffix`, `SchoolID`, `Password`, `Role`, `DepartmentID`, `Status`, `Email`, `FirstLogin`) VALUES
(47, 'Admin', 'System', '', NULL, '1230000001', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', 'Admin', NULL, 'Active', 'facultyevaluation2025@gmail.com', 0);

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
  ADD PRIMARY KEY (`DomainID`);

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
-- Indexes for table `gradefiles`
--
ALTER TABLE `gradefiles`
  ADD PRIMARY KEY (`FileID`),
  ADD KEY `LoadID` (`LoadID`),
  ADD KEY `CycleID` (`CycleID`),
  ADD KEY `ReviewedBy` (`ReviewedBy`);

--
-- Indexes for table `gradesubmissions`
--
ALTER TABLE `gradesubmissions`
  ADD PRIMARY KEY (`SubmissionID`),
  ADD UNIQUE KEY `UQ_Gradesubmissions_Load_Cycle` (`LoadID`,`CycleID`),
  ADD KEY `FK_Gradesubmissions_FacultyLoad` (`LoadID`),
  ADD KEY `FK_Gradesubmissions_EvalCycle` (`CycleID`),
  ADD KEY `FileID` (`FileID`);

--
-- Indexes for table `irregular_student_enrollments`
--
ALTER TABLE `irregular_student_enrollments`
  ADD PRIMARY KEY (`EnrollmentID`),
  ADD KEY `StudentID` (`StudentID`),
  ADD KEY `LoadID` (`LoadID`),
  ADD KEY `CycleID` (`CycleID`),
  ADD KEY `ApprovedBy` (`ApprovedBy`);

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
  MODIFY `ClassID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=100;

--
-- AUTO_INCREMENT for table `courses`
--
ALTER TABLE `courses`
  MODIFY `CourseID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `DepartmentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `evaluationcycles`
--
ALTER TABLE `evaluationcycles`
  MODIFY `CycleID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `evaluationdomains`
--
ALTER TABLE `evaluationdomains`
  MODIFY `DomainID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `evaluationquestions`
--
ALTER TABLE `evaluationquestions`
  MODIFY `QuestionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=62;

--
-- AUTO_INCREMENT for table `evaluations`
--
ALTER TABLE `evaluations`
  MODIFY `EvalID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3654;

--
-- AUTO_INCREMENT for table `evaluationsubmissions`
--
ALTER TABLE `evaluationsubmissions`
  MODIFY `SubmissionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=174;

--
-- AUTO_INCREMENT for table `facultyload`
--
ALTER TABLE `facultyload`
  MODIFY `LoadID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=106;

--
-- AUTO_INCREMENT for table `gradefiles`
--
ALTER TABLE `gradefiles`
  MODIFY `FileID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `gradesubmissions`
--
ALTER TABLE `gradesubmissions`
  MODIFY `SubmissionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=93;

--
-- AUTO_INCREMENT for table `irregular_student_enrollments`
--
ALTER TABLE `irregular_student_enrollments`
  MODIFY `EnrollmentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `passwordresettokens`
--
ALTER TABLE `passwordresettokens`
  MODIFY `TokenID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `StudentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

--
-- AUTO_INCREMENT for table `subjects`
--
ALTER TABLE `subjects`
  MODIFY `SubjectID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

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
  ADD CONSTRAINT `facultyload_ibfk_2` FOREIGN KEY (`CourseID`) REFERENCES `courses` (`CourseID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `facultyload_ibfk_3` FOREIGN KEY (`SubjectID`) REFERENCES `subjects` (`SubjectID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `facultyload_ibfk_4` FOREIGN KEY (`ClassID`) REFERENCES `classes` (`ClassID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_facultyload_department` FOREIGN KEY (`DepartmentID`) REFERENCES `departments` (`DepartmentID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `gradefiles`
--
ALTER TABLE `gradefiles`
  ADD CONSTRAINT `gradefiles_ibfk_1` FOREIGN KEY (`LoadID`) REFERENCES `facultyload` (`LoadID`),
  ADD CONSTRAINT `gradefiles_ibfk_2` FOREIGN KEY (`CycleID`) REFERENCES `evaluationcycles` (`CycleID`),
  ADD CONSTRAINT `gradefiles_ibfk_3` FOREIGN KEY (`ReviewedBy`) REFERENCES `users` (`UserID`);

--
-- Constraints for table `gradesubmissions`
--
ALTER TABLE `gradesubmissions`
  ADD CONSTRAINT `FK_Gradesubmissions_EvalCycle` FOREIGN KEY (`CycleID`) REFERENCES `evaluationcycles` (`CycleID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Gradesubmissions_FacultyLoad` FOREIGN KEY (`LoadID`) REFERENCES `facultyload` (`LoadID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `gradesubmissions_ibfk_1` FOREIGN KEY (`FileID`) REFERENCES `gradefiles` (`FileID`);

--
-- Constraints for table `irregular_student_enrollments`
--
ALTER TABLE `irregular_student_enrollments`
  ADD CONSTRAINT `irregular_student_enrollments_ibfk_1` FOREIGN KEY (`StudentID`) REFERENCES `students` (`StudentID`),
  ADD CONSTRAINT `irregular_student_enrollments_ibfk_2` FOREIGN KEY (`LoadID`) REFERENCES `facultyload` (`LoadID`),
  ADD CONSTRAINT `irregular_student_enrollments_ibfk_3` FOREIGN KEY (`CycleID`) REFERENCES `evaluationcycles` (`CycleID`),
  ADD CONSTRAINT `irregular_student_enrollments_ibfk_4` FOREIGN KEY (`ApprovedBy`) REFERENCES `users` (`UserID`);

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
