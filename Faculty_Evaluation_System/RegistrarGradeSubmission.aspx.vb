Imports System.Data
Imports System.Configuration
Imports MySql.Data.MySqlClient
Imports System.Web.Services
Imports System.Web.Script.Services
Imports System.Web.Script.Serialization

Public Class RegistrarGradeSubmission
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
            LoadCurrentCycleInfo()
            LoadDepartments()
            LoadFacultyData()
            lblRegistrarName.Text = If(Session("FullName"), "Registrar")
        End If
    End Sub

    Private Function IsUserAuthorized() As Boolean
        If Session("UserID") Is Nothing Then Return False

        Dim userRole As String = If(Session("Role")?.ToString(), "")
        If userRole = "Admin" OrElse userRole = "Registrar" Then Return True

        Session.Clear()
        Session.Abandon()
        Return False
    End Function

#Region "Current Submissions"

    Private Sub LoadCurrentCycleInfo()
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                ' Get the most recent cycle (current), not just active ones
                Dim sql As String = "SELECT CycleName, Term, StartDate, EndDate, Status FROM evaluationcycles WHERE IsActive = 1 ORDER BY CycleID DESC LIMIT 1"
                Using cmd As New MySqlCommand(sql, conn)
                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        If rdr.Read() Then
                            Dim cycleName = SafeGetString(rdr, "CycleName")
                            Dim term = SafeGetString(rdr, "Term")
                            Dim startDate = SafeGetDateTime(rdr, "StartDate")
                            Dim endDate = SafeGetDateTime(rdr, "EndDate")
                            Dim status = SafeGetString(rdr, "Status")

                            lblCurrentCycle.Text = $"{cycleName} - {term}"

                            ' Add status indicator
                            If status = "Active" Then
                                lblCurrentCycle.Text += " <span class='badge bg-success'>Active</span>"
                            Else
                                lblCurrentCycle.Text += " <span class='badge bg-secondary'>Ended</span>"
                            End If
                        Else
                            lblCurrentCycle.Text = "No Evaluation Cycle Found"
                        End If
                    End Using
                End Using
            End Using
        Catch ex As Exception
            lblCurrentCycle.Text = "Error Loading Cycle Info"
        End Try
    End Sub

    Private Sub LoadDepartments()
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                Dim sql As String = "SELECT DepartmentID, DepartmentName FROM departments WHERE IsActive = 1 ORDER BY DepartmentName"
                Using cmd As New MySqlCommand(sql, conn)
                    Using da As New MySqlDataAdapter(cmd)
                        Dim dt As New DataTable()
                        da.Fill(dt)

                        ddlDepartment.DataSource = dt.Copy()
                        ddlDepartment.DataValueField = "DepartmentID"
                        ddlDepartment.DataTextField = "DepartmentName"
                        ddlDepartment.DataBind()
                        ddlDepartment.Items.Insert(0, New ListItem("All Departments", "0"))
                    End Using
                End Using
            End Using
        Catch ex As Exception
            ' Log error
        End Try
    End Sub

    Private Sub LoadFacultyData()
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                Dim searchTerm As String = If(txtSearch.Text.Trim(), "")

                ' Get the current cycle ID (most recent)
                Dim currentCycleID As Integer = GetCurrentCycleID(conn)
                If currentCycleID = 0 Then
                    pnlNoResults.Visible = True
                    lblCurrentCycle.Text = "No Evaluation Cycle Found"
                    Return
                End If

                ' Get the term for the current cycle
                Dim currentTerm As String = GetCurrentTermByCycle(conn, currentCycleID)
                If String.IsNullOrEmpty(currentTerm) Then
                    pnlNoResults.Visible = True
                    Return
                End If

                Dim sql As String = "
                SELECT DISTINCT d.DepartmentID, d.DepartmentName, 
                       COUNT(DISTINCT u.UserID) as FacultyCount
                FROM departments d
                INNER JOIN users u ON d.DepartmentID = u.DepartmentID
                INNER JOIN facultyload fl ON u.UserID = fl.FacultyID
                WHERE u.Role = 'Faculty' AND u.Status = 'Active'
                AND fl.Term = @CurrentTerm
                AND fl.IsDeleted = 0
                AND (@DeptID = 0 OR d.DepartmentID = @DeptID)
                AND (@Search = '' OR CONCAT(u.FirstName, ' ', u.LastName) LIKE CONCAT('%', @Search, '%'))
                GROUP BY d.DepartmentID, d.DepartmentName
                ORDER BY d.DepartmentName"

                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@DeptID", ddlDepartment.SelectedValue)
                    cmd.Parameters.AddWithValue("@Search", searchTerm)
                    cmd.Parameters.AddWithValue("@CurrentTerm", currentTerm)

                    Using da As New MySqlDataAdapter(cmd)
                        Dim dt As New DataTable()
                        da.Fill(dt)
                        rptDepartments.DataSource = dt
                        rptDepartments.DataBind()
                        pnlNoResults.Visible = dt.Rows.Count = 0
                    End Using
                End Using
            End Using
        Catch ex As Exception
            pnlNoResults.Visible = True
        End Try
    End Sub

    Protected Sub rptDepartments_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            Dim deptID As Integer = Convert.ToInt32(DataBinder.Eval(e.Item.DataItem, "DepartmentID"))
            Dim rptFaculty As Repeater = TryCast(e.Item.FindControl("rptFaculty"), Repeater)
            If rptFaculty IsNot Nothing Then
                rptFaculty.DataSource = GetFacultyByDepartment(deptID)
                rptFaculty.DataBind()
            End If
        End If
    End Sub

    Protected Sub rptFaculty_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            Dim facultyID As Integer = Convert.ToInt32(DataBinder.Eval(e.Item.DataItem, "FacultyID"))
            Dim totalSubjects As Integer = Convert.ToInt32(DataBinder.Eval(e.Item.DataItem, "TotalSubjects"))
            Dim submittedCount As Integer = Convert.ToInt32(DataBinder.Eval(e.Item.DataItem, "SubmittedCount"))

            Dim lblStatusBadge As Label = TryCast(e.Item.FindControl("lblStatusBadge"), Label)
            Dim lblSubmissionStatus As Label = TryCast(e.Item.FindControl("lblSubmissionStatus"), Label)

            If lblStatusBadge IsNot Nothing AndAlso lblSubmissionStatus IsNot Nothing Then
                If totalSubjects = 0 Then
                    lblStatusBadge.Text = "No Subjects"
                    lblStatusBadge.CssClass = "status-badge status-none"
                    lblSubmissionStatus.Text = "No subjects assigned for current term"
                ElseIf submittedCount = totalSubjects Then
                    lblStatusBadge.Text = "All Submitted"
                    lblStatusBadge.CssClass = "status-badge status-completed"
                    lblSubmissionStatus.Text = $"{submittedCount} of {totalSubjects} subjects submitted"
                Else
                    lblStatusBadge.Text = "Pending"
                    lblStatusBadge.CssClass = "status-badge status-pending"
                    lblSubmissionStatus.Text = $"{submittedCount} of {totalSubjects} subjects submitted"
                End If
            End If
        End If
    End Sub

    Private Function GetFacultyByDepartment(departmentID As Integer) As DataTable
        Dim dt As New DataTable()
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                Dim searchTerm As String = If(txtSearch.Text.Trim(), "")

                ' Get the current cycle ID (most recent)
                Dim currentCycleID As Integer = GetCurrentCycleID(conn)
                If currentCycleID = 0 Then Return dt

                ' Get the term for the current cycle
                Dim currentTerm As String = GetCurrentTermByCycle(conn, currentCycleID)
                If String.IsNullOrEmpty(currentTerm) Then Return dt

                Dim sql As String = "
                SELECT 
                    u.UserID AS FacultyID, 
                    CONCAT(u.FirstName, ' ', u.LastName) AS FullName,
                    (SELECT COUNT(*) 
                     FROM facultyload fl 
                     WHERE fl.FacultyID = u.UserID 
                     AND fl.Term = @CurrentTerm
                     AND fl.IsDeleted = 0) AS TotalSubjects,
                    (SELECT COUNT(*) 
                     FROM gradesubmissions gs 
                     INNER JOIN facultyload fl ON gs.LoadID = fl.LoadID 
                     WHERE fl.FacultyID = u.UserID 
                     AND gs.CycleID = @CurrentCycleID
                     AND fl.Term = @CurrentTerm
                     AND fl.IsDeleted = 0) AS SubmittedCount
                FROM users u
                WHERE u.Role = 'Faculty' AND u.Status = 'Active' 
                AND u.DepartmentID = @DeptID
                AND (@Search = '' OR CONCAT(u.FirstName, ' ', u.LastName) LIKE CONCAT('%', @Search, '%'))
                ORDER BY u.LastName, u.FirstName"

                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@DeptID", departmentID)
                    cmd.Parameters.AddWithValue("@Search", searchTerm)
                    cmd.Parameters.AddWithValue("@CurrentTerm", currentTerm)
                    cmd.Parameters.AddWithValue("@CurrentCycleID", currentCycleID)

                    Using da As New MySqlDataAdapter(cmd)
                        da.Fill(dt)
                    End Using
                End Using
            End Using
        Catch ex As Exception
            ' Log error
        End Try
        Return dt
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetFacultyCurrentSubmissions(facultyID As Integer) As List(Of FacultySubjectInfo)
        Dim list As New List(Of FacultySubjectInfo)()
        Dim connStr As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connStr)
                conn.Open()

                ' Get the current cycle (most recent)
                Dim cycleID As Integer = GetCurrentCycleID(conn)
                If cycleID = 0 Then Return list

                Dim currentTerm As String = GetCurrentTermByCycle(conn, cycleID)
                If String.IsNullOrEmpty(currentTerm) Then Return list

                Dim sql As String = "
                SELECT 
                    fl.LoadID, 
                    s.SubjectCode, 
                    s.SubjectName, 
                    c.YearLevel, 
                    c.Section, 
                    co.CourseName, 
                    fl.Term,
                    gs.SubmissionID,
                    gs.Status as SubmissionStatus,
                    CASE WHEN gs.SubmissionID IS NOT NULL THEN 1 ELSE 0 END AS IsSubmitted,
                    CASE WHEN gs.Status = 'Confirmed' THEN 1 ELSE 0 END AS IsConfirmed,
                    DATE_FORMAT(gs.SubmissionDate, '%M %d, %Y %h:%i %p') AS SubmissionDate,
                    gf.FileID, 
                    gf.FileName, 
                    gf.FileSize,
                    ec.Status as CycleStatus
                FROM facultyload fl
                INNER JOIN subjects s ON fl.SubjectID = s.SubjectID
                INNER JOIN classes c ON fl.ClassID = c.ClassID
                INNER JOIN courses co ON fl.CourseID = co.CourseID
                LEFT JOIN gradesubmissions gs ON fl.LoadID = gs.LoadID AND gs.CycleID = @CycleID
                LEFT JOIN gradefiles gf ON gs.FileID = gf.FileID
                LEFT JOIN evaluationcycles ec ON gs.CycleID = ec.CycleID
                WHERE fl.FacultyID = @FacultyID 
                AND fl.Term = @CurrentTerm 
                AND fl.IsDeleted = 0
                ORDER BY s.SubjectCode"

                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                    cmd.Parameters.AddWithValue("@CurrentTerm", currentTerm)
                    cmd.Parameters.AddWithValue("@CycleID", cycleID)

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        While rdr.Read()
                            list.Add(New FacultySubjectInfo() With {
                            .LoadID = SafeGetInt(rdr, "LoadID"),
                            .SubmissionID = SafeGetInt(rdr, "SubmissionID"),
                            .SubjectCode = SafeGetString(rdr, "SubjectCode"),
                            .SubjectName = SafeGetString(rdr, "SubjectName"),
                            .YearLevel = SafeGetString(rdr, "YearLevel"),
                            .Section = SafeGetString(rdr, "Section"),
                            .CourseName = SafeGetString(rdr, "CourseName"),
                            .Term = SafeGetString(rdr, "Term"),
                            .IsSubmitted = SafeGetInt(rdr, "IsSubmitted") = 1,
                            .IsConfirmed = SafeGetInt(rdr, "IsConfirmed") = 1,
                            .SubmissionDate = SafeGetString(rdr, "SubmissionDate"),
                            .FileID = SafeGetInt(rdr, "FileID"),
                            .FileName = SafeGetString(rdr, "FileName"),
                            .FileSize = SafeGetLong(rdr, "FileSize"),
                            .HasFile = SafeGetInt(rdr, "FileID") > 0,
                            .SubmissionStatus = SafeGetString(rdr, "SubmissionStatus"),
                            .CycleStatus = SafeGetString(rdr, "CycleStatus")
                        })
                        End While
                    End Using
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetFacultyCurrentSubmissions: " & ex.Message)
        End Try
        Return list
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function MarkGradeAsSubmitted(loadID As Integer) As WebMethodResult
        Dim res As New WebMethodResult()
        Dim connStr As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        System.Diagnostics.Debug.WriteLine($"MarkGradeAsSubmitted called with LoadID: {loadID}")

        Try
            Using conn As New MySqlConnection(connStr)
                conn.Open()

                ' Get the current active cycle ID
                Dim cycleID As Integer = GetCurrentCycleID(conn)
                If cycleID = 0 Then
                    res.Success = False
                    res.Message = "No active evaluation cycle found"
                    Return res
                End If

                ' Check if submission already exists
                Dim checkSql As String = "SELECT SubmissionID, Status FROM gradesubmissions WHERE LoadID = @LoadID AND CycleID = @CycleID"
                Using checkCmd As New MySqlCommand(checkSql, conn)
                    checkCmd.Parameters.AddWithValue("@LoadID", loadID)
                    checkCmd.Parameters.AddWithValue("@CycleID", cycleID)

                    Using rdr As MySqlDataReader = checkCmd.ExecuteReader()
                        If rdr.Read() Then
                            ' Submission already exists
                            Dim existingID As Integer = SafeGetInt(rdr, "SubmissionID")
                            Dim currentStatus As String = SafeGetString(rdr, "Status")

                            res.Success = False
                            res.Message = $"A submission already exists with status: {currentStatus}"
                            Return res
                        End If
                    End Using
                End Using

                ' No submission exists - insert new submission with CONFIRMED status
                Dim insertSql As String = "INSERT INTO gradesubmissions (LoadID, CycleID, SubmissionDate, Status, SubmittedBy) VALUES (@LoadID, @CycleID, NOW(), 'Confirmed', 0)"
                Using insertCmd As New MySqlCommand(insertSql, conn)
                    insertCmd.Parameters.AddWithValue("@LoadID", loadID)
                    insertCmd.Parameters.AddWithValue("@CycleID", cycleID)
                    Dim rowsAffected As Integer = insertCmd.ExecuteNonQuery()

                    If rowsAffected > 0 Then
                        res.Success = True
                        res.Message = "Grade marked as submitted and confirmed successfully"
                    Else
                        res.Success = False
                        res.Message = "Failed to create new submission"
                    End If
                End Using
            End Using
        Catch ex As Exception
            res.Success = False
            res.Message = "Error: " & ex.Message
            System.Diagnostics.Debug.WriteLine($"Exception in MarkGradeAsSubmitted: {ex.ToString()}")
        End Try

        Return res
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function ConfirmGradeSubmissionStatus(submissionID As Integer) As WebMethodResult
        Dim res As New WebMethodResult()
        Dim connStr As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        System.Diagnostics.Debug.WriteLine($"ConfirmGradeSubmissionStatus called with SubmissionID: {submissionID}")

        Try
            Using conn As New MySqlConnection(connStr)
                conn.Open()

                ' Update the status to 'Confirmed' in gradesubmissions table
                Dim updateSql As String = "UPDATE gradesubmissions SET Status = 'Confirmed' WHERE SubmissionID = @SubmissionID"
                Using cmd As New MySqlCommand(updateSql, conn)
                    cmd.Parameters.AddWithValue("@SubmissionID", submissionID)
                    Dim rowsAffected As Integer = cmd.ExecuteNonQuery()

                    If rowsAffected > 0 Then
                        res.Success = True
                        res.Message = "Grade submission confirmed successfully"
                    Else
                        res.Success = False
                        res.Message = "No changes made - submission may already be confirmed or not found"
                    End If
                End Using
            End Using
        Catch ex As Exception
            res.Success = False
            res.Message = "Error: " & ex.Message
            System.Diagnostics.Debug.WriteLine("ConfirmGradeSubmissionStatus Error: " & ex.ToString())
        End Try
        Return res
    End Function

#End Region

#Region "Event Handlers"

    Protected Sub ddlDepartment_SelectedIndexChanged(sender As Object, e As EventArgs)
        LoadFacultyData()
    End Sub

    Protected Sub txtSearch_TextChanged(sender As Object, e As EventArgs)
        LoadFacultyData()
    End Sub

#End Region

#Region "Helper Methods"

    Private Shared Function GetCurrentTerm(conn As MySqlConnection) As String
        Dim sql As String = "SELECT Term FROM evaluationcycles WHERE Status='Active' AND IsActive=1 LIMIT 1"
        Using cmd As New MySqlCommand(sql, conn)
            Dim result = cmd.ExecuteScalar()
            Return If(result?.ToString(), "")
        End Using
    End Function

    Private Shared Function GetCurrentCycleID(conn As MySqlConnection) As Integer
        Try
            Dim sql As String = "SELECT CycleID FROM evaluationcycles WHERE IsActive = 1 ORDER BY CycleID DESC LIMIT 1"
            Using cmd As New MySqlCommand(sql, conn)
                Dim result = cmd.ExecuteScalar()
                Return If(result IsNot Nothing AndAlso Not DBNull.Value.Equals(result), Convert.ToInt32(result), 0)
            End Using
        Catch ex As Exception
            Return 0
        End Try
    End Function

    Private Shared Function GetLatestCycleID(conn As MySqlConnection) As Integer
        Dim sql As String = "SELECT CycleID FROM evaluationcycles WHERE IsActive = 1 ORDER BY CycleID DESC LIMIT 1"
        Using cmd As New MySqlCommand(sql, conn)
            Dim result = cmd.ExecuteScalar()
            Return If(result IsNot Nothing, Convert.ToInt32(result), 0)
        End Using
    End Function

    Private Shared Function GetCurrentTermByCycle(conn As MySqlConnection, cycleID As Integer) As String
        Try
            Dim sql As String = "SELECT Term FROM evaluationcycles WHERE CycleID = @CycleID"
            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@CycleID", cycleID)
                Dim result = cmd.ExecuteScalar()
                Return If(result?.ToString(), "")
            End Using
        Catch ex As Exception
            Return ""
        End Try
    End Function


    Private Shared Function SafeGetString(rdr As MySqlDataReader, fieldName As String) As String
        Try
            Return If(rdr.IsDBNull(rdr.GetOrdinal(fieldName)), "", rdr(fieldName).ToString())
        Catch
            Return ""
        End Try
    End Function

    Private Shared Function SafeGetInt(rdr As MySqlDataReader, fieldName As String) As Integer
        Try
            Return If(rdr.IsDBNull(rdr.GetOrdinal(fieldName)), 0, Convert.ToInt32(rdr(fieldName)))
        Catch
            Return 0
        End Try
    End Function

    Private Shared Function SafeGetLong(rdr As MySqlDataReader, fieldName As String) As Long
        Try
            Return If(rdr.IsDBNull(rdr.GetOrdinal(fieldName)), 0, Convert.ToInt64(rdr(fieldName)))
        Catch
            Return 0
        End Try
    End Function

    Private Shared Function SafeGetDateTime(rdr As MySqlDataReader, fieldName As String) As DateTime?
        Try
            Return If(rdr.IsDBNull(rdr.GetOrdinal(fieldName)), Nothing, Convert.ToDateTime(rdr(fieldName)))
        Catch
            Return Nothing
        End Try
    End Function

#End Region

#Region "Data Classes"

    Public Class FacultySubjectInfo
        Public Property LoadID As Integer
        Public Property SubmissionID As Integer
        Public Property SubjectCode As String
        Public Property SubjectName As String
        Public Property YearLevel As String
        Public Property Section As String
        Public Property CourseName As String
        Public Property Term As String
        Public Property IsSubmitted As Boolean
        Public Property IsConfirmed As Boolean
        Public Property SubmissionDate As String
        Public Property FileID As Integer
        Public Property FileName As String
        Public Property FileSize As Long
        Public Property HasFile As Boolean
        Public Property SubmissionStatus As String
        Public Property CycleStatus As String ' Add this property
    End Class

    Public Class WebMethodResult
        Public Property Success As Boolean
        Public Property Message As String
    End Class

#End Region
    Protected Sub btnLogout_Click(sender As Object, e As EventArgs)
        Session.Clear()
        Session.Abandon()
        Response.Redirect("~/Login.aspx")
    End Sub
End Class


