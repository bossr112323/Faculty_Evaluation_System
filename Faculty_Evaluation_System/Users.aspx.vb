Imports System.Configuration
Imports System.Security.Cryptography
Imports System.Text
Imports MySql.Data.MySqlClient
Imports System.Net.Mail
Imports System.IO
Imports System.Text.RegularExpressions

Public Class Users
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    ' Email configuration
    Private ReadOnly Property SmtpServer As String
        Get
            Return ConfigurationManager.AppSettings("SMTPServer")
        End Get
    End Property

    Private ReadOnly Property SmtpPort As Integer
        Get
            Return Integer.Parse(ConfigurationManager.AppSettings("SMTPPort"))
        End Get
    End Property

    Private ReadOnly Property SmtpUsername As String
        Get
            Return ConfigurationManager.AppSettings("SMTPUsername")
        End Get
    End Property

    Private ReadOnly Property SmtpPassword As String
        Get
            Return ConfigurationManager.AppSettings("SMTPPassword")
        End Get
    End Property

    Private ReadOnly Property SmtpEnableSSL As Boolean
        Get
            Return Boolean.Parse(ConfigurationManager.AppSettings("SMTPEnableSSL"))
        End Get
    End Property

    Private ReadOnly Property FromEmail As String
        Get
            Return "facultyevaluation2025@gmail.com"
        End Get
    End Property

    Private ReadOnly Property BaseUrl As String
        Get
            Return "https://madge-intensional-tanna.ngrok-free.dev"
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Session("Role") Is Nothing OrElse Session("Role").ToString() <> "Admin" Then
                Response.Redirect("Login.aspx")
            End If

            lblWelcome.Text = Session("FullName")
            LoadDepartments()
            LoadEditDepartments() ' Load departments for edit modal
            BindAllGrids()
            UpdateSidebarBadges()
        Else
            ' Clear previous messages on postback
            lblMessage.Text = ""
            lblMessage.CssClass = "alert d-none"
        End If
    End Sub

    ' Load departments for edit modal dropdown
    Private Sub LoadEditDepartments()
        Using conn As New MySqlConnection(ConnString)
            Dim cmd As New MySqlCommand("SELECT DepartmentID, DepartmentName FROM Departments WHERE IsActive=1 ORDER BY DepartmentName", conn)
            Dim da As New MySqlDataAdapter(cmd)
            Dim dt As New DataTable()
            da.Fill(dt)

            ddlEditDepartment.DataSource = dt
            ddlEditDepartment.DataTextField = "DepartmentName"
            ddlEditDepartment.DataValueField = "DepartmentID"
            ddlEditDepartment.DataBind()
            ddlEditDepartment.Items.Insert(0, New ListItem("Select Department", ""))
        End Using
    End Sub

#Region "Status Helper Methods"
    Public Function GetStatusBadgeClass(status As String) As String
        Select Case status?.ToLower()
            Case "active"
                Return "bg-success"
            Case "inactive"
                Return "bg-secondary"
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
            Case Else
                Return "bi-question-circle"
        End Select
    End Function

    Public Function GetStatusButtonClass(status As String) As String
        Select Case status?.ToLower()
            Case "active"
                Return "btn btn-sm btn-success"
            Case "inactive"
                Return "btn btn-sm btn-secondary"
            Case Else
                Return "btn btn-sm btn-secondary"
        End Select
    End Function


#End Region

    ' ------------------ Load Departments ------------------
    Private Sub LoadDepartments()
        Using conn As New MySqlConnection(ConnString)
            Dim cmd As New MySqlCommand("SELECT DepartmentID, DepartmentName FROM Departments WHERE IsActive=1 ORDER BY DepartmentName", conn)
            Dim da As New MySqlDataAdapter(cmd)
            Dim dt As New DataTable()
            da.Fill(dt)

            ddlDepartment.DataSource = dt
            ddlDepartment.DataTextField = "DepartmentName"
            ddlDepartment.DataValueField = "DepartmentID"
            ddlDepartment.DataBind()
            ddlDepartment.Items.Insert(0, New ListItem("Select Department", ""))
        End Using
    End Sub

    ' ------------------ Bind All Grids ------------------
    Private Sub BindAllGrids(Optional search As String = "")
        BindGrid(gvFaculty, "Faculty", search)
        BindGrid(gvDean, "Dean", search)
        BindGrid(gvHR, "Admin", search)
        BindGrid(gvRegistrar, "Registrar", search)
    End Sub

    Private Sub BindGrid(grid As GridView, role As String, Optional search As String = "")
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "SELECT u.UserID, u.LastName, u.FirstName, u.MiddleInitial, u.Suffix, u.SchoolID, u.Role, 
                            u.DepartmentID, d.DepartmentName, u.Status, u.Email 
                     FROM Users u 
                     LEFT JOIN Departments d ON u.DepartmentID = d.DepartmentID
                     WHERE u.Role=@Role"

            If Not String.IsNullOrWhiteSpace(search) Then
                sql &= " AND (u.LastName LIKE @Search OR u.FirstName LIKE @Search OR u.SchoolID LIKE @Search OR d.DepartmentName LIKE @Search OR u.Email LIKE @Search)"
            End If
            sql &= " ORDER BY u.LastName, u.FirstName ASC"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@Role", role)
                If Not String.IsNullOrWhiteSpace(search) Then
                    cmd.Parameters.AddWithValue("@Search", "%" & search & "%")
                End If

                Dim da As New MySqlDataAdapter(cmd)
                Dim dt As New DataTable()
                da.Fill(dt)

                ' Hide department column for Admin and Registrar in grid header
                If (grid.ID = "gvHR" OrElse grid.ID = "gvRegistrar") AndAlso dt.Columns.Contains("DepartmentName") Then
                    grid.Columns(7).Visible = False ' Department column index
                End If

                grid.DataSource = dt
                grid.DataBind()
            End Using
        End Using
    End Sub

    ' ------------------ Add User with Auto-Generated Password ------------------
    Protected Sub btnAddUser_Click(sender As Object, e As EventArgs)
        lblModalMessage.Text = ""
        lblModalMessage.CssClass = "alert d-none"

        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "SetKeepModalOpen", "setKeepModalOpen(true);", True)

        ' Validate required fields
        If String.IsNullOrWhiteSpace(txtLastName.Text) OrElse
       String.IsNullOrWhiteSpace(txtFirstName.Text) OrElse
       String.IsNullOrWhiteSpace(txtSchoolID.Text) OrElse
       String.IsNullOrWhiteSpace(ddlRole.SelectedValue) Then

            lblModalMessage.Text = "⚠ Please fill in all required fields."
            lblModalMessage.CssClass = "alert alert-danger d-block"
            Return
        End If

        ' Validate email based on role
        Dim role As String = ddlRole.SelectedValue
        If String.IsNullOrWhiteSpace(txtEmail.Text.Trim()) Then
            lblModalMessage.Text = "⚠ Email is required for all roles."
            lblModalMessage.CssClass = "alert alert-danger d-block"
            Return
        End If

        If Not IsValidEmail(txtEmail.Text.Trim()) Then
            lblModalMessage.Text = "⚠ Please enter a valid email address."
            lblModalMessage.CssClass = "alert alert-danger d-block"
            Return
        End If

        ' Department validation based on role - Only Faculty and Dean require departments
        If (role = "Faculty" OrElse role = "Dean") AndAlso String.IsNullOrWhiteSpace(ddlDepartment.SelectedValue) Then
            lblModalMessage.Text = "⚠ Department is required for " & role & " role."
            lblModalMessage.CssClass = "alert alert-danger d-block"
            Return
        End If

        ' For Admin and Registrar, don't set department
        Dim finalDepartmentID As Object = DBNull.Value
        If role = "Faculty" OrElse role = "Dean" Then
            finalDepartmentID = ddlDepartment.SelectedValue
        End If

        ' Check for duplicate Dean in department
        If role = "Dean" Then
            If CheckDuplicateDean(ddlDepartment.SelectedValue) Then
                lblModalMessage.Text = "⚠ There is already an active Dean in this department. Only one Dean per department is allowed."
                lblModalMessage.CssClass = "alert alert-danger d-block"
                Return
            End If
        End If

        ' Generate random password
        Dim generatedPassword As String = GenerateRandomPassword()

        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Check if user exists (active or inactive)
            Dim checkUserSql As String = "SELECT UserID, Status FROM Users WHERE SchoolID = @SchoolID"
            If Not String.IsNullOrWhiteSpace(txtEmail.Text.Trim()) Then
                checkUserSql &= " OR Email = @Email"
            End If
            checkUserSql &= " LIMIT 1"

            Dim existingUserID As Integer = 0
            Dim existingStatus As String = Nothing

            Using checkCmd As New MySqlCommand(checkUserSql, conn)
                checkCmd.Parameters.AddWithValue("@SchoolID", txtSchoolID.Text.Trim())
                If Not String.IsNullOrWhiteSpace(txtEmail.Text.Trim()) Then
                    checkCmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim())
                End If
                Using reader As MySqlDataReader = checkCmd.ExecuteReader()
                    If reader.Read() Then
                        existingUserID = reader.GetInt32("UserID")
                        existingStatus = reader.GetString("Status")
                    End If
                End Using
            End Using

            If existingUserID > 0 Then
                lblModalMessage.Text = "⚠ User with this School ID or Email already exists."
                lblModalMessage.CssClass = "alert alert-danger d-block"
                Return
            End If

            ' Insert new user
            Dim insertSql As String = "
INSERT INTO Users (LastName, FirstName, MiddleInitial, Suffix, SchoolID, Password, Role, DepartmentID, Email, Status)
VALUES (@LastName, @FirstName, @MiddleInitial, @Suffix, @SchoolID, @Password, @Role, @DepartmentID, @Email, 'Active')"

            Using insertCmd As New MySqlCommand(insertSql, conn)
                insertCmd.Parameters.AddWithValue("@LastName", txtLastName.Text.Trim())
                insertCmd.Parameters.AddWithValue("@FirstName", txtFirstName.Text.Trim())
                insertCmd.Parameters.AddWithValue("@MiddleInitial", If(String.IsNullOrWhiteSpace(txtMiddleInitial.Text), DBNull.Value, txtMiddleInitial.Text.Trim()))
                insertCmd.Parameters.AddWithValue("@Suffix", If(String.IsNullOrWhiteSpace(txtSuffix.Text), DBNull.Value, txtSuffix.Text.Trim()))
                insertCmd.Parameters.AddWithValue("@SchoolID", txtSchoolID.Text.Trim())
                insertCmd.Parameters.AddWithValue("@Password", HashPassword(generatedPassword))
                insertCmd.Parameters.AddWithValue("@Role", role)
                insertCmd.Parameters.AddWithValue("@DepartmentID", finalDepartmentID)
                insertCmd.Parameters.AddWithValue("@Email", If(String.IsNullOrWhiteSpace(txtEmail.Text), DBNull.Value, txtEmail.Text.Trim()))
                insertCmd.ExecuteNonQuery()
            End Using

            ' Send email with credentials
            If SendUserCredentials(txtFirstName.Text.Trim(), txtLastName.Text.Trim(),
                             If(String.IsNullOrWhiteSpace(txtEmail.Text), "", txtEmail.Text.Trim()),
                             txtSchoolID.Text.Trim(), generatedPassword, role) Then

                lblModalMessage.Text = "✅ User added successfully! Login credentials sent to email."
                lblModalMessage.CssClass = "alert alert-success d-block"
                lblMessage.Text = "✅ User added successfully! Credentials emailed."
            Else
                lblModalMessage.Text = "✅ User added but failed to send email. Please contact the user with their credentials."
                lblModalMessage.CssClass = "alert alert-warning d-block"
                lblMessage.Text = "✅ User added (email failed)"
            End If
        End Using

        ClearForm()
        BindAllGrids()

        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "SetKeepModalOpen", "setKeepModalOpen(false);", True)
        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "CloseModal", "closeModal();", True)
    End Sub
    Private Function CheckDuplicateDean(departmentID As String, Optional excludeUserID As String = "") As Boolean
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim sql As String = "SELECT COUNT(*) FROM Users WHERE Role = 'Dean' AND DepartmentID = @DepartmentID AND Status = 'Active'"

            ' Exclude current user if provided
            If Not String.IsNullOrEmpty(excludeUserID) Then
                sql &= " AND UserID <> @ExcludeUserID"
            End If

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@DepartmentID", departmentID)
                If Not String.IsNullOrEmpty(excludeUserID) Then
                    cmd.Parameters.AddWithValue("@ExcludeUserID", excludeUserID)
                End If

                Dim count As Integer = Convert.ToInt32(cmd.ExecuteScalar())
                Return count > 0
            End Using
        End Using
    End Function
    ' ------------------ Import/Export Functionality ------------------
    Protected Sub btnImport_Click(sender As Object, e As EventArgs)
        lblImportMessage.Text = ""
        lblImportMessage.CssClass = "alert d-none"

        Try
            If Not fuImport.HasFile Then
                ShowImportMessage("⚠ Please select a CSV file to upload.", "danger")
                Return
            End If

            Dim fileExtension As String = Path.GetExtension(fuImport.FileName).ToLower()
            If fileExtension <> ".csv" Then
                ShowImportMessage("⚠ Please upload a valid CSV file.", "danger")
                Return
            End If

            If fuImport.PostedFile.ContentLength > 10485760 Then ' 10MB
                ShowImportMessage("⚠ File size exceeds 10MB limit.", "danger")
                Return
            End If

            ' REMOVED: cbSendEmails.Checked parameter - emails are now always sent
            Dim results As ImportResults = ProcessUserCSVFile(fuImport.FileContent)

            ' Show results
            Dim resultMessage As New StringBuilder()
            resultMessage.AppendLine($"✅ CSV Import Completed!")
            resultMessage.AppendLine($"• Successfully processed: {results.ProcessedCount}")
            resultMessage.AppendLine($"• Added: {results.AddedCount}")
            resultMessage.AppendLine($"• Updated: {results.UpdatedCount}")
            resultMessage.AppendLine($"• Skipped: {results.SkippedCount}")

            If results.Errors.Count > 0 Then
                resultMessage.AppendLine($"<br/>❌ Errors:")
                For Each errorItem In results.Errors
                    resultMessage.AppendLine($"• {errorItem}")
                Next
            End If

            ShowImportMessage(resultMessage.ToString(), If(results.Errors.Count > 0, "warning", "success"))
            BindAllGrids()

        Catch ex As Exception
            ShowImportMessage($"❌ Error processing CSV file: {ex.Message}", "danger")
        End Try
    End Sub

    Protected Sub btnExport_Click(sender As Object, e As EventArgs)
        ExportUsersToCSV()
    End Sub

    Private Sub ExportUsersToCSV()
        Response.Clear()
        Response.Buffer = True
        Response.AddHeader("content-disposition", "attachment;filename=Users_Export_" & DateTime.Now.ToString("yyyyMMdd") & ".csv")
        Response.Charset = ""
        Response.ContentType = "application/text"

        Dim csv As New StringBuilder()
        ' Remove Status from headers
        csv.AppendLine("LastName,FirstName,MiddleInitial,Suffix,SchoolID,Email,Role,DepartmentName")

        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            ' Remove Status from SELECT
            Dim sql As String = "SELECT u.LastName, u.FirstName, u.MiddleInitial, u.Suffix, u.SchoolID, u.Email, u.Role, d.DepartmentName 
                            FROM Users u 
                            LEFT JOIN Departments d ON u.DepartmentID = d.DepartmentID 
                            ORDER BY u.Role, u.LastName, u.FirstName"

            Using cmd As New MySqlCommand(sql, conn)
                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    While reader.Read()
                        ' Remove Status from export
                        csv.AppendLine($"""{EscapeCsv(reader("LastName").ToString())}"",""{EscapeCsv(reader("FirstName").ToString())}"",""{EscapeCsv(reader("MiddleInitial").ToString())}"",""{EscapeCsv(reader("Suffix").ToString())}"",""{EscapeCsv(reader("SchoolID").ToString())}"",""{EscapeCsv(reader("Email").ToString())}"",""{EscapeCsv(reader("Role").ToString())}"",""{EscapeCsv(reader("DepartmentName").ToString())}""")
                    End While
                End Using
            End Using
        End Using

        Response.Output.Write(csv.ToString())
        Response.Flush()
        Response.End()
    End Sub

    Private Function ProcessUserCSVFile(fileContent As Stream) As ImportResults
        Dim results As New ImportResults()

        Using reader As New StreamReader(fileContent)
            ' Read header row
            Dim headerLine As String = reader.ReadLine()
            If String.IsNullOrEmpty(headerLine) Then
                results.Errors.Add("CSV file is empty")
                Return results
            End If

            ' Process data rows
            Dim lineNumber As Integer = 1
            While Not reader.EndOfStream
                lineNumber += 1
                Dim dataLine As String = reader.ReadLine()

                If String.IsNullOrWhiteSpace(dataLine) Then Continue While

                Try
                    Dim data As String() = ParseCSVLine(dataLine)

                    ' Changed from 9 to 8 columns since Status was removed
                    If data.Length < 8 Then
                        results.Errors.Add($"Line {lineNumber}: Invalid data format - expected 8 columns, got {data.Length}")
                        results.SkippedCount += 1
                        Continue While
                    End If

                    ' Map CSV data to user fields - Status removed
                    Dim user As New UserData With {
                    .LastName = data(0).Trim(),
                    .FirstName = data(1).Trim(),
                    .MiddleInitial = If(data.Length > 2 AndAlso Not String.IsNullOrEmpty(data(2)), data(2).Trim(), ""),
                    .Suffix = If(data.Length > 3 AndAlso Not String.IsNullOrEmpty(data(3)), data(3).Trim(), ""),
                    .SchoolID = data(4).Trim(),
                    .Email = data(5).Trim(),
                    .Role = data(6).Trim(),
                    .DepartmentName = data(7).Trim()
                }

                    ' Process user record
                    ProcessUserRecord(user, results)

                Catch ex As Exception
                    results.Errors.Add($"Line {lineNumber}: {ex.Message}")
                    results.SkippedCount += 1
                End Try
            End While
        End Using

        Return results
    End Function
    Private Sub ProcessUserRecord(user As UserData, results As ImportResults)
        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Validate role
            Dim validRoles As String() = {"Faculty", "Dean", "Admin", "Registrar"}
            If Not validRoles.Contains(user.Role) Then
                results.Errors.Add($"Invalid role: {user.Role}")
                results.SkippedCount += 1
                Return
            End If

            ' Get DepartmentID if needed
            Dim departmentID As Object = DBNull.Value
            If user.Role <> "Admin" AndAlso user.Role <> "Registrar" Then
                If String.IsNullOrWhiteSpace(user.DepartmentName) Then
                    results.Errors.Add($"Department required for {user.Role} role")
                    results.SkippedCount += 1
                    Return
                End If

                departmentID = GetDepartmentID(conn, user.DepartmentName)
                If departmentID Is Nothing Then
                    results.Errors.Add($"Department not found: {user.DepartmentName}")
                    results.SkippedCount += 1
                    Return
                End If
            End If

            ' Generate password
            Dim generatedPassword As String = GenerateRandomPassword()

            ' Check if user exists
            Dim existingUserID As Integer = GetExistingUserID(conn, user.SchoolID, user.Email)

            If existingUserID > 0 Then
                ' Update existing user
                If UpdateUserFromCSV(conn, existingUserID, user, departmentID) Then
                    results.UpdatedCount += 1
                Else
                    results.Errors.Add($"Failed to update user: {user.SchoolID}")
                    results.SkippedCount += 1
                End If
            Else
                ' Insert new user - ALWAYS send emails for new users
                If InsertUserFromCSV(conn, user, departmentID, generatedPassword) Then
                    ' REMOVED: sendEmails condition - always send emails for new users
                    If Not String.IsNullOrWhiteSpace(user.Email) Then
                        If SendUserCredentials(user.FirstName, user.LastName, user.Email, user.SchoolID, generatedPassword, user.Role) Then
                            results.AddedCount += 1
                        Else
                            results.Errors.Add($"User added but failed to send email: {user.Email}")
                            results.AddedCount += 1
                        End If
                    Else
                        results.AddedCount += 1
                    End If
                Else
                    results.Errors.Add($"Failed to add user: {user.SchoolID}")
                    results.SkippedCount += 1
                End If
            End If

            results.ProcessedCount += 1
        End Using
    End Sub

    ' ------------------ Grid Events ------------------
    Protected Sub gv_PageIndexChanging(sender As Object, e As GridViewPageEventArgs)
        Dim grid As GridView = CType(sender, GridView)
        grid.PageIndex = e.NewPageIndex
        BindAllGrids(ViewState("CurrentSearch"))
    End Sub

    Protected Sub gv_RowEditing(sender As Object, e As GridViewEditEventArgs)
        Dim grid As GridView = CType(sender, GridView)
        grid.EditIndex = e.NewEditIndex
        BindAllGrids(ViewState("CurrentSearch"))
    End Sub

    Protected Sub gv_RowCancelingEdit(sender As Object, e As GridViewCancelEditEventArgs)
        Dim grid As GridView = CType(sender, GridView)
        grid.EditIndex = -1
        BindAllGrids(ViewState("CurrentSearch"))
    End Sub

    Protected Sub gv_RowUpdating(sender As Object, e As GridViewUpdateEventArgs)
        Dim grid As GridView = CType(sender, GridView)
        Dim userID As String = grid.DataKeys(e.RowIndex).Value.ToString()
        Dim row As GridViewRow = grid.Rows(e.RowIndex)

        ' Get the original role from data item
        Dim originalRole As String = grid.DataKeys(e.RowIndex).Values("Role").ToString()

        ' Get values from edit template
        Dim txtEditLastName As TextBox = CType(row.FindControl("txtEditLastName"), TextBox)
        Dim txtEditFirstName As TextBox = CType(row.FindControl("txtEditFirstName"), TextBox)
        Dim txtEditMiddleInitial As TextBox = CType(row.FindControl("txtEditMiddleInitial"), TextBox)
        Dim txtEditSuffix As TextBox = CType(row.FindControl("txtEditSuffix"), TextBox)
        Dim txtEditSchoolID As TextBox = CType(row.FindControl("txtEditSchoolID"), TextBox)
        Dim txtEditEmail As TextBox = CType(row.FindControl("txtEditEmail"), TextBox)
        Dim ddlEditRole As DropDownList = CType(row.FindControl("ddlEditRole"), DropDownList)
        Dim ddlEditDepartment As DropDownList = CType(row.FindControl("ddlEditDepartment"), DropDownList)
        Dim ddlEditStatus As DropDownList = CType(row.FindControl("ddlEditStatus"), DropDownList)

        ' Check if controls were found
        If txtEditLastName Is Nothing OrElse txtEditFirstName Is Nothing OrElse txtEditSchoolID Is Nothing OrElse
   ddlEditStatus Is Nothing Then
            ShowMessage("❌ Error: Could not find form controls. Please try again.", "danger")
            Return
        End If

        Dim lastName As String = txtEditLastName.Text.Trim()
        Dim firstName As String = txtEditFirstName.Text.Trim()
        Dim middleInitial As String = If(txtEditMiddleInitial IsNot Nothing, txtEditMiddleInitial.Text.Trim(), "")
        Dim suffix As String = If(txtEditSuffix IsNot Nothing, txtEditSuffix.Text.Trim(), "")
        Dim newSchoolID As String = txtEditSchoolID.Text.Trim()
        Dim email As String = If(txtEditEmail IsNot Nothing, txtEditEmail.Text.Trim(), "")

        ' For Admin and Registrar, don't allow role change - use original role
        Dim role As String = originalRole
        If ddlEditRole IsNot Nothing AndAlso ddlEditRole.Enabled Then
            role = ddlEditRole.SelectedValue
        End If

        Dim departmentID As String = ""
        If ddlEditDepartment IsNot Nothing AndAlso ddlEditDepartment.Visible Then
            departmentID = ddlEditDepartment.SelectedValue
        End If

        Dim status As String = ddlEditStatus.SelectedValue

        ' Validate required fields
        If String.IsNullOrWhiteSpace(lastName) OrElse String.IsNullOrWhiteSpace(firstName) OrElse
   String.IsNullOrWhiteSpace(newSchoolID) Then
            ShowMessage("⚠ Please fill in all required fields.", "warning")
            Return
        End If

        ' Validate email based on role
        If role <> "Registrar" Then
            If String.IsNullOrWhiteSpace(email) Then
                ShowMessage("⚠ Email is required for " & role & " role.", "warning")
                Return
            End If

            If Not IsValidEmail(email) Then
                ShowMessage("⚠ Please enter a valid email address.", "warning")
                Return
            End If
        Else
            ' For Registrar, validate email only if provided
            If Not String.IsNullOrWhiteSpace(email) AndAlso Not IsValidEmail(email) Then
                ShowMessage("⚠ Please enter a valid email address.", "warning")
                Return
            End If
        End If

        ' Department validation based on role - Only Faculty and Dean require departments
        If (role = "Faculty" OrElse role = "Dean") AndAlso String.IsNullOrWhiteSpace(departmentID) Then
            ShowMessage("⚠ Department is required for " & role & " role.", "warning")
            Return
        End If

        ' For Admin and Registrar, ensure department is cleared
        If (role = "Admin" OrElse role = "Registrar") Then
            departmentID = "" ' Clear department for these roles
        End If

        ' Check for duplicate Dean in department (only if role is being changed to Dean or department is changed for existing Dean)
        If role = "Dean" Then
            Dim originalDeptID As String = ""
            If grid.DataKeys(e.RowIndex).Values("DepartmentID") IsNot Nothing Then
                originalDeptID = grid.DataKeys(e.RowIndex).Values("DepartmentID").ToString()
            End If

            ' Only check for duplicates if:
            ' 1. Role is being changed TO Dean (from another role) OR
            ' 2. User was already a Dean AND department is being changed
            If (originalRole <> "Dean") OrElse (originalRole = "Dean" AndAlso departmentID <> originalDeptID) Then
                ' Pass the current user ID to exclude them from the duplicate check
                If CheckDuplicateDean(departmentID, userID) Then
                    ShowMessage("⚠ There is already an active Dean in this department. Only one Dean per department is allowed.", "warning")
                    Return
                End If
            End If
        End If

        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Check for duplicate SchoolID (excluding current record) and in Students
            Dim checkSql As String = "
SELECT COUNT(*) 
FROM (
    SELECT SchoolID FROM Users WHERE SchoolID=@NewSchoolID AND UserID<>@UserID
    UNION
    SELECT SchoolID FROM Students WHERE SchoolID=@NewSchoolID
) AS dup"

            Using checkCmd As New MySqlCommand(checkSql, conn)
                checkCmd.Parameters.AddWithValue("@NewSchoolID", newSchoolID)
                checkCmd.Parameters.AddWithValue("@UserID", userID)

                Dim exists As Integer = Convert.ToInt32(checkCmd.ExecuteScalar())
                If exists > 0 Then
                    ShowMessage("⚠ This School ID already exists in Users or Students.", "warning")
                    Return
                End If
            End Using

            ' Check for duplicate Email (excluding current user) - only if email is provided
            If Not String.IsNullOrWhiteSpace(email) Then
                Dim checkEmailSql As String = "SELECT COUNT(*) FROM Users WHERE Email=@Email AND UserID<>@UserID"
                Using checkEmailCmd As New MySqlCommand(checkEmailSql, conn)
                    checkEmailCmd.Parameters.AddWithValue("@Email", email)
                    checkEmailCmd.Parameters.AddWithValue("@UserID", userID)

                    Dim emailExists As Integer = Convert.ToInt32(checkEmailCmd.ExecuteScalar())
                    If emailExists > 0 Then
                        ShowMessage("⚠ This Email address already exists in the system.", "warning")
                        Return
                    End If
                End Using
            End If

            ' Update user
            Dim sql As String = "UPDATE Users 
             SET LastName=@LastName, FirstName=@FirstName, MiddleInitial=@MiddleInitial, 
                 Suffix=@Suffix, SchoolID=@NewSchoolID, Role=@Role, 
                 DepartmentID=@DepartmentID, Email=@Email, Status=@Status
             WHERE UserID=@UserID"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@LastName", lastName)
                cmd.Parameters.AddWithValue("@FirstName", firstName)
                cmd.Parameters.AddWithValue("@MiddleInitial", If(String.IsNullOrWhiteSpace(middleInitial), DBNull.Value, middleInitial))
                cmd.Parameters.AddWithValue("@Suffix", If(String.IsNullOrWhiteSpace(suffix), DBNull.Value, suffix))
                cmd.Parameters.AddWithValue("@NewSchoolID", newSchoolID)
                cmd.Parameters.AddWithValue("@Role", role)
                cmd.Parameters.AddWithValue("@DepartmentID", If(String.IsNullOrWhiteSpace(departmentID), DBNull.Value, departmentID))
                cmd.Parameters.AddWithValue("@Email", If(String.IsNullOrWhiteSpace(email), DBNull.Value, email))
                cmd.Parameters.AddWithValue("@Status", status)
                cmd.Parameters.AddWithValue("@UserID", userID)
                cmd.ExecuteNonQuery()
            End Using
        End Using

        grid.EditIndex = -1
        ShowMessage("✅ Update successful!", "success")
        BindAllGrids(ViewState("CurrentSearch"))
    End Sub

    Protected Sub gv_RowDeleting(sender As Object, e As GridViewDeleteEventArgs)
        Dim grid As GridView = CType(sender, GridView)
        Dim userID As String = grid.DataKeys(e.RowIndex).Value.ToString()

        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            ' HARD DELETE - remove user permanently
            Dim sql As String = "DELETE FROM Users WHERE UserID=@UserID"
            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@UserID", userID)
                cmd.ExecuteNonQuery()
            End Using
        End Using

        ShowMessage("✅ User has been permanently deleted.", "success")
        BindAllGrids(ViewState("CurrentSearch"))
    End Sub

    ' Handle Status Toggle
    Protected Sub gv_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        If e.CommandName = "ToggleStatus" Then
            Dim userID As Integer = Convert.ToInt32(e.CommandArgument)
            ToggleUserStatus(userID)
            BindAllGrids(ViewState("CurrentSearch"))
        End If
    End Sub

    Private Sub ToggleUserStatus(userID As Integer)
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim sql As String = "UPDATE Users SET Status = IF(Status='Active','Inactive','Active') WHERE UserID=@UserID"
            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@UserID", userID)
                cmd.ExecuteNonQuery()
            End Using
        End Using
        ShowMessage("✅ User status updated successfully!", "success")
    End Sub

    Protected Sub gv_RowDataBound(sender As Object, e As GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim grid As GridView = CType(sender, GridView)
            Dim currentRole As String = DataBinder.Eval(e.Row.DataItem, "Role").ToString()

            ' Hide department column for Admin and Registrar grids
            If grid.ID = "gvHR" OrElse grid.ID = "gvRegistrar" Then
                If e.Row.Cells.Count > 7 Then
                    e.Row.Cells(7).Visible = False
                End If
            End If

            If (e.Row.RowState And DataControlRowState.Edit) > 0 Then
                ' Apply form-control class to all textboxes in edit mode
                For Each ctrl As Control In e.Row.Cells
                    If TypeOf ctrl Is DataControlFieldCell Then
                        For Each innerCtrl As Control In CType(ctrl, DataControlFieldCell).Controls
                            If TypeOf innerCtrl Is TextBox Then
                                Dim tb As TextBox = CType(innerCtrl, TextBox)
                                tb.CssClass = "form-control"
                            End If
                        Next
                    End If
                Next

                ' Department dropdown - only load for Faculty and Dean
                Dim ddlDept As DropDownList = CType(e.Row.FindControl("ddlEditDepartment"), DropDownList)
                If ddlDept IsNot Nothing Then
                    ' Only load departments for Faculty and Dean roles
                    If currentRole = "Faculty" OrElse currentRole = "Dean" Then
                        Using conn As New MySqlConnection(ConnString)
                            Dim cmd As New MySqlCommand("SELECT DepartmentID, DepartmentName FROM Departments WHERE IsActive=1 ORDER BY DepartmentName", conn)
                            conn.Open()
                            Dim reader As MySqlDataReader = cmd.ExecuteReader()
                            ddlDept.DataSource = reader
                            ddlDept.DataTextField = "DepartmentName"
                            ddlDept.DataValueField = "DepartmentID"
                            ddlDept.DataBind()
                            reader.Close()
                        End Using

                        Dim currentDeptID As String = DataBinder.Eval(e.Row.DataItem, "DepartmentID").ToString()
                        If ddlDept.Items.FindByValue(currentDeptID) IsNot Nothing Then
                            ddlDept.SelectedValue = currentDeptID
                        End If
                    Else
                        ' Hide department dropdown for Admin and Registrar
                        ddlDept.Visible = False
                    End If
                End If

                ' Role dropdown - disable for Admin and Registrar
                Dim ddlRole As DropDownList = CType(e.Row.FindControl("ddlEditRole"), DropDownList)
                If ddlRole IsNot Nothing Then
                    If currentRole = "Admin" OrElse currentRole = "Registrar" Then
                        ddlRole.Enabled = False
                        ddlRole.ToolTip = "Role cannot be changed for " & currentRole & " users"
                    End If

                    ' Set current role as selected
                    If ddlRole.Items.FindByValue(currentRole) IsNot Nothing Then
                        ddlRole.SelectedValue = currentRole
                    End If
                End If

                ' Status dropdown - Always set current status
                Dim ddlStatus As DropDownList = CType(e.Row.FindControl("ddlEditStatus"), DropDownList)
                If ddlStatus IsNot Nothing Then
                    Dim currentStatus As String = DataBinder.Eval(e.Row.DataItem, "Status").ToString()
                    If ddlStatus.Items.FindByValue(currentStatus) IsNot Nothing Then
                        ddlStatus.SelectedValue = currentStatus
                    End If
                End If
            End If
        End If
    End Sub

    ' ------------------ Search ------------------
    Protected Sub btnSearch_Click(sender As Object, e As EventArgs)
        ViewState("CurrentSearch") = txtSearch.Text.Trim()
        BindAllGrids(ViewState("CurrentSearch"))
    End Sub

    ' ------------------ Helper Methods ------------------
    Private Function GenerateRandomPassword() As String
        Const validChars As String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%"
        Dim random As New Random()
        Dim length As Integer = 12
        Dim chars = Enumerable.Repeat(validChars, length).Select(Function(s) s(random.Next(s.Length))).ToArray()
        Return New String(chars)
    End Function

    Private Function HashPassword(password As String) As String
        Using sha256 As SHA256 = SHA256.Create()
            Dim bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password))
            Return BitConverter.ToString(bytes).Replace("-", "").ToLower()
        End Using
    End Function

    Private Function IsValidEmail(email As String) As Boolean
        If String.IsNullOrWhiteSpace(email) Then Return False
        Try
            Dim mailAddress As New MailAddress(email)
            Return True
        Catch
            Return False
        End Try
    End Function

    Private Sub ClearForm()
        txtLastName.Text = ""
        txtFirstName.Text = ""
        txtMiddleInitial.Text = ""
        txtSuffix.Text = ""
        txtSchoolID.Text = ""
        txtEmail.Text = ""
        ddlRole.SelectedIndex = 0
        ddlDepartment.SelectedIndex = 0

        lblModalMessage.Text = ""
        lblModalMessage.CssClass = "alert d-none"

        ' Reset validation styles
        Dim controlsToReset As Control() = {txtLastName, txtFirstName, txtMiddleInitial, txtSuffix, txtSchoolID, txtEmail}
        For Each ctrl As Control In controlsToReset
            If TypeOf ctrl Is TextBox Then
                Dim tb As TextBox = CType(ctrl, TextBox)
                tb.CssClass = tb.CssClass.Replace(" is-invalid", "").Replace(" is-valid", "")
            End If
        Next

        If ddlDepartment IsNot Nothing Then
            ddlDepartment.CssClass = ddlDepartment.CssClass.Replace(" is-invalid", "").Replace(" is-valid", "")
        End If
    End Sub

    Private Sub ShowMessage(msg As String, type As String)
        lblMessage.Text = msg
        lblMessage.CssClass = "alert alert-" & type & " d-block"

        ' Register script to auto-hide after 5 seconds
        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "AutoHideMessage",
                                       "setTimeout(function() { 
                                           var msg = document.getElementById('" & lblMessage.ClientID & "'); 
                                           if(msg) { 
                                               msg.classList.add('d-none'); 
                                               msg.classList.remove('d-block'); 
                                           } 
                                       }, 5000);", True)
    End Sub

    Private Sub ShowImportMessage(message As String, type As String)
        lblImportMessage.Text = message.Replace(vbCrLf, "<br/>")
        lblImportMessage.CssClass = $"alert alert-{type} d-block"
    End Sub

    ' CSV Processing Helpers
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
    Public Function GetStatusToggleConfirmation(status As String) As String
        Dim newStatus As String = If(status.ToLower() = "active", "inactive", "active")
        Return $"return confirm('Are you sure you want to change this user status to {newStatus.ToUpper()}?');"
    End Function
    Private Function EscapeCsv(value As String) As String
        If String.IsNullOrEmpty(value) Then Return ""
        Return value.Replace("""", """""")
    End Function

    Private Function GetDepartmentID(conn As MySqlConnection, departmentName As String) As Object
        Using cmd As New MySqlCommand("SELECT DepartmentID FROM Departments WHERE DepartmentName = @DepartmentName AND IsActive=1", conn)
            cmd.Parameters.AddWithValue("@DepartmentName", departmentName)
            Dim result = cmd.ExecuteScalar()
            Return If(result IsNot Nothing, result, DBNull.Value)
        End Using
    End Function

    Private Function GetExistingUserID(conn As MySqlConnection, schoolID As String, email As String) As Integer
        Using cmd As New MySqlCommand("SELECT UserID FROM Users WHERE SchoolID = @SchoolID OR Email = @Email LIMIT 1", conn)
            cmd.Parameters.AddWithValue("@SchoolID", schoolID)
            cmd.Parameters.AddWithValue("@Email", email)
            Dim result = cmd.ExecuteScalar()
            Return If(result IsNot Nothing, Convert.ToInt32(result), 0)
        End Using
    End Function

    Private Function InsertUserFromCSV(conn As MySqlConnection, user As UserData, departmentID As Object, password As String) As Boolean
        Using cmd As New MySqlCommand("
        INSERT INTO Users (LastName, FirstName, MiddleInitial, Suffix, SchoolID, Email, Password, Role, DepartmentID, Status)
        VALUES (@LastName, @FirstName, @MiddleInitial, @Suffix, @SchoolID, @Email, @Password, @Role, @DepartmentID, 'Active')", conn)

            cmd.Parameters.AddWithValue("@LastName", user.LastName)
            cmd.Parameters.AddWithValue("@FirstName", user.FirstName)
            cmd.Parameters.AddWithValue("@MiddleInitial", If(String.IsNullOrWhiteSpace(user.MiddleInitial), DBNull.Value, user.MiddleInitial))
            cmd.Parameters.AddWithValue("@Suffix", If(String.IsNullOrWhiteSpace(user.Suffix), DBNull.Value, user.Suffix))
            cmd.Parameters.AddWithValue("@SchoolID", user.SchoolID)
            cmd.Parameters.AddWithValue("@Email", If(String.IsNullOrWhiteSpace(user.Email), DBNull.Value, user.Email))
            cmd.Parameters.AddWithValue("@Password", HashPassword(password))
            cmd.Parameters.AddWithValue("@Role", user.Role)
            cmd.Parameters.AddWithValue("@DepartmentID", departmentID)
            ' Status is hardcoded to 'Active' in the SQL query

            Return cmd.ExecuteNonQuery() > 0
        End Using
    End Function

    Private Function UpdateUserFromCSV(conn As MySqlConnection, userID As Integer, user As UserData, departmentID As Object) As Boolean
        Using cmd As New MySqlCommand("
        UPDATE Users 
        SET LastName = @LastName, FirstName = @FirstName, MiddleInitial = @MiddleInitial, Suffix = @Suffix,
            Email = @Email, Role = @Role, DepartmentID = @DepartmentID
        WHERE UserID = @UserID", conn)

            cmd.Parameters.AddWithValue("@LastName", user.LastName)
            cmd.Parameters.AddWithValue("@FirstName", user.FirstName)
            cmd.Parameters.AddWithValue("@MiddleInitial", If(String.IsNullOrWhiteSpace(user.MiddleInitial), DBNull.Value, user.MiddleInitial))
            cmd.Parameters.AddWithValue("@Suffix", If(String.IsNullOrWhiteSpace(user.Suffix), DBNull.Value, user.Suffix))
            cmd.Parameters.AddWithValue("@Email", If(String.IsNullOrWhiteSpace(user.Email), DBNull.Value, user.Email))
            cmd.Parameters.AddWithValue("@Role", user.Role)
            cmd.Parameters.AddWithValue("@DepartmentID", departmentID)
            ' Status removed from UPDATE - keep existing status
            cmd.Parameters.AddWithValue("@UserID", userID)

            Return cmd.ExecuteNonQuery() > 0
        End Using
    End Function

    Private Function SendUserCredentials(firstName As String, lastName As String, email As String, schoolID As String, password As String, role As String) As Boolean
        If String.IsNullOrWhiteSpace(email) Then
            Return False
        End If

        Try
            Using smtpClient As New SmtpClient(SmtpServer)
                smtpClient.Port = SmtpPort
                smtpClient.Credentials = New System.Net.NetworkCredential(SmtpUsername, SmtpPassword)
                smtpClient.EnableSsl = SmtpEnableSSL
                smtpClient.Timeout = 30000 ' 30 seconds timeout

                Dim mailMessage As New MailMessage()
                mailMessage.From = New MailAddress(FromEmail)
                mailMessage.To.Add(email)
                mailMessage.Subject = $"Your {role} Account Credentials - Golden West Colleges"

                Dim emailBody As String = $"
Dear {firstName} {lastName},

Your {role.ToLower()} account has been created successfully.

Here are your login credentials:
• School ID: {schoolID}
• Password: {password}
• Login Portal: {BaseUrl}/Login.aspx
• Role: {role}

Please log in and change your password immediately for security.

Best regards,
Golden West Colleges Administration"

                mailMessage.Body = emailBody
                mailMessage.IsBodyHtml = False

                ' Add error handling for specific SMTP exceptions
                smtpClient.Send(mailMessage)
                Return True
            End Using
        Catch ex As System.Net.Mail.SmtpException
            System.Diagnostics.Debug.WriteLine($"SMTP Error sending email to {email}: {ex.Message} (Status: {ex.StatusCode})")
            Return False
        Catch ex As System.Net.WebException
            System.Diagnostics.Debug.WriteLine($"Network Error sending email to {email}: {ex.Message}")
            Return False
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"General Error sending email to {email}: {ex.Message}")
            Return False
        End Try
    End Function
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
#Region "Supporting Classes"
    Public Class UserData
        Public Property LastName As String
        Public Property FirstName As String
        Public Property MiddleInitial As String
        Public Property Suffix As String
        Public Property SchoolID As String
        Public Property Email As String
        Public Property Role As String
        Public Property DepartmentName As String
        Public Property Status As String
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
    ' ------------------ Modal Edit Methods ------------------
Protected Sub btnEditUser_Click(sender As Object, e As EventArgs)
    Dim userID As Integer = Convert.ToInt32(hfEditUserID.Value)
    LoadUserDataForEdit(userID)
    
    ' Show edit modal
    ScriptManager.RegisterStartupScript(Me, Me.GetType(), "ShowEditModal", "showEditModal();", True)
End Sub

Protected Sub btnUpdateUser_Click(sender As Object, e As EventArgs)
    lblEditMessage.Text = ""
    lblEditMessage.CssClass = "alert d-none"

    Dim userID As Integer = Convert.ToInt32(hfEditUserID.Value)
    
    ' Get values from edit modal
    Dim lastName As String = txtEditLastName.Text.Trim()
    Dim firstName As String = txtEditFirstName.Text.Trim()
    Dim middleInitial As String = txtEditMiddleInitial.Text.Trim()
    Dim suffix As String = txtEditSuffix.Text.Trim()
    Dim schoolID As String = txtEditSchoolID.Text.Trim()
    Dim email As String = txtEditEmail.Text.Trim()
    Dim role As String = ddlEditRole.SelectedValue
    Dim departmentID As String = ddlEditDepartment.SelectedValue
    Dim status As String = ddlEditStatus.SelectedValue

    ' Validate required fields
    If String.IsNullOrWhiteSpace(lastName) OrElse
       String.IsNullOrWhiteSpace(firstName) OrElse
       String.IsNullOrWhiteSpace(schoolID) OrElse
       String.IsNullOrWhiteSpace(role) Then

        lblEditMessage.Text = "⚠ Please fill in all required fields."
        lblEditMessage.CssClass = "alert alert-danger d-block"
        Return
    End If

    ' Validate email - required for ALL roles
    If String.IsNullOrWhiteSpace(email) Then
        lblEditMessage.Text = "⚠ Email is required for all roles."
        lblEditMessage.CssClass = "alert alert-danger d-block"
        Return
    End If

    If Not IsValidEmail(email) Then
        lblEditMessage.Text = "⚠ Please enter a valid email address."
        lblEditMessage.CssClass = "alert alert-danger d-block"
        Return
    End If

    ' Department validation - only required for Faculty and Dean
    If (role = "Faculty" OrElse role = "Dean") AndAlso String.IsNullOrWhiteSpace(departmentID) Then
        lblEditMessage.Text = "⚠ Department is required for " & role & " role."
        lblEditMessage.CssClass = "alert alert-danger d-block"
        Return
    End If

    ' Check for duplicate Dean in department
    If role = "Dean" Then
        If CheckDuplicateDean(departmentID, userID.ToString()) Then
            lblEditMessage.Text = "⚠ There is already an active Dean in this department. Only one Dean per department is allowed."
            lblEditMessage.CssClass = "alert alert-danger d-block"
            Return
        End If
    End If

        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Check for duplicate SchoolID (excluding current record) and in Students
            Dim checkSql As String = "
SELECT COUNT(*) 
FROM (
    SELECT SchoolID FROM Users WHERE SchoolID=@NewSchoolID AND UserID<>@UserID
    UNION
    SELECT SchoolID FROM Students WHERE SchoolID=@NewSchoolID
) AS dup"

            Using checkCmd As New MySqlCommand(checkSql, conn)
                checkCmd.Parameters.AddWithValue("@NewSchoolID", schoolID)
                checkCmd.Parameters.AddWithValue("@UserID", userID)

                Dim exists As Integer = Convert.ToInt32(checkCmd.ExecuteScalar())
                If exists > 0 Then
                    lblEditMessage.Text = "⚠ This School ID already exists in Users or Students."
                    lblEditMessage.CssClass = "alert alert-danger d-block"
                    Return
                End If
            End Using

            ' Check for duplicate Email (excluding current user)
            Dim checkEmailSql As String = "SELECT COUNT(*) FROM Users WHERE Email=@Email AND UserID<>@UserID"
            Using checkEmailCmd As New MySqlCommand(checkEmailSql, conn)
                checkEmailCmd.Parameters.AddWithValue("@Email", email)
                checkEmailCmd.Parameters.AddWithValue("@UserID", userID)

                Dim emailExists As Integer = Convert.ToInt32(checkEmailCmd.ExecuteScalar())
                If emailExists > 0 Then
                    lblEditMessage.Text = "⚠ This Email address already exists in the system."
                    lblEditMessage.CssClass = "alert alert-danger d-block"
                    Return
                End If
            End Using

            ' Update user
            Dim sql As String = "UPDATE Users 
     SET LastName=@LastName, FirstName=@FirstName, MiddleInitial=@MiddleInitial, 
         Suffix=@Suffix, SchoolID=@NewSchoolID, Role=@Role, 
         DepartmentID=@DepartmentID, Email=@Email, Status=@Status
     WHERE UserID=@UserID"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@LastName", lastName)
                cmd.Parameters.AddWithValue("@FirstName", firstName)
                cmd.Parameters.AddWithValue("@MiddleInitial", If(String.IsNullOrWhiteSpace(middleInitial), DBNull.Value, middleInitial))
                cmd.Parameters.AddWithValue("@Suffix", If(String.IsNullOrWhiteSpace(suffix), DBNull.Value, suffix))
                cmd.Parameters.AddWithValue("@NewSchoolID", schoolID)
                cmd.Parameters.AddWithValue("@Role", role)
                ' Set department to NULL for Admin and Registrar roles
                If role = "Admin" OrElse role = "Registrar" Then
                    cmd.Parameters.AddWithValue("@DepartmentID", DBNull.Value)
                Else
                    cmd.Parameters.AddWithValue("@DepartmentID", If(String.IsNullOrWhiteSpace(departmentID), DBNull.Value, departmentID))
                End If
                cmd.Parameters.AddWithValue("@Email", email)
                cmd.Parameters.AddWithValue("@Status", status)
                cmd.Parameters.AddWithValue("@UserID", userID)
                cmd.ExecuteNonQuery()
            End Using
        End Using
        ' Show success message and close modal
        ShowMessage("✅ User updated successfully!", "success")
    BindAllGrids(ViewState("CurrentSearch"))
    
    ScriptManager.RegisterStartupScript(Me, Me.GetType(), "CloseEditModal", "closeEditModal();", True)
End Sub

Private Sub LoadUserDataForEdit(userID As Integer)
    Using conn As New MySqlConnection(ConnString)
        conn.Open()
        Dim sql As String = "SELECT u.*, d.DepartmentName 
                             FROM Users u 
                             LEFT JOIN Departments d ON u.DepartmentID = d.DepartmentID 
                             WHERE u.UserID = @UserID"
        
        Using cmd As New MySqlCommand(sql, conn)
            cmd.Parameters.AddWithValue("@UserID", userID)
            Using reader As MySqlDataReader = cmd.ExecuteReader()
                If reader.Read() Then
                    ' Store UserID in hidden field
                    hfEditUserID.Value = userID.ToString()
                    
                    ' Populate form fields
                    txtEditLastName.Text = reader("LastName").ToString()
                    txtEditFirstName.Text = reader("FirstName").ToString()
                    txtEditMiddleInitial.Text = reader("MiddleInitial").ToString()
                    txtEditSuffix.Text = reader("Suffix").ToString()
                    txtEditSchoolID.Text = reader("SchoolID").ToString()
                    txtEditEmail.Text = reader("Email").ToString()
                    
                    ' Set role
                    If ddlEditRole.Items.FindByValue(reader("Role").ToString()) IsNot Nothing Then
                        ddlEditRole.SelectedValue = reader("Role").ToString()
                    End If
                    
                    ' Set department
                    If Not IsDBNull(reader("DepartmentID")) AndAlso ddlEditDepartment.Items.FindByValue(reader("DepartmentID").ToString()) IsNot Nothing Then
                        ddlEditDepartment.SelectedValue = reader("DepartmentID").ToString()
                    Else
                        ddlEditDepartment.SelectedIndex = 0
                    End If
                    
                    ' Set status
                    If ddlEditStatus.Items.FindByValue(reader("Status").ToString()) IsNot Nothing Then
                        ddlEditStatus.SelectedValue = reader("Status").ToString()
                    End If
                    
                    ' Update UI based on role
                    ScriptManager.RegisterStartupScript(Me, Me.GetType(), "UpdateEditFormRequirements", "updateEditFormRequirements();", True)
                End If
            End Using
        End Using
    End Using
End Sub

End Class

