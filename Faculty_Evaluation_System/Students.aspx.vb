Imports System.Data
Imports System.Security.Cryptography
Imports System.Text
Imports System.Net.Mail
Imports MySql.Data.MySqlClient
Imports System.IO
Imports System.Text.RegularExpressions

Public Class Students
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return System.Configuration.ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    ' Add email configuration properties
    Private ReadOnly Property SmtpServer As String
        Get
            Return System.Configuration.ConfigurationManager.AppSettings("SMTPServer") ' Match case
        End Get
    End Property

    Private ReadOnly Property SmtpPort As Integer
        Get
            Return Integer.Parse(System.Configuration.ConfigurationManager.AppSettings("SMTPPort")) ' Match case
        End Get
    End Property

    Private ReadOnly Property SmtpUsername As String
        Get
            Return System.Configuration.ConfigurationManager.AppSettings("SMTPUsername") ' Match case
        End Get
    End Property

    Private ReadOnly Property SmtpPassword As String
        Get
            Return System.Configuration.ConfigurationManager.AppSettings("SMTPPassword") ' Match case
        End Get
    End Property

    Private ReadOnly Property SmtpEnableSSL As Boolean
        Get
            Return Boolean.Parse(System.Configuration.ConfigurationManager.AppSettings("SMTPEnableSSL")) ' Match case
        End Get
    End Property

    ' Add the missing FromEmail property
    Private ReadOnly Property FromEmail As String
        Get
            Return "facultyevaluation2025@gmail.com" ' Hardcode since it's not in Web.config
        End Get
    End Property
    Private ReadOnly Property BaseUrl As String
        Get
            Return "https://madge-intensional-tanna.ngrok-free.dev"
        End Get
    End Property
    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        ' Authentication check
        If Session("Role") Is Nothing OrElse Session("Role").ToString() <> "Admin" Then
            Response.Redirect("Login.aspx")
        End If

        If Not IsPostBack Then
            LoadCourses()
            LoadEditCourses()
            BindStudents()
            UpdateSidebarBadges()
        Else
            ' Clear previous messages on postback
            lblMessage.Text = ""
            lblMessage.CssClass = "alert d-none"

            ' Check if this is a course selection postback
            Dim isCourseSelection As Boolean = Request.Form("__EVENTTARGET") IsNot Nothing AndAlso
                                          Request.Form("__EVENTTARGET").Contains(ddlCourse.UniqueID)

            If isCourseSelection Then
                ' For course selection, reset modal flags but don't force close
                ScriptManager.RegisterStartupScript(Me, Me.GetType(), "ResetModalForCourse",
                "userManuallyClosed = false; shouldKeepModalOpen = false;", True)
            End If
        End If

        lblWelcome.Text = Session("FullName").ToString()
    End Sub

    Private Function IsAddStudentPostBack() As Boolean
        Return Request.Form("__EVENTTARGET") = btnAddStudent.UniqueID
    End Function

#Region "CSV Import Functionality"
    Protected Sub btnImportCSV_Click(sender As Object, e As EventArgs)
        System.Diagnostics.Debug.WriteLine("Import button clicked")

        ' Clear previous messages
        lblImportMessage.Text = ""
        lblImportMessage.CssClass = "alert d-none"

        Try
            ' Validate file selection
            If Not fuCSV.HasFile Then
                ShowImportMessage("⚠ Please select a CSV file to upload.", "danger")
                Return
            End If

            ' Validate file extension
            Dim fileExtension As String = Path.GetExtension(fuCSV.FileName).ToLower()
            If fileExtension <> ".csv" Then
                ShowImportMessage("⚠ Please upload a valid CSV file. Selected: " & fileExtension, "danger")
                Return
            End If

            ' Validate file size
            If fuCSV.PostedFile.ContentLength > 10485760 Then ' 10MB
                ShowImportMessage("⚠ File size exceeds 10MB limit.", "danger")
                Return
            End If

            ' Show processing message
            ShowImportMessage("🔄 Reading and processing CSV file...", "info")

            ' Process CSV file
            Dim results As ImportResults = ProcessCSVFile(fuCSV.FileContent)

            ' Build results message
            Dim resultMessage As New StringBuilder()
            resultMessage.AppendLine($"<strong>✅ CSV Import Completed!</strong><br/>")
            resultMessage.AppendLine($"• Total records processed: {results.ProcessedCount}<br/>")
            resultMessage.AppendLine($"• New students added: {results.AddedCount}<br/>")
            resultMessage.AppendLine($"• Existing students updated: {results.UpdatedCount}<br/>")
            resultMessage.AppendLine($"• Records skipped: {results.SkippedCount}<br/>")

            If results.Errors.Count > 0 Then
                resultMessage.AppendLine($"<br/><strong>❌ Errors ({results.Errors.Count}):</strong><br/>")
                For i As Integer = 0 To Math.Min(results.Errors.Count - 1, 9) ' Show first 10 errors
                    resultMessage.AppendLine($"• {results.Errors(i)}<br/>")
                Next
                If results.Errors.Count > 10 Then
                    resultMessage.AppendLine($"• ... and {results.Errors.Count - 10} more errors<br/>")
                End If
            End If

            ' Show final results
            ShowImportMessage(resultMessage.ToString(), If(results.Errors.Count > 0, "warning", "success"))

            ' Refresh student grid
            BindStudents()

            ' IMPORTANT: Clear the file upload control
            ClearFileUpload()

        Catch ex As Exception
            ' Show detailed error
            Dim errorMessage As String = $"❌ Error processing CSV file: {ex.Message}"
            If ex.InnerException IsNot Nothing Then
                errorMessage &= $"<br/>Details: {ex.InnerException.Message}"
            End If
            ShowImportMessage(errorMessage, "danger")

            System.Diagnostics.Debug.WriteLine($"Import Error: {ex.Message}")
            System.Diagnostics.Debug.WriteLine($"Stack Trace: {ex.StackTrace}")
        Finally
            ' Reset button state using JavaScript
            ScriptManager.RegisterStartupScript(Me, Me.GetType(), "ResetImportButton", "resetImportButton();", True)
        End Try
    End Sub

    ' Add this method to clear the file upload
    Private Sub ClearFileUpload()
        ' Clear the file upload control by replacing it
        fuCSV.Attributes.Clear()

        ' Register script to clear the file input on client side
        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "ClearFileInput", "clearFileInput();", True)
    End Sub


    ' Add this helper method to reset the import button from server side
    Private Sub ResetImportButton()
        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "ResetImportButton", "resetImportButton();", True)
    End Sub

    Private Sub ShowImportMessage(message As String, type As String)
        lblImportMessage.Text = message
        lblImportMessage.CssClass = $"alert alert-{type} d-block"

        ' Also show in main message area for better visibility
        If type = "danger" Or type = "warning" Then
            lblMessage.Text = message
            lblMessage.CssClass = $"alert alert-{type} d-block"
        End If
    End Sub

    Private Function ProcessCSVFile(fileContent As Stream) As ImportResults
        Dim results As New ImportResults()

        Using reader As New StreamReader(fileContent)
            ' Read and validate header
            Dim headerLine As String = reader.ReadLine()
            If String.IsNullOrEmpty(headerLine) Then
                results.Errors.Add("CSV file is empty")
                Return results
            End If

            ' Validate header format
            If Not ValidateCSVContent(headerLine) Then
                results.Errors.Add("Invalid CSV format. Please use the provided template.")
                Return results
            End If

            ' Process data rows
            Dim lineNumber As Integer = 1 ' Header is line 1
            While Not reader.EndOfStream
                lineNumber += 1
                Dim dataLine As String = reader.ReadLine()

                If String.IsNullOrWhiteSpace(dataLine) Then Continue While

                Try
                    Dim data As String() = ParseCSVLine(dataLine)

                    ' Validate minimum required columns
                    If data.Length < 7 Then
                        results.Errors.Add($"Line {lineNumber}: Insufficient columns. Expected at least 7, found {data.Length}")
                        results.SkippedCount += 1
                        Continue While
                    End If

                    ' Map CSV data to student fields - CORRECTED MAPPING
                    Dim student As New StudentData With {
    .LastName = data(0).Trim(),
    .FirstName = data(1).Trim(),
    .MiddleInitial = If(data.Length > 2, data(2).Trim(), ""),
    .Suffix = If(data.Length > 3, data(3).Trim(), ""),
    .SchoolID = data(4).Trim(),
    .Email = data(5).Trim(),
    .CourseName = data(6).Trim(),
    .YearLevel = If(data.Length > 7, data(7).Trim(), "1ST"),
    .Section = If(data.Length > 8, data(8).Trim(), "A"),
    .StudentType = If(data.Length > 9, data(9).Trim(), "Regular") ' Default to Regular
}

                    ' Validate required fields
                    If String.IsNullOrWhiteSpace(student.LastName) OrElse
                   String.IsNullOrWhiteSpace(student.FirstName) OrElse
                   String.IsNullOrWhiteSpace(student.SchoolID) OrElse
                   String.IsNullOrWhiteSpace(student.Email) OrElse
                   String.IsNullOrWhiteSpace(student.CourseName) Then

                        results.Errors.Add($"Line {lineNumber}: Missing required fields")
                        results.SkippedCount += 1
                        Continue While
                    End If

                    ' Validate email format
                    If Not IsValidEmail(student.Email) Then
                        results.Errors.Add($"Line {lineNumber}: Invalid email format: {student.Email}")
                        results.SkippedCount += 1
                        Continue While
                    End If

                    ' Process student record
                    ProcessStudentRecord(student, results, lineNumber)

                Catch ex As Exception
                    results.Errors.Add($"Line {lineNumber}: {ex.Message}")
                    results.SkippedCount += 1
                End Try
            End While
        End Using

        Return results
    End Function

    Private Function ParseCSVLine(line As String) As String()
        Dim result As New List(Of String)()
        Dim currentField As New StringBuilder()
        Dim inQuotes As Boolean = False

        For i As Integer = 0 To line.Length - 1
            Dim c As Char = line(i)

            If c = """"c Then
                If inQuotes AndAlso i < line.Length - 1 AndAlso line(i + 1) = """"c Then
                    ' Escaped quote
                    currentField.Append("""")
                    i += 1 ' Skip next quote
                Else
                    inQuotes = Not inQuotes
                End If
            ElseIf c = ","c AndAlso Not inQuotes Then
                result.Add(currentField.ToString())
                currentField.Clear()
            Else
                currentField.Append(c)
            End If
        Next

        ' Add the last field
        result.Add(currentField.ToString())

        Return result.ToArray()
    End Function

    Private Function ValidateStudentData(student As StudentData) As Boolean
        Return Not (String.IsNullOrWhiteSpace(student.LastName) OrElse
                   String.IsNullOrWhiteSpace(student.FirstName) OrElse
                   String.IsNullOrWhiteSpace(student.SchoolID) OrElse
                   String.IsNullOrWhiteSpace(student.Email) OrElse
                   String.IsNullOrWhiteSpace(student.DepartmentName) OrElse
                   String.IsNullOrWhiteSpace(student.CourseName) OrElse
                   String.IsNullOrWhiteSpace(student.YearLevel))
    End Function

    Private Sub ProcessStudentRecord(student As StudentData, results As ImportResults, lineNumber As Integer)
        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Get CourseID from course name - FIXED: Now only using CourseName
            Dim courseInfo As Tuple(Of Integer, Integer) = GetCourseAndDepartmentID(conn, student.CourseName)
            If courseInfo Is Nothing OrElse courseInfo.Item1 = 0 Then
                results.Errors.Add($"Line {lineNumber}: Course not found: {student.CourseName}")
                results.SkippedCount += 1
                Return
            End If

            Dim courseID As Integer = courseInfo.Item1
            Dim departmentID As Integer = courseInfo.Item2

            ' Get or Create Class
            Dim classID As Integer = GetOrCreateClass(conn, courseID, student.YearLevel, student.Section)
            If classID = 0 Then
                results.Errors.Add($"Line {lineNumber}: Could not create class: {student.YearLevel}-{student.Section}")
                results.SkippedCount += 1
                Return
            End If

            ' Generate password
            Dim generatedPassword As String = GenerateRandomPassword()

            ' Check if student exists
            Dim existingStudentID As Integer = FindExistingStudentForCSV(conn, student.SchoolID, student.Email)

            If existingStudentID > 0 Then
                ' Update existing student
                If UpdateStudentFromCSV(conn, existingStudentID, student, classID, departmentID, courseID) Then
                    results.UpdatedCount += 1
                Else
                    results.Errors.Add($"Line {lineNumber}: Failed to update student: {student.SchoolID}")
                    results.SkippedCount += 1
                End If
            Else
                ' Insert new student
                If InsertStudentFromCSV(conn, student, classID, departmentID, courseID, generatedPassword) Then
                    ' Send email with credentials
                    If SendStudentCredentials(student, generatedPassword) Then
                        results.AddedCount += 1
                    Else
                        results.Errors.Add($"Line {lineNumber}: Student added but failed to send email: {student.Email}")
                        results.AddedCount += 1 ' Still count as added
                    End If
                Else
                    results.Errors.Add($"Line {lineNumber}: Failed to add student: {student.SchoolID}")
                    results.SkippedCount += 1
                End If
            End If

            results.ProcessedCount += 1
        End Using
    End Sub

    Private Function GetCourseAndDepartmentID(conn As MySqlConnection, courseName As String) As Tuple(Of Integer, Integer)
        Using cmd As New MySqlCommand("SELECT CourseID, DepartmentID FROM Courses WHERE CourseName = @CourseName AND IsActive=1", conn)
            cmd.Parameters.AddWithValue("@CourseName", courseName)
            Using reader As MySqlDataReader = cmd.ExecuteReader()
                If reader.Read() Then
                    Return New Tuple(Of Integer, Integer)(reader.GetInt32("CourseID"), reader.GetInt32("DepartmentID"))
                End If
            End Using
        End Using
        Return Nothing
    End Function

    Private Function GetOrCreateClass(conn As MySqlConnection, courseID As Integer, yearLevel As String, section As String) As Integer
        ' Try to get existing class
        Using cmd As New MySqlCommand("SELECT ClassID FROM Classes WHERE CourseID = @CourseID AND YearLevel = @YearLevel AND Section = @Section AND IsActive=1", conn)
            cmd.Parameters.AddWithValue("@CourseID", courseID)
            cmd.Parameters.AddWithValue("@YearLevel", yearLevel)
            cmd.Parameters.AddWithValue("@Section", section)
            Dim result = cmd.ExecuteScalar()

            If result IsNot Nothing Then
                Return Convert.ToInt32(result)
            End If
        End Using

        ' Create new class
        Using cmd As New MySqlCommand("INSERT INTO Classes (CourseID, YearLevel, Section, IsActive) VALUES (@CourseID, @YearLevel, @Section, 1); SELECT LAST_INSERT_ID();", conn)
            cmd.Parameters.AddWithValue("@CourseID", courseID)
            cmd.Parameters.AddWithValue("@YearLevel", yearLevel)
            cmd.Parameters.AddWithValue("@Section", section)
            Return Convert.ToInt32(cmd.ExecuteScalar())
        End Using
    End Function

    Private Function GetDepartmentID(conn As MySqlConnection, departmentName As String) As Integer
        Using cmd As New MySqlCommand("SELECT DepartmentID FROM Departments WHERE DepartmentName = @DepartmentName AND IsActive=1", conn)
            cmd.Parameters.AddWithValue("@DepartmentName", departmentName)
            Dim result = cmd.ExecuteScalar()
            Return If(result IsNot Nothing, Convert.ToInt32(result), 0)
        End Using
    End Function

    Private Function GetCourseID(conn As MySqlConnection, courseName As String, departmentID As Integer) As Integer
        Using cmd As New MySqlCommand("SELECT CourseID FROM Courses WHERE CourseName = @CourseName AND DepartmentID = @DepartmentID AND IsActive=1", conn)
            cmd.Parameters.AddWithValue("@CourseName", courseName)
            cmd.Parameters.AddWithValue("@DepartmentID", departmentID)
            Dim result = cmd.ExecuteScalar()
            Return If(result IsNot Nothing, Convert.ToInt32(result), 0)
        End Using
    End Function



    Private Function InsertStudentFromCSV(conn As MySqlConnection, student As StudentData, classID As Integer, departmentID As Integer, courseID As Integer, password As String) As Boolean
        Using cmd As New MySqlCommand("
        INSERT INTO Students (LastName, FirstName, MiddleInitial, Suffix, SchoolID, Email, Password, DepartmentID, CourseID, ClassID, Status)
        VALUES (@LastName, @FirstName, @MiddleInitial, @Suffix, @SchoolID, @Email, @Password, @DeptID, @CourseID, @ClassID, 'Active')", conn)

            cmd.Parameters.AddWithValue("@LastName", student.LastName)
            cmd.Parameters.AddWithValue("@FirstName", student.FirstName)
            cmd.Parameters.AddWithValue("@MiddleInitial", If(String.IsNullOrWhiteSpace(student.MiddleInitial), DBNull.Value, student.MiddleInitial))
            cmd.Parameters.AddWithValue("@Suffix", If(String.IsNullOrWhiteSpace(student.Suffix), DBNull.Value, student.Suffix))
            cmd.Parameters.AddWithValue("@SchoolID", student.SchoolID)
            cmd.Parameters.AddWithValue("@Email", student.Email.ToLower())
            cmd.Parameters.AddWithValue("@Password", HashPassword(password))
            cmd.Parameters.AddWithValue("@DeptID", departmentID)
            cmd.Parameters.AddWithValue("@CourseID", courseID)
            cmd.Parameters.AddWithValue("@ClassID", classID)

            Return cmd.ExecuteNonQuery() > 0
        End Using
    End Function


    Private Function ValidateCSVContent(headerLine As String) As Boolean
        Dim expectedHeaders As String() = {"LastName", "FirstName", "MiddleInitial", "Suffix", "SchoolID", "Email", "CourseName", "YearLevel", "Section"}
        Dim actualHeaders As String() = headerLine.Split(","c)

        If actualHeaders.Length < 7 Then
            Return False
        End If

        ' Check critical headers - now expecting CourseName at position 6
        If actualHeaders(0).Trim() <> "LastName" OrElse
       actualHeaders(1).Trim() <> "FirstName" OrElse
       actualHeaders(4).Trim() <> "SchoolID" OrElse
       actualHeaders(5).Trim() <> "Email" OrElse
       actualHeaders(6).Trim() <> "CourseName" Then
            Return False
        End If

        Return True
    End Function

    Private Function UpdateStudentFromCSV(conn As MySqlConnection, studentID As Integer, student As StudentData, classID As Integer, departmentID As Integer, courseID As Integer) As Boolean
        Using cmd As New MySqlCommand("
    UPDATE Students 
    SET LastName = @LastName, FirstName = @FirstName, MiddleInitial = @MiddleInitial, Suffix = @Suffix,
        Email = @Email, DepartmentID = @DepartmentID, CourseID = @CourseID, ClassID = @ClassID, Status = 'Active'
    WHERE StudentID = @StudentID", conn)

            cmd.Parameters.AddWithValue("@LastName", student.LastName)
            cmd.Parameters.AddWithValue("@FirstName", student.FirstName)
            cmd.Parameters.AddWithValue("@MiddleInitial", If(String.IsNullOrWhiteSpace(student.MiddleInitial), DBNull.Value, student.MiddleInitial))
            cmd.Parameters.AddWithValue("@Suffix", If(String.IsNullOrWhiteSpace(student.Suffix), DBNull.Value, student.Suffix))
            cmd.Parameters.AddWithValue("@Email", student.Email.ToLower())
            cmd.Parameters.AddWithValue("@DepartmentID", departmentID)
            cmd.Parameters.AddWithValue("@CourseID", courseID)
            cmd.Parameters.AddWithValue("@ClassID", classID)
            cmd.Parameters.AddWithValue("@StudentID", studentID)

            Return cmd.ExecuteNonQuery() > 0
        End Using
    End Function

    Private Function GenerateRandomPassword() As String
        Const validChars As String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%"
        Dim random As New Random()
        Dim length As Integer = 12
        Dim chars = Enumerable.Repeat(validChars, length).Select(Function(s) s(random.Next(s.Length))).ToArray()
        Return New String(chars)
    End Function

    Private Function SendStudentCredentials(student As StudentData, password As String) As Boolean
        Try
            Using smtpClient As New SmtpClient(SmtpServer)
                smtpClient.Port = SmtpPort
                smtpClient.Credentials = New System.Net.NetworkCredential(SmtpUsername, SmtpPassword)
                smtpClient.EnableSsl = SmtpEnableSSL

                Dim mailMessage As New MailMessage()
                mailMessage.From = New MailAddress(FromEmail)
                mailMessage.To.Add(student.Email)
                mailMessage.Subject = "Your Student Account Credentials - Golden West Colleges"

                Dim emailBody As String = $"
Dear {student.FirstName} {student.LastName},

Your student account has been created successfully.

Here are your login credentials:
• School ID: {student.SchoolID}
• Password: {password}
• Login Portal: {BaseUrl}/Login.aspx

Please log in and change your password immediately for security.

Best regards,
Golden West Colleges Administration"

                mailMessage.Body = emailBody
                smtpClient.Send(mailMessage)
                Return True
            End Using
        Catch ex As Exception
            ' Log email error but don't fail the import
            System.Diagnostics.Debug.WriteLine($"Email sending failed for {student.Email}: {ex.Message}")
            Return False
        End Try
    End Function

    Protected Sub btnDownloadTemplate_Click(sender As Object, e As EventArgs)
        Dim csvTemplate As String = "LastName,FirstName,MiddleInitial,Suffix,SchoolID,Email,CourseName,YearLevel,Section,StudentType" & vbCrLf &
                       "Dela Cruz,Juan,A,Jr,2025-001,juan.delacruz@student.college.edu,Bachelor of Science in Information Technology,1ST,A,Regular" & vbCrLf &
                       "Santos,Maria,R,,2025-002,maria.santos@student.college.edu,Bachelor of Science in Computer Science,1ST,B,Irregular"

        Response.Clear()
        Response.Buffer = True
        Response.AddHeader("content-disposition", "attachment;filename=Student_Import_Template.csv")
        Response.Charset = ""
        Response.ContentType = "application/text"
        Response.Output.Write(csvTemplate)
        Response.Flush()
        Response.End()
    End Sub




#End Region

#Region "Supporting Classes for CSV Import"
    Public Class StudentData
        Public Property LastName As String
        Public Property FirstName As String
        Public Property MiddleInitial As String
        Public Property Suffix As String
        Public Property SchoolID As String
        Public Property Email As String
        Public Property DepartmentName As String
        Public Property CourseName As String
        Public Property YearLevel As String
        Public Property Section As String
        Public Property StudentType As String
    End Class

    Public Class ImportResults
        Public Property ProcessedCount As Integer
        Public Property AddedCount As Integer
        Public Property UpdatedCount As Integer
        Public Property SkippedCount As Integer
        Public Property Errors As New List(Of String)

        Public Sub New()
            ProcessedCount = 0
            AddedCount = 0
            UpdatedCount = 0
            SkippedCount = 0
        End Sub
    End Class
#End Region

#Region "Password Hashing"
    Private Function HashPassword(password As String) As String
        Using sha256 As SHA256 = SHA256.Create()
            Dim bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password))
            Return BitConverter.ToString(bytes).Replace("-", "").ToLower()
        End Using
    End Function
#End Region

#Region "Dropdown Loading Methods"
    Private Sub LoadCourses()
        ddlCourse.Items.Clear()
        ddlCourse.Items.Insert(0, New ListItem("Select Course", ""))

        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            ' Load all active courses without department grouping
            Using cmd As New MySqlCommand("
            SELECT CourseID, CourseName 
            FROM Courses 
            WHERE IsActive=1 
            ORDER BY CourseName", conn)

                Dim dt As New DataTable()
                Using da As New MySqlDataAdapter(cmd)
                    da.Fill(dt)
                End Using

                ddlCourse.DataSource = dt
                ddlCourse.DataTextField = "CourseName"
                ddlCourse.DataValueField = "CourseID"
                ddlCourse.DataBind()
            End Using
        End Using

        ddlCourse.Items.Insert(0, New ListItem("Select Course", ""))
    End Sub

    Private Sub LoadYearLevels()
        ddlYearLevel.Items.Clear()
        ddlYearLevel.Items.Insert(0, New ListItem("Select Year Level", ""))

        If String.IsNullOrEmpty(ddlCourse.SelectedValue) Then Exit Sub

        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Using cmd As New MySqlCommand("SELECT DISTINCT YearLevel FROM Classes WHERE CourseID = @CourseID AND IsActive=1 ORDER BY YearLevel", conn)
                cmd.Parameters.AddWithValue("@CourseID", ddlCourse.SelectedValue)
                Dim dt As New DataTable()
                Using da As New MySqlDataAdapter(cmd)
                    da.Fill(dt)
                End Using
                ddlYearLevel.DataSource = dt
                ddlYearLevel.DataTextField = "YearLevel"
                ddlYearLevel.DataValueField = "YearLevel"
                ddlYearLevel.DataBind()
            End Using
        End Using
        ddlYearLevel.Items.Insert(0, New ListItem("Select Year Level", ""))
    End Sub
#End Region

#Region "Autocomplete WebMethod"
    <System.Web.Services.WebMethod()>
    <System.Web.Script.Services.ScriptMethod(ResponseFormat:=System.Web.Script.Services.ResponseFormat.Json)>
    Public Shared Function GetSections(courseID As String, yearLevel As String, prefixText As String) As List(Of String)
        Dim sections As New List(Of String)()

        If String.IsNullOrEmpty(courseID) OrElse String.IsNullOrEmpty(yearLevel) Then
            Return sections
        End If

        Dim connString As String = System.Configuration.ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Using conn As New MySqlConnection(connString)
            Try
                conn.Open()
                Dim sql As String = "SELECT DISTINCT Section FROM Classes WHERE IsActive=1 AND CourseID = @CourseID AND YearLevel = @YearLevel AND Section LIKE @Prefix ORDER BY Section"

                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@CourseID", courseID)
                    cmd.Parameters.AddWithValue("@YearLevel", yearLevel)
                    cmd.Parameters.AddWithValue("@Prefix", "%" & prefixText & "%")

                    Using reader As MySqlDataReader = cmd.ExecuteReader()
                        While reader.Read()
                            sections.Add(reader("Section").ToString())
                        End While
                    End Using
                End Using
            Catch ex As Exception
                System.Diagnostics.Debug.WriteLine("Error in GetSections: " & ex.Message)
            End Try
        End Using

        Return sections
    End Function
#End Region

#Region "Dropdown Event Handlers"




    Private Sub BindCourseDropdown(ddl As DropDownList)
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Using cmd As New MySqlCommand("SELECT CourseID, CourseName FROM Courses WHERE IsActive=1 ORDER BY CourseName", conn)
                Dim dt As New DataTable()
                Using da As New MySqlDataAdapter(cmd)
                    da.Fill(dt)
                End Using
                ddl.DataSource = dt
                ddl.DataTextField = "CourseName"
                ddl.DataValueField = "CourseID"
                ddl.DataBind()
                ddl.Items.Insert(0, New ListItem("Select Course", ""))
            End Using
        End Using
    End Sub
    Private Sub BindYearLevelsForEdit(ddl As DropDownList, courseID As String)
        ddl.Items.Clear()
        ddl.Items.Insert(0, New ListItem("Select Year Level", ""))

        If String.IsNullOrEmpty(courseID) Then Return

        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Using cmd As New MySqlCommand("SELECT DISTINCT YearLevel FROM Classes WHERE CourseID = @CourseID AND IsActive=1 ORDER BY YearLevel", conn)
                cmd.Parameters.AddWithValue("@CourseID", courseID)
                Dim dt As New DataTable()
                Using da As New MySqlDataAdapter(cmd)
                    da.Fill(dt)
                End Using
                ddl.DataSource = dt
                ddl.DataTextField = "YearLevel"
                ddl.DataValueField = "YearLevel"
                ddl.DataBind()
                ddl.Items.Insert(0, New ListItem("Select Year Level", ""))
            End Using
        End Using
    End Sub
#End Region

#Region "Add Student Functionality with Reactivation"
    Protected Sub btnAddStudent_Click(sender As Object, e As EventArgs)
        ' Clear previous messages
        lblModalMessage.Text = ""
        lblModalMessage.CssClass = "alert d-none"

        ' Reset user manually closed flag on server-side postback
        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "ResetUserClosedFlag", "userManuallyClosed = false;", True)

        ' Set modal to stay open for validation errors
        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "SetKeepModalOpen", "setKeepModalOpen(true);", True)

        ' Validate required fields
        If Not ValidateAddStudentForm() Then
            ShowModalMessage("⚠ Please fill in all required fields.", "danger")
            ScriptManager.RegisterStartupScript(Me, Me.GetType(), "KeepModalOpenOnError", "setKeepModalOpen(true);", True)
            Return
        End If

        ' Validate email format
        If Not IsValidEmail(txtEmail.Text.Trim()) Then
            ShowModalMessage("⚠ Please enter a valid email address.", "danger")
            ScriptManager.RegisterStartupScript(Me, Me.GetType(), "KeepModalOpenOnError", "setKeepModalOpen(true);", True)
            Return
        End If

        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Get Department ID from selected course
            Dim departmentID As Integer = GetDepartmentIDFromCourse(conn, ddlCourse.SelectedValue)
            If departmentID = 0 Then
                ShowModalMessage("⚠ Unable to determine department for the selected course.", "danger")
                ScriptManager.RegisterStartupScript(Me, Me.GetType(), "KeepModalOpenOnError", "setKeepModalOpen(true);", True)
                Return
            End If

            ' Get Class ID
            Dim classID As Integer = GetClassID(conn, ddlCourse.SelectedValue, ddlYearLevel.SelectedValue, txtSection.Text.Trim())
            If classID = 0 Then
                ShowModalMessage("⚠ No class found for the selected course, year level, and section combination.", "danger")
                ScriptManager.RegisterStartupScript(Me, Me.GetType(), "KeepModalOpenOnError", "setKeepModalOpen(true);", True)
                Return
            End If

            ' Generate password
            Dim generatedPassword As String = GenerateRandomPassword()

            ' Check for existing student (active OR inactive)
            Dim existingStudentID As Integer = FindExistingStudentForCSV(conn, txtSchoolID.Text.Trim(), txtEmail.Text.Trim().ToLower())


            ' Check for duplicate active records
            If CheckActiveDuplicate(conn, txtSchoolID.Text.Trim(), txtEmail.Text.Trim().ToLower()) Then
                    ShowModalMessage("⚠ This School ID or Email is already registered with an active account.", "warning")
                    ScriptManager.RegisterStartupScript(Me, Me.GetType(), "KeepModalOpenOnError", "setKeepModalOpen(true);", True)
                    Return
                End If

                ' Insert new student
                If InsertStudent(conn, classID, departmentID, generatedPassword) Then
                    ' Send email with credentials
                    If SendStudentCredentialsManual(txtFirstName.Text.Trim(), txtLastName.Text.Trim(), txtEmail.Text.Trim(), txtSchoolID.Text.Trim(), generatedPassword) Then
                        ShowModalMessage("✅ Student added successfully! Password sent to email.", "success")
                        lblMessage.Text = "✅ Student added successfully!"
                        lblMessage.CssClass = "alert alert-success d-block"

                        ' Close modal on success
                        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "CloseModalOnSuccess", "setKeepModalOpen(false); closeModal();", True)
                    Else
                        ShowModalMessage("✅ Student added but failed to send email. Please contact the student with their credentials.", "warning")
                        lblMessage.Text = "✅ Student added (email failed)"
                        lblMessage.CssClass = "alert alert-warning d-block"

                        ' Close modal on success (even with email warning)
                        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "CloseModalOnSuccess", "setKeepModalOpen(false); closeModal();", True)
                    End If
                Else
                    ShowModalMessage("❌ Error adding student. Please try again.", "danger")
                    ScriptManager.RegisterStartupScript(Me, Me.GetType(), "KeepModalOpenOnError", "setKeepModalOpen(true);", True)
                    Return
                End If


            ClearAddForm()
            BindStudents()

            ' Only close modal on success (handled in JavaScript above)
        End Using
    End Sub

    ' Add this helper method to show modal messages from server
    Private Sub ShowModalMessage(message As String, type As String)
        lblModalMessage.Text = message
        lblModalMessage.CssClass = $"alert alert-{type} d-block"
    End Sub

    Private Function ValidateAddStudentForm() As Boolean
        If String.IsNullOrWhiteSpace(txtLastName.Text) OrElse
   String.IsNullOrWhiteSpace(txtFirstName.Text) OrElse
   String.IsNullOrWhiteSpace(txtSchoolID.Text) OrElse
   String.IsNullOrWhiteSpace(txtEmail.Text) OrElse
   String.IsNullOrEmpty(ddlCourse.SelectedValue) OrElse
   String.IsNullOrEmpty(ddlYearLevel.SelectedValue) OrElse
   String.IsNullOrWhiteSpace(txtSection.Text) Then

            lblModalMessage.Text = "⚠ Please fill in all required fields."
            lblModalMessage.CssClass = "alert alert-danger d-block"
            Return False
        End If
        Return True
    End Function

    Private Function GetDepartmentIDFromCourse(conn As MySqlConnection, courseID As String) As Integer
        Using cmd As New MySqlCommand("SELECT DepartmentID FROM Courses WHERE CourseID = @CourseID", conn)
            cmd.Parameters.AddWithValue("@CourseID", courseID)
            Dim result = cmd.ExecuteScalar()
            Return If(result IsNot Nothing, Convert.ToInt32(result), 0)
        End Using
    End Function


    Private Function InsertStudent(conn As MySqlConnection, classID As Integer, departmentID As Integer, password As String) As Boolean
        ' Double-check no active duplicate exists before inserting
        If CheckActiveDuplicate(conn, txtSchoolID.Text.Trim(), txtEmail.Text.Trim().ToLower()) Then
            Return False
        End If
        Using cmd As New MySqlCommand("
    INSERT INTO Students (LastName, FirstName, MiddleInitial, Suffix, SchoolID, Email, Password, DepartmentID, CourseID, ClassID, Status, StudentType)
    VALUES (@LastName, @FirstName, @MiddleInitial, @Suffix, @SchoolID, @Email, @Password, @DeptID, @CourseID, @ClassID, 'Active', @StudentType)", conn)

            cmd.Parameters.AddWithValue("@LastName", txtLastName.Text.Trim())
            cmd.Parameters.AddWithValue("@FirstName", txtFirstName.Text.Trim())
            cmd.Parameters.AddWithValue("@MiddleInitial", If(String.IsNullOrWhiteSpace(txtMiddleInitial.Text), DBNull.Value, txtMiddleInitial.Text.Trim()))
            cmd.Parameters.AddWithValue("@Suffix", If(String.IsNullOrWhiteSpace(txtSuffix.Text), DBNull.Value, txtSuffix.Text.Trim()))
            cmd.Parameters.AddWithValue("@SchoolID", txtSchoolID.Text.Trim())
            cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim().ToLower())
            cmd.Parameters.AddWithValue("@Password", HashPassword(password))
            cmd.Parameters.AddWithValue("@DeptID", departmentID)
            cmd.Parameters.AddWithValue("@CourseID", ddlCourse.SelectedValue)
            cmd.Parameters.AddWithValue("@ClassID", classID)
            cmd.Parameters.AddWithValue("@StudentType", ddlStudentType.SelectedValue)
            Return cmd.ExecuteNonQuery() > 0
        End Using
    End Function

    Private Function FindExistingStudentForCSV(conn As MySqlConnection, schoolID As String, email As String) As Integer
        Using cmd As New MySqlCommand("
    SELECT StudentID 
    FROM Students 
    WHERE (SchoolID = @SchoolID OR Email = @Email)
    AND Status = 'Active'
    LIMIT 1", conn)

            cmd.Parameters.AddWithValue("@SchoolID", schoolID)
            cmd.Parameters.AddWithValue("@Email", email)

            Dim result = cmd.ExecuteScalar()
            Return If(result IsNot Nothing, Convert.ToInt32(result), 0)
        End Using
    End Function


    Private Function CheckActiveDuplicate(conn As MySqlConnection, schoolID As String, email As String) As Boolean
        ' Check for duplicate active records in Students or Users
        Using cmd As New MySqlCommand("
            SELECT COUNT(*) 
            FROM (
                SELECT SchoolID, Email FROM Students WHERE Status = 'Active' AND (SchoolID = @SchoolID OR Email = @Email)
                UNION
                SELECT SchoolID, Email FROM Users WHERE (SchoolID = @SchoolID OR Email = @Email)
            ) AS dup", conn)

            cmd.Parameters.AddWithValue("@SchoolID", schoolID)
            cmd.Parameters.AddWithValue("@Email", email)
            Return Convert.ToInt32(cmd.ExecuteScalar()) > 0
        End Using
    End Function



    Private Function GetClassID(conn As MySqlConnection, courseID As String, yearLevel As String, section As String) As Integer
        Using cmd As New MySqlCommand("
            SELECT ClassID 
            FROM Classes 
            WHERE CourseID = @CourseID AND YearLevel = @YearLevel AND Section = @Section AND IsActive=1", conn)
            cmd.Parameters.AddWithValue("@CourseID", courseID)
            cmd.Parameters.AddWithValue("@YearLevel", yearLevel)
            cmd.Parameters.AddWithValue("@Section", section)

            Dim result = cmd.ExecuteScalar()
            Return If(result IsNot Nothing, Convert.ToInt32(result), 0)
        End Using
    End Function


    Private Function SendStudentCredentialsManual(firstName As String, lastName As String, email As String, schoolID As String, password As String) As Boolean
        Try
            Using smtpClient As New SmtpClient(SmtpServer)
                smtpClient.Port = SmtpPort
                smtpClient.Credentials = New System.Net.NetworkCredential(SmtpUsername, SmtpPassword)
                smtpClient.EnableSsl = SmtpEnableSSL

                Dim mailMessage As New MailMessage()
                mailMessage.From = New MailAddress(FromEmail)
                mailMessage.To.Add(email)
                mailMessage.Subject = "Your Student Account Credentials - Golden West Colleges"

                Dim emailBody As String = $"
Dear {firstName} {lastName},

Your student account has been created successfully.

Here are your login credentials:
• School ID: {schoolID}
• Password: {password}
• Login Portal: {BaseUrl}/Login.aspx

Please log in and change your password immediately for security.

Best regards,
Golden West Colleges Administration"

                mailMessage.Body = emailBody
                smtpClient.Send(mailMessage)
                Return True
            End Using
        Catch ex As Exception
            ' Log email error but don't fail the student creation
            System.Diagnostics.Debug.WriteLine($"Email sending failed for {email}: {ex.Message}")
            Return False
        End Try
    End Function
    Private Sub ClearAddForm()
        txtLastName.Text = ""
        txtFirstName.Text = ""
        txtMiddleInitial.Text = ""
        txtSuffix.Text = ""
        txtSchoolID.Text = ""
        txtEmail.Text = ""
        ddlCourse.SelectedIndex = 0
        ddlYearLevel.Items.Clear()
        ddlYearLevel.Items.Insert(0, New ListItem("Select Year Level", ""))
        txtSection.Text = ""
        lblModalMessage.Text = ""
        lblModalMessage.CssClass = "alert d-none"
    End Sub
#End Region

#Region "Student Grid Management"
    Private Sub BindStudents(Optional search As String = "")
        Dim dt As New DataTable()
        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            Dim sql As String = "
SELECT s.StudentID, s.LastName, s.FirstName, s.MiddleInitial, s.Suffix, s.SchoolID, s.Email, s.Status, s.StudentType,
       d.DepartmentID, d.DepartmentName AS DepartmentName, 
       c.CourseID, c.CourseName, 
       cl.ClassID, cl.YearLevel, cl.Section
FROM Students s
INNER JOIN Departments d ON s.DepartmentID = d.DepartmentID
INNER JOIN Courses c ON s.CourseID = c.CourseID
INNER JOIN Classes cl ON s.ClassID = cl.ClassID
WHERE 1=1"

            If Not String.IsNullOrWhiteSpace(search) Then
                sql &= " AND (s.LastName LIKE @Search OR s.FirstName LIKE @Search OR s.SchoolID LIKE @Search OR s.Email LIKE @Search OR d.DepartmentName LIKE @Search OR c.CourseName LIKE @Search OR cl.YearLevel LIKE @Search OR cl.Section LIKE @Search OR s.Status LIKE @Search)"
            End If

            sql &= " ORDER BY s.Status, s.LastName, s.FirstName ASC" ' Order by status to group active/inactive

            Using cmd As New MySqlCommand(sql, conn)
                If Not String.IsNullOrWhiteSpace(search) Then
                    cmd.Parameters.AddWithValue("@Search", "%" & search & "%")
                End If

                Using da As New MySqlDataAdapter(cmd)
                    da.Fill(dt)
                End Using
            End Using
        End Using

        gvStudents.DataSource = dt
        gvStudents.DataBind()
    End Sub

#Region "Status Helper Methods"
    Public Function GetStatusBadgeClass(status As String) As String
        Select Case status?.ToLower()
            Case "active"
                Return "bg-success"
            Case "inactive"
                Return "bg-secondary"
            Case "suspended"
                Return "bg-warning"
            Case Else
                Return "bg-secondary"
        End Select
    End Function

    Public Function GetStatusIcon(status As String) As String
        Select Case status?.ToLower()
            Case "active"
                Return "bi-check-circle"
            Case "inactive"
                Return "bi-x-circle"
            Case "suspended"
                Return "bi-pause-circle"
            Case Else
                Return "bi-question-circle"
        End Select
    End Function

    ' Helper method to build full name for display
    Public Function BuildFullName(lastName As String, firstName As String, middleInitial As String, suffix As String) As String
        Dim fullName As New StringBuilder()

        fullName.Append(lastName)
        fullName.Append(", ")
        fullName.Append(firstName)

        If Not String.IsNullOrWhiteSpace(middleInitial) Then
            fullName.Append(" ")
            fullName.Append(middleInitial.Trim().ToUpper())
            fullName.Append(".")
        End If

        If Not String.IsNullOrWhiteSpace(suffix) Then
            fullName.Append(" ")
            fullName.Append(suffix.Trim())
        End If

        Return fullName.ToString()
    End Function
#End Region

    Protected Sub btnSearch_Click(sender As Object, e As EventArgs) Handles btnGridSearch.Click
        BindStudents(txtGridSearch.Text.Trim())
    End Sub
#End Region

#Region "GridView Events"



    Private Function ValidateEditStudentForm(txtLastNameEdit As TextBox, txtFirstNameEdit As TextBox, txtSchoolIDEdit As TextBox, txtEmailEdit As TextBox, ddlCourse As DropDownList, ddlYearLevel As DropDownList, txtSectionEdit As TextBox, ddlStatus As DropDownList) As Boolean
        If txtLastNameEdit Is Nothing OrElse String.IsNullOrWhiteSpace(txtLastNameEdit.Text) OrElse
       txtFirstNameEdit Is Nothing OrElse String.IsNullOrWhiteSpace(txtFirstNameEdit.Text) OrElse
       txtSchoolIDEdit Is Nothing OrElse String.IsNullOrWhiteSpace(txtSchoolIDEdit.Text) OrElse
       txtEmailEdit Is Nothing OrElse String.IsNullOrWhiteSpace(txtEmailEdit.Text) OrElse
       ddlCourse Is Nothing OrElse String.IsNullOrEmpty(ddlCourse.SelectedValue) OrElse
       ddlYearLevel Is Nothing OrElse String.IsNullOrEmpty(ddlYearLevel.SelectedValue) OrElse
       txtSectionEdit Is Nothing OrElse String.IsNullOrWhiteSpace(txtSectionEdit.Text) OrElse
       ddlStatus Is Nothing OrElse String.IsNullOrEmpty(ddlStatus.SelectedValue) Then

            lblMessage.Text = "⚠ Please fill in all required fields before saving."
            lblMessage.CssClass = "alert alert-danger d-block"
            Return False
        End If
        Return True
    End Function

    Private Function CheckDuplicateSchoolIDForEdit(conn As MySqlConnection, schoolID As String, studentID As Integer) As Boolean
        Using cmd As New MySqlCommand("
            SELECT COUNT(*) 
            FROM (
                SELECT SchoolID FROM Students WHERE SchoolID = @SchoolID AND StudentID <> @StudentID
                UNION
                SELECT SchoolID FROM Users WHERE SchoolID = @SchoolID
            ) AS dup", conn)
            cmd.Parameters.AddWithValue("@SchoolID", schoolID)
            cmd.Parameters.AddWithValue("@StudentID", studentID)
            Return Convert.ToInt32(cmd.ExecuteScalar()) > 0
        End Using
    End Function

    Private Function CheckDuplicateEmailForEdit(conn As MySqlConnection, email As String, studentID As Integer) As Boolean
        Using cmd As New MySqlCommand("
            SELECT COUNT(*) 
            FROM (
                SELECT Email FROM Students WHERE Email = @Email AND StudentID <> @StudentID
                UNION
                SELECT Email FROM Users WHERE Email = @Email
            ) AS dup", conn)
            cmd.Parameters.AddWithValue("@Email", email)
            cmd.Parameters.AddWithValue("@StudentID", studentID)
            Return Convert.ToInt32(cmd.ExecuteScalar()) > 0
        End Using
    End Function

    Private Function UpdateStudent(conn As MySqlConnection, studentID As Integer, lastName As String, firstName As String, middleInitial As String, suffix As String, schoolID As String, email As String, departmentID As Integer, courseID As String, classID As Integer, status As String, studentType As String) As Boolean
        Using cmd As New MySqlCommand("
    UPDATE Students 
    SET LastName = @LastName, FirstName = @FirstName, MiddleInitial = @MiddleInitial, Suffix = @Suffix,
        SchoolID = @SchoolID, Email = @Email, 
        DepartmentID = @DeptID, CourseID = @CourseID, ClassID = @ClassID, Status = @Status, StudentType = @StudentType
    WHERE StudentID = @StudentID", conn)


            cmd.Parameters.AddWithValue("@LastName", lastName)
            cmd.Parameters.AddWithValue("@FirstName", firstName)
            cmd.Parameters.AddWithValue("@MiddleInitial", If(String.IsNullOrWhiteSpace(middleInitial), DBNull.Value, middleInitial))
            cmd.Parameters.AddWithValue("@Suffix", If(String.IsNullOrWhiteSpace(suffix), DBNull.Value, suffix))
            cmd.Parameters.AddWithValue("@SchoolID", schoolID)
            cmd.Parameters.AddWithValue("@Email", email)
            cmd.Parameters.AddWithValue("@DeptID", departmentID)
            cmd.Parameters.AddWithValue("@CourseID", courseID)
            cmd.Parameters.AddWithValue("@ClassID", classID)
            cmd.Parameters.AddWithValue("@Status", status)
            cmd.Parameters.AddWithValue("@StudentID", studentID)
            cmd.Parameters.AddWithValue("@StudentType", studentType)

            Return cmd.ExecuteNonQuery() > 0
        End Using
    End Function

    Protected Sub gvStudents_RowDeleting(sender As Object, e As GridViewDeleteEventArgs)
        Dim studentID As Integer = Convert.ToInt32(gvStudents.DataKeys(e.RowIndex).Value)

        ' Get student info for confirmation message
        Dim studentInfo As String = GetStudentInfo(studentID)

        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' First, check if student has any evaluation records
            If StudentHasEvaluationRecords(conn, studentID) Then
                lblMessage.Text = $"❌ Cannot delete student {studentInfo} because they have evaluation records. Please deactivate instead."
                lblMessage.CssClass = "alert alert-danger d-block"
                Return
            End If

            ' Use transaction to ensure data integrity
            Using transaction As MySqlTransaction = conn.BeginTransaction()
                Try
                    ' Delete student record permanently
                    Using cmd As New MySqlCommand("DELETE FROM Students WHERE StudentID = @StudentID", conn, transaction)
                        cmd.Parameters.AddWithValue("@StudentID", studentID)
                        Dim rowsAffected As Integer = cmd.ExecuteNonQuery()

                        If rowsAffected > 0 Then
                            transaction.Commit()
                            lblMessage.Text = $"✅ Student {studentInfo} permanently deleted!"
                            lblMessage.CssClass = "alert alert-success d-block"
                        Else
                            transaction.Rollback()
                            lblMessage.Text = "❌ Student not found or already deleted."
                            lblMessage.CssClass = "alert alert-warning d-block"
                        End If
                    End Using

                Catch ex As MySqlException
                    transaction.Rollback()

                    ' Handle foreign key constraint violations
                    If ex.Number = 1451 Then ' Foreign key constraint fails
                        lblMessage.Text = $"❌ Cannot delete student {studentInfo} because they are referenced in other records. Please deactivate instead."
                        lblMessage.CssClass = "alert alert-danger d-block"
                    Else
                        lblMessage.Text = $"❌ Error deleting student: {ex.Message}"
                        lblMessage.CssClass = "alert alert-danger d-block"
                    End If
                    Return

                Catch ex As Exception
                    transaction.Rollback()
                    lblMessage.Text = $"❌ Error deleting student: {ex.Message}"
                    lblMessage.CssClass = "alert alert-danger d-block"
                    Return
                End Try
            End Using
        End Using

        ' Rebind the grid to reflect changes
        BindStudents(txtGridSearch.Text.Trim())
    End Sub
    Private Function GetStudentInfo(studentID As Integer) As String
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Using cmd As New MySqlCommand("SELECT FirstName, LastName, SchoolID FROM Students WHERE StudentID = @StudentID", conn)
                cmd.Parameters.AddWithValue("@StudentID", studentID)
                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    If reader.Read() Then
                        Return $"{reader("FirstName")} {reader("LastName")} ({reader("SchoolID")})"
                    End If
                End Using
            End Using
        End Using
        Return "the student"
    End Function

    Private Function StudentHasEvaluationRecords(conn As MySqlConnection, studentID As Integer) As Boolean
        ' Check if student has any evaluation submissions
        Using cmd As New MySqlCommand("SELECT COUNT(*) FROM evaluationsubmissions WHERE StudentID = @StudentID", conn)
            cmd.Parameters.AddWithValue("@StudentID", studentID)
            Return Convert.ToInt32(cmd.ExecuteScalar()) > 0
        End Using
    End Function
    Protected Sub gvStudents_PageIndexChanging(sender As Object, e As GridViewPageEventArgs)
        gvStudents.PageIndex = e.NewPageIndex
        BindStudents(txtGridSearch.Text.Trim())
    End Sub
#End Region

#Region "GridView Row Data Binding"
    Protected Sub gvStudents_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvStudents.RowDataBound
        ' Only handle data rows, no need for edit mode setup since we're using modal
        If e.Row.RowType = DataControlRowType.DataRow Then
            ' You can add any other row formatting here if needed
        End If
    End Sub


#End Region

#Region "GridView Edit Dropdown Events"



#End Region

#Region "Utility Methods"
    Private Function IsValidEmail(email As String) As Boolean
        If String.IsNullOrWhiteSpace(email) Then Return False

        Try
            Dim addr = New MailAddress(email)
            Return addr.Address = email
        Catch
            Return False
        End Try
    End Function
#End Region
#Region "CSV Export Functionality"
    Protected Sub btnExportCSV_Click(sender As Object, e As EventArgs)
        Try
            ExportStudentsToCSV()
        Catch ex As Exception
            lblMessage.Text = $"❌ Error exporting CSV: {ex.Message}"
            lblMessage.CssClass = "alert alert-danger d-block"
        End Try
    End Sub

    Private Sub ExportStudentsToCSV()
        Dim studentsData As DataTable = GetStudentsDataForExport()

        If studentsData.Rows.Count = 0 Then
            lblMessage.Text = "⚠ No student data found to export."
            lblMessage.CssClass = "alert alert-warning d-block"
            Return
        End If

        ' Build CSV content
        Dim csvContent As New StringBuilder()

        ' Add headers
        csvContent.AppendLine("LastName,FirstName,MiddleInitial,Suffix,SchoolID,Email,CourseName,YearLevel,Section,StudentType")

        ' Add data rows
        For Each row As DataRow In studentsData.Rows
            csvContent.AppendLine($"""{EscapeCsvField(row("LastName").ToString())}"",""{EscapeCsvField(row("FirstName").ToString())}"",""{EscapeCsvField(If(row("MiddleInitial") Is DBNull.Value, "", row("MiddleInitial").ToString()))}"",""{EscapeCsvField(If(row("Suffix") Is DBNull.Value, "", row("Suffix").ToString()))}"",""{EscapeCsvField(row("SchoolID").ToString())}"",""{EscapeCsvField(row("Email").ToString())}"",""{EscapeCsvField(row("CourseName").ToString())}"",""{EscapeCsvField(row("YearLevel").ToString())}"",""{EscapeCsvField(row("Section").ToString())}"",""{EscapeCsvField(row("StudentType").ToString())}""")
        Next

        ' Send CSV file to client
        Response.Clear()
        Response.Buffer = True
        Response.AddHeader("content-disposition", "attachment;filename=Students_Export_" & DateTime.Now.ToString("yyyyMMdd_HHmmss") & ".csv")
        Response.Charset = ""
        Response.ContentType = "text/csv"
        Response.Output.Write(csvContent.ToString())
        Response.Flush()
        Response.End()

    End Sub

    Private Function GetStudentsDataForExport() As DataTable
        Dim dt As New DataTable()

        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            Dim sql As String = "
    SELECT 
        s.LastName, s.FirstName, s.MiddleInitial, s.Suffix, s.SchoolID, s.Email, s.Status, s.StudentType,
        d.DepartmentName, 
        c.CourseName, 
        cl.YearLevel, cl.Section
    FROM Students s
    INNER JOIN Departments d ON s.DepartmentID = d.DepartmentID
    INNER JOIN Courses c ON s.CourseID = c.CourseID
    INNER JOIN Classes cl ON s.ClassID = cl.ClassID
    WHERE s.Status = 'Active'
    ORDER BY s.LastName, s.FirstName ASC"

            Using cmd As New MySqlCommand(sql, conn)
                Using da As New MySqlDataAdapter(cmd)
                    da.Fill(dt)
                End Using
            End Using
        End Using

        Return dt
    End Function
    Public Function GetStudentTypeBadgeClass(studentType As String) As String
        Select Case studentType?.ToLower()
            Case "regular"
                Return "bg-primary"
            Case "irregular"
                Return "bg-warning text-dark"
            Case Else
                Return "bg-secondary"
        End Select
    End Function

    Public Function GetStudentTypeIcon(studentType As String) As String
        Select Case studentType?.ToLower()
            Case "regular"
                Return "bi-person-check"
            Case "irregular"
                Return "bi-person-dash"
            Case Else
                Return "bi-person"
        End Select
    End Function
    Private Function EscapeCsvField(field As String) As String
        If String.IsNullOrEmpty(field) Then Return ""

        ' Escape quotes by doubling them and wrap in quotes if contains comma, quote, or newline
        If field.Contains(",") OrElse field.Contains("""") OrElse field.Contains(vbCr) OrElse field.Contains(vbLf) Then
            Return """" & field.Replace("""", """""") & """"
        End If

        Return field
    End Function
#End Region
    ' ========== SIDEBAR BADGE METHODS ==========
    Private Sub UpdateSidebarBadges()
        Try
            Dim pendingEnrollmentCount = GetPendingEnrollmentCount()
            Dim pendingReleaseCount = GetPendingReleaseCountByFaculty()

            ' Update enrollment badge using ASP.NET Label control
            If pendingEnrollmentCount > 0 Then
                sidebarEnrollmentBadge.Text = pendingEnrollmentCount.ToString()
                sidebarEnrollmentBadge.Visible = True
            Else
                sidebarEnrollmentBadge.Visible = False
            End If

            ' Update release results badge using ASP.NET Label control
            If pendingReleaseCount > 0 Then
                sidebarReleaseBadge.Text = pendingReleaseCount.ToString()
                sidebarReleaseBadge.Visible = True
            Else
                sidebarReleaseBadge.Visible = False
            End If

        Catch ex As Exception
            ' Silently fail for badges to not break the main page
            System.Diagnostics.Debug.WriteLine($"Error updating sidebar badges: {ex.Message}")
        End Try
    End Sub

    Private Function GetPendingEnrollmentCount() As Integer
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                Dim activeCycleID = GetActiveCycleID()

                If activeCycleID = 0 Then Return 0

                Dim query = "
            SELECT COUNT(DISTINCT StudentID) as PendingCount 
            FROM irregular_student_enrollments 
            WHERE CycleID = @CycleID AND IsApproved = 0"

                Using cmd As New MySqlCommand(query, conn)
                    cmd.Parameters.AddWithValue("@CycleID", activeCycleID)
                    Dim result = cmd.ExecuteScalar()
                    Return If(result IsNot Nothing AndAlso Not IsDBNull(result), Convert.ToInt32(result), 0)
                End Using
            End Using
        Catch ex As Exception
            Return 0
        End Try
    End Function

    Private Function GetPendingReleaseCountByFaculty() As Integer
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                Dim activeCycleID = GetActiveCycleID()

                If activeCycleID = 0 Then Return 0

                ' Fixed query: Count faculty with confirmed grade submissions 
                ' but evaluation results not released (IsReleased ≠ 2)
                Dim query = "
        SELECT COUNT(DISTINCT fl.FacultyID) as PendingReleaseCount 
        FROM gradesubmissions gs
        INNER JOIN facultyload fl ON gs.LoadID = fl.LoadID
        WHERE gs.CycleID = @CycleID 
        AND gs.Status = 'Confirmed'
        AND NOT EXISTS (
            SELECT 1 FROM evaluations e 
            WHERE e.LoadID = gs.LoadID 
            AND e.CycleID = gs.CycleID 
            AND e.IsReleased = 2
        )"

                Using cmd As New MySqlCommand(query, conn)
                    cmd.Parameters.AddWithValue("@CycleID", activeCycleID)
                    Dim result = cmd.ExecuteScalar()
                    Return If(result IsNot Nothing AndAlso Not IsDBNull(result), Convert.ToInt32(result), 0)
                End Using
            End Using
        Catch ex As Exception
            Return 0
        End Try
    End Function

    Private Function GetActiveCycleID() As Integer
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim query = "SELECT CycleID FROM evaluationcycles WHERE Status = 'Active' LIMIT 1"

            Using cmd As New MySqlCommand(query, conn)
                Dim result = cmd.ExecuteScalar()
                Return If(result IsNot Nothing, Convert.ToInt32(result), 0)
            End Using
        End Using
    End Function

    ' WebMethod for getting sidebar badge counts
    <System.Web.Services.WebMethod()>
    Public Shared Function GetSidebarBadgeCounts() As String
        Try
            Dim counts As New Dictionary(Of String, Integer)
            Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

            Using conn As New MySqlConnection(connString)
                conn.Open()
                Dim activeCycleID = GetActiveCycleIDStatic(conn)

                If activeCycleID > 0 Then
                    ' Pending enrollment count
                    Using cmd As New MySqlCommand("SELECT COUNT(DISTINCT StudentID) FROM irregular_student_enrollments WHERE CycleID = @CycleID AND IsApproved = 0", conn)
                        cmd.Parameters.AddWithValue("@CycleID", activeCycleID)
                        counts("PendingEnrollments") = Convert.ToInt32(cmd.ExecuteScalar())
                    End Using

                    ' Pending release count by faculty
                    ' Pending release count by faculty - FIXED VERSION
                    Using cmd As New MySqlCommand("
    SELECT COUNT(DISTINCT fl.FacultyID) 
    FROM gradesubmissions gs
    INNER JOIN facultyload fl ON gs.LoadID = fl.LoadID
    WHERE gs.CycleID = @CycleID 
    AND gs.Status = 'Confirmed'
    AND NOT EXISTS (
        SELECT 1 FROM evaluations e 
        WHERE e.LoadID = gs.LoadID 
        AND e.CycleID = gs.CycleID 
        AND e.IsReleased = 2
    )", conn)
                        cmd.Parameters.AddWithValue("@CycleID", activeCycleID)
                        counts("PendingReleases") = Convert.ToInt32(cmd.ExecuteScalar())
                    End Using
                Else
                    counts("PendingEnrollments") = 0
                    counts("PendingReleases") = 0
                End If
            End Using

            Return Newtonsoft.Json.JsonConvert.SerializeObject(counts)
        Catch ex As Exception
            Return "{""PendingEnrollments"":0,""PendingReleases"":0}"
        End Try
    End Function

    Private Shared Function GetActiveCycleIDStatic(conn As MySqlConnection) As Integer
        Dim query = "SELECT CycleID FROM evaluationcycles WHERE Status = 'Active' LIMIT 1"
        Using cmd As New MySqlCommand(query, conn)
            Dim result = cmd.ExecuteScalar()
            Return If(result IsNot Nothing, Convert.ToInt32(result), 0)
        End Using
    End Function


    ' ========== EDIT MODAL FUNCTIONALITY ==========
    Protected Sub btnUpdateStudent_Click(sender As Object, e As EventArgs)
        lblEditMessage.Text = ""
        lblEditMessage.CssClass = "alert d-none"

        Dim studentID As Integer = Convert.ToInt32(hfEditStudentID.Value)

        ' Get values from edit modal
        Dim lastName As String = txtEditLastName.Text.Trim()
        Dim firstName As String = txtEditFirstName.Text.Trim()
        Dim middleInitial As String = txtEditMiddleInitial.Text.Trim()
        Dim suffix As String = txtEditSuffix.Text.Trim()
        Dim schoolID As String = txtEditSchoolID.Text.Trim()
        Dim email As String = txtEditEmail.Text.Trim()
        Dim courseID As String = ddlEditCourse.SelectedValue
        Dim yearLevel As String = ddlEditYearLevel.SelectedValue
        Dim section As String = txtEditSection.Text.Trim()
        Dim studentType As String = ddlEditStudentType.SelectedValue
        Dim status As String = ddlEditStatus.SelectedValue

        ' Validate required fields
        If String.IsNullOrWhiteSpace(lastName) OrElse
           String.IsNullOrWhiteSpace(firstName) OrElse
           String.IsNullOrWhiteSpace(schoolID) OrElse
           String.IsNullOrWhiteSpace(email) OrElse
           String.IsNullOrEmpty(courseID) OrElse
           String.IsNullOrEmpty(yearLevel) OrElse
           String.IsNullOrWhiteSpace(section) Then

            lblEditMessage.Text = "⚠ Please fill in all required fields."
            lblEditMessage.CssClass = "alert alert-danger d-block"
            Return
        End If

        ' Validate email format
        If Not IsValidEmail(email) Then
            lblEditMessage.Text = "⚠ Please enter a valid email address."
            lblEditMessage.CssClass = "alert alert-danger d-block"
            Return
        End If

        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Check for duplicate School ID (excluding current student)
            If CheckDuplicateSchoolIDForEdit(conn, schoolID, studentID) Then
                lblEditMessage.Text = "⚠ This School ID is already used by another account."
                lblEditMessage.CssClass = "alert alert-danger d-block"
                Return
            End If

            ' Check for duplicate Email (excluding current student)
            If CheckDuplicateEmailForEdit(conn, email, studentID) Then
                lblEditMessage.Text = "⚠ This Email address is already used by another account."
                lblEditMessage.CssClass = "alert alert-danger d-block"
                Return
            End If

            ' Get Department ID from selected course
            Dim departmentID As Integer = GetDepartmentIDFromCourse(conn, courseID)
            If departmentID = 0 Then
                lblEditMessage.Text = "⚠ Unable to determine department for the selected course."
                lblEditMessage.CssClass = "alert alert-danger d-block"
                Return
            End If

            ' Get Class ID
            Dim classID As Integer = GetClassID(conn, courseID, yearLevel, section)
            If classID = 0 Then
                lblEditMessage.Text = "⚠ No class found for the selected course, year level, and section combination."
                lblEditMessage.CssClass = "alert alert-danger d-block"
                Return
            End If

            ' Update student
            If UpdateStudent(conn, studentID, lastName, firstName, middleInitial, suffix, schoolID, email, departmentID, courseID, classID, status, studentType) Then
                lblEditMessage.Text = "✅ Student updated successfully!"
                lblEditMessage.CssClass = "alert alert-success d-block"
                lblMessage.Text = "✅ Student updated successfully!"
                lblMessage.CssClass = "alert alert-success d-block"

                ' Close modal and refresh grid
                ScriptManager.RegisterStartupScript(Me, Me.GetType(), "CloseEditModal", "closeEditModal();", True)
                BindStudents(txtGridSearch.Text.Trim())
            Else
                lblEditMessage.Text = "❌ Error updating student. Please try again."
                lblEditMessage.CssClass = "alert alert-danger d-block"
            End If
        End Using
    End Sub

    ' ========== EDIT MODAL DROPDOWN EVENT HANDLERS ==========
    Protected Sub ddlEditCourse_SelectedIndexChanged(sender As Object, e As EventArgs)
        LoadEditYearLevels()
        txtEditSection.Text = ""

        ' Update section field state
        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "ValidateEditSection", "validateEditSectionField();", True)
    End Sub

    Protected Sub ddlEditYearLevel_SelectedIndexChanged(sender As Object, e As EventArgs)
        txtEditSection.Text = ""

        ' Update section field state
        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "ValidateEditSection", "validateEditSectionField();", True)
    End Sub

    Private Sub LoadEditYearLevels()
        ddlEditYearLevel.Items.Clear()
        ddlEditYearLevel.Items.Insert(0, New ListItem("Select Year Level", ""))

        If String.IsNullOrEmpty(ddlEditCourse.SelectedValue) Then Exit Sub

        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Using cmd As New MySqlCommand("SELECT DISTINCT YearLevel FROM Classes WHERE CourseID = @CourseID AND IsActive=1 ORDER BY YearLevel", conn)
                cmd.Parameters.AddWithValue("@CourseID", ddlEditCourse.SelectedValue)
                Dim dt As New DataTable()
                Using da As New MySqlDataAdapter(cmd)
                    da.Fill(dt)
                End Using
                ddlEditYearLevel.DataSource = dt
                ddlEditYearLevel.DataTextField = "YearLevel"
                ddlEditYearLevel.DataValueField = "YearLevel"
                ddlEditYearLevel.DataBind()
            End Using
        End Using
        ddlEditYearLevel.Items.Insert(0, New ListItem("Select Year Level", ""))
    End Sub

    ' ========== LOAD COURSES FOR EDIT MODAL ==========
    Private Sub LoadEditCourses()
        ddlEditCourse.Items.Clear()
        ddlEditCourse.Items.Insert(0, New ListItem("Select Course", ""))

        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Using cmd As New MySqlCommand("SELECT CourseID, CourseName FROM Courses WHERE IsActive=1 ORDER BY CourseName", conn)
                Dim dt As New DataTable()
                Using da As New MySqlDataAdapter(cmd)
                    da.Fill(dt)
                End Using
                ddlEditCourse.DataSource = dt
                ddlEditCourse.DataTextField = "CourseName"
                ddlEditCourse.DataValueField = "CourseID"
                ddlEditCourse.DataBind()
            End Using
        End Using
        ddlEditCourse.Items.Insert(0, New ListItem("Select Course", ""))
    End Sub



    ' Update the main form dropdown event handlers to validate section field
    Protected Sub ddlCourse_SelectedIndexChanged(sender As Object, e As EventArgs)
        LoadYearLevels()
        txtSection.Text = ""

        ' Update section field state
        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "ValidateSection", "validateSectionField();", True)

        ' IMPORTANT: Allow modal to function normally after course selection
        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "ResetModalFlags",
        "userManuallyClosed = false; shouldKeepModalOpen = false;", True)
    End Sub

    Protected Sub ddlYearLevel_SelectedIndexChanged(sender As Object, e As EventArgs)
        txtSection.Text = ""

        ' Update section field state
        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "ValidateSection", "validateSectionField();", True)
    End Sub
End Class



