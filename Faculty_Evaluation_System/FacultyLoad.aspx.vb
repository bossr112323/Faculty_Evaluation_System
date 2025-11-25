Imports MySql.Data.MySqlClient
Imports System.Configuration
Imports System.Web.Services
Imports System.Web.Script.Serialization
Imports System.IO

Public Class FacultyLoad
    Inherits System.Web.UI.Page
    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property
    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        ' Check user role
        If Session("Role") Is Nothing OrElse Session("Role").ToString() <> "Admin" Then
            Response.Redirect("~/Login.aspx")
        End If

        If Not IsPostBack Then
            ' Initialize page on first load
            lblWelcome.Text = Session("FullName").ToString()
            LoadCourses()
            LoadYearLevels()
            LoadFacultySummary()
            VerifySpecificFacultyCounts() ' Add this line
            UpdateSidebarBadges()

            ' Initialize dropdowns
            ddlCourses.Items.Insert(0, New ListItem("Select Course", ""))
            ddlYearLevel.Items.Insert(0, New ListItem("Select Year Level", ""))
            ddlTerm.Items.Insert(0, New ListItem("Select Semester", ""))

            ' Clear messages only on initial load
            lblMessage.Text = ""
            lblMessage.CssClass = "alert d-none"
            lblModalMessage.Text = ""
            lblModalMessage.CssClass = "alert d-none"
        End If
    End Sub
#Region "Helper Methods for Display"
    Public Function GetSubjectCountDisplay(subjectCount As Object) As String
        If subjectCount Is DBNull.Value Then
            Return "0"
        Else
            Return subjectCount.ToString()
        End If
    End Function
#End Region
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
#Region "Web Methods for Autocomplete"
    <WebMethod()>
    Public Shared Function SearchFaculty(searchTerm As String) As List(Of Object)
        Dim results As New List(Of Object)()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        Try
            Using conn As New MySqlConnection(connString)
                Dim sql As String = "SELECT UserID, 
                    CONCAT(LastName, ', ', FirstName, 
                        CASE WHEN MiddleInitial IS NOT NULL AND MiddleInitial != '' THEN CONCAT(' ', MiddleInitial, '.') ELSE '' END,
                        CASE WHEN Suffix IS NOT NULL AND Suffix != '' THEN CONCAT(' ', Suffix) ELSE '' END
                    ) AS FullName 
                    FROM users 
                    WHERE Role='Faculty' 
                    AND Status='Active'
                    AND CONCAT(LastName, ', ', FirstName, 
                        CASE WHEN MiddleInitial IS NOT NULL AND MiddleInitial != '' THEN CONCAT(' ', MiddleInitial, '.') ELSE '' END,
                        CASE WHEN Suffix IS NOT NULL AND Suffix != '' THEN CONCAT(' ', Suffix) ELSE '' END
                    ) LIKE @SearchTerm 
                    ORDER BY LastName, FirstName LIMIT 10"

                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@SearchTerm", "%" & searchTerm & "%")
                    conn.Open()
                    Using reader As MySqlDataReader = cmd.ExecuteReader()
                        While reader.Read()
                            results.Add(New With {
                                .id = reader("UserID").ToString(),
                                .label = reader("FullName").ToString(),
                                .value = reader("FullName").ToString()
                            })
                        End While
                    End Using
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("SearchFaculty error: " & ex.Message)
        End Try
        Return results
    End Function
    <WebMethod()>
    Public Shared Function SearchSubjects(searchTerm As String) As List(Of Object)
        Dim results As New List(Of Object)()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        Try
            Using conn As New MySqlConnection(connString)
                Dim sql As String = "SELECT SubjectID, SubjectName, SubjectCode FROM subjects WHERE IsActive=1 AND (SubjectName LIKE @SearchTerm OR SubjectCode LIKE @SearchTerm) ORDER BY SubjectName LIMIT 10"
                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@SearchTerm", "%" & searchTerm & "%")
                    conn.Open()
                    Using reader As MySqlDataReader = cmd.ExecuteReader()
                        While reader.Read()
                            Dim displayText As String = reader("SubjectName").ToString()
                            If Not String.IsNullOrEmpty(reader("SubjectCode").ToString()) Then
                                displayText = reader("SubjectCode").ToString() & " - " & displayText
                            End If
                            results.Add(New With {
                            .id = reader("SubjectID").ToString(),
                            .label = displayText,
                            .value = displayText
                        })
                        End While
                    End Using
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("SearchSubjects error: " & ex.Message)
        End Try
        Return results
    End Function
    <WebMethod()>
    Public Shared Function SearchSections(searchTerm As String, yearLevel As String, courseID As String) As List(Of Object)
        Dim results As New List(Of Object)()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        Try
            Using conn As New MySqlConnection(connString)
                Dim sql As String = "SELECT DISTINCT Section FROM classes WHERE YearLevel = @YearLevel AND CourseID = @CourseID AND IsActive=1 AND Section LIKE @SearchTerm ORDER BY Section LIMIT 10"
                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@YearLevel", yearLevel)
                    cmd.Parameters.AddWithValue("@CourseID", courseID)
                    cmd.Parameters.AddWithValue("@SearchTerm", "%" & searchTerm & "%")
                    conn.Open()
                    Using reader As MySqlDataReader = cmd.ExecuteReader()
                        While reader.Read()
                            results.Add(New With {
                            .id = reader("Section").ToString(),
                            .label = reader("Section").ToString(),
                            .value = reader("Section").ToString()
                        })
                        End While
                    End Using
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("SearchSections error: " & ex.Message)
        End Try
        Return results
    End Function
#End Region
#Region "Load Dropdowns"
    Private Sub LoadCourses()
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "SELECT CourseID, CourseName FROM courses WHERE IsActive = 1 ORDER BY CourseName"
            Using cmd As New MySqlCommand(sql, conn)
                Dim da As New MySqlDataAdapter(cmd)
                Dim dt As New DataTable()
                da.Fill(dt)
                ddlCourses.DataSource = dt
                ddlCourses.DataTextField = "CourseName"
                ddlCourses.DataValueField = "CourseID"
                ddlCourses.DataBind()
            End Using
        End Using
    End Sub
    Private Sub LoadYearLevels()
        Using conn As New MySqlConnection(ConnString)
            Dim cmd As New MySqlCommand("SELECT DISTINCT YearLevel FROM classes WHERE IsActive=1 ORDER BY YearLevel", conn)
            Dim da As New MySqlDataAdapter(cmd)
            Dim dt As New DataTable()
            da.Fill(dt)
            ddlYearLevel.DataSource = dt
            ddlYearLevel.DataTextField = "YearLevel"
            ddlYearLevel.DataValueField = "YearLevel"
            ddlYearLevel.DataBind()
        End Using
    End Sub
#End Region
#Region "Dropdown Events"
    Protected Sub ddlCourses_SelectedIndexChanged(sender As Object, e As EventArgs)
        If ddlCourses.SelectedValue = "" Then
            ddlYearLevel.SelectedValue = ""
            txtSection.Text = ""
            hfSectionValue.Value = ""
        End If
    End Sub
    Protected Sub ddlYearLevel_SelectedIndexChanged(sender As Object, e As EventArgs)
        If ddlYearLevel.SelectedValue = "" Then
            txtSection.Text = ""
            hfSectionValue.Value = ""
        End If
    End Sub
#End Region
    Protected Sub btnAssign_Click(sender As Object, e As EventArgs)
        ' ✅ Validate all fields
        If String.IsNullOrEmpty(hfFacultyID.Value) Or ddlCourses.SelectedValue = "" Or
   String.IsNullOrEmpty(hfSubjectID.Value) Or String.IsNullOrEmpty(ddlYearLevel.SelectedValue) Or
   String.IsNullOrEmpty(hfSectionValue.Value) Or ddlTerm.SelectedValue = "" Then
            lblModalMessage.Text = "⚠ Please fill in all fields with valid selections."
            lblModalMessage.CssClass = "alert alert-danger d-block"
            ScriptManager.RegisterStartupScript(Me, Me.GetType(), "KeepModalOpen", "setKeepModalOpen(true);", True)
            Return
        End If
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                ' ✅ Get DepartmentID from Course
                Dim departmentID As Integer = 0
                Dim getDeptSql As String = "SELECT DepartmentID FROM courses WHERE CourseID=@CourseID AND IsActive=1"
                Using getDeptCmd As New MySqlCommand(getDeptSql, conn)
                    getDeptCmd.Parameters.AddWithValue("@CourseID", ddlCourses.SelectedValue)
                    Dim deptResult = getDeptCmd.ExecuteScalar()
                    If deptResult IsNot Nothing Then
                        departmentID = Convert.ToInt32(deptResult)
                    Else
                        lblModalMessage.Text = "⚠ No department found for the selected course."
                        lblModalMessage.CssClass = "alert alert-warning d-block"
                        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "KeepModalOpen", "setKeepModalOpen(true);", True)
                        Return
                    End If
                End Using
                ' ✅ Get ClassID
                Dim classID As Integer = 0
                Dim getClassSql As String = "SELECT ClassID FROM classes WHERE YearLevel=@YearLevel AND Section=@Section AND CourseID=@CourseID AND IsActive=1"
                Using getClassCmd As New MySqlCommand(getClassSql, conn)
                    getClassCmd.Parameters.AddWithValue("@YearLevel", ddlYearLevel.SelectedValue)
                    getClassCmd.Parameters.AddWithValue("@Section", hfSectionValue.Value)
                    getClassCmd.Parameters.AddWithValue("@CourseID", ddlCourses.SelectedValue)
                    Dim result = getClassCmd.ExecuteScalar()
                    If result IsNot Nothing Then
                        classID = Convert.ToInt32(result)
                    Else
                        lblModalMessage.Text = "⚠ No class found for the selected year level, section, and course."
                        lblModalMessage.CssClass = "alert alert-warning d-block"
                        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "KeepModalOpen", "setKeepModalOpen(true);", True)
                        Return
                    End If
                End Using
                ' ✅ ENHANCED DUPLICATE VALIDATION: Check if the same subject, class, and term combination already exists for ANY faculty
                Dim existingAssignment As Object = Nothing
                Dim existingFacultyID As String = ""
                Dim existingFacultyName As String = ""
                Dim isDeleted As Boolean = False
                Dim existingSubjectCode As String = ""
                Dim existingSubjectName As String = ""
                ' Enhanced check to get more details about existing assignment
                Dim checkSql As String = "
            SELECT fl.LoadID, fl.FacultyID, fl.IsDeleted,
                   CONCAT(u.LastName, ', ', u.FirstName, 
                       CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial != '' THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
                       CASE WHEN u.Suffix IS NOT NULL AND u.Suffix != '' THEN CONCAT(' ', u.Suffix) ELSE '' END
                   ) AS FacultyName,
                   s.SubjectCode,
                   s.SubjectName
            FROM facultyload fl
            INNER JOIN users u ON fl.FacultyID = u.UserID
            INNER JOIN subjects s ON fl.SubjectID = s.SubjectID
            WHERE fl.SubjectID=@SubjectID 
              AND fl.ClassID=@ClassID 
              AND fl.Term=@Term
            LIMIT 1"
                Using checkCmd As New MySqlCommand(checkSql, conn)
                    checkCmd.Parameters.AddWithValue("@SubjectID", hfSubjectID.Value)
                    checkCmd.Parameters.AddWithValue("@ClassID", classID)
                    checkCmd.Parameters.AddWithValue("@Term", ddlTerm.SelectedValue)

                    Using reader As MySqlDataReader = checkCmd.ExecuteReader()
                        If reader.Read() Then
                            existingAssignment = reader("LoadID")
                            existingFacultyID = reader("FacultyID").ToString()
                            existingFacultyName = reader("FacultyName").ToString()
                            isDeleted = Convert.ToBoolean(reader("IsDeleted"))
                            existingSubjectCode = reader("SubjectCode").ToString()
                            existingSubjectName = reader("SubjectName").ToString()
                        End If
                    End Using
                End Using
                ' Get current subject details for better error messages
                Dim currentSubjectCode As String = ""
                Dim currentSubjectName As String = ""
                Dim getSubjectSql As String = "SELECT SubjectCode, SubjectName FROM subjects WHERE SubjectID=@SubjectID"
                Using getSubjectCmd As New MySqlCommand(getSubjectSql, conn)
                    getSubjectCmd.Parameters.AddWithValue("@SubjectID", hfSubjectID.Value)
                    Using reader As MySqlDataReader = getSubjectCmd.ExecuteReader()
                        If reader.Read() Then
                            currentSubjectCode = reader("SubjectCode").ToString()
                            currentSubjectName = reader("SubjectName").ToString()
                        End If
                    End Using
                End Using
                If existingAssignment IsNot Nothing Then
                    If isDeleted Then
                        ' ✅ Reactivate deleted load - but only if it's for the same faculty
                        If existingFacultyID = hfFacultyID.Value Then
                            Dim updateSql As String = "
                        UPDATE facultyload
                        SET FacultyID=@FacultyID,
                            DepartmentID=@DepartmentID,
                            CourseID=@CourseID,
                            SubjectID=@SubjectID,
                            ClassID=@ClassID,
                            Term=@Term,
                            IsDeleted=0
                        WHERE LoadID=@LoadID"
                            Using updateCmd As New MySqlCommand(updateSql, conn)
                                updateCmd.Parameters.AddWithValue("@FacultyID", hfFacultyID.Value)
                                updateCmd.Parameters.AddWithValue("@DepartmentID", departmentID)
                                updateCmd.Parameters.AddWithValue("@CourseID", ddlCourses.SelectedValue)
                                updateCmd.Parameters.AddWithValue("@SubjectID", hfSubjectID.Value)
                                updateCmd.Parameters.AddWithValue("@ClassID", classID)
                                updateCmd.Parameters.AddWithValue("@Term", ddlTerm.SelectedValue)
                                updateCmd.Parameters.AddWithValue("@LoadID", existingAssignment)
                                updateCmd.ExecuteNonQuery()
                            End Using
                            lblModalMessage.Text = "✅ Deleted faculty load has been reassigned successfully!"
                            lblModalMessage.CssClass = "alert alert-success d-block"
                            ScriptManager.RegisterStartupScript(Me, Me.GetType(), "CloseModal", "setKeepModalOpen(false); hideAssignModal();", True)
                        Else
                            ' Cannot reactivate a deleted assignment for a different faculty
                            lblModalMessage.Text = $"⚠ The subject '{currentSubjectCode} - {currentSubjectName}' in this class/term combination was previously assigned to {existingFacultyName}. Cannot reassign the same subject to a different faculty in the same class."
                            lblModalMessage.CssClass = "alert alert-warning d-block"
                            ScriptManager.RegisterStartupScript(Me, Me.GetType(), "KeepModalOpen", "setKeepModalOpen(true);", True)
                            Return
                        End If
                    Else
                        ' Active record exists - show detailed error message
                        If existingFacultyID = hfFacultyID.Value Then
                            lblModalMessage.Text = $"⚠ You have already been assigned the subject '{currentSubjectCode} - {currentSubjectName}' for this class and term. Each subject can only be assigned once per class per term."
                            lblModalMessage.CssClass = "alert alert-warning d-block"
                        Else
                            lblModalMessage.Text = $"⚠ The subject '{currentSubjectCode} - {currentSubjectName}' is already assigned to {existingFacultyName} for this class and term. Each subject-class-term combination can only be assigned to one faculty member."
                            lblModalMessage.CssClass = "alert alert-warning d-block"
                        End If
                        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "KeepModalOpen", "setKeepModalOpen(true);", True)
                        Return
                    End If
                Else
                    ' ✅ Additional validation: Check if this faculty already has this subject in the same term but different class
                    Dim sameSubjectDifferentClassSql As String = "
                SELECT COUNT(*) 
                FROM facultyload fl
                INNER JOIN classes cl ON fl.ClassID = cl.ClassID
                WHERE fl.FacultyID = @FacultyID 
                  AND fl.SubjectID = @SubjectID 
                  AND fl.Term = @Term 
                  AND fl.ClassID != @ClassID
                  AND fl.IsDeleted = 0"
                    Using sameSubjectCmd As New MySqlCommand(sameSubjectDifferentClassSql, conn)
                        sameSubjectCmd.Parameters.AddWithValue("@FacultyID", hfFacultyID.Value)
                        sameSubjectCmd.Parameters.AddWithValue("@SubjectID", hfSubjectID.Value)
                        sameSubjectCmd.Parameters.AddWithValue("@Term", ddlTerm.SelectedValue)
                        sameSubjectCmd.Parameters.AddWithValue("@ClassID", classID)

                        Dim sameSubjectCount As Integer = Convert.ToInt32(sameSubjectCmd.ExecuteScalar())

                        If sameSubjectCount > 0 Then
                            System.Diagnostics.Debug.WriteLine($"Faculty {hfFacultyID.Value} is teaching subject {hfSubjectID.Value} in multiple classes for term {ddlTerm.SelectedValue}")
                        End If
                    End Using
                    ' ✅ No existing record - insert new assignment
                    Dim insertSql As String = "
                INSERT INTO facultyload (FacultyID, DepartmentID, CourseID, SubjectID, ClassID, Term, IsDeleted)
                VALUES (@FacultyID, @DepartmentID, @CourseID, @SubjectID, @ClassID, @Term, 0)"
                    Using cmd As New MySqlCommand(insertSql, conn)
                        cmd.Parameters.AddWithValue("@FacultyID", hfFacultyID.Value)
                        cmd.Parameters.AddWithValue("@DepartmentID", departmentID)
                        cmd.Parameters.AddWithValue("@CourseID", ddlCourses.SelectedValue)
                        cmd.Parameters.AddWithValue("@SubjectID", hfSubjectID.Value)
                        cmd.Parameters.AddWithValue("@ClassID", classID)
                        cmd.Parameters.AddWithValue("@Term", ddlTerm.SelectedValue)
                        cmd.ExecuteNonQuery()
                    End Using

                    lblModalMessage.Text = "✅ Faculty load assigned successfully!"
                    lblModalMessage.CssClass = "alert alert-success d-block"
                    ScriptManager.RegisterStartupScript(Me, Me.GetType(), "CloseModal", "setKeepModalOpen(false); hideAssignModal();", True)
                End If
            End Using

            LoadFacultySummary() ' Changed from LoadFacultyLoad
            ClearForm()

            lblMessage.Text = "✅ Faculty load assignment completed successfully!"
            lblMessage.CssClass = "alert alert-success d-block"

        Catch ex As MySqlException
            lblModalMessage.Text = "❌ Error: " & ex.Message
            lblModalMessage.CssClass = "alert alert-danger d-block"
            ScriptManager.RegisterStartupScript(Me, Me.GetType(), "KeepModalOpen", "setKeepModalOpen(true);", True)
        End Try
    End Sub
#Region "Load Faculty Summary Grid (Grouped by Faculty)"
    Private Sub LoadFacultySummary()
        Using conn As New MySqlConnection(ConnString)
            ' Corrected query with proper counting of active loads only
            Dim sql As String = "
SELECT 
    u.UserID as FacultyID,
    CONCAT(u.LastName, ', ', u.FirstName, 
        CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial != '' THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
        CASE WHEN u.Suffix IS NOT NULL AND u.Suffix != '' THEN CONCAT(' ', u.Suffix) ELSE '' END
    ) AS FacultyName,
    COALESCE(d.DepartmentName, 'No Department') AS DepartmentName,
    (
        SELECT COUNT(*) 
        FROM facultyload fl 
        WHERE fl.FacultyID = u.UserID AND fl.IsDeleted = 0
    ) AS SubjectCount,
    COALESCE(
        (SELECT GROUP_CONCAT(DISTINCT Term ORDER BY Term SEPARATOR ', ') 
         FROM facultyload 
         WHERE FacultyID = u.UserID AND IsDeleted = 0),
        'No Assignments'
    ) AS TeachingTerms
FROM users u
LEFT JOIN departments d ON u.DepartmentID = d.DepartmentID
WHERE u.Role = 'Faculty' AND u.Status = 'Active'
ORDER BY u.LastName, u.FirstName"

            Using cmd As New MySqlCommand(sql, conn)
                Dim da As New MySqlDataAdapter(cmd)
                Dim dt As New DataTable()
                da.Fill(dt)
                gvFacultySummary.DataSource = dt
                gvFacultySummary.DataBind()

                ' Debug output
                System.Diagnostics.Debug.WriteLine($"=== LOADED FACULTY SUMMARY ===")
                For Each row As DataRow In dt.Rows
                    System.Diagnostics.Debug.WriteLine($"Faculty: {row("FacultyName")}, Count: {row("SubjectCount")}")
                Next
            End Using
        End Using
    End Sub
#End Region

#Region "Load Faculty Details (Specific Faculty Loads)"
    Private Sub LoadFacultyDetails(facultyID As String)
        Using conn As New MySqlConnection(ConnString)
            ' Updated query to show ALL active loads for the faculty
            Dim sql As String = "
SELECT fl.LoadID, 
       fl.FacultyID, 
       fl.SubjectID, 
       fl.CourseID, 
       fl.ClassID, 
       fl.Term,
       CONCAT(u.LastName, ', ', u.FirstName, 
           CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial != '' THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
           CASE WHEN u.Suffix IS NOT NULL AND u.Suffix != '' THEN CONCAT(' ', u.Suffix) ELSE '' END
       ) AS FacultyName, 
       s.SubjectName, 
       s.SubjectCode,
       c.CourseName,
       cl.YearLevel,
       cl.Section
FROM facultyload fl
INNER JOIN users u ON fl.FacultyID = u.UserID
INNER JOIN subjects s ON fl.SubjectID = s.SubjectID
INNER JOIN courses c ON fl.CourseID = c.CourseID
INNER JOIN classes cl ON fl.ClassID = cl.ClassID
WHERE fl.IsDeleted = 0 AND fl.FacultyID = @FacultyID
ORDER BY fl.Term, s.SubjectName, cl.YearLevel, cl.Section"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                Dim da As New MySqlDataAdapter(cmd)
                Dim dt As New DataTable()
                da.Fill(dt)

                gvFacultyDetails.DataSource = dt
                gvFacultyDetails.DataBind()

                ' Debug information
                System.Diagnostics.Debug.WriteLine($"=== FACULTY DETAILS DEBUG ===")
                System.Diagnostics.Debug.WriteLine($"Faculty ID: {facultyID}")
                System.Diagnostics.Debug.WriteLine($"Total rows in details: {dt.Rows.Count}")
                For Each row As DataRow In dt.Rows
                    System.Diagnostics.Debug.WriteLine($"Load: {row("SubjectCode")} - {row("SubjectName")} | Term: {row("Term")}")
                Next
            End Using
        End Using
    End Sub
#End Region
#Region "Helper Methods"
    Private Sub ClearForm()
        ddlCourses.SelectedValue = ""
        ddlYearLevel.SelectedValue = ""
        ddlTerm.SelectedValue = ""
        txtFaculty.Text = ""
        hfFacultyID.Value = ""
        txtSubject.Text = ""
        hfSubjectID.Value = ""
        txtSection.Text = ""
        hfSectionValue.Value = ""
        lblModalMessage.Text = ""
        lblModalMessage.CssClass = "alert d-none"
    End Sub
#End Region
    Protected Sub btnSearch_Click(sender As Object, e As EventArgs)
        Dim keyword As String = txtSearch.Text.Trim()

        Using conn As New MySqlConnection(ConnString)
            ' Corrected search query
            Dim sql As String = "
SELECT 
    u.UserID as FacultyID,
    CONCAT(u.LastName, ', ', u.FirstName, 
        CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial != '' THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
        CASE WHEN u.Suffix IS NOT NULL AND u.Suffix != '' THEN CONCAT(' ', u.Suffix) ELSE '' END
    ) AS FacultyName,
    COALESCE(d.DepartmentName, 'No Department') AS DepartmentName,
    (
        SELECT COUNT(*) 
        FROM facultyload fl 
        WHERE fl.FacultyID = u.UserID AND fl.IsDeleted = 0
    ) AS SubjectCount,
    COALESCE(
        (SELECT GROUP_CONCAT(DISTINCT Term ORDER BY Term SEPARATOR ', ') 
         FROM facultyload 
         WHERE FacultyID = u.UserID AND IsDeleted = 0),
        'No Assignments'
    ) AS TeachingTerms
FROM users u
LEFT JOIN departments d ON u.DepartmentID = d.DepartmentID
WHERE u.Role = 'Faculty' AND u.Status = 'Active'
AND (CONCAT(u.LastName, ', ', u.FirstName, 
        CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial != '' THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
        CASE WHEN u.Suffix IS NOT NULL AND u.Suffix != '' THEN CONCAT(' ', u.Suffix) ELSE '' END
    ) LIKE @Keyword
    OR COALESCE(d.DepartmentName, 'No Department') LIKE @Keyword)
ORDER BY u.LastName, u.FirstName"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@Keyword", "%" & keyword & "%")

                Dim da As New MySqlDataAdapter(cmd)
                Dim dt As New DataTable()
                da.Fill(dt)
                gvFacultySummary.DataSource = dt
                gvFacultySummary.DataBind()
            End Using
        End Using
    End Sub
    Private Sub VerifySpecificFacultyCounts()
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                ' Check Romasoc (UserID: 55)
                System.Diagnostics.Debug.WriteLine($"=== MICAH ROMASOC COUNT VERIFICATION ===")
                Using cmd As New MySqlCommand("SELECT COUNT(*) as ActualCount FROM facultyload WHERE FacultyID = 55 AND IsDeleted = 0", conn)
                    Dim romasocCount As Integer = Convert.ToInt32(cmd.ExecuteScalar())
                    System.Diagnostics.Debug.WriteLine($"Database count: {romasocCount}")

                    ' List individual loads
                    Using cmd2 As New MySqlCommand("SELECT LoadID, SubjectID, CourseID, ClassID, Term FROM facultyload WHERE FacultyID = 55 AND IsDeleted = 0 ORDER BY LoadID", conn)
                        Using reader As MySqlDataReader = cmd2.ExecuteReader()
                            While reader.Read()
                                System.Diagnostics.Debug.WriteLine($"  LoadID {reader("LoadID")}: Subject={reader("SubjectID")}, Course={reader("CourseID")}, Class={reader("ClassID")}, Term={reader("Term")}")
                            End While
                        End Using
                    End Using
                End Using

                ' Check Navarro (UserID: 60)
                System.Diagnostics.Debug.WriteLine($"=== JOHN NAVARRO COUNT VERIFICATION ===")
                Using cmd As New MySqlCommand("SELECT COUNT(*) as ActualCount FROM facultyload WHERE FacultyID = 60 AND IsDeleted = 0", conn)
                    Dim navarroCount As Integer = Convert.ToInt32(cmd.ExecuteScalar())
                    System.Diagnostics.Debug.WriteLine($"Database count: {navarroCount}")

                    ' List individual loads
                    Using cmd2 As New MySqlCommand("SELECT LoadID, SubjectID, CourseID, ClassID, Term FROM facultyload WHERE FacultyID = 60 AND IsDeleted = 0 ORDER BY LoadID", conn)
                        Using reader As MySqlDataReader = cmd2.ExecuteReader()
                            While reader.Read()
                                System.Diagnostics.Debug.WriteLine($"  LoadID {reader("LoadID")}: Subject={reader("SubjectID")}, Course={reader("CourseID")}, Class={reader("ClassID")}, Term={reader("Term")}")
                            End While
                        End Using
                    End Using
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"Verification error: {ex.Message}")
        End Try
    End Sub

#Region "GridView Events for Faculty Summary"
    Protected Sub gvFacultySummary_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        If e.CommandName = "ViewDetails" Then
            Dim facultyID As String = e.CommandArgument.ToString()
            hfSelectedFacultyID.Value = facultyID

            ' Get faculty name for display
            Dim facultyName As String = GetFacultyName(facultyID)
            lblFacultyDetailsTitle.Text = $"Subject Assignments for {facultyName}"

            ' Load and bind the data
            LoadFacultyDetails(facultyID)

            ' Force databind and update the panel
            gvFacultyDetails.DataBind()
            updFacultyDetails.Update()

            ScriptManager.RegisterStartupScript(Me, Me.GetType(), "ShowDetailsModal", "showDetailsModal();", True)

        ElseIf e.CommandName = "AssignSubject" Then
            Dim facultyID As String = e.CommandArgument.ToString()
            hfFacultyID.Value = facultyID

            ' Get faculty name and pre-fill the faculty field
            Dim facultyName As String = GetFacultyName(facultyID)
            txtFaculty.Text = facultyName

            ' Update the hidden field
            updAssignFaculty.Update()

            ScriptManager.RegisterStartupScript(Me, Me.GetType(), "ShowAssignModal", "showAssignModal();", True)
        End If
    End Sub
    Private Function GetFacultyName(facultyID As String) As String
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "SELECT CONCAT(LastName, ', ', FirstName, 
                CASE WHEN MiddleInitial IS NOT NULL AND MiddleInitial != '' THEN CONCAT(' ', MiddleInitial, '.') ELSE '' END,
                CASE WHEN Suffix IS NOT NULL AND Suffix != '' THEN CONCAT(' ', Suffix) ELSE '' END
            ) AS FacultyName FROM users WHERE UserID = @FacultyID"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                conn.Open()
                Dim result = cmd.ExecuteScalar()
                Return If(result IsNot Nothing, result.ToString(), "Unknown Faculty")
            End Using
        End Using
    End Function
#End Region
#Region "GridView Events for Faculty Details"
    Protected Sub gvFacultyDetails_RowEditing(sender As Object, e As GridViewEditEventArgs)
        gvFacultyDetails.EditIndex = e.NewEditIndex
        LoadFacultyDetails(hfSelectedFacultyID.Value)
    End Sub

    Protected Sub gvFacultyDetails_RowCancelingEdit(sender As Object, e As GridViewCancelEditEventArgs)
        gvFacultyDetails.EditIndex = -1
        LoadFacultyDetails(hfSelectedFacultyID.Value)
    End Sub
    Protected Sub gvFacultyDetails_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        If e.CommandName = "EditRecord" Then
            Dim loadID As Integer = Convert.ToInt32(e.CommandArgument)
            System.Diagnostics.Debug.WriteLine($"EditRecord command received - LoadID: {loadID}")

            ' Load the data for edit modal
            LoadEditModalData(loadID)

            ' Show the modal using JavaScript
            ScriptManager.RegisterStartupScript(Me, Me.GetType(), "ShowEditModal", "showEditModal();", True)
        End If
    End Sub
    Protected Sub gvFacultyDetails_RowUpdating(sender As Object, e As GridViewUpdateEventArgs)
        Dim loadID As Integer = Convert.ToInt32(gvFacultyDetails.DataKeys(e.RowIndex).Value)
        Dim row As GridViewRow = gvFacultyDetails.Rows(e.RowIndex)
        Dim ddlEditSubject As DropDownList = CType(row.FindControl("ddlEditSubject"), DropDownList)
        Dim ddlEditCourse As DropDownList = CType(row.FindControl("ddlEditCourse"), DropDownList)
        Dim ddlEditYearLevel As DropDownList = CType(row.FindControl("ddlEditYearLevel"), DropDownList)
        Dim ddlEditSection As DropDownList = CType(row.FindControl("ddlEditSection"), DropDownList)
        Dim ddlEditTerm As DropDownList = CType(row.FindControl("ddlEditTerm"), DropDownList)

        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                ' Get ClassID
                Dim classID As Integer = 0
                Dim getClassSql As String = "SELECT ClassID FROM classes WHERE YearLevel=@YearLevel AND Section=@Section AND CourseID=@CourseID AND IsActive=1"
                Using getClassCmd As New MySqlCommand(getClassSql, conn)
                    getClassCmd.Parameters.AddWithValue("@YearLevel", ddlEditYearLevel.SelectedValue)
                    getClassCmd.Parameters.AddWithValue("@Section", ddlEditSection.SelectedValue)
                    getClassCmd.Parameters.AddWithValue("@CourseID", ddlEditCourse.SelectedValue)
                    Dim result = getClassCmd.ExecuteScalar()
                    If result IsNot Nothing Then
                        classID = Convert.ToInt32(result)
                    Else
                        ShowMessage("⚠ No class found for the selected year level, section, and course.", "warning")
                        Return
                    End If
                End Using

                ' Update the record
                Dim updateSql As String = "
            UPDATE facultyload 
            SET SubjectID=@SubjectID, 
                CourseID=@CourseID, 
                ClassID=@ClassID, 
                Term=@Term
            WHERE LoadID=@LoadID"
                Using updateCmd As New MySqlCommand(updateSql, conn)
                    updateCmd.Parameters.AddWithValue("@SubjectID", ddlEditSubject.SelectedValue)
                    updateCmd.Parameters.AddWithValue("@CourseID", ddlEditCourse.SelectedValue)
                    updateCmd.Parameters.AddWithValue("@ClassID", classID)
                    updateCmd.Parameters.AddWithValue("@Term", ddlEditTerm.SelectedValue)
                    updateCmd.Parameters.AddWithValue("@LoadID", loadID)
                    updateCmd.ExecuteNonQuery()
                End Using
            End Using

            gvFacultyDetails.EditIndex = -1
            LoadFacultyDetails(hfSelectedFacultyID.Value)
            ShowMessage("✅ Faculty load updated successfully.", "success")

        Catch ex As Exception
            ShowMessage("❌ Error updating faculty load: " & ex.Message, "danger")
        End Try
    End Sub
    Protected Sub gvFacultyDetails_RowDeleting(sender As Object, e As GridViewDeleteEventArgs)
        Dim loadID As Integer = Convert.ToInt32(gvFacultyDetails.DataKeys(e.RowIndex).Value)

        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                Dim sql As String = "UPDATE facultyload SET IsDeleted = 1 WHERE LoadID = @LoadID"
                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@LoadID", loadID)
                    cmd.ExecuteNonQuery()
                End Using
            End Using

            LoadFacultyDetails(hfSelectedFacultyID.Value)
            LoadFacultySummary()
            ShowMessage("✅ Faculty load deleted successfully.", "success")

        Catch ex As Exception
            ShowMessage("❌ Error deleting faculty load: " & ex.Message, "danger")
        End Try
    End Sub
    Protected Sub gvFacultyDetails_RowDataBound(sender As Object, e As GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            If (e.Row.RowState And DataControlRowState.Edit) > 0 Then
                ' Get data from DataKeys
                Dim courseID As Integer = Convert.ToInt32(gvFacultyDetails.DataKeys(e.Row.RowIndex).Values("CourseID"))
                Dim yearLevel As String = gvFacultyDetails.DataKeys(e.Row.RowIndex).Values("YearLevel").ToString()
                Dim section As String = gvFacultyDetails.DataKeys(e.Row.RowIndex).Values("Section").ToString()
                Dim subjectID As Integer = Convert.ToInt32(gvFacultyDetails.DataKeys(e.Row.RowIndex).Values("SubjectID"))
                Dim term As String = gvFacultyDetails.DataKeys(e.Row.RowIndex).Values("Term").ToString()

                ' Load and set Subject dropdown
                Dim ddlSubject As DropDownList = CType(e.Row.FindControl("ddlEditSubject"), DropDownList)
                If ddlSubject IsNot Nothing Then
                    LoadSubjectDropdown(ddlSubject)
                    ddlSubject.SelectedValue = subjectID.ToString()
                End If

                ' Load and set Course dropdown
                Dim ddlCourse As DropDownList = CType(e.Row.FindControl("ddlEditCourse"), DropDownList)
                If ddlCourse IsNot Nothing Then
                    LoadCourseDropdown(ddlCourse)
                    ddlCourse.SelectedValue = courseID.ToString()
                End If

                ' Load and set Year Level dropdown
                Dim ddlYearLevel As DropDownList = CType(e.Row.FindControl("ddlEditYearLevel"), DropDownList)
                If ddlYearLevel IsNot Nothing Then
                    LoadYearLevelsForCourse(courseID, ddlYearLevel)
                    ddlYearLevel.SelectedValue = yearLevel
                End If

                ' Load and set Section dropdown
                Dim ddlSection As DropDownList = CType(e.Row.FindControl("ddlEditSection"), DropDownList)
                If ddlSection IsNot Nothing Then
                    LoadSectionsForYearLevelAndCourse(yearLevel, courseID, ddlSection)
                    ddlSection.SelectedValue = section
                End If

                ' Set Term dropdown
                Dim ddlTerm As DropDownList = CType(e.Row.FindControl("ddlEditTerm"), DropDownList)
                If ddlTerm IsNot Nothing Then
                    ddlTerm.SelectedValue = term
                End If
            End If
        End If
    End Sub
#End Region
#Region "Helper Methods for Dropdowns"
    Private Sub LoadSubjectDropdown(ddl As DropDownList)
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "SELECT SubjectID, SubjectName FROM subjects WHERE IsActive = 1 ORDER BY SubjectName"
            Using cmd As New MySqlCommand(sql, conn)
                conn.Open()
                ddl.DataSource = cmd.ExecuteReader()
                ddl.DataTextField = "SubjectName"
                ddl.DataValueField = "SubjectID"
                ddl.DataBind()
            End Using
        End Using
    End Sub
    Private Sub LoadCourseDropdown(ddl As DropDownList)
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "SELECT CourseID, CourseName FROM courses WHERE IsActive = 1 ORDER BY CourseName"
            Using cmd As New MySqlCommand(sql, conn)
                conn.Open()
                ddl.DataSource = cmd.ExecuteReader()
                ddl.DataTextField = "CourseName"
                ddl.DataValueField = "CourseID"
                ddl.DataBind()
            End Using
        End Using
    End Sub
    Private Sub LoadYearLevelsForCourse(courseID As Integer, ddl As DropDownList)
        ddl.Items.Clear()
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "SELECT DISTINCT YearLevel FROM classes WHERE CourseID=@CourseID AND IsActive=1 ORDER BY YearLevel"
            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@CourseID", courseID)
                conn.Open()
                ddl.DataSource = cmd.ExecuteReader()
                ddl.DataTextField = "YearLevel"
                ddl.DataValueField = "YearLevel"
                ddl.DataBind()
            End Using
        End Using
    End Sub

    Private Sub LoadSectionsForYearLevelAndCourse(yearLevel As String, courseID As Integer, ddl As DropDownList)
        ddl.Items.Clear()
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "SELECT DISTINCT Section FROM classes WHERE YearLevel=@YearLevel AND CourseID=@CourseID AND IsActive=1 ORDER BY Section"
            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@YearLevel", yearLevel)
                cmd.Parameters.AddWithValue("@CourseID", courseID)
                conn.Open()
                ddl.DataSource = cmd.ExecuteReader()
                ddl.DataTextField = "Section"
                ddl.DataValueField = "Section"
                ddl.DataBind()
            End Using
        End Using
    End Sub
    Protected Sub ddlEditCourse_SelectedIndexChanged(sender As Object, e As EventArgs)
        Dim ddlEditCourse As DropDownList = CType(sender, DropDownList)
        Dim row As GridViewRow = CType(ddlEditCourse.NamingContainer, GridViewRow)
        Dim ddlEditYearLevel As DropDownList = CType(row.FindControl("ddlEditYearLevel"), DropDownList)

        If ddlEditCourse.SelectedValue <> "" Then
            Dim courseID As Integer = Convert.ToInt32(ddlEditCourse.SelectedValue)
            LoadYearLevelsForCourse(courseID, ddlEditYearLevel)

            ' Clear section dropdown
            Dim ddlEditSection As DropDownList = CType(row.FindControl("ddlEditSection"), DropDownList)
            If ddlEditSection IsNot Nothing Then
                ddlEditSection.Items.Clear()
                ddlEditSection.Items.Insert(0, New ListItem("Select Section", ""))
            End If
        End If
    End Sub
    Protected Sub ddlEditYearLevel_SelectedIndexChanged(sender As Object, e As EventArgs)
        Dim ddlEditYearLevel As DropDownList = CType(sender, DropDownList)
        Dim row As GridViewRow = CType(ddlEditYearLevel.NamingContainer, GridViewRow)
        Dim ddlEditSection As DropDownList = CType(row.FindControl("ddlEditSection"), DropDownList)
        Dim ddlEditCourse As DropDownList = CType(row.FindControl("ddlEditCourse"), DropDownList)

        If ddlEditYearLevel.SelectedValue <> "" AndAlso ddlEditCourse.SelectedValue <> "" Then
            Dim yearLevel As String = ddlEditYearLevel.SelectedValue
            Dim courseID As Integer = Convert.ToInt32(ddlEditCourse.SelectedValue)
            LoadSectionsForYearLevelAndCourse(yearLevel, courseID, ddlEditSection)
        End If
    End Sub
#End Region

#Region "Message Helper"
    Private Sub ShowMessage(message As String, type As String)
        lblMessage.Text = message
        lblMessage.CssClass = $"alert alert-{type} d-block alert-slide"
    End Sub
#End Region
    Protected Sub btnExport_Click(sender As Object, e As EventArgs)
        Try
            ExportFacultyLoadToCSV()
        Catch ex As Exception
            ShowMessage("❌ Error exporting data: " & ex.Message, "danger")
        End Try
    End Sub
    Private Sub ExportFacultyLoadToCSV()
        Dim csvContent As New StringBuilder()

        ' Add CSV headers
        csvContent.AppendLine("FacultyName,Department,Course,YearLevel,Section,SubjectCode,SubjectName,Term,Status")

        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "
            SELECT 
                CONCAT(u.LastName, ', ', u.FirstName, 
                    CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial != '' THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
                    CASE WHEN u.Suffix IS NOT NULL AND u.Suffix != '' THEN CONCAT(' ', u.Suffix) ELSE '' END
                ) AS FacultyName,
                d.DepartmentName AS Department,
                c.CourseName AS Course,
                cl.YearLevel,
                cl.Section,
                s.SubjectCode,
                s.SubjectName,
                fl.Term,
                CASE WHEN fl.IsDeleted = 1 THEN 'Inactive' ELSE 'Active' END AS Status
            FROM facultyload fl
            INNER JOIN users u ON fl.FacultyID = u.UserID
            INNER JOIN subjects s ON fl.SubjectID = s.SubjectID
            INNER JOIN courses c ON fl.CourseID = c.CourseID
            INNER JOIN classes cl ON fl.ClassID = cl.ClassID
            INNER JOIN departments d ON fl.DepartmentID = d.DepartmentID
            ORDER BY u.LastName, u.FirstName, s.SubjectName"

            Using cmd As New MySqlCommand(sql, conn)
                conn.Open()
                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    While reader.Read()
                        Dim row As New List(Of String)

                        ' Add all fields with proper CSV escaping
                        row.Add(EscapeCsvField(reader("FacultyName").ToString()))
                        row.Add(EscapeCsvField(reader("Department").ToString()))
                        row.Add(EscapeCsvField(reader("Course").ToString()))
                        row.Add(EscapeCsvField(reader("YearLevel").ToString()))
                        row.Add(EscapeCsvField(reader("Section").ToString()))
                        row.Add(EscapeCsvField(reader("SubjectCode").ToString()))
                        row.Add(EscapeCsvField(reader("SubjectName").ToString()))
                        row.Add(EscapeCsvField(reader("Term").ToString()))
                        row.Add(EscapeCsvField(reader("Status").ToString()))

                        csvContent.AppendLine(String.Join(",", row))
                    End While
                End Using
            End Using
        End Using

        ' Send CSV file to browser
        Response.Clear()
        Response.Buffer = True
        Response.Charset = "utf-8"
        Response.ContentType = "text/csv"
        Response.AddHeader("content-disposition", $"attachment;filename=FacultyLoad_Export_{DateTime.Now:yyyyMMdd_HHmmss}.csv")
        Response.Write(csvContent.ToString())
        Response.Flush()
        Response.End()
    End Sub
    Protected Sub btnDownloadTemplate_Click(sender As Object, e As EventArgs)
        DownloadTemplate()
    End Sub

    Private Sub DownloadTemplate()
        Dim templateContent As New StringBuilder()

        ' Create comprehensive template with headers and examples
        templateContent.AppendLine("FacultyName,Department,Course,YearLevel,Section,SubjectCode,SubjectName,Term")
        templateContent.AppendLine("""Smith, John D."",""IT Department"",""Bachelor of Science in Information Technology"",""1ST"",""A"",""PROG101"",""Introduction to Programming"",""1st Semester""")
        templateContent.AppendLine("""Johnson, Maria R."",""CS Department"",""Bachelor of Science in Computer Science"",""2ND"",""B"",""DBMS101"",""Database Management Systems"",""2nd Semester""")
        templateContent.AppendLine("""Williams, Lisa K."",""Criminology Department"",""Bachelor of Science in Criminology"",""1ST"",""A"",""CRIM101"",""Criminal Law"",""1st Semester""")

        ' Add instructions as comments
        templateContent.AppendLine()
        templateContent.AppendLine("# INSTRUCTIONS:")
        templateContent.AppendLine("# - FacultyName: Format as 'Last, First Middle' (e.g., 'Smith, John D.')")
        templateContent.AppendLine("# - Department: Department name")
        templateContent.AppendLine("# - Course: Full course name")
        templateContent.AppendLine("# - YearLevel: 1ST, 2ND, 3RD, 4TH")
        templateContent.AppendLine("# - Section: Section code (A, B, C, etc.)")
        templateContent.AppendLine("# - SubjectCode: Subject code (e.g., PROG101)")
        templateContent.AppendLine("# - SubjectName: Full subject name")
        templateContent.AppendLine("# - Term: '1st Semester' or '2nd Semester'")
        templateContent.AppendLine("#")
        templateContent.AppendLine("# NOTES:")
        templateContent.AppendLine("# - Required fields: FacultyName, Course, SubjectCode, YearLevel, Section, Term")
        templateContent.AppendLine("# - Department is auto-detected from Course")
        templateContent.AppendLine("# - Missing subjects and classes are created automatically")
        templateContent.AppendLine("# - Duplicate active assignments are skipped")
        templateContent.AppendLine("# - Previously deleted assignments are reactivated")

        ' Send template file to browser
        Response.Clear()
        Response.Buffer = True
        Response.Charset = "utf-8"
        Response.ContentType = "text/csv"
        Response.AddHeader("content-disposition", "attachment;filename=FacultyLoad_Import_Template.csv")
        Response.Write(templateContent.ToString())
        Response.Flush()
        Response.End()
    End Sub
    Protected Sub btnImport_Click(sender As Object, e As EventArgs)
        If Not fileUpload.HasFile Then
            ShowImportMessage("❌ Please select a CSV file to import.", "danger")
            Return
        End If

        If Path.GetExtension(fileUpload.FileName).ToLower() <> ".csv" Then
            ShowImportMessage("❌ Please select a valid CSV file.", "danger")
            Return
        End If

        If fileUpload.PostedFile.ContentLength > 10 * 1024 * 1024 Then ' 10MB
            ShowImportMessage("❌ File size exceeds 10MB limit.", "danger")
            Return
        End If

        ImportFacultyLoadFromCSV()
    End Sub
    Private Sub ImportFacultyLoadFromCSV()
        Dim importResult As New ImportResult()
        Dim filePath As String = String.Empty

        Try
            ' Ensure upload directory exists
            EnsureUploadDirectory()

            ' Save uploaded file
            filePath = SaveUploadedFile()

            ' Process CSV file
            Using reader As New StreamReader(filePath)
                ProcessCsvFile(reader, importResult)
            End Using

            ' Display results
            DisplayImportResults(importResult)

            ' Refresh grid if any records were processed
            If importResult.TotalProcessed > 0 Then
                LoadFacultySummary()
            End If

        Catch ex As Exception
            ShowImportMessage("❌ Import failed: " & ex.Message, "danger")
        Finally
            ' Clean up uploaded file
            If Not String.IsNullOrEmpty(filePath) Then
                CleanupUploadedFile(filePath)
            End If
        End Try
    End Sub

    Private Sub ProcessCsvFile(reader As StreamReader, ByRef importResult As ImportResult)
        Dim lineNumber As Integer = 0
        Dim skipErrors As Boolean = chkSkipErrors.Checked
        Dim createMissing As Boolean = chkCreateMissing.Checked

        While Not reader.EndOfStream
            lineNumber += 1
            Dim line As String = reader.ReadLine().Trim()

            ' Skip empty lines and comments
            If String.IsNullOrEmpty(line) OrElse line.StartsWith("#") Then
                Continue While
            End If

            ' Process CSV line
            Try
                Dim fields As String() = ParseCsvLine(line)

                ' Validate minimum field count
                If fields.Length < 5 Then
                    Throw New Exception("Insufficient fields. Minimum 5 required.")
                End If

                ' Skip header row
                If lineNumber = 1 AndAlso fields(0).Equals("FacultyName", StringComparison.OrdinalIgnoreCase) Then
                    Continue While
                End If

                ' Process record
                ProcessImportRecord(fields, lineNumber, importResult, createMissing)

            Catch ex As Exception
                importResult.ErrorCount += 1
                importResult.ErrorMessages.Add($"Line {lineNumber}: {ex.Message}")

                If Not skipErrors Then
                    Throw New Exception($"Import stopped at line {lineNumber}: {ex.Message}")
                End If
            End Try
        End While
    End Sub
    Private Sub ProcessImportRecord(fields As String(), lineNumber As Integer, ByRef importResult As ImportResult, createMissing As Boolean)
        ' Extract and validate fields
        Dim facultyName As String = GetField(fields, 0, "FacultyName").Trim()
        Dim courseName As String = GetField(fields, 1, "Course").Trim()
        Dim yearLevel As String = GetField(fields, 2, "YearLevel").Trim().ToUpper()
        Dim section As String = GetField(fields, 3, "Section").Trim().ToUpper()
        Dim subjectCode As String = GetField(fields, 4, "SubjectCode").Trim().ToUpper()
        Dim subjectName As String = GetField(fields, 5, "SubjectName").Trim()
        Dim term As String = GetField(fields, 6, "Term", "1st Semester").Trim()
        ' Validate required fields
        ValidateRequiredField(facultyName, "FacultyName", lineNumber)
        ValidateRequiredField(courseName, "Course", lineNumber)
        ValidateRequiredField(yearLevel, "YearLevel", lineNumber)
        ValidateRequiredField(section, "Section", lineNumber)
        ValidateRequiredField(subjectCode, "SubjectCode", lineNumber)
        ValidateRequiredField(term, "Term", lineNumber)
        ' Process the record in database
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            ProcessDatabaseRecord(facultyName, courseName, yearLevel, section, subjectCode, subjectName, term, lineNumber, importResult, createMissing, conn)
        End Using
    End Sub
    Private Sub ProcessDatabaseRecord(facultyName As String, courseName As String, yearLevel As String, section As String,
                                    subjectCode As String, subjectName As String, term As String, lineNumber As Integer,
                                    ByRef importResult As ImportResult, createMissing As Boolean, conn As MySqlConnection)

        ' 1. Resolve Faculty
        Dim facultyID As Integer = ResolveFaculty(facultyName, conn)
        If facultyID = 0 Then
            Throw New Exception($"Faculty not found: {facultyName}")
        End If

        ' 2. Resolve Course and get DepartmentID
        Dim courseID As Integer = ResolveCourse(courseName, conn)
        If courseID = 0 Then
            Throw New Exception($"Course not found: {courseName}")
        End If

        ' 3. Get DepartmentID from Course
        Dim departmentID As Integer = GetDepartmentFromCourse(courseID, conn)
        If departmentID = 0 Then
            Throw New Exception($"Department not found for course: {courseName}")
        End If

        ' 4. Resolve or create Subject
        Dim subjectID As Integer = ResolveSubject(subjectCode, subjectName, createMissing, conn)
        If subjectID = 0 Then
            Throw New Exception($"Subject not found: {subjectCode} and auto-creation is disabled")
        End If

        ' 5. Resolve or create Class
        Dim classID As Integer = ResolveClass(yearLevel, section, courseID, createMissing, conn)
        If classID = 0 Then
            Throw New Exception($"Class not found: {yearLevel}-{section} for course ID {courseID} and auto-creation is disabled")
        End If

        ' 6. Process Faculty Load assignment
        ProcessFacultyLoadAssignment(facultyID, departmentID, courseID, subjectID, classID, term, facultyName, subjectCode, yearLevel, section, lineNumber, importResult, conn)
    End Sub
    Private Sub ProcessFacultyLoadAssignment(facultyID As Integer, departmentID As Integer, courseID As Integer,
                                           subjectID As Integer, classID As Integer, term As String,
                                           facultyName As String, subjectCode As String, yearLevel As String, section As String,
                                           lineNumber As Integer, ByRef importResult As ImportResult, conn As MySqlConnection)

        ' Check for existing assignment
        Dim existingAssignment As ExistingAssignment = GetExistingAssignment(facultyID, subjectID, classID, term, conn)

        If existingAssignment IsNot Nothing Then
            If existingAssignment.IsDeleted Then
                ' Reactivate deleted assignment
                ReactivateFacultyLoad(existingAssignment.LoadID, facultyID, departmentID, courseID, subjectID, classID, term, conn)
                importResult.ReactivatedCount += 1
                importResult.ReactivatedMessages.Add($"Line {lineNumber}: Reactivated {facultyName} - {subjectCode} ({yearLevel}-{section})")
            Else
                ' Skip active assignment
                importResult.SkippedCount += 1
                importResult.SkippedMessages.Add($"Line {lineNumber}: Skipped {facultyName} - {subjectCode} ({yearLevel}-{section}) - Already assigned")
            End If
        Else
            ' Create new assignment
            CreateFacultyLoad(facultyID, departmentID, courseID, subjectID, classID, term, conn)
            importResult.SuccessCount += 1
            importResult.SuccessMessages.Add($"Line {lineNumber}: Added {facultyName} - {subjectCode} ({yearLevel}-{section})")
        End If
    End Sub
    Private Function ResolveFaculty(facultyName As String, conn As MySqlConnection) As Integer
        Dim nameParts As String() = facultyName.Split(","c)
        If nameParts.Length < 2 Then Return 0

        Dim lastName As String = nameParts(0).Trim()
        Dim firstMiddle As String = nameParts(1).Trim()
        Dim firstMiddleParts As String() = firstMiddle.Split(" "c)
        Dim firstName As String = firstMiddleParts(0).Trim()
        Dim middleInitial As String = If(firstMiddleParts.Length > 1, firstMiddleParts(1).Trim().Replace(".", ""), "")

        Dim sql As String = "SELECT UserID FROM users WHERE Role='Faculty' AND Status='Active' AND LastName=@LastName AND FirstName=@FirstName"
        If Not String.IsNullOrEmpty(middleInitial) Then
            sql &= " AND MiddleInitial=@MiddleInitial"
        End If

        Using cmd As New MySqlCommand(sql, conn)
            cmd.Parameters.AddWithValue("@LastName", lastName)
            cmd.Parameters.AddWithValue("@FirstName", firstName)
            If Not String.IsNullOrEmpty(middleInitial) Then
                cmd.Parameters.AddWithValue("@MiddleInitial", middleInitial)
            End If

            Dim result = cmd.ExecuteScalar()
            Return If(result IsNot Nothing, Convert.ToInt32(result), 0)
        End Using
    End Function
    Private Function ResolveCourse(courseName As String, conn As MySqlConnection) As Integer
        Dim sqlWhere As String = "SELECT CourseID FROM courses WHERE IsActive=1 AND CourseName=@CourseName"
        Using cmd As New MySqlCommand(sqlWhere, conn)
            cmd.Parameters.AddWithValue("@CourseName", courseName)
            Dim result = cmd.ExecuteScalar()
            Return If(result IsNot Nothing, Convert.ToInt32(result), 0)
        End Using
    End Function
    Private Function GetDepartmentFromCourse(courseID As Integer, conn As MySqlConnection) As Integer
        Dim sql As String = "SELECT DepartmentID FROM courses WHERE CourseID=@CourseID"
        Using cmd As New MySqlCommand(sql, conn)
            cmd.Parameters.AddWithValue("@CourseID", courseID)
            Dim result = cmd.ExecuteScalar()
            Return If(result IsNot Nothing, Convert.ToInt32(result), 0)
        End Using
    End Function
    Private Function ResolveSubject(subjectCode As String, subjectName As String, createMissing As Boolean, conn As MySqlConnection) As Integer
        ' Try to find existing subject
        Dim sqlFind As String = "SELECT SubjectID FROM subjects WHERE SubjectCode=@SubjectCode AND IsActive=1"
        Using cmdFind As New MySqlCommand(sqlFind, conn)
            cmdFind.Parameters.AddWithValue("@SubjectCode", subjectCode)
            Dim result = cmdFind.ExecuteScalar()
            If result IsNot Nothing Then
                Return Convert.ToInt32(result)
            End If
        End Using

        ' Create new subject if allowed
        If createMissing AndAlso Not String.IsNullOrEmpty(subjectName) Then
            Dim sqlInsert As String = "INSERT INTO subjects (SubjectCode, SubjectName, IsActive) VALUES (@SubjectCode, @SubjectName, 1)"
            Using cmdInsert As New MySqlCommand(sqlInsert, conn)
                cmdInsert.Parameters.AddWithValue("@SubjectCode", subjectCode)
                cmdInsert.Parameters.AddWithValue("@SubjectName", subjectName)
                cmdInsert.ExecuteNonQuery()
                Return cmdInsert.LastInsertedId
            End Using
        End If

        Return 0
    End Function
    Private Function ResolveClass(yearLevel As String, section As String, courseID As Integer, createMissing As Boolean, conn As MySqlConnection) As Integer
        ' Try to find existing class
        Dim sqlFind As String = "SELECT ClassID FROM classes WHERE YearLevel=@YearLevel AND Section=@Section AND CourseID=@CourseID AND IsActive=1"
        Using cmdFind As New MySqlCommand(sqlFind, conn)
            cmdFind.Parameters.AddWithValue("@YearLevel", yearLevel)
            cmdFind.Parameters.AddWithValue("@Section", section)
            cmdFind.Parameters.AddWithValue("@CourseID", courseID)
            Dim result = cmdFind.ExecuteScalar()
            If result IsNot Nothing Then
                Return Convert.ToInt32(result)
            End If
        End Using

        ' Create new class if allowed
        If createMissing Then
            Dim sqlInsert As String = "INSERT INTO classes (CourseID, YearLevel, Section, IsActive) VALUES (@CourseID, @YearLevel, @Section, 1)"
            Using cmdInsert As New MySqlCommand(sqlInsert, conn)
                cmdInsert.Parameters.AddWithValue("@CourseID", courseID)
                cmdInsert.Parameters.AddWithValue("@YearLevel", yearLevel)
                cmdInsert.Parameters.AddWithValue("@Section", section)
                cmdInsert.ExecuteNonQuery()
                Return cmdInsert.LastInsertedId
            End Using
        End If

        Return 0
    End Function
    Private Class ExistingAssignment
        Public Property LoadID As Integer
        Public Property IsDeleted As Boolean
    End Class
    Private Function GetExistingAssignment(facultyID As Integer, subjectID As Integer, classID As Integer, term As String, conn As MySqlConnection) As ExistingAssignment
        Dim sql As String = "SELECT LoadID, IsDeleted FROM facultyload WHERE FacultyID=@FacultyID AND SubjectID=@SubjectID AND ClassID=@ClassID AND Term=@Term"
        Using cmd As New MySqlCommand(sql, conn)
            cmd.Parameters.AddWithValue("@FacultyID", facultyID)
            cmd.Parameters.AddWithValue("@SubjectID", subjectID)
            cmd.Parameters.AddWithValue("@ClassID", classID)
            cmd.Parameters.AddWithValue("@Term", term)

            Using reader As MySqlDataReader = cmd.ExecuteReader()
                If reader.Read() Then
                    Return New ExistingAssignment With {
                        .LoadID = Convert.ToInt32(reader("LoadID")),
                        .IsDeleted = Convert.ToBoolean(reader("IsDeleted"))
                    }
                End If
            End Using
        End Using
        Return Nothing
    End Function
    Private Sub ReactivateFacultyLoad(loadID As Integer, facultyID As Integer, departmentID As Integer, courseID As Integer, subjectID As Integer, classID As Integer, term As String, conn As MySqlConnection)
        Dim sql As String = "UPDATE facultyload SET FacultyID=@FacultyID, DepartmentID=@DepartmentID, CourseID=@CourseID, SubjectID=@SubjectID, ClassID=@ClassID, Term=@Term, IsDeleted=0 WHERE LoadID=@LoadID"
        Using cmd As New MySqlCommand(sql, conn)
            cmd.Parameters.AddWithValue("@LoadID", loadID)
            cmd.Parameters.AddWithValue("@FacultyID", facultyID)
            cmd.Parameters.AddWithValue("@DepartmentID", departmentID)
            cmd.Parameters.AddWithValue("@CourseID", courseID)
            cmd.Parameters.AddWithValue("@SubjectID", subjectID)
            cmd.Parameters.AddWithValue("@ClassID", classID)
            cmd.Parameters.AddWithValue("@Term", term)
            cmd.ExecuteNonQuery()
        End Using
    End Sub
    Private Sub CreateFacultyLoad(facultyID As Integer, departmentID As Integer, courseID As Integer, subjectID As Integer, classID As Integer, term As String, conn As MySqlConnection)
        Dim sql As String = "INSERT INTO facultyload (FacultyID, DepartmentID, CourseID, SubjectID, ClassID, Term, IsDeleted) VALUES (@FacultyID, @DepartmentID, @CourseID, @SubjectID, @ClassID, @Term, 0)"
        Using cmd As New MySqlCommand(sql, conn)
            cmd.Parameters.AddWithValue("@FacultyID", facultyID)
            cmd.Parameters.AddWithValue("@DepartmentID", departmentID)
            cmd.Parameters.AddWithValue("@CourseID", courseID)
            cmd.Parameters.AddWithValue("@SubjectID", subjectID)
            cmd.Parameters.AddWithValue("@ClassID", classID)
            cmd.Parameters.AddWithValue("@Term", term)
            cmd.ExecuteNonQuery()
        End Using
    End Sub
    Private Function ParseCsvLine(line As String) As String()
        Dim fields As New List(Of String)()
        Dim currentField As New StringBuilder()
        Dim inQuotes As Boolean = False
        Dim quoteChar As Char = """"c

        For i As Integer = 0 To line.Length - 1
            Dim c As Char = line(i)

            If c = quoteChar Then
                If inQuotes AndAlso i < line.Length - 1 AndAlso line(i + 1) = quoteChar Then
                    ' Escaped quote
                    currentField.Append(quoteChar)
                    i += 1 ' Skip next quote
                Else
                    inQuotes = Not inQuotes
                End If
            ElseIf c = ","c AndAlso Not inQuotes Then
                fields.Add(currentField.ToString())
                currentField.Clear()
            Else
                currentField.Append(c)
            End If
        Next
        ' Add the last field
        fields.Add(currentField.ToString())
        Return fields.ToArray()
    End Function
    Private Function EscapeCsvField(field As String) As String
        If String.IsNullOrEmpty(field) Then Return ""

        ' If field contains comma, quote, or newline, wrap in quotes and escape quotes
        If field.Contains(",") OrElse field.Contains("""") OrElse field.Contains(vbCr) OrElse field.Contains(vbLf) Then
            Return """" & field.Replace("""", """""") & """"
        End If

        Return field
    End Function
    Private Function GetField(fields As String(), index As Integer, fieldName As String, Optional defaultValue As String = "") As String
        If index < fields.Length Then
            Return fields(index)
        End If
        Return defaultValue
    End Function

    Private Sub ValidateRequiredField(value As String, fieldName As String, lineNumber As Integer)
        If String.IsNullOrWhiteSpace(value) Then
            Throw New Exception($"{fieldName} is required")
        End If
    End Sub
    Private Sub EnsureUploadDirectory()
        If Not Directory.Exists(UploadFolder) Then
            Directory.CreateDirectory(UploadFolder)
        End If
    End Sub

    Private Function SaveUploadedFile() As String
        Dim fileName As String = $"Import_{DateTime.Now:yyyyMMdd_HHmmss}_{Path.GetRandomFileName()}.csv"
        Dim filePath As String = Path.Combine(UploadFolder, fileName)
        fileUpload.SaveAs(filePath)
        Return filePath
    End Function
    Private Sub CleanupUploadedFile(filePath As String)
        Try
            If File.Exists(filePath) Then
                File.Delete(filePath)
            End If
        Catch ex As Exception
            ' Log deletion error but don't interrupt user
            System.Diagnostics.Debug.WriteLine($"Cleanup error: {ex.Message}")
        End Try
    End Sub
    Private Class ImportResult
        Public Property SuccessCount As Integer = 0
        Public Property ReactivatedCount As Integer = 0
        Public Property SkippedCount As Integer = 0
        Public Property ErrorCount As Integer = 0
        Public Property SuccessMessages As New List(Of String)()
        Public Property ReactivatedMessages As New List(Of String)()
        Public Property SkippedMessages As New List(Of String)()
        Public Property ErrorMessages As New List(Of String)()

        Public ReadOnly Property TotalProcessed As Integer
            Get
                Return SuccessCount + ReactivatedCount + SkippedCount
            End Get
        End Property
    End Class
    Private Sub DisplayImportResults(result As ImportResult)
        Dim resultHtml As New StringBuilder()

        resultHtml.AppendLine($"<div class='mb-2'><strong>Import Summary:</strong></div>")
        resultHtml.AppendLine($"<div class='row text-center mb-3'>")
        resultHtml.AppendLine($"<div class='col'><span class='badge bg-success'>{result.SuccessCount} Added</span></div>")
        resultHtml.AppendLine($"<div class='col'><span class='badge bg-warning'>{result.ReactivatedCount} Reactivated</span></div>")
        resultHtml.AppendLine($"<div class='col'><span class='badge bg-info'>{result.SkippedCount} Skipped</span></div>")
        resultHtml.AppendLine($"<div class='col'><span class='badge bg-danger'>{result.ErrorCount} Errors</span></div>")
        resultHtml.AppendLine($"</div>")

        ' Show detailed messages (limited to first 10 of each type)
        If result.SuccessMessages.Any() Then
            resultHtml.AppendLine($"<div class='mt-2'><strong>New Assignments ({Math.Min(10, result.SuccessCount)} shown):</strong></div>")
            For Each msg In result.SuccessMessages.Take(10)
                resultHtml.AppendLine($"<div class='text-success small'>✓ {msg}</div>")
            Next
        End If

        If result.ReactivatedMessages.Any() Then
            resultHtml.AppendLine($"<div class='mt-2'><strong>Reactivated Assignments ({Math.Min(10, result.ReactivatedCount)} shown):</strong></div>")
            For Each msg In result.ReactivatedMessages.Take(10)
                resultHtml.AppendLine($"<div class='text-warning small'>↻ {msg}</div>")
            Next
        End If

        If result.SkippedMessages.Any() Then
            resultHtml.AppendLine($"<div class='mt-2'><strong>Skipped Assignments ({Math.Min(10, result.SkippedCount)} shown):</strong></div>")
            For Each msg In result.SkippedMessages.Take(10)
                resultHtml.AppendLine($"<div class='text-info small'>⏭️ {msg}</div>")
            Next
        End If

        If result.ErrorMessages.Any() Then
            resultHtml.AppendLine($"<div class='mt-2'><strong>Errors ({Math.Min(10, result.ErrorCount)} shown):</strong></div>")
            For Each msg In result.ErrorMessages.Take(10)
                resultHtml.AppendLine($"<div class='text-danger small'>❌ {msg}</div>")
            Next
        End If

        litImportResults.Text = resultHtml.ToString()
        pnlImportResults.Visible = True

        ' Set appropriate message
        If result.SuccessCount > 0 OrElse result.ReactivatedCount > 0 Then
            ShowImportMessage($"✅ Import completed! Processed {result.TotalProcessed} records ({result.SuccessCount} new, {result.ReactivatedCount} reactivated).", "success")
        ElseIf result.SkippedCount > 0 Then
            ShowImportMessage($"⏭️ Import completed. {result.SkippedCount} records were skipped (already assigned).", "info")
        Else
            ShowImportMessage("❌ No records were imported. Please check the error details above.", "danger")
        End If
    End Sub
    Private Sub ShowImportMessage(message As String, type As String)
        lblImportMessage.Text = message
        lblImportMessage.CssClass = $"alert alert-{type} d-block"
    End Sub
    Private ReadOnly Property UploadFolder As String
        Get
            Return Server.MapPath("~/Uploads/")
        End Get
    End Property
    ' Helper method to calculate total subject count from terms
    Public Function GetTotalSubjectCount(dataItem As Object) As Integer
        Dim total As Integer = 0
        Dim terms = TryCast(dataItem.GetType().GetProperty("Terms").GetValue(dataItem), IEnumerable)

        If terms IsNot Nothing Then
            For Each term In terms
                Dim subjectCount = term.GetType().GetProperty("SubjectCount").GetValue(term)
                total += Convert.ToInt32(subjectCount)
            Next
        End If

        Return total
    End Function
    Protected Sub btnEditModal_Click(sender As Object, e As EventArgs)
        Dim btnEdit As LinkButton = CType(sender, LinkButton)

        ' Debug: Check if we're getting the CommandArgument
        If String.IsNullOrEmpty(btnEdit.CommandArgument) Then
            lblMessage.Text = "❌ Error: LoadID is missing from CommandArgument"
            lblMessage.CssClass = "alert alert-danger d-block"
            System.Diagnostics.Debug.WriteLine("ERROR: CommandArgument is empty")
            Return
        End If

        Dim loadID As Integer = Convert.ToInt32(btnEdit.CommandArgument)
        System.Diagnostics.Debug.WriteLine($"Edit button clicked - LoadID: {loadID}")

        ' Load the data for edit modal
        LoadEditModalData(loadID)

        ' Debug: Check if data was loaded
        System.Diagnostics.Debug.WriteLine($"After LoadEditModalData - hfEditLoadID: {hfEditLoadID.Value}")

        ScriptManager.RegisterStartupScript(Me, Me.GetType(), "ShowEditModal", "showEditModal();", True)
    End Sub
    Private Sub LoadEditModalData(loadID As Integer)
        Try
            System.Diagnostics.Debug.WriteLine($"Starting LoadEditModalData for LoadID: {loadID}")

            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                Dim sql As String = "
            SELECT fl.LoadID, fl.FacultyID, fl.SubjectID, fl.CourseID, fl.ClassID, fl.Term,
                   CONCAT(u.LastName, ', ', u.FirstName, 
                       CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial != '' THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
                       CASE WHEN u.Suffix IS NOT NULL AND u.Suffix != '' THEN CONCAT(' ', u.Suffix) ELSE '' END
                   ) AS FacultyName,
                   s.SubjectName, s.SubjectCode,
                   c.CourseName,
                   cl.YearLevel, cl.Section
            FROM facultyload fl
            INNER JOIN users u ON fl.FacultyID = u.UserID
            INNER JOIN subjects s ON fl.SubjectID = s.SubjectID
            INNER JOIN courses c ON fl.CourseID = c.CourseID
            INNER JOIN classes cl ON fl.ClassID = cl.ClassID
            WHERE fl.LoadID = @LoadID"

                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@LoadID", loadID)

                    Using reader As MySqlDataReader = cmd.ExecuteReader()
                        If reader.Read() Then
                            ' Store the LoadID in hidden field
                            hfEditLoadID.Value = reader("LoadID").ToString()
                            hfEditModalFacultyID.Value = reader("FacultyID").ToString()
                            txtEditModalFaculty.Text = reader("FacultyName").ToString()

                            ' Load dropdowns
                            LoadEditModalCourses()
                            LoadEditModalSubjects()
                            LoadEditModalYearLevels(reader("CourseID").ToString())
                            LoadEditModalSections(reader("YearLevel").ToString(), reader("CourseID").ToString())

                            ' Set selected values
                            ddlEditModalCourse.SelectedValue = reader("CourseID").ToString()
                            ddlEditModalYearLevel.SelectedValue = reader("YearLevel").ToString()
                            ddlEditModalSection.SelectedValue = reader("Section").ToString()
                            ddlEditModalSubject.SelectedValue = reader("SubjectID").ToString()
                            ddlEditModalTerm.SelectedValue = reader("Term").ToString()

                            System.Diagnostics.Debug.WriteLine($"Edit modal data loaded successfully")
                            System.Diagnostics.Debug.WriteLine($"Course: {reader("CourseID")}, Subject: {reader("SubjectID")}, Year: {reader("YearLevel")}, Section: {reader("Section")}")
                        Else
                            System.Diagnostics.Debug.WriteLine($"No data found for LoadID: {loadID}")
                            lblEditModalMessage.Text = "❌ Faculty load data not found."
                            lblEditModalMessage.CssClass = "alert alert-danger d-block"
                        End If
                    End Using
                End Using
            End Using

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"Error in LoadEditModalData: {ex.Message}")
            System.Diagnostics.Debug.WriteLine($"Stack Trace: {ex.StackTrace}")
            lblEditModalMessage.Text = "❌ Error loading edit data: " & ex.Message
            lblEditModalMessage.CssClass = "alert alert-danger d-block"
        End Try
    End Sub
    Private Sub LoadEditModalCourses()
        Try
            ddlEditModalCourse.Items.Clear()
            Using conn As New MySqlConnection(ConnString)
                Dim sql As String = "SELECT CourseID, CourseName FROM courses WHERE IsActive = 1 ORDER BY CourseName"
                Using cmd As New MySqlCommand(sql, conn)
                    conn.Open()
                    Dim dt As New DataTable()
                    dt.Load(cmd.ExecuteReader())
                    ddlEditModalCourse.DataSource = dt
                    ddlEditModalCourse.DataTextField = "CourseName"
                    ddlEditModalCourse.DataValueField = "CourseID"
                    ddlEditModalCourse.DataBind()
                End Using
            End Using
            ddlEditModalCourse.Items.Insert(0, New ListItem("Select Course", ""))
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"Error in LoadEditModalCourses: {ex.Message}")
        End Try
    End Sub
    Private Sub LoadEditModalSubjects()
        Try
            ddlEditModalSubject.Items.Clear()
            Using conn As New MySqlConnection(ConnString)
                Dim sql As String = "SELECT SubjectID, SubjectName FROM subjects WHERE IsActive = 1 ORDER BY SubjectName"
                Using cmd As New MySqlCommand(sql, conn)
                    conn.Open()
                    Dim dt As New DataTable()
                    dt.Load(cmd.ExecuteReader())
                    ddlEditModalSubject.DataSource = dt
                    ddlEditModalSubject.DataTextField = "SubjectName"
                    ddlEditModalSubject.DataValueField = "SubjectID"
                    ddlEditModalSubject.DataBind()
                End Using
            End Using
            ddlEditModalSubject.Items.Insert(0, New ListItem("Select Subject", ""))
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"Error in LoadEditModalSubjects: {ex.Message}")
        End Try
    End Sub
    Private Sub LoadEditModalYearLevels(courseID As String)
        Try
            ddlEditModalYearLevel.Items.Clear()
            Using conn As New MySqlConnection(ConnString)
                Dim sql As String = "SELECT DISTINCT YearLevel FROM classes WHERE CourseID=@CourseID AND IsActive=1 ORDER BY YearLevel"
                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@CourseID", courseID)
                    conn.Open()
                    Dim dt As New DataTable()
                    dt.Load(cmd.ExecuteReader())
                    ddlEditModalYearLevel.DataSource = dt
                    ddlEditModalYearLevel.DataTextField = "YearLevel"
                    ddlEditModalYearLevel.DataValueField = "YearLevel"
                    ddlEditModalYearLevel.DataBind()
                End Using
            End Using
            ddlEditModalYearLevel.Items.Insert(0, New ListItem("Select Year Level", ""))
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"Error in LoadEditModalYearLevels: {ex.Message}")
        End Try
    End Sub
    Private Sub LoadEditModalSections(yearLevel As String, courseID As String)
        Try
            ddlEditModalSection.Items.Clear()
            Using conn As New MySqlConnection(ConnString)
                Dim sql As String = "SELECT DISTINCT Section FROM classes WHERE YearLevel=@YearLevel AND CourseID=@CourseID AND IsActive=1 ORDER BY Section"
                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@YearLevel", yearLevel)
                    cmd.Parameters.AddWithValue("@CourseID", courseID)
                    conn.Open()
                    Dim dt As New DataTable()
                    dt.Load(cmd.ExecuteReader())
                    ddlEditModalSection.DataSource = dt
                    ddlEditModalSection.DataTextField = "Section"
                    ddlEditModalSection.DataValueField = "Section"
                    ddlEditModalSection.DataBind()
                End Using
            End Using
            ddlEditModalSection.Items.Insert(0, New ListItem("Select Section", ""))
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"Error in LoadEditModalSections: {ex.Message}")
        End Try
    End Sub
    Protected Sub ddlEditModalCourse_SelectedIndexChanged(sender As Object, e As EventArgs)
        If ddlEditModalCourse.SelectedValue <> "" Then
            LoadEditModalYearLevels(ddlEditModalCourse.SelectedValue)
        Else
            ddlEditModalYearLevel.Items.Clear()
            ddlEditModalYearLevel.Items.Insert(0, New ListItem("Select Year Level", ""))
            ddlEditModalSection.Items.Clear()
            ddlEditModalSection.Items.Insert(0, New ListItem("Select Section", ""))
        End If
    End Sub
    Protected Sub ddlEditModalYearLevel_SelectedIndexChanged(sender As Object, e As EventArgs)
        If ddlEditModalYearLevel.SelectedValue <> "" AndAlso ddlEditModalCourse.SelectedValue <> "" Then
            LoadEditModalSections(ddlEditModalYearLevel.SelectedValue, ddlEditModalCourse.SelectedValue)
        Else
            ddlEditModalSection.Items.Clear()
            ddlEditModalSection.Items.Insert(0, New ListItem("Select Section", ""))
        End If
    End Sub
    Protected Sub btnUpdateAssignment_Click(sender As Object, e As EventArgs)
        ' Validate fields
        If ddlEditModalCourse.SelectedValue = "" Or ddlEditModalYearLevel.SelectedValue = "" Or
   ddlEditModalSection.SelectedValue = "" Or ddlEditModalSubject.SelectedValue = "" Or
   ddlEditModalTerm.SelectedValue = "" Then

            lblEditModalMessage.Text = "⚠ Please fill in all required fields."
            lblEditModalMessage.CssClass = "alert alert-danger d-block"
            ScriptManager.RegisterStartupScript(Me, Me.GetType(), "KeepEditModalOpen", "setKeepEditModalOpen(true);", True)
            Return
        End If
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                ' Get ClassID
                Dim classID As Integer = 0
                Dim getClassSql As String = "SELECT ClassID FROM classes WHERE YearLevel=@YearLevel AND Section=@Section AND CourseID=@CourseID AND IsActive=1"
                Using getClassCmd As New MySqlCommand(getClassSql, conn)
                    getClassCmd.Parameters.AddWithValue("@YearLevel", ddlEditModalYearLevel.SelectedValue)
                    getClassCmd.Parameters.AddWithValue("@Section", ddlEditModalSection.SelectedValue)
                    getClassCmd.Parameters.AddWithValue("@CourseID", ddlEditModalCourse.SelectedValue)
                    Dim result = getClassCmd.ExecuteScalar()
                    If result IsNot Nothing Then
                        classID = Convert.ToInt32(result)
                    Else
                        lblEditModalMessage.Text = "⚠ No class found for the selected year level, section, and course."
                        lblEditModalMessage.CssClass = "alert alert-warning d-block"
                        Return
                    End If
                End Using
                ' ✅ ENHANCED DUPLICATE VALIDATION FOR EDIT
                Dim existingAssignment As Object = Nothing
                Dim existingFacultyID As String = ""
                Dim existingFacultyName As String = ""
                Dim existingSubjectCode As String = ""
                Dim existingSubjectName As String = ""
                ' Check if the same subject, class, and term combination already exists for ANY faculty (excluding current record)
                Dim checkSql As String = "
            SELECT fl.LoadID, fl.FacultyID,
                   CONCAT(u.LastName, ', ', u.FirstName, 
                       CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial != '' THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
                       CASE WHEN u.Suffix IS NOT NULL AND u.Suffix != '' THEN CONCAT(' ', u.Suffix) ELSE '' END
                   ) AS FacultyName,
                   s.SubjectCode,
                   s.SubjectName
            FROM facultyload fl
            INNER JOIN users u ON fl.FacultyID = u.UserID
            INNER JOIN subjects s ON fl.SubjectID = s.SubjectID
            WHERE fl.SubjectID = @SubjectID 
              AND fl.ClassID = @ClassID 
              AND fl.Term = @Term
              AND fl.LoadID != @LoadID
              AND fl.IsDeleted = 0
            LIMIT 1"
                Using checkCmd As New MySqlCommand(checkSql, conn)
                    checkCmd.Parameters.AddWithValue("@SubjectID", ddlEditModalSubject.SelectedValue)
                    checkCmd.Parameters.AddWithValue("@ClassID", classID)
                    checkCmd.Parameters.AddWithValue("@Term", ddlEditModalTerm.SelectedValue)
                    checkCmd.Parameters.AddWithValue("@LoadID", hfEditLoadID.Value)

                    Using reader As MySqlDataReader = checkCmd.ExecuteReader()
                        If reader.Read() Then
                            existingAssignment = reader("LoadID")
                            existingFacultyID = reader("FacultyID").ToString()
                            existingFacultyName = reader("FacultyName").ToString()
                            existingSubjectCode = reader("SubjectCode").ToString()
                            existingSubjectName = reader("SubjectName").ToString()
                        End If
                    End Using
                End Using
                ' Get current subject details for better error messages
                Dim currentSubjectCode As String = ""
                Dim currentSubjectName As String = ""
                Dim getSubjectSql As String = "SELECT SubjectCode, SubjectName FROM subjects WHERE SubjectID=@SubjectID"
                Using getSubjectCmd As New MySqlCommand(getSubjectSql, conn)
                    getSubjectCmd.Parameters.AddWithValue("@SubjectID", ddlEditModalSubject.SelectedValue)
                    Using reader As MySqlDataReader = getSubjectCmd.ExecuteReader()
                        If reader.Read() Then
                            currentSubjectCode = reader("SubjectCode").ToString()
                            currentSubjectName = reader("SubjectName").ToString()
                        End If
                    End Using
                End Using
                ' Check if duplicate exists
                If existingAssignment IsNot Nothing Then
                    lblEditModalMessage.Text = $"⚠ The subject '{currentSubjectCode} - {currentSubjectName}' is already assigned to {existingFacultyName} for this class and term. Each subject-class-term combination can only be assigned to one faculty member."
                    lblEditModalMessage.CssClass = "alert alert-warning d-block"
                    ' Keep the modal open
                    ScriptManager.RegisterStartupScript(Me, Me.GetType(), "KeepEditModalOpen", "setKeepEditModalOpen(true);", True)
                    Return
                End If
                ' Get DepartmentID from Course
                Dim departmentID As Integer = 0
                Dim getDeptSql As String = "SELECT DepartmentID FROM courses WHERE CourseID=@CourseID"
                Using getDeptCmd As New MySqlCommand(getDeptSql, conn)
                    getDeptCmd.Parameters.AddWithValue("@CourseID", ddlEditModalCourse.SelectedValue)
                    Dim deptResult = getDeptCmd.ExecuteScalar()
                    If deptResult IsNot Nothing Then
                        departmentID = Convert.ToInt32(deptResult)
                    End If
                End Using
                ' Update the faculty load
                Dim updateSql As String = "
            UPDATE facultyload 
            SET DepartmentID=@DepartmentID,
                CourseID=@CourseID, 
                SubjectID=@SubjectID, 
                ClassID=@ClassID, 
                Term=@Term
            WHERE LoadID=@LoadID"
                Using updateCmd As New MySqlCommand(updateSql, conn)
                    updateCmd.Parameters.AddWithValue("@DepartmentID", departmentID)
                    updateCmd.Parameters.AddWithValue("@CourseID", ddlEditModalCourse.SelectedValue)
                    updateCmd.Parameters.AddWithValue("@SubjectID", ddlEditModalSubject.SelectedValue)
                    updateCmd.Parameters.AddWithValue("@ClassID", classID)
                    updateCmd.Parameters.AddWithValue("@Term", ddlEditModalTerm.SelectedValue)
                    updateCmd.Parameters.AddWithValue("@LoadID", hfEditLoadID.Value)
                    updateCmd.ExecuteNonQuery()
                End Using
            End Using
            ' Close modal and refresh data
            ScriptManager.RegisterStartupScript(Me, Me.GetType(), "CloseEditModal", "closeEditModal();", True)
            ' Reload the data
            LoadFacultyDetails(hfSelectedFacultyID.Value)
            LoadFacultySummary()
            ' Show success message
            lblMessage.Text = "✅ Faculty load updated successfully!"
            lblMessage.CssClass = "alert alert-success d-block"
        Catch ex As Exception
            lblEditModalMessage.Text = "❌ Error updating faculty load: " & ex.Message
            lblEditModalMessage.CssClass = "alert alert-danger d-block"
        End Try
    End Sub
End Class

