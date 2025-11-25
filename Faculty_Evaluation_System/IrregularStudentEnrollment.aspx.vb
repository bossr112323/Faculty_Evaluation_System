Imports System.Data
Imports MySql.Data.MySqlClient
Imports System.Configuration

Public Class IrregularStudentEnrollment
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    Private Property ActiveCycleID As Integer
        Get
            If ViewState("ActiveCycleID") IsNot Nothing Then
                Return Convert.ToInt32(ViewState("ActiveCycleID"))
            End If
            Return 0
        End Get
        Set(value As Integer)
            ViewState("ActiveCycleID") = value
        End Set
    End Property

    Private Property ActiveTerm As String
        Get
            If ViewState("ActiveTerm") IsNot Nothing Then
                Return ViewState("ActiveTerm").ToString()
            End If
            Return ""
        End Get
        Set(value As String)
            ViewState("ActiveTerm") = value
        End Set
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Session("Role") Is Nothing OrElse Session("Role").ToString() <> "Student" Then
                Response.Redirect("Login.aspx")
            End If

            ' Check if student is marked as irregular
            If Not IsIrregularStudent() Then
                Response.Redirect("StudentDashboard.aspx")
            End If

            LoadPageData()
        End If
    End Sub

    Private Sub LoadPageData()
        ' First, ensure we have an active cycle
        If Not EnsureActiveCycle() Then
            ShowError("Unable to set up evaluation cycle. Please contact administrator.")
            Return
        End If


        LoadAvailableSubjects()
        UpdateSelectedCount()
    End Sub

    Private Function EnsureActiveCycle() As Boolean
        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Get any active cycle
            Dim cmd As New MySqlCommand("
                SELECT CycleID, Term 
                FROM evaluationcycles 
                WHERE Status = 'Active' 
                LIMIT 1", conn)

            Using reader = cmd.ExecuteReader()
                If reader.Read() Then
                    ActiveCycleID = Convert.ToInt32(reader("CycleID"))
                    ActiveTerm = reader("Term").ToString()
                    lblCurrentTerm.Text = ActiveTerm
                    Return True
                End If
            End Using

            ShowError("No active evaluation cycle found. Please contact administrator.")
            Return False
        End Using
    End Function



    Private Sub LoadAvailableSubjects()
        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Get student's course and department
            Dim studentCmd As New MySqlCommand("
                SELECT CourseID, DepartmentID 
                FROM Students 
                WHERE StudentID = @StudentID", conn)
            studentCmd.Parameters.AddWithValue("@StudentID", Session("UserID"))

            Dim courseID As Integer = 0, deptID As Integer = 0
            Using reader = studentCmd.ExecuteReader()
                If reader.Read() Then
                    courseID = Convert.ToInt32(reader("CourseID"))
                    deptID = Convert.ToInt32(reader("DepartmentID"))
                End If
            End Using

            If courseID = 0 Then
                ShowError("Student course information not found.")
                Return
            End If

            ' Build the base query with filters
            Dim query As String = "
                SELECT 
                    fl.LoadID,
                    sub.SubjectCode,
                    sub.SubjectName,
                    CONCAT(u.LastName, ', ', u.FirstName) AS FacultyName,
                    c.YearLevel,
                    c.Section,
                    fl.Term,
                    CASE 
                        WHEN ise.IsApproved = 1 THEN 'Approved'
                        WHEN ise.IsApproved = 0 THEN 'Pending'
                        ELSE 'Not Enrolled'
                    END AS EnrollmentStatus,
                    ise.IsApproved
                FROM FacultyLoad fl
                INNER JOIN Users u ON fl.FacultyID = u.UserID
                INNER JOIN Subjects sub ON fl.SubjectID = sub.SubjectID
                INNER JOIN Classes c ON fl.ClassID = c.ClassID
                LEFT JOIN irregular_student_enrollments ise ON fl.LoadID = ise.LoadID 
                    AND ise.StudentID = @StudentID 
                    AND ise.CycleID = @ActiveCycleID
                WHERE fl.Term = @ActiveTerm
                  AND fl.CourseID = @CourseID
                  AND fl.DepartmentID = @DeptID
                  AND fl.IsDeleted = 0"

            ' Apply search filter
            If Not String.IsNullOrEmpty(txtSearch.Text.Trim()) Then
                query += " AND (sub.SubjectCode LIKE @Search OR sub.SubjectName LIKE @Search OR u.LastName LIKE @Search OR u.FirstName LIKE @Search)"
            End If

            ' Apply year level filter
            If Not String.IsNullOrEmpty(ddlYearLevel.SelectedValue) Then
                query += " AND c.YearLevel = @YearLevel"
            End If

            query += " ORDER BY c.YearLevel, sub.SubjectName"

            Dim cmd As New MySqlCommand(query, conn)
            cmd.Parameters.AddWithValue("@ActiveTerm", ActiveTerm)
            cmd.Parameters.AddWithValue("@CourseID", courseID)
            cmd.Parameters.AddWithValue("@DeptID", deptID)
            cmd.Parameters.AddWithValue("@StudentID", Session("UserID"))
            cmd.Parameters.AddWithValue("@ActiveCycleID", ActiveCycleID)

            ' Add search parameter if needed
            If Not String.IsNullOrEmpty(txtSearch.Text.Trim()) Then
                cmd.Parameters.AddWithValue("@Search", "%" & txtSearch.Text.Trim() & "%")
            End If

            ' Add year level parameter if needed
            If Not String.IsNullOrEmpty(ddlYearLevel.SelectedValue) Then
                cmd.Parameters.AddWithValue("@YearLevel", ddlYearLevel.SelectedValue)
            End If

            Dim da As New MySqlDataAdapter(cmd)
            Dim dt As New DataTable()
            da.Fill(dt)

            System.Diagnostics.Debug.WriteLine($"Loaded {dt.Rows.Count} subjects from database")

            If dt.Rows.Count > 0 Then
                rptSubjects.DataSource = dt
                rptSubjects.DataBind()
                pnlNoSubjects.Visible = False
            Else
                rptSubjects.DataSource = Nothing
                rptSubjects.DataBind()
                pnlNoSubjects.Visible = True
            End If
        End Using
    End Sub

    Protected Sub rptSubjects_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            Dim enrollmentStatus As String = DataBinder.Eval(e.Item.DataItem, "EnrollmentStatus").ToString()

            Dim lblStatusBadge As Label = CType(e.Item.FindControl("lblStatusBadge"), Label)
            Dim pnlAlreadyEnrolled As Panel = CType(e.Item.FindControl("pnlAlreadyEnrolled"), Panel)
            Dim lblEnrollmentMessage As Label = CType(e.Item.FindControl("lblEnrollmentMessage"), Label)

            If enrollmentStatus <> "Not Enrolled" Then
                Select Case enrollmentStatus
                    Case "Pending"
                        lblStatusBadge.Text = "Pending Approval"
                        lblStatusBadge.CssClass = "badge status-badge bg-warning text-dark"
                        lblEnrollmentMessage.Text = "This subject is pending approval from the registrar."
                    Case "Approved"
                        lblStatusBadge.Text = "Approved"
                        lblStatusBadge.CssClass = "badge status-badge bg-success"
                        lblEnrollmentMessage.Text = "This subject has been approved for evaluation."
                End Select

                pnlAlreadyEnrolled.Visible = True
                lblStatusBadge.Visible = True
            Else
                lblStatusBadge.Visible = False
                pnlAlreadyEnrolled.Visible = False
            End If
        End If
    End Sub

    Private Sub UpdateSelectedCount()
        Dim count As Integer = 0
        For Each item As RepeaterItem In rptSubjects.Items
            Dim chk As CheckBox = CType(item.FindControl("chkSubject"), CheckBox)
            If chk IsNot Nothing AndAlso chk.Checked AndAlso chk.Enabled Then
                count += 1
            End If
        Next
        selectedCount.Text = count.ToString()
    End Sub

    ' Filter Events
    Protected Sub txtSearch_TextChanged(sender As Object, e As EventArgs)
        LoadAvailableSubjects()
        UpdateSelectedCount()
    End Sub

    Protected Sub ddlYearLevel_SelectedIndexChanged(sender As Object, e As EventArgs)
        LoadAvailableSubjects()
        UpdateSelectedCount()
    End Sub

    Protected Sub btnClearFilters_Click(sender As Object, e As EventArgs)
        txtSearch.Text = ""
        ddlYearLevel.SelectedIndex = 0
        LoadAvailableSubjects()
        UpdateSelectedCount()
        ShowInfo("Filters cleared.")
    End Sub

    Protected Sub btnClearSelection_Click(sender As Object, e As EventArgs)
        For Each item As RepeaterItem In rptSubjects.Items
            Dim chk As CheckBox = CType(item.FindControl("chkSubject"), CheckBox)
            If chk IsNot Nothing AndAlso chk.Enabled Then
                chk.Checked = False
            End If
        Next
        UpdateSelectedCount()
        ShowInfo("Selection cleared.")
    End Sub

    Protected Sub btnSubmitSelection_Click(sender As Object, e As EventArgs)
        Dim selectedLoads As New List(Of Integer)()

        System.Diagnostics.Debug.WriteLine("Starting submission process...")

        For Each item As RepeaterItem In rptSubjects.Items
            Dim chk As CheckBox = CType(item.FindControl("chkSubject"), CheckBox)
            Dim hfLoadID As HiddenField = CType(item.FindControl("hfLoadID"), HiddenField)

            If chk IsNot Nothing AndAlso hfLoadID IsNot Nothing AndAlso chk.Checked AndAlso chk.Enabled Then
                Try
                    Dim loadID As Integer = Convert.ToInt32(hfLoadID.Value)
                    selectedLoads.Add(loadID)
                    System.Diagnostics.Debug.WriteLine("Selected LoadID: " & loadID)
                Catch ex As Exception
                    System.Diagnostics.Debug.WriteLine("Error getting LoadID: " & ex.Message)
                End Try
            End If
        Next

        System.Diagnostics.Debug.WriteLine("Total selected: " & selectedLoads.Count)

        If selectedLoads.Count = 0 Then
            ShowError("Please select at least one subject.")
            Return
        End If

        ' Double-check we have active cycle
        If ActiveCycleID = 0 Then
            ShowError("No active evaluation cycle found. Please try again later.")
            Return
        End If

        ' Check if student ID is available
        If Session("UserID") Is Nothing Then
            ShowError("Session expired. Please log in again.")
            Return
        End If

        If SaveEnrollmentRequest(selectedLoads) Then
            ShowSuccess("Your subject selection has been submitted for approval.")
            DisableForm()
            ' Reload to show updated status
            LoadAvailableSubjects()
        Else
            ShowError("Error submitting your selection. Please try again or contact administrator.")
        End If
    End Sub

    Private Function SaveEnrollmentRequest(selectedLoads As List(Of Integer)) As Boolean
        Using conn As New MySqlConnection(ConnString)
            Try
                conn.Open()
                Dim transaction As MySqlTransaction = conn.BeginTransaction()

                Try
                    ' Insert new enrollment requests (only for subjects not already enrolled)
                    For Each loadID In selectedLoads
                        ' Check if already enrolled
                        Dim checkCmd As New MySqlCommand("
                            SELECT COUNT(*) 
                            FROM irregular_student_enrollments 
                            WHERE StudentID = @StudentID 
                            AND LoadID = @LoadID 
                            AND CycleID = @CycleID", conn, transaction)
                        checkCmd.Parameters.AddWithValue("@StudentID", Session("UserID"))
                        checkCmd.Parameters.AddWithValue("@LoadID", loadID)
                        checkCmd.Parameters.AddWithValue("@CycleID", ActiveCycleID)

                        Dim existingCount As Integer = Convert.ToInt32(checkCmd.ExecuteScalar())

                        If existingCount = 0 Then
                            ' Insert new enrollment request
                            Dim insertCmd As New MySqlCommand("
                                INSERT INTO irregular_student_enrollments 
                                (StudentID, LoadID, CycleID, EnrollmentDate, IsApproved) 
                                VALUES (@StudentID, @LoadID, @CycleID, NOW(), 0)", conn, transaction)
                            insertCmd.Parameters.AddWithValue("@StudentID", Session("UserID"))
                            insertCmd.Parameters.AddWithValue("@LoadID", loadID)
                            insertCmd.Parameters.AddWithValue("@CycleID", ActiveCycleID)
                            insertCmd.ExecuteNonQuery()
                        End If
                    Next

                    transaction.Commit()
                    System.Diagnostics.Debug.WriteLine("Successfully saved enrollment request")
                    Return True

                Catch ex As Exception
                    transaction.Rollback()
                    System.Diagnostics.Debug.WriteLine("Transaction Error: " & ex.Message)
                    System.Diagnostics.Debug.WriteLine("Stack Trace: " & ex.StackTrace)
                    Return False
                End Try

            Catch ex As Exception
                System.Diagnostics.Debug.WriteLine("Connection Error: " & ex.Message)
                Return False
            End Try
        End Using
    End Function

    Protected Sub btnCancel_Click(sender As Object, e As EventArgs)
        Response.Redirect("StudentDashboard.aspx")
    End Sub

    Private Function IsIrregularStudent() As Boolean
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim cmd As New MySqlCommand("SELECT StudentType FROM Students WHERE StudentID = @StudentID", conn)
            cmd.Parameters.AddWithValue("@StudentID", Session("UserID"))
            Dim result = cmd.ExecuteScalar()
            Return result IsNot Nothing AndAlso result.ToString() = "Irregular"
        End Using
    End Function

    Private Sub DisableForm()
        btnSubmitSelection.Enabled = False
        btnClearSelection.Enabled = False
        For Each item As RepeaterItem In rptSubjects.Items
            Dim chk As CheckBox = CType(item.FindControl("chkSubject"), CheckBox)
            If chk IsNot Nothing Then
                chk.Enabled = False
            End If
        Next
    End Sub

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


