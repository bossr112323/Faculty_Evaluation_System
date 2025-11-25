Imports System.Configuration
Imports System.Data
Imports System.Text
Imports MySql.Data.MySqlClient
Imports System.Collections.Generic
Imports System.Web.Services
Imports System.Web.Script.Services
Imports System.Web.Script.Serialization

Public Class Reports
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    ' Data Structures (unchanged)
    Public Class InstitutionData
        Public Property KPIs As KPIData
        Public Property DomainPerformance As List(Of DomainPerformanceData)
        Public Property TrendData As List(Of TrendData)
    End Class

    Public Class DepartmentData
        Public Property Departments As List(Of DepartmentResultData)
        Public Property TopDomains As List(Of DomainScoreData)
        Public Property BottomDomains As List(Of DomainScoreData)
    End Class

    Public Class FacultyData
        Public Property FacultyPerformance As FacultyPerformanceData
        Public Property DomainScores As List(Of DomainScoreData)
        Public Property SubjectResults As List(Of SubjectResultData)
        Public Property Comments As List(Of CommentGroup) ' Changed from List(Of CommentData)
    End Class

    Public Class FacultyPerformanceData
        Public Property OverallScore As Decimal ' Weighted percentage
        Public Property RawOverallScore As Decimal ' 1-5 scale average
        Public Property SubjectsCount As Integer
        Public Property EvaluationsCount As Integer
    End Class

    Public Class SubjectResultData
        Public Property SubjectID As Integer
        Public Property SubjectName As String
        Public Property CourseName As String
        Public Property DepartmentName As String
        Public Property DepartmentID As Integer
        Public Property CourseID As Integer
        Public Property AverageScore As Decimal
        Public Property EvaluationCount As Integer
    End Class

    Public Class TrendData
        Public Property CycleName As String
        Public Property AverageScore As Decimal
    End Class

    Public Class KPIData
        Public Property FacultyEvaluated As Integer
        Public Property TotalFaculty As Integer
        Public Property FacultyPending As Integer
        Public Property ClassesEvaluated As Integer ' Changed from SubjectsEvaluated
        Public Property ClassesOffered As Integer ' Changed from SubjectsOffered
        Public Property StudentParticipationRate As Decimal
        Public Property InstitutionAverage As Decimal
        Public Property Trend As Decimal
        Public Property TotalEvaluations As Integer
        Public Property TotalStudents As Integer
        Public Property StudentsParticipated As Integer
    End Class

    Public Class DomainPerformanceData
        Public Property DomainName As String
        Public Property AverageScore As Decimal ' Weighted percentage
        Public Property RawAverage As Decimal ' 1-5 scale average
        Public Property Weight As Integer ' Ensure this exists
    End Class

    Public Class DomainScoreData
        Public Property DomainName As String
        Public Property Score As Decimal ' Weighted percentage
        Public Property RawScore As Decimal ' 1-5 scale average
        Public Property Weight As Integer ' Add this property
    End Class


    Public Class DepartmentResultData
        Public Property DepartmentID As Integer
        Public Property DepartmentName As String
        Public Property OverallScore As Decimal
        Public Property DomainScores As List(Of DomainScoreData)
        Public Property RawDomainScores As List(Of DomainRawScoreData) ' Add this line
        Public Property FacultyCount As Integer
        Public Property EvaluationCount As Integer
        Public Property Trend As Decimal
    End Class

    ' Add new class for raw scores
    Public Class DomainRawScoreData
        Public Property DomainName As String
        Public Property RawScore As Decimal ' 1-5 scale
        Public Property Weight As Integer
    End Class

    Public Class CommentData
        Public Property CommentType As String ' "Strengths", "Weaknesses", or "Additional"
        Public Property CommentText As String
        Public Property SubmissionDate As String
        Public Property SubjectName As String
        Public Property DepartmentName As String
        Public Property CourseName As String
        Public Property EvaluationCount As Integer ' How many times this type of comment appears
    End Class

    Public Class CommentGroup
        Public Property CommentType As String
        Public Property Comments As List(Of CommentData)
        Public Property TotalCount As Integer
    End Class

    Public Class CourseData
        Public Property CourseID As Integer
        Public Property CourseName As String
        Public Property AverageScore As Decimal ' Weighted percentage
        Public Property RawAverage As Decimal ' 1-5 scale average
        Public Property FacultyCount As Integer
        Public Property EvaluationCount As Integer
        Public Property SubjectCount As Integer
        Public Property ContributionPercent As Decimal
    End Class

    Public Class SearchSuggestion
        Public Property Type As String
        Public Property ID As Integer
        Public Property PrimaryText As String
        Public Property SecondaryText As String
    End Class

    Public Class FacultyListData
        Public Property FacultyID As Integer
        Public Property FacultyName As String
        Public Property DepartmentName As String
        Public Property OverallScore As Decimal ' Weighted percentage
        Public Property RawOverallScore As Decimal ' 1-5 scale average
        Public Property SubjectsCount As Integer
        Public Property EvaluationsCount As Integer
    End Class

    Public Class FacultyQuestionBreakdownData
        Public Property DomainName As String
        Public Property Questions As List(Of QuestionData)
        Public Property DomainAverage As Decimal
    End Class

    Public Class QuestionData
        Public Property QuestionText As String
        Public Property AverageScore As Decimal ' 1-5 scale
        Public Property ResponseCount As Integer
        Public Property PercentageScore As Decimal ' Keep percentage for reference if needed
    End Class
    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Session("Role") Is Nothing OrElse Session("Role").ToString() <> "Admin" Then
            Response.Redirect("Login.aspx")
            Return
        End If

        If Not IsPostBack Then
            lblWelcome.Text = If(Session("FullName"), "Admin")
            LoadFilterDropdowns()
            SetDefaultCycle()
            UpdateSidebarBadges() ' Add this line
        End If
    End Sub

    Private Sub LoadFilterDropdowns()
        LoadDepartments()
    End Sub
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
    Private Sub LoadDepartments()
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                Dim sql As String = "SELECT DepartmentID, DepartmentName FROM departments WHERE IsActive = 1 ORDER BY DepartmentName"

                Using cmd As New MySqlCommand(sql, conn)
                    Using reader As MySqlDataReader = cmd.ExecuteReader()
                        ddlDepartment.DataSource = reader
                        ddlDepartment.DataTextField = "DepartmentName"
                        ddlDepartment.DataValueField = "DepartmentID"
                        ddlDepartment.DataBind()
                        ddlDepartment.Items.Insert(0, New ListItem("All Departments", "0"))
                    End Using
                End Using

                Using cmd2 As New MySqlCommand(sql, conn)
                    Using reader2 As MySqlDataReader = cmd2.ExecuteReader()
                        ddlFacultyDepartment.DataSource = reader2
                        ddlFacultyDepartment.DataTextField = "DepartmentName"
                        ddlFacultyDepartment.DataValueField = "DepartmentID"
                        ddlFacultyDepartment.DataBind()
                        ddlFacultyDepartment.Items.Insert(0, New ListItem("All Departments", "0"))
                    End Using
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error loading departments: " & ex.Message)
        End Try
    End Sub

    ' WebMethods
    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetInstitutionData(cycleId As String) As String
        Dim institutionData As New InstitutionData()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()
                Dim intCycleId As Integer = If(String.IsNullOrEmpty(cycleId) OrElse cycleId = "0", 0, Integer.Parse(cycleId))
                institutionData.KPIs = GetKPIData(conn, intCycleId, 0, 0)
                institutionData.DomainPerformance = GetDomainPerformance(conn, intCycleId, 0, 0)
                institutionData.TrendData = GetTrendData(conn, intCycleId)

                System.Diagnostics.Debug.WriteLine($"Returning KPIs: FacultyEvaluated={institutionData.KPIs.FacultyEvaluated}")
                System.Diagnostics.Debug.WriteLine($"Returning DomainPerformance count: {institutionData.DomainPerformance.Count}")
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"Error in GetInstitutionData: {ex.Message}")
            institutionData = New InstitutionData() With {
                .KPIs = New KPIData(),
                .DomainPerformance = New List(Of DomainPerformanceData)(),
                .TrendData = New List(Of TrendData)()
            }
        End Try

        Dim serializer As New JavaScriptSerializer()
        Return serializer.Serialize(institutionData)
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetDepartmentData(cycleId As String, departmentId As String, courseId As String) As String
        Dim departmentData As New DepartmentData()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()
                Dim intCycleId As Integer = If(String.IsNullOrEmpty(cycleId) OrElse cycleId = "0", 0, Integer.Parse(cycleId))
                Dim intDepartmentId As Integer = If(String.IsNullOrEmpty(departmentId) OrElse departmentId = "0", 0, Integer.Parse(departmentId))
                departmentData.Departments = GetDepartmentResults(conn, intCycleId, intDepartmentId)
                departmentData.TopDomains = GetTopDomains(conn, intCycleId, intDepartmentId)
                departmentData.BottomDomains = GetBottomDomains(conn, intCycleId, intDepartmentId)
            End Using
        Catch ex As Exception
            departmentData = New DepartmentData() With {
                .Departments = New List(Of DepartmentResultData)(),
                .TopDomains = New List(Of DomainScoreData)(),
                .BottomDomains = New List(Of DomainScoreData)()
            }
        End Try

        Dim serializer As New JavaScriptSerializer()
        Return serializer.Serialize(departmentData)
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetFacultyData(cycleId As String, departmentId As String, courseId As String, facultyId As String, subjectId As String) As String
        Dim facultyData As New FacultyData()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        System.Diagnostics.Debug.WriteLine($"=== GetFacultyData Called ===")
        System.Diagnostics.Debug.WriteLine($"Params: cycleId={cycleId}, departmentId={departmentId}, facultyId={facultyId}")

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()
                Dim intCycleId As Integer = If(String.IsNullOrEmpty(cycleId) OrElse cycleId = "0", 0, Integer.Parse(cycleId))
                Dim intDepartmentId As Integer = If(String.IsNullOrEmpty(departmentId) OrElse departmentId = "0", 0, Integer.Parse(departmentId))
                Dim intCourseId As Integer = If(String.IsNullOrEmpty(courseId) OrElse courseId = "0", 0, Integer.Parse(courseId))
                Dim intFacultyId As Integer = If(String.IsNullOrEmpty(facultyId) OrElse facultyId = "0", 0, Integer.Parse(facultyId))
                Dim intSubjectId As Integer = If(String.IsNullOrEmpty(subjectId) OrElse subjectId = "0", 0, Integer.Parse(subjectId))

                System.Diagnostics.Debug.WriteLine($"Parsed: cycleId={intCycleId}, departmentId={intDepartmentId}, facultyId={intFacultyId}")

                facultyData.FacultyPerformance = GetFacultyPerformance(conn, intCycleId, intDepartmentId, intCourseId, intFacultyId, intSubjectId)
                facultyData.DomainScores = GetFacultyDomainScores(conn, intCycleId, intDepartmentId, intCourseId, intFacultyId, intSubjectId)
                facultyData.SubjectResults = GetFacultySubjectResults(conn, intCycleId, intDepartmentId, intCourseId, intFacultyId, intSubjectId)
                facultyData.Comments = GetFacultyComments(conn, intCycleId, intDepartmentId, intCourseId, intFacultyId, intSubjectId)

                System.Diagnostics.Debug.WriteLine($"FacultyPerformance: OverallScore={facultyData.FacultyPerformance.OverallScore}")
                System.Diagnostics.Debug.WriteLine($"DomainScores count: {facultyData.DomainScores.Count}")
                System.Diagnostics.Debug.WriteLine($"SubjectResults count: {facultyData.SubjectResults.Count}")
                System.Diagnostics.Debug.WriteLine($"Comments groups count: {facultyData.Comments.Count}")
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"Error in GetFacultyData: {ex.Message}")
            System.Diagnostics.Debug.WriteLine($"Stack Trace: {ex.StackTrace}")
            facultyData = New FacultyData() With {
            .FacultyPerformance = New FacultyPerformanceData(),
            .DomainScores = New List(Of DomainScoreData)(),
            .SubjectResults = New List(Of SubjectResultData)(),
            .Comments = New List(Of CommentGroup)()  ' Fixed this line
        }
        End Try

        Dim serializer As New JavaScriptSerializer()
        Dim result = serializer.Serialize(facultyData)
        System.Diagnostics.Debug.WriteLine($"GetFacultyData returning: {result}")
        Return result
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetFacultyList(cycleId As String, departmentId As String, courseId As String) As String
        Dim facultyList As New List(Of FacultyListData)()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()
                Dim intCycleId As Integer = If(String.IsNullOrEmpty(cycleId) OrElse cycleId = "0", 0, Integer.Parse(cycleId))
                Dim intDepartmentId As Integer = If(String.IsNullOrEmpty(departmentId) OrElse departmentId = "0", 0, Integer.Parse(departmentId))
                facultyList = GetFacultyListData(conn, intCycleId, intDepartmentId)
            End Using
        Catch ex As Exception
            ' Return empty list on error
        End Try

        Dim serializer As New JavaScriptSerializer()
        Return serializer.Serialize(facultyList)
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetFacultyQuestionBreakdown(cycleId As String, facultyId As String, subjectId As String, departmentId As String, courseId As String) As String
        Dim questionBreakdown As New List(Of FacultyQuestionBreakdownData)()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()
                Dim intCycleId As Integer = If(String.IsNullOrEmpty(cycleId) OrElse cycleId = "0", 0, Integer.Parse(cycleId))
                Dim intFacultyId As Integer = If(String.IsNullOrEmpty(facultyId) OrElse facultyId = "0", 0, Integer.Parse(facultyId))
                Dim intSubjectId As Integer = If(String.IsNullOrEmpty(subjectId) OrElse subjectId = "0", 0, Integer.Parse(subjectId))
                Dim intDepartmentId As Integer = If(String.IsNullOrEmpty(departmentId) OrElse departmentId = "0", 0, Integer.Parse(departmentId))
                Dim intCourseId As Integer = If(String.IsNullOrEmpty(courseId) OrElse courseId = "0", 0, Integer.Parse(courseId))

                questionBreakdown = GetFacultyQuestionBreakdownData(conn, intCycleId, intFacultyId, intSubjectId, intDepartmentId, intCourseId)
            End Using
        Catch ex As Exception
            ' Return empty list on error
        End Try

        Dim serializer As New JavaScriptSerializer()
        Return serializer.Serialize(questionBreakdown)
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function SearchAllData(searchTerm As String) As String
        Dim suggestions As New List(Of SearchSuggestion)()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()

                ' Add "Overall" option if search term matches
                If searchTerm.Trim().ToLower().Contains("overall") Or searchTerm.Trim() = "" Then
                    suggestions.Add(New SearchSuggestion With {
                .Type = "Cycle",
                .ID = -1, ' Use -1 to indicate "Overall"
                .PrimaryText = "Overall - All Cycles",
                .SecondaryText = "Combined data from all evaluation cycles"
            })
                End If

                ' Search Cycles (existing code)
                Dim cycleSql As String = "SELECT CycleID, CycleName, Term, Status, StartDate, EndDate FROM evaluationcycles " &
                           "WHERE (CycleName LIKE @searchTerm OR Term LIKE @searchTerm " &
                           "OR DATE_FORMAT(StartDate, '%M %d, %Y') LIKE @searchTerm " &
                           "OR DATE_FORMAT(EndDate, '%M %d, %Y') LIKE @searchTerm " &
                           "OR DATE_FORMAT(StartDate, '%Y-%m-%d') LIKE @searchTerm " &
                           "OR DATE_FORMAT(EndDate, '%Y-%m-%d') LIKE @searchTerm) " &
                           "ORDER BY StartDate DESC LIMIT 5"

                Using cmd As New MySqlCommand(cycleSql, conn)
                    cmd.Parameters.AddWithValue("@searchTerm", $"%{searchTerm}%")
                    Using reader As MySqlDataReader = cmd.ExecuteReader()
                        While reader.Read()
                            Dim startDate = If(reader("StartDate") Is DBNull.Value, "N/A", Convert.ToDateTime(reader("StartDate")).ToString("MMM d, yyyy"))
                            Dim endDate = If(reader("EndDate") Is DBNull.Value, "N/A", Convert.ToDateTime(reader("EndDate")).ToString("MMM d, yyyy"))

                            suggestions.Add(New SearchSuggestion With {
                        .Type = "Cycle",
                        .ID = If(reader("CycleID") Is DBNull.Value, 0, Convert.ToInt32(reader("CycleID"))),
                        .PrimaryText = If(reader("CycleName") Is DBNull.Value, String.Empty, reader("CycleName").ToString()),
                        .SecondaryText = $"{If(reader("Term") Is DBNull.Value, String.Empty, reader("Term").ToString())} - {startDate} to {endDate} - {If(reader("Status") Is DBNull.Value, String.Empty, reader("Status").ToString())}"
                    })
                        End While
                    End Using
                End Using

                ' Search Faculty - UPDATED to use concatenated name
                Dim facultySql As String = "SELECT UserID, 
                CONCAT(LastName, ', ', FirstName, 
                    CASE WHEN MiddleInitial IS NOT NULL AND MiddleInitial != '' THEN CONCAT(' ', MiddleInitial, '.') ELSE '' END,
                    CASE WHEN Suffix IS NOT NULL AND Suffix != '' THEN CONCAT(' ', Suffix) ELSE '' END
                ) AS FullName, 
                DepartmentName 
                FROM users u 
                LEFT JOIN departments d ON u.DepartmentID = d.DepartmentID 
                WHERE CONCAT(LastName, ', ', FirstName, 
                    CASE WHEN MiddleInitial IS NOT NULL AND MiddleInitial != '' THEN CONCAT(' ', MiddleInitial, '.') ELSE '' END,
                    CASE WHEN Suffix IS NOT NULL AND Suffix != '' THEN CONCAT(' ', Suffix) ELSE '' END
                ) LIKE @searchTerm 
                AND u.Role = 'Faculty' AND u.Status = 'Active' 
                ORDER BY LastName, FirstName LIMIT 5"

                Using cmd As New MySqlCommand(facultySql, conn)
                    cmd.Parameters.AddWithValue("@searchTerm", $"%{searchTerm}%")
                    Using reader As MySqlDataReader = cmd.ExecuteReader()
                        While reader.Read()
                            suggestions.Add(New SearchSuggestion With {
                        .Type = "Faculty",
                        .ID = If(reader("UserID") Is DBNull.Value, 0, Convert.ToInt32(reader("UserID"))),
                        .PrimaryText = If(reader("FullName") Is DBNull.Value, String.Empty, reader("FullName").ToString()),
                        .SecondaryText = If(reader("DepartmentName") Is DBNull.Value, String.Empty, reader("DepartmentName").ToString())
                    })
                        End While
                    End Using
                End Using
            End Using
        Catch ex As Exception
            ' Return empty list on error
        End Try

        Dim serializer As New JavaScriptSerializer()
        Return serializer.Serialize(suggestions)
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetCourseData(cycleId As String, departmentId As String) As String
        Dim courseList As New List(Of CourseData)()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()
                Dim intCycleId As Integer = If(String.IsNullOrEmpty(cycleId) OrElse cycleId = "0", 0, Integer.Parse(cycleId))
                Dim intDepartmentId As Integer = If(String.IsNullOrEmpty(departmentId) OrElse departmentId = "0", 0, Integer.Parse(departmentId))

                courseList = GetCourseDataFromDB(conn, intCycleId, intDepartmentId)
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetCourseData: " & ex.Message)
        End Try

        Dim serializer As New JavaScriptSerializer()
        Return serializer.Serialize(courseList)
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetCourseDomainScores(cycleId As String, departmentId As String, courseId As String) As String
        Dim domainScores As New List(Of DomainScoreData)()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()
                Dim intCycleId As Integer = If(String.IsNullOrEmpty(cycleId) OrElse cycleId = "0", 0, Integer.Parse(cycleId))
                Dim intDepartmentId As Integer = If(String.IsNullOrEmpty(departmentId) OrElse departmentId = "0", 0, Integer.Parse(departmentId))
                Dim intCourseId As Integer = If(String.IsNullOrEmpty(courseId) OrElse courseId = "0", 0, Integer.Parse(courseId))

                domainScores = GetCourseDomainScoresFromDB(conn, intCycleId, intDepartmentId, intCourseId)
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetCourseDomainScores: " & ex.Message)
        End Try

        Dim serializer As New JavaScriptSerializer()
        Return serializer.Serialize(domainScores)
    End Function

    ' Data Retrieval Methods with Weighted Calculations
    Private Shared Function GetTrendData(conn As MySqlConnection, cycleId As Integer) As List(Of TrendData)
        Dim trendData As New List(Of TrendData)()

        Try
            Dim sql As New StringBuilder()
            sql.AppendLine("SELECT ")
            sql.AppendLine("  ec.CycleName, ")
            sql.AppendLine("  COALESCE(ROUND(SUM((domain_avg.domain_score / 5) * domain_avg.domain_weight), 1), 0) as AverageScore ")
            sql.AppendLine("FROM evaluationcycles ec ")
            sql.AppendLine("LEFT JOIN (")
            sql.AppendLine("  SELECT ")
            sql.AppendLine("    es.CycleID, ")
            sql.AppendLine("    AVG(e.Score) as domain_score, ")
            sql.AppendLine("    ed.Weight as domain_weight ")
            sql.AppendLine("  FROM evaluations e ")
            sql.AppendLine("  INNER JOIN evaluationquestions eq ON e.QuestionID = eq.QuestionID ")
            sql.AppendLine("  INNER JOIN evaluationdomains ed ON eq.DomainID = ed.DomainID ")
            sql.AppendLine("  INNER JOIN evaluationsubmissions es ON e.SubmissionID = es.SubmissionID ")
            sql.AppendLine("  INNER JOIN facultyload fl ON es.LoadID = fl.LoadID AND fl.IsDeleted = 0 ")
            sql.AppendLine("  GROUP BY es.CycleID, ed.DomainID, ed.Weight ")
            sql.AppendLine(") as domain_avg ON ec.CycleID = domain_avg.CycleID ")
            sql.AppendLine("GROUP BY ec.CycleID, ec.CycleName ")
            sql.AppendLine("HAVING COUNT(domain_avg.domain_score) > 0 ")
            sql.AppendLine("ORDER BY ec.StartDate DESC ")
            sql.AppendLine("LIMIT 6")

            Using cmd As New MySqlCommand(sql.ToString(), conn)
                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    While reader.Read()
                        trendData.Add(New TrendData With {
                            .CycleName = If(reader("CycleName") Is DBNull.Value, "Unknown", reader("CycleName").ToString()),
                            .AverageScore = If(reader("AverageScore") Is DBNull.Value, 0D, Convert.ToDecimal(reader("AverageScore")))
                        })
                    End While
                End Using
            End Using

            If trendData.Count = 0 Then
                trendData = GetCurrentCycleDataAsTrend(conn, cycleId)
            End If

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"Error in GetTrendData: {ex.Message}")
            trendData = New List(Of TrendData)()
        End Try

        Return trendData
    End Function

    Private Shared Function GetCurrentCycleDataAsTrend(conn As MySqlConnection, cycleId As Integer) As List(Of TrendData)
        Dim trendData As New List(Of TrendData)()

        Try
            Dim sql As String = "
            SELECT 
                ec.CycleName, 
                COALESCE(ROUND(SUM((domain_avg.domain_score / 5) * domain_avg.domain_weight), 1), 0) as AverageScore 
            FROM evaluationcycles ec 
            LEFT JOIN (
                SELECT 
                    es.CycleID,
                    AVG(e.Score) as domain_score,
                    ed.Weight as domain_weight
                FROM evaluations e
                INNER JOIN evaluationquestions eq ON e.QuestionID = eq.QuestionID
                INNER JOIN evaluationdomains ed ON eq.DomainID = ed.DomainID
                INNER JOIN evaluationsubmissions es ON e.SubmissionID = es.SubmissionID
                INNER JOIN facultyload fl ON es.LoadID = fl.LoadID AND fl.IsDeleted = 0
                WHERE es.CycleID = @CycleID
                GROUP BY es.CycleID, ed.DomainID, ed.Weight
            ) as domain_avg ON ec.CycleID = domain_avg.CycleID
            WHERE ec.CycleID = @CycleID
            GROUP BY ec.CycleID, ec.CycleName"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@CycleID", cycleId)
                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    If reader.Read() Then
                        trendData.Add(New TrendData With {
                            .CycleName = If(reader("CycleName") Is DBNull.Value, "Current Cycle", reader("CycleName").ToString()),
                            .AverageScore = If(reader("AverageScore") Is DBNull.Value, 0D, Convert.ToDecimal(reader("AverageScore")))
                        })
                    Else
                        trendData.Add(New TrendData With {
                            .CycleName = "No Data",
                            .AverageScore = 0D
                        })
                    End If
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"Error in GetCurrentCycleDataAsTrend: {ex.Message}")
        End Try

        Return trendData
    End Function

    Private Shared Function GetKPIData(conn As MySqlConnection, cycleId As Integer, departmentId As Integer, courseId As Integer) As KPIData
        Dim kpiData As New KPIData()

        Try
            ' Get basic counts - UPDATED to use distinct classes from evaluations
            Dim countSql As New StringBuilder()
            countSql.AppendLine("SELECT ")
            countSql.AppendLine("  COUNT(DISTINCT fl.FacultyID) as FacultyEvaluated, ")
            countSql.AppendLine("  (SELECT COUNT(*) FROM users WHERE Role = 'Faculty' AND Status = 'Active') as TotalFaculty, ")
            countSql.AppendLine("  COUNT(DISTINCT fl.ClassID) as ClassesEvaluated, ") ' Distinct classes with evaluations
            countSql.AppendLine("  (SELECT COUNT(DISTINCT ClassID) FROM students WHERE Status = 'Active' AND ClassID IS NOT NULL) as ClassesOffered, ") ' Distinct classes with active students
            countSql.AppendLine("  COUNT(DISTINCT es.StudentID) as StudentsParticipated, ")
            countSql.AppendLine("  (SELECT COUNT(*) FROM students WHERE Status = 'Active') as TotalStudents, ")
            countSql.AppendLine("  COUNT(*) as TotalEvaluations ")
            countSql.AppendLine("FROM evaluations e ")
            countSql.AppendLine("INNER JOIN evaluationsubmissions es ON e.SubmissionID = es.SubmissionID ")
            countSql.AppendLine("INNER JOIN facultyload fl ON es.LoadID = fl.LoadID ")
            countSql.AppendLine("WHERE fl.IsDeleted = 0 ")

            If cycleId > 0 Then
                countSql.AppendLine("AND es.CycleID = @CycleID ")
            End If

            Using cmd As New MySqlCommand(countSql.ToString(), conn)
                If cycleId > 0 Then
                    cmd.Parameters.AddWithValue("@CycleID", cycleId)
                End If

                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    If reader.Read() Then
                        kpiData.FacultyEvaluated = If(reader("FacultyEvaluated") Is DBNull.Value, 0, Convert.ToInt32(reader("FacultyEvaluated")))
                        kpiData.TotalFaculty = If(reader("TotalFaculty") Is DBNull.Value, 0, Convert.ToInt32(reader("TotalFaculty")))
                        kpiData.FacultyPending = kpiData.TotalFaculty - kpiData.FacultyEvaluated
                        kpiData.ClassesEvaluated = If(reader("ClassesEvaluated") Is DBNull.Value, 0, Convert.ToInt32(reader("ClassesEvaluated")))
                        kpiData.ClassesOffered = If(reader("ClassesOffered") Is DBNull.Value, 0, Convert.ToInt32(reader("ClassesOffered")))
                        kpiData.StudentsParticipated = If(reader("StudentsParticipated") Is DBNull.Value, 0, Convert.ToInt32(reader("StudentsParticipated")))
                        kpiData.TotalStudents = If(reader("TotalStudents") Is DBNull.Value, 0, Convert.ToInt32(reader("TotalStudents")))
                        kpiData.TotalEvaluations = If(reader("TotalEvaluations") Is DBNull.Value, 0, Convert.ToInt32(reader("TotalEvaluations")))

                        If kpiData.TotalStudents > 0 Then
                            kpiData.StudentParticipationRate = Math.Round((kpiData.StudentsParticipated / kpiData.TotalStudents) * 100, 1)
                        Else
                            kpiData.StudentParticipationRate = 0
                        End If
                    End If
                End Using
            End Using

            ' CORRECTED: Get weighted institution average using submission-based method
            Dim weightedAvgSql As New StringBuilder()
            weightedAvgSql.AppendLine("WITH domain_scores AS (")
            weightedAvgSql.AppendLine("  SELECT ")
            weightedAvgSql.AppendLine("    es.SubmissionID,")
            weightedAvgSql.AppendLine("    d.DomainID,")
            weightedAvgSql.AppendLine("    d.Weight,")
            weightedAvgSql.AppendLine("    AVG(e.Score) AS DomainAvg,")
            weightedAvgSql.AppendLine("    (AVG(e.Score) / 5) * d.Weight AS WeightedPercentage")
            weightedAvgSql.AppendLine("  FROM Evaluations e")
            weightedAvgSql.AppendLine("  INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID")
            weightedAvgSql.AppendLine("  INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID")
            weightedAvgSql.AppendLine("  INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID")
            weightedAvgSql.AppendLine("  INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID")
            weightedAvgSql.AppendLine("  WHERE fl.IsDeleted = 0")
            weightedAvgSql.AppendLine("    AND e.Score IS NOT NULL")
            weightedAvgSql.AppendLine("    AND e.Score > 0")

            If cycleId > 0 Then
                weightedAvgSql.AppendLine("    AND es.CycleID = @CycleID")
            End If

            weightedAvgSql.AppendLine("  GROUP BY es.SubmissionID, d.DomainID, d.Weight")
            weightedAvgSql.AppendLine("),")
            weightedAvgSql.AppendLine("submission_totals AS (")
            weightedAvgSql.AppendLine("  SELECT")
            weightedAvgSql.AppendLine("    SubmissionID,")
            weightedAvgSql.AppendLine("    SUM(WeightedPercentage) AS TotalScore")
            weightedAvgSql.AppendLine("  FROM domain_scores")
            weightedAvgSql.AppendLine("  GROUP BY SubmissionID")
            weightedAvgSql.AppendLine(")")
            weightedAvgSql.AppendLine("SELECT ROUND(AVG(TotalScore), 1) AS InstitutionAverage")
            weightedAvgSql.AppendLine("FROM submission_totals")

            Using cmd As New MySqlCommand(weightedAvgSql.ToString(), conn)
                If cycleId > 0 Then
                    cmd.Parameters.AddWithValue("@CycleID", cycleId)
                End If

                Dim result = cmd.ExecuteScalar()
                If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                    kpiData.InstitutionAverage = Convert.ToDecimal(result)
                Else
                    kpiData.InstitutionAverage = 0
                End If
            End Using

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetKPIData: " & ex.Message)
        End Try

        Return kpiData
    End Function

    Private Shared Function GetDomainPerformance(conn As MySqlConnection, cycleId As Integer, departmentId As Integer, courseId As Integer) As List(Of DomainPerformanceData)
        Dim domains As New List(Of DomainPerformanceData)()

        Try
            Dim sql As New StringBuilder()
            sql.AppendLine("SELECT ")
            sql.AppendLine("  d.DomainID, ")
            sql.AppendLine("  d.DomainName, ")
            sql.AppendLine("  d.Weight,")
            sql.AppendLine("  ROUND(AVG(e.Score), 2) AS RawAvg, ")
            sql.AppendLine("  ROUND((AVG(e.Score) / 5) * d.Weight, 1) AS AvgScore ")
            sql.AppendLine("FROM evaluationdomains d ")
            sql.AppendLine("LEFT JOIN evaluationquestions eq ON d.DomainID = eq.DomainID ")
            sql.AppendLine("LEFT JOIN evaluations e ON eq.QuestionID = e.QuestionID ")
            sql.AppendLine("LEFT JOIN evaluationsubmissions es ON e.SubmissionID = es.SubmissionID ")
            sql.AppendLine("LEFT JOIN facultyload fl ON es.LoadID = fl.LoadID AND fl.IsDeleted = 0 ")
            sql.AppendLine(" WHERE e.Score IS NOT NULL ")
            sql.AppendLine("  AND e.Score > 0 ")

            If cycleId > 0 Then
                sql.AppendLine("AND es.CycleID = @CycleID ")
            End If

            sql.AppendLine("GROUP BY d.DomainID, d.DomainName, d.Weight ")
            sql.AppendLine("HAVING AVG(e.Score) > 0 ")
            sql.AppendLine("ORDER BY d.Weight DESC")

            Using cmd As New MySqlCommand(sql.ToString(), conn)
                If cycleId > 0 Then
                    cmd.Parameters.AddWithValue("@CycleID", cycleId)
                End If

                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    While reader.Read()
                        domains.Add(New DomainPerformanceData With {
                        .DomainName = If(reader("DomainName") Is DBNull.Value, "Unknown", reader("DomainName").ToString()),
                        .Weight = If(reader("Weight") Is DBNull.Value, 0, Convert.ToInt32(reader("Weight"))),
                        .RawAverage = If(reader("RawAvg") Is DBNull.Value, 0D, Convert.ToDecimal(reader("RawAvg"))),
                        .AverageScore = If(reader("AvgScore") Is DBNull.Value, 0D, Convert.ToDecimal(reader("AvgScore")))
                    })
                    End While
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetDomainPerformance: " & ex.Message)
        End Try

        Return domains
    End Function

    Private Shared Function GetDepartmentResults(conn As MySqlConnection, cycleId As Integer, departmentId As Integer) As List(Of DepartmentResultData)
        Dim departments As New List(Of DepartmentResultData)()

        Try
            ' CORRECTED: Use submission-based weighted calculation like DepartmentResult
            Dim sql As New StringBuilder()
            sql.AppendLine("WITH department_scores AS (")
            sql.AppendLine("  SELECT ")
            sql.AppendLine("    d.DepartmentID,")
            sql.AppendLine("    d.DepartmentName,")
            sql.AppendLine("    es.SubmissionID,")
            sql.AppendLine("    dom.DomainID,")
            sql.AppendLine("    dom.Weight,")
            sql.AppendLine("    AVG(e.Score) AS DomainAvg,")
            sql.AppendLine("    (AVG(e.Score) / 5) * dom.Weight AS WeightedPercentage")
            sql.AppendLine("  FROM departments d")
            sql.AppendLine("  INNER JOIN FacultyLoad fl ON d.DepartmentID = fl.DepartmentID AND fl.IsDeleted = 0")
            sql.AppendLine("  INNER JOIN EvaluationSubmissions es ON fl.LoadID = es.LoadID")
            sql.AppendLine("  INNER JOIN Evaluations e ON es.SubmissionID = e.SubmissionID")
            sql.AppendLine("  INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID")
            sql.AppendLine("  INNER JOIN EvaluationDomains dom ON q.DomainID = dom.DomainID")
            sql.AppendLine("  WHERE d.IsActive = 1")
            sql.AppendLine("    AND e.Score IS NOT NULL")
            sql.AppendLine("    AND e.Score > 0")

            If cycleId > 0 Then
                sql.AppendLine("    AND es.CycleID = @CycleID")
            End If
            If departmentId > 0 Then
                sql.AppendLine("    AND d.DepartmentID = @DepartmentID")
            End If

            sql.AppendLine("  GROUP BY d.DepartmentID, d.DepartmentName, es.SubmissionID, dom.DomainID, dom.Weight")
            sql.AppendLine("),")
            sql.AppendLine("department_totals AS (")
            sql.AppendLine("  SELECT")
            sql.AppendLine("    DepartmentID,")
            sql.AppendLine("    DepartmentName,")
            sql.AppendLine("    SubmissionID,")
            sql.AppendLine("    SUM(WeightedPercentage) AS TotalScore")
            sql.AppendLine("  FROM department_scores")
            sql.AppendLine("  GROUP BY DepartmentID, DepartmentName, SubmissionID")
            sql.AppendLine("),")
            sql.AppendLine("department_stats AS (")
            sql.AppendLine("  SELECT")
            sql.AppendLine("    dt.DepartmentID,")
            sql.AppendLine("    dt.DepartmentName,")
            sql.AppendLine("    ROUND(AVG(dt.TotalScore), 1) AS OverallScore,")
            sql.AppendLine("    COUNT(DISTINCT fl.FacultyID) AS FacultyCount,")
            sql.AppendLine("    COUNT(DISTINCT es.SubmissionID) AS EvaluationCount")
            sql.AppendLine("  FROM department_totals dt")
            sql.AppendLine("  LEFT JOIN FacultyLoad fl ON dt.DepartmentID = fl.DepartmentID AND fl.IsDeleted = 0")
            sql.AppendLine("  LEFT JOIN EvaluationSubmissions es ON fl.LoadID = es.LoadID")
            sql.AppendLine("  GROUP BY dt.DepartmentID, dt.DepartmentName")
            sql.AppendLine(")")
            sql.AppendLine("SELECT ")
            sql.AppendLine("  DepartmentID, ")
            sql.AppendLine("  DepartmentName, ")
            sql.AppendLine("  OverallScore, ")
            sql.AppendLine("  FacultyCount, ")
            sql.AppendLine("  EvaluationCount ")
            sql.AppendLine("FROM department_stats ")
            sql.AppendLine("ORDER BY DepartmentName")

            Using cmd As New MySqlCommand(sql.ToString(), conn)
                If departmentId > 0 Then
                    cmd.Parameters.AddWithValue("@DepartmentID", departmentId)
                End If
                If cycleId > 0 Then
                    cmd.Parameters.AddWithValue("@CycleID", cycleId)
                End If

                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    While reader.Read()
                        Dim dept As New DepartmentResultData With {
                        .DepartmentID = If(reader("DepartmentID") Is DBNull.Value, 0, Convert.ToInt32(reader("DepartmentID"))),
                        .DepartmentName = If(reader("DepartmentName") Is DBNull.Value, "Unknown", reader("DepartmentName").ToString()),
                        .OverallScore = If(reader("OverallScore") Is DBNull.Value, 0D, Convert.ToDecimal(reader("OverallScore"))),
                        .FacultyCount = If(reader("FacultyCount") Is DBNull.Value, 0, Convert.ToInt32(reader("FacultyCount"))),
                        .EvaluationCount = If(reader("EvaluationCount") Is DBNull.Value, 0, Convert.ToInt32(reader("EvaluationCount"))),
                        .DomainScores = New List(Of DomainScoreData)()
                    }
                        departments.Add(dept)
                    End While
                End Using
            End Using

            ' Get domain scores for each department
            For Each dept In departments
                dept.DomainScores = GetDepartmentDomainScores(conn, cycleId, dept.DepartmentID)
            Next

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetDepartmentResults: " & ex.Message)
        End Try

        Return departments
    End Function

    Private Shared Function GetDepartmentDomainScores(conn As MySqlConnection, cycleId As Integer, departmentId As Integer) As List(Of DomainScoreData)
        Dim domains As New List(Of DomainScoreData)()

        Try
            Dim sql As New StringBuilder()
            sql.AppendLine("SELECT ")
            sql.AppendLine("  ed.DomainName, ")
            sql.AppendLine("  COALESCE(ROUND((AVG(e.Score) / 5) * ed.Weight, 1), 0) as DomainScore, ")
            sql.AppendLine("  COALESCE(ROUND(AVG(e.Score), 2), 0) as RawScore, ")
            sql.AppendLine("  ed.Weight as DomainWeight ")
            sql.AppendLine("FROM evaluationdomains ed ")
            sql.AppendLine("LEFT JOIN evaluationquestions eq ON ed.DomainID = eq.DomainID ")
            sql.AppendLine("LEFT JOIN evaluations e ON eq.QuestionID = e.QuestionID ")
            sql.AppendLine("LEFT JOIN evaluationsubmissions es ON e.SubmissionID = es.SubmissionID ")
            sql.AppendLine("LEFT JOIN facultyload fl ON es.LoadID = fl.LoadID AND fl.IsDeleted = 0 ")
            sql.AppendLine("WHERE fl.DepartmentID = @DepartmentID ")
            ' sql.AppendLine("WHERE ed.IsActive = 1 AND eq.IsActive = 1 ")

            If cycleId > 0 Then
                sql.AppendLine("AND es.CycleID = @CycleID ")
            End If

            sql.AppendLine("GROUP BY ed.DomainID, ed.DomainName, ed.Weight ")
            sql.AppendLine("HAVING COUNT(e.EvalID) > 0 ")
            sql.AppendLine("ORDER BY ed.DomainID")

            Using cmd As New MySqlCommand(sql.ToString(), conn)
                cmd.Parameters.AddWithValue("@DepartmentID", departmentId)
                If cycleId > 0 Then
                    cmd.Parameters.AddWithValue("@CycleID", cycleId)
                End If

                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    While reader.Read()
                        Dim domain As New DomainScoreData()
                        domain.DomainName = If(reader("DomainName") Is DBNull.Value, "Unknown", reader("DomainName").ToString())
                        domain.Score = If(reader("DomainScore") Is DBNull.Value, 0D, Convert.ToDecimal(reader("DomainScore")))
                        domain.RawScore = If(reader("RawScore") Is DBNull.Value, 0D, Convert.ToDecimal(reader("RawScore")))
                        domain.Weight = If(reader("DomainWeight") Is DBNull.Value, 0, Convert.ToInt32(reader("DomainWeight")))
                        domains.Add(domain)
                    End While
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetDepartmentDomainScores: " & ex.Message)
        End Try

        Return domains
    End Function

    Private Shared Function GetTopDomains(conn As MySqlConnection, cycleId As Integer, departmentId As Integer) As List(Of DomainScoreData)
        Return GetDomainRanking(conn, cycleId, departmentId, "DESC", 3)
    End Function

    Private Shared Function GetBottomDomains(conn As MySqlConnection, cycleId As Integer, departmentId As Integer) As List(Of DomainScoreData)
        Return GetDomainRanking(conn, cycleId, departmentId, "ASC", 3)
    End Function

    Private Shared Function GetDomainRanking(conn As MySqlConnection, cycleId As Integer, departmentId As Integer, order As String, limit As Integer) As List(Of DomainScoreData)
        Dim domains As New List(Of DomainScoreData)()

        Try
            Dim sql As New StringBuilder()
            sql.AppendLine("SELECT ")
            sql.AppendLine("  ed.DomainName, ")
            sql.AppendLine("  COALESCE(ROUND((AVG(e.Score) / 5) * ed.Weight, 1), 0) as DomainScore ")
            sql.AppendLine("FROM evaluationdomains ed ")
            sql.AppendLine("LEFT JOIN evaluationquestions eq ON ed.DomainID = eq.DomainID ")
            sql.AppendLine("LEFT JOIN evaluations e ON eq.QuestionID = e.QuestionID ")
            sql.AppendLine("LEFT JOIN evaluationsubmissions es ON e.SubmissionID = es.SubmissionID ")
            sql.AppendLine("LEFT JOIN facultyload fl ON es.LoadID = fl.LoadID AND fl.IsDeleted = 0 ")
            ' sql.AppendLine("WHERE ed.IsActive = 1 AND eq.IsActive = 1 ")

            If cycleId > 0 Then
                sql.AppendLine("AND es.CycleID = @CycleID ")
            End If
            If departmentId > 0 Then
                sql.AppendLine("AND fl.DepartmentID = @DepartmentID ")
            End If

            sql.AppendLine("GROUP BY ed.DomainID, ed.DomainName, ed.Weight ")
            sql.AppendLine("HAVING COUNT(e.EvalID) > 0 ")
            sql.AppendLine($"ORDER BY DomainScore {order} ")
            sql.AppendLine($"LIMIT {limit}")

            Using cmd As New MySqlCommand(sql.ToString(), conn)
                If cycleId > 0 Then
                    cmd.Parameters.AddWithValue("@CycleID", cycleId)
                End If
                If departmentId > 0 Then
                    cmd.Parameters.AddWithValue("@DepartmentID", departmentId)
                End If

                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    While reader.Read()
                        domains.Add(New DomainScoreData With {
                            .DomainName = If(reader("DomainName") Is DBNull.Value, "Unknown", reader("DomainName").ToString()),
                            .Score = If(reader("DomainScore") Is DBNull.Value, 0D, Convert.ToDecimal(reader("DomainScore")))
                        })
                    End While
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetDomainRanking: " & ex.Message)
        End Try

        Return domains
    End Function

    Private Shared Function GetFacultyPerformance(conn As MySqlConnection, cycleId As Integer, departmentId As Integer, courseId As Integer, facultyId As Integer, subjectId As Integer) As FacultyPerformanceData
        Dim performance As New FacultyPerformanceData()

        Try
            ' CORRECTED: Use submission-based weighted calculation like DepartmentResult
            Dim weightedSql As New StringBuilder()
            weightedSql.AppendLine("WITH domain_scores AS (")
            weightedSql.AppendLine("  SELECT ")
            weightedSql.AppendLine("    es.SubmissionID,")
            weightedSql.AppendLine("    d.DomainID,")
            weightedSql.AppendLine("    d.Weight,")
            weightedSql.AppendLine("    AVG(e.Score) AS DomainAvg,")
            weightedSql.AppendLine("    (AVG(e.Score) / 5) * d.Weight AS WeightedPercentage")
            weightedSql.AppendLine("  FROM Evaluations e")
            weightedSql.AppendLine("  INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID")
            weightedSql.AppendLine("  INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID")
            weightedSql.AppendLine("  INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID")
            weightedSql.AppendLine("  INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID")
            weightedSql.AppendLine("  WHERE fl.IsDeleted = 0")
            weightedSql.AppendLine("    AND fl.FacultyID = @FacultyID")
            weightedSql.AppendLine("    AND e.Score IS NOT NULL")
            weightedSql.AppendLine("    AND e.Score > 0")

            If cycleId > 0 Then
                weightedSql.AppendLine("    AND es.CycleID = @CycleID")
            End If
            If departmentId > 0 Then
                weightedSql.AppendLine("    AND fl.DepartmentID = @DepartmentID")
            End If
            If courseId > 0 Then
                weightedSql.AppendLine("    AND fl.CourseID = @CourseID")
            End If
            If subjectId > 0 Then
                weightedSql.AppendLine("    AND fl.SubjectID = @SubjectID")
            End If

            weightedSql.AppendLine("  GROUP BY es.SubmissionID, d.DomainID, d.Weight")
            weightedSql.AppendLine("),")
            weightedSql.AppendLine("submission_totals AS (")
            weightedSql.AppendLine("  SELECT")
            weightedSql.AppendLine("    SubmissionID,")
            weightedSql.AppendLine("    SUM(WeightedPercentage) AS TotalScore")
            weightedSql.AppendLine("  FROM domain_scores")
            weightedSql.AppendLine("  GROUP BY SubmissionID")
            weightedSql.AppendLine("),")
            weightedSql.AppendLine("faculty_stats AS (")
            weightedSql.AppendLine("  SELECT")
            weightedSql.AppendLine("    ROUND(AVG(st.TotalScore), 1) AS WeightedOverallScore,")
            weightedSql.AppendLine("    COUNT(DISTINCT st.SubmissionID) AS EvaluationsCount")
            weightedSql.AppendLine("  FROM submission_totals st")
            weightedSql.AppendLine(")")
            weightedSql.AppendLine("SELECT ")
            weightedSql.AppendLine("  WeightedOverallScore,")
            weightedSql.AppendLine("  EvaluationsCount")
            weightedSql.AppendLine("FROM faculty_stats")

            Using cmd As New MySqlCommand(weightedSql.ToString(), conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyId)
                If cycleId > 0 Then cmd.Parameters.AddWithValue("@CycleID", cycleId)
                If departmentId > 0 Then cmd.Parameters.AddWithValue("@DepartmentID", departmentId)
                If courseId > 0 Then cmd.Parameters.AddWithValue("@CourseID", courseId)
                If subjectId > 0 Then cmd.Parameters.AddWithValue("@SubjectID", subjectId)

                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    If reader.Read() Then
                        performance.OverallScore = If(reader("WeightedOverallScore") Is DBNull.Value, 0D, Convert.ToDecimal(reader("WeightedOverallScore")))
                        performance.EvaluationsCount = If(reader("EvaluationsCount") Is DBNull.Value, 0, Convert.ToInt32(reader("EvaluationsCount")))
                    Else
                        performance.OverallScore = 0
                        performance.EvaluationsCount = 0
                    End If
                End Using
            End Using

            ' Get raw overall score (1-5 scale)
            Dim rawSql As String = "
            SELECT COALESCE(ROUND(AVG(e.Score), 2), 0) as RawOverallScore
            FROM evaluations e
            INNER JOIN evaluationsubmissions es ON e.SubmissionID = es.SubmissionID
            INNER JOIN facultyload fl ON es.LoadID = fl.LoadID
            WHERE fl.IsDeleted = 0 
            AND fl.FacultyID = @FacultyID 
            AND e.Score IS NOT NULL 
            AND e.Score > 0 "

            If cycleId > 0 Then rawSql &= " AND es.CycleID = @CycleID "
            If departmentId > 0 Then rawSql &= " AND fl.DepartmentID = @DepartmentID "
            If courseId > 0 Then rawSql &= " AND fl.CourseID = @CourseID "
            If subjectId > 0 Then rawSql &= " AND fl.SubjectID = @SubjectID "

            Using cmd As New MySqlCommand(rawSql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyId)
                If cycleId > 0 Then cmd.Parameters.AddWithValue("@CycleID", cycleId)
                If departmentId > 0 Then cmd.Parameters.AddWithValue("@DepartmentID", departmentId)
                If courseId > 0 Then cmd.Parameters.AddWithValue("@CourseID", courseId)
                If subjectId > 0 Then cmd.Parameters.AddWithValue("@SubjectID", subjectId)

                Dim result = cmd.ExecuteScalar()
                performance.RawOverallScore = If(result Is Nothing Or IsDBNull(result), 0D, Convert.ToDecimal(result))
            End Using

            ' Get subjects count
            Dim subjectsSql As String = "
            SELECT COUNT(DISTINCT fl.SubjectID) as SubjectsCount
            FROM facultyload fl
            WHERE fl.IsDeleted = 0 
            AND fl.FacultyID = @FacultyID "

            If cycleId > 0 Then
                subjectsSql &= " AND EXISTS (SELECT 1 FROM evaluationsubmissions es WHERE es.LoadID = fl.LoadID AND es.CycleID = @CycleID) "
            End If
            If departmentId > 0 Then subjectsSql &= " AND fl.DepartmentID = @DepartmentID "
            If courseId > 0 Then subjectsSql &= " AND fl.CourseID = @CourseID "
            If subjectId > 0 Then subjectsSql &= " AND fl.SubjectID = @SubjectID "

            Using cmd As New MySqlCommand(subjectsSql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyId)
                If cycleId > 0 Then cmd.Parameters.AddWithValue("@CycleID", cycleId)
                If departmentId > 0 Then cmd.Parameters.AddWithValue("@DepartmentID", departmentId)
                If courseId > 0 Then cmd.Parameters.AddWithValue("@CourseID", courseId)
                If subjectId > 0 Then cmd.Parameters.AddWithValue("@SubjectID", subjectId)

                Dim result = cmd.ExecuteScalar()
                performance.SubjectsCount = If(result Is Nothing Or IsDBNull(result), 0, Convert.ToInt32(result))
            End Using

            System.Diagnostics.Debug.WriteLine($"Faculty {facultyId} performance: Raw={performance.RawOverallScore}, Weighted={performance.OverallScore}, Subjects={performance.SubjectsCount}, Evals={performance.EvaluationsCount}")

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetFacultyPerformance: " & ex.Message)
            System.Diagnostics.Debug.WriteLine("Stack Trace: " & ex.StackTrace)
        End Try

        Return performance
    End Function

    Private Shared Function GetFacultyDomainScores(conn As MySqlConnection, cycleId As Integer, departmentId As Integer, courseId As Integer, facultyId As Integer, subjectId As Integer) As List(Of DomainScoreData)
        Dim domains As New List(Of DomainScoreData)()

        Try
            Dim sql As String = "
        SELECT 
            d.DomainID,
            d.DomainName, 
            d.Weight,
            ROUND(AVG(e.Score), 2) AS RawScore,
            ROUND((AVG(e.Score) / 5) * d.Weight, 1) AS DomainScore
        FROM Evaluations e
        INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
        INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
        INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
        INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
        WHERE fl.IsDeleted = 0 
        AND fl.FacultyID = @FacultyID 
        AND e.Score IS NOT NULL 
        AND e.Score > 0 "
            ' AND d.IsActive = 1 
            ' AND q.IsActive = 1

            If subjectId > 0 Then sql &= " AND fl.SubjectID = @SubjectID "
            If departmentId > 0 Then sql &= " AND fl.DepartmentID = @DepartmentID "
            If courseId > 0 Then sql &= " AND fl.CourseID = @CourseID "
            If cycleId > 0 Then sql &= " AND es.CycleID = @CycleID "

            sql &= " GROUP BY d.DomainID, d.DomainName, d.Weight "
            sql &= " HAVING AVG(e.Score) > 0 "
            sql &= " ORDER BY d.Weight DESC"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyId)

                If subjectId > 0 Then cmd.Parameters.AddWithValue("@SubjectID", subjectId)
                If departmentId > 0 Then cmd.Parameters.AddWithValue("@DepartmentID", departmentId)
                If courseId > 0 Then cmd.Parameters.AddWithValue("@CourseID", courseId)
                If cycleId > 0 Then cmd.Parameters.AddWithValue("@CycleID", cycleId)

                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    Dim recordCount As Integer = 0
                    While reader.Read()
                        recordCount += 1
                        Dim domainName = If(reader("DomainName") Is DBNull.Value, "Unknown", reader("DomainName").ToString())
                        Dim domainScore = If(reader("DomainScore") Is DBNull.Value, 0D, Convert.ToDecimal(reader("DomainScore")))
                        Dim rawScore = If(reader("RawScore") Is DBNull.Value, 0D, Convert.ToDecimal(reader("RawScore")))
                        Dim weight = If(reader("Weight") Is DBNull.Value, 0, Convert.ToInt32(reader("Weight")))

                        domains.Add(New DomainScoreData With {
                        .DomainName = domainName,
                        .Score = domainScore,
                        .RawScore = rawScore,
                        .Weight = weight
                    })
                    End While
                End Using
            End Using

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"ERROR in GetFacultyDomainScores: {ex.Message}")
        End Try

        Return domains
    End Function

    Private Shared Function GetFacultySubjectResults(conn As MySqlConnection, cycleId As Integer, departmentId As Integer, courseId As Integer, facultyId As Integer, subjectId As Integer) As List(Of SubjectResultData)
        Dim subjects As New List(Of SubjectResultData)()

        Try
            ' CORRECTED: Use submission-based weighted calculation for subject results
            Dim sql As New StringBuilder()
            sql.AppendLine("WITH subject_domains AS (")
            sql.AppendLine("  SELECT ")
            sql.AppendLine("    fl.SubjectID,")
            sql.AppendLine("    fl.DepartmentID,")
            sql.AppendLine("    fl.CourseID,")
            sql.AppendLine("    es.SubmissionID,")
            sql.AppendLine("    d.DomainID,")
            sql.AppendLine("    d.Weight,")
            sql.AppendLine("    AVG(e.Score) AS DomainAvg,")
            sql.AppendLine("    (AVG(e.Score) / 5) * d.Weight AS WeightedPercentage")
            sql.AppendLine("  FROM Evaluations e")
            sql.AppendLine("  INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID")
            sql.AppendLine("  INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID")
            sql.AppendLine("  INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID")
            sql.AppendLine("  INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID")
            sql.AppendLine("  WHERE fl.IsDeleted = 0")
            sql.AppendLine("    AND fl.FacultyID = @FacultyID")
            sql.AppendLine("    AND e.Score IS NOT NULL")
            sql.AppendLine("    AND e.Score > 0")

            If cycleId > 0 Then sql.AppendLine("    AND es.CycleID = @CycleID")
            If departmentId > 0 Then sql.AppendLine("    AND fl.DepartmentID = @DepartmentID")
            If courseId > 0 Then sql.AppendLine("    AND fl.CourseID = @CourseID")
            If subjectId > 0 Then sql.AppendLine("    AND fl.SubjectID = @SubjectID")

            sql.AppendLine("  GROUP BY fl.SubjectID, fl.DepartmentID, fl.CourseID, es.SubmissionID, d.DomainID, d.Weight")
            sql.AppendLine("),")
            sql.AppendLine("subject_totals AS (")
            sql.AppendLine("  SELECT")
            sql.AppendLine("    SubjectID,")
            sql.AppendLine("    DepartmentID,")
            sql.AppendLine("    CourseID,")
            sql.AppendLine("    SubmissionID,")
            sql.AppendLine("    SUM(WeightedPercentage) AS TotalScore")
            sql.AppendLine("  FROM subject_domains")
            sql.AppendLine("  GROUP BY SubjectID, DepartmentID, CourseID, SubmissionID")
            sql.AppendLine("),")
            sql.AppendLine("subject_stats AS (")
            sql.AppendLine("  SELECT")
            sql.AppendLine("    st.SubjectID,")
            sql.AppendLine("    st.DepartmentID,")
            sql.AppendLine("    st.CourseID,")
            sql.AppendLine("    ROUND(AVG(st.TotalScore), 1) AS AverageScore,")
            sql.AppendLine("    COUNT(DISTINCT st.SubmissionID) AS EvaluationCount")
            sql.AppendLine("  FROM subject_totals st")
            sql.AppendLine("  GROUP BY st.SubjectID, st.DepartmentID, st.CourseID")
            sql.AppendLine(")")
            sql.AppendLine("SELECT ")
            sql.AppendLine("  s.SubjectID, ")
            sql.AppendLine("  s.SubjectName, ")
            sql.AppendLine("  d.DepartmentID, ")
            sql.AppendLine("  d.DepartmentName, ")
            sql.AppendLine("  c.CourseID, ")
            sql.AppendLine("  c.CourseName, ")
            sql.AppendLine("  COALESCE(ss.AverageScore, 0) as AverageScore, ")
            sql.AppendLine("  COALESCE(ss.EvaluationCount, 0) as EvaluationCount ")
            sql.AppendLine("FROM FacultyLoad fl")
            sql.AppendLine("INNER JOIN Subjects s ON fl.SubjectID = s.SubjectID AND s.IsActive = 1")
            sql.AppendLine("INNER JOIN Courses c ON fl.CourseID = c.CourseID AND c.IsActive = 1")
            sql.AppendLine("INNER JOIN Departments d ON fl.DepartmentID = d.DepartmentID AND d.IsActive = 1")
            sql.AppendLine("LEFT JOIN subject_stats ss ON fl.SubjectID = ss.SubjectID AND fl.DepartmentID = ss.DepartmentID AND fl.CourseID = ss.CourseID")
            sql.AppendLine("WHERE fl.IsDeleted = 0 ")
            sql.AppendLine("AND fl.FacultyID = @FacultyID ")

            If departmentId > 0 Then sql.AppendLine("AND fl.DepartmentID = @DepartmentID ")
            If courseId > 0 Then sql.AppendLine("AND fl.CourseID = @CourseID ")
            If subjectId > 0 Then sql.AppendLine("AND fl.SubjectID = @SubjectID ")

            sql.AppendLine("GROUP BY s.SubjectID, s.SubjectName, d.DepartmentID, d.DepartmentName, c.CourseID, c.CourseName, ss.AverageScore, ss.EvaluationCount ")
            sql.AppendLine("ORDER BY d.DepartmentName, c.CourseName, s.SubjectName")

            Using cmd As New MySqlCommand(sql.ToString(), conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyId)
                If cycleId > 0 Then cmd.Parameters.AddWithValue("@CycleID", cycleId)
                If departmentId > 0 Then cmd.Parameters.AddWithValue("@DepartmentID", departmentId)
                If courseId > 0 Then cmd.Parameters.AddWithValue("@CourseID", courseId)
                If subjectId > 0 Then cmd.Parameters.AddWithValue("@SubjectID", subjectId)

                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    While reader.Read()
                        subjects.Add(New SubjectResultData With {
                        .SubjectID = If(reader("SubjectID") Is DBNull.Value, 0, Convert.ToInt32(reader("SubjectID"))),
                        .SubjectName = If(reader("SubjectName") Is DBNull.Value, "Unknown", reader("SubjectName").ToString()),
                        .CourseName = If(reader("CourseName") Is DBNull.Value, "Unknown", reader("CourseName").ToString()),
                        .DepartmentName = If(reader("DepartmentName") Is DBNull.Value, "Unknown", reader("DepartmentName").ToString()),
                        .DepartmentID = If(reader("DepartmentID") Is DBNull.Value, 0, Convert.ToInt32(reader("DepartmentID"))),
                        .CourseID = If(reader("CourseID") Is DBNull.Value, 0, Convert.ToInt32(reader("CourseID"))),
                        .AverageScore = If(reader("AverageScore") Is DBNull.Value, 0D, Convert.ToDecimal(reader("AverageScore"))),
                        .EvaluationCount = If(reader("EvaluationCount") Is DBNull.Value, 0, Convert.ToInt32(reader("EvaluationCount")))
                    })
                    End While
                End Using
            End Using

            System.Diagnostics.Debug.WriteLine($"Found {subjects.Count} subjects for faculty {facultyId}")

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetFacultySubjectResults: " & ex.Message)
        End Try

        Return subjects
    End Function

    Private Shared Function GetFacultyComments(conn As MySqlConnection, cycleId As Integer, departmentId As Integer, courseId As Integer, facultyId As Integer, subjectId As Integer) As List(Of CommentGroup)
        Dim commentGroups As New List(Of CommentGroup)()

        ' Initialize the three comment groups
        Dim strengthsGroup As New CommentGroup With {.CommentType = "Strengths", .Comments = New List(Of CommentData)(), .TotalCount = 0}
        Dim weaknessesGroup As New CommentGroup With {.CommentType = "Weaknesses", .Comments = New List(Of CommentData)(), .TotalCount = 0}
        Dim additionalGroup As New CommentGroup With {.CommentType = "Additional Comments", .Comments = New List(Of CommentData)(), .TotalCount = 0}

        Try
            Dim sql As New StringBuilder()
            sql.AppendLine("SELECT ")
            sql.AppendLine("  es.Strengths, ")
            sql.AppendLine("  es.Weaknesses, ")
            sql.AppendLine("  es.AdditionalMessage ")
            sql.AppendLine("FROM evaluationsubmissions es")
            sql.AppendLine("INNER JOIN facultyload fl ON es.LoadID = fl.LoadID")
            sql.AppendLine("WHERE ((es.Strengths IS NOT NULL AND es.Strengths <> '') ")
            sql.AppendLine("   OR (es.Weaknesses IS NOT NULL AND es.Weaknesses <> '') ")
            sql.AppendLine("   OR (es.AdditionalMessage IS NOT NULL AND es.AdditionalMessage <> '')) ")
            sql.AppendLine("AND fl.FacultyID = @FacultyID ")
            sql.AppendLine("AND fl.IsDeleted = 0 ")

            ' Add filters for context
            If subjectId > 0 Then
                sql.AppendLine("AND fl.SubjectID = @SubjectID ")
            End If

            If departmentId > 0 Then
                sql.AppendLine("AND fl.DepartmentID = @DepartmentID ")
            End If

            If courseId > 0 Then
                sql.AppendLine("AND fl.CourseID = @CourseID ")
            End If

            If cycleId > 0 Then
                sql.AppendLine("AND es.CycleID = @CycleID ")
            End If

            sql.AppendLine("ORDER BY es.SubmissionDate DESC")

            Using cmd As New MySqlCommand(sql.ToString(), conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyId)

                If subjectId > 0 Then
                    cmd.Parameters.AddWithValue("@SubjectID", subjectId)
                End If

                If departmentId > 0 Then
                    cmd.Parameters.AddWithValue("@DepartmentID", departmentId)
                End If

                If courseId > 0 Then
                    cmd.Parameters.AddWithValue("@CourseID", courseId)
                End If

                If cycleId > 0 Then
                    cmd.Parameters.AddWithValue("@CycleID", cycleId)
                End If

                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    While reader.Read()
                        Dim strengths = If(reader("Strengths") Is DBNull.Value, String.Empty, reader("Strengths").ToString().Trim())
                        Dim weaknesses = If(reader("Weaknesses") Is DBNull.Value, String.Empty, reader("Weaknesses").ToString().Trim())
                        Dim additionalMessage = If(reader("AdditionalMessage") Is DBNull.Value, String.Empty, reader("AdditionalMessage").ToString().Trim())

                        ' Process Strengths
                        If Not String.IsNullOrWhiteSpace(strengths) Then
                            strengthsGroup.Comments.Add(New CommentData With {
                            .CommentText = strengths
                        })
                        End If

                        ' Process Weaknesses
                        If Not String.IsNullOrWhiteSpace(weaknesses) Then
                            weaknessesGroup.Comments.Add(New CommentData With {
                            .CommentText = weaknesses
                        })
                        End If

                        ' Process Additional Messages
                        If Not String.IsNullOrWhiteSpace(additionalMessage) Then
                            additionalGroup.Comments.Add(New CommentData With {
                            .CommentText = additionalMessage
                        })
                        End If
                    End While
                End Using
            End Using

            ' Set total counts
            strengthsGroup.TotalCount = strengthsGroup.Comments.Count
            weaknessesGroup.TotalCount = weaknessesGroup.Comments.Count
            additionalGroup.TotalCount = additionalGroup.Comments.Count

            ' Only add groups that have comments
            If strengthsGroup.TotalCount > 0 Then commentGroups.Add(strengthsGroup)
            If weaknessesGroup.TotalCount > 0 Then commentGroups.Add(weaknessesGroup)
            If additionalGroup.TotalCount > 0 Then commentGroups.Add(additionalGroup)

            System.Diagnostics.Debug.WriteLine($"Found comments - Strengths: {strengthsGroup.TotalCount}, Weaknesses: {weaknessesGroup.TotalCount}, Additional: {additionalGroup.TotalCount}")

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetFacultyComments: " & ex.Message)
            System.Diagnostics.Debug.WriteLine("Stack Trace: " & ex.StackTrace)
        End Try

        Return commentGroups
    End Function

    Private Shared Function GetFacultyListData(conn As MySqlConnection, cycleId As Integer, departmentId As Integer) As List(Of FacultyListData)
        Dim facultyList As New List(Of FacultyListData)()

        Try
            ' Modified query to only get faculty with evaluations and sort by highest score first
            Dim sql As New StringBuilder()
            sql.AppendLine("WITH faculty_scores AS (")
            sql.AppendLine("  WITH domain_scores AS (")
            sql.AppendLine("    SELECT ")
            sql.AppendLine("      fl.FacultyID,")
            sql.AppendLine("      es.SubmissionID,")
            sql.AppendLine("      d.DomainID,")
            sql.AppendLine("      d.Weight,")
            sql.AppendLine("      AVG(e.Score) AS DomainAvg,")
            sql.AppendLine("      (AVG(e.Score) / 5) * d.Weight AS WeightedPercentage")
            sql.AppendLine("    FROM Evaluations e")
            sql.AppendLine("    INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID")
            sql.AppendLine("    INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID")
            sql.AppendLine("    INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID")
            sql.AppendLine("    INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID")
            sql.AppendLine("    WHERE fl.IsDeleted = 0")
            sql.AppendLine("      AND e.Score IS NOT NULL")
            sql.AppendLine("      AND e.Score > 0")

            If cycleId > 0 Then
                sql.AppendLine("      AND es.CycleID = @CycleID")
            End If
            If departmentId > 0 Then
                sql.AppendLine("      AND fl.DepartmentID = @DepartmentID")
            End If

            sql.AppendLine("    GROUP BY fl.FacultyID, es.SubmissionID, d.DomainID, d.Weight")
            sql.AppendLine("  ),")
            sql.AppendLine("  submission_totals AS (")
            sql.AppendLine("    SELECT")
            sql.AppendLine("      FacultyID,")
            sql.AppendLine("      SubmissionID,")
            sql.AppendLine("      SUM(WeightedPercentage) AS TotalScore")
            sql.AppendLine("    FROM domain_scores")
            sql.AppendLine("    GROUP BY FacultyID, SubmissionID")
            sql.AppendLine("  ),")
            sql.AppendLine("  faculty_stats AS (")
            sql.AppendLine("    SELECT")
            sql.AppendLine("      FacultyID,")
            sql.AppendLine("      ROUND(AVG(TotalScore), 1) AS WeightedOverallScore,")
            sql.AppendLine("      COUNT(DISTINCT SubmissionID) AS EvaluationsCount")
            sql.AppendLine("    FROM submission_totals")
            sql.AppendLine("    GROUP BY FacultyID")
            sql.AppendLine("  )")
            sql.AppendLine("  SELECT ")
            sql.AppendLine("    fs.FacultyID,")
            sql.AppendLine("    fs.WeightedOverallScore AS OverallScore,")
            sql.AppendLine("    fs.EvaluationsCount,")
            sql.AppendLine("    (SELECT COUNT(DISTINCT fl2.SubjectID) ")
            sql.AppendLine("     FROM FacultyLoad fl2 ")
            sql.AppendLine("     WHERE fl2.FacultyID = fs.FacultyID AND fl2.IsDeleted = 0")
            If cycleId > 0 Then
                sql.AppendLine("       AND EXISTS (SELECT 1 FROM EvaluationSubmissions es2 WHERE es2.LoadID = fl2.LoadID AND es2.CycleID = @CycleID2)")
            End If
            sql.AppendLine("    ) AS SubjectsCount,")
            sql.AppendLine("    (SELECT COALESCE(ROUND(AVG(e2.Score), 2), 0) ")
            sql.AppendLine("     FROM evaluations e2")
            sql.AppendLine("     INNER JOIN evaluationsubmissions es2 ON e2.SubmissionID = es2.SubmissionID")
            sql.AppendLine("     INNER JOIN facultyload fl2 ON es2.LoadID = fl2.LoadID")
            sql.AppendLine("     WHERE fl2.FacultyID = fs.FacultyID AND fl2.IsDeleted = 0 ")
            sql.AppendLine("       AND e2.Score IS NOT NULL AND e2.Score > 0")
            If cycleId > 0 Then
                sql.AppendLine("       AND es2.CycleID = @CycleID3")
            End If
            sql.AppendLine("    ) AS RawOverallScore")
            sql.AppendLine("  FROM faculty_stats fs")
            sql.AppendLine("  WHERE fs.EvaluationsCount > 0") ' Only faculty with evaluations
            sql.AppendLine(")")
            sql.AppendLine("SELECT ")
            sql.AppendLine("  fs.FacultyID, ")
            sql.AppendLine("  CONCAT(u.LastName, ', ', u.FirstName, ")
            sql.AppendLine("    CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial != '' THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,")
            sql.AppendLine("    CASE WHEN u.Suffix IS NOT NULL AND u.Suffix != '' THEN CONCAT(' ', u.Suffix) ELSE '' END")
            sql.AppendLine("  ) as FacultyName, ")
            sql.AppendLine("  d.DepartmentName,")
            sql.AppendLine("  fs.OverallScore,")
            sql.AppendLine("  fs.RawOverallScore,")
            sql.AppendLine("  fs.SubjectsCount,")
            sql.AppendLine("  fs.EvaluationsCount")
            sql.AppendLine("FROM faculty_scores fs")
            sql.AppendLine("INNER JOIN users u ON fs.FacultyID = u.UserID")
            sql.AppendLine("LEFT JOIN departments d ON u.DepartmentID = d.DepartmentID")
            sql.AppendLine("WHERE u.Role = 'Faculty' AND u.Status = 'Active'")

            If departmentId > 0 Then
                sql.AppendLine("  AND u.DepartmentID = @DepartmentID2")
            End If

            sql.AppendLine("ORDER BY fs.OverallScore DESC, u.LastName, u.FirstName") ' Sort by highest score first

            Using cmd As New MySqlCommand(sql.ToString(), conn)
                ' Add parameters for all the parameter placeholders
                If cycleId > 0 Then
                    cmd.Parameters.AddWithValue("@CycleID", cycleId)
                    cmd.Parameters.AddWithValue("@CycleID2", cycleId)
                    cmd.Parameters.AddWithValue("@CycleID3", cycleId)
                End If
                If departmentId > 0 Then
                    cmd.Parameters.AddWithValue("@DepartmentID", departmentId)
                    cmd.Parameters.AddWithValue("@DepartmentID2", departmentId)
                End If

                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    While reader.Read()
                        facultyList.Add(New FacultyListData With {
                    .FacultyID = If(reader("FacultyID") Is DBNull.Value, 0, Convert.ToInt32(reader("FacultyID"))),
                    .FacultyName = If(reader("FacultyName") Is DBNull.Value, "Unknown", reader("FacultyName").ToString()),
                    .DepartmentName = If(reader("DepartmentName") Is DBNull.Value, "Unknown", reader("DepartmentName").ToString()),
                    .OverallScore = If(reader("OverallScore") Is DBNull.Value, 0D, Convert.ToDecimal(reader("OverallScore"))),
                    .RawOverallScore = If(reader("RawOverallScore") Is DBNull.Value, 0D, Convert.ToDecimal(reader("RawOverallScore"))),
                    .SubjectsCount = If(reader("SubjectsCount") Is DBNull.Value, 0, Convert.ToInt32(reader("SubjectsCount"))),
                    .EvaluationsCount = If(reader("EvaluationsCount") Is DBNull.Value, 0, Convert.ToInt32(reader("EvaluationsCount")))
                })
                    End While
                End Using
            End Using

            System.Diagnostics.Debug.WriteLine($"Found {facultyList.Count} evaluated faculty members")

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetFacultyListData: " & ex.Message)
            System.Diagnostics.Debug.WriteLine("Stack Trace: " & ex.StackTrace)
        End Try

        Return facultyList
    End Function

    Private Shared Sub UpdateFacultyScores(conn As MySqlConnection, faculty As FacultyListData, cycleId As Integer, departmentId As Integer)
        Try
            ' Get faculty performance data
            Dim performance As FacultyPerformanceData = GetFacultyPerformance(conn, cycleId, departmentId, 0, faculty.FacultyID, 0)

            faculty.OverallScore = performance.OverallScore
            faculty.RawOverallScore = performance.RawOverallScore
            faculty.SubjectsCount = performance.SubjectsCount
            faculty.EvaluationsCount = performance.EvaluationsCount

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"Error updating scores for faculty {faculty.FacultyID}: {ex.Message}")
        End Try
    End Sub

    Private Shared Function GetFacultyQuestionBreakdownData(conn As MySqlConnection, cycleId As Integer, facultyId As Integer, subjectId As Integer, departmentId As Integer, courseId As Integer) As List(Of FacultyQuestionBreakdownData)
        Dim questionBreakdown As New List(Of FacultyQuestionBreakdownData)()

        Try
            ' Updated query to use 1-5 scale for question scores
            Dim sql As New StringBuilder()
            sql.AppendLine("WITH question_scores AS (")
            sql.AppendLine("  SELECT ")
            sql.AppendLine("    ed.DomainID,")
            sql.AppendLine("    ed.DomainName,")
            sql.AppendLine("    eq.QuestionID,")
            sql.AppendLine("    eq.QuestionText,")
            sql.AppendLine("    ROUND(AVG(e.Score), 2) as RawScore,") ' 1-5 scale
            sql.AppendLine("    ROUND((AVG(e.Score) / 5) * 100, 1) as PercentageScore,") ' Keep for reference
            sql.AppendLine("    COUNT(e.EvalID) as ResponseCount")
            sql.AppendLine("  FROM evaluations e")
            sql.AppendLine("  INNER JOIN evaluationquestions eq ON e.QuestionID = eq.QuestionID")
            sql.AppendLine("  INNER JOIN evaluationdomains ed ON eq.DomainID = ed.DomainID")
            sql.AppendLine("  INNER JOIN evaluationsubmissions es ON e.SubmissionID = es.SubmissionID")
            sql.AppendLine("  INNER JOIN facultyload fl ON es.LoadID = fl.LoadID")
            sql.AppendLine("  WHERE fl.IsDeleted = 0")
            sql.AppendLine("  AND fl.FacultyID = @FacultyID")
            sql.AppendLine("  AND e.Score IS NOT NULL")
            sql.AppendLine("  AND e.Score > 0")
            ' sql.AppendLine("  AND ed.IsActive = 1")
            ' sql.AppendLine("  AND eq.IsActive = 1")

            If subjectId > 0 Then sql.AppendLine("  AND fl.SubjectID = @SubjectID")
            If departmentId > 0 Then sql.AppendLine("  AND fl.DepartmentID = @DepartmentID")
            If courseId > 0 Then sql.AppendLine("  AND fl.CourseID = @CourseID")
            If cycleId > 0 Then sql.AppendLine("  AND es.CycleID = @CycleID")

            sql.AppendLine("  GROUP BY ed.DomainID, ed.DomainName, eq.QuestionID, eq.QuestionText")
            sql.AppendLine("),")
            sql.AppendLine("domain_averages AS (")
            sql.AppendLine("  SELECT")
            sql.AppendLine("    DomainID,")
            sql.AppendLine("    DomainName,")
            sql.AppendLine("    ROUND(AVG(RawScore), 2) as DomainAverageRaw") ' Domain average on 1-5 scale
            sql.AppendLine("  FROM question_scores")
            sql.AppendLine("  GROUP BY DomainID, DomainName")
            sql.AppendLine(")")
            sql.AppendLine("SELECT ")
            sql.AppendLine("  qs.DomainName,")
            sql.AppendLine("  qs.QuestionText,")
            sql.AppendLine("  qs.RawScore as AverageScore,") ' Use raw score for display
            sql.AppendLine("  qs.PercentageScore,")
            sql.AppendLine("  qs.ResponseCount,")
            sql.AppendLine("  da.DomainAverageRaw as DomainAverage")
            sql.AppendLine("FROM question_scores qs")
            sql.AppendLine("INNER JOIN domain_averages da ON qs.DomainID = da.DomainID")
            sql.AppendLine("ORDER BY qs.DomainName, qs.QuestionID")

            Using cmd As New MySqlCommand(sql.ToString(), conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyId)

                If subjectId > 0 Then cmd.Parameters.AddWithValue("@SubjectID", subjectId)
                If departmentId > 0 Then cmd.Parameters.AddWithValue("@DepartmentID", departmentId)
                If courseId > 0 Then cmd.Parameters.AddWithValue("@CourseID", courseId)
                If cycleId > 0 Then cmd.Parameters.AddWithValue("@CycleID", cycleId)

                Dim currentDomain As String = String.Empty
                Dim currentDomainData As FacultyQuestionBreakdownData = Nothing

                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    While reader.Read()
                        Dim domainName = If(reader("DomainName") Is DBNull.Value, "Unknown", reader("DomainName").ToString())
                        Dim questionText = If(reader("QuestionText") Is DBNull.Value, "Unknown", reader("QuestionText").ToString())
                        Dim averageScore = If(reader("AverageScore") Is DBNull.Value, 0D, Convert.ToDecimal(reader("AverageScore")))
                        Dim percentageScore = If(reader("PercentageScore") Is DBNull.Value, 0D, Convert.ToDecimal(reader("PercentageScore")))
                        Dim responseCount = If(reader("ResponseCount") Is DBNull.Value, 0, Convert.ToInt32(reader("ResponseCount")))
                        Dim domainAverage = If(reader("DomainAverage") Is DBNull.Value, 0D, Convert.ToDecimal(reader("DomainAverage")))

                        If domainName <> currentDomain Then
                            If currentDomainData IsNot Nothing Then
                                questionBreakdown.Add(currentDomainData)
                            End If
                            currentDomainData = New FacultyQuestionBreakdownData With {
                            .DomainName = domainName,
                            .Questions = New List(Of QuestionData)(),
                            .DomainAverage = domainAverage ' Now this is 1-5 scale
                        }
                            currentDomain = domainName
                        End If

                        currentDomainData.Questions.Add(New QuestionData With {
                        .QuestionText = questionText,
                        .AverageScore = averageScore, ' 1-5 scale
                        .PercentageScore = percentageScore,
                        .ResponseCount = responseCount
                    })
                    End While

                    If currentDomainData IsNot Nothing Then
                        questionBreakdown.Add(currentDomainData)
                    End If
                End Using
            End Using

            System.Diagnostics.Debug.WriteLine($"Found {questionBreakdown.Count} domains with question breakdown for faculty {facultyId}")

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetFacultyQuestionBreakdownData: " & ex.Message)
        End Try

        Return questionBreakdown
    End Function

    Private Shared Function GetCourseDataFromDB(conn As MySqlConnection, cycleId As Integer, departmentId As Integer) As List(Of CourseData)
        Dim courses As New List(Of CourseData)()

        Try
            Dim sql As New StringBuilder()
            sql.AppendLine("WITH course_domains AS (")
            sql.AppendLine("  SELECT ")
            sql.AppendLine("    fl.CourseID, ")
            sql.AppendLine("    ed.DomainID, ")
            sql.AppendLine("    ed.Weight, ")
            sql.AppendLine("    AVG(e.Score) as RawScore, ")
            sql.AppendLine("    (AVG(e.Score) / 5) * ed.Weight as WeightedScore ")
            sql.AppendLine("  FROM evaluations e ")
            sql.AppendLine("  INNER JOIN evaluationquestions eq ON e.QuestionID = eq.QuestionID ")
            sql.AppendLine("  INNER JOIN evaluationdomains ed ON eq.DomainID = ed.DomainID ")
            sql.AppendLine("  INNER JOIN evaluationsubmissions es ON e.SubmissionID = es.SubmissionID ")
            sql.AppendLine("  INNER JOIN facultyload fl ON es.LoadID = fl.LoadID AND fl.IsDeleted = 0 ")
            sql.AppendLine("  WHERE 1=1 ")

            ' Add cycle filter to CTE
            If cycleId > 0 Then
                sql.AppendLine("  AND es.CycleID = @CycleID ")
            End If
            If departmentId > 0 Then
                sql.AppendLine("  AND fl.DepartmentID = @DepartmentID ")
            End If

            sql.AppendLine("  GROUP BY fl.CourseID, ed.DomainID, ed.Weight ")
            sql.AppendLine("),")
            sql.AppendLine("course_totals AS (")
            sql.AppendLine("  SELECT ")
            sql.AppendLine("    CourseID, ")
            sql.AppendLine("    ROUND(SUM(WeightedScore), 1) as TotalWeightedScore, ")
            sql.AppendLine("    ROUND(AVG(RawScore), 2) as AverageRawScore ")
            sql.AppendLine("  FROM course_domains ")
            sql.AppendLine("  GROUP BY CourseID ")
            sql.AppendLine("),")
            sql.AppendLine("course_evaluations AS (")
            sql.AppendLine("  SELECT ")
            sql.AppendLine("    fl.CourseID, ")
            sql.AppendLine("    COUNT(DISTINCT es.SubmissionID) as EvaluationCount ")
            sql.AppendLine("  FROM facultyload fl ")
            sql.AppendLine("  INNER JOIN evaluationsubmissions es ON fl.LoadID = es.LoadID ")
            sql.AppendLine("  WHERE fl.IsDeleted = 0 ")
            ' Add cycle filter to evaluation counts
            If cycleId > 0 Then
                sql.AppendLine("  AND es.CycleID = @CycleID2 ")
            End If
            If departmentId > 0 Then
                sql.AppendLine("  AND fl.DepartmentID = @DepartmentID2 ")
            End If
            sql.AppendLine("  GROUP BY fl.CourseID ")
            sql.AppendLine(")")
            sql.AppendLine("SELECT ")
            sql.AppendLine("  c.CourseID, ")
            sql.AppendLine("  c.CourseName, ")
            sql.AppendLine("  COALESCE(ct.TotalWeightedScore, 0) as AverageScore, ")
            sql.AppendLine("  COALESCE(ct.AverageRawScore, 0) as RawAverage, ")
            sql.AppendLine("  COUNT(DISTINCT fl.FacultyID) as FacultyCount, ")
            sql.AppendLine("  COALESCE(ce.EvaluationCount, 0) as EvaluationCount, ")
            sql.AppendLine("  COUNT(DISTINCT fl.SubjectID) as SubjectCount, ")
            sql.AppendLine("  0 as ContributionPercent ")
            sql.AppendLine("FROM courses c ")
            sql.AppendLine("LEFT JOIN course_totals ct ON c.CourseID = ct.CourseID ")
            sql.AppendLine("LEFT JOIN course_evaluations ce ON c.CourseID = ce.CourseID ")
            sql.AppendLine("LEFT JOIN facultyload fl ON c.CourseID = fl.CourseID AND fl.IsDeleted = 0 ")
            sql.AppendLine("WHERE c.IsActive = 1 ")

            If departmentId > 0 Then
                sql.AppendLine("AND fl.DepartmentID = @DepartmentID3 ")
            End If

            sql.AppendLine("GROUP BY c.CourseID, c.CourseName, ct.TotalWeightedScore, ct.AverageRawScore, ce.EvaluationCount ")
            sql.AppendLine("ORDER BY c.CourseName")

            Using cmd As New MySqlCommand(sql.ToString(), conn)
                If departmentId > 0 Then
                    cmd.Parameters.AddWithValue("@DepartmentID", departmentId)
                    cmd.Parameters.AddWithValue("@DepartmentID2", departmentId)
                    cmd.Parameters.AddWithValue("@DepartmentID3", departmentId)
                End If
                If cycleId > 0 Then
                    cmd.Parameters.AddWithValue("@CycleID", cycleId)
                    cmd.Parameters.AddWithValue("@CycleID2", cycleId)
                End If

                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    While reader.Read()
                        courses.Add(New CourseData With {
                    .CourseID = If(reader("CourseID") Is DBNull.Value, 0, Convert.ToInt32(reader("CourseID"))),
                    .CourseName = If(reader("CourseName") Is DBNull.Value, "Unknown", reader("CourseName").ToString()),
                    .AverageScore = If(reader("AverageScore") Is DBNull.Value, 0D, Convert.ToDecimal(reader("AverageScore"))),
                    .RawAverage = If(reader("RawAverage") Is DBNull.Value, 0D, Convert.ToDecimal(reader("RawAverage"))),
                    .FacultyCount = If(reader("FacultyCount") Is DBNull.Value, 0, Convert.ToInt32(reader("FacultyCount"))),
                    .EvaluationCount = If(reader("EvaluationCount") Is DBNull.Value, 0, Convert.ToInt32(reader("EvaluationCount"))),
                    .SubjectCount = If(reader("SubjectCount") Is DBNull.Value, 0, Convert.ToInt32(reader("SubjectCount"))),
                    .ContributionPercent = 0
                })
                    End While
                End Using
            End Using

            ' Calculate contribution percentage based on filtered evaluations
            Dim totalEvals As Integer = courses.Sum(Function(c) c.EvaluationCount)
            If totalEvals > 0 Then
                For Each course In courses
                    course.ContributionPercent = Math.Round((course.EvaluationCount / totalEvals) * 100, 1)
                Next
            End If

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetCourseDataFromDB: " & ex.Message)
        End Try

        Return courses
    End Function

    Private Shared Function GetCourseDomainScoresFromDB(conn As MySqlConnection, cycleId As Integer, departmentId As Integer, courseId As Integer) As List(Of DomainScoreData)
        Dim domains As New List(Of DomainScoreData)()

        Try
            Dim sql As New StringBuilder()
            sql.AppendLine("SELECT ")
            sql.AppendLine("  ed.DomainID, ")
            sql.AppendLine("  ed.DomainName, ")
            sql.AppendLine("  COALESCE(ROUND((AVG(e.Score) / 5) * ed.Weight, 1), 0) as DomainScore, ")
            sql.AppendLine("  COALESCE(ROUND(AVG(e.Score), 2), 0) as RawScore, ")
            sql.AppendLine("  ed.Weight, ")
            sql.AppendLine("  COUNT(e.EvalID) as EvaluationCount ")
            sql.AppendLine("FROM evaluationdomains ed ")
            sql.AppendLine("LEFT JOIN evaluationquestions eq ON ed.DomainID = eq.DomainID AND eq.IsActive = 1 ")
            sql.AppendLine("LEFT JOIN evaluations e ON eq.QuestionID = e.QuestionID ")
            sql.AppendLine("LEFT JOIN evaluationsubmissions es ON e.SubmissionID = es.SubmissionID ")
            sql.AppendLine("LEFT JOIN facultyload fl ON es.LoadID = fl.LoadID AND fl.IsDeleted = 0 ")
            'sql.AppendLine("WHERE")

            If departmentId > 0 Then
                sql.AppendLine("WHERE fl.DepartmentID = @DepartmentID ")
            End If

            If courseId > 0 Then
                sql.AppendLine("AND fl.CourseID = @CourseID ")
            Else
                sql.AppendLine("AND fl.CourseID IS NOT NULL ")
            End If

            ' Add cycle filter
            If cycleId > 0 Then
                sql.AppendLine("AND es.CycleID = @CycleID ")
            End If

            sql.AppendLine("GROUP BY ed.DomainID, ed.DomainName, ed.Weight ")
            sql.AppendLine("HAVING COUNT(e.EvalID) > 0 ") ' Only include domains with evaluations
            sql.AppendLine("ORDER BY ed.DomainID")

            Using cmd As New MySqlCommand(sql.ToString(), conn)
                If departmentId > 0 Then
                    cmd.Parameters.AddWithValue("@DepartmentID", departmentId)
                End If

                If courseId > 0 Then
                    cmd.Parameters.AddWithValue("@CourseID", courseId)
                End If

                If cycleId > 0 Then
                    cmd.Parameters.AddWithValue("@CycleID", cycleId)
                End If

                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    While reader.Read()
                        Dim domainId = If(reader("DomainID") Is DBNull.Value, 0, Convert.ToInt32(reader("DomainID")))
                        Dim domainName = If(reader("DomainName") Is DBNull.Value, "Unknown", reader("DomainName").ToString())
                        Dim domainScore = If(reader("DomainScore") Is DBNull.Value, 0D, Convert.ToDecimal(reader("DomainScore")))
                        Dim rawScore = If(reader("RawScore") Is DBNull.Value, 0D, Convert.ToDecimal(reader("RawScore")))
                        Dim weight = If(reader("Weight") Is DBNull.Value, 0, Convert.ToInt32(reader("Weight")))

                        domains.Add(New DomainScoreData With {
                    .DomainName = domainName,
                    .Score = domainScore,
                    .RawScore = rawScore,
                    .Weight = weight
                })
                    End While
                End Using
            End Using

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"ERROR in GetCourseDomainScoresFromDB: {ex.Message}")
        End Try

        Return domains
    End Function
    Private Function GetLatestActiveCycleID() As Integer
        Dim latestCycleId As Integer = 0
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                Dim sql As String = "SELECT CycleID FROM evaluationcycles WHERE Status = 'Active' ORDER BY StartDate DESC LIMIT 1"

                Using cmd As New MySqlCommand(sql, conn)
                    Dim result = cmd.ExecuteScalar()
                    If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                        latestCycleId = Convert.ToInt32(result)
                    Else
                        ' If no active cycle, get the most recent cycle by date
                        sql = "SELECT CycleID FROM evaluationcycles ORDER BY StartDate DESC LIMIT 1"
                        Using cmd2 As New MySqlCommand(sql, conn)
                            result = cmd2.ExecuteScalar()
                            If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                                latestCycleId = Convert.ToInt32(result)
                            End If
                        End Using
                    End If
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error getting latest cycle: " & ex.Message)
        End Try
        Return latestCycleId
    End Function
    Private Sub SetDefaultCycle()
        Dim latestCycleId As Integer = GetLatestActiveCycleID()

        If latestCycleId > 0 Then
            Try
                Using conn As New MySqlConnection(ConnString)
                    conn.Open()
                    Dim sql As String = "SELECT CycleID, CycleName FROM evaluationcycles WHERE CycleID = @CycleID"

                    Using cmd As New MySqlCommand(sql, conn)
                        cmd.Parameters.AddWithValue("@CycleID", latestCycleId)
                        Using reader As MySqlDataReader = cmd.ExecuteReader()
                            If reader.Read() Then
                                Dim cycleName As String = If(reader("CycleName") Is DBNull.Value, "Current Cycle", reader("CycleName").ToString())

                                ' Set all cycle hidden fields and text boxes
                                hfInstitutionCycleID.Value = latestCycleId.ToString()
                                hfDepartmentCycleID.Value = latestCycleId.ToString()
                                hfFacultyCycleID.Value = latestCycleId.ToString()

                                txtInstitutionCycle.Text = cycleName
                                txtDepartmentCycle.Text = cycleName
                                txtFacultyCycle.Text = cycleName
                            End If
                        End Using
                    End Using
                End Using
            Catch ex As Exception
                System.Diagnostics.Debug.WriteLine("Error setting default cycle: " & ex.Message)
            End Try
        End If
    End Sub

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetDefaultCycle() As String
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        Dim result As New With {
        .CycleID = 0,
        .CycleName = "No Active Cycle"
    }

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()
                Dim sql As String = "SELECT CycleID, CycleName FROM evaluationcycles WHERE Status = 'Active' ORDER BY StartDate DESC LIMIT 1"

                Using cmd As New MySqlCommand(sql, conn)
                    Using reader As MySqlDataReader = cmd.ExecuteReader()
                        If reader.Read() Then
                            result.CycleID = If(reader("CycleID") Is DBNull.Value, 0, Convert.ToInt32(reader("CycleID")))
                            result.CycleName = If(reader("CycleName") Is DBNull.Value, "Current Cycle", reader("CycleName").ToString())
                        Else
                            ' Fallback to most recent cycle
                            sql = "SELECT CycleID, CycleName FROM evaluationcycles ORDER BY StartDate DESC LIMIT 1"
                            Using cmd2 As New MySqlCommand(sql, conn)
                                Using reader2 As MySqlDataReader = cmd2.ExecuteReader()
                                    If reader2.Read() Then
                                        result.CycleID = If(reader2("CycleID") Is DBNull.Value, 0, Convert.ToInt32(reader2("CycleID")))
                                        result.CycleName = If(reader2("CycleName") Is DBNull.Value, "Current Cycle", reader2("CycleName").ToString())
                                    End If
                                End Using
                            End Using
                        End If
                    End Using
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetDefaultCycle: " & ex.Message)
        End Try

        Dim serializer As New JavaScriptSerializer()
        Return serializer.Serialize(result)
    End Function
End Class

