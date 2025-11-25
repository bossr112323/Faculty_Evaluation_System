Imports MySql.Data.MySqlClient
Imports System.Configuration
Imports System.Security.Cryptography
Imports System.Text

Public Class ChangePassword
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    ' --- Hash password with SHA256 ---
    Private Function HashPassword(password As String) As String
        Using sha256 As SHA256 = SHA256.Create()
            Dim bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password))
            Return BitConverter.ToString(bytes).Replace("-", "").ToLower()
        End Using
    End Function

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Session("SchoolID") Is Nothing OrElse Session("Role") Is Nothing Then
            Response.Redirect("~/Login.aspx")
        End If
    End Sub

    Protected Sub btnChangePassword_Click(sender As Object, e As EventArgs)
        Dim currentPwd As String = txtCurrentPassword.Text.Trim()
        Dim newPwd As String = txtNewPassword.Text.Trim()
        Dim confirmPwd As String = txtConfirmPassword.Text.Trim()

        If String.IsNullOrWhiteSpace(currentPwd) OrElse String.IsNullOrWhiteSpace(newPwd) OrElse String.IsNullOrWhiteSpace(confirmPwd) Then
            lblMessage.Text = "⚠ Please fill in all fields."
            lblMessage.CssClass = "alert alert-danger d-block"
            Return
        End If

        If newPwd.Length < 8 Then
            lblMessage.Text = "⚠ New password must be at least 8 characters long."
            lblMessage.CssClass = "alert alert-danger d-block"
            Return
        End If

        If newPwd <> confirmPwd Then
            lblMessage.Text = "⚠ New password and confirmation do not match."
            lblMessage.CssClass = "alert alert-danger d-block"
            Return
        End If

        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                Dim hashedCurrent As String = HashPassword(currentPwd)
                Dim hashedNew As String = HashPassword(newPwd)

                If Session("Role").ToString().ToUpper() = "STUDENT" Then
                    ' --- Students table ---
                    Dim sqlCheck As String = "SELECT COUNT(*) FROM Students WHERE SchoolID=@sid AND Password=@pwd"
                    Using cmdCheck As New MySqlCommand(sqlCheck, conn)
                        cmdCheck.Parameters.AddWithValue("@sid", Session("SchoolID").ToString())
                        cmdCheck.Parameters.AddWithValue("@pwd", hashedCurrent)
                        Dim count As Integer = Convert.ToInt32(cmdCheck.ExecuteScalar())
                        If count = 0 Then
                            lblMessage.Text = "⚠ Current password is incorrect."
                            lblMessage.CssClass = "alert alert-danger d-block"
                            Return
                        End If
                    End Using

                    Dim sqlUpdate As String = "UPDATE Students SET Password=@newPwd WHERE SchoolID=@sid"
                    Using cmdUpdate As New MySqlCommand(sqlUpdate, conn)
                        cmdUpdate.Parameters.AddWithValue("@newPwd", hashedNew)
                        cmdUpdate.Parameters.AddWithValue("@sid", Session("SchoolID").ToString())
                        cmdUpdate.ExecuteNonQuery()
                    End Using

                Else
                    ' --- Users table (HR, Dean, Faculty) ---
                    Dim sqlCheck As String = "SELECT COUNT(*) FROM Users WHERE SchoolID=@sid AND Password=@pwd"
                    Using cmdCheck As New MySqlCommand(sqlCheck, conn)
                        cmdCheck.Parameters.AddWithValue("@sid", Session("SchoolID").ToString())
                        cmdCheck.Parameters.AddWithValue("@pwd", hashedCurrent)
                        Dim count As Integer = Convert.ToInt32(cmdCheck.ExecuteScalar())
                        If count = 0 Then
                            lblMessage.Text = "⚠ Current password is incorrect."
                            lblMessage.CssClass = "alert alert-danger d-block"
                            Return
                        End If
                    End Using

                    Dim sqlUpdate As String = "UPDATE Users SET Password=@newPwd WHERE SchoolID=@sid"
                    Using cmdUpdate As New MySqlCommand(sqlUpdate, conn)
                        cmdUpdate.Parameters.AddWithValue("@newPwd", hashedNew)
                        cmdUpdate.Parameters.AddWithValue("@sid", Session("SchoolID").ToString())
                        cmdUpdate.ExecuteNonQuery()
                    End Using
                End If
            End Using

            lblMessage.Text = "✅ Password changed successfully!"
            lblMessage.CssClass = "alert alert-success d-block"

            txtCurrentPassword.Text = ""
            txtNewPassword.Text = ""
            txtConfirmPassword.Text = ""

        Catch ex As Exception
            lblMessage.Text = "⚠ Error: " & ex.Message
            lblMessage.CssClass = "alert alert-danger d-block"
        End Try
    End Sub
End Class
