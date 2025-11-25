Imports System.Data
Imports System.Configuration
Imports MySql.Data.MySqlClient
Imports System.Web.Services
Imports System.Web.Script.Services
Imports System.Web.Script.Serialization
Imports System.Collections.Generic
Imports System.Web

Public Class FacultyDashboard
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsUserAuthorized() Then
            Response.Redirect("~/Login.aspx")
            Return
        End If

        If Not IsPostBack Then

            LoadFacultyInfo()
        End If
    End Sub

    Private Function IsUserAuthorized() As Boolean
        Try
            If Session("UserID") Is Nothing Then Return False
            If Session("Role") Is Nothing Then Return False
            Dim userRole As String = Session("Role").ToString()
            Return userRole = "Faculty"
        Catch ex As Exception
            Return False
        End Try
    End Function

    Private Sub LoadFacultyInfo()
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim sql As String = "
        SELECT 
            CONCAT(u.FirstName, ' ', 
                   CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial <> '' THEN CONCAT(u.MiddleInitial, '. ') ELSE '' END,
                   u.LastName,
                   CASE WHEN u.Suffix IS NOT NULL AND u.Suffix <> '' THEN CONCAT(' ', u.Suffix) ELSE '' END
            ) AS FullName, 
            d.DepartmentName
        FROM Users u
        LEFT JOIN Departments d ON u.DepartmentID = d.DepartmentID
        WHERE u.UserID=@uid AND u.Role='Faculty' LIMIT 1"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@uid", Session("UserID"))
                Using rdr As MySqlDataReader = cmd.ExecuteReader()
                    If rdr.Read() Then
                        lblFacultyName.Text = GetSafeString(rdr, "FullName")
                        lblDepartment.Text = GetSafeString(rdr, "DepartmentName", "N/A")
                    End If
                End Using
            End Using
        End Using
    End Sub

    ' Add these helper methods if they don't exist
    Private Function GetSafeString(rdr As MySqlDataReader, columnName As String, Optional defaultValue As String = "") As String
        Try
            Dim ordinal As Integer = rdr.GetOrdinal(columnName)
            If rdr.IsDBNull(ordinal) Then
                Return defaultValue
            Else
                Return rdr(columnName).ToString()
            End If
        Catch ex As Exception
            Return defaultValue
        End Try
    End Function



    <WebMethod(EnableSession:=True)>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetDashboardData() As String
        Dim result As New WebMethodResult(Of DashboardData)()
        Try
            ' Get faculty ID from session
            Dim context As HttpContext = HttpContext.Current
            If context.Session("UserID") Is Nothing Then
                result.Success = False
                result.Message = "Session expired. Please login again."
                Return New JavaScriptSerializer().Serialize(result)
            End If

            Dim facultyID As Integer = Convert.ToInt32(context.Session("UserID"))
            Dim dashboardData As New DashboardData()
            Dim connStr As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

            Using conn As New MySqlConnection(connStr)
                conn.Open()

                ' Get current active cycle
                Dim currentCycle As CycleInfo = GetCurrentActiveCycle(conn)
                If currentCycle Is Nothing Then
                    result.Success = False
                    result.Message = "No active evaluation cycle found"
                    Return New JavaScriptSerializer().Serialize(result)
                End If

                ' Get faculty classes for current term
                dashboardData.Classes = GetFacultyClasses(conn, facultyID, currentCycle.Term)

                ' Calculate statistics
                dashboardData.Statistics = CalculateStatistics(conn, facultyID, currentCycle.CycleID, dashboardData.Classes)

                result.Success = True
                result.Data = dashboardData
            End Using

        Catch ex As Exception
            result.Success = False
            result.Message = "Error loading dashboard data: " & ex.Message
        End Try

        Return New JavaScriptSerializer().Serialize(result)
    End Function

    Private Shared Function GetCurrentActiveCycle(conn As MySqlConnection) As CycleInfo
        Try
            Dim sql As String = "SELECT CycleID, Term, CycleName FROM evaluationcycles WHERE Status = 'Active' AND IsActive = 1 LIMIT 1"
            Using cmd As New MySqlCommand(sql, conn)
                Using rdr As MySqlDataReader = cmd.ExecuteReader()
                    If rdr.Read() Then
                        Return New CycleInfo() With {
                            .CycleID = SafeGetInt(rdr, "CycleID"),
                            .Term = SafeGetString(rdr, "Term"),
                            .CycleName = SafeGetString(rdr, "CycleName")
                        }
                    End If
                End Using
            End Using
        Catch ex As Exception
            Return Nothing
        End Try
        Return Nothing
    End Function

    Private Shared Function GetFacultyClasses(conn As MySqlConnection, facultyID As Integer, currentTerm As String) As List(Of ClassInfo)
        Dim classes As New List(Of ClassInfo)()

        Try
            Dim sql As String = "
            SELECT 
                fl.LoadID, 
                s.SubjectCode, 
                s.SubjectName, 
                c.YearLevel, 
                c.Section, 
                co.CourseName,
                fl.Term,
                (SELECT COUNT(*) FROM students WHERE ClassID = c.ClassID AND Status = 'Active') AS StudentCount,
                CASE WHEN EXISTS (
                    SELECT 1 FROM gradesubmissions gs 
                    WHERE gs.LoadID = fl.LoadID 
                    AND gs.CycleID = (SELECT CycleID FROM evaluationcycles WHERE Status = 'Active')
                ) THEN 1 ELSE 0 END AS GradeSubmitted
            FROM facultyload fl
            INNER JOIN subjects s ON fl.SubjectID = s.SubjectID
            INNER JOIN classes c ON fl.ClassID = c.ClassID
            INNER JOIN courses co ON fl.CourseID = co.CourseID
            WHERE fl.FacultyID = @FacultyID 
                AND fl.Term = @CurrentTerm 
                AND fl.IsDeleted = 0
                AND s.IsActive = 1
                AND c.IsActive = 1
                AND co.IsActive = 1
            ORDER BY s.SubjectCode, c.YearLevel, c.Section"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@CurrentTerm", currentTerm)

                Using rdr As MySqlDataReader = cmd.ExecuteReader()
                    While rdr.Read()
                        classes.Add(New ClassInfo() With {
                            .LoadID = SafeGetInt(rdr, "LoadID"),
                            .SubjectCode = SafeGetString(rdr, "SubjectCode"),
                            .SubjectName = SafeGetString(rdr, "SubjectName"),
                            .YearLevel = SafeGetString(rdr, "YearLevel"),
                            .Section = SafeGetString(rdr, "Section"),
                            .CourseName = SafeGetString(rdr, "CourseName"),
                            .Term = SafeGetString(rdr, "Term"),
                            .StudentCount = SafeGetInt(rdr, "StudentCount"),
                            .GradeSubmitted = SafeGetInt(rdr, "GradeSubmitted") = 1
                        })
                    End While
                End Using
            End Using

        Catch ex As Exception
            ' Log error but return empty list
            System.Diagnostics.Debug.WriteLine("Error getting faculty classes: " & ex.Message)
        End Try

        Return classes
    End Function

    Private Shared Function CalculateStatistics(conn As MySqlConnection, facultyID As Integer, cycleID As Integer, classes As List(Of ClassInfo)) As DashboardStatistics
        Dim stats As New DashboardStatistics()

        Try
            ' Total classes
            stats.TotalClasses = If(classes?.Count, 0)

            ' Submitted grades count
            stats.SubmittedGrades = If(classes?.Where(Function(c) c.GradeSubmitted).Count(), 0)

            ' Pending grades count
            stats.PendingGrades = stats.TotalClasses - stats.SubmittedGrades

            ' Evaluated classes count (classes with at least one evaluation submission)
            stats.EvaluatedClasses = GetEvaluatedClassesCount(conn, facultyID, cycleID)

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error calculating statistics: " & ex.Message)
        End Try

        Return stats
    End Function

    Private Shared Function GetEvaluatedClassesCount(conn As MySqlConnection, facultyID As Integer, cycleID As Integer) As Integer
        Try
            Dim sql As String = "
            SELECT COUNT(DISTINCT es.LoadID) as EvaluatedCount
            FROM evaluationsubmissions es
            INNER JOIN facultyload fl ON es.LoadID = fl.LoadID
            WHERE fl.FacultyID = @FacultyID 
                AND es.CycleID = @CycleID"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@CycleID", cycleID)

                Dim result = cmd.ExecuteScalar()
                Return If(result Is Nothing OrElse Convert.IsDBNull(result), 0, Convert.ToInt32(result))
            End Using

        Catch ex As Exception
            Return 0
        End Try
    End Function

    ' Utility methods
    Private Shared Function SafeGetString(rdr As MySqlDataReader, fieldName As String) As String
        Try
            Dim ordinal As Integer = rdr.GetOrdinal(fieldName)
            Return If(rdr.IsDBNull(ordinal), "", rdr.GetString(ordinal))
        Catch
            Return ""
        End Try
    End Function

    Private Shared Function SafeGetInt(rdr As MySqlDataReader, fieldName As String) As Integer
        Try
            Dim ordinal As Integer = rdr.GetOrdinal(fieldName)
            Return If(rdr.IsDBNull(ordinal), 0, rdr.GetInt32(ordinal))
        Catch
            Return 0
        End Try
    End Function

    Protected Sub btnLogout_Click(sender As Object, e As EventArgs)
        Session.Clear()
        Session.Abandon()
        Response.Redirect("~/Login.aspx")
    End Sub

    ' Data Classes
    Public Class DashboardData
        Public Property Statistics As DashboardStatistics
        Public Property Classes As List(Of ClassInfo)
    End Class

    Public Class DashboardStatistics
        Public Property TotalClasses As Integer
        Public Property SubmittedGrades As Integer
        Public Property PendingGrades As Integer
        Public Property EvaluatedClasses As Integer
    End Class

    Public Class ClassInfo
        Public Property LoadID As Integer
        Public Property SubjectCode As String
        Public Property SubjectName As String
        Public Property YearLevel As String
        Public Property Section As String
        Public Property CourseName As String
        Public Property Term As String
        Public Property StudentCount As Integer
        Public Property GradeSubmitted As Boolean
        Public Property EvaluationCount As Integer
    End Class

    Public Class CycleInfo
        Public Property CycleID As Integer
        Public Property Term As String
        Public Property CycleName As String
    End Class

    Public Class WebMethodResult
        Public Property Success As Boolean
        Public Property Message As String
    End Class

    Public Class WebMethodResult(Of T)
        Inherits WebMethodResult
        Public Property Data As T
    End Class
End Class


