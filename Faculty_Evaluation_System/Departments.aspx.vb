Imports System.Configuration
Imports MySql.Data.MySqlClient

Public Class Department
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Session("Role") Is Nothing OrElse Session("Role").ToString() <> "Admin" Then
                Response.Redirect("Login.aspx")
            End If

            lblWelcome.Text = Session("FullName").ToString()
            LoadDepartments()
            UpdateSidebarBadges()
        End If

    End Sub

    ' Load Departments
    Private Sub LoadDepartments()
        Dim dt As New DataTable()
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "SELECT DepartmentID, DepartmentName FROM Departments WHERE IsActive = 1 ORDER BY DepartmentName ASC"
            Using cmd As New MySqlCommand(sql, conn)
                Using da As New MySqlDataAdapter(cmd)
                    da.Fill(dt)
                End Using
            End Using
        End Using
        gvDepartments.DataSource = dt
        gvDepartments.DataBind()
    End Sub

    ' Add Department with duplicate + reactivation check
    Protected Sub btnAddDept_Click(sender As Object, e As EventArgs)
        Dim deptName As String = txtDeptName.Text.Trim()

        If String.IsNullOrWhiteSpace(deptName) Then
            lblMessage.Text = "⚠ Department name cannot be empty."
            lblMessage.CssClass = "alert alert-danger d-block"
            Return
        End If

        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Check if department already exists (active or inactive)
            Using cmdCheck As New MySqlCommand("SELECT DepartmentID, IsActive FROM Departments WHERE DepartmentName=@DeptName LIMIT 1", conn)
                cmdCheck.Parameters.AddWithValue("@DeptName", deptName)
                Using rdr As MySqlDataReader = cmdCheck.ExecuteReader()
                    If rdr.Read() Then
                        Dim existingID As Integer = Convert.ToInt32(rdr("DepartmentID"))
                        Dim isActive As Boolean = Convert.ToBoolean(rdr("IsActive"))

                        If isActive Then
                            ' Already active → block
                            lblMessage.Text = "⚠ Department already exists."
                            lblMessage.CssClass = "alert alert-danger d-block"
                            Return
                        Else
                            ' Exists but inactive → reactivate
                            rdr.Close()
                            Using cmdReactivate As New MySqlCommand("UPDATE Departments SET IsActive=1 WHERE DepartmentID=@ID", conn)
                                cmdReactivate.Parameters.AddWithValue("@ID", existingID)
                                cmdReactivate.ExecuteNonQuery()
                            End Using

                            lblMessage.Text = "✅ Department reactivated successfully!"
                            lblMessage.CssClass = "alert alert-success d-block"
                            txtDeptName.Text = ""
                            LoadDepartments()
                            Return
                        End If
                    End If
                End Using
            End Using

            ' If not found, insert new department
            Using cmd As New MySqlCommand("INSERT INTO Departments (DepartmentName, IsActive) VALUES (@DeptName, 1)", conn)
                cmd.Parameters.AddWithValue("@DeptName", deptName)
                cmd.ExecuteNonQuery()
            End Using
        End Using

        lblMessage.Text = "✅ Department added successfully!"
        lblMessage.CssClass = "alert alert-success d-block"
        txtDeptName.Text = ""
        LoadDepartments()
    End Sub


    ' Paging
    Protected Sub gvDepartments_PageIndexChanging(sender As Object, e As GridViewPageEventArgs)
        gvDepartments.PageIndex = e.NewPageIndex
        LoadDepartments()
    End Sub

    ' Edit
    Protected Sub gvDepartments_RowEditing(sender As Object, e As GridViewEditEventArgs)
        gvDepartments.EditIndex = e.NewEditIndex
        LoadDepartments()
    End Sub

    ' Cancel Edit
    Protected Sub gvDepartments_RowCancelingEdit(sender As Object, e As GridViewCancelEditEventArgs)
        gvDepartments.EditIndex = -1
        LoadDepartments()
    End Sub

    ' Update Department with duplicate check (only against active departments)
    Protected Sub gvDepartments_RowUpdating(sender As Object, e As GridViewUpdateEventArgs)
        Dim DepartmentID As Integer = Convert.ToInt32(gvDepartments.DataKeys(e.RowIndex).Value)
        Dim row As GridViewRow = gvDepartments.Rows(e.RowIndex)
        Dim txtDeptNameEdit As TextBox = CType(row.FindControl("txtDeptNameEdit"), TextBox)
        Dim newName As String = txtDeptNameEdit.Text.Trim()

        If String.IsNullOrWhiteSpace(newName) Then
            lblMessage.Text = "⚠ Department name cannot be empty."
            lblMessage.CssClass = "alert alert-danger d-block"
            Return
        End If

        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Duplicate check (only active departments other than current one)
            Using cmdCheck As New MySqlCommand("SELECT COUNT(*) FROM Departments WHERE DepartmentName=@DeptName AND DepartmentID<>@DepartmentID AND IsActive=1", conn)
                cmdCheck.Parameters.AddWithValue("@DeptName", newName)
                cmdCheck.Parameters.AddWithValue("@DepartmentID", DepartmentID)
                Dim exists As Integer = Convert.ToInt32(cmdCheck.ExecuteScalar())
                If exists > 0 Then
                    lblMessage.Text = "⚠ Department already exists."
                    lblMessage.CssClass = "alert alert-danger d-block"
                    Return
                End If
            End Using

            ' Update department name
            Using cmd As New MySqlCommand("UPDATE Departments SET DepartmentName=@DepartmentName WHERE DepartmentID=@DepartmentID", conn)
                cmd.Parameters.AddWithValue("@DepartmentName", newName)
                cmd.Parameters.AddWithValue("@DepartmentID", DepartmentID)
                cmd.ExecuteNonQuery()
            End Using
        End Using

        gvDepartments.EditIndex = -1
        LoadDepartments()
        lblMessage.Text = "✅ Department updated successfully!"
        lblMessage.CssClass = "alert alert-success d-block"
    End Sub


    ' Delete with FK protection
    ' Soft delete (archive) department instead of hard delete
    Protected Sub gvDepartments_RowDeleting(sender As Object, e As GridViewDeleteEventArgs)
        Dim DepartmentID As Integer = Convert.ToInt32(gvDepartments.DataKeys(e.RowIndex).Value)

        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                ' Check if department exists
                Dim checkSql As String = "SELECT COUNT(*) FROM Departments WHERE DepartmentID=@DepartmentID"
                Using checkCmd As New MySqlCommand(checkSql, conn)
                    checkCmd.Parameters.AddWithValue("@DepartmentID", DepartmentID)
                    Dim exists As Integer = Convert.ToInt32(checkCmd.ExecuteScalar())
                    If exists = 0 Then
                        lblMessage.Text = "⚠ Department not found."
                        lblMessage.CssClass = "alert alert-danger d-block"
                        Return
                    End If
                End Using

                ' Soft delete (set inactive)
                Dim sql As String = "UPDATE Departments SET IsActive=0 WHERE DepartmentID=@DepartmentID"
                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@DepartmentID", DepartmentID)
                    cmd.ExecuteNonQuery()
                End Using
            End Using

            lblMessage.Text = "✅ Department archived successfully!"
            lblMessage.CssClass = "alert alert-success d-block"

        Catch ex As Exception
            lblMessage.Text = "⚠ Error: " & ex.Message
            lblMessage.CssClass = "alert alert-danger d-block"
        End Try

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

End Class

