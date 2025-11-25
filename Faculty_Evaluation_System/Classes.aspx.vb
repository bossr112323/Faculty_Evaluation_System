Imports MySql.Data.MySqlClient
Imports System.Configuration

Public Class Classes
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Session("Role") Is Nothing OrElse Session("Role").ToString() <> "Admin" Then
                Response.Redirect("Login.aspx")
            End If
            lblWelcome.Text = Session("FullName")
            LoadCourses()
            UpdateSidebarBadges()
            LoadClasses()
        End If
    End Sub

    ' ========== SIDEBAR BADGE METHODS ==========
    Private Sub UpdateSidebarBadges()
        Try
            Dim pendingEnrollmentCount = GetPendingEnrollmentCount()
            Dim pendingReleaseCount = GetPendingReleaseCountByFaculty()

            If pendingEnrollmentCount > 0 Then
                sidebarEnrollmentBadge.Text = pendingEnrollmentCount.ToString()
                sidebarEnrollmentBadge.Visible = True
            Else
                sidebarEnrollmentBadge.Visible = False
            End If

            If pendingReleaseCount > 0 Then
                sidebarReleaseBadge.Text = pendingReleaseCount.ToString()
                sidebarReleaseBadge.Visible = True
            Else
                sidebarReleaseBadge.Visible = False
            End If

        Catch ex As Exception
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
                    Using cmd As New MySqlCommand("SELECT COUNT(DISTINCT StudentID) FROM irregular_student_enrollments WHERE CycleID = @CycleID AND IsApproved = 0", conn)
                        cmd.Parameters.AddWithValue("@CycleID", activeCycleID)
                        counts("PendingEnrollments") = Convert.ToInt32(cmd.ExecuteScalar())
                    End Using

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

    ' ========== COURSE AND CLASS MANAGEMENT ==========

    ' NEW: Get course duration by course ID
    Private Function GetCourseDuration(courseID As Integer) As Integer
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim query = "SELECT YearLevels FROM Courses WHERE CourseID = @CourseID"
            Using cmd As New MySqlCommand(query, conn)
                cmd.Parameters.AddWithValue("@CourseID", courseID)
                Dim result = cmd.ExecuteScalar()
                Return If(result IsNot Nothing AndAlso Not IsDBNull(result), Convert.ToInt32(result), 4) ' Default to 4 years
            End Using
        End Using
    End Function

    ' UPDATED: Load courses with duration information
    Private Sub LoadCourses()
        Using conn As New MySqlConnection(ConnString)
            Dim cmd As New MySqlCommand("SELECT CourseID, CourseName, YearLevels FROM Courses WHERE IsActive=1", conn)
            Dim da As New MySqlDataAdapter(cmd)
            Dim dt As New DataTable()
            da.Fill(dt)

            ddlBulkCourse.DataSource = dt
            ddlBulkCourse.DataTextField = "CourseName"
            ddlBulkCourse.DataValueField = "CourseID"
            ddlBulkCourse.DataBind()
            ddlBulkCourse.Items.Insert(0, New ListItem("Select Course", ""))
        End Using
    End Sub

    ' NEW: Populate year levels based on course duration
    Private Sub PopulateYearLevels(courseID As Integer, ddlYearLevel As DropDownList)
        If ddlYearLevel Is Nothing Then Return

        ddlYearLevel.Items.Clear()
        ddlYearLevel.Items.Add(New ListItem("Select Year Level", ""))

        If courseID > 0 Then
            Dim duration As Integer = GetCourseDuration(courseID)

            For i As Integer = 1 To duration
                Dim yearText As String = GetYearLevelText(i)
                ddlYearLevel.Items.Add(New ListItem(yearText, yearText))
            Next
        Else
            ' Default year levels if no course selected
            ddlYearLevel.Items.Add(New ListItem("1ST", "1ST"))
            ddlYearLevel.Items.Add(New ListItem("2ND", "2ND"))
            ddlYearLevel.Items.Add(New ListItem("3RD", "3RD"))
            ddlYearLevel.Items.Add(New ListItem("4TH", "4TH"))
        End If
    End Sub

    ' NEW: Convert year number to text (1 -> "1ST", 2 -> "2ND", etc.)
    Private Function GetYearLevelText(yearNumber As Integer) As String
        Select Case yearNumber
            Case 1
                Return "1ST"
            Case 2
                Return "2ND"
            Case 3
                Return "3RD"
            Case Else
                Return yearNumber.ToString() & "TH"
        End Select
    End Function

    ' NEW: Handle course selection change to update year levels
    Protected Sub ddlCourses_SelectedIndexChanged(sender As Object, e As EventArgs)
        If ddlBulkCourse.SelectedValue <> "" Then
            Dim courseID As Integer = Convert.ToInt32(ddlBulkCourse.SelectedValue)
            PopulateYearLevels(courseID, ddlBulkYearLevel)
        Else
            PopulateYearLevels(0, ddlBulkYearLevel)
        End If
    End Sub

    ' UPDATED: Load classes with course duration validation
    Private Sub LoadClasses(Optional searchTerm As String = "")
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "
        SELECT DISTINCT 
            c.CourseID, 
            crs.CourseName, 
            c.YearLevel,
            crs.YearLevels as CourseDuration
        FROM Classes c
        INNER JOIN Courses crs ON c.CourseID = crs.CourseID
        WHERE c.IsActive = 1"

            If Not String.IsNullOrEmpty(searchTerm) Then
                sql &= " AND (crs.CourseName LIKE @Search OR c.YearLevel LIKE @Search)"
            End If

            sql &= " ORDER BY crs.CourseName, c.YearLevel"

            Using cmd As New MySqlCommand(sql, conn)
                If Not String.IsNullOrEmpty(searchTerm) Then
                    cmd.Parameters.AddWithValue("@Search", "%" & searchTerm & "%")
                End If
                Dim da As New MySqlDataAdapter(cmd)
                Dim dt As New DataTable()
                da.Fill(dt)

                ' Add a dummy ClassID for each row (since we're grouping by Course and YearLevel)
                dt.Columns.Add("ClassID", GetType(Integer))
                For i As Integer = 0 To dt.Rows.Count - 1
                    dt.Rows(i)("ClassID") = i + 1
                Next

                gvClasses.DataSource = dt
                gvClasses.DataBind()
            End Using
        End Using
    End Sub


    ' UPDATED: Check if class already exists with course duration validation
    Private Function ClassExists(courseID As Integer, yearLevel As String, section As String, Optional excludeClassID As Integer = 0) As Boolean
        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' First validate if year level is within course duration
            Dim courseDuration As Integer = GetCourseDuration(courseID)
            Dim yearNumber As Integer = GetYearNumber(yearLevel)

            If yearNumber > courseDuration Then
                Throw New Exception($"Year level '{yearLevel}' exceeds the course duration of {courseDuration} year(s)")
            End If

            Dim sql As String = "SELECT COUNT(*) FROM Classes WHERE CourseID = @CourseID AND YearLevel = @YearLevel AND Section = @Section"

            If excludeClassID > 0 Then
                sql &= " AND ClassID != @ClassID"
            End If

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@CourseID", courseID)
                cmd.Parameters.AddWithValue("@YearLevel", yearLevel)
                cmd.Parameters.AddWithValue("@Section", section)

                If excludeClassID > 0 Then
                    cmd.Parameters.AddWithValue("@ClassID", excludeClassID)
                End If

                Dim count As Integer = Convert.ToInt32(cmd.ExecuteScalar())
                Return count > 0
            End Using
        End Using
    End Function

    ' NEW: Convert year level text to number ("1ST" -> 1, "2ND" -> 2, etc.)
    Private Function GetYearNumber(yearLevel As String) As Integer
        If String.IsNullOrEmpty(yearLevel) Then Return 0

        Dim yearText As String = yearLevel.ToUpper()
        If yearText.EndsWith("ST") Then
            Return Convert.ToInt32(yearText.Replace("ST", ""))
        ElseIf yearText.EndsWith("ND") Then
            Return Convert.ToInt32(yearText.Replace("ND", ""))
        ElseIf yearText.EndsWith("RD") Then
            Return Convert.ToInt32(yearText.Replace("RD", ""))
        ElseIf yearText.EndsWith("TH") Then
            Return Convert.ToInt32(yearText.Replace("TH", ""))
        Else
            Return Convert.ToInt32(yearText)
        End If
    End Function

    ' UPDATED: Add class with course duration validation
    Protected Sub btnAddClass_Click(sender As Object, e As EventArgs)
        If ddlBulkCourse.SelectedValue = "" Or ddlBulkYearLevel.SelectedValue = "" OrElse txtSectionRange.Text.Trim() = "" Then
            lblMessage.Text = "⚠ Please select a course, year level, and enter a section."
            lblMessage.CssClass = "alert alert-danger d-block"
            Return
        End If

        Dim courseID As Integer = Convert.ToInt32(ddlBulkCourse.SelectedValue)
        Dim yearLevel As String = ddlBulkYearLevel.SelectedValue
        Dim section As String = txtSectionRange.Text.Trim()

        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                ' Validate year level against course duration
                Dim courseDuration As Integer = GetCourseDuration(courseID)
                Dim yearNumber As Integer = GetYearNumber(yearLevel)

                If yearNumber > courseDuration Then
                    lblMessage.Text = $"⚠ Year level '{yearLevel}' exceeds the course duration of {courseDuration} year(s). Maximum allowed: {GetYearLevelText(courseDuration)}"
                    lblMessage.CssClass = "alert alert-warning d-block"
                    Return
                End If

                ' Check if class already exists
                Dim checkSql As String = "SELECT ClassID, IsActive 
                                      FROM Classes 
                                      WHERE CourseID=@CourseID AND YearLevel=@YearLevel AND Section=@Section
                                      LIMIT 1"

                Using checkCmd As New MySqlCommand(checkSql, conn)
                    checkCmd.Parameters.AddWithValue("@CourseID", courseID)
                    checkCmd.Parameters.AddWithValue("@YearLevel", yearLevel)
                    checkCmd.Parameters.AddWithValue("@Section", section)

                    Using rdr As MySqlDataReader = checkCmd.ExecuteReader()
                        If rdr.Read() Then
                            Dim existingID As Integer = rdr("ClassID")
                            Dim isActive As Boolean = Convert.ToBoolean(rdr("IsActive"))
                            rdr.Close()

                            If Not isActive Then
                                ' Reactivate instead of new insert
                                Dim reactivateSql As String = "UPDATE Classes SET IsActive=1 WHERE ClassID=@ID"
                                Using reactivateCmd As New MySqlCommand(reactivateSql, conn)
                                    reactivateCmd.Parameters.AddWithValue("@ID", existingID)
                                    reactivateCmd.ExecuteNonQuery()
                                End Using

                                lblMessage.Text = "✅ Class reactivated successfully!"
                                lblMessage.CssClass = "alert alert-success d-block"
                                txtSectionRange.Text = ""
                                LoadClasses()
                                Return
                            Else
                                lblMessage.Text = "❌ Class already exists with the same course, year level, and section!"
                                lblMessage.CssClass = "alert alert-danger d-block"
                                Return
                            End If
                        End If
                    End Using
                End Using

                ' Insert new class
                Dim insertSql As String = "INSERT INTO Classes (CourseID, YearLevel, Section, IsActive) 
                                       VALUES (@CourseID, @YearLevel, @Section, 1)"
                Using insertCmd As New MySqlCommand(insertSql, conn)
                    insertCmd.Parameters.AddWithValue("@CourseID", courseID)
                    insertCmd.Parameters.AddWithValue("@YearLevel", yearLevel)
                    insertCmd.Parameters.AddWithValue("@Section", section)
                    insertCmd.ExecuteNonQuery()
                End Using
            End Using

            lblMessage.Text = "✅ Class added successfully!"
            lblMessage.CssClass = "alert alert-success d-block"
            txtSectionRange.Text = ""
            LoadClasses()

        Catch ex As Exception
            lblMessage.Text = "❌ Error: " & ex.Message
            lblMessage.CssClass = "alert alert-danger d-block"
        End Try
    End Sub

    Protected Sub btnSearch_Click(sender As Object, e As EventArgs)
        LoadClasses(txtSearch.Text.Trim())
    End Sub

    ' GridView Events
    Protected Sub gvClasses_RowEditing(sender As Object, e As GridViewEditEventArgs)
        gvClasses.EditIndex = e.NewEditIndex
        LoadClasses(txtSearch.Text.Trim())
    End Sub

    Protected Sub gvClasses_RowCancelingEdit(sender As Object, e As GridViewCancelEditEventArgs)
        gvClasses.EditIndex = -1
        LoadClasses(txtSearch.Text.Trim())
    End Sub

    ' UPDATED: Row updating with course duration validation
    Protected Sub gvClasses_RowUpdating(sender As Object, e As GridViewUpdateEventArgs)
        Dim courseID As Integer = Convert.ToInt32(gvClasses.DataKeys(e.RowIndex).Values("CourseID"))
        Dim oldYearLevel As String = gvClasses.DataKeys(e.RowIndex).Values("YearLevel").ToString()
        Dim row As GridViewRow = gvClasses.Rows(e.RowIndex)

        Dim ddlYear As DropDownList = CType(row.FindControl("ddlEditYearLevel"), DropDownList)
        Dim txtSection As TextBox = CType(row.FindControl("txtEditSection"), TextBox)
        Dim newYearLevel As String = ddlYear.SelectedValue
        Dim newSectionInput As String = txtSection.Text.Trim()

        Try
            ' Validate year level against course duration
            Dim courseDuration As Integer = GetCourseDuration(courseID)
            Dim yearNumber As Integer = GetYearNumber(newYearLevel)

            If yearNumber > courseDuration Then
                lblMessage.Text = $"⚠ Year level '{newYearLevel}' exceeds the course duration of {courseDuration} year(s). Maximum allowed: {GetYearLevelText(courseDuration)}"
                lblMessage.CssClass = "alert alert-warning d-block"
                gvClasses.EditIndex = -1
                LoadClasses(txtSearch.Text.Trim())
                Return
            End If

            ' Parse the new section input (could be range like A-D or list like A,B,C)
            Dim newSections As List(Of String) = ParseSectionInput(newSectionInput)

            If newSections.Count = 0 Then
                lblMessage.Text = "⚠ Please enter valid sections (e.g., A-D or A,B,C)"
                lblMessage.CssClass = "alert alert-warning d-block"
                Return
            End If

            ' Get current sections for the course/year level
            Dim currentSections As List(Of String) = GetSectionsForCourseYear(courseID, oldYearLevel)

            ' If year level changed, we need to handle section migration
            If oldYearLevel <> newYearLevel Then
                UpdateYearLevelForAllSections(courseID, oldYearLevel, newYearLevel)
            End If

            ' Update sections to match the new input
            UpdateSectionsToMatchInput(courseID, newYearLevel, currentSections, newSections)

            lblMessage.Text = "✅ Sections updated successfully!"
            lblMessage.CssClass = "alert alert-success d-block"

        Catch ex As Exception
            lblMessage.Text = "❌ Error: " & ex.Message
            lblMessage.CssClass = "alert alert-danger d-block"
        End Try

        gvClasses.EditIndex = -1
        LoadClasses(txtSearch.Text.Trim())
    End Sub
    ' NEW: Parse section input (handles both ranges and comma-separated lists)
    Private Function ParseSectionInput(input As String) As List(Of String)
        If String.IsNullOrEmpty(input) Then
            Return New List(Of String)()
        End If

        input = input.Trim()

        ' Try to parse as range first (A-D, A to Z, etc.)
        Dim rangeSections As List(Of String) = ParseSectionRange(input)
        If rangeSections.Count > 0 Then
            Return rangeSections
        End If

        ' Try to parse as comma-separated list
        If input.Contains(",") Then
            Return input.Split(","c).Select(Function(s) s.Trim()).Where(Function(s) Not String.IsNullOrEmpty(s)).ToList()
        End If

        ' Single section
        Return New List(Of String) From {input}
    End Function

    ' NEW: Update sections to match the new input (add new sections, deactivate removed ones)
    Private Sub UpdateSectionsToMatchInput(courseID As Integer, yearLevel As String, currentSections As List(Of String), newSections As List(Of String))
        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Sections to add (in new list but not in current)
            Dim sectionsToAdd = newSections.Except(currentSections, StringComparer.OrdinalIgnoreCase).ToList()

            ' Sections to remove (in current but not in new list)
            Dim sectionsToRemove = currentSections.Except(newSections, StringComparer.OrdinalIgnoreCase).ToList()

            ' Add new sections
            For Each section In sectionsToAdd
                If Not ClassExists(courseID, yearLevel, section) Then
                    Dim insertSql As String = "INSERT INTO Classes (CourseID, YearLevel, Section, IsActive) VALUES (@CourseID, @YearLevel, @Section, 1)"
                    Using cmd As New MySqlCommand(insertSql, conn)
                        cmd.Parameters.AddWithValue("@CourseID", courseID)
                        cmd.Parameters.AddWithValue("@YearLevel", yearLevel)
                        cmd.Parameters.AddWithValue("@Section", section)
                        cmd.ExecuteNonQuery()
                    End Using
                Else
                    ' Reactivate if exists but inactive
                    Dim reactivateSql As String = "UPDATE Classes SET IsActive = 1 WHERE CourseID = @CourseID AND YearLevel = @YearLevel AND Section = @Section"
                    Using cmd As New MySqlCommand(reactivateSql, conn)
                        cmd.Parameters.AddWithValue("@CourseID", courseID)
                        cmd.Parameters.AddWithValue("@YearLevel", yearLevel)
                        cmd.Parameters.AddWithValue("@Section", section)
                        cmd.ExecuteNonQuery()
                    End Using
                End If
            Next

            ' Remove sections that are no longer in the range
            For Each section In sectionsToRemove
                Dim deactivateSql As String = "UPDATE Classes SET IsActive = 0 WHERE CourseID = @CourseID AND YearLevel = @YearLevel AND Section = @Section"
                Using cmd As New MySqlCommand(deactivateSql, conn)
                    cmd.Parameters.AddWithValue("@CourseID", courseID)
                    cmd.Parameters.AddWithValue("@YearLevel", yearLevel)
                    cmd.Parameters.AddWithValue("@Section", section)
                    cmd.ExecuteNonQuery()
                End Using
            Next
        End Using
    End Sub
    Private Sub UpdateYearLevelForAllSections(courseID As Integer, oldYearLevel As String, newYearLevel As String)
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim sql As String = "UPDATE Classes SET YearLevel = @NewYearLevel WHERE CourseID = @CourseID AND YearLevel = @OldYearLevel AND IsActive = 1"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@NewYearLevel", newYearLevel)
                cmd.Parameters.AddWithValue("@CourseID", courseID)
                cmd.Parameters.AddWithValue("@OldYearLevel", oldYearLevel)
                cmd.ExecuteNonQuery()
            End Using
        End Using
    End Sub

    ' NEW: Update section name
    Private Sub UpdateSectionName(courseID As Integer, yearLevel As String, oldSection As String, newSection As String)
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim sql As String = "UPDATE Classes SET Section = @NewSection WHERE CourseID = @CourseID AND YearLevel = @YearLevel AND Section = @OldSection AND IsActive = 1"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@NewSection", newSection)
                cmd.Parameters.AddWithValue("@CourseID", courseID)
                cmd.Parameters.AddWithValue("@YearLevel", yearLevel)
                cmd.Parameters.AddWithValue("@OldSection", oldSection)
                cmd.ExecuteNonQuery()
            End Using
        End Using
    End Sub

    ' NEW: Create new class
    Private Sub CreateNewClass(courseID As Integer, yearLevel As String, section As String)
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim sql As String = "INSERT INTO Classes (CourseID, YearLevel, Section, IsActive) VALUES (@CourseID, @YearLevel, @Section, 1)"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@CourseID", courseID)
                cmd.Parameters.AddWithValue("@YearLevel", yearLevel)
                cmd.Parameters.AddWithValue("@Section", section)
                cmd.ExecuteNonQuery()
            End Using
        End Using
    End Sub


    ' UPDATED: RowDataBound to populate year levels based on course duration
    Protected Sub gvClasses_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvClasses.RowDataBound
        If e.Row.RowType = DataControlRowType.DataRow Then
            If e.Row.RowState.HasFlag(DataControlRowState.Edit) Then
                Dim ddlYear As DropDownList = CType(e.Row.FindControl("ddlEditYearLevel"), DropDownList)
                If ddlYear IsNot Nothing Then
                    ' Get course ID and populate year levels based on course duration
                    Dim courseID As Integer = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "CourseID"))
                    PopulateYearLevels(courseID, ddlYear)

                    ' Set selected value to current year level
                    Dim currentYearLevel As String = DataBinder.Eval(e.Row.DataItem, "YearLevel").ToString()
                    ddlYear.SelectedValue = currentYearLevel
                End If
            End If
        End If
    End Sub

    ' Existing helper methods remain the same
    Private Function GetCourseIDByName(courseName As String) As Integer
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim sql As String = "SELECT CourseID FROM Courses WHERE CourseName = @CourseName"
            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@CourseName", courseName)
                Dim result = cmd.ExecuteScalar()
                If result IsNot Nothing AndAlso Not DBNull.Value.Equals(result) Then
                    Return Convert.ToInt32(result)
                End If
            End Using
        End Using
        Return 0
    End Function
    ' ========== BULK SECTION CREATION METHODS ==========

    ' NEW: Handle bulk course selection change
    Protected Sub ddlBulkCourse_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ddlBulkCourse.SelectedIndexChanged
        If ddlBulkCourse.SelectedValue <> "" Then
            Dim courseID As Integer = Convert.ToInt32(ddlBulkCourse.SelectedValue)
            PopulateYearLevels(courseID, ddlBulkYearLevel)
        Else
            PopulateYearLevels(0, ddlBulkYearLevel)
        End If
    End Sub

    ' NEW: Load bulk courses dropdown
    Private Sub LoadBulkCourses()
        Using conn As New MySqlConnection(ConnString)
            Dim cmd As New MySqlCommand("SELECT CourseID, CourseName, YearLevels FROM Courses WHERE IsActive=1", conn)
            Dim da As New MySqlDataAdapter(cmd)
            Dim dt As New DataTable()
            da.Fill(dt)

            ddlBulkCourse.DataSource = dt
            ddlBulkCourse.DataTextField = "CourseName"
            ddlBulkCourse.DataValueField = "CourseID"
            ddlBulkCourse.DataBind()
            ddlBulkCourse.Items.Insert(0, New ListItem("Select Course", ""))
        End Using
    End Sub

    ' NEW: Parse section range from text input
    Private Function ParseSectionRange(input As String) As List(Of String)
        If String.IsNullOrEmpty(input) Then
            Return New List(Of String)()
        End If

        input = input.Trim()

        ' Common patterns for parsing
        ' Letter range: A-O, A to Z, etc.
        If System.Text.RegularExpressions.Regex.IsMatch(input, "^([A-Z])\s*[-–—]?\s*([A-Z])$", System.Text.RegularExpressions.RegexOptions.IgnoreCase) Then
            Dim match = System.Text.RegularExpressions.Regex.Match(input, "^([A-Z])\s*[-–—]?\s*([A-Z])$", System.Text.RegularExpressions.RegexOptions.IgnoreCase)
            Dim startChar As Char = Char.ToUpper(Convert.ToChar(match.Groups(1).Value))
            Dim endChar As Char = Char.ToUpper(Convert.ToChar(match.Groups(2).Value))
            Return GenerateLetterSections(startChar, endChar, "")
        End If

        ' Letter range with "to": A to Z
        If System.Text.RegularExpressions.Regex.IsMatch(input, "^([A-Z])\s+to\s+([A-Z])$", System.Text.RegularExpressions.RegexOptions.IgnoreCase) Then
            Dim match = System.Text.RegularExpressions.Regex.Match(input, "^([A-Z])\s+to\s+([A-Z])$", System.Text.RegularExpressions.RegexOptions.IgnoreCase)
            Dim startChar As Char = Char.ToUpper(Convert.ToChar(match.Groups(1).Value))
            Dim endChar As Char = Char.ToUpper(Convert.ToChar(match.Groups(2).Value))
            Return GenerateLetterSections(startChar, endChar, "")
        End If

        ' Prefixed letter range: Set-A to Set-C
        If System.Text.RegularExpressions.Regex.IsMatch(input, "^([a-zA-Z]+-)([A-Z])\s+to\s+\1([A-Z])$", System.Text.RegularExpressions.RegexOptions.IgnoreCase) Then
            Dim match = System.Text.RegularExpressions.Regex.Match(input, "^([a-zA-Z]+-)([A-Z])\s+to\s+\1([A-Z])$", System.Text.RegularExpressions.RegexOptions.IgnoreCase)
            Dim prefix As String = match.Groups(1).Value
            Dim startChar As Char = Char.ToUpper(Convert.ToChar(match.Groups(2).Value))
            Dim endChar As Char = Char.ToUpper(Convert.ToChar(match.Groups(3).Value))
            Return GenerateLetterSections(startChar, endChar, prefix)
        End If

        ' Number range: 1-5
        If System.Text.RegularExpressions.Regex.IsMatch(input, "^(\d+)\s*[-–—]?\s*(\d+)$") Then
            Dim match = System.Text.RegularExpressions.Regex.Match(input, "^(\d+)\s*[-–—]?\s*(\d+)$")
            Dim startNum As Integer = Convert.ToInt32(match.Groups(1).Value)
            Dim endNum As Integer = Convert.ToInt32(match.Groups(2).Value)
            Return GenerateNumberSections(startNum, endNum, "")
        End If

        ' Number range with "to": 1 to 10
        If System.Text.RegularExpressions.Regex.IsMatch(input, "^(\d+)\s+to\s+(\d+)$") Then
            Dim match = System.Text.RegularExpressions.Regex.Match(input, "^(\d+)\s+to\s+(\d+)$")
            Dim startNum As Integer = Convert.ToInt32(match.Groups(1).Value)
            Dim endNum As Integer = Convert.ToInt32(match.Groups(2).Value)
            Return GenerateNumberSections(startNum, endNum, "")
        End If

        ' Prefixed number range: Sec-1 to Sec-10
        If System.Text.RegularExpressions.Regex.IsMatch(input, "^([a-zA-Z]+-)(\d+)\s+to\s+\1(\d+)$", System.Text.RegularExpressions.RegexOptions.IgnoreCase) Then
            Dim match = System.Text.RegularExpressions.Regex.Match(input, "^([a-zA-Z]+-)(\d+)\s+to\s+\1(\d+)$", System.Text.RegularExpressions.RegexOptions.IgnoreCase)
            Dim prefix As String = match.Groups(1).Value
            Dim startNum As Integer = Convert.ToInt32(match.Groups(2).Value)
            Dim endNum As Integer = Convert.ToInt32(match.Groups(3).Value)
            Return GenerateNumberSections(startNum, endNum, prefix)
        End If

        Return New List(Of String)()
    End Function

    ' NEW: Generate letter sections
    Private Function GenerateLetterSections(startChar As Char, endChar As Char, prefix As String) As List(Of String)
        Dim sections As New List(Of String)()
        Dim startCode As Integer = Asc(startChar)
        Dim endCode As Integer = Asc(endChar)

        If startCode > endCode Then
            Return sections ' Invalid range
        End If

        For i As Integer = startCode To endCode
            sections.Add(prefix + Chr(i))
        Next

        Return sections
    End Function

    ' NEW: Generate number sections
    Private Function GenerateNumberSections(startNum As Integer, endNum As Integer, prefix As String) As List(Of String)
        Dim sections As New List(Of String)()

        If startNum > endNum Then
            Return sections ' Invalid range
        End If

        For i As Integer = startNum To endNum
            sections.Add(prefix + i.ToString())
        Next

        Return sections
    End Function

    ' NEW: Bulk create sections
    Protected Sub btnBulkCreate_Click(sender As Object, e As EventArgs)
        If ddlBulkCourse.SelectedValue = "" Or ddlBulkYearLevel.SelectedValue = "" Then
            lblMessage.Text = "⚠ Please select a course and year level for bulk creation."
            lblMessage.CssClass = "alert alert-danger d-block"
            Return
        End If

        Dim sectionRangeInput As String = txtSectionRange.Text.Trim()

        If String.IsNullOrEmpty(sectionRangeInput) Then
            lblMessage.Text = "⚠ Please enter a section range."
            lblMessage.CssClass = "alert alert-warning d-block"
            Return
        End If

        Dim courseID As Integer = Convert.ToInt32(ddlBulkCourse.SelectedValue)
        Dim yearLevel As String = ddlBulkYearLevel.SelectedValue
        Dim sections As List(Of String) = ParseSectionRange(sectionRangeInput)

        If sections.Count = 0 Then
            lblMessage.Text = "⚠ Invalid section range format. Use: A-O, 1-10, Set-A to Set-C, etc."
            lblMessage.CssClass = "alert alert-warning d-block"
            Return
        End If

        Dim createdCount As Integer = 0
        Dim skippedCount As Integer = 0
        Dim errorCount As Integer = 0
        Dim errorMessages As New List(Of String)()

        Try
            ' Validate year level against course duration first
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                Dim courseDuration As Integer = GetCourseDuration(courseID)
                Dim yearNumber As Integer = GetYearNumber(yearLevel)

                If yearNumber > courseDuration Then
                    lblMessage.Text = $"⚠ Year level '{yearLevel}' exceeds the course duration of {courseDuration} year(s). Maximum allowed: {GetYearLevelText(courseDuration)}"
                    lblMessage.CssClass = "alert alert-warning d-block"
                    Return
                End If
            End Using

            ' Process each section with separate connections to avoid DataReader conflicts
            For Each section As String In sections
                Try
                    Using conn As New MySqlConnection(ConnString)
                        conn.Open()

                        ' Check if class already exists using ExecuteScalar instead of DataReader
                        Dim checkSql As String = "SELECT COUNT(*) FROM Classes WHERE CourseID=@CourseID AND YearLevel=@YearLevel AND Section=@Section AND IsActive=1"

                        Using checkCmd As New MySqlCommand(checkSql, conn)
                            checkCmd.Parameters.AddWithValue("@CourseID", courseID)
                            checkCmd.Parameters.AddWithValue("@YearLevel", yearLevel)
                            checkCmd.Parameters.AddWithValue("@Section", section)

                            Dim existingActiveCount As Integer = Convert.ToInt32(checkCmd.ExecuteScalar())

                            If existingActiveCount > 0 Then
                                ' Class already exists and is active
                                skippedCount += 1
                            Else
                                ' Check if there's an inactive class to reactivate
                                Dim checkInactiveSql As String = "SELECT ClassID FROM Classes WHERE CourseID=@CourseID AND YearLevel=@YearLevel AND Section=@Section AND IsActive=0 LIMIT 1"

                                Using checkInactiveCmd As New MySqlCommand(checkInactiveSql, conn)
                                    checkInactiveCmd.Parameters.AddWithValue("@CourseID", courseID)
                                    checkInactiveCmd.Parameters.AddWithValue("@YearLevel", yearLevel)
                                    checkInactiveCmd.Parameters.AddWithValue("@Section", section)

                                    Dim inactiveClassID As Object = checkInactiveCmd.ExecuteScalar()

                                    If inactiveClassID IsNot Nothing AndAlso Not IsDBNull(inactiveClassID) Then
                                        ' Reactivate existing inactive class
                                        Dim reactivateSql As String = "UPDATE Classes SET IsActive=1 WHERE ClassID=@ID"
                                        Using reactivateCmd As New MySqlCommand(reactivateSql, conn)
                                            reactivateCmd.Parameters.AddWithValue("@ID", Convert.ToInt32(inactiveClassID))
                                            reactivateCmd.ExecuteNonQuery()
                                        End Using
                                        createdCount += 1
                                    Else
                                        ' Create new class
                                        Dim insertSql As String = "INSERT INTO Classes (CourseID, YearLevel, Section, IsActive) VALUES (@CourseID, @YearLevel, @Section, 1)"
                                        Using insertCmd As New MySqlCommand(insertSql, conn)
                                            insertCmd.Parameters.AddWithValue("@CourseID", courseID)
                                            insertCmd.Parameters.AddWithValue("@YearLevel", yearLevel)
                                            insertCmd.Parameters.AddWithValue("@Section", section)
                                            insertCmd.ExecuteNonQuery()
                                        End Using
                                        createdCount += 1
                                    End If
                                End Using
                            End If
                        End Using
                    End Using
                Catch ex As Exception
                    errorCount += 1
                    ' Store first few error messages
                    If errorMessages.Count < 3 Then
                        errorMessages.Add($"'{section}' - {ex.Message}")
                    End If
                    ' Log individual section errors but continue with others
                    System.Diagnostics.Debug.WriteLine($"Error creating section {section}: {ex.Message}")
                End Try
            Next

            ' Show results
            Dim resultMessage As String = $"✅ Bulk creation completed! "

            If createdCount > 0 Then
                resultMessage += $"{createdCount} section(s) created. "
            End If

            If skippedCount > 0 Then
                resultMessage += $"{skippedCount} section(s) already existed. "
            End If

            If errorCount > 0 Then
                resultMessage += $"{errorCount} section(s) had errors."
                If errorMessages.Count > 0 Then
                    resultMessage += $" First few errors: {String.Join("; ", errorMessages)}"
                    If errorCount > 3 Then
                        resultMessage += $"... and {errorCount - 3} more"
                    End If
                End If
                lblMessage.CssClass = "alert alert-warning d-block"
            Else
                lblMessage.CssClass = "alert alert-success d-block"
            End If

            lblMessage.Text = resultMessage

            ' Clear the input field
            txtSectionRange.Text = ""

            ' Refresh the classes list
            LoadClasses()

        Catch ex As Exception
            lblMessage.Text = $"❌ Error during bulk creation: {ex.Message}"
            lblMessage.CssClass = "alert alert-danger d-block"
        End Try
    End Sub
    Protected Sub gvClasses_RowDeleting(sender As Object, e As GridViewDeleteEventArgs)
        Try
            Dim courseID As Integer = Convert.ToInt32(gvClasses.DataKeys(e.RowIndex).Values("CourseID"))
            Dim yearLevel As String = gvClasses.DataKeys(e.RowIndex).Values("YearLevel").ToString()

            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                Dim sql As String = "UPDATE Classes SET IsActive = 0 WHERE CourseID = @CourseID AND YearLevel = @YearLevel"
                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@CourseID", courseID)
                    cmd.Parameters.AddWithValue("@YearLevel", yearLevel)
                    cmd.ExecuteNonQuery()
                End Using
            End Using

            lblMessage.Text = "✅ All sections for this year level archived successfully!"
            lblMessage.CssClass = "alert alert-success d-block"
            LoadClasses(txtSearch.Text.Trim())

        Catch ex As Exception
            lblMessage.Text = "❌ Error archiving classes: " & ex.Message
            lblMessage.CssClass = "alert alert-danger d-block"
        End Try
    End Sub
    ' NEW: Get section display as range for consecutive sections
    Public Function GetSectionDisplay(courseID As Object, yearLevel As Object) As String
        If courseID Is Nothing Or yearLevel Is Nothing Then
            Return ""
        End If

        Dim courseIdInt As Integer = Convert.ToInt32(courseID)
        Dim yearLevelStr As String = yearLevel.ToString()

        ' Get all sections for this course and year level
        Dim sections As List(Of String) = GetSectionsForCourseYear(courseIdInt, yearLevelStr)

        If sections.Count = 0 Then
            Return ""
        End If

        ' If only one section, return it as is
        If sections.Count = 1 Then
            Return sections(0)
        End If

        ' Group consecutive single-letter sections
        Dim singleLetterSections = sections.Where(Function(s) s.Length = 1 AndAlso Char.IsLetter(s(0))).ToList()
        Dim otherSections = sections.Where(Function(s) s.Length > 1 OrElse Not Char.IsLetter(s(0))).ToList()

        Dim ranges As New List(Of String)()

        ' Process single letter sections for ranges
        If singleLetterSections.Count > 0 Then
            Dim letterRanges = GetLetterRanges(singleLetterSections)
            ranges.AddRange(letterRanges)
        End If

        ' Add other sections individually
        ranges.AddRange(otherSections)

        ' If all sections are in one range, return just the range
        If ranges.Count = 1 AndAlso ranges(0).Contains("-") Then
            Return ranges(0)
        End If

        ' Otherwise return comma-separated
        Return String.Join(", ", ranges)
    End Function
    Public Function GetCurrentSectionRangeForEdit(dataItem As Object) As String
        If dataItem Is Nothing Then Return ""

        Dim rowView As DataRowView = TryCast(dataItem, DataRowView)
        If rowView Is Nothing Then Return ""

        Dim courseID As Integer = Convert.ToInt32(rowView("CourseID"))
        Dim yearLevel As String = rowView("YearLevel").ToString()

        ' Get the current section range display for editing
        Return GetSectionRangeForEdit(courseID, yearLevel)
    End Function

    ' NEW: Get section range string for edit mode
    Private Function GetSectionRangeForEdit(courseID As Integer, yearLevel As String) As String
        Dim sections As List(Of String) = GetSectionsForCourseYear(courseID, yearLevel)

        If sections.Count = 0 Then Return ""

        ' If only one section, return it as is
        If sections.Count = 1 Then
            Return sections(0)
        End If

        ' Group consecutive single-letter sections
        Dim singleLetterSections = sections.Where(Function(s) s.Length = 1 AndAlso Char.IsLetter(s(0))).ToList()
        Dim otherSections = sections.Where(Function(s) s.Length > 1 OrElse Not Char.IsLetter(s(0))).ToList()

        Dim ranges As New List(Of String)()

        ' Process single letter sections for ranges
        If singleLetterSections.Count > 0 Then
            Dim letterRanges = GetLetterRanges(singleLetterSections)
            ranges.AddRange(letterRanges)
        End If

        ' Add other sections individually
        ranges.AddRange(otherSections)

        ' Return the range string
        If ranges.Count = 1 AndAlso ranges(0).Contains("-") Then
            Return ranges(0)
        Else
            Return String.Join(",", ranges)
        End If
    End Function

    ' NEW: Get sections for a specific course and year level
    Private Function GetSectionsForCourseYear(courseID As Integer, yearLevel As String) As List(Of String)
        Dim sections As New List(Of String)()

        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim sql As String = "SELECT Section FROM Classes WHERE CourseID = @CourseID AND YearLevel = @YearLevel AND IsActive = 1 ORDER BY Section"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@CourseID", courseID)
                cmd.Parameters.AddWithValue("@YearLevel", yearLevel)

                Using rdr As MySqlDataReader = cmd.ExecuteReader()
                    While rdr.Read()
                        sections.Add(rdr("Section").ToString())
                    End While
                End Using
            End Using
        End Using

        Return sections
    End Function

    ' NEW: Convert list of single letters to ranges (A, B, C, E, F -> A-C, E-F)
    Private Function GetLetterRanges(letters As List(Of String)) As List(Of String)
        If letters.Count = 0 Then Return New List(Of String)()

        ' Convert to characters and sort
        Dim chars As List(Of Char) = letters.ConvertAll(Function(s) s(0)).OrderBy(Function(c) c).ToList()
        Dim ranges As New List(Of String)()

        Dim startChar As Char = chars(0)
        Dim endChar As Char = chars(0)

        For i As Integer = 1 To chars.Count - 1
            If Asc(chars(i)) - Asc(endChar) = 1 Then
                ' Consecutive letter
                endChar = chars(i)
            Else
                ' Break in sequence
                If startChar = endChar Then
                    ranges.Add(startChar.ToString())
                Else
                    ranges.Add($"{startChar}-{endChar}")
                End If
                startChar = chars(i)
                endChar = chars(i)
            End If
        Next

        ' Add the last range
        If startChar = endChar Then
            ranges.Add(startChar.ToString())
        Else
            ranges.Add($"{startChar}-{endChar}")
        End If

        Return ranges
    End Function
    Public Function GetCurrentSectionForEdit(dataItem As Object) As String
        If dataItem Is Nothing Then Return ""

        Dim rowView As DataRowView = TryCast(dataItem, DataRowView)
        If rowView Is Nothing Then Return ""

        Dim courseID As Integer = Convert.ToInt32(rowView("CourseID"))
        Dim yearLevel As String = rowView("YearLevel").ToString()

        ' Get the first section for this course and year level
        Return GetFirstSection(courseID, yearLevel)
    End Function

    ' NEW: Get first section for a course and year level
    Private Function GetFirstSection(courseID As Integer, yearLevel As String) As String
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim sql As String = "SELECT Section FROM Classes WHERE CourseID = @CourseID AND YearLevel = @YearLevel AND IsActive = 1 ORDER BY Section LIMIT 1"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@CourseID", courseID)
                cmd.Parameters.AddWithValue("@YearLevel", yearLevel)

                Dim result = cmd.ExecuteScalar()
                Return If(result IsNot Nothing AndAlso Not IsDBNull(result), result.ToString(), "")
            End Using
        End Using
    End Function
End Class

