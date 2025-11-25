Imports System.Data
Imports MySql.Data.MySqlClient
Imports System.Configuration
Imports System.Web.Services

Public Class AdminConfirmEnrollment
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Not AuthorizeUser() Then
                Response.Redirect("Login.aspx")
                Return
            End If

            InitializePage()
        End If
    End Sub

    ' ========== AUTHORIZATION & INITIALIZATION ==========
    Private Function AuthorizeUser() As Boolean
        Return Session("Role") IsNot Nothing AndAlso
               (Session("Role").ToString() = "Admin" OrElse Session("Role").ToString() = "Dean")
    End Function

    Private Sub InitializePage()
        lblWelcome.Text = Session("FullName").ToString()
        LoadPageData()
    End Sub

    Private Sub LoadPageData()
        Try
            LoadCourseFilter()
            LoadStudentRequests()
            UpdateSidebarPendingBadge()
        Catch ex As Exception
            ShowError($"Error loading page data: {ex.Message}")
        End Try
    End Sub

    ' ========== FILTER METHODS ==========
    Private Sub LoadCourseFilter()
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                Dim query = "SELECT CourseID, CourseName FROM Courses WHERE IsActive = 1 ORDER BY CourseName"

                Using cmd As New MySqlCommand(query, conn)
                    Using da As New MySqlDataAdapter(cmd)
                        Dim dt As New DataTable()
                        da.Fill(dt)

                        ddlCourseFilter.DataSource = dt
                        ddlCourseFilter.DataTextField = "CourseName"
                        ddlCourseFilter.DataValueField = "CourseID"
                        ddlCourseFilter.DataBind()
                        ddlCourseFilter.Items.Insert(0, New ListItem("All Courses", ""))
                    End Using
                End Using
            End Using
        Catch ex As Exception
            Throw New Exception($"Failed to load course filter: {ex.Message}")
        End Try
    End Sub

    ' ========== STUDENT REQUESTS METHODS ==========
    Private Sub LoadStudentRequests()
        Try
            Dim activeCycleID = GetActiveCycleID()

            If activeCycleID = 0 Then
                ShowInfo("No active evaluation cycle found.")
                pnlNoRequests.Visible = True
                Return
            End If

            Dim requests = GetStudentRequests(activeCycleID)
            BindStudentRequests(requests)
        Catch ex As Exception
            Throw New Exception($"Failed to load student requests: {ex.Message}")
        End Try
    End Sub

    Private Function GetStudentRequests(cycleID As Integer) As DataTable
        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            Dim sql = BuildStudentQuery()
            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@CycleID", cycleID)
                ApplyQueryFilters(cmd)

                Using da As New MySqlDataAdapter(cmd)
                    Dim dt As New DataTable()
                    da.Fill(dt)
                    Return dt
                End Using
            End Using
        End Using
    End Function

    Private Function BuildStudentQuery() As String
        Dim sql = "
        SELECT DISTINCT
            s.StudentID,
            s.SchoolID,
            CONCAT(s.LastName, ', ', s.FirstName,
                   CASE 
                       WHEN s.MiddleInitial IS NOT NULL AND TRIM(s.MiddleInitial) <> '' 
                       THEN CONCAT(' ', s.MiddleInitial, '.') 
                       ELSE '' 
                   END,
                   CASE 
                       WHEN s.Suffix IS NOT NULL AND TRIM(s.Suffix) <> '' 
                       THEN CONCAT(' ', s.Suffix) 
                       ELSE '' 
                   END) AS FullName,
            c.CourseName,
            MAX(ise.EnrollmentDate) AS EnrollmentDate,
            ec.Term,
            MAX(ise.IsApproved) AS IsApproved
        FROM irregular_student_enrollments ise
        INNER JOIN Students s ON ise.StudentID = s.StudentID
        INNER JOIN Courses c ON s.CourseID = c.CourseID
        INNER JOIN evaluationcycles ec ON ise.CycleID = ec.CycleID
        WHERE ise.CycleID = @CycleID"

        ' Apply filters
        If ddlStatusFilter.SelectedValue <> "" Then
            sql &= " AND ise.IsApproved = @Status"
        End If

        If ddlCourseFilter.SelectedValue <> "" Then
            sql &= " AND s.CourseID = @CourseID"
        End If

        If Not String.IsNullOrEmpty(txtSearchStudent.Text.Trim()) Then
            sql &= " AND (s.SchoolID LIKE @Search OR s.LastName LIKE @Search OR s.FirstName LIKE @Search)"
        End If

        sql &= " GROUP BY s.StudentID, s.SchoolID, s.LastName, s.FirstName, s.MiddleInitial, s.Suffix, c.CourseName, ec.Term"
        sql &= " ORDER BY MAX(ise.EnrollmentDate) DESC"

        Return sql
    End Function

    Private Sub ApplyQueryFilters(cmd As MySqlCommand)
        If ddlStatusFilter.SelectedValue <> "" Then
            cmd.Parameters.AddWithValue("@Status", ddlStatusFilter.SelectedValue)
        End If

        If ddlCourseFilter.SelectedValue <> "" Then
            cmd.Parameters.AddWithValue("@CourseID", ddlCourseFilter.SelectedValue)
        End If

        If Not String.IsNullOrEmpty(txtSearchStudent.Text.Trim()) Then
            cmd.Parameters.AddWithValue("@Search", $"%{txtSearchStudent.Text.Trim()}%")
        End If
    End Sub

    Private Sub BindStudentRequests(requests As DataTable)
        If requests.Rows.Count > 0 Then
            gvStudents.DataSource = requests
            gvStudents.DataBind()
            pnlNoRequests.Visible = False
            lblResultsCount.Text = $"{requests.Rows.Count} request(s) found"
        Else
            gvStudents.DataSource = Nothing
            gvStudents.DataBind()
            pnlNoRequests.Visible = True
            lblResultsCount.Text = "No requests found"
        End If
    End Sub

    ' ========== GRIDVIEW EVENT HANDLERS ==========
    Protected Sub gvStudents_RowDataBound(sender As Object, e As GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim studentID = Convert.ToInt32(gvStudents.DataKeys(e.Row.RowIndex).Value)
            Dim isApproved As Integer = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "IsApproved"))

            ConfigureStudentRow(e.Row, studentID, isApproved)
        ElseIf e.Row.RowType = DataControlRowType.Header Then
            ' Add checkall functionality
            Dim chkSelectAll = CType(e.Row.FindControl("chkSelectAll"), CheckBox)
            If chkSelectAll IsNot Nothing Then
                chkSelectAll.Attributes.Add("onclick", "toggleSelectAll(this)")
            End If
        End If
    End Sub

    Private Sub ConfigureStudentRow(row As GridViewRow, studentID As Integer, isApproved As Integer)
        ' Configure status badge
        Dim lblStatus = CType(row.FindControl("lblStatus"), Label)

        Select Case isApproved
            Case 1 ' Approved
                lblStatus.Text = "APPROVED"
                lblStatus.CssClass = "badge bg-success"
            Case 2 ' Rejected
                lblStatus.Text = "REJECTED"
                lblStatus.CssClass = "badge bg-danger"
            Case Else ' Pending
                lblStatus.Text = "PENDING"
                lblStatus.CssClass = "badge bg-warning text-dark"
        End Select
    End Sub

    ' ========== BULK ACTIONS ==========
    Protected Sub btnBulkApprove_Click(sender As Object, e As EventArgs)
        Try
            Dim selectedStudents = GetSelectedStudents()

            If selectedStudents.Count = 0 Then
                ShowError("Please select at least one student.")
                Return
            End If

            If ProcessBulkAction(selectedStudents, 1, "approve") Then
                ShowSuccess($"{selectedStudents.Count} enrollment request(s) approved successfully.")
                RefreshData()
            Else
                ShowError("Error approving selected enrollment requests.")
            End If
        Catch ex As Exception
            ShowError($"Error during bulk approval: {ex.Message}")
        End Try
    End Sub

    Protected Sub btnBulkReject_Click(sender As Object, e As EventArgs)
        Try
            Dim selectedStudents = GetSelectedStudents()

            If selectedStudents.Count = 0 Then
                ShowError("Please select at least one student.")
                Return
            End If

            If ProcessBulkAction(selectedStudents, 2, "reject") Then
                ShowSuccess($"{selectedStudents.Count} enrollment request(s) rejected.")
                RefreshData()
            Else
                ShowError("Error rejecting selected enrollment requests.")
            End If
        Catch ex As Exception
            ShowError($"Error during bulk rejection: {ex.Message}")
        End Try
    End Sub

    Private Function GetSelectedStudents() As List(Of Integer)
        Dim selectedStudents As New List(Of Integer)()

        For Each row As GridViewRow In gvStudents.Rows
            If row.RowType = DataControlRowType.DataRow Then
                Dim chkSelect = CType(row.FindControl("chkSelect"), CheckBox)
                If chkSelect IsNot Nothing AndAlso chkSelect.Checked Then
                    Dim studentID = Convert.ToInt32(gvStudents.DataKeys(row.RowIndex).Value)
                    selectedStudents.Add(studentID)
                End If
            End If
        Next

        Return selectedStudents
    End Function

    Private Function ProcessBulkAction(studentIDs As List(Of Integer), status As Integer, actionName As String) As Boolean
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                Dim activeCycleID = GetActiveCycleID()

                If activeCycleID = 0 Then
                    ShowError("No active evaluation cycle found.")
                    Return False
                End If

                Dim studentIDList = String.Join(",", studentIDs)
                Dim query = $"
                    UPDATE irregular_student_enrollments 
                    SET IsApproved = @Status, 
                        ApprovedBy = @AdminID, 
                        ApprovalDate = NOW()
                    WHERE StudentID IN ({studentIDList}) AND CycleID = @CycleID"

                Using cmd As New MySqlCommand(query, conn)
                    cmd.Parameters.AddWithValue("@Status", status)
                    cmd.Parameters.AddWithValue("@AdminID", Session("UserID"))
                    cmd.Parameters.AddWithValue("@CycleID", activeCycleID)

                    Return cmd.ExecuteNonQuery() > 0
                End Using
            End Using
        Catch ex As Exception
            Throw New Exception($"Error during bulk {actionName}: {ex.Message}")
        End Try
    End Function

    ' ========== MODAL ACTIONS ==========
    Protected Sub btnModalApprove_Click(sender As Object, e As EventArgs)
        Try
            Dim studentID = Convert.ToInt32(hfSelectedStudentID.Value)

            If ProcessEnrollmentAction(studentID, 1, "approve") Then
                ShowSuccess("Enrollment request approved successfully.")
                RefreshData()
                ' Close modal
                ScriptManager.RegisterStartupScript(Me, Me.GetType(), "CloseModal", "$('#studentDetailsModal').modal('hide');", True)
            Else
                ShowError("Error approving enrollment request.")
            End If
        Catch ex As Exception
            ShowError($"Error during approval: {ex.Message}")
        End Try
    End Sub

    Protected Sub btnModalReject_Click(sender As Object, e As EventArgs)
        Try
            Dim studentID = Convert.ToInt32(hfSelectedStudentID.Value)

            If ProcessEnrollmentAction(studentID, 2, "reject") Then
                ShowSuccess("Enrollment request rejected.")
                RefreshData()
                ' Close modal
                ScriptManager.RegisterStartupScript(Me, Me.GetType(), "CloseModal", "$('#studentDetailsModal').modal('hide');", True)
            Else
                ShowError("Error rejecting enrollment request.")
            End If
        Catch ex As Exception
            ShowError($"Error during rejection: {ex.Message}")
        End Try
    End Sub

    Private Function ProcessEnrollmentAction(studentID As Integer, status As Integer, actionName As String) As Boolean
        Try
            Return UpdateEnrollmentStatus(studentID, status)
        Catch ex As Exception
            Throw New Exception($"Error during {actionName}: {ex.Message}")
        End Try
    End Function

    Private Function UpdateEnrollmentStatus(studentID As Integer, status As Integer) As Boolean
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim activeCycleID = GetActiveCycleID()

            If activeCycleID = 0 Then
                ShowError("No active evaluation cycle found.")
                Return False
            End If

            Dim query = "
                UPDATE irregular_student_enrollments 
                SET IsApproved = @Status, 
                    ApprovedBy = @AdminID, 
                    ApprovalDate = NOW()
                WHERE StudentID = @StudentID AND CycleID = @CycleID"

            Using cmd As New MySqlCommand(query, conn)
                cmd.Parameters.AddWithValue("@StudentID", studentID)
                cmd.Parameters.AddWithValue("@CycleID", activeCycleID)
                cmd.Parameters.AddWithValue("@Status", status)
                cmd.Parameters.AddWithValue("@AdminID", Session("UserID"))

                Return cmd.ExecuteNonQuery() > 0
            End Using
        End Using
    End Function

    ' ========== SUBJECTS DATA ==========
    <WebMethod()>
    Public Shared Function GetStudentSubjects(studentID As Integer) As String
        Try
            Dim connString = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
            Using conn As New MySqlConnection(connString)
                conn.Open()
                Dim activeCycleID = GetActiveCycleIDStatic(conn)

                If activeCycleID = 0 Then
                    Return "[]"
                End If

                Dim query = "
                SELECT 
                    sub.SubjectCode, 
                    sub.SubjectName,
                    CONCAT(u.LastName, ', ', u.FirstName,
                           CASE 
                               WHEN u.MiddleInitial IS NOT NULL AND TRIM(u.MiddleInitial) <> '' 
                               THEN CONCAT(' ', u.MiddleInitial, '.') 
                               ELSE '' 
                           END) AS FacultyName,
                    c.YearLevel,
                    c.Section
                FROM irregular_student_enrollments ise
                INNER JOIN FacultyLoad fl ON ise.LoadID = fl.LoadID
                INNER JOIN Subjects sub ON fl.SubjectID = sub.SubjectID
                INNER JOIN Users u ON fl.FacultyID = u.UserID
                INNER JOIN Classes c ON fl.ClassID = c.ClassID
                WHERE ise.StudentID = @StudentID AND ise.CycleID = @CycleID
                ORDER BY sub.SubjectName"

                Using cmd As New MySqlCommand(query, conn)
                    cmd.Parameters.AddWithValue("@StudentID", studentID)
                    cmd.Parameters.AddWithValue("@CycleID", activeCycleID)

                    Using da As New MySqlDataAdapter(cmd)
                        Dim dt As New DataTable()
                        da.Fill(dt)

                        If dt.Rows.Count > 0 Then
                            Dim result As New List(Of Dictionary(Of String, String))()
                            For Each row As DataRow In dt.Rows
                                result.Add(New Dictionary(Of String, String) From {
                                {"Code", row("SubjectCode").ToString()},
                                {"Name", row("SubjectName").ToString()},
                                {"Faculty", row("FacultyName").ToString()},
                                {"Class", $"{row("YearLevel")} {row("Section")}"}
                            })
                            Next
                            Return Newtonsoft.Json.JsonConvert.SerializeObject(result)
                        Else
                            Return "[]"
                        End If
                    End Using
                End Using
            End Using
        Catch ex As Exception
            ' Return empty array with error information
            Return Newtonsoft.Json.JsonConvert.SerializeObject(New List(Of Dictionary(Of String, String)) From {
            New Dictionary(Of String, String) From {
                {"Code", "ERROR"},
                {"Name", "Error loading subjects"},
                {"Faculty", ex.Message},
                {"Class", ""}
            }
        })
        End Try
    End Function

    <WebMethod()>
    Public Shared Function GetStudentInfo(studentID As Integer) As String
        Try
            Dim connString = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
            Using conn As New MySqlConnection(connString)
                conn.Open()

                Dim query = "
                SELECT 
                    s.SchoolID,
                    CONCAT(s.LastName, ', ', s.FirstName,
                           CASE 
                               WHEN s.MiddleInitial IS NOT NULL AND TRIM(s.MiddleInitial) <> '' 
                               THEN CONCAT(' ', s.MiddleInitial, '.') 
                               ELSE '' 
                           END,
                           CASE 
                               WHEN s.Suffix IS NOT NULL AND TRIM(s.Suffix) <> '' 
                               THEN CONCAT(' ', s.Suffix) 
                               ELSE '' 
                           END) AS FullName,
                    c.CourseName,
                    d.DepartmentName
                FROM Students s
                INNER JOIN Courses c ON s.CourseID = c.CourseID
                INNER JOIN Departments d ON s.DepartmentID = d.DepartmentID
                WHERE s.StudentID = @StudentID"

                Using cmd As New MySqlCommand(query, conn)
                    cmd.Parameters.AddWithValue("@StudentID", studentID)

                    Using reader = cmd.ExecuteReader()
                        If reader.Read() Then
                            Dim result = New Dictionary(Of String, String) From {
                            {"StudentID", reader("SchoolID").ToString()},
                            {"FullName", reader("FullName").ToString()},
                            {"Course", reader("CourseName").ToString()},
                            {"Department", reader("DepartmentName").ToString()}
                        }
                            Return Newtonsoft.Json.JsonConvert.SerializeObject(result)
                        Else
                            ' Return empty object if no student found
                            Return Newtonsoft.Json.JsonConvert.SerializeObject(New Dictionary(Of String, String) From {
                            {"StudentID", ""},
                            {"FullName", "Student not found"},
                            {"Course", ""},
                            {"Department", ""}
                        })
                        End If
                    End Using
                End Using
            End Using
        Catch ex As Exception
            ' Return error information in JSON format
            Return Newtonsoft.Json.JsonConvert.SerializeObject(New Dictionary(Of String, String) From {
            {"StudentID", ""},
            {"FullName", "Error loading student information"},
            {"Course", ""},
            {"Department", ""},
            {"Error", ex.Message}
        })
        End Try
    End Function

    ' ========== SIDEBAR BADGE METHODS ==========
    Private Sub UpdateSidebarPendingBadge()
        Try
            Dim pendingEnrollmentCount = GetPendingEnrollmentCount()
            Dim pendingReleaseCount = GetPendingReleaseCountByFaculty()

            ' Update enrollment badge
            sidebarPendingBadge.Text = pendingEnrollmentCount.ToString()
            sidebarPendingBadge.Visible = pendingEnrollmentCount > 0

            ' Update release results badge
            sidebarReleasePendingBadge.Text = pendingReleaseCount.ToString()
            sidebarReleasePendingBadge.Visible = pendingReleaseCount > 0
        Catch ex As Exception
            ' Log error but don't break the page
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

    Private Shared Function GetActiveCycleIDStatic(conn As MySqlConnection) As Integer
        Try
            Dim query = "SELECT CycleID FROM evaluationcycles WHERE Status = 'Active' LIMIT 1"
            Using cmd As New MySqlCommand(query, conn)
                Dim result = cmd.ExecuteScalar()
                Return If(result IsNot Nothing AndAlso Not IsDBNull(result), Convert.ToInt32(result), 0)
            End Using
        Catch ex As Exception
            Return 0
        End Try
    End Function

    ' ========== HELPER METHODS ==========
    Private Function GetActiveCycleID() As Integer
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                Dim query = "SELECT CycleID FROM evaluationcycles WHERE Status = 'Active' LIMIT 1"

                Using cmd As New MySqlCommand(query, conn)
                    Dim result = cmd.ExecuteScalar()
                    Return If(result IsNot Nothing, Convert.ToInt32(result), 0)
                End Using
            End Using
        Catch ex As Exception
            Return 0
        End Try
    End Function

    ' ========== FILTER EVENT HANDLERS ==========
    Protected Sub ddlStatusFilter_SelectedIndexChanged(sender As Object, e As EventArgs)
        LoadStudentRequests()
    End Sub

    Protected Sub ddlCourseFilter_SelectedIndexChanged(sender As Object, e As EventArgs)
        LoadStudentRequests()
    End Sub

    Protected Sub txtSearchStudent_TextChanged(sender As Object, e As EventArgs)
        LoadStudentRequests()
    End Sub

    Protected Sub btnRefresh_Click(sender As Object, e As EventArgs)
        RefreshData()
    End Sub

    Private Sub RefreshData()
        LoadStudentRequests()
        UpdateSidebarPendingBadge()
    End Sub

    ' ========== UI HELPER METHODS ==========
    Private Sub ShowError(message As String)
        lblMessage.Text = message
        lblMessage.CssClass = "alert alert-danger d-block"
    End Sub

    Private Sub ShowSuccess(message As String)
        lblMessage.Text = message
        lblMessage.CssClass = "alert alert-success d-block"
    End Sub

    Private Sub ShowInfo(message As String)
        lblMessage.Text = message
        lblMessage.CssClass = "alert alert-info d-block"
    End Sub
End Class