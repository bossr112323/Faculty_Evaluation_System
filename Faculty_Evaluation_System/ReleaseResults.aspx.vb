Imports System.Configuration
Imports System.Data
Imports MySql.Data.MySqlClient
Imports System.Net.Mail
Imports System.Net

Public Class ReleaseResults
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    ' SMTP configuration properties
    Private ReadOnly Property SmtpServer As String
        Get
            Return If(ConfigurationManager.AppSettings("SMTPServer"), "smtp.gmail.com")
        End Get
    End Property

    Private ReadOnly Property SmtpPort As Integer
        Get
            Dim port As String = ConfigurationManager.AppSettings("SMTPPort")
            Return If(Not String.IsNullOrEmpty(port), Integer.Parse(port), 587)
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
            Dim ssl As String = ConfigurationManager.AppSettings("SMTPEnableSSL")
            Return If(Not String.IsNullOrEmpty(ssl), Boolean.Parse(ssl), True)
        End Get
    End Property

    Private ReadOnly Property FromEmail As String
        Get
            Return If(ConfigurationManager.AppSettings("FromEmail"), "facultyevaluation2025@gmail.com")
        End Get
    End Property

    ' Base URL for the system
    Private Function GetBaseUrl() As String
        Return "https://madge-intensional-tanna.ngrok-free.dev"
    End Function

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsUserAuthorized() Then
            Response.Redirect("~/Login.aspx")
            Return
        End If

        If Not IsPostBack Then
            LoadWelcomeMessage()
            LoadFacultyData()
            UpdateSidebarBadges()
        Else
            ' Update badge on postbacks too
            LoadFacultyData()
        End If
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

                Dim query = "
            SELECT COUNT(DISTINCT fl.FacultyID) as PendingReleaseCount 
            FROM gradesubmissions gs
            INNER JOIN facultyload fl ON gs.LoadID = fl.LoadID
            WHERE gs.CycleID = @CycleID 
            AND gs.Status = 'Confirmed'
            -- Exclude faculty who already have results released
            AND NOT EXISTS (
                SELECT 1 FROM evaluations e
                INNER JOIN facultyload fl2 ON e.LoadID = fl2.LoadID
                WHERE fl2.FacultyID = fl.FacultyID 
                AND e.CycleID = @CycleID 
                AND e.IsReleased = 2
                LIMIT 1
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
        INNER JOIN facultyload fl2 ON e.LoadID = fl2.LoadID
        WHERE fl2.FacultyID = fl.FacultyID 
        AND e.CycleID = @CycleID 
        AND e.IsReleased = 2
        LIMIT 1
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
    Private Function IsUserAuthorized() As Boolean
        If Session("UserID") Is Nothing Then
            Return False
        End If

        Dim userRole As String = If(Session("Role")?.ToString(), "")
        Return userRole = "Admin" OrElse userRole = "HR"
    End Function

    Private Sub LoadWelcomeMessage()
        If Session("FirstName") IsNot Nothing AndAlso Session("LastName") IsNot Nothing Then
            lblWelcome.Text = $"Welcome, {Session("FirstName")} {Session("LastName")}"
        Else
            lblWelcome.Text = Session("FullName")
        End If
    End Sub

    Private Sub LoadFacultyData()
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                Dim cycleID As Integer = GetLatestCycleID(conn)
                If cycleID = 0 Then
                    ShowAlert("No evaluation cycle found.", "warning")
                    pnlNoResults.Visible = True
                    bulkActionsCard.Style("display") = "none"
                    Return
                End If

                ' Get faculty data with release status
                Dim facultyData As DataTable = GetFacultyWithReleaseStatus(conn, cycleID)

                ' Apply search filter if search term exists
                If Not String.IsNullOrEmpty(txtSearch.Text.Trim()) Then
                    facultyData = ApplySearchFilter(facultyData, txtSearch.Text.Trim())
                End If

                ' Update results count
                UpdateResultsCount(facultyData)

                ' Update bulk actions visibility
                UpdateBulkActionsVisibility(facultyData)

                ' Bind to gridview
                If facultyData.Rows.Count > 0 Then
                    gvFaculty.DataSource = facultyData
                    gvFaculty.DataBind()
                    pnlNoResults.Visible = False
                Else
                    gvFaculty.DataSource = Nothing
                    gvFaculty.DataBind()
                    pnlNoResults.Visible = True
                End If
            End Using
        Catch ex As Exception
            ShowAlert($"Error loading faculty data: {ex.Message}", "danger")
            bulkActionsCard.Style("display") = "none"
        End Try
    End Sub

    Private Sub UpdateResultsCount(facultyData As DataTable)
        If facultyData.Rows.Count > 0 Then
            lblResultsCount.Text = $"{facultyData.Rows.Count} faculty found"
        Else
            lblResultsCount.Text = "No faculty found"
        End If
    End Sub

    ' Helper method to generate confirmation script
    Public Function GetConfirmationScript(isReleased As Object, facultyName As Object) As String
        If isReleased Is Nothing OrElse facultyName Is Nothing Then
            Return "return false;"
        End If

        Try
            Dim released As Integer = Convert.ToInt32(isReleased)
            Dim name As String = facultyName.ToString()

            If released = 2 Then
                Return "return confirm('Are you sure you want to revoke results for " & name.Replace("'", "\'") & "?');"
            Else
                Return "return confirm('Are you sure you want to release results to " & name.Replace("'", "\'") & "?');"
            End If
        Catch ex As Exception
            Return "return false;"
        End Try
    End Function

    ' Apply search filter to the data
    Private Function ApplySearchFilter(data As DataTable, searchTerm As String) As DataTable
        If String.IsNullOrEmpty(searchTerm) Then Return data

        searchTerm = searchTerm.ToLower()
        Dim filteredRows = data.AsEnumerable().Where(Function(row)
                                                         Return row.Field(Of String)("FullName").ToLower().Contains(searchTerm) OrElse
                                                                row.Field(Of String)("DepartmentName").ToLower().Contains(searchTerm) OrElse
                                                                row.Field(Of String)("Email").ToLower().Contains(searchTerm) OrElse
                                                                "all grades confirmed".Contains(searchTerm) OrElse
                                                                (If(row("IsReleased") IsNot DBNull.Value,
                                                                    If(Convert.ToInt32(row("IsReleased")) = 0, "ready to release", "released"),
                                                                    "").ToString().ToLower().Contains(searchTerm))
                                                     End Function).ToArray()

        If filteredRows.Length = 0 Then
            Return data.Clone()
        Else
            Return filteredRows.CopyToDataTable()
        End If
    End Function

    Private Function GetLatestCycleID(conn As MySqlConnection) As Integer
        Dim sql As String = "SELECT CycleID FROM evaluationcycles ORDER BY CycleID DESC LIMIT 1"
        Using cmd As New MySqlCommand(sql, conn)
            Dim result = cmd.ExecuteScalar()
            Return If(result IsNot Nothing AndAlso Not IsDBNull(result), Convert.ToInt32(result), 0)
        End Using
    End Function

    Private Function GetFacultyWithReleaseStatus(conn As MySqlConnection, cycleID As Integer) As DataTable
        Dim sql As String = "
        SELECT 
            u.UserID AS FacultyID,
            CONCAT(u.LastName, ', ', u.FirstName,
                   CASE 
                       WHEN u.MiddleInitial IS NOT NULL AND TRIM(u.MiddleInitial) <> '' 
                       THEN CONCAT(' ', u.MiddleInitial, '.') 
                       ELSE '' 
                   END,
                   CASE 
                       WHEN u.Suffix IS NOT NULL AND TRIM(u.Suffix) <> '' 
                       THEN CONCAT(' ', u.Suffix) 
                       ELSE '' 
                   END) AS FullName,
            d.DepartmentName,
            u.Email,
            CASE WHEN EXISTS (
                SELECT 1 FROM evaluations e
                INNER JOIN facultyload fl ON e.LoadID = fl.LoadID
                WHERE fl.FacultyID = u.UserID AND e.CycleID = @CycleID AND e.IsReleased = 2
                LIMIT 1
            ) THEN 2 ELSE 0 END AS IsReleased
        FROM users u
        INNER JOIN departments d ON u.DepartmentID = d.DepartmentID
        WHERE u.Role = 'Faculty' 
        AND u.Status = 'Active'
        AND EXISTS (
            SELECT 1 FROM facultyload fl 
            WHERE fl.FacultyID = u.UserID 
            AND fl.IsDeleted = 0
            AND fl.Term = (SELECT Term FROM evaluationcycles WHERE CycleID = @CycleID)
        )
        -- Only show faculty who have all grade submissions confirmed
        AND (
            SELECT COUNT(*) FROM gradesubmissions gs
            INNER JOIN facultyload fl ON gs.LoadID = fl.LoadID
            WHERE fl.FacultyID = u.UserID AND gs.CycleID = @CycleID AND gs.Status = 'Confirmed'
        ) = (
            SELECT COUNT(*) FROM facultyload fl 
            WHERE fl.FacultyID = u.UserID AND fl.IsDeleted = 0
            AND fl.Term = (SELECT Term FROM evaluationcycles WHERE CycleID = @CycleID)
        )
        ORDER BY u.LastName, u.FirstName"

        Using cmd As New MySqlCommand(sql, conn)
            cmd.Parameters.AddWithValue("@CycleID", cycleID)
            Using da As New MySqlDataAdapter(cmd)
                Dim dt As New DataTable()
                da.Fill(dt)
                Return dt
            End Using
        End Using
    End Function



    Protected Sub rptFaculty_ItemCommand(source As Object, e As System.Web.UI.WebControls.RepeaterCommandEventArgs)
        If String.IsNullOrEmpty(e.CommandName) Then Return

        Dim facultyID As Integer
        If Not Integer.TryParse(e.CommandArgument.ToString(), facultyID) Then
            ShowAlert("Invalid faculty ID.", "danger")
            Return
        End If

        Select Case e.CommandName.ToLower()
            Case "release"
                UpdateReleaseStatus(facultyID, 2, "released")
            Case "revoke"
                UpdateReleaseStatus(facultyID, 0, "revoked")
            Case Else
                ShowAlert("Invalid action requested.", "danger")
                Return
        End Select

        ' Reload data to reflect changes
        LoadFacultyData()
    End Sub

    Private Sub UpdateReleaseStatus(facultyID As Integer, releaseValue As Integer, action As String)
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                Dim cycleID As Integer = GetLatestCycleID(conn)
                If cycleID = 0 Then
                    ShowAlert("No evaluation cycle found.", "warning")
                    Return
                End If

                ' Get faculty info for email
                Dim facultyInfo As DataTable = GetFacultyInfo(conn, facultyID)
                If facultyInfo.Rows.Count = 0 Then
                    ShowAlert("Faculty information not found.", "warning")
                    Return
                End If

                Dim facultyName As String = facultyInfo.Rows(0)("FullName").ToString()
                Dim facultyEmail As String = facultyInfo.Rows(0)("Email").ToString()
                Dim cycleName As String = GetCycleName(conn, cycleID)

                ' Get all load IDs for this faculty in current cycle
                Dim loadIDs As List(Of Integer) = GetFacultyLoadIDs(conn, facultyID, cycleID)

                If loadIDs.Count = 0 Then
                    ShowAlert("No subject loads found for this faculty in latest cycle.", "warning")
                    Return
                End If

                ' Update release status in a transaction
                Using transaction As MySqlTransaction = conn.BeginTransaction()
                    Try
                        For Each loadID As Integer In loadIDs
                            UpdateEvaluationStatus(conn, transaction, cycleID, loadID, releaseValue)
                            UpdateEvaluationSubmissionStatus(conn, transaction, cycleID, loadID, releaseValue)
                        Next

                        transaction.Commit()

                        ' Send email only when releasing
                        If releaseValue = 2 AndAlso Not String.IsNullOrEmpty(facultyEmail) Then
                            If SendResultReleaseEmail(facultyEmail, facultyName, cycleName) Then
                                ShowAlert($"Results successfully {action} for {facultyName}. Email notification sent.", "success")
                            Else
                                ShowAlert($"Results {action} for {facultyName} but email notification failed.", "warning")
                            End If
                        Else
                            ShowAlert($"Results successfully {action} for {facultyName}.", "success")
                        End If

                    Catch ex As Exception
                        transaction.Rollback()
                        Throw New Exception($"Transaction failed: {ex.Message}")
                    End Try
                End Using
            End Using
        Catch ex As Exception
            ShowAlert($"Error updating results: {ex.Message}", "danger")
        End Try
    End Sub

    Private Function GetFacultyInfo(conn As MySqlConnection, facultyID As Integer) As DataTable
        Dim sql As String = "SELECT 
        CONCAT(u.LastName, ', ', u.FirstName,
               CASE 
                   WHEN u.MiddleInitial IS NOT NULL AND TRIM(u.MiddleInitial) <> '' 
                   THEN CONCAT(' ', u.MiddleInitial, '.') 
                   ELSE '' 
               END,
               CASE 
                   WHEN u.Suffix IS NOT NULL AND TRIM(u.Suffix) <> '' 
                   THEN CONCAT(' ', u.Suffix) 
                   ELSE '' 
               END) AS FullName, 
        u.Email 
        FROM users u WHERE u.UserID = @FacultyID"

        Using cmd As New MySqlCommand(sql, conn)
            cmd.Parameters.AddWithValue("@FacultyID", facultyID)
            Using da As New MySqlDataAdapter(cmd)
                Dim dt As New DataTable()
                da.Fill(dt)
                Return dt
            End Using
        End Using
    End Function
    Protected Sub gvFaculty_RowDataBound(sender As Object, e As GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim facultyID = Convert.ToInt32(gvFaculty.DataKeys(e.Row.RowIndex).Value)
            Dim isReleased As Integer = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "IsReleased"))

            ConfigureFacultyRow(e.Row, facultyID, isReleased)
        ElseIf e.Row.RowType = DataControlRowType.Header Then
            ' Add checkall functionality
            Dim chkSelectAll = CType(e.Row.FindControl("chkSelectAll"), CheckBox)
            If chkSelectAll IsNot Nothing Then
                chkSelectAll.Attributes.Add("onclick", "toggleSelectAll(this)")
            End If
        End If
    End Sub



    Private Sub ConfigureFacultyRow(row As GridViewRow, facultyID As Integer, isReleased As Integer)
        ' Configure status badge
        Dim lblStatus = CType(row.FindControl("lblStatus"), Label)

        Select Case isReleased
            Case 2 ' Released
                lblStatus.Text = "RELEASED"
                lblStatus.CssClass = "badge bg-success"
            Case Else ' Ready to release
                lblStatus.Text = "READY"
                lblStatus.CssClass = "badge bg-warning text-dark"
        End Select
    End Sub
    Protected Sub btnLogout_Click(sender As Object, e As EventArgs)
        Session.Clear()
        Session.Abandon()
        Response.Redirect("~/Login.aspx")
    End Sub

    Private Function GetCycleName(conn As MySqlConnection, cycleID As Integer) As String
        Dim sql As String = "SELECT CycleName FROM evaluationcycles WHERE CycleID = @CycleID"
        Using cmd As New MySqlCommand(sql, conn)
            cmd.Parameters.AddWithValue("@CycleID", cycleID)
            Dim result = cmd.ExecuteScalar()
            Return If(result IsNot Nothing AndAlso Not IsDBNull(result), result.ToString(), "Latest Evaluation")
        End Using
    End Function

    Private Function GetFacultyLoadIDs(conn As MySqlConnection, facultyID As Integer, cycleID As Integer) As List(Of Integer)
        Dim loadIDs As New List(Of Integer)()

        Dim sql As String = "
            SELECT fl.LoadID 
            FROM facultyload fl 
            WHERE fl.FacultyID = @FacultyID 
            AND fl.Term = (SELECT Term FROM evaluationcycles WHERE CycleID = @CycleID)
            AND fl.IsDeleted = 0"

        Using cmd As New MySqlCommand(sql, conn)
            cmd.Parameters.AddWithValue("@FacultyID", facultyID)
            cmd.Parameters.AddWithValue("@CycleID", cycleID)

            Using rdr As MySqlDataReader = cmd.ExecuteReader()
                While rdr.Read()
                    loadIDs.Add(Convert.ToInt32(rdr("LoadID")))
                End While
            End Using
        End Using

        Return loadIDs
    End Function

    Private Sub UpdateEvaluationStatus(conn As MySqlConnection, transaction As MySqlTransaction,
                                     cycleID As Integer, loadID As Integer, releaseValue As Integer)
        Dim sql As String = "
            UPDATE evaluations 
            SET IsReleased = @IsReleased
            WHERE CycleID = @CycleID 
            AND LoadID = @LoadID"

        Using cmd As New MySqlCommand(sql, conn, transaction)
            cmd.Parameters.AddWithValue("@CycleID", cycleID)
            cmd.Parameters.AddWithValue("@LoadID", loadID)
            cmd.Parameters.AddWithValue("@IsReleased", releaseValue)
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Private Sub UpdateEvaluationSubmissionStatus(conn As MySqlConnection, transaction As MySqlTransaction,
                                               cycleID As Integer, loadID As Integer, releaseValue As Integer)
        Dim sql As String = "
            UPDATE evaluationsubmissions 
            SET IsReleased = @IsReleased
            WHERE CycleID = @CycleID 
            AND LoadID = @LoadID"

        Using cmd As New MySqlCommand(sql, conn, transaction)
            cmd.Parameters.AddWithValue("@CycleID", cycleID)
            cmd.Parameters.AddWithValue("@LoadID", loadID)
            cmd.Parameters.AddWithValue("@IsReleased", releaseValue)
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Private Function SendResultReleaseEmail(facultyEmail As String, facultyName As String, cycleName As String) As Boolean
        Try
            ' Validate SMTP configuration
            If String.IsNullOrEmpty(SmtpServer) OrElse String.IsNullOrEmpty(SmtpUsername) OrElse String.IsNullOrEmpty(SmtpPassword) Then
                System.Diagnostics.Debug.WriteLine("SMTP configuration missing")
                Return False
            End If

            Using smtpClient As New SmtpClient(SmtpServer, SmtpPort)
                smtpClient.Credentials = New NetworkCredential(SmtpUsername, SmtpPassword)
                smtpClient.EnableSsl = SmtpEnableSSL
                smtpClient.Timeout = 10000 ' 10 seconds timeout

                Using mailMessage As New MailMessage()
                    mailMessage.From = New MailAddress(FromEmail, "Golden West Colleges - Evaluation System")
                    mailMessage.To.Add(facultyEmail)
                    mailMessage.Subject = $"Faculty Evaluation Results Released - {cycleName}"
                    mailMessage.IsBodyHtml = True

                    ' Email body
                    mailMessage.Body = CreateEmailBody(facultyName, cycleName)

                    smtpClient.Send(mailMessage)
                    Return True
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"Email sending failed: {ex.Message}")
            Return False
        End Try
    End Function

    Private Function CreateEmailBody(facultyName As String, cycleName As String) As String
        Dim baseUrl As String = GetBaseUrl()
        Return $"
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: 'Segoe UI', Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }}
                .container {{ max-width: 600px; margin: 0 auto; background: #ffffff; }}
                .header {{ background: linear-gradient(135deg, #1a3a8f 0%, #2a4aaf 100%); color: white; padding: 30px 20px; text-align: center; }}
                .content {{ padding: 30px; background: #f8f9fc; }}
                .footer {{ text-align: center; padding: 20px; font-size: 12px; color: #666; background: #e9ecef; }}
                .button {{ display: inline-block; padding: 12px 30px; background: #1a3a8f; color: white; text-decoration: none; border-radius: 5px; margin: 15px 0; font-weight: bold; }}
                .features {{ background: white; padding: 20px; border-radius: 5px; margin: 20px 0; border-left: 4px solid #d4af37; }}
                .login-link {{ text-align: center; margin: 25px 0; }}
                .system-url {{ background: #e9ecef; padding: 10px; border-radius: 4px; font-family: monospace; margin: 10px 0; text-align: center; }}
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'>
                    <h1>Evaluation Results Available</h1>
                    <p>Golden West Colleges - Faculty Evaluation System</p>
                </div>
                <div class='content'>
                    <p>Dear <strong> {facultyName}</strong>,</p>
                    
                    <p>Your faculty evaluation results for <strong>{cycleName}</strong> have been released and are now available for viewing in the Faculty Evaluation System.</p>
                    
                    <div class='features'>
                        <p><strong>Your evaluation report includes:</strong></p>
                        <ul>
                            <li>Overall performance score and rating</li>
                            <li>Detailed breakdown by evaluation domains</li>
                            <li>Student feedback and comments</li>
                            <li>Comparative analysis with department averages</li>
                            <li>Professional development insights</li>
                        </ul>
                    </div>
                    
                    <div class='login-link'>
                        <p><strong>Access Your Results:</strong></p>
                        <a href='{baseUrl}/Login.aspx' class='button'>View My Evaluation Results</a>
                        <p style='margin-top: 10px; font-size: 14px; color: #555;'>
                            Or copy and paste this link in your browser:<br>
                            <span class='system-url'>{baseUrl}/Login.aspx</span>
                        </p>
                    </div>
                    
                    <p><strong>To access your results:</strong></p>
                    <ol>
                        <li>Click the button above or visit: <strong>{baseUrl}</strong></li>
                        <li>Log in with your faculty credentials</li>
                        <li>Navigate to the 'My Evaluations' or 'Results' section</li>
                        <li>Select '{cycleName}' to view your detailed report</li>
                    </ol>
                    
                    <p>We encourage you to review your results carefully and reflect on the feedback provided by your students. This evaluation is designed to support your continuous professional growth and teaching excellence.</p>
                    
                    <p>If you have any questions or would like to discuss your evaluation results, please contact the Admin.</p>
                    
                    <p>If you encounter any technical issues accessing the system, please contact Admin.</p>
                    
                    <p>Thank you for your dedication to our students and institution.</p>
                    
                    <p>Best regards,<br>
                    <strong>Faculty Evaluation Committee</strong><br>
                    Golden West Colleges</p>
                </div>
                <div class='footer'>
                    <p>This is an automated notification. Please do not reply to this email.</p>
                    <p>&copy; {DateTime.Now.Year} Golden West Colleges. All rights reserved.</p>
                </div>
            </div>
        </body>
        </html>"
    End Function

    Private Sub ShowAlert(message As String, type As String)
        lblAlert.Text = message
        lblAlert.CssClass = $"alert alert-{type} alert-dismissible fade show"

        ' Auto-hide success messages after 5 seconds
        If type = "success" Then
            ScriptManager.RegisterStartupScript(Me, Me.GetType(), "AutoHideAlert",
                "setTimeout(function() { 
                    var alert = document.querySelector('.alert');
                    if(alert) alert.classList.add('d-none');
                 }, 5000);", True)
        End If
    End Sub

    ' Search button click handler
    Protected Sub btnSearch_Click(sender As Object, e As EventArgs)
        LoadFacultyData()
    End Sub

    ' Get ready count for AJAX updates
    Public Function GetReadyCount() As Integer
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                Dim cycleID As Integer = GetLatestCycleID(conn)
                If cycleID = 0 Then Return 0

                Dim facultyData As DataTable = GetFacultyWithReleaseStatus(conn, cycleID)
                If facultyData.Rows.Count = 0 Then Return 0

                Dim readyCount As Integer = 0
                For Each row As DataRow In facultyData.Rows
                    If Convert.ToInt32(row("IsReleased")) = 0 Then
                        readyCount += 1
                    End If
                Next

                Return readyCount
            End Using
        Catch ex As Exception
            Return 0
        End Try
    End Function

    ' Update the LoadFacultyData method to show/hide bulk actions
    Private Sub UpdateBulkActionsVisibility(facultyData As DataTable)
        If facultyData Is Nothing OrElse facultyData.Rows.Count = 0 Then
            bulkActionsCard.Style("display") = "none"
            Return
        End If

        ' Show bulk actions if there are any faculty (ready to release OR released)
        ' This allows users to both release and revoke results
        bulkActionsCard.Style("display") = "block"
    End Sub

    ' Bulk release selected faculty
    Protected Sub btnReleaseSelected_Click(sender As Object, e As EventArgs)
        ' Get selected faculty IDs from form request
        Dim selectedIDs As List(Of Integer) = GetSelectedFacultyIDsFromRequest()

        If selectedIDs.Count = 0 Then
            ShowAlert("Please select at least one faculty member to release results.", "warning")
            Return
        End If

        BulkUpdateReleaseStatus(selectedIDs, 2, "released")
    End Sub

    ' Bulk revoke selected faculty
    Protected Sub btnRevokeSelected_Click(sender As Object, e As EventArgs)
        ' Get selected faculty IDs from form request
        Dim selectedIDs As List(Of Integer) = GetSelectedFacultyIDsFromRequest()

        If selectedIDs.Count = 0 Then
            ShowAlert("Please select at least one faculty member to revoke results.", "warning")
            Return
        End If

        BulkUpdateReleaseStatus(selectedIDs, 0, "revoked")
    End Sub

    ' Helper method to get selected faculty IDs from form request
    Private Function GetSelectedFacultyIDsFromRequest() As List(Of Integer)
        Dim selectedIDs As New List(Of Integer)()

        ' Get all faculty IDs from the form
        For Each key As String In Request.Form.AllKeys
            If key.StartsWith("chkFaculty_") Then
                Dim facultyID As Integer
                If Integer.TryParse(Request.Form(key), facultyID) Then
                    selectedIDs.Add(facultyID)
                End If
            End If
        Next

        Return selectedIDs
    End Function

    ' Bulk update release status for multiple faculty
    Private Sub BulkUpdateReleaseStatus(facultyIDs As List(Of Integer), releaseValue As Integer, action As String)
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                Dim cycleID As Integer = GetLatestCycleID(conn)
                If cycleID = 0 Then
                    ShowAlert("No evaluation cycle found.", "warning")
                    Return
                End If

                Dim successCount As Integer = 0
                Dim emailCount As Integer = 0
                Dim facultyNames As New List(Of String)()

                Using transaction As MySqlTransaction = conn.BeginTransaction()
                    Try
                        For Each facultyID As Integer In facultyIDs
                            ' Get faculty info
                            Dim facultyInfo As DataTable = GetFacultyInfo(conn, facultyID)
                            If facultyInfo.Rows.Count = 0 Then Continue For

                            Dim facultyName As String = facultyInfo.Rows(0)("FullName").ToString()
                            Dim facultyEmail As String = facultyInfo.Rows(0)("Email").ToString()
                            Dim cycleName As String = GetCycleName(conn, cycleID)

                            ' Get all load IDs for this faculty in current cycle
                            Dim loadIDs As List(Of Integer) = GetFacultyLoadIDs(conn, facultyID, cycleID)

                            If loadIDs.Count = 0 Then Continue For

                            ' Update release status
                            For Each loadID As Integer In loadIDs
                                UpdateEvaluationStatus(conn, transaction, cycleID, loadID, releaseValue)
                                UpdateEvaluationSubmissionStatus(conn, transaction, cycleID, loadID, releaseValue)
                            Next

                            facultyNames.Add(facultyName)
                            successCount += 1

                            ' Send email only when releasing
                            If releaseValue = 2 AndAlso Not String.IsNullOrEmpty(facultyEmail) Then
                                If SendResultReleaseEmail(facultyEmail, facultyName, cycleName) Then
                                    emailCount += 1
                                End If
                            End If
                        Next

                        transaction.Commit()

                        ' Show summary message
                        Dim namesList As String = String.Join(", ", facultyNames.Take(3))
                        If facultyNames.Count > 3 Then
                            namesList &= $" and {facultyNames.Count - 3} others"
                        End If

                        If releaseValue = 2 Then
                            If emailCount = successCount Then
                                ShowAlert($"Results successfully released for {successCount} faculty members ({namesList}). All email notifications sent.", "success")
                            ElseIf emailCount > 0 Then
                                ShowAlert($"Results released for {successCount} faculty members ({namesList}). {emailCount} email notifications sent, {successCount - emailCount} failed.", "warning")
                            Else
                                ShowAlert($"Results released for {successCount} faculty members ({namesList}) but email notifications failed.", "warning")
                            End If
                        Else
                            ShowAlert($"Results successfully revoked for {successCount} faculty members ({namesList}).", "success")
                        End If

                    Catch ex As Exception
                        transaction.Rollback()
                        Throw New Exception($"Bulk update transaction failed: {ex.Message}")
                    End Try
                End Using

                ' Reload data to reflect changes
                LoadFacultyData()
            End Using
        Catch ex As Exception
            ShowAlert($"Error during bulk update: {ex.Message}", "danger")
        End Try
    End Sub
    Protected Sub gvFaculty_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        If String.IsNullOrEmpty(e.CommandName) Then Return

        Dim facultyID As Integer
        If Not Integer.TryParse(e.CommandArgument.ToString(), facultyID) Then
            ShowAlert("Invalid faculty ID.", "danger")
            Return
        End If

        Select Case e.CommandName.ToLower()
            Case "release"
                UpdateReleaseStatus(facultyID, 2, "released")
            Case "revoke"
                UpdateReleaseStatus(facultyID, 0, "revoked")
            Case Else
                ShowAlert("Invalid action requested.", "danger")
                Return
        End Select

        ' Reload data to reflect changes
        LoadFacultyData()
    End Sub
End Class




