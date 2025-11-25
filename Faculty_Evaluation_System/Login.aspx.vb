Imports MySql.Data.MySqlClient
Imports System.Security.Cryptography
Imports System.Text
Imports System.Net.Mail

Public Class Login
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return System.Configuration.ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    Private Const MaxAttempts As Integer = 6
    Private Const LockoutMinutes As Integer = 5

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Session("LoginAttempts") Is Nothing Then Session("LoginAttempts") = 0

            ' Redirect logged-in users (skip OTP if already verified or not first login)
            If Session("UserID") IsNot Nothing AndAlso Session("Role") IsNot Nothing Then
                If Session("OTPVerified") IsNot Nothing AndAlso CBool(Session("OTPVerified")) Then
                    RedirectByRole(Session("Role").ToString())
                ElseIf Session("FirstLoginCompleted") IsNot Nothing AndAlso CBool(Session("FirstLoginCompleted")) Then
                    ' User has completed first login before, no OTP needed
                    RedirectByRole(Session("Role").ToString())
                End If
            End If

            Response.Cache.SetCacheability(HttpCacheability.NoCache)
            Response.Cache.SetExpires(DateTime.UtcNow.AddHours(-1))
            Response.Cache.SetNoStore()
        End If
    End Sub

    Protected Sub btnLogin_Click(ByVal sender As Object, ByVal e As EventArgs)
        lblMsg.Text = ""
        lblMsg.CssClass = ""

        ' Check lockout
        If Session("LockoutTime") IsNot Nothing Then
            Dim lockoutTime As DateTime = CType(Session("LockoutTime"), DateTime)
            If DateTime.Now < lockoutTime Then
                Dim remaining As TimeSpan = lockoutTime - DateTime.Now
                lblMsg.Text = $"❌ Too many failed attempts. Please wait {remaining.Minutes}m {remaining.Seconds}s."
                lblMsg.CssClass = "alert alert-danger d-block"
                Return
            Else
                ' Lockout expired
                Session("LoginAttempts") = 0
                Session("LockoutTime") = Nothing
            End If
        End If

        Dim schoolID As String = txtSchoolID.Text.Trim()
        Dim pwd As String = txtPassword.Text.Trim()

        If String.IsNullOrEmpty(schoolID) OrElse String.IsNullOrEmpty(pwd) Then
            lblMsg.Text = "⚠ Please enter School ID and Password."
            lblMsg.CssClass = "alert alert-warning d-block"
            Return
        End If

        If pwd.Length < 8 Then
            lblMsg.Text = "⚠ Password must be at least 8 characters."
            lblMsg.CssClass = "alert alert-warning d-block"
            Return
        End If

        Dim hashedPwd As String = HashPassword(pwd)

        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                ' Check Students
                Dim sqlStudent As String = "
                    SELECT StudentID, LastName, FirstName, MiddleInitial, Suffix, DepartmentID, CourseID, ClassID, Status, Email, FirstLogin
                    FROM Students
                    WHERE SchoolID=@sid AND Password=@pwd
                    LIMIT 1"
                Using cmd As New MySqlCommand(sqlStudent, conn)
                    cmd.Parameters.AddWithValue("@sid", schoolID)
                    cmd.Parameters.AddWithValue("@pwd", hashedPwd)

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        If rdr.Read() Then
                            If Not rdr("Status").ToString().Equals("Active", StringComparison.OrdinalIgnoreCase) Then
                                lblMsg.Text = "⚠ Account inactive. Contact HR/Admin."
                                lblMsg.CssClass = "alert alert-danger d-block"
                                Return
                            End If

                            ' Reset attempts
                            Session("LoginAttempts") = 0
                            Session("LockoutTime") = Nothing

                            ' Build full name from components
                            Dim fullName As String = BuildFullName(
                                rdr("LastName").ToString(),
                                rdr("FirstName").ToString(),
                                If(IsDBNull(rdr("MiddleInitial")), "", rdr("MiddleInitial").ToString()),
                                If(IsDBNull(rdr("Suffix")), "", rdr("Suffix").ToString())
                            )

                            ' Get email and first login status
                            Dim userEmail As String = ""
                            If Not IsDBNull(rdr("Email")) Then
                                userEmail = rdr("Email").ToString()
                            End If

                            Dim firstLogin As Boolean = True
                            If Not IsDBNull(rdr("FirstLogin")) Then
                                firstLogin = Convert.ToBoolean(rdr("FirstLogin"))
                            End If

                            ' Store session
                            Session("TempUserID") = rdr("StudentID").ToString()
                            Session("TempSchoolID") = schoolID
                            Session("TempFullName") = fullName
                            Session("TempRole") = "Student"
                            Session("TempDepartmentID") = If(IsDBNull(rdr("DepartmentID")), "", rdr("DepartmentID").ToString())
                            Session("TempCourseID") = If(IsDBNull(rdr("CourseID")), "", rdr("CourseID").ToString())
                            Session("TempClassID") = If(IsDBNull(rdr("ClassID")), "", rdr("ClassID").ToString())
                            Session("TempEmail") = userEmail
                            Session("TempFirstLogin") = firstLogin
                            Session("OTPVerified") = False

                            If firstLogin Then
                                ' First time login - require OTP
                                If SendOTP(userEmail, fullName) Then
                                    Response.Redirect("OTPVerification.aspx", False)
                                Else
                                    lblMsg.Text = "⚠ Failed to send OTP. Please try again or contact administrator."
                                    lblMsg.CssClass = "alert alert-danger d-block"
                                End If
                            Else
                                ' Not first login - proceed directly
                                SetUserSessionAndRedirect("Student", rdr("StudentID").ToString(), schoolID, fullName,
                                                       If(IsDBNull(rdr("DepartmentID")), "", rdr("DepartmentID").ToString()),
                                                       If(IsDBNull(rdr("CourseID")), "", rdr("CourseID").ToString()),
                                                       If(IsDBNull(rdr("ClassID")), "", rdr("ClassID").ToString()),
                                                       userEmail)
                            End If
                            Return
                        End If
                    End Using
                End Using

                ' Check Users (Faculty, Dean, HR) with separate name fields
                Dim sqlUser As String = "
                    SELECT u.UserID, u.LastName, u.FirstName, u.MiddleInitial, u.Suffix, u.Role, 
                           u.DepartmentID, d.DepartmentName, u.Status, u.Email, u.FirstLogin
                    FROM Users u
                    LEFT JOIN Departments d ON u.DepartmentID = d.DepartmentID
                    WHERE u.SchoolID=@sid AND u.Password=@pwd
                    LIMIT 1"
                Using cmd As New MySqlCommand(sqlUser, conn)
                    cmd.Parameters.AddWithValue("@sid", schoolID)
                    cmd.Parameters.AddWithValue("@pwd", hashedPwd)

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        If rdr.Read() Then
                            If Not rdr("Status").ToString().Equals("Active", StringComparison.OrdinalIgnoreCase) Then
                                lblMsg.Text = "⚠ Account inactive. Contact Admin."
                                lblMsg.CssClass = "alert alert-danger d-block"
                                Return
                            End If

                            ' Reset attempts
                            Session("LoginAttempts") = 0
                            Session("LockoutTime") = Nothing

                            ' Build full name from components
                            Dim fullName As String = BuildFullName(
                                rdr("LastName").ToString(),
                                rdr("FirstName").ToString(),
                                If(IsDBNull(rdr("MiddleInitial")), "", rdr("MiddleInitial").ToString()),
                                If(IsDBNull(rdr("Suffix")), "", rdr("Suffix").ToString())
                            )

                            ' Get email and first login status
                            Dim userEmail As String = ""
                            If Not IsDBNull(rdr("Email")) Then
                                userEmail = rdr("Email").ToString()
                            End If

                            Dim firstLogin As Boolean = True
                            If Not IsDBNull(rdr("FirstLogin")) Then
                                firstLogin = Convert.ToBoolean(rdr("FirstLogin"))
                            End If

                            ' Store session
                            Session("TempUserID") = rdr("UserID").ToString()
                            Session("TempSchoolID") = schoolID
                            Session("TempFullName") = fullName
                            Session("TempRole") = rdr("Role").ToString()
                            Session("TempDepartmentID") = If(IsDBNull(rdr("DepartmentID")), "", rdr("DepartmentID").ToString())
                            Session("TempDepartmentName") = If(IsDBNull(rdr("DepartmentName")), "", rdr("DepartmentName").ToString())
                            Session("TempEmail") = userEmail
                            Session("TempFirstLogin") = firstLogin
                            Session("OTPVerified") = False

                            If firstLogin Then
                                ' First time login - require OTP
                                If SendOTP(userEmail, fullName) Then
                                    Response.Redirect("OTPVerification.aspx", False)
                                Else
                                    lblMsg.Text = "⚠ Failed to send OTP. Please try again or contact administrator."
                                    lblMsg.CssClass = "alert alert-danger d-block"
                                End If
                            Else
                                ' Not first login - proceed directly
                                SetUserSessionAndRedirect(rdr("Role").ToString(), rdr("UserID").ToString(), schoolID, fullName,
                                                       If(IsDBNull(rdr("DepartmentID")), "", rdr("DepartmentID").ToString()),
                                                       "", "", userEmail)
                            End If
                            Return
                        End If
                    End Using
                End Using
            End Using

            ' Failed login attempt
            Session("LoginAttempts") = Convert.ToInt32(Session("LoginAttempts")) + 1
            Dim remainingAttempts As Integer = MaxAttempts - Convert.ToInt32(Session("LoginAttempts"))

            If remainingAttempts <= 0 Then
                Session("LockoutTime") = DateTime.Now.AddMinutes(LockoutMinutes)
                lblMsg.Text = $"❌ Too many failed attempts. Login disabled for {LockoutMinutes} minutes."
            Else
                lblMsg.Text = $"❌ Invalid School ID or Password. {remainingAttempts} attempt(s) left."
            End If
            lblMsg.CssClass = "alert alert-danger d-block"
            txtPassword.Text = ""

        Catch ex As Exception
            lblMsg.Text = "⚠ Login failed: " & ex.Message
            lblMsg.CssClass = "alert alert-danger d-block"
        End Try
    End Sub

    ' Set user session and redirect (for non-first-time logins)
    Private Sub SetUserSessionAndRedirect(role As String, userID As String, schoolID As String, fullName As String,
                                       departmentID As String, courseID As String, classID As String, email As String)
        Session("UserID") = userID
        Session("SchoolID") = schoolID
        Session("FullName") = fullName
        Session("Role") = role
        Session("DepartmentID") = departmentID
        Session("CourseID") = courseID
        Session("ClassID") = classID
        Session("Email") = email
        Session("OTPVerified") = True
        Session("FirstLoginCompleted") = True

        RedirectByRole(role)
    End Sub

    ' Generate and send OTP (only for first-time login)
    Private Function SendOTP(email As String, fullName As String) As Boolean
        Try
            If String.IsNullOrEmpty(email) Then
                Return False
            End If

            ' Generate 6-digit OTP
            Dim random As New Random()
            Dim otp As String = random.Next(100000, 999999).ToString()
            Dim expiryTime As DateTime = DateTime.Now.AddMinutes(10)

            ' Store OTP in session
            Session("OTPCode") = otp
            Session("OTPExpiry") = expiryTime
            Session("OTPAttempts") = 0

            Using smtpClient As New SmtpClient()
                Using mailMessage As New MailMessage()
                    mailMessage.From = New MailAddress("facultyevaluation2025@gmail.com", "Golden West Colleges")
                    mailMessage.To.Add(email)
                    mailMessage.Subject = $"Your First-Time Login Secure Access Code - {DateTime.Now:MMM dd, yyyy}"
                    mailMessage.Body = CreateFirstTimeOTPEmailTemplate(otp, fullName, 10)
                    mailMessage.IsBodyHtml = True
                    mailMessage.Priority = MailPriority.High

                    smtpClient.Send(mailMessage)
                End Using
            End Using

            Return True

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("OTP Send Error: " & ex.Message)
            Return False
        End Try
    End Function

    ' Update FirstLogin status in database after successful OTP verification
    Public Shared Sub UpdateFirstLoginStatus(userID As String, role As String)
        Dim connString As String = System.Configuration.ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()

                Dim sql As String = ""
                If role = "Student" Then
                    sql = "UPDATE Students SET FirstLogin = 0 WHERE StudentID = @UserID"
                Else
                    sql = "UPDATE Users SET FirstLogin = 0 WHERE UserID = @UserID"
                End If

                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@UserID", userID)
                    cmd.ExecuteNonQuery()
                End Using
            End Using
        Catch ex As Exception
            ' Log error but don't break the login flow
            System.Diagnostics.Debug.WriteLine("UpdateFirstLogin Error: " & ex.Message)
        End Try
    End Sub

    Private Function CreateFirstTimeOTPEmailTemplate(otp As String, fullName As String, validMinutes As Integer) As String
        Return $"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            background: #f8f9fc;
            margin: 0;
            padding: 20px;
        }}
        .container {{
            max-width: 600px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }}
        .header {{
            background: linear-gradient(135deg, #1a3a8f 0%, #2a4aaf 100%);
            color: white;
            padding: 25px;
            text-align: center;
        }}
        .institution {{
            font-family: 'Montserrat', sans-serif;
            font-weight: 800;
            font-size: 22px;
            margin-bottom: 5px;
            text-transform: uppercase;
        }}
        .system {{
            font-family: 'Poppins', sans-serif;
            font-weight: 600;
            font-size: 13px;
            opacity: 0.9;
        }}
        .content {{
            padding: 30px;
        }}
        .greeting {{
            color: #1a3a8f;
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 15px;
        }}
        .otp-box {{
            background: linear-gradient(135deg, #f8f9fe, #eef2ff);
            border: 2px solid #e1e5ee;
            border-radius: 10px;
            padding: 25px;
            text-align: center;
            margin: 20px 0;
        }}
        .otp {{
            font-family: 'Courier New', monospace;
            font-size: 36px;
            font-weight: 800;
            color: #1a3a8f;
            letter-spacing: 6px;
            margin: 10px 0;
        }}
        .info-box {{
            background: #fff3cd;
            color: #856404;
            padding: 15px;
            border-radius: 8px;
            margin: 15px 0;
            border-left: 4px solid #d4af37;
            font-size: 14px;
        }}
        .security {{
            background: #d1ecf1;
            color: #0c5460;
            padding: 12px;
            border-radius: 6px;
            margin: 15px 0;
            font-size: 13px;
        }}
        .footer {{
            background: #1a3a8f;
            color: white;
            padding: 20px;
            text-align: center;
            font-size: 12px;
        }}
        .highlight {{
            background: linear-gradient(135deg, #d4af37, #e6c158);
            color: #333;
            padding: 20px;
            border-radius: 8px;
            margin: 15px 0;
            text-align: center;
            font-weight: 600;
        }}
        @media (max-width: 600px) {{
            .content {{ padding: 20px; }}
            .otp {{ font-size: 28px; letter-spacing: 4px; }}
        }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <div class='institution'>GOLDEN WEST COLLEGES</div>
            <div class='system'>First-Time Login Verification</div>
        </div>
        
        <div class='content'>
            <div class='greeting'>Welcome {fullName}!</div>
            
            <div class='highlight'>
                🎉 Welcome to Golden West Colleges Faculty Evaluation System!
            </div>
            
            <p style='color: #6c757d; margin-bottom: 20px;'>
                This is your first time logging in. For security purposes, please use the following verification code to complete your setup:
            </p>
            
            <div class='otp-box'>
                <div style='color: #6c757d; font-size: 14px; margin-bottom: 10px;'>First-Time Login Verification Code</div>
                <div class='otp'>{otp}</div>
                <div style='color: #6c757d; font-size: 12px; margin-top: 10px;'>
                    Expires in {validMinutes} minutes
                </div>
            </div>
            
            <div class='info-box'>
                <strong>⚠ Important:</strong> This OTP is only required for your first login. Future logins will not require this step.
            </div>
            
            <div class='security'>
                <strong>🔒 Security Notice:</strong> Never share this code. If you didn't request this, contact administrator immediately.
            </div>
        </div>
        
        <div class='footer'>
            <div>© {DateTime.Now.Year} Golden West Colleges</div>
            <div style='opacity: 0.8; margin-top: 5px;'>Faculty Evaluation System - First Login Setup</div>
        </div>
    </div>
</body>
</html>"
    End Function

    ' ... Rest of your existing methods (BuildFullName, HashPassword, RedirectByRole) remain the same ...
    Private Function BuildFullName(lastName As String, firstName As String, middleInitial As String, suffix As String) As String
        Dim fullName As New StringBuilder()

        fullName.Append(lastName)
        fullName.Append(", ")
        fullName.Append(firstName)

        If Not String.IsNullOrWhiteSpace(middleInitial) Then
            fullName.Append(" ")
            fullName.Append(middleInitial.Trim().ToUpper())
            fullName.Append(".")
        End If

        If Not String.IsNullOrWhiteSpace(suffix) Then
            fullName.Append(" ")
            fullName.Append(suffix.Trim())
        End If

        Return fullName.ToString()
    End Function

    Private Function HashPassword(password As String) As String
        Using sha256 As SHA256 = SHA256.Create()
            Dim bytes As Byte() = sha256.ComputeHash(Encoding.UTF8.GetBytes(password))
            Dim sb As New StringBuilder()
            For Each b In bytes
                sb.Append(b.ToString("x2"))
            Next
            Return sb.ToString()
        End Using
    End Function

    ' Redirect user based on role
    Private Sub RedirectByRole(role As String)
        Select Case role.Trim().ToUpper()
            Case "STUDENT"
                Response.Redirect("StudentDashboard.aspx", False)
            Case "FACULTY"
                Response.Redirect("FacultyDashboard.aspx", False)
            Case "DEAN"
                Response.Redirect("DepartmentResult.aspx", False)
            Case "REGISTRAR"
                Response.Redirect("RegistrarGradeSubmission.aspx", False)
            Case "ADMIN"
                Response.Redirect("HRDashboard.aspx", False)
            Case Else
                Session.Abandon()
                lblMsg.Text = "⚠ Invalid role. Contact administrator."
                lblMsg.CssClass = "alert alert-danger d-block"
        End Select
        Context.ApplicationInstance.CompleteRequest()
    End Sub

End Class