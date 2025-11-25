Imports MySql.Data.MySqlClient
Imports System.Configuration

Public Class StudentDashboard
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        ' 🔒 Security check: Only allow Student role
        If Session("Role") Is Nothing OrElse Not Session("Role").ToString().Equals("Student", StringComparison.OrdinalIgnoreCase) Then
            Response.Redirect("Login.aspx", False)
            Context.ApplicationInstance.CompleteRequest()
            Return
        End If

        If Not IsPostBack Then
            LoadStudentInfo()
            LoadEvaluationStats()
            CheckStudentType() ' Add this line
        End If
    End Sub

    Private Sub LoadStudentInfo()
        Try
            lblStudentName.Text = If(Session("FullName") IsNot Nothing, Session("FullName").ToString(), "Student")

            Dim deptName As String = "N/A"
            Dim courseName As String = "N/A"
            Dim className As String = "N/A"

            Dim deptID As String = If(Session("DepartmentID") IsNot Nothing, Session("DepartmentID").ToString(), "")
            Dim courseID As String = If(Session("CourseID") IsNot Nothing, Session("CourseID").ToString(), "")
            Dim classID As String = If(Session("ClassID") IsNot Nothing, Session("ClassID").ToString(), "")

            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                ' Department
                If deptID <> "" Then
                    Using cmd As New MySqlCommand("SELECT DepartmentName FROM Departments WHERE DepartmentID=@DeptID LIMIT 1", conn)
                        cmd.Parameters.AddWithValue("@DeptID", deptID)
                        Dim result = cmd.ExecuteScalar()
                        If result IsNot Nothing Then deptName = result.ToString()
                    End Using
                End If

                ' Course
                If courseID <> "" Then
                    Using cmd As New MySqlCommand("SELECT CourseName FROM Courses WHERE CourseID=@CourseID LIMIT 1", conn)
                        cmd.Parameters.AddWithValue("@CourseID", courseID)
                        Dim result = cmd.ExecuteScalar()
                        If result IsNot Nothing Then courseName = result.ToString()
                    End Using
                End If

                ' Class (YearLevel + Section)
                If classID <> "" Then
                    Using cmd As New MySqlCommand("SELECT CONCAT(YearLevel, ' - ', Section) AS ClassName FROM Classes WHERE ClassID=@ClassID LIMIT 1", conn)
                        cmd.Parameters.AddWithValue("@ClassID", classID)
                        Dim result = cmd.ExecuteScalar()
                        If result IsNot Nothing Then className = result.ToString()
                    End Using
                End If
            End Using

            lblDepartment.Text = deptName
            lblCourse.Text = courseName
            lblClass.Text = className

        Catch ex As Exception
            lblDepartment.Text = "N/A"
            lblCourse.Text = "N/A"
            lblClass.Text = "N/A"
        End Try
    End Sub

    Private Sub LoadEvaluationStats()
        Try
            Dim studentID As Integer = Convert.ToInt32(Session("UserID"))
            Dim classID As String = If(Session("ClassID") IsNot Nothing, Session("ClassID").ToString(), "")
            Dim courseID As String = If(Session("CourseID") IsNot Nothing, Session("CourseID").ToString(), "")
            Dim studentType As String = "Regular"

            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                ' Get student type first
                Using cmd As New MySqlCommand("SELECT StudentType FROM students WHERE StudentID = @StudentID", conn)
                    cmd.Parameters.AddWithValue("@StudentID", studentID)
                    Dim result = cmd.ExecuteScalar()
                    If result IsNot Nothing Then
                        studentType = result.ToString()
                    End If
                End Using

                ' Get active cycle with term information
                Dim activeCycleID As Integer = 0
                Dim activeCycleTerm As String = ""
                Using cmd As New MySqlCommand("SELECT CycleID, Term FROM evaluationcycles WHERE Status = 'Active' LIMIT 1", conn)
                    Using reader = cmd.ExecuteReader()
                        If reader.Read() Then
                            activeCycleID = Convert.ToInt32(reader("CycleID"))
                            activeCycleTerm = reader("Term").ToString()
                        Else
                            ' No active cycle
                            lblPendingEvaluations.Text = "0"
                            lblCompletedEvaluations.Text = "0"
                            Return
                        End If
                    End Using
                End Using

                ' Get completed evaluations count for this student in active cycle
                Dim completedCount As Integer = 0
                Using cmd As New MySqlCommand("
                SELECT COUNT(DISTINCT es.LoadID) 
                FROM evaluationsubmissions es
                INNER JOIN facultyload fl ON es.LoadID = fl.LoadID
                WHERE es.StudentID = @StudentID 
                AND es.CycleID = @CycleID
                AND fl.Term = @Term", conn)
                    cmd.Parameters.AddWithValue("@StudentID", studentID)
                    cmd.Parameters.AddWithValue("@CycleID", activeCycleID)
                    cmd.Parameters.AddWithValue("@Term", activeCycleTerm)
                    completedCount = Convert.ToInt32(cmd.ExecuteScalar())
                End Using

                ' Get total pending evaluations - DIFFERENT QUERY BASED ON STUDENT TYPE
                Dim pendingCount As Integer = 0

                If studentType = "Regular" Then
                    ' For regular students: count faculty loads for their class and course IN THE SAME TERM as active cycle
                    Using cmd As New MySqlCommand("
                    SELECT COUNT(*) 
                    FROM facultyload fl
                    WHERE fl.ClassID = @ClassID 
                    AND fl.CourseID = @CourseID
                    AND fl.Term = @Term  -- CRITICAL: Only subjects in the same term as active cycle
                    AND fl.IsDeleted = 0
                    AND NOT EXISTS (
                        SELECT 1 FROM evaluationsubmissions es 
                        WHERE es.LoadID = fl.LoadID 
                        AND es.StudentID = @StudentID 
                        AND es.CycleID = @CycleID
                    )", conn)
                        cmd.Parameters.AddWithValue("@ClassID", classID)
                        cmd.Parameters.AddWithValue("@CourseID", courseID)
                        cmd.Parameters.AddWithValue("@StudentID", studentID)
                        cmd.Parameters.AddWithValue("@Term", activeCycleTerm)
                        cmd.Parameters.AddWithValue("@CycleID", activeCycleID)
                        pendingCount = Convert.ToInt32(cmd.ExecuteScalar())
                    End Using
                Else
                    ' For irregular students: count approved irregular enrollments for active cycle
                    ' AND ensure the faculty load is in the same term as active cycle
                    Using cmd As New MySqlCommand("
                    SELECT COUNT(*) 
                    FROM irregular_student_enrollments ise
                    INNER JOIN facultyload fl ON ise.LoadID = fl.LoadID
                    WHERE ise.StudentID = @StudentID 
                    AND ise.CycleID = @CycleID
                    AND ise.IsApproved = 1
                    AND fl.Term = @Term  -- CRITICAL: Only subjects in the same term as active cycle
                    AND NOT EXISTS (
                        SELECT 1 FROM evaluationsubmissions es 
                        WHERE es.LoadID = ise.LoadID 
                        AND es.StudentID = @StudentID 
                        AND es.CycleID = @CycleID
                    )", conn)
                        cmd.Parameters.AddWithValue("@StudentID", studentID)
                        cmd.Parameters.AddWithValue("@CycleID", activeCycleID)
                        cmd.Parameters.AddWithValue("@Term", activeCycleTerm)
                        pendingCount = Convert.ToInt32(cmd.ExecuteScalar())
                    End Using
                End If

                lblPendingEvaluations.Text = pendingCount.ToString()
                lblCompletedEvaluations.Text = completedCount.ToString()

            End Using

        Catch ex As Exception
            ' Log error and set default values
            System.Diagnostics.Debug.WriteLine("Error loading evaluation stats: " & ex.Message)
            lblPendingEvaluations.Text = "0"
            lblCompletedEvaluations.Text = "0"
        End Try
    End Sub

    Private Sub CheckStudentType()
        Try
            Dim studentID As Integer = Convert.ToInt32(Session("UserID"))

            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                ' Check if student is irregular
                Using cmd As New MySqlCommand("SELECT StudentType FROM students WHERE StudentID = @StudentID", conn)
                    cmd.Parameters.AddWithValue("@StudentID", studentID)
                    Dim studentType As String = cmd.ExecuteScalar()?.ToString()

                    ' Make the irregular enrollment button visible only for irregular students
                    If studentType = "Irregular" Then
                        IrregularEnrollmentCard.Visible = True
                    Else
                        IrregularEnrollmentCard.Visible = False
                    End If
                End Using
            End Using

        Catch ex As Exception
            ' Hide the button if there's an error
            IrregularEnrollmentCard.Visible = False
        End Try
    End Sub
    Protected Sub btnChangePassword_Click(sender As Object, e As EventArgs)
        Response.Redirect("~/ChangePassword.aspx")
    End Sub

End Class

