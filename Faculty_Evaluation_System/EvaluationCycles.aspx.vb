Imports MySql.Data.MySqlClient
Imports System.Configuration
Imports System.Web
Imports System.Net.Mail
Imports System.Net

Public Class EvaluationCycles
    Inherits System.Web.UI.Page

    ' Database connection string
    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property
    Private Function GetBaseUrl() As String
        Return "https://madge-intensional-tanna.ngrok-free.dev"
    End Function
    ' Gmail credentials (Use App Password!)
    Private Const SenderEmail As String = "facultyevaluation2025@gmail.com"
    Private Const SenderPassword As String = "hcbc tkss ehtk fzqt"

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            ' Security check
            If Not IsAuthorized() Then
                Response.Redirect("~/Login.aspx", True)
                Return
            End If

            ' Auto deactivate expired cycles
            AutoDeactivateExpiredCycles()

            lblWelcome.Text = HttpUtility.HtmlEncode(Session("FullName"))
            LoadCycles()
            UpdateSidebarBadges()

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
    Private Function IsAuthorized() As Boolean
        Return Session("Role") IsNot Nothing AndAlso Session("Role").ToString() = "Admin"
    End Function

    ' Load all active cycles
    Private Sub LoadCycles()
        Try
            Using conn As New MySqlConnection(ConnString)
                Dim cmd As New MySqlCommand("
                    SELECT CycleID, Term, Status, StartDate, EndDate, CycleName 
                    FROM EvaluationCycles 
                    WHERE IsActive = 1 
                    ORDER BY CycleID DESC", conn)
                Dim da As New MySqlDataAdapter(cmd)
                Dim dt As New DataTable()
                da.Fill(dt)

                gvCycles.DataSource = dt
                gvCycles.DataBind()
                lblCycleCount.Text = dt.Rows.Count.ToString()
            End Using
        Catch ex As Exception
            ShowMessage("❌ Error loading evaluation cycles: " & ex.Message, "danger")
        End Try
    End Sub

    ' Add new cycle
    Protected Sub btnAddCycle_Click(sender As Object, e As EventArgs)
        ' Validate inputs
        If String.IsNullOrWhiteSpace(ddlTerm.SelectedValue) Then
            ShowMessage("⚠ Please select a term.", "warning") : Return
        End If

        If String.IsNullOrWhiteSpace(txtCycleName.Text) Then
            ShowMessage("⚠ Cycle name cannot be empty.", "warning") : Return
        End If

        Dim startDate, endDate As DateTime
        If Not DateTime.TryParse(txtStartDate.Text.Trim(), startDate) OrElse Not DateTime.TryParse(txtEndDate.Text.Trim(), endDate) Then
            ShowMessage("⚠ Invalid start or end date format.", "warning") : Return
        End If

        If startDate >= endDate Then
            ShowMessage("⚠ End date must be after start date.", "warning") : Return
        End If

        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                ' Prevent duplicate cycle names
                Using checkCmd As New MySqlCommand("SELECT COUNT(*) FROM EvaluationCycles WHERE CycleName = @CycleName", conn)
                    checkCmd.Parameters.AddWithValue("@CycleName", txtCycleName.Text.Trim())
                    If Convert.ToInt32(checkCmd.ExecuteScalar()) > 0 Then
                        ShowMessage("⚠ A cycle with this name already exists.", "warning")
                        Return
                    End If
                End Using

                ' Insert new cycle
                Dim sql As String = "
                    INSERT INTO EvaluationCycles (Term, Status, StartDate, EndDate, CycleName, Notified)
                    VALUES (@Term, 'Inactive', @StartDate, @EndDate, @CycleName, 0)"
                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@Term", ddlTerm.SelectedValue)
                    cmd.Parameters.AddWithValue("@CycleName", txtCycleName.Text.Trim())
                    cmd.Parameters.AddWithValue("@StartDate", startDate)
                    cmd.Parameters.AddWithValue("@EndDate", endDate)
                    cmd.ExecuteNonQuery()
                End Using
            End Using

            ShowMessage("✅ New evaluation cycle created successfully!", "success")
            ClearForm()
            LoadCycles()

        Catch ex As Exception
            ShowMessage("❌ Error creating evaluation cycle: " & ex.Message, "danger")
        End Try
    End Sub

    ' GridView command handling
    Protected Sub gvCycles_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        If String.IsNullOrEmpty(e.CommandArgument.ToString()) Then
            ShowMessage("❌ Invalid cycle selection.", "danger") : Return
        End If

        Dim CycleID As Integer = Convert.ToInt32(e.CommandArgument)

        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                Select Case e.CommandName
                    Case "Activate"
                        ActivateCycle(conn, CycleID)
                    Case "Deactivate"
                        DeactivateCycle(conn, CycleID)
                    Case "DeleteCycle"
                        DeleteCycle(conn, CycleID)
                End Select
            End Using

            LoadCycles()
        Catch ex As Exception
            ShowMessage("❌ Error processing request: " & ex.Message, "danger")
        End Try
    End Sub
    Protected Sub gvCycles_RowDataBound(sender As Object, e As GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            ' Add confirmation to delete button
            Dim deleteButton As LinkButton = TryCast(e.Row.FindControl("btnDelete"), LinkButton)
            If deleteButton IsNot Nothing Then
                deleteButton.OnClientClick = "return confirm('Are you sure you want to delete this evaluation cycle? This action cannot be undone.');"
            End If
        End If
    End Sub

    ' ✅ Activate cycle + send email notifications
    Private Sub ActivateCycle(conn As MySqlConnection, cycleId As Integer)
        ' Deactivate all cycles
        Using cmd As New MySqlCommand("UPDATE EvaluationCycles SET Status='Inactive'", conn)
            cmd.ExecuteNonQuery()
        End Using

        ' Activate selected
        Using cmd As New MySqlCommand("UPDATE EvaluationCycles SET Status='Active' WHERE CycleID=@CycleID", conn)
            cmd.Parameters.AddWithValue("@CycleID", cycleId)
            cmd.ExecuteNonQuery()
        End Using

        ' Get cycle info
        Dim cycleName As String = "", term As String = "", notified As Integer = 0
        Using infoCmd As New MySqlCommand("SELECT CycleName, Term, Notified FROM EvaluationCycles WHERE CycleID=@CycleID", conn)
            infoCmd.Parameters.AddWithValue("@CycleID", cycleId)
            Using rdr = infoCmd.ExecuteReader()
                If rdr.Read() Then
                    cycleName = rdr("CycleName").ToString()
                    term = rdr("Term").ToString()
                    notified = Convert.ToInt32(rdr("Notified"))
                End If
            End Using
        End Using

        ' ✅ Only send notifications if not already sent
        If notified = 0 Then
            SendCycleNotifications(conn, cycleId, cycleName, term)

            ' Mark as notified
            Using cmd As New MySqlCommand("UPDATE EvaluationCycles SET Notified=1 WHERE CycleID=@CycleID", conn)
                cmd.Parameters.AddWithValue("@CycleID", cycleId)
                cmd.ExecuteNonQuery()
            End Using
        End If

        ShowMessage("✅ Cycle activated successfully and notifications sent!", "success")
    End Sub

    ' Send emails to Students and Faculty
    Private Sub SendCycleNotifications(conn As MySqlConnection, cycleId As Integer, cycleName As String, term As String)
        Dim baseUrl As String = GetBaseUrl()
        Dim loginUrl As String = baseUrl & "/Login.aspx"

        ' Students - with login link
        Using stuCmd As New MySqlCommand("SELECT Email, 
    CONCAT(LastName, ', ', FirstName, 
        CASE WHEN MiddleInitial IS NOT NULL AND MiddleInitial != '' THEN CONCAT(' ', MiddleInitial, '.') ELSE '' END,
        CASE WHEN Suffix IS NOT NULL AND Suffix != '' THEN CONCAT(' ', Suffix) ELSE '' END
    ) AS FullName 
    FROM Students WHERE Email <> ''", conn)
            Using rdr = stuCmd.ExecuteReader()
                While rdr.Read()
                    Dim email = rdr("Email").ToString()
                    Dim name = rdr("FullName").ToString()
                    Dim subject = "📢 Evaluation Cycle Now Active"
                    Dim body = $"
    Hi {name},<br><br>
    The Faculty Evaluation for <b>{term}</b> (<b>{cycleName}</b>) is now open.<br><br>
    <strong>Please log in to submit your evaluation:</strong><br>
    <a href='{loginUrl}' style='background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 10px 0;'>Login to Evaluation System</a><br><br>
    Or copy and paste this link in your browser:<br>
    <code>{loginUrl}</code><br><br>
    Thank you,<br>
    <b>Faculty Evaluation System</b>"
                    SendEmail(email, subject, body)
                End While
            End Using
        End Using

        ' Faculty - with login link
        Using facCmd As New MySqlCommand("SELECT Email, 
    CONCAT(LastName, ', ', FirstName, 
        CASE WHEN MiddleInitial IS NOT NULL AND MiddleInitial != '' THEN CONCAT(' ', MiddleInitial, '.') ELSE '' END,
        CASE WHEN Suffix IS NOT NULL AND Suffix != '' THEN CONCAT(' ', Suffix) ELSE '' END
    ) AS FullName 
    FROM Users WHERE Role='Faculty' AND Email <> ''", conn)
            Using rdr = facCmd.ExecuteReader()
                While rdr.Read()
                    Dim email = rdr("Email").ToString()
                    Dim name = rdr("FullName").ToString()
                    Dim subject = "📢 Evaluation Cycle Started - Important: Submit Your Grades First"
                    Dim body = $"
    <div style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
        <div style='background: linear-gradient(135deg, #1a3a8f 0%, #2a4aaf 100%); color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0;'>
            <h2>Evaluation Cycle Started</h2>
        </div>
        <div style='padding: 25px; background: #f8f9fc; border-radius: 0 0 5px 5px; border: 1px solid #e3e6f0;'>
            <p>Dear <strong>Prof. {name}</strong>,</p>
            
            <p>The Faculty Evaluation for <strong>{term}</strong> (<strong>{cycleName}</strong>) has started. Students can now evaluate your teaching performance.</p>
            
            <div style='background: #fff3cd; border: 1px solid #ffeaa7; border-left: 4px solid #f39c12; padding: 15px; margin: 20px 0; border-radius: 4px;'>
                <h4 style='color: #856404; margin-top: 0;'>⚠ Important Requirement</h4>
                <p style='margin-bottom: 0;'><strong>Before evaluation results can be released, you must submit ALL student grades for this term.</strong></p>
            </div>
            
            <p><strong>Action Required:</strong></p>
            <ol>
                <li><strong>Submit all student grades</strong> for your assigned subjects</li>
                <li>Ensure all grade submissions are <strong>confirmed</strong> in the system</li>
                <li>Only after all grades are submitted will your evaluation results be released</li>
            </ol>
            
            <div style='text-align: center; margin: 25px 0;'>
                <p><strong>Access the system to submit grades:</strong></p>
                <a href='{loginUrl}' style='background-color: #2196F3; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 10px 0; font-weight: bold; font-size: 16px;'>Submit Grades & Monitor Evaluations</a>
                <p style='margin-top: 10px; font-size: 14px; color: #555;'>
                    Or copy and paste this link in your browser:<br>
                    <code style='background: #e9ecef; padding: 8px 12px; border-radius: 4px;'>{loginUrl}</code>
                </p>
            </div>
            
            <p><strong>Deadline Information:</strong></p>
            <ul>
                <li>Grade submission deadline: Before evaluation results release</li>
                <li>Evaluation period: Students are currently evaluating your courses</li>
                <li>Results release: After all grade submissions are confirmed</li>
            </ul>
            
            <p>If you have any questions about grade submission or the evaluation process, please contact your Department Chair or the Registrar's Office.</p>
            
            <p>Thank you for your cooperation in completing this important academic requirement.</p>
            
            <p>Best regards,<br>
            <strong>Faculty Evaluation Committee</strong><br>
            Golden West Colleges Inc.</p>
        </div>
        <div style='text-align: center; padding: 15px; font-size: 12px; color: #666; background: #e9ecef; border-radius: 0 0 5px 5px;'>
            <p>This is an automated message. Please do not reply to this email.</p>
        </div>
    </div>"
                    SendEmail(email, subject, body)
                End While
            End Using
        End Using

        ' Deans - with login link
        Using deanCmd As New MySqlCommand("SELECT u.Email, 
    CONCAT(u.LastName, ', ', u.FirstName, 
        CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial != '' THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
        CASE WHEN u.Suffix IS NOT NULL AND u.Suffix != '' THEN CONCAT(' ', u.Suffix) ELSE '' END
    ) AS FullName, 
    d.DepartmentName 
    FROM Users u
    INNER JOIN Departments d ON u.DepartmentID = d.DepartmentID
    WHERE u.Role='Dean' AND u.Email <> ''", conn)
            Using rdr = deanCmd.ExecuteReader()
                While rdr.Read()
                    Dim email = rdr("Email").ToString()
                    Dim name = rdr("FullName").ToString()
                    Dim dept = rdr("DepartmentName").ToString()
                    Dim subject = "📢 Evaluation Cycle Activated for Your Department"
                    Dim body = $"
    Hi {name},<br><br>
    The Faculty Evaluation for <b>{term}</b> (<b>{cycleName}</b>) is now active.<br>
    Please monitor the evaluation progress and performance of your department (<b>{dept}</b>).<br><br>
    <strong>Log in to view reports and monitor progress:</strong><br>
    <a href='{loginUrl}' style='background-color: #FF9800; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 10px 0;'>Login to Evaluation System</a><br><br>
    Or copy and paste this link in your browser:<br>
    <code>{loginUrl}</code><br><br>
    Thank you,<br>
    <b>Faculty Evaluation System</b>"
                    SendEmail(email, subject, body)
                End While
            End Using
        End Using
    End Sub

    ' Send email via Gmail SMTP
    Private Sub SendEmail(recipient As String, subject As String, body As String)
        Try
            Dim mail As New MailMessage()
            mail.From = New MailAddress(SenderEmail, "Faculty Evaluation System")
            mail.To.Add(recipient)
            mail.Subject = subject
            mail.Body = body
            mail.IsBodyHtml = True

            Using smtp As New SmtpClient("smtp.gmail.com", 587)
                smtp.Credentials = New NetworkCredential(SenderEmail, SenderPassword)
                smtp.EnableSsl = True
                smtp.Send(mail)
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Email send failed: " & ex.Message)
        End Try
    End Sub

    ' Deactivate cycle
    Private Sub DeactivateCycle(conn As MySqlConnection, cycleId As Integer)
        Using cmd As New MySqlCommand("UPDATE EvaluationCycles SET Status='Inactive' WHERE CycleID=@CycleID", conn)
            cmd.Parameters.AddWithValue("@CycleID", cycleId)
            cmd.ExecuteNonQuery()
        End Using
        ShowMessage("⚠ Cycle deactivated.", "warning")
    End Sub

    ' Delete cycle safely
    Private Sub DeleteCycle(conn As MySqlConnection, cycleId As Integer)
        Dim cycleTerm As String = ""
        Using getCmd As New MySqlCommand("SELECT Term, Status FROM EvaluationCycles WHERE CycleID=@CycleID", conn)
            getCmd.Parameters.AddWithValue("@CycleID", cycleId)
            Using reader As MySqlDataReader = getCmd.ExecuteReader()
                If reader.Read() Then
                    cycleTerm = reader("Term").ToString()
                    If reader("Status").ToString() = "Active" Then
                        ShowMessage("❌ Cannot delete an active cycle. Please deactivate it first.", "danger")
                        Return
                    End If
                End If
            End Using
        End Using

        ' Check evaluations
        Using checkCmd As New MySqlCommand("
            SELECT COUNT(*) FROM EvaluationSubmissions 
            WHERE CycleID=@CycleID", conn)
            checkCmd.Parameters.AddWithValue("@CycleID", cycleId)
            If Convert.ToInt32(checkCmd.ExecuteScalar()) > 0 Then
                ShowMessage("❌ Cannot delete cycle with existing evaluations.", "danger")
                Return
            End If
        End Using

        Using cmd As New MySqlCommand("UPDATE EvaluationCycles SET IsActive=0 WHERE CycleID=@CycleID", conn)
            cmd.Parameters.AddWithValue("@CycleID", cycleId)
            cmd.ExecuteNonQuery()
        End Using

        ShowMessage($"✅ Cycle '{cycleTerm}' deleted successfully!", "success")
    End Sub

    ' Auto-deactivate expired cycles
    Private Sub AutoDeactivateExpiredCycles()
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                Dim sql As String = "UPDATE EvaluationCycles SET Status='Inactive' WHERE Status='Active' AND EndDate < CURDATE()"
                Using cmd As New MySqlCommand(sql, conn)
                    cmd.ExecuteNonQuery()
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Auto-deactivation error: " & ex.Message)
        End Try
    End Sub

    ' UI helpers
    Private Sub ShowMessage(message As String, type As String)
        lblMessage.Text = message
        lblMessage.CssClass = $"alert alert-{type} d-block alert-slide"
        If type = "success" Then
            ScriptManager.RegisterStartupScript(Me, Me.GetType(), "hideAlert",
                $"setTimeout(function() {{ document.getElementById('{lblMessage.ClientID}').classList.add('d-none'); }}, 5000);", True)
        End If
    End Sub

    Private Sub ClearForm()
        ddlTerm.SelectedIndex = 0
        txtCycleName.Text = ""
        txtStartDate.Text = ""
        txtEndDate.Text = ""
    End Sub

    Protected Sub gvCycles_RowDeleting(sender As Object, e As GridViewDeleteEventArgs)
        e.Cancel = True
    End Sub




End Class
