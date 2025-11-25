Imports System.Data
Imports System.Configuration
Imports MySql.Data.MySqlClient
Imports System.Web.Services
Imports System.Web.Script.Services
Imports System.Web
Imports System.IO
Imports System.Web.Script.Serialization

Public Class GradeSubmission
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsUserAuthorized() Then
            Response.Redirect("~/Login.aspx")
            Return
        End If

        If Not IsPostBack Then
            LoadFacultyInfo()
        End If
    End Sub
    Private Sub LoadFacultyInfo()
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim sql As String = "
        SELECT 
            CONCAT(u.FirstName, ' ', 
                   CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial <> '' THEN CONCAT(u.MiddleInitial, '. ') ELSE '' END,
                   u.LastName,
                   CASE WHEN u.Suffix IS NOT NULL AND u.Suffix <> '' THEN CONCAT(' ', u.Suffix) ELSE '' END
            ) AS FullName, 
            d.DepartmentName
        FROM Users u
        LEFT JOIN Departments d ON u.DepartmentID = d.DepartmentID
        WHERE u.UserID=@uid AND u.Role='Faculty' LIMIT 1"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@uid", Session("UserID"))
                Using rdr As MySqlDataReader = cmd.ExecuteReader()
                    If rdr.Read() Then
                        lblFacultyName.Text = GetSafeString(rdr, "FullName")
                        lblDepartment.Text = GetSafeString(rdr, "DepartmentName", "N/A")
                    End If
                End Using
            End Using
        End Using
    End Sub

    ' Add these helper methods if they don't exist
    Private Function GetSafeString(rdr As MySqlDataReader, columnName As String, Optional defaultValue As String = "") As String
        Try
            Dim ordinal As Integer = rdr.GetOrdinal(columnName)
            If rdr.IsDBNull(ordinal) Then
                Return defaultValue
            Else
                Return rdr(columnName).ToString()
            End If
        Catch ex As Exception
            Return defaultValue
        End Try
    End Function


    Private Function IsUserAuthorized() As Boolean
        Try
            If Session("UserID") Is Nothing Then Return False
            If Session("Role") Is Nothing Then Return False
            Dim userRole As String = Session("Role").ToString()
            Return userRole = "Faculty"
        Catch ex As Exception
            Return False
        End Try
    End Function



    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetFacultyClasses(facultyID As Integer) As String
        Dim result As New WebMethodResult(Of List(Of ClassInfo))()
        Try
            Dim classes As New List(Of ClassInfo)()
            Dim connStr As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

            Using conn As New MySqlConnection(connStr)
                conn.Open()

                ' Get the latest evaluation cycle (regardless of active status)
                Dim latestCycle As CycleInfo = GetLatestEvaluationCycle(conn)

                If latestCycle Is Nothing Then
                    result.Success = False
                    result.Message = "No evaluation cycle found"
                    Return New JavaScriptSerializer().Serialize(result)
                End If

                Dim sql As String = "
            SELECT fl.LoadID, s.SubjectCode, s.SubjectName, c.YearLevel, c.Section, 
                   co.CourseName, fl.Term,
                   CASE WHEN gs.SubmissionID IS NOT NULL THEN 1 ELSE 0 END AS GradeSubmitted
            FROM facultyload fl
            INNER JOIN subjects s ON fl.SubjectID = s.SubjectID
            INNER JOIN classes c ON fl.ClassID = c.ClassID
            INNER JOIN courses co ON fl.CourseID = co.CourseID
            LEFT JOIN gradesubmissions gs ON fl.LoadID = gs.LoadID 
                AND gs.CycleID = @CycleID
            WHERE fl.FacultyID = @FacultyID AND fl.Term = @CurrentTerm AND fl.IsDeleted = 0
            ORDER BY s.SubjectCode"

                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                    cmd.Parameters.AddWithValue("@CurrentTerm", latestCycle.Term)
                    cmd.Parameters.AddWithValue("@CycleID", latestCycle.CycleID)
                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        While rdr.Read()
                            classes.Add(New ClassInfo() With {
                            .LoadID = SafeGetInt(rdr, "LoadID"),
                            .SubjectCode = SafeGetString(rdr, "SubjectCode"),
                            .SubjectName = SafeGetString(rdr, "SubjectName"),
                            .YearLevel = SafeGetString(rdr, "YearLevel"),
                            .Section = SafeGetString(rdr, "Section"),
                            .CourseName = SafeGetString(rdr, "CourseName"),
                            .GradeSubmitted = SafeGetInt(rdr, "GradeSubmitted") = 1
                        })
                        End While
                    End Using
                End Using
            End Using

            result.Success = True
            result.Data = classes

        Catch ex As Exception
            result.Success = False
            result.Message = "Error loading classes: " & ex.Message
        End Try

        Return New JavaScriptSerializer().Serialize(result)
    End Function
    Private Shared Function GetLatestEvaluationCycle(conn As MySqlConnection) As CycleInfo
        Try
            ' Get the latest evaluation cycle by StartDate, regardless of active status
            Dim sql As String = "SELECT CycleID, CycleName, Term, StartDate, EndDate, Status " &
                      "FROM evaluationcycles " &
                      "WHERE IsActive = 1 " &
                      "ORDER BY StartDate DESC LIMIT 1"

            Using cmd As New MySqlCommand(sql, conn)
                Using rdr As MySqlDataReader = cmd.ExecuteReader()
                    If rdr.Read() Then
                        Return New CycleInfo() With {
                        .CycleID = SafeGetInt(rdr, "CycleID"),
                        .CycleName = SafeGetString(rdr, "CycleName"),
                        .Term = SafeGetString(rdr, "Term"),
                        .StartDate = SafeGetString(rdr, "StartDate"),
                        .EndDate = SafeGetString(rdr, "EndDate")
                    }
                    End If
                End Using
            End Using

            ' If no active cycle found, get the most recent one by date
            sql = "SELECT CycleID, CycleName, Term, StartDate, EndDate, Status " &
              "FROM evaluationcycles " &
              "ORDER BY StartDate DESC LIMIT 1"

            Using cmd As New MySqlCommand(sql, conn)
                Using rdr As MySqlDataReader = cmd.ExecuteReader()
                    If rdr.Read() Then
                        Return New CycleInfo() With {
                        .CycleID = SafeGetInt(rdr, "CycleID"),
                        .CycleName = SafeGetString(rdr, "CycleName"),
                        .Term = SafeGetString(rdr, "Term"),
                        .StartDate = SafeGetString(rdr, "StartDate"),
                        .EndDate = SafeGetString(rdr, "EndDate")
                    }
                    End If
                End Using
            End Using

            Return Nothing
        Catch ex As Exception
            Return Nothing
        End Try
    End Function
    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetEvaluationCycles() As String
        Dim result As New WebMethodResult(Of List(Of CycleInfo))()
        Try
            Dim cycles As New List(Of CycleInfo)()
            Dim connStr As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

            Using conn As New MySqlConnection(connStr)
                conn.Open()
                ' Get all active cycles ordered by start date (newest first)
                Dim sql As String = "SELECT CycleID, CycleName, Term, StartDate, EndDate " &
                              "FROM evaluationcycles WHERE IsActive = 1 " &
                              "ORDER BY StartDate DESC"

                Using cmd As New MySqlCommand(sql, conn)
                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        While rdr.Read()
                            cycles.Add(New CycleInfo() With {
                            .CycleID = SafeGetInt(rdr, "CycleID"),
                            .CycleName = SafeGetString(rdr, "CycleName"),
                            .Term = SafeGetString(rdr, "Term"),
                            .StartDate = SafeGetString(rdr, "StartDate"),
                            .EndDate = SafeGetString(rdr, "EndDate")
                        })
                        End While
                    End Using
                End Using
            End Using

            result.Success = True
            result.Data = cycles

        Catch ex As Exception
            result.Success = False
            result.Message = "Error loading evaluation cycles: " & ex.Message
        End Try

        Return New JavaScriptSerializer().Serialize(result)
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetSubmissionHistoryByCycle(facultyID As Integer) As String
        Dim result As New WebMethodResult(Of List(Of CycleHistory))()
        Try
            Dim cycles As New List(Of CycleHistory)()
            Dim connStr As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

            Using conn As New MySqlConnection(connStr)
                conn.Open()

                ' Only include PAST evaluation cycles (EndDate < today)
                ' This excludes the current active cycle
                Dim sql As String = "
        SELECT 
            ec.CycleID,
            ec.CycleName,
            ec.Term,
            ec.StartDate,
            ec.EndDate,
            COUNT(gs.SubmissionID) as SubmissionCount,
            MAX(gs.SubmissionDate) as LatestSubmission,
            SUM(CASE WHEN gs.Status = 'Confirmed' THEN 1 ELSE 0 END) as ApprovedCount,
            SUM(CASE WHEN gs.Status = 'Rejected' THEN 1 ELSE 0 END) as RejectedCount,
            SUM(CASE WHEN gs.Status = 'Submitted' THEN 1 ELSE 0 END) as PendingCount
        FROM evaluationcycles ec
        INNER JOIN gradesubmissions gs ON ec.CycleID = gs.CycleID
        INNER JOIN facultyload fl ON gs.LoadID = fl.LoadID
        WHERE fl.FacultyID = @FacultyID 
          AND ec.EndDate < CURDATE()  -- Only PAST cycles (excludes current cycle)
        GROUP BY ec.CycleID, ec.CycleName, ec.Term, ec.StartDate, ec.EndDate
        ORDER BY ec.StartDate DESC"

                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        While rdr.Read()
                            Dim startDateObj As Object = rdr("StartDate")
                            Dim endDateObj As Object = rdr("EndDate")
                            Dim latestSubmissionObj As Object = rdr("LatestSubmission")

                            cycles.Add(New CycleHistory() With {
                            .CycleID = SafeGetInt(rdr, "CycleID"),
                            .CycleName = SafeGetString(rdr, "CycleName"),
                            .Term = SafeGetString(rdr, "Term"),
                            .StartDate = If(startDateObj Is DBNull.Value, Nothing, startDateObj.ToString()),
                            .EndDate = If(endDateObj Is DBNull.Value, Nothing, endDateObj.ToString()),
                            .SubmissionCount = SafeGetInt(rdr, "SubmissionCount"),
                            .LatestSubmission = If(latestSubmissionObj Is DBNull.Value, Nothing, latestSubmissionObj.ToString()),
                            .ApprovedCount = SafeGetInt(rdr, "ApprovedCount"),
                            .RejectedCount = SafeGetInt(rdr, "RejectedCount"),
                            .PendingCount = SafeGetInt(rdr, "PendingCount")
                        })
                        End While
                    End Using
                End Using
            End Using

            result.Success = True
            result.Data = cycles

        Catch ex As Exception
            result.Success = False
            result.Message = "Error loading submission history by cycle: " & ex.Message
        End Try

        Return New JavaScriptSerializer().Serialize(result)
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetSubmissionHistory(facultyID As Integer) As String
        Dim result As New WebMethodResult(Of List(Of SubmissionHistory))()
        Dim submissions As New List(Of SubmissionHistory)()

        Try
            Dim connStr As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

            Using conn As New MySqlConnection(connStr)
                conn.Open()

                ' Updated SQL query with all necessary joins for class details
                Dim sql As String = "
        SELECT 
            gs.SubmissionID, 
            DATE_FORMAT(gs.SubmissionDate, '%Y-%m-%d %H:%i:%s') AS SubmissionDate, 
            gs.Status, 
            gs.Remarks,
            s.SubjectCode, 
            s.SubjectName, 
            fl.LoadID, 
            ec.CycleID,
            ec.CycleName, 
            ec.Term,
            gf.FileID,
            gf.FileName,
            gf.FilePath,
            gf.FileSize,
            gf.MimeType,
            DATE_FORMAT(gf.SubmissionDate, '%Y-%m-%d %H:%i:%s') as FileSubmissionDate,
            -- Class details
            co.CourseName,
            c.YearLevel,
            c.Section
        FROM gradesubmissions gs
        INNER JOIN facultyload fl ON gs.LoadID = fl.LoadID
        INNER JOIN subjects s ON fl.SubjectID = s.SubjectID
        INNER JOIN evaluationcycles ec ON gs.CycleID = ec.CycleID
        LEFT JOIN gradefiles gf ON gs.FileID = gf.FileID
        -- Joins for class details
        INNER JOIN classes c ON fl.ClassID = c.ClassID
        INNER JOIN courses co ON fl.CourseID = co.CourseID
        WHERE fl.FacultyID = @FacultyID
          AND ec.EndDate < CURDATE()  -- Only PAST cycles (excludes current cycle)
        ORDER BY ec.CycleID DESC, gs.SubmissionDate DESC"

                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@FacultyID", facultyID)

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        While rdr.Read()
                            Dim submission As New SubmissionHistory() With {
                            .SubmissionID = SafeGetInt(rdr, "SubmissionID"),
                            .SubmissionDate = SafeGetDateTimeString(rdr, "SubmissionDate"),
                            .Status = SafeGetString(rdr, "Status"),
                            .Remarks = SafeGetString(rdr, "Remarks"),
                            .SubjectCode = SafeGetString(rdr, "SubjectCode"),
                            .SubjectName = SafeGetString(rdr, "SubjectName"),
                            .LoadID = SafeGetInt(rdr, "LoadID"),
                            .CycleID = SafeGetInt(rdr, "CycleID"),
                            .CycleName = SafeGetString(rdr, "CycleName"),
                            .Term = SafeGetString(rdr, "Term"),
                            .FileID = SafeGetInt(rdr, "FileID"),
                            .FileName = SafeGetString(rdr, "FileName"),
                            .FilePath = SafeGetString(rdr, "FilePath"),
                            .FileSize = SafeGetInt(rdr, "FileSize"),
                            .MimeType = SafeGetString(rdr, "MimeType"),
                            .FileSubmissionDate = SafeGetDateTimeString(rdr, "FileSubmissionDate"),
                            .CourseName = SafeGetString(rdr, "CourseName"),
                            .YearLevel = SafeGetString(rdr, "YearLevel"),
                            .Section = SafeGetString(rdr, "Section")
                        }

                            submissions.Add(submission)
                        End While
                    End Using
                End Using
            End Using

            result.Success = True
            result.Data = submissions

        Catch ex As Exception
            result.Success = False
            result.Message = "Error loading submission history: " & ex.Message

            ' Log detailed error for debugging
            System.Diagnostics.Debug.WriteLine("GetSubmissionHistory Error: " & ex.ToString())
            System.Diagnostics.Debug.WriteLine("Stack Trace: " & ex.StackTrace)
        End Try

        Return New JavaScriptSerializer().Serialize(result)
    End Function
    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetAllSubmissionsForClass(loadID As Integer) As String
        Dim result As New WebMethodResult(Of SubmissionHistory)()
        Try
            Dim submission As SubmissionHistory = Nothing
            Dim connStr As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

            Using conn As New MySqlConnection(connStr)
                conn.Open()

                ' Get the latest submission for this specific class (regardless of cycle status)
                Dim sql As String = "
        SELECT 
            gs.SubmissionID, 
            DATE_FORMAT(gs.SubmissionDate, '%Y-%m-%d %H:%i:%s') AS SubmissionDate, 
            gs.Status, 
            gs.Remarks,
            s.SubjectCode, 
            s.SubjectName, 
            fl.LoadID, 
            ec.CycleID,
            ec.CycleName, 
            ec.Term,
            gf.FileID,
            gf.FileName,
            gf.FilePath,
            gf.FileSize,
            gf.MimeType,
            DATE_FORMAT(gf.SubmissionDate, '%Y-%m-%d %H:%i:%s') as FileSubmissionDate
        FROM gradesubmissions gs
        INNER JOIN facultyload fl ON gs.LoadID = fl.LoadID
        INNER JOIN subjects s ON fl.SubjectID = s.SubjectID
        INNER JOIN evaluationcycles ec ON gs.CycleID = ec.CycleID
        LEFT JOIN gradefiles gf ON gs.FileID = gf.FileID
        WHERE fl.LoadID = @LoadID
        ORDER BY gs.SubmissionDate DESC
        LIMIT 1"

                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@LoadID", loadID)
                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        If rdr.Read() Then
                            submission = New SubmissionHistory() With {
                            .SubmissionID = SafeGetInt(rdr, "SubmissionID"),
                            .SubmissionDate = SafeGetDateTimeString(rdr, "SubmissionDate"),
                            .Status = SafeGetString(rdr, "Status"),
                            .Remarks = SafeGetString(rdr, "Remarks"),
                            .SubjectCode = SafeGetString(rdr, "SubjectCode"),
                            .SubjectName = SafeGetString(rdr, "SubjectName"),
                            .LoadID = SafeGetInt(rdr, "LoadID"),
                            .CycleID = SafeGetInt(rdr, "CycleID"),
                            .CycleName = SafeGetString(rdr, "CycleName"),
                            .Term = SafeGetString(rdr, "Term"),
                            .FileID = SafeGetInt(rdr, "FileID"),
                            .FileName = SafeGetString(rdr, "FileName"),
                            .FilePath = SafeGetString(rdr, "FilePath"),
                            .FileSize = SafeGetInt(rdr, "FileSize"),
                            .MimeType = SafeGetString(rdr, "MimeType"),
                            .FileSubmissionDate = SafeGetDateTimeString(rdr, "FileSubmissionDate")
                        }
                        End If
                    End Using
                End Using
            End Using

            If submission IsNot Nothing Then
                result.Success = True
                result.Data = submission
            Else
                result.Success = False
                result.Message = "No submission found for this class"
            End If

        Catch ex As Exception
            result.Success = False
            result.Message = "Error loading class submission: " & ex.Message
        End Try

        Return New JavaScriptSerializer().Serialize(result)
    End Function
    Private Shared Function SafeGetDateTimeString(rdr As MySqlDataReader, columnName As String, Optional defaultValue As String = "") As String
        Try
            Dim ordinal As Integer = rdr.GetOrdinal(columnName)
            If rdr.IsDBNull(ordinal) Then
                Return defaultValue
            Else
                ' Get the DateTime value and format it properly
                Dim dateValue As DateTime = rdr.GetDateTime(ordinal)
                Return dateValue.ToString("yyyy-MM-dd HH:mm:ss")
            End If
        Catch ex As Exception
            Return defaultValue
        End Try
    End Function
    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetFileDownloadUrl(fileID As Integer) As String
        Dim result As New WebMethodResult(Of String)()
        Try
            Dim connStr As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

            Using conn As New MySqlConnection(connStr)
                conn.Open()
                Dim sql As String = "SELECT FilePath, FileName FROM gradefiles WHERE FileID = @FileID"

                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@FileID", fileID)
                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        If rdr.Read() Then
                            Dim filePath As String = SafeGetString(rdr, "FilePath")
                            Dim fileName As String = SafeGetString(rdr, "FileName")

                            ' Convert physical path to virtual path for download
                            If File.Exists(filePath) Then
                                ' Create a download handler URL
                                result.Success = True
                                result.Data = $"FileDownload.ashx?fileId={fileID}"
                            Else
                                result.Success = False
                                result.Message = "File not found on server"
                            End If
                        Else
                            result.Success = False
                            result.Message = "File record not found"
                        End If
                    End Using
                End Using
            End Using

        Catch ex As Exception
            result.Success = False
            result.Message = "Error accessing file: " & ex.Message
        End Try

        Return New JavaScriptSerializer().Serialize(result)
    End Function
    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function SubmitGradeFile(loadID As Integer, cycleID As Integer, facultyID As Integer, fileName As String, fileContent As String) As String
        Dim result As New WebMethodResult()
        Dim conn As MySqlConnection = Nothing
        Dim transaction As MySqlTransaction = Nothing

        Try
            Dim connStr As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
            conn = New MySqlConnection(connStr)
            conn.Open()

            ' Start transaction
            transaction = conn.BeginTransaction()

            ' Verify faculty owns this load
            Dim verifySql As String = "SELECT COUNT(*) FROM facultyload WHERE LoadID = @LoadID AND FacultyID = @FacultyID AND IsDeleted = 0"
            Using cmdVerify As New MySqlCommand(verifySql, conn, transaction)
                cmdVerify.Parameters.AddWithValue("@LoadID", loadID)
                cmdVerify.Parameters.AddWithValue("@FacultyID", facultyID)
                Dim count As Integer = Convert.ToInt32(cmdVerify.ExecuteScalar())

                If count = 0 Then
                    transaction.Rollback()
                    result.Success = False
                    result.Message = "Unauthorized: You don't have access to this class or class doesn't exist"
                    Return New JavaScriptSerializer().Serialize(result)
                End If
            End Using

            ' Verify cycle exists and is active
            Dim cycleSql As String = "SELECT COUNT(*) FROM evaluationcycles WHERE CycleID = @CycleID AND IsActive = 1"
            Using cmdCycle As New MySqlCommand(cycleSql, conn, transaction)
                cmdCycle.Parameters.AddWithValue("@CycleID", cycleID)
                Dim cycleCount As Integer = Convert.ToInt32(cmdCycle.ExecuteScalar())

                If cycleCount = 0 Then
                    transaction.Rollback()
                    result.Success = False
                    result.Message = "Invalid evaluation cycle or cycle is not active"
                    Return New JavaScriptSerializer().Serialize(result)
                End If
            End Using

            ' Generate unique filename
            Dim fileExtension As String = System.IO.Path.GetExtension(fileName)
            Dim uniqueFileName As String = Guid.NewGuid().ToString() & fileExtension

            ' Use Server-relative path instead of absolute path
            Dim uploadFolder As String = HttpContext.Current.Server.MapPath("~/Uploads/GradeSheets/")

            ' Create directory if it doesn't exist
            If Not System.IO.Directory.Exists(uploadFolder) Then
                System.IO.Directory.CreateDirectory(uploadFolder)
            End If

            Dim filePath As String = System.IO.Path.Combine(uploadFolder, uniqueFileName)

            ' Convert base64 to file and save
            If String.IsNullOrEmpty(fileContent) Then
                transaction.Rollback()
                result.Success = False
                result.Message = "File content is empty"
                Return New JavaScriptSerializer().Serialize(result)
            End If

            Dim fileBytes As Byte() = Convert.FromBase64String(fileContent)
            System.IO.File.WriteAllBytes(filePath, fileBytes)

            ' Check if file was actually written
            If Not System.IO.File.Exists(filePath) Then
                transaction.Rollback()
                result.Success = False
                result.Message = "Failed to save file to server"
                Return New JavaScriptSerializer().Serialize(result)
            End If

            ' Insert into grade_files table
            Dim fileID As Integer = 0
            Dim fileSql As String = "INSERT INTO gradefiles (LoadID, CycleID, FileName, FilePath, FileSize, MimeType, SubmissionDate, Status) " &
                          "VALUES (@LoadID, @CycleID, @FileName, @FilePath, @FileSize, @MimeType, NOW(), 'Pending'); SELECT LAST_INSERT_ID();"

            Using cmdFile As New MySqlCommand(fileSql, conn, transaction)
                cmdFile.Parameters.AddWithValue("@LoadID", loadID)
                cmdFile.Parameters.AddWithValue("@CycleID", cycleID)
                cmdFile.Parameters.AddWithValue("@FileName", fileName)
                cmdFile.Parameters.AddWithValue("@FilePath", filePath)
                cmdFile.Parameters.AddWithValue("@FileSize", fileBytes.Length)
                cmdFile.Parameters.AddWithValue("@MimeType", GetMimeType(fileExtension))
                fileID = Convert.ToInt32(cmdFile.ExecuteScalar())
            End Using

            ' Check if existing submission exists for this load and cycle
            Dim checkExistingSql As String = "SELECT SubmissionID, FileID FROM gradesubmissions WHERE LoadID = @LoadID AND CycleID = @CycleID"
            Dim existingSubmissionID As Integer = 0
            Dim existingFileID As Integer = 0

            Using cmdCheck As New MySqlCommand(checkExistingSql, conn, transaction)
                cmdCheck.Parameters.AddWithValue("@LoadID", loadID)
                cmdCheck.Parameters.AddWithValue("@CycleID", cycleID)
                Using rdr As MySqlDataReader = cmdCheck.ExecuteReader()
                    If rdr.Read() Then
                        existingSubmissionID = SafeGetInt(rdr, "SubmissionID")
                        existingFileID = SafeGetInt(rdr, "FileID")
                    End If
                End Using
            End Using

            If existingSubmissionID > 0 Then
                ' Update existing submission
                Dim updateSql As String = "UPDATE gradesubmissions SET SubmissionDate = NOW(), Status = 'Submitted', FileID = @FileID WHERE SubmissionID = @SubmissionID"
                Using cmdUpdate As New MySqlCommand(updateSql, conn, transaction)
                    cmdUpdate.Parameters.AddWithValue("@FileID", fileID)
                    cmdUpdate.Parameters.AddWithValue("@SubmissionID", existingSubmissionID)
                    cmdUpdate.ExecuteNonQuery()
                End Using

                ' Delete old file record if it exists
                If existingFileID > 0 Then
                    Dim deleteFileSql As String = "DELETE FROM gradefiles WHERE FileID = @FileID"
                    Using cmdDelete As New MySqlCommand(deleteFileSql, conn, transaction)
                        cmdDelete.Parameters.AddWithValue("@FileID", existingFileID)
                        cmdDelete.ExecuteNonQuery()
                    End Using
                End If
            Else
                ' Insert new submission
                Dim insertSql As String = "INSERT INTO gradesubmissions (LoadID, CycleID, SubmissionDate, Status, SubmittedBy, FileID) " &
                               "VALUES (@LoadID, @CycleID, NOW(), 'Submitted', @FacultyID, @FileID)"
                Using cmdInsert As New MySqlCommand(insertSql, conn, transaction)
                    cmdInsert.Parameters.AddWithValue("@LoadID", loadID)
                    cmdInsert.Parameters.AddWithValue("@CycleID", cycleID)
                    cmdInsert.Parameters.AddWithValue("@FacultyID", facultyID)
                    cmdInsert.Parameters.AddWithValue("@FileID", fileID)
                    cmdInsert.ExecuteNonQuery()
                End Using
            End If

            ' Commit transaction
            transaction.Commit()

            result.Success = True
            result.Message = "Grade sheet submitted successfully!"

        Catch ex As Exception
            ' Rollback transaction in case of error
            If transaction IsNot Nothing Then
                Try
                    transaction.Rollback()
                Catch rollbackEx As Exception
                    ' Log rollback error but don't throw
                End Try
            End If

            result.Success = False
            result.Message = "Error submitting grade sheet: " & ex.Message

            ' Log the full exception details for debugging
            System.Diagnostics.Debug.WriteLine("SubmitGradeFile Error: " & ex.ToString())

        Finally
            If conn IsNot Nothing Then
                conn.Close()
            End If
        End Try

        Return New JavaScriptSerializer().Serialize(result)
    End Function

    Private Shared Function GetMimeType(fileExtension As String) As String
        Select Case fileExtension.ToLower()
            Case ".xlsx"
                Return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            Case ".xls"
                Return "application/vnd.ms-excel"
            Case ".csv"
                Return "text/csv"
            Case Else
                Return "application/octet-stream"
        End Select
    End Function

    ' Utility methods
    Private Shared Function GetCurrentTerm(conn As MySqlConnection) As String
        Try
            Dim sql As String = "SELECT Term FROM evaluationcycles WHERE Status='Active' LIMIT 1"
            Using cmd As New MySqlCommand(sql, conn)
                Dim result = cmd.ExecuteScalar()
                Return If(result?.ToString(), "")
            End Using
        Catch
            Return ""
        End Try
    End Function

    Private Shared Function SafeGetString(rdr As MySqlDataReader, fieldName As String) As String
        Try
            Dim ordinal As Integer = rdr.GetOrdinal(fieldName)
            Return If(rdr.IsDBNull(ordinal), "", rdr.GetString(ordinal))
        Catch
            Return ""
        End Try
    End Function

    Private Shared Function SafeGetInt(rdr As MySqlDataReader, fieldName As String) As Integer
        Try
            Dim ordinal As Integer = rdr.GetOrdinal(fieldName)
            Return If(rdr.IsDBNull(ordinal), 0, rdr.GetInt32(ordinal))
        Catch
            Return 0
        End Try
    End Function

    Protected Sub btnLogout_Click(sender As Object, e As EventArgs)
        Session.Clear()
        Session.Abandon()
        Response.Redirect("~/Login.aspx")
    End Sub
    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetLatestEvaluationCycle() As String
        Dim result As New WebMethodResult(Of CycleInfo)()
        Try
            Dim connStr As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

            Using conn As New MySqlConnection(connStr)
                conn.Open()

                ' Get the latest evaluation cycle by StartDate, regardless of active status
                Dim sql As String = "SELECT CycleID, CycleName, Term, StartDate, EndDate, Status " &
                          "FROM evaluationcycles " &
                          "ORDER BY StartDate DESC LIMIT 1"

                Using cmd As New MySqlCommand(sql, conn)
                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        If rdr.Read() Then
                            result.Data = New CycleInfo() With {
                            .CycleID = SafeGetInt(rdr, "CycleID"),
                            .CycleName = SafeGetString(rdr, "CycleName"),
                            .Term = SafeGetString(rdr, "Term"),
                            .StartDate = SafeGetString(rdr, "StartDate"),
                            .EndDate = SafeGetString(rdr, "EndDate"),
                            .Status = SafeGetString(rdr, "Status")
                        }
                            result.Success = True
                        Else
                            result.Success = False
                            result.Message = "No evaluation cycle found"
                        End If
                    End Using
                End Using
            End Using

        Catch ex As Exception
            result.Success = False
            result.Message = "Error loading latest evaluation cycle: " & ex.Message
        End Try

        Return New JavaScriptSerializer().Serialize(result)
    End Function
    ' Data Classes
    Public Class ClassInfo
        Public Property LoadID As Integer
        Public Property SubjectCode As String
        Public Property SubjectName As String
        Public Property YearLevel As String
        Public Property Section As String
        Public Property CourseName As String
        Public Property GradeSubmitted As Boolean
    End Class
    Public Class CycleHistory
        Public Property CycleID As Integer
        Public Property CycleName As String
        Public Property Term As String
        Public Property StartDate As String
        Public Property EndDate As String
        Public Property SubmissionCount As Integer
        Public Property LatestSubmission As String
        Public Property ApprovedCount As Integer
        Public Property RejectedCount As Integer
        Public Property PendingCount As Integer
    End Class

    Public Class CycleSubmissions
        Public Property CycleID As Integer
        Public Property Submissions As List(Of SubmissionHistory)
    End Class
    Public Class CycleInfo
        Public Property CycleID As Integer
        Public Property CycleName As String
        Public Property Term As String
        Public Property StartDate As String
        Public Property EndDate As String
        Public Property Status As String ' Add this property
    End Class

    Public Class SubmissionHistory
        Public Property SubmissionID As Integer
        Public Property SubmissionDate As String
        Public Property Status As String
        Public Property Remarks As String
        Public Property SubjectCode As String
        Public Property SubjectName As String
        Public Property LoadID As Integer
        Public Property CycleID As Integer
        Public Property CycleName As String
        Public Property Term As String
        Public Property FileID As Integer
        Public Property FileName As String
        Public Property FilePath As String
        Public Property FileSize As Integer
        Public Property MimeType As String
        Public Property FileSubmissionDate As String
        ' Class details
        Public Property CourseName As String
        Public Property YearLevel As String
        Public Property Section As String
    End Class

    Public Class WebMethodResult
        Public Property Success As Boolean
        Public Property Message As String
    End Class

    Public Class WebMethodResult(Of T)
        Inherits WebMethodResult
        Public Property Data As T
    End Class
End Class


