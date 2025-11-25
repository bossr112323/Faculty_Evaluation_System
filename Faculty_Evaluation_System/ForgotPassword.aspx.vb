Imports System.Configuration
Imports System.Data
Imports System.Net.Mail
Imports System.Security.Cryptography
Imports System.Web
Imports MySql.Data.MySqlClient
Imports System.Text

Public Class ForgotPassword
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            ' Hide message on initial load
            messageAlert.Attributes("class") = "alert-message d-none"
            pnlResetCode.Visible = False
            pnlNewPassword.Visible = False
        End If
    End Sub

    ' Step 1: Request reset by School ID
    Protected Sub btnRequest_Click(sender As Object, e As EventArgs)
        Dim schoolID As String = txtSchoolID.Text.Trim()

        If String.IsNullOrEmpty(schoolID) Then
            ShowMessage("Please enter your School ID.", "warning")
            Return
        End If

        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                ' Check if School ID exists and get email and name components
                Dim userEmail As String = ""
                Dim firstName As String = ""
                Dim lastName As String = ""
                Dim middleInitial As String = ""
                Dim suffix As String = ""
                Dim sql As String = "
                    SELECT SchoolID, Email, FirstName, LastName, MiddleInitial, Suffix, 'Student' as Role 
                    FROM Students 
                    WHERE SchoolID=@sid AND Status='Active'
                    UNION
                    SELECT SchoolID, Email, FirstName, LastName, MiddleInitial, Suffix, Role 
                    FROM Users 
                    WHERE SchoolID=@sid AND Status='Active'
                "

                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@sid", schoolID)

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        If rdr.Read() Then
                            userEmail = If(rdr("Email") Is DBNull.Value, "", rdr("Email").ToString())
                            firstName = If(rdr("FirstName") Is DBNull.Value, "", rdr("FirstName").ToString())
                            lastName = If(rdr("LastName") Is DBNull.Value, "", rdr("LastName").ToString())
                            middleInitial = If(rdr("MiddleInitial") Is DBNull.Value, "", rdr("MiddleInitial").ToString())
                            suffix = If(rdr("Suffix") Is DBNull.Value, "", rdr("Suffix").ToString())

                            ' Construct full name
                            Dim fullName As String = ConstructFullName(firstName, middleInitial, lastName, suffix)

                            Session("ResetSchoolID") = schoolID
                            Session("ResetUserName") = fullName
                        Else
                            ShowMessage("No active account found with that School ID.", "danger")
                            Return
                        End If
                    End Using
                End Using

                ' Check if email is available
                If String.IsNullOrEmpty(userEmail) Then
                    ShowMessage("No email address found for this account. Please contact administrator.", "danger")
                    Return
                End If

                ' Generate 6-digit reset code
                Dim resetCode As String = GenerateResetCode()

                ' Store reset code in database
                StoreResetToken(schoolID, resetCode)

                ' Send email with reset code
                If SendResetEmail(userEmail, Session("ResetUserName").ToString(), resetCode) Then
                    pnlSchoolID.Visible = False
                    pnlResetCode.Visible = True
                    ShowMessage("Reset code sent to your email. Please check your inbox.", "success")

                    ' Start the cooldown timer client-side
                    ClientScript.RegisterStartupScript(Me.GetType(), "startCooldown", "startResendCooldown();", True)
                Else
                    ShowMessage("Failed to send reset email. Please try again.", "danger")
                End If
            End Using

        Catch ex As Exception
            ShowMessage("Error: " & ex.Message, "danger")
        End Try
    End Sub

    ' Step 2: Verify reset code
    Protected Sub btnVerifyCode_Click(sender As Object, e As EventArgs)
        Dim enteredCode As String = txtResetCode.Text.Trim()
        Dim schoolID As String = Session("ResetSchoolID").ToString()

        If String.IsNullOrEmpty(enteredCode) OrElse enteredCode.Length <> 6 Then
            ShowMessage("Please enter the 6-digit code sent to your email.", "warning")
            Return
        End If

        If VerifyResetCode(schoolID, enteredCode) Then
            pnlResetCode.Visible = False
            pnlNewPassword.Visible = True
            ShowMessage("Code verified. Please enter your new password.", "success")
        Else
            ShowMessage("Invalid or expired reset code. Please try again.", "danger")
        End If
    End Sub

    ' Step 3: Reset password
    Protected Sub btnResetPassword_Click(sender As Object, e As EventArgs)
        Dim newPassword As String = txtNewPassword.Text.Trim()
        Dim confirmPassword As String = txtConfirmPassword.Text.Trim()
        Dim schoolID As String = Session("ResetSchoolID").ToString()

        If String.IsNullOrEmpty(newPassword) Then
            ShowMessage("Please enter a new password.", "warning")
            Return
        End If

        If newPassword <> confirmPassword Then
            ShowMessage("Passwords do not match.", "warning")
            Return
        End If

        If newPassword.Length < 6 Then
            ShowMessage("Password must be at least 6 characters long.", "warning")
            Return
        End If

        Try
            ' Update password in database
            If UpdatePassword(schoolID, newPassword) Then
                ' Mark token as used
                MarkTokenAsUsed(schoolID)

                ShowMessage("Password reset successfully! You can now login with your new password.", "success")

                ' Clear session
                Session.Remove("ResetSchoolID")
                Session.Remove("ResetUserName")

                ' Redirect to login after 3 seconds
                ClientScript.RegisterStartupScript(Me.GetType(), "redirect",
                    "setTimeout(function() { window.location.href = 'Login.aspx'; }, 3000);", True)
            Else
                ShowMessage("Failed to reset password. Please try again.", "danger")
            End If

        Catch ex As Exception
            ShowMessage("Error: " & ex.Message, "danger")
        End Try
    End Sub

    ' Resend code functionality
    Protected Sub btnResendCode_Click(sender As Object, e As EventArgs)
        Dim schoolID As String = Session("ResetSchoolID").ToString()
        Dim userName As String = Session("ResetUserName").ToString()

        ' Get email from database
        Dim userEmail As String = ""
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim sql As String = "
                SELECT Email FROM Students WHERE SchoolID=@sid
                UNION
                SELECT Email FROM Users WHERE SchoolID=@sid
            "
            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@sid", schoolID)
                Using rdr As MySqlDataReader = cmd.ExecuteReader()
                    If rdr.Read() Then
                        userEmail = If(rdr("Email") Is DBNull.Value, "", rdr("Email").ToString())
                    End If
                End Using
            End Using
        End Using

        If Not String.IsNullOrEmpty(userEmail) Then
            Dim newCode As String = GenerateResetCode()
            StoreResetToken(schoolID, newCode)

            If SendResetEmail(userEmail, userName, newCode) Then
                ShowMessage("New reset code sent to your email.", "success")
                ' Start the cooldown timer client-side
                ClientScript.RegisterStartupScript(Me.GetType(), "startCooldown", "startResendCooldown();", True)
            Else
                ShowMessage("Failed to resend code. Please try again.", "danger")
            End If
        Else
            ShowMessage("Email not found for this account.", "danger")
        End If
    End Sub

    ' Helper method to construct full name from components
    Private Function ConstructFullName(firstName As String, middleInitial As String, lastName As String, suffix As String) As String
        Dim fullName As New StringBuilder()

        ' Add first name
        fullName.Append(firstName.Trim())

        ' Add middle initial if available
        If Not String.IsNullOrEmpty(middleInitial) AndAlso middleInitial.Trim().Length > 0 Then
            fullName.Append(" ").Append(middleInitial.Trim())
        End If

        ' Add last name
        fullName.Append(" ").Append(lastName.Trim())

        ' Add suffix if available
        If Not String.IsNullOrEmpty(suffix) AndAlso suffix.Trim().Length > 0 Then
            fullName.Append(" ").Append(suffix.Trim())
        End If

        Return fullName.ToString().Trim()
    End Function

    ' Improved ShowMessage method
    Private Sub ShowMessage(message As String, type As String)
        messageText.InnerHtml = message
        messageAlert.Attributes("class") = $"alert-message alert-{type}"

        ' Register script to ensure proper display
        Dim script As String = "
            setTimeout(function() {
                const messageAlert = document.getElementById('messageAlert');
                if (messageAlert) {
                    messageAlert.style.display = 'flex';
                    messageAlert.classList.remove('d-none');
                    messageAlert.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                }
            }, 100);"

        ClientScript.RegisterStartupScript(Me.GetType(), "showMessage", script, True)
    End Sub

    ' Helper Methods
    Private Function GenerateResetCode() As String
        Dim random As New Random()
        Return random.Next(100000, 999999).ToString()
    End Function

    Private Sub StoreResetToken(schoolID As String, token As String)
        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Clean up old tokens for this user
            Dim cleanupSql As String = "DELETE FROM passwordresettokens WHERE SchoolID = @schoolID OR Expiration < NOW()"
            Using cmd As New MySqlCommand(cleanupSql, conn)
                cmd.Parameters.AddWithValue("@schoolID", schoolID)
                cmd.ExecuteNonQuery()
            End Using

            ' Insert new token (valid for 15 minutes)
            Dim insertSql As String = "INSERT INTO passwordresettokens (SchoolID, Token, Expiration, Used) VALUES (@schoolID, @token, DATE_ADD(NOW(), INTERVAL 15 MINUTE), 0)"
            Using cmd As New MySqlCommand(insertSql, conn)
                cmd.Parameters.AddWithValue("@schoolID", schoolID)
                cmd.Parameters.AddWithValue("@token", token)
                cmd.ExecuteNonQuery()
            End Using
        End Using
    End Sub

    Private Function VerifyResetCode(schoolID As String, token As String) As Boolean
        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            Dim sql As String = "SELECT TokenID FROM passwordresettokens WHERE SchoolID = @schoolID AND Token = @token AND Expiration > NOW() AND Used = 0"
            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@schoolID", schoolID)
                cmd.Parameters.AddWithValue("@token", token)

                Using rdr As MySqlDataReader = cmd.ExecuteReader()
                    Return rdr.HasRows
                End Using
            End Using
        End Using
    End Function

    Private Function UpdatePassword(schoolID As String, newPassword As String) As Boolean
        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Hash the new password
            Dim hashedPassword As String = HashPassword(newPassword)

            ' Update password in students table
            Dim studentSql As String = "UPDATE students SET Password = @password WHERE SchoolID = @schoolID"
            Using studentCmd As New MySqlCommand(studentSql, conn)
                studentCmd.Parameters.AddWithValue("@password", hashedPassword)
                studentCmd.Parameters.AddWithValue("@schoolID", schoolID)
                Dim studentRows As Integer = studentCmd.ExecuteNonQuery()

                If studentRows > 0 Then
                    Return True
                End If
            End Using

            ' Update password in users table
            Dim userSql As String = "UPDATE users SET Password = @password WHERE SchoolID = @schoolID"
            Using userCmd As New MySqlCommand(userSql, conn)
                userCmd.Parameters.AddWithValue("@password", hashedPassword)
                userCmd.Parameters.AddWithValue("@schoolID", schoolID)
                Dim userRows As Integer = userCmd.ExecuteNonQuery()

                Return userRows > 0
            End Using
        End Using
    End Function

    Private Sub MarkTokenAsUsed(schoolID As String)
        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            Dim sql As String = "UPDATE passwordresettokens SET Used = 1 WHERE SchoolID = @schoolID"
            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@schoolID", schoolID)
                cmd.ExecuteNonQuery()
            End Using
        End Using
    End Sub

    Private Function SendResetEmail(toEmail As String, userName As String, resetCode As String) As Boolean
        Try
            ' Get SMTP settings from Web.config
            Dim smtpServer As String = ConfigurationManager.AppSettings("SMTPServer")
            Dim smtpPort As Integer = Integer.Parse(ConfigurationManager.AppSettings("SMTPPort"))
            Dim smtpUsername As String = ConfigurationManager.AppSettings("SMTPUsername")
            Dim smtpPassword As String = ConfigurationManager.AppSettings("SMTPPassword")
            Dim enableSSL As Boolean = Boolean.Parse(ConfigurationManager.AppSettings("SMTPEnableSSL"))
            Dim timeout As Integer = Integer.Parse(If(ConfigurationManager.AppSettings("SMTPTimeout"), "30000"))

            Using message As New MailMessage()
                message.From = New MailAddress(smtpUsername, "Faculty Evaluation System")
                message.To.Add(New MailAddress(toEmail))
                message.Subject = "Password Reset Code - Faculty Evaluation System"
                message.IsBodyHtml = True

                Dim emailBody As String = String.Format("
            <html>
            <head>
                <style>
                    body {{ font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }}
                    .container {{ max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }}
                    .header {{ background: linear-gradient(135deg, #1a3a8f 0%, #2a4aaf 100%); padding: 30px; text-align: center; color: white; }}
                    .content {{ padding: 30px; }}
                    .code-box {{ background: #f8f9fc; padding: 25px; text-align: center; margin: 25px 0; border-radius: 8px; border: 2px dashed #1a3a8f; }}
                    .code {{ font-size: 42px; font-weight: bold; color: #1a3a8f; letter-spacing: 10px; margin: 15px 0; font-family: 'Courier New', monospace; }}
                    .footer {{ background: #f8f9fc; padding: 20px; text-align: center; color: #6c757d; font-size: 12px; border-top: 1px solid #e3e6f0; }}
                </style>
            </head>
            <body>
                <div class='container'>
                    <div class='header'>
                        <h1 style='margin: 0; font-size: 28px;'><i class='bi bi-shield-lock'></i> Password Reset Request</h1>
                    </div>
                    <div class='content'>
                        <p>Hello <strong>{0}</strong>,</p>
                        <p>You have requested to reset your password for the <strong>Faculty Evaluation System</strong>.</p>
                        
                        <div class='code-box'>
                            <h3 style='color: #1a3a8f; margin: 0 0 15px 0; font-size: 18px;'>YOUR RESET CODE</h3>
                            <div class='code'>{1}</div>
                            <p style='color: #6c757d; margin: 10px 0 0 0; font-size: 14px;'>
                                <i class='bi bi-clock'></i> Expires in 15 minutes
                            </p>
                        </div>
                        
                        <p>Enter this code on the password reset page to continue with your password reset process.</p>
                        <p style='color: #858796;'><strong>Note:</strong> If you didn't request this password reset, please ignore this email. Your account remains secure.</p>
                    </div>
                    <div class='footer'>
                        <p style='margin: 0;'>Faculty Evaluation System<br>
                        <small>This is an automated message. Please do not reply to this email.</small></p>
                    </div>
                </div>
            </body>
            </html>", HttpUtility.HtmlEncode(userName), resetCode)

                message.Body = emailBody

                Using smtpClient As New SmtpClient(smtpServer, smtpPort)
                    smtpClient.Credentials = New Net.NetworkCredential(smtpUsername, smtpPassword)
                    smtpClient.EnableSsl = enableSSL
                    smtpClient.Timeout = timeout

                    Try
                        smtpClient.Send(message)
                        System.Diagnostics.Debug.WriteLine($"Password reset email sent to {toEmail}")
                        Return True
                    Catch sendEx As SmtpException
                        System.Diagnostics.Debug.WriteLine($"SMTP Error sending to {toEmail}: {sendEx.Message}")
                        Return False
                    End Try
                End Using
            End Using

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"Email configuration error: {ex.Message}")
            System.Diagnostics.Debug.WriteLine($"Stack Trace: {ex.StackTrace}")
            Return False
        End Try
    End Function

    Private Function HashPassword(password As String) As String
        Using sha256 As SHA256 = SHA256.Create()
            Dim bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password))
            Return BitConverter.ToString(bytes).Replace("-", "").ToLower()
        End Using
    End Function
End Class