Imports MySql.Data.MySqlClient
Imports System.Data
Imports System.Web.Script.Serialization
Imports System.Collections.Generic

Public Class StudentsBulk
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return System.Configuration.ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    ' Store selected student IDs in ViewState
    Private Property SelectedStudentIDs As List(Of Integer)
        Get
            If ViewState("SelectedStudentIDs") Is Nothing Then
                ViewState("SelectedStudentIDs") = New List(Of Integer)()
            End If
            Return CType(ViewState("SelectedStudentIDs"), List(Of Integer))
        End Get
        Set(value As List(Of Integer))
            ViewState("SelectedStudentIDs") = value
        End Set
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Session("Role") Is Nothing OrElse Session("Role").ToString() <> "Admin" Then
                Response.Redirect("Login.aspx")
                Return
            End If

            LoadDepartments(ddlFilterDept)
            LoadYearLevels()
            LoadStatistics()
            BindStudents()
            UpdateSelectedCountDisplay()
        End If
    End Sub

    ' --- Statistics Loading ---
    Private Sub LoadStatistics()
        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Total students
            Dim cmdTotal As New MySqlCommand("SELECT COUNT(*) FROM Students", conn)
            totalStudents.InnerText = FormatNumber(cmdTotal.ExecuteScalar(), 0)
        End Using
    End Sub

    ' --- Load year levels from Classes table ---
    Private Sub LoadYearLevels()
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim cmd As New MySqlCommand("SELECT DISTINCT YearLevel FROM Classes WHERE YearLevel IS NOT NULL AND YearLevel != '' AND IsActive=1 ORDER BY YearLevel", conn)
            Using reader As MySqlDataReader = cmd.ExecuteReader()
                ddlFilterYearLevel.Items.Clear()
                ddlFilterYearLevel.Items.Add(New ListItem("All Years", ""))

                ddlYearLevel.Items.Clear()
                ddlYearLevel.Items.Add(New ListItem("Select Year Level", ""))

                While reader.Read()
                    Dim yearLevel As String = reader("YearLevel").ToString()
                    ddlFilterYearLevel.Items.Add(New ListItem(yearLevel, yearLevel))
                    ddlYearLevel.Items.Add(New ListItem(yearLevel, yearLevel))
                End While
            End Using
        End Using
    End Sub

    ' --- Back to Dashboard ---
    Protected Sub btnBack_Click(sender As Object, e As EventArgs)
        Response.Redirect("Students.aspx")
    End Sub

    ' --- Dropdown Loaders ---
    Private Sub LoadDepartments(ddl As DropDownList)
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim cmd As New MySqlCommand("SELECT DepartmentID, DepartmentName FROM Departments WHERE IsActive=1 ORDER BY DepartmentName", conn)
            Using da As New MySqlDataAdapter(cmd)
                Dim dt As New DataTable()
                da.Fill(dt)
                ddl.DataSource = dt
                ddl.DataTextField = "DepartmentName"
                ddl.DataValueField = "DepartmentID"
                ddl.DataBind()
            End Using
        End Using
        ddl.Items.Insert(0, New ListItem("All Departments", ""))
    End Sub

    ' --- Apply Filters ---
    Protected Sub btnApplyFilters_Click(sender As Object, e As EventArgs)
        BindStudents()
        UpdateSelectedCountDisplay()
    End Sub

    ' --- Search & Bind ---
    Private Sub BindStudents()
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim sql As String = "
        SELECT s.StudentID, 
               CONCAT(s.FirstName, 
                      CASE WHEN s.MiddleInitial IS NOT NULL AND s.MiddleInitial != '' THEN CONCAT(' ', s.MiddleInitial, '.') ELSE '' END,
                      ' ', s.LastName,
                      CASE WHEN s.Suffix IS NOT NULL AND s.Suffix != '' THEN CONCAT(' ', s.Suffix) ELSE '' END
               ) AS FullName,
               s.SchoolID, s.CourseID, s.StudentType,
               d.DepartmentName, c.CourseName,
               cl.YearLevel, cl.Section, s.Status
        FROM Students s
        INNER JOIN Departments d ON s.DepartmentID = d.DepartmentID
        INNER JOIN Courses c ON s.CourseID = c.CourseID
        INNER JOIN Classes cl ON s.ClassID = cl.ClassID
        WHERE 1=1"

            Dim cmd As New MySqlCommand()
            cmd.Connection = conn

            ' Apply filters
            If Not String.IsNullOrEmpty(txtSearch.Text.Trim()) Then
                sql &= " AND (CONCAT(s.FirstName, ' ', s.LastName) LIKE @Search OR s.SchoolID LIKE @Search)"
                cmd.Parameters.AddWithValue("@Search", "%" & txtSearch.Text.Trim() & "%")
            End If

            If Not String.IsNullOrEmpty(ddlFilterDept.SelectedValue) Then
                sql &= " AND s.DepartmentID = @DeptID"
                cmd.Parameters.AddWithValue("@DeptID", ddlFilterDept.SelectedValue)
            End If

            If Not String.IsNullOrEmpty(ddlFilterYearLevel.SelectedValue) Then
                sql &= " AND cl.YearLevel = @YearLevel"
                cmd.Parameters.AddWithValue("@YearLevel", ddlFilterYearLevel.SelectedValue)
            End If

            If Not String.IsNullOrEmpty(ddlFilterStatus.SelectedValue) Then
                sql &= " AND s.Status = @Status"
                cmd.Parameters.AddWithValue("@Status", ddlFilterStatus.SelectedValue)
            End If

            ' Add StudentType filter
            If Not String.IsNullOrEmpty(ddlFilterStudentType.SelectedValue) Then
                sql &= " AND s.StudentType = @StudentType"
                cmd.Parameters.AddWithValue("@StudentType", ddlFilterStudentType.SelectedValue)
            End If

            sql &= " ORDER BY s.FirstName, s.LastName ASC"

            cmd.CommandText = sql

            Using da As New MySqlDataAdapter(cmd)
                Dim dt As New DataTable()
                da.Fill(dt)

                gvStudentsBulk.DataSource = dt
                gvStudentsBulk.DataBind()

                lblTotalRecords.Text = $"{dt.Rows.Count} students found"
            End Using
        End Using
    End Sub

    Protected Sub btnSearch_Click(sender As Object, e As EventArgs) Handles btnSearch.Click
        BindStudents()
        UpdateSelectedCountDisplay()
    End Sub

    Protected Sub btnClearFilters_Click(sender As Object, e As EventArgs) Handles btnClearFilters.Click
        txtSearch.Text = ""
        ddlFilterDept.SelectedIndex = 0
        ddlFilterYearLevel.SelectedIndex = 0
        ddlFilterStatus.SelectedIndex = 0
        ddlFilterStudentType.SelectedIndex = 0 ' Add this line
        BindStudents()
        UpdateSelectedCountDisplay()
    End Sub

    Protected Sub gvStudentsBulk_PageIndexChanging(sender As Object, e As GridViewPageEventArgs)
        SaveCurrentPageSelections()
        gvStudentsBulk.PageIndex = e.NewPageIndex
        BindStudents()
        UpdateSelectedCountDisplay()
    End Sub

    Protected Sub gvStudentsBulk_RowDataBound(sender As Object, e As GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            ' Add hover effect
            e.Row.Attributes.Add("onmouseover", "this.style.backgroundColor='#f8f9fa'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor='white'")
        End If

        ' If in edit mode, populate the year level dropdown and set StudentType
        If e.Row.RowType = DataControlRowType.DataRow AndAlso (e.Row.RowState And DataControlRowState.Edit) = DataControlRowState.Edit Then
            Dim ddlEditYearLevel As DropDownList = CType(e.Row.FindControl("ddlEditYearLevel"), DropDownList)
            If ddlEditYearLevel IsNot Nothing Then
                LoadYearLevelsForEdit(ddlEditYearLevel)

                ' Set the current value
                Dim currentYearLevel As String = DataBinder.Eval(e.Row.DataItem, "YearLevel").ToString()
                If ddlEditYearLevel.Items.FindByValue(currentYearLevel) IsNot Nothing Then
                    ddlEditYearLevel.SelectedValue = currentYearLevel
                End If
            End If

            ' Set StudentType in edit mode
            Dim ddlEditStudentType As DropDownList = CType(e.Row.FindControl("ddlEditStudentType"), DropDownList)
            If ddlEditStudentType IsNot Nothing Then
                Dim currentStudentType As String = DataBinder.Eval(e.Row.DataItem, "StudentType").ToString()
                ddlEditStudentType.SelectedValue = currentStudentType
            End If
        End If
    End Sub

    ' Load year levels for the edit dropdown
    Private Sub LoadYearLevelsForEdit(ddl As DropDownList)
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim cmd As New MySqlCommand("SELECT DISTINCT YearLevel FROM Classes WHERE YearLevel IS NOT NULL AND YearLevel != '' AND IsActive=1 ORDER BY YearLevel", conn)
            Using reader As MySqlDataReader = cmd.ExecuteReader()
                ddl.Items.Clear()
                While reader.Read()
                    ddl.Items.Add(New ListItem(reader("YearLevel").ToString(), reader("YearLevel").ToString()))
                End While
            End Using
        End Using
    End Sub

    ' --- Helper method to check if student is selected ---
    Public Function IsStudentSelected(dataItem As Object) As Boolean
        If dataItem IsNot Nothing Then
            Dim studentID As Integer = Convert.ToInt32(DataBinder.Eval(dataItem, "StudentID"))
            Return SelectedStudentIDs.Contains(studentID)
        End If
        Return False
    End Function

    ' --- Save selections from current page ---
    Private Sub SaveCurrentPageSelections()
        For Each row As GridViewRow In gvStudentsBulk.Rows
            If row.RowType = DataControlRowType.DataRow Then
                Dim chkSelect As CheckBox = CType(row.FindControl("chkSelect"), CheckBox)
                Dim studentID As Integer = Convert.ToInt32(gvStudentsBulk.DataKeys(row.RowIndex).Value)

                If chkSelect.Checked Then
                    If Not SelectedStudentIDs.Contains(studentID) Then
                        SelectedStudentIDs.Add(studentID)
                    End If
                Else
                    SelectedStudentIDs.Remove(studentID)
                End If
            End If
        Next
    End Sub

    ' --- Update selected count display ---
    Private Sub UpdateSelectedCountDisplay()
        Dim selectedCount As Integer = SelectedStudentIDs.Count
        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "UpdateSelectedCount",
            $"document.getElementById('lblSelectedCountClient').innerText = '{selectedCount} selected';", True)
    End Sub

    ' --- Select All / Deselect All ---
    Protected Sub btnSelectAll_Click(sender As Object, e As EventArgs)
        SaveCurrentPageSelections()

        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim sql As String = "SELECT s.StudentID FROM Students s INNER JOIN Classes cl ON s.ClassID = cl.ClassID WHERE 1=1"

            Dim cmd As New MySqlCommand()
            cmd.Connection = conn

            ' Apply the same filters as main query
            If Not String.IsNullOrEmpty(txtSearch.Text.Trim()) Then
                sql &= " AND (CONCAT(s.FirstName, ' ', s.LastName) LIKE @Search OR s.SchoolID LIKE @Search)"
                cmd.Parameters.AddWithValue("@Search", "%" & txtSearch.Text.Trim() & "%")
            End If

            If Not String.IsNullOrEmpty(ddlFilterDept.SelectedValue) Then
                sql &= " AND s.DepartmentID = @DeptID"
                cmd.Parameters.AddWithValue("@DeptID", ddlFilterDept.SelectedValue)
            End If

            If Not String.IsNullOrEmpty(ddlFilterYearLevel.SelectedValue) Then
                sql &= " AND cl.YearLevel = @YearLevel"
                cmd.Parameters.AddWithValue("@YearLevel", ddlFilterYearLevel.SelectedValue)
            End If

            If Not String.IsNullOrEmpty(ddlFilterStatus.SelectedValue) Then
                sql &= " AND s.Status = @Status"
                cmd.Parameters.AddWithValue("@Status", ddlFilterStatus.SelectedValue)
            End If

            ' Add StudentType filter
            If Not String.IsNullOrEmpty(ddlFilterStudentType.SelectedValue) Then
                sql &= " AND s.StudentType = @StudentType"
                cmd.Parameters.AddWithValue("@StudentType", ddlFilterStudentType.SelectedValue)
            End If

            cmd.CommandText = sql

            Using reader As MySqlDataReader = cmd.ExecuteReader()
                SelectedStudentIDs.Clear()
                While reader.Read()
                    SelectedStudentIDs.Add(reader.GetInt32("StudentID"))
                End While
            End Using
        End Using

        BindStudents()
        UpdateSelectedCountDisplay()
        ShowMessage($"Selected all {SelectedStudentIDs.Count} students matching current filters.", "success")
    End Sub

    Protected Sub btnDeselectAll_Click(sender As Object, e As EventArgs)
        SelectedStudentIDs.Clear()
        BindStudents()
        UpdateSelectedCountDisplay()
        ShowMessage("Cleared all selections.", "success")
    End Sub

    ' --- Helper method for status class ---
    Public Function GetStatusClass(status As String) As String
        Select Case status.ToLower()
            Case "active"
                Return "status-active"
            Case "inactive"
                Return "status-inactive"
            Case "graduated"
                Return "status-graduated"
            Case Else
                Return "status-inactive"
        End Select
    End Function

    ' --- Individual Row Editing ---
    Protected Sub gvStudentsBulk_RowEditing(sender As Object, e As GridViewEditEventArgs)
        gvStudentsBulk.EditIndex = e.NewEditIndex
        BindStudents()
    End Sub

    Protected Sub gvStudentsBulk_RowCancelingEdit(sender As Object, e As GridViewCancelEditEventArgs)
        gvStudentsBulk.EditIndex = -1
        BindStudents()
    End Sub

    Protected Sub gvStudentsBulk_RowUpdating(sender As Object, e As GridViewUpdateEventArgs)
        Dim studentID As Integer = Convert.ToInt32(gvStudentsBulk.DataKeys(e.RowIndex).Value)
        Dim row As GridViewRow = gvStudentsBulk.Rows(e.RowIndex)

        ' Get updated values
        Dim ddlYearLevel As DropDownList = CType(row.FindControl("ddlEditYearLevel"), DropDownList)
        Dim txtSection As TextBox = CType(row.FindControl("txtEditSection"), TextBox)
        Dim ddlStatus As DropDownList = CType(row.FindControl("ddlEditStatus"), DropDownList)
        Dim ddlStudentType As DropDownList = CType(row.FindControl("ddlEditStudentType"), DropDownList) ' Add this

        Dim newYearLevel As String = ddlYearLevel.SelectedValue
        Dim newSection As String = txtSection.Text.Trim()
        Dim newStatus As String = ddlStatus.SelectedValue
        Dim newStudentType As String = ddlStudentType.SelectedValue ' Add this

        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                ' Get the student's course ID
                Dim courseID As Integer = GetStudentCourseID(studentID, conn)

                If courseID > 0 Then
                    ' Get or create the class
                    Dim classID As Integer = GetOrCreateClassID(newYearLevel, newSection, courseID, conn)

                    ' Update the student
                    Using cmd As New MySqlCommand("UPDATE Students SET ClassID = @ClassID, Status = @Status, StudentType = @StudentType WHERE StudentID = @StudentID", conn)
                        cmd.Parameters.AddWithValue("@ClassID", classID)
                        cmd.Parameters.AddWithValue("@Status", newStatus)
                        cmd.Parameters.AddWithValue("@StudentType", newStudentType) ' Add this
                        cmd.Parameters.AddWithValue("@StudentID", studentID)
                        cmd.ExecuteNonQuery()
                    End Using

                    ShowMessage("Student updated successfully!", "success")
                Else
                    ShowMessage("Error: Could not find student course information.", "danger")
                End If
            End Using

            gvStudentsBulk.EditIndex = -1
            BindStudents()
            LoadStatistics()

        Catch ex As Exception
            ShowMessage($"Error updating student: {ex.Message}", "danger")
        End Try
    End Sub

    ' --- Individual Row Deletion ---
    Protected Sub gvStudentsBulk_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        If e.CommandName = "DeleteStudent" Then
            Dim studentID As Integer = Convert.ToInt32(e.CommandArgument)

            Try
                Using conn As New MySqlConnection(ConnString)
                    conn.Open()

                    ' Hard delete the student
                    Using cmd As New MySqlCommand("DELETE FROM Students WHERE StudentID = @StudentID", conn)
                        cmd.Parameters.AddWithValue("@StudentID", studentID)
                        cmd.ExecuteNonQuery()
                    End Using
                End Using

                ShowMessage("Student deleted successfully!", "success")
                BindStudents()
                LoadStatistics()

            Catch ex As Exception
                ShowMessage($"Error deleting student: {ex.Message}", "danger")
            End Try
        End If
    End Sub
    ' Add these methods to your code-behind
    Public Function GetStudentTypeClass(studentType As String) As String
        Select Case studentType?.ToLower()
            Case "regular"
                Return "badge bg-primary"
            Case "irregular"
                Return "badge bg-warning text-dark"
            Case Else
                Return "badge bg-secondary"
        End Select
    End Function

    Public Function GetStudentTypeIcon(studentType As String) As String
        Select Case studentType?.ToLower()
            Case "regular"
                Return "fas fa-user-check"
            Case "irregular"
                Return "fas fa-user-clock"
            Case Else
                Return "fas fa-user"
        End Select
    End Function
    ' --- Bulk Operations ---
    Protected Sub btnBulkUpdate_Click(sender As Object, e As EventArgs) Handles btnBulkUpdate.Click
        SaveCurrentPageSelections()

        If SelectedStudentIDs.Count = 0 Then
            ShowMessage("Please select at least one student.", "warning")
            Return
        End If

        Dim yearLevel As String = ddlYearLevel.SelectedValue
        Dim section As String = txtSection.Text.Trim()
        Dim status As String = ddlNewStatus.SelectedValue
        Dim studentType As String = ddlNewStudentType.SelectedValue ' Add this

        ' Check if at least one field is provided
        If String.IsNullOrEmpty(yearLevel) AndAlso String.IsNullOrEmpty(section) AndAlso String.IsNullOrEmpty(status) AndAlso String.IsNullOrEmpty(studentType) Then
            ShowMessage("Please select at least one field to update.", "warning")
            Return
        End If

        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                For Each studentID As Integer In SelectedStudentIDs
                    ' Get current student data
                    Dim currentData As DataTable = GetStudentData(studentID, conn)
                    If currentData.Rows.Count > 0 Then
                        Dim row As DataRow = currentData.Rows(0)

                        ' Determine new values (use existing if not provided in bulk update)
                        Dim newYearLevel As String = If(Not String.IsNullOrEmpty(yearLevel), yearLevel, row("YearLevel").ToString())
                        Dim newSection As String = If(Not String.IsNullOrEmpty(section), section, row("Section").ToString())
                        Dim newStatus As String = If(Not String.IsNullOrEmpty(status), status, row("Status").ToString())
                        Dim newStudentType As String = If(Not String.IsNullOrEmpty(studentType), studentType, row("StudentType").ToString()) ' Add this
                        Dim courseID As Integer = Convert.ToInt32(row("CourseID"))

                        ' Get or create the class
                        Dim classID As Integer = GetOrCreateClassID(newYearLevel, newSection, courseID, conn)

                        ' Update the student
                        Using cmd As New MySqlCommand("UPDATE Students SET ClassID = @ClassID, Status = @Status, StudentType = @StudentType WHERE StudentID = @StudentID", conn)
                            cmd.Parameters.AddWithValue("@ClassID", classID)
                            cmd.Parameters.AddWithValue("@Status", newStatus)
                            cmd.Parameters.AddWithValue("@StudentType", newStudentType) ' Add this
                            cmd.Parameters.AddWithValue("@StudentID", studentID)
                            cmd.ExecuteNonQuery()
                        End Using
                    End If
                Next

                ShowMessage($"Successfully updated {SelectedStudentIDs.Count} student(s)!", "success")
                BindStudents()
                LoadStatistics()

                ' Clear form
                ddlYearLevel.SelectedIndex = 0
                txtSection.Text = ""
                ddlNewStatus.SelectedIndex = 0
                ddlNewStudentType.SelectedIndex = 0 ' Add this
                SelectedStudentIDs.Clear()
                UpdateSelectedCountDisplay()

            End Using
        Catch ex As Exception
            ShowMessage($"Error updating students: {ex.Message}", "danger")
        End Try
    End Sub

    Protected Sub btnBulkDelete_Click(sender As Object, e As EventArgs) Handles btnBulkDelete.Click
        SaveCurrentPageSelections()

        If SelectedStudentIDs.Count = 0 Then
            ShowMessage("Please select at least one student.", "warning")
            Return
        End If

        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                ' Hard delete students
                For Each studentID As Integer In SelectedStudentIDs
                    Using cmd As New MySqlCommand("DELETE FROM Students WHERE StudentID = @StudentID", conn)
                        cmd.Parameters.AddWithValue("@StudentID", studentID)
                        cmd.ExecuteNonQuery()
                    End Using
                Next

                ShowMessage($"Successfully deleted {SelectedStudentIDs.Count} student(s)!", "success")
                SelectedStudentIDs.Clear()
                BindStudents()
                LoadStatistics()
                UpdateSelectedCountDisplay()

            End Using
        Catch ex As Exception
            ShowMessage($"Error deleting students: {ex.Message}", "danger")
        End Try
    End Sub

    ' --- Helper Methods ---
    Private Function GetStudentCourseID(studentID As Integer, conn As MySqlConnection) As Integer
        Dim sql As String = "SELECT CourseID FROM Students WHERE StudentID = @StudentID"
        Using cmd As New MySqlCommand(sql, conn)
            cmd.Parameters.AddWithValue("@StudentID", studentID)
            Dim result As Object = cmd.ExecuteScalar()
            If result IsNot Nothing AndAlso Not DBNull.Value.Equals(result) Then
                Return Convert.ToInt32(result)
            End If
        End Using
        Return 0
    End Function

    Private Function GetStudentData(studentID As Integer, conn As MySqlConnection) As DataTable
        Dim sql As String = "
        SELECT s.CourseID, cl.YearLevel, cl.Section, s.Status, s.StudentType
        FROM Students s
        INNER JOIN Classes cl ON s.ClassID = cl.ClassID
        WHERE s.StudentID = @StudentID"

        Using cmd As New MySqlCommand(sql, conn)
            cmd.Parameters.AddWithValue("@StudentID", studentID)
            Using da As New MySqlDataAdapter(cmd)
                Dim dt As New DataTable()
                da.Fill(dt)
                Return dt
            End Using
        End Using
    End Function

    Private Function GetOrCreateClassID(yearLevel As String, section As String, courseID As Integer, conn As MySqlConnection) As Integer
        ' Find existing class
        Dim findSQL As String = "SELECT ClassID FROM Classes WHERE YearLevel = @YearLevel AND Section = @Section AND CourseID = @CourseID"
        Using cmd As New MySqlCommand(findSQL, conn)
            cmd.Parameters.AddWithValue("@YearLevel", yearLevel)
            cmd.Parameters.AddWithValue("@Section", section)
            cmd.Parameters.AddWithValue("@CourseID", courseID)
            Dim existingID As Object = cmd.ExecuteScalar()

            If existingID IsNot Nothing AndAlso Not DBNull.Value.Equals(existingID) Then
                Return Convert.ToInt32(existingID)
            End If
        End Using

        ' Create new class
        Dim insertSQL As String = "INSERT INTO Classes (YearLevel, Section, CourseID, IsActive) VALUES (@YearLevel, @Section, @CourseID, 1); SELECT LAST_INSERT_ID();"
        Using cmd As New MySqlCommand(insertSQL, conn)
            cmd.Parameters.AddWithValue("@YearLevel", yearLevel)
            cmd.Parameters.AddWithValue("@Section", section)
            cmd.Parameters.AddWithValue("@CourseID", courseID)
            Return Convert.ToInt32(cmd.ExecuteScalar())
        End Using
    End Function

    ' --- Utility Methods ---
    Private Sub ShowMessage(message As String, messageType As String)
        lblMessage.Text = message
        pnlMessage.Visible = True

        Dim baseClass As String = "mt-3 alert alert-dismissible fade show"

        Select Case messageType.ToLower()
            Case "success"
                pnlMessage.CssClass = $"{baseClass} alert-success"
            Case "warning"
                pnlMessage.CssClass = $"{baseClass} alert-warning"
            Case "danger"
                pnlMessage.CssClass = $"{baseClass} alert-danger"
            Case Else
                pnlMessage.CssClass = $"{baseClass} alert-info"
        End Select

        ' Auto-hide success messages
        If messageType = "success" Then
            ScriptManager.RegisterStartupScript(Me, Me.GetType(), "autoHide",
                "setTimeout(function() { 
                    var alert = document.querySelector('.alert');
                    if(alert) bootstrap.Alert.getOrCreateInstance(alert).close();
                }, 5000);", True)
        End If
    End Sub
End Class