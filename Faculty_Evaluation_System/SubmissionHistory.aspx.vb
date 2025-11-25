Imports System.Data
Imports System.Configuration
Imports MySql.Data.MySqlClient
Imports System.Web.Services
Imports System.Web.Script.Services
Imports System.Web.Script.Serialization

Public Class SubmissionHistory
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
            LoadDepartments()
            LoadCycles()
            LoadFacultyFolders()
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

    Private Sub LoadCycles()
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                ' Get only inactive cycles for historical view
                Dim sql As String = "SELECT CycleID, CONCAT(CycleName, ' - ', Term) as DisplayName 
                                   FROM evaluationcycles 
                                   WHERE IsActive = 1 AND Status = 'Inactive'
                                   ORDER BY StartDate DESC"

                Using cmd As New MySqlCommand(sql, conn)
                    Using da As New MySqlDataAdapter(cmd)
                        Dim dt As New DataTable()
                        da.Fill(dt)
                        ddlCycle.DataSource = dt
                        ddlCycle.DataValueField = "CycleID"
                        ddlCycle.DataTextField = "DisplayName"
                        ddlCycle.DataBind()
                        ddlCycle.Items.Insert(0, New ListItem("All Past Cycles", "0"))
                    End Using
                End Using
            End Using
        Catch ex As Exception
            ' Log error
        End Try
    End Sub

    Private Sub LoadFacultyFolders()
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                Dim searchTerm As String = If(txtSearch.Text.Trim(), "")
                Dim deptID As Integer = Convert.ToInt32(ddlDepartment.SelectedValue)
                Dim cycleID As Integer = Convert.ToInt32(ddlCycle.SelectedValue)

                ' Get current active cycle ID to exclude
                Dim currentCycleID As Integer = GetCurrentCycleID(conn)

                Dim sql As String = "
                    SELECT DISTINCT
                        u.UserID AS FacultyID,
                        CONCAT(u.FirstName, ' ', u.LastName) AS FullName,
                        d.DepartmentName AS Department,
                        u.DepartmentID
                    FROM users u
                    INNER JOIN departments d ON u.DepartmentID = d.DepartmentID
                    WHERE u.Role = 'Faculty' 
                    AND u.Status = 'Active'
                    AND (@DeptID = 0 OR u.DepartmentID = @DeptID)
                    AND (@Search = '' OR CONCAT(u.FirstName, ' ', u.LastName) LIKE CONCAT('%', @Search, '%'))
                    AND EXISTS (
                        SELECT 1 FROM gradesubmissions gs
                        INNER JOIN facultyload fl ON gs.LoadID = fl.LoadID
                        WHERE fl.FacultyID = u.UserID
                        AND (@CycleID = 0 OR gs.CycleID = @CycleID)
                        AND gs.CycleID != @CurrentCycleID  -- Exclude current cycle
                    )
                    ORDER BY u.LastName, u.FirstName"

                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@DeptID", deptID)
                    cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    cmd.Parameters.AddWithValue("@CurrentCycleID", currentCycleID)
                    cmd.Parameters.AddWithValue("@Search", searchTerm)

                    Using da As New MySqlDataAdapter(cmd)
                        Dim dt As New DataTable()
                        da.Fill(dt)

                        ' Bind data to both repeaters
                        rptFacultyFolders.DataSource = dt
                        rptFacultyFolders.DataBind()

                        rptFacultyTable.DataSource = dt
                        rptFacultyTable.DataBind()

                        pnlNoResults.Visible = dt.Rows.Count = 0
                        lblResultCount.Text = $"Showing {dt.Rows.Count} faculty member(s)"
                    End Using
                End Using
            End Using
        Catch ex As Exception
            pnlNoResults.Visible = True
            System.Diagnostics.Debug.WriteLine("Error in LoadFacultyFolders: " & ex.Message)
        End Try
    End Sub

    Protected Sub rptFacultyFolders_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            Dim facultyID As Integer = Convert.ToInt32(DataBinder.Eval(e.Item.DataItem, "FacultyID"))
            Dim lblSubmissionCount As Label = TryCast(e.Item.FindControl("lblSubmissionCount"), Label)

            If lblSubmissionCount IsNot Nothing Then
                Dim submissionCount As Integer = GetFacultySubmissionCount(facultyID)
                lblSubmissionCount.Text = $"{submissionCount} submission(s)"
            End If
        End If
    End Sub

    Protected Sub rptFacultyTable_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            Dim facultyID As Integer = Convert.ToInt32(DataBinder.Eval(e.Item.DataItem, "FacultyID"))
            Dim lblTableSubmissionCount As Label = TryCast(e.Item.FindControl("lblTableSubmissionCount"), Label)

            If lblTableSubmissionCount IsNot Nothing Then
                Dim submissionCount As Integer = GetFacultySubmissionCount(facultyID)
                lblTableSubmissionCount.Text = submissionCount.ToString()
            End If
        End If
    End Sub

    Private Function GetFacultySubmissionCount(facultyID As Integer) As Integer
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                Dim cycleID As Integer = Convert.ToInt32(ddlCycle.SelectedValue)
                Dim currentCycleID As Integer = GetCurrentCycleID(conn)

                Dim sql As String = "
                    SELECT COUNT(*) as SubmissionCount
                    FROM gradesubmissions gs
                    INNER JOIN facultyload fl ON gs.LoadID = fl.LoadID
                    WHERE fl.FacultyID = @FacultyID
                    AND (@CycleID = 0 OR gs.CycleID = @CycleID)
                    AND gs.CycleID != @CurrentCycleID"

                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                    cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    cmd.Parameters.AddWithValue("@CurrentCycleID", currentCycleID)

                    Dim result = cmd.ExecuteScalar()
                    Return If(result IsNot Nothing, Convert.ToInt32(result), 0)
                End Using
            End Using
        Catch ex As Exception
            Return 0
        End Try
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetFacultyHistoricalCycles(facultyID As Integer) As List(Of CycleWithSubmissions)
        Dim list As New List(Of CycleWithSubmissions)()
        Dim connStr As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        System.Diagnostics.Debug.WriteLine($"GetFacultyHistoricalCycles called with FacultyID: {facultyID}")

        Try
            Using conn As New MySqlConnection(connStr)
                conn.Open()

                ' Get current active cycle ID to exclude
                Dim currentCycleID As Integer = GetCurrentCycleID(conn)

                ' Get only inactive cycles for this faculty (historical data)
                Dim cycleSql As String = "
                    SELECT DISTINCT 
                        ec.CycleID,
                        ec.CycleName,
                        ec.Term,
                        ec.Status
                    FROM gradesubmissions gs
                    INNER JOIN evaluationcycles ec ON gs.CycleID = ec.CycleID
                    INNER JOIN facultyload fl ON gs.LoadID = fl.LoadID
                    WHERE fl.FacultyID = @FacultyID
                    AND ec.CycleID != @CurrentCycleID  -- Exclude current cycle
                    ORDER BY ec.StartDate DESC"

                Using cycleCmd As New MySqlCommand(cycleSql, conn)
                    cycleCmd.Parameters.AddWithValue("@FacultyID", facultyID)
                    cycleCmd.Parameters.AddWithValue("@CurrentCycleID", currentCycleID)

                    Using cycleRdr As MySqlDataReader = cycleCmd.ExecuteReader()
                        While cycleRdr.Read()
                            Dim cycle As New CycleWithSubmissions() With {
                                .CycleID = SafeGetInt(cycleRdr, "CycleID"),
                                .CycleName = SafeGetString(cycleRdr, "CycleName"),
                                .Term = SafeGetString(cycleRdr, "Term"),
                                .Status = SafeGetString(cycleRdr, "Status"),
                                .Submissions = New List(Of HistoricalSubmissionInfo)()
                            }
                            list.Add(cycle)
                        End While
                    End Using
                End Using

                System.Diagnostics.Debug.WriteLine($"Found {list.Count} historical cycles for faculty {facultyID}")

                ' Now for each cycle, get the submissions
                For Each cycle In list
                    System.Diagnostics.Debug.WriteLine($"Getting submissions for historical cycle {cycle.CycleID}")

                    Dim submissionSql As String = "
                        SELECT 
                            gs.SubmissionID,
                            DATE_FORMAT(gs.SubmissionDate, '%M %d, %Y %h:%i %p') as FormattedDate,
                            gs.Status,
                            s.SubjectCode,
                            s.SubjectName,
                            c.YearLevel,
                            c.Section,
                            co.CourseName,
                            gf.FileID,
                            gf.FileName,
                            gf.FileSize,
                            CASE WHEN gf.FileID IS NOT NULL THEN 1 ELSE 0 END as HasFile
                        FROM gradesubmissions gs
                        INNER JOIN facultyload fl ON gs.LoadID = fl.LoadID
                        INNER JOIN subjects s ON fl.SubjectID = s.SubjectID
                        INNER JOIN classes c ON fl.ClassID = c.ClassID
                        INNER JOIN courses co ON fl.CourseID = co.CourseID
                        LEFT JOIN gradefiles gf ON gs.FileID = gf.FileID
                        WHERE fl.FacultyID = @FacultyID
                        AND gs.CycleID = @CycleID
                        ORDER BY s.SubjectCode"

                    Using submissionCmd As New MySqlCommand(submissionSql, conn)
                        submissionCmd.Parameters.AddWithValue("@FacultyID", facultyID)
                        submissionCmd.Parameters.AddWithValue("@CycleID", cycle.CycleID)

                        Using submissionRdr As MySqlDataReader = submissionCmd.ExecuteReader()
                            While submissionRdr.Read()
                                Dim submission As New HistoricalSubmissionInfo() With {
                                    .SubmissionID = SafeGetInt(submissionRdr, "SubmissionID"),
                                    .SubmissionDate = SafeGetString(submissionRdr, "FormattedDate"),
                                    .Status = SafeGetString(submissionRdr, "Status"),
                                    .SubjectCode = SafeGetString(submissionRdr, "SubjectCode"),
                                    .SubjectName = SafeGetString(submissionRdr, "SubjectName"),
                                    .YearLevel = SafeGetString(submissionRdr, "YearLevel"),
                                    .Section = SafeGetString(submissionRdr, "Section"),
                                    .CourseName = SafeGetString(submissionRdr, "CourseName"),
                                    .FileID = SafeGetInt(submissionRdr, "FileID"),
                                    .FileName = SafeGetString(submissionRdr, "FileName"),
                                    .FileSize = SafeGetLong(submissionRdr, "FileSize"),
                                    .HasFile = SafeGetInt(submissionRdr, "FileID") > 0
                                }
                                cycle.Submissions.Add(submission)
                            End While
                        End Using
                    End Using

                    System.Diagnostics.Debug.WriteLine($"Historical cycle {cycle.CycleID} has {cycle.Submissions.Count} submissions")
                Next
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetFacultyHistoricalCycles: " & ex.Message)
            System.Diagnostics.Debug.WriteLine("Stack Trace: " & ex.StackTrace)
        End Try

        System.Diagnostics.Debug.WriteLine($"Returning {list.Count} historical cycles with total {list.Sum(Function(c) c.Submissions.Count)} submissions")
        Return list
    End Function

#Region "Event Handlers"

    Protected Sub ddlDepartment_SelectedIndexChanged(sender As Object, e As EventArgs)
        LoadFacultyFolders()
    End Sub

    Protected Sub ddlCycle_SelectedIndexChanged(sender As Object, e As EventArgs)
        LoadFacultyFolders()
    End Sub

    Protected Sub txtSearch_TextChanged(sender As Object, e As EventArgs)
        LoadFacultyFolders()
    End Sub

#End Region

#Region "Helper Methods"

    Private Shared Function GetCurrentCycleID(conn As MySqlConnection) As Integer
        Try
            Dim sql As String = "SELECT CycleID FROM evaluationcycles WHERE Status = 'Active' AND IsActive = 1 LIMIT 1"
            Using cmd As New MySqlCommand(sql, conn)
                Dim result = cmd.ExecuteScalar()
                Return If(result IsNot Nothing AndAlso Not DBNull.Value.Equals(result), Convert.ToInt32(result), 0)
            End Using
        Catch ex As Exception
            Return 0
        End Try
    End Function

    Private Shared Function SafeGetString(rdr As MySqlDataReader, fieldName As String) As String
        Try
            Dim ordinal As Integer = rdr.GetOrdinal(fieldName)
            Return If(rdr.IsDBNull(ordinal), "", rdr.GetString(ordinal))
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"Error getting string for field {fieldName}: {ex.Message}")
            Return ""
        End Try
    End Function

    Private Shared Function SafeGetInt(rdr As MySqlDataReader, fieldName As String) As Integer
        Try
            Dim ordinal As Integer = rdr.GetOrdinal(fieldName)
            Return If(rdr.IsDBNull(ordinal), 0, rdr.GetInt32(ordinal))
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"Error getting int for field {fieldName}: {ex.Message}")
            Return 0
        End Try
    End Function

    Private Shared Function SafeGetLong(rdr As MySqlDataReader, fieldName As String) As Long
        Try
            Dim ordinal As Integer = rdr.GetOrdinal(fieldName)
            Return If(rdr.IsDBNull(ordinal), 0, rdr.GetInt64(ordinal))
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"Error getting long for field {fieldName}: {ex.Message}")
            Return 0
        End Try
    End Function

#End Region

#Region "Data Classes"

    Public Class CycleWithSubmissions
        Public Property CycleID As Integer
        Public Property CycleName As String
        Public Property Term As String
        Public Property Status As String
        Public Property Submissions As List(Of HistoricalSubmissionInfo)
    End Class

    Public Class HistoricalSubmissionInfo
        Public Property SubmissionID As Integer
        Public Property SubmissionDate As String
        Public Property Status As String
        Public Property SubjectCode As String
        Public Property SubjectName As String
        Public Property YearLevel As String
        Public Property Section As String
        Public Property CourseName As String
        Public Property FileID As Integer
        Public Property FileName As String
        Public Property FileSize As Long
        Public Property HasFile As Boolean
    End Class

#End Region
    Protected Sub btnLogout_Click(sender As Object, e As EventArgs)
        Session.Clear()
        Session.Abandon()
        Response.Redirect("~/Login.aspx")
    End Sub
End Class