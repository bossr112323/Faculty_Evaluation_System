Imports System.Data
Imports System.Configuration
Imports MySql.Data.MySqlClient
Imports System.IO

Public Class DownloadGradeFile
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsUserAuthorized() Then
            Response.StatusCode = 403
            Response.Write("Unauthorized access")
            Response.End()
            Return
        End If

        Dim fileID As Integer
        If Not Integer.TryParse(Request.QueryString("fileID"), fileID) Then
            Response.StatusCode = 400
            Response.Write("Invalid file ID")
            Response.End()
            Return
        End If

        DownloadFile(fileID)
    End Sub

    Private Function IsUserAuthorized() As Boolean
        If Session("UserID") Is Nothing Then Return False

        Dim userRole As String = If(Session("Role")?.ToString(), "")
        Return userRole = "Admin" OrElse userRole = "Registrar" OrElse userRole = "Faculty"
    End Function

    Private Sub DownloadFile(fileID As Integer)
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                Dim sql As String = "SELECT FileName, FilePath, MimeType FROM gradefiles WHERE FileID = @FileID"
                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@FileID", fileID)
                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        If rdr.Read() Then
                            Dim fileName As String = If(rdr.IsDBNull(rdr.GetOrdinal("FileName")), "", rdr("FileName").ToString())
                            Dim filePath As String = If(rdr.IsDBNull(rdr.GetOrdinal("FilePath")), "", rdr("FilePath").ToString())
                            Dim mimeType As String = If(rdr.IsDBNull(rdr.GetOrdinal("MimeType")), "application/octet-stream", rdr("MimeType").ToString())

                            If File.Exists(filePath) Then
                                Response.Clear()
                                Response.ContentType = mimeType
                                Response.AppendHeader("Content-Disposition", "attachment; filename=" & fileName)
                                Response.TransmitFile(filePath)
                                Response.Flush()
                            Else
                                Response.StatusCode = 404
                                Response.Write("File not found on server")
                            End If
                        Else
                            Response.StatusCode = 404
                            Response.Write("File record not found")
                        End If
                    End Using
                End Using
            End Using
        Catch ex As Exception
            Response.StatusCode = 500
            Response.Write("Error downloading file: " & ex.Message)
        Finally
            Response.End()
        End Try
    End Sub
End Class