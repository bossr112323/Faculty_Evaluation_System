Imports System.Configuration
Imports System.IO
Imports System.Web.Script.Serialization
Imports MySql.Data.MySqlClient

Public Class Subjects
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Session("Role") Is Nothing OrElse Session("Role").ToString() <> "Admin" Then
                Response.Redirect("~/Login.aspx")
            End If
            lblWelcome.Text = Session("FullName")
            LoadSubjects()
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
    ' ✅ Load subjects with optional search filter
    Private Sub LoadSubjects(Optional searchTerm As String = "")
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "SELECT SubjectID, SubjectCode, SubjectName FROM Subjects"
            If Not String.IsNullOrEmpty(searchTerm) Then
                sql &= " WHERE SubjectCode LIKE @Search OR SubjectName LIKE @Search"
            End If
            sql &= " ORDER BY SubjectName"

            Using cmd As New MySqlCommand(sql, conn)
                If Not String.IsNullOrEmpty(searchTerm) Then
                    cmd.Parameters.AddWithValue("@Search", "%" & searchTerm & "%")
                End If

                Dim da As New MySqlDataAdapter(cmd)
                Dim dt As New DataTable()
                da.Fill(dt)

                gvSubjects.DataSource = dt
                gvSubjects.DataBind()
            End Using
        End Using
    End Sub

    ' ✅ Add new subject
    Protected Sub btnAddSubject_Click(sender As Object, e As EventArgs)
        If txtSubjectCode.Text.Trim() = "" Or txtSubjectName.Text.Trim() = "" Then
            lblMessage.Text = "⚠ Subject code and name cannot be empty."
            lblMessage.CssClass = "alert alert-danger d-block"
            Return
        End If

        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Check duplicates
            Dim checkSql As String = "SELECT COUNT(*) FROM Subjects 
                                  WHERE SubjectCode=@SubjectCode OR SubjectName=@SubjectName"
            Using checkCmd As New MySqlCommand(checkSql, conn)
                checkCmd.Parameters.AddWithValue("@SubjectCode", txtSubjectCode.Text.Trim())
                checkCmd.Parameters.AddWithValue("@SubjectName", txtSubjectName.Text.Trim())
                Dim exists As Integer = Convert.ToInt32(checkCmd.ExecuteScalar())

                If exists > 0 Then
                    lblMessage.Text = "⚠ Subject code or name already exists!"
                    lblMessage.CssClass = "alert alert-warning d-block"
                    Return
                End If
            End Using

            ' Insert if no duplicate
            Dim sql As String = "INSERT INTO Subjects (SubjectCode, SubjectName) 
                             VALUES (@SubjectCode, @SubjectName)"
            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@SubjectCode", txtSubjectCode.Text.Trim())
                cmd.Parameters.AddWithValue("@SubjectName", txtSubjectName.Text.Trim())
                cmd.ExecuteNonQuery()
            End Using
        End Using

        lblMessage.Text = "✅ Subject added successfully!"
        lblMessage.CssClass = "alert alert-success d-block"
        txtSubjectCode.Text = ""
        txtSubjectName.Text = ""
        LoadSubjects()
    End Sub


    ' ✅ Search
    Protected Sub btnSearch_Click(sender As Object, e As EventArgs)
        LoadSubjects(txtSearch.Text.Trim())
    End Sub

    ' ✅ Grid Events
    Protected Sub gvSubjects_PageIndexChanging(sender As Object, e As GridViewPageEventArgs)
        gvSubjects.PageIndex = e.NewPageIndex
        LoadSubjects(txtSearch.Text.Trim())
    End Sub

    Protected Sub gvSubjects_RowEditing(sender As Object, e As GridViewEditEventArgs)
        gvSubjects.EditIndex = e.NewEditIndex
        LoadSubjects(txtSearch.Text.Trim())
    End Sub

    Protected Sub gvSubjects_RowCancelingEdit(sender As Object, e As GridViewCancelEditEventArgs)
        gvSubjects.EditIndex = -1
        LoadSubjects(txtSearch.Text.Trim())
    End Sub

    Protected Sub gvSubjects_RowUpdating(sender As Object, e As GridViewUpdateEventArgs)
        Dim SubjectID As Integer = Convert.ToInt32(gvSubjects.DataKeys(e.RowIndex).Value)
        Dim row As GridViewRow = gvSubjects.Rows(e.RowIndex)
        Dim txtEditSubjectCode As TextBox = CType(row.FindControl("txtEditSubjectCode"), TextBox)
        Dim txtEditSubjectName As TextBox = CType(row.FindControl("txtEditSubjectName"), TextBox)

        Dim SubjectCode As String = txtEditSubjectCode.Text.Trim()
        Dim SubjectName As String = txtEditSubjectName.Text.Trim()

        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' 🔍 Check duplicates, excluding current subject
            Dim checkSql As String = "SELECT COUNT(*) FROM Subjects 
                                  WHERE (SubjectCode=@SubjectCode OR SubjectName=@SubjectName) 
                                  AND SubjectID <> @SubjectID"
            Using checkCmd As New MySqlCommand(checkSql, conn)
                checkCmd.Parameters.AddWithValue("@SubjectCode", SubjectCode)
                checkCmd.Parameters.AddWithValue("@SubjectName", SubjectName)
                checkCmd.Parameters.AddWithValue("@SubjectID", SubjectID)
                Dim exists As Integer = Convert.ToInt32(checkCmd.ExecuteScalar())

                If exists > 0 Then
                    lblMessage.Text = "⚠ Subject code or name already exists!"
                    lblMessage.CssClass = "alert alert-warning d-block"
                    Return
                End If
            End Using

            ' ✅ Update if no duplicate
            Dim sql As String = "UPDATE Subjects 
                             SET SubjectCode=@SubjectCode, SubjectName=@SubjectName 
                             WHERE SubjectID=@SubjectID"
            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@SubjectCode", SubjectCode)
                cmd.Parameters.AddWithValue("@SubjectName", SubjectName)
                cmd.Parameters.AddWithValue("@SubjectID", SubjectID)
                cmd.ExecuteNonQuery()
            End Using
        End Using

        lblMessage.Text = "✅ Subject updated successfully!"
        lblMessage.CssClass = "alert alert-success d-block"
        gvSubjects.EditIndex = -1
        LoadSubjects(txtSearch.Text.Trim())
    End Sub


    Protected Sub gvSubjects_RowDeleting(sender As Object, e As GridViewDeleteEventArgs)
        Try
            ' Double check DataKeys
            If gvSubjects.DataKeys Is Nothing OrElse gvSubjects.DataKeys.Count = 0 Then
                lblMessage.Text = "❌ No DataKeys found. Check GridView DataKeyNames."
                lblMessage.CssClass = "alert alert-danger d-block"
                Return
            End If

            Dim SubjectID As Integer = Convert.ToInt32(gvSubjects.DataKeys(e.RowIndex).Value)

            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                Dim sql As String = "DELETE FROM Subjects WHERE SubjectID=@SubjectID"
                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@SubjectID", SubjectID)
                    cmd.ExecuteNonQuery()
                End Using
            End Using

            lblMessage.Text = "✅ Subject deleted successfully!"
            lblMessage.CssClass = "alert alert-success d-block"
            LoadSubjects(txtSearch.Text.Trim())

        Catch ex As Exception
            lblMessage.Text = "❌ Error deleting subject: " & ex.Message
            lblMessage.CssClass = "alert alert-danger d-block"
        End Try
    End Sub


    ' ========== CSV IMPORT CLASSES ==========
    Private Class ImportResult
        Public Property TotalRecords As Integer
        Public Property Successful As Integer
        Public Property Failed As Integer
        Public Property Duplicates As Integer
        Public Property FailedRecords As New List(Of FailedRecord)
    End Class

    Private Class FailedRecord
        Public Property RowNumber As Integer
        Public Property SubjectCode As String
        Public Property SubjectName As String
        Public Property ErrorMessage As String
    End Class

    Private Class CsvRow
        Public Property RowNumber As Integer
        Public Property SubjectCode As String
        Public Property SubjectName As String
    End Class



    ' ========== CSV IMPORT METHODS ==========
    Protected Sub btnImportCsv_Click(sender As Object, e As EventArgs)
        If Not fuCsvFile.HasFile Then
            lblMessage.Text = "⚠ Please select a CSV file to import."
            lblMessage.CssClass = "alert alert-warning d-block"
            Return
        End If

        ' Validate file type
        If Path.GetExtension(fuCsvFile.FileName).ToLower() <> ".csv" Then
            lblMessage.Text = "⚠ Please upload a CSV file only."
            lblMessage.CssClass = "alert alert-warning d-block"
            Return
        End If

        ' Validate file size (5MB max)
        If fuCsvFile.PostedFile.ContentLength > 5 * 1024 * 1024 Then
            lblMessage.Text = "⚠ File size must be less than 5MB."
            lblMessage.CssClass = "alert alert-warning d-block"
            Return
        End If

        Try
            ' Process the CSV file
            Dim importResult As ImportResult = ProcessCsvImport(fuCsvFile.PostedFile.InputStream)

            ' Store results in hidden fields for client-side display
            Dim serializer As New JavaScriptSerializer()
            hfImportResults.Value = serializer.Serialize(importResult)

            ' Prepare failed records for display as simple list
            If importResult.FailedRecords.Count > 0 Then
                Dim failedRecordsHtml As New StringBuilder()
                For Each failedRecord In importResult.FailedRecords
                    failedRecordsHtml.AppendFormat("<div class='border-bottom pb-1 mb-1'>")
                    failedRecordsHtml.AppendFormat("<strong>Row {0}:</strong> {1} | {2}<br/>",
                                               failedRecord.RowNumber,
                                               Server.HtmlEncode(failedRecord.SubjectCode),
                                               Server.HtmlEncode(failedRecord.SubjectName))
                    failedRecordsHtml.AppendFormat("<small class='text-danger'>{0}</small>",
                                               Server.HtmlEncode(failedRecord.ErrorMessage))
                    failedRecordsHtml.AppendFormat("</div>")
                Next
                hfFailedRecords.Value = failedRecordsHtml.ToString()
            End If

            ' Refresh the subjects grid
            LoadSubjects()

            ' Show success message
            If importResult.Successful > 0 Then
                lblMessage.Text = $"✅ Successfully imported {importResult.Successful} subjects!"
                lblMessage.CssClass = "alert alert-success d-block"
            ElseIf importResult.Duplicates > 0 Then
                lblMessage.Text = $"⚠ Found {importResult.Duplicates} duplicate subjects. No new subjects imported."
                lblMessage.CssClass = "alert alert-warning d-block"
            Else
                lblMessage.Text = "❌ No valid subjects found in the file."
                lblMessage.CssClass = "alert alert-danger d-block"
            End If

        Catch ex As Exception
            lblMessage.Text = "❌ Error importing CSV: " & ex.Message
            lblMessage.CssClass = "alert alert-danger d-block"
        End Try
    End Sub

    Private Function ProcessCsvImport(stream As Stream) As ImportResult
        Dim result As New ImportResult()
        Dim failedRecords As New List(Of FailedRecord)()

        Using reader As New StreamReader(stream)
            Dim lineNumber As Integer = 0
            Dim isFirstLine As Boolean = True

            While Not reader.EndOfStream
                Dim line As String = reader.ReadLine()
                lineNumber += 1

                ' Skip empty lines
                If String.IsNullOrWhiteSpace(line) Then
                    Continue While
                End If

                ' Skip header row
                If isFirstLine Then
                    isFirstLine = False
                    If line.ToLower().Contains("subjectcode") Or line.ToLower().Contains("subjectname") Then
                        Continue While
                    End If
                End If

                result.TotalRecords += 1

                Try
                    ' Simple CSV parsing - split by comma and trim quotes
                    Dim fields = line.Split(","c)
                    If fields.Length < 2 Then
                        failedRecords.Add(New FailedRecord With {
                        .RowNumber = lineNumber,
                        .SubjectCode = "N/A",
                        .SubjectName = "N/A",
                        .ErrorMessage = "Invalid format - expected 2 columns (SubjectCode, SubjectName)"
                    })
                        result.Failed += 1
                        Continue While
                    End If

                    Dim subjectCode As String = fields(0).Trim().Trim(""""c)
                    Dim subjectName As String = fields(1).Trim().Trim(""""c)

                    ' Validate required fields
                    If String.IsNullOrWhiteSpace(subjectCode) OrElse String.IsNullOrWhiteSpace(subjectName) Then
                        failedRecords.Add(New FailedRecord With {
                        .RowNumber = lineNumber,
                        .SubjectCode = subjectCode,
                        .SubjectName = subjectName,
                        .ErrorMessage = "Subject code and name are required"
                    })
                        result.Failed += 1
                        Continue While
                    End If

                    ' Validate field lengths
                    If subjectCode.Length > 50 Then
                        failedRecords.Add(New FailedRecord With {
                        .RowNumber = lineNumber,
                        .SubjectCode = subjectCode,
                        .SubjectName = subjectName,
                        .ErrorMessage = "Subject code must be 50 characters or less"
                    })
                        result.Failed += 1
                        Continue While
                    End If

                    If subjectName.Length > 100 Then
                        failedRecords.Add(New FailedRecord With {
                        .RowNumber = lineNumber,
                        .SubjectCode = subjectCode,
                        .SubjectName = subjectName,
                        .ErrorMessage = "Subject name must be 100 characters or less"
                    })
                        result.Failed += 1
                        Continue While
                    End If

                    ' Check for duplicates and insert
                    Using conn As New MySqlConnection(ConnString)
                        conn.Open()

                        ' Check if subject already exists
                        Dim checkSql As String = "SELECT COUNT(*) FROM Subjects 
                                           WHERE SubjectCode = @SubjectCode OR SubjectName = @SubjectName"
                        Using checkCmd As New MySqlCommand(checkSql, conn)
                            checkCmd.Parameters.AddWithValue("@SubjectCode", subjectCode)
                            checkCmd.Parameters.AddWithValue("@SubjectName", subjectName)
                            Dim exists As Integer = Convert.ToInt32(checkCmd.ExecuteScalar())

                            If exists > 0 Then
                                result.Duplicates += 1
                                Continue While
                            End If
                        End Using

                        ' Insert new subject
                        Dim insertSql As String = "INSERT INTO Subjects (SubjectCode, SubjectName) 
                                           VALUES (@SubjectCode, @SubjectName)"
                        Using insertCmd As New MySqlCommand(insertSql, conn)
                            insertCmd.Parameters.AddWithValue("@SubjectCode", subjectCode)
                            insertCmd.Parameters.AddWithValue("@SubjectName", subjectName)
                            insertCmd.ExecuteNonQuery()
                            result.Successful += 1
                        End Using
                    End Using

                Catch ex As Exception
                    failedRecords.Add(New FailedRecord With {
                    .RowNumber = lineNumber,
                    .SubjectCode = "N/A",
                    .SubjectName = "N/A",
                    .ErrorMessage = "Error processing line: " & ex.Message
                })
                    result.Failed += 1
                End Try
            End While
        End Using

        result.FailedRecords = failedRecords
        Return result
    End Function

    Private Function ParseCsvLine(line As String, lineNumber As Integer) As CsvRow
        Dim fields As List(Of String) = ParseCsvFields(line)

        If fields.Count < 2 Then
            Throw New Exception("Invalid CSV format - expected 2 columns (SubjectCode, SubjectName)")
        End If

        Return New CsvRow With {
            .RowNumber = lineNumber,
            .SubjectCode = If(fields(0), "").Trim(),
            .SubjectName = If(fields(1), "").Trim()
        }
    End Function

    Private Function ParseCsvFields(line As String) As List(Of String)
        Dim fields As New List(Of String)()
        Dim currentField As New StringBuilder()
        Dim inQuotes As Boolean = False
        Dim quoteCount As Integer = 0

        For i As Integer = 0 To line.Length - 1
            Dim c As Char = line(i)

            If c = """"c Then
                If inQuotes AndAlso i < line.Length - 1 AndAlso line(i + 1) = """"c Then
                    ' Escaped quote inside quoted field
                    currentField.Append("""")
                    i += 1 ' Skip next quote
                Else
                    inQuotes = Not inQuotes
                    quoteCount += 1
                End If
            ElseIf c = ","c AndAlso Not inQuotes Then
                ' End of field
                fields.Add(currentField.ToString())
                currentField.Clear()
            Else
                currentField.Append(c)
            End If
        Next

        ' Add the last field
        fields.Add(currentField.ToString())

        ' Remove surrounding quotes if present
        For i As Integer = 0 To fields.Count - 1
            If Not String.IsNullOrEmpty(fields(i)) AndAlso fields(i).StartsWith("""") AndAlso fields(i).EndsWith("""") Then
                fields(i) = fields(i).Substring(1, fields(i).Length - 2)
            End If
        Next

        Return fields
    End Function

    ' ========== TEMPLATE DOWNLOAD ==========
    Protected Sub btnDownloadTemplate_Click(sender As Object, e As EventArgs)
        DownloadCsvTemplate()
    End Sub

    Private Sub DownloadCsvTemplate()
        Response.Clear()
        Response.Buffer = True
        Response.AddHeader("content-disposition", "attachment;filename=Subjects_Import_Template.csv")
        Response.Charset = "UTF-8"
        Response.ContentType = "text/csv"

        Dim sb As New StringBuilder()

        ' Add UTF-8 BOM and header
        sb.Append("SubjectCode,SubjectName")
        sb.AppendLine()

        ' Add sample data
        sb.AppendLine("MATH101,Mathematics 101")
        sb.AppendLine("ENG201,English Composition")
        sb.AppendLine("SCI301,General Science")
        sb.AppendLine("HIST401,World History")
        sb.AppendLine("""CS101"",""Computer Science, Introduction to""") ' Example with quotes and comma in field

        Response.Write(sb.ToString())
        Response.Flush()
        Response.End()
    End Sub

    ' ========== HELPER METHODS ==========
    Private Sub ShowImportError(message As String)
        Dim errorResult As New ImportResult() With {
            .TotalRecords = 0,
            .Successful = 0,
            .Failed = 1,
            .Duplicates = 0
        }

        errorResult.FailedRecords.Add(New FailedRecord With {
            .RowNumber = 1,
            .SubjectCode = "N/A",
            .SubjectName = "N/A",
            .ErrorMessage = message
        })

        Dim serializer As New JavaScriptSerializer()
        hfImportResults.Value = serializer.Serialize(errorResult)
        hfFailedRecords.Value = $"<tr><td>1</td><td>N/A</td><td>N/A</td><td class='text-danger'>{Server.HtmlEncode(message)}</td></tr>"
    End Sub

    Private Sub HandleImportProgress()
        ' This method can be used for real-time progress updates if needed
        ' For now, we'll use the complete results approach
    End Sub

    ' 
End Class
