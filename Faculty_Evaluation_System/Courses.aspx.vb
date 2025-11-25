Imports MySql.Data.MySqlClient
Imports System.Configuration

Public Class Courses
    Inherits System.Web.UI.Page

    ' Connection String
    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    ' Page Load
    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            ' Ensure HR role
            If Session("Role") Is Nothing OrElse Session("Role").ToString() <> "Admin" Then
                Response.Redirect("Login.aspx")
            End If

            lblWelcome.Text = Session("FullName")
            LoadDepartments()
            LoadCourses()
            UpdateSidebarBadges()
        End If
    End Sub

    ' Load Departments for dropdown
    Private Sub LoadDepartments()
        Using conn As New MySqlConnection(ConnString)
            Dim cmd As New MySqlCommand("SELECT DepartmentID, DepartmentName FROM Departments WHERE IsActive=1", conn)
            Dim da As New MySqlDataAdapter(cmd)
            Dim dt As New DataTable()
            da.Fill(dt)

            ddlDepartments.DataSource = dt
            ddlDepartments.DataTextField = "DepartmentName"
            ddlDepartments.DataValueField = "DepartmentID"
            ddlDepartments.DataBind()
            ddlDepartments.Items.Insert(0, New ListItem("Select Department", ""))
        End Using
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
    ' Load Courses grid
    Private Sub LoadCourses()
        Using conn As New MySqlConnection(ConnString)
            Dim cmd As New MySqlCommand("
        SELECT c.CourseID, c.CourseName, c.DepartmentID, d.DepartmentName, c.YearLevels
        FROM Courses c
        INNER JOIN Departments d ON c.DepartmentID = d.DepartmentID
        WHERE c.IsActive = 1
        ORDER BY c.CourseName ASC", conn)
            Dim da As New MySqlDataAdapter(cmd)
            Dim dt As New DataTable()
            da.Fill(dt)

            gvCourses.DataSource = dt
            gvCourses.DataBind()
        End Using
    End Sub


    ' Add new course with duplicate check
    Protected Sub btnAddCourse_Click(sender As Object, e As EventArgs)
        If txtCourseName.Text.Trim() = "" Or ddlDepartments.SelectedValue = "" Then
            lblMessage.Text = "⚠ Please enter a course name and select a department."
            lblMessage.CssClass = "alert alert-danger d-block"
            Return
        End If

        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                ' Check if course already exists (active or inactive)
                Dim checkSql As String = "SELECT CourseID, IsActive 
                                  FROM Courses 
                                  WHERE CourseName=@CourseName AND DepartmentID=@DeptID LIMIT 1"
                Using checkCmd As New MySqlCommand(checkSql, conn)
                    checkCmd.Parameters.AddWithValue("@CourseName", txtCourseName.Text.Trim())
                    checkCmd.Parameters.AddWithValue("@DeptID", ddlDepartments.SelectedValue)

                    Using rdr As MySqlDataReader = checkCmd.ExecuteReader()
                        If rdr.Read() Then
                            Dim courseID As Integer = rdr("CourseID")
                            Dim isActive As Boolean = Convert.ToBoolean(rdr("IsActive"))

                            If isActive Then
                                lblMessage.Text = "⚠ A course with the same name already exists in this department."
                                lblMessage.CssClass = "alert alert-warning d-block"
                                Return
                            Else
                                ' Reactivate instead of insert
                                rdr.Close()
                                Using cmdReactivate As New MySqlCommand("UPDATE Courses SET IsActive=1, YearLevels=@YearLevels WHERE CourseID=@ID", conn)
                                    cmdReactivate.Parameters.AddWithValue("@ID", courseID)
                                    cmdReactivate.Parameters.AddWithValue("@YearLevels", ddlYearLevels.SelectedValue)
                                    cmdReactivate.ExecuteNonQuery()
                                End Using
                                lblMessage.Text = "✅ Course reactivated successfully!"
                                lblMessage.CssClass = "alert alert-success d-block"
                                txtCourseName.Text = ""
                                ddlDepartments.SelectedIndex = 0
                                ddlYearLevels.SelectedValue = "4"
                                LoadCourses()
                                Return
                            End If
                        End If
                    End Using
                End Using

                ' Insert if not found
                Dim insertSql As String = "INSERT INTO Courses (CourseName, DepartmentID, YearLevels, IsActive) VALUES (@CourseName, @DeptID, @YearLevels, 1)"
                Using cmd As New MySqlCommand(insertSql, conn)
                    cmd.Parameters.AddWithValue("@CourseName", txtCourseName.Text.Trim())
                    cmd.Parameters.AddWithValue("@DeptID", ddlDepartments.SelectedValue)
                    cmd.Parameters.AddWithValue("@YearLevels", ddlYearLevels.SelectedValue)
                    cmd.ExecuteNonQuery()
                End Using
            End Using

            lblMessage.Text = "✅ Course added successfully!"
            lblMessage.CssClass = "alert alert-success d-block"
            txtCourseName.Text = ""
            ddlDepartments.SelectedIndex = 0
            ddlYearLevels.SelectedValue = "4"
            LoadCourses()

        Catch ex As Exception
            lblMessage.Text = "⚠ Error: " & ex.Message
            lblMessage.CssClass = "alert alert-danger d-block"
        End Try
    End Sub


    ' GridView Events
    Protected Sub gvCourses_PageIndexChanging(sender As Object, e As GridViewPageEventArgs)
        gvCourses.PageIndex = e.NewPageIndex
        LoadCourses()
    End Sub

    Protected Sub gvCourses_RowEditing(sender As Object, e As GridViewEditEventArgs)
        gvCourses.EditIndex = e.NewEditIndex
        LoadCourses()
    End Sub

    Protected Sub gvCourses_RowCancelingEdit(sender As Object, e As GridViewCancelEditEventArgs)
        gvCourses.EditIndex = -1
        LoadCourses()
    End Sub

    ' Update course with duplicate check
    Protected Sub gvCourses_RowUpdating(sender As Object, e As GridViewUpdateEventArgs)
        Dim CourseID As Integer = Convert.ToInt32(gvCourses.DataKeys(e.RowIndex).Value)
        Dim row As GridViewRow = gvCourses.Rows(e.RowIndex)

        Dim txtEditCourseName As TextBox = CType(row.FindControl("txtEditCourseName"), TextBox)
        Dim ddlEditDepartments As DropDownList = CType(row.FindControl("ddlEditDepartments"), DropDownList)
        Dim ddlEditYearLevels As DropDownList = CType(row.FindControl("ddlEditYearLevels"), DropDownList)

        If txtEditCourseName Is Nothing Or ddlEditDepartments Is Nothing Or ddlEditYearLevels Is Nothing Then
            lblMessage.Text = "⚠ Unable to find edit controls."
            lblMessage.CssClass = "alert alert-danger d-block"
            Return
        End If

        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                ' Check for duplicate course in the same department (excluding current course)
                Dim checkSql As String = "SELECT COUNT(*) FROM Courses WHERE CourseName = @CourseName AND DepartmentID = @DeptID AND CourseID != @CourseID AND IsActive=1"
                Using checkCmd As New MySqlCommand(checkSql, conn)
                    checkCmd.Parameters.AddWithValue("@CourseName", txtEditCourseName.Text.Trim())
                    checkCmd.Parameters.AddWithValue("@DeptID", ddlEditDepartments.SelectedValue)
                    checkCmd.Parameters.AddWithValue("@CourseID", CourseID)

                    Dim existingCount As Integer = Convert.ToInt32(checkCmd.ExecuteScalar())

                    If existingCount > 0 Then
                        lblMessage.Text = "⚠ A course with the same name already exists in this department."
                        lblMessage.CssClass = "alert alert-warning d-block"
                        gvCourses.EditIndex = -1
                        LoadCourses()
                        Return
                    End If
                End Using

                ' If no duplicate, proceed with update
                Dim updateSql As String = "UPDATE Courses SET CourseName=@CourseName, DepartmentID=@DeptID, YearLevels=@YearLevels WHERE CourseID=@CourseID"
                Using cmd As New MySqlCommand(updateSql, conn)
                    cmd.Parameters.AddWithValue("@CourseName", txtEditCourseName.Text.Trim())
                    cmd.Parameters.AddWithValue("@DeptID", ddlEditDepartments.SelectedValue)
                    cmd.Parameters.AddWithValue("@YearLevels", ddlEditYearLevels.SelectedValue)
                    cmd.Parameters.AddWithValue("@CourseID", CourseID)
                    cmd.ExecuteNonQuery()
                End Using
            End Using

            gvCourses.EditIndex = -1
            lblMessage.Text = "✅ Course updated successfully!"
            lblMessage.CssClass = "alert alert-success d-block"
            LoadCourses()

        Catch ex As Exception
            lblMessage.Text = "⚠ Error: " & ex.Message
            lblMessage.CssClass = "alert alert-danger d-block"
        End Try
    End Sub

    Protected Sub gvCourses_RowDeleting(sender As Object, e As GridViewDeleteEventArgs)
        Dim CourseID As Integer = Convert.ToInt32(gvCourses.DataKeys(e.RowIndex).Value)

        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                ' 🔍 Check for classes under this course
                Dim checkClassesSql As String = "SELECT COUNT(*) FROM Classes WHERE CourseID = @CourseID AND IsActive=1"
                Using checkCmd As New MySqlCommand(checkClassesSql, conn)
                    checkCmd.Parameters.AddWithValue("@CourseID", CourseID)
                    Dim classCount As Integer = Convert.ToInt32(checkCmd.ExecuteScalar())

                    If classCount > 0 Then
                        lblMessage.Text = "⚠ Cannot delete course. There are active classes linked to this course."
                        lblMessage.CssClass = "alert alert-warning d-block"
                        Return
                    End If
                End Using

                ' 🔍 Check for faculty load under this course
                Dim checkFacultyLoadSql As String = "SELECT COUNT(*) FROM FacultyLoad WHERE CourseID = @CourseID"
                Using checkCmd As New MySqlCommand(checkFacultyLoadSql, conn)
                    checkCmd.Parameters.AddWithValue("@CourseID", CourseID)
                    Dim facultyLoadCount As Integer = Convert.ToInt32(checkCmd.ExecuteScalar())

                    If facultyLoadCount > 0 Then
                        lblMessage.Text = "⚠ Cannot delete course. It is assigned to faculty members."
                        lblMessage.CssClass = "alert alert-warning d-block"
                        Return
                    End If
                End Using

                ' ✅ Soft delete instead of permanent delete
                Dim deactivateSql As String = "UPDATE Courses SET IsActive=0 WHERE CourseID=@CourseID"
                Using cmd As New MySqlCommand(deactivateSql, conn)
                    cmd.Parameters.AddWithValue("@CourseID", CourseID)
                    cmd.ExecuteNonQuery()
                End Using
            End Using

            lblMessage.Text = "✅ Course deactivated successfully!"
            lblMessage.CssClass = "alert alert-success d-block"
            LoadCourses()

        Catch ex As Exception
            lblMessage.Text = "⚠ Error: " & ex.Message
            lblMessage.CssClass = "alert alert-danger d-block"
        End Try
    End Sub


    ' Populate department dropdown in edit mode
    Protected Sub gvCourses_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvCourses.RowDataBound
        If e.Row.RowType = DataControlRowType.DataRow Then
            ' Style delete button with confirmation
            For Each control As Control In e.Row.Cells(e.Row.Cells.Count - 1).Controls
                If TypeOf control Is LinkButton Then
                    Dim lb As LinkButton = CType(control, LinkButton)
                    If lb.CommandName = "Delete" Then
                        lb.OnClientClick = "return confirm('Are you sure you want to delete this course?');"
                        lb.CssClass = "btn btn-danger btn-sm"
                    ElseIf lb.CommandName = "Edit" Then
                        lb.CssClass = "btn btn-warning btn-sm"
                    ElseIf lb.CommandName = "Update" Then
                        lb.CssClass = "btn btn-success btn-sm"
                    ElseIf lb.CommandName = "Cancel" Then
                        lb.CssClass = "btn btn-secondary btn-sm"
                    End If
                End If
            Next

            ' Populate department dropdown in edit mode
            If gvCourses.EditIndex = e.Row.RowIndex Then
                ' Department dropdown
                Dim ddlDept As DropDownList = CType(e.Row.FindControl("ddlEditDepartments"), DropDownList)
                If ddlDept IsNot Nothing Then
                    Using conn As New MySqlConnection(ConnString)
                        Dim cmd As New MySqlCommand("SELECT DepartmentID, DepartmentName FROM Departments", conn)
                        Dim da As New MySqlDataAdapter(cmd)
                        Dim dt As New DataTable()
                        da.Fill(dt)
                        ddlDept.DataSource = dt
                        ddlDept.DataTextField = "DepartmentName"
                        ddlDept.DataValueField = "DepartmentID"
                        ddlDept.DataBind()
                    End Using

                    Dim currentDeptID As String = DataBinder.Eval(e.Row.DataItem, "DepartmentID").ToString()
                    ddlDept.SelectedValue = currentDeptID
                End If

                ' Year Levels dropdown
                Dim ddlYears As DropDownList = CType(e.Row.FindControl("ddlEditYearLevels"), DropDownList)
                If ddlYears IsNot Nothing Then
                    Dim currentYearLevels As String = DataBinder.Eval(e.Row.DataItem, "YearLevels").ToString()
                    ddlYears.SelectedValue = currentYearLevels
                End If
            End If
        End If
    End Sub
    ' Search functionality

End Class


