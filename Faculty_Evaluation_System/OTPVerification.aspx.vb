Imports MySql.Data.MySqlClient
Imports System.Net.Mail

Public Class OTPVerification
    Inherits System.Web.UI.Page

    Private Const MaxOTPAttempts As Integer = 3
    Private Const OTPValidMinutes As Integer = 10

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Session("TempUserID") Is Nothing OrElse Session("TempRole") Is Nothing Then
                Response.Redirect("Login.aspx")
                Return
            End If

            ' Display user info
            userName.InnerText = Session("TempFullName").ToString()

            ' Check if this is first login and display appropriate message
            Dim isFirstLogin As Boolean = True
            If Session("TempFirstLogin") IsNot Nothing Then
                isFirstLogin = Convert.ToBoolean(Session("TempFirstLogin"))
            End If

            If isFirstLogin Then
                userRole.InnerText = $"{Session("TempRole")} • First-Time Login • {Session("TempSchoolID")}"
            Else
                userRole.InnerText = $"{Session("TempRole")} • {Session("TempSchoolID")}"
            End If

            ' Display masked email
            Dim email As String = If(Session("TempEmail"), "")
            If Not String.IsNullOrEmpty(email) Then
                userEmail.InnerText = MaskEmail(email)
            End If

            If Session("OTPAttempts") Is Nothing Then
                Session("OTPAttempts") = 0
            End If

            Response.Cache.SetCacheability(HttpCacheability.NoCache)
            Response.Cache.SetExpires(DateTime.UtcNow.AddHours(-1))
            Response.Cache.SetNoStore()
        End If
    End Sub

    Protected Sub btnVerify_Click(ByVal sender As Object, ByVal e As EventArgs)
        lblMsg.Text = ""
        lblMsg.CssClass = ""

        Dim enteredOTP As String = txtOTP.Text.Trim()

        If String.IsNullOrEmpty(enteredOTP) OrElse enteredOTP.Length <> 6 OrElse Not IsNumeric(enteredOTP) Then
            ShowWarningMessage("Please enter a valid 6-digit OTP code.")
            Return
        End If

        If Session("OTPCode") Is Nothing OrElse Session("OTPExpiry") Is Nothing Then
            ShowErrorMessage("OTP session expired. Please request a new code.")
            Return
        End If

        Dim storedOTP As String = Session("OTPCode").ToString()
        Dim expiryTime As DateTime = CType(Session("OTPExpiry"), DateTime)

        If DateTime.Now > expiryTime Then
            ShowErrorMessage("OTP has expired. Please request a new code.")
            Session("OTPCode") = Nothing
            Session("OTPExpiry") = Nothing
            Return
        End If

        Dim attempts As Integer = Convert.ToInt32(Session("OTPAttempts"))
        If attempts >= MaxOTPAttempts Then
            ShowErrorMessage("Too many failed attempts. Please request a new OTP.")
            Return
        End If

        If enteredOTP = storedOTP Then
            ' OTP verified successfully
            Session("OTPAttempts") = 0
            Session("OTPVerified") = True

            ' Check if this is first login and update database
            Dim isFirstLogin As Boolean = True
            If Session("TempFirstLogin") IsNot Nothing Then
                isFirstLogin = Convert.ToBoolean(Session("TempFirstLogin"))
            End If

            If isFirstLogin Then
                ' Update first login status in database
                UpdateFirstLoginStatus(Session("TempUserID").ToString(), Session("TempRole").ToString())
            End If

            ' Move temp session to actual session
            Session("UserID") = Session("TempUserID")
            Session("SchoolID") = Session("TempSchoolID")
            Session("FullName") = Session("TempFullName")
            Session("Role") = Session("TempRole")
            Session("DepartmentID") = Session("TempDepartmentID")
            Session("CourseID") = Session("TempCourseID")
            Session("ClassID") = Session("TempClassID")
            Session("DepartmentName") = Session("TempDepartmentName")
            Session("FirstLoginCompleted") = True

            ' Clear temp sessions
            ClearTempSessions()

            ' Clear OTP sessions
            Session("OTPCode") = Nothing
            Session("OTPExpiry") = Nothing

            ' Redirect based on role
            RedirectByRole(Session("Role").ToString())

        Else
            ' Invalid OTP
            attempts += 1
            Session("OTPAttempts") = attempts
            Dim remainingAttempts As Integer = MaxOTPAttempts - attempts

            If remainingAttempts > 0 Then
                ShowErrorMessage($"Invalid OTP code. {remainingAttempts} attempt(s) remaining.")
            Else
                ShowErrorMessage("Too many failed attempts. Please request a new OTP.")
            End If
            txtOTP.Text = ""
            txtOTP.Focus()
        End If
    End Sub

    Protected Sub btnResend_Click(ByVal sender As Object, ByVal e As EventArgs)
        lblMsg.Text = ""
        lblMsg.CssClass = ""

        Dim userEmail As String = If(Session("TempEmail"), "")
        Dim fullName As String = If(Session("TempFullName"), "")

        If String.IsNullOrEmpty(userEmail) Then
            ShowErrorMessage("Email not found. Please contact administrator.")
            Return
        End If

        ' Check if this is first login to customize the email
        Dim isFirstLogin As Boolean = True
        If Session("TempFirstLogin") IsNot Nothing Then
            isFirstLogin = Convert.ToBoolean(Session("TempFirstLogin"))
        End If

        If SendOTP(userEmail, fullName, isFirstLogin) Then
            Session("OTPAttempts") = 0
            ShowSuccessMessage("New verification code sent to your email.")
            txtOTP.Text = ""
            txtOTP.Focus()
        Else
            ShowErrorMessage("Failed to send OTP. Please try again.")
        End If
    End Sub

    Protected Sub lnkBack_Click(ByVal sender As Object, ByVal e As EventArgs)
        ClearTempSessions()
        Response.Redirect("Login.aspx")
    End Sub

    ' Update FirstLogin status in database
    Private Sub UpdateFirstLoginStatus(userID As String, role As String)
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

    ' Generate and send OTP with appropriate email design based on first login status
    Private Function SendOTP(email As String, fullName As String, isFirstLogin As Boolean) As Boolean
        Try
            ' Generate 6-digit OTP
            Dim random As New Random()
            Dim otp As String = random.Next(100000, 999999).ToString()
            Dim expiryTime As DateTime = DateTime.Now.AddMinutes(OTPValidMinutes)

            ' Store OTP in session
            Session("OTPCode") = otp
            Session("OTPExpiry") = expiryTime

            ' Create appropriate email based on first login status
            Using smtpClient As New SmtpClient()
                Using mailMessage As New MailMessage()
                    mailMessage.From = New MailAddress("facultyevaluation2025@gmail.com", "Golden West Colleges")
                    mailMessage.To.Add(email)

                    If isFirstLogin Then
                        mailMessage.Subject = $"Your First-Time Login Verification Code - {DateTime.Now:MMM dd, yyyy}"
                        mailMessage.Body = CreateFirstTimeLoginEmailTemplate(otp, fullName, OTPValidMinutes)
                    Else
                        mailMessage.Subject = $"Your Verification Code - {DateTime.Now:MMM dd, yyyy 'at' hh:mm tt}"
                        mailMessage.Body = CreateRegularEmailTemplate(otp, fullName, OTPValidMinutes)
                    End If

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

    ' Create first-time login email template
    Private Function CreateFirstTimeLoginEmailTemplate(otp As String, fullName As String, validMinutes As Integer) As String
        Return $"
<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>First-Time Login Verification</title>
    <style>
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }}
        .email-container {{
            max-width: 600px;
            margin: 0 auto;
            background: white;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }}
        .header {{
            background: linear-gradient(135deg, #1a3a8f 0%, #2a4aaf 100%);
            color: white;
            padding: 30px;
            text-align: center;
            position: relative;
        }}
        .header::before {{
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #d4af37, #e6c158, #d4af37);
        }}
        .institution-name {{
            font-family: 'Montserrat', sans-serif;
            font-weight: 800;
            font-size: 24px;
            margin: 0 0 8px 0;
            text-transform: uppercase;
            letter-spacing: 1px;
        }}
        .system-name {{
            font-family: 'Poppins', sans-serif;
            font-weight: 600;
            font-size: 14px;
            opacity: 0.9;
            margin: 0;
        }}
        .content {{
            padding: 40px;
            background: #f8f9fc;
        }}
        .greeting {{
            color: #1a3a8f;
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 20px;
        }}
        .welcome-banner {{
            background: linear-gradient(135deg, #d4af37, #e6c158);
            color: #333;
            padding: 20px;
            border-radius: 12px;
            text-align: center;
            margin: 20px 0;
            font-weight: 700;
            font-size: 16px;
            border: 2px solid #b8941f;
        }}
        .otp-container {{
            background: white;
            border-radius: 12px;
            padding: 30px;
            text-align: center;
            margin: 25px 0;
            border: 2px dashed #e1e5ee;
            position: relative;
        }}
        .otp-label {{
            color: #6c757d;
            font-size: 14px;
            margin-bottom: 15px;
            display: block;
        }}
        .otp-code {{
            font-family: 'Courier New', monospace;
            font-size: 42px;
            font-weight: 800;
            color: #1a3a8f;
            letter-spacing: 8px;
            margin: 15px 0;
            background: linear-gradient(135deg, #1a3a8f, #2a4aaf);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.1);
        }}
        .timer-info {{
            background: #fff3cd;
            color: #856404;
            padding: 12px;
            border-radius: 8px;
            margin: 20px 0;
            border-left: 4px solid #d4af37;
            font-size: 14px;
        }}
        .instructions {{
            color: #6c757d;
            font-size: 14px;
            line-height: 1.6;
            margin: 25px 0;
        }}
        .security-note {{
            background: #d1ecf1;
            color: #0c5460;
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
            border-left: 4px solid #1a3a8f;
            font-size: 13px;
        }}
        .first-login-note {{
            background: #e7f3ff;
            color: #004085;
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
            border-left: 4px solid #1a3a8f;
            font-size: 13px;
        }}
        .footer {{
            background: #1a3a8f;
            color: white;
            padding: 25px;
            text-align: center;
            font-size: 12px;
        }}
        .contact-info {{
            margin-top: 15px;
            opacity: 0.8;
        }}
        @media (max-width: 600px) {{
            .content {{
                padding: 25px;
            }}
            .otp-code {{
                font-size: 32px;
                letter-spacing: 6px;
            }}
            .institution-name {{
                font-size: 20px;
            }}
        }}
    </style>
</head>
<body>
    <div class='email-container'>
        <div class='header'>
            <div class='institution-name'>GOLDEN WEST COLLEGES</div>
            <div class='system-name'>First-Time Login Setup</div>
        </div>
        
        <div class='content'>
            <div class='greeting'>Welcome {fullName}!</div>
            
            <div class='welcome-banner'>
                🎉 Welcome to Golden West Colleges Faculty Evaluation System!
            </div>
            
            <p style='color: #6c757d; line-height: 1.6;'>
                To complete your first-time login setup and activate your account, please use the verification code below:
            </p>
            
            <div class='otp-container'>
                <span class='otp-label'>Your First-Time Login Verification Code</span>
                <div class='otp-code'>{otp}</div>
                <small style='color: #6c757d;'>Enter this code on the verification page</small>
            </div>
            
            <div class='timer-info'>
                <strong>⏰ Time-sensitive:</strong> This code will expire in {validMinutes} minutes for security reasons.
            </div>
            
            <div class='first-login-note'>
                <strong>📝 First Login Note:</strong> This OTP is only required for your initial login. 
                Future logins will proceed directly to your dashboard after password verification.
            </div>
            
            <div class='instructions'>
                <strong>To complete your first-time login:</strong><br>
                1. Return to the verification page<br>
                2. Enter the 6-digit code shown above<br>
                3. Click 'Verify & Continue' to activate your account<br>
                4. You'll be redirected to your personalized dashboard
            </div>
            
            <div class='security-note'>
                <strong>🔒 Security Alert:</strong> 
                Never share this code with anyone. Our team will never ask for your verification code. 
                If you didn't request this code, please contact us immediately.
            </div>
            
            <p style='color: #6c757d; font-size: 13px; text-align: center; margin-top: 30px;'>
                This is an automated message. Please do not reply to this email.
            </p>
        </div>
        
        <div class='footer'>
            <div>© {DateTime.Now.Year} Golden West Colleges. All rights reserved.</div>
            <div class='contact-info'>
                Faculty Evaluation System | Account Activation Portal
            </div>
        </div>
    </div>
</body>
</html>"
    End Function

    ' Create regular login email template (for existing users who need OTP for other reasons)
    Private Function CreateRegularEmailTemplate(otp As String, fullName As String, validMinutes As Integer) As String
        Return $"
<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Verification Code</title>
    <style>
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }}
        .email-container {{
            max-width: 600px;
            margin: 0 auto;
            background: white;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }}
        .header {{
            background: linear-gradient(135deg, #1a3a8f 0%, #2a4aaf 100%);
            color: white;
            padding: 30px;
            text-align: center;
            position: relative;
        }}
        .header::before {{
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #d4af37, #e6c158, #d4af37);
        }}
        .institution-name {{
            font-family: 'Montserrat', sans-serif;
            font-weight: 800;
            font-size: 24px;
            margin: 0 0 8px 0;
            text-transform: uppercase;
            letter-spacing: 1px;
        }}
        .system-name {{
            font-family: 'Poppins', sans-serif;
            font-weight: 600;
            font-size: 14px;
            opacity: 0.9;
            margin: 0;
        }}
        .content {{
            padding: 40px;
            background: #f8f9fc;
        }}
        .greeting {{
            color: #1a3a8f;
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 20px;
        }}
        .otp-container {{
            background: white;
            border-radius: 12px;
            padding: 30px;
            text-align: center;
            margin: 25px 0;
            border: 2px dashed #e1e5ee;
            position: relative;
        }}
        .otp-label {{
            color: #6c757d;
            font-size: 14px;
            margin-bottom: 15px;
            display: block;
        }}
        .otp-code {{
            font-family: 'Courier New', monospace;
            font-size: 42px;
            font-weight: 800;
            color: #1a3a8f;
            letter-spacing: 8px;
            margin: 15px 0;
            background: linear-gradient(135deg, #1a3a8f, #2a4aaf);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.1);
        }}
        .timer-info {{
            background: #fff3cd;
            color: #856404;
            padding: 12px;
            border-radius: 8px;
            margin: 20px 0;
            border-left: 4px solid #d4af37;
            font-size: 14px;
        }}
        .instructions {{
            color: #6c757d;
            font-size: 14px;
            line-height: 1.6;
            margin: 25px 0;
        }}
        .security-note {{
            background: #d1ecf1;
            color: #0c5460;
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
            border-left: 4px solid #1a3a8f;
            font-size: 13px;
        }}
        .footer {{
            background: #1a3a8f;
            color: white;
            padding: 25px;
            text-align: center;
            font-size: 12px;
        }}
        .contact-info {{
            margin-top: 15px;
            opacity: 0.8;
        }}
        @media (max-width: 600px) {{
            .content {{
                padding: 25px;
            }}
            .otp-code {{
                font-size: 32px;
                letter-spacing: 6px;
            }}
            .institution-name {{
                font-size: 20px;
            }}
        }}
    </style>
</head>
<body>
    <div class='email-container'>
        <div class='header'>
            <div class='institution-name'>GOLDEN WEST COLLEGES</div>
            <div class='system-name'>Secure Verification Code</div>
        </div>
        
        <div class='content'>
            <div class='greeting'>Hello {fullName},</div>
            
            <p style='color: #6c757d; line-height: 1.6;'>
                You're one step away from accessing your account. Use the verification code below to complete your login:
            </p>
            
            <div class='otp-container'>
                <span class='otp-label'>Your Verification Code</span>
                <div class='otp-code'>{otp}</div>
                <small style='color: #6c757d;'>Enter this code on the verification page</small>
            </div>
            
            <div class='timer-info'>
                <strong>⏰ Time-sensitive:</strong> This code will expire in {validMinutes} minutes for security reasons.
            </div>
            
            <div class='instructions'>
                <strong>To complete your login:</strong><br>
                1. Return to the verification page<br>
                2. Enter the 6-digit code shown above<br>
                3. Click 'Verify & Continue' to access your account
            </div>
            
            <div class='security-note'>
                <strong>🔒 Security Alert:</strong> 
                Never share this code with anyone. Our team will never ask for your verification code. 
                If you didn't request this code, please contact us immediately.
            </div>
            
            <p style='color: #6c757d; font-size: 13px; text-align: center; margin-top: 30px;'>
                This is an automated message. Please do not reply to this email.
            </p>
        </div>
        
        <div class='footer'>
            <div>© {DateTime.Now.Year} Golden West Colleges. All rights reserved.</div>
            <div class='contact-info'>
                Faculty Evaluation System | Secure Access Portal
            </div>
        </div>
    </div>
</body>
</html>"
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
                Response.Redirect("Login.aspx", False)
        End Select
        Context.ApplicationInstance.CompleteRequest()
    End Sub

    ' Clear temporary sessions
    Private Sub ClearTempSessions()
        Session("TempUserID") = Nothing
        Session("TempSchoolID") = Nothing
        Session("TempFullName") = Nothing
        Session("TempRole") = Nothing
        Session("TempDepartmentID") = Nothing
        Session("TempCourseID") = Nothing
        Session("TempClassID") = Nothing
        Session("TempDepartmentName") = Nothing
        Session("TempEmail") = Nothing
        Session("TempFirstLogin") = Nothing
    End Sub

    ' Utility methods for better message display
    Private Sub ShowSuccessMessage(message As String)
        lblMsg.Text = $"✅ {message}"
        lblMsg.CssClass = "alert alert-success d-block"
    End Sub

    Private Sub ShowErrorMessage(message As String)
        lblMsg.Text = $"❌ {message}"
        lblMsg.CssClass = "alert alert-danger d-block"
    End Sub

    Private Sub ShowWarningMessage(message As String)
        lblMsg.Text = $"⚠ {message}"
        lblMsg.CssClass = "alert alert-warning d-block"
    End Sub

    Private Function MaskEmail(email As String) As String
        If String.IsNullOrEmpty(email) OrElse Not email.Contains("@") Then
            Return email
        End If

        Dim parts() As String = email.Split("@"c)
        Dim username As String = parts(0)
        Dim domain As String = parts(1)

        If username.Length <= 2 Then
            Return username & "***@" & domain
        Else
            Return username.Substring(0, 2) & "***@" & domain
        End If
    End Function

End Class