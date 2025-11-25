Imports System.Configuration
Imports System.Data
Imports System.IO
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports MySql.Data.MySqlClient
Imports System.Web.Services
Imports System.Web.Script.Services
Imports System.Web.Script.Serialization
Imports ClosedXML.Excel

Public Class Prints
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
                Return
            End If

            lblWelcome.Text = If(Session("FullName") IsNot Nothing, Session("FullName").ToString(), "Administrator")
            litPreparedBy.Text = If(Session("FullName") IsNot Nothing, Session("FullName").ToString(), "System Administrator")

            LoadDepartments()
            ' Load latest results by default
            LoadEvaluationList("", "")
            UpdatePrintHeaderLiterals()
            UpdateSidebarBadges()

            lblPrintDate.Text = DateTime.Now.ToString("MMMM dd, yyyy")
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
    Private Sub LoadDepartments()
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "SELECT DepartmentID, DepartmentName FROM Departments WHERE IsActive = 1 ORDER BY DepartmentName"

            Using cmd As New MySqlCommand(sql, conn)
                Dim dt As New DataTable()
                Dim da As New MySqlDataAdapter(cmd)
                da.Fill(dt)

                ddlFilterDepartment.DataSource = dt
                ddlFilterDepartment.DataTextField = "DepartmentName"
                ddlFilterDepartment.DataValueField = "DepartmentID"
                ddlFilterDepartment.DataBind()
                ddlFilterDepartment.Items.Insert(0, New ListItem("All Departments", ""))
            End Using
        End Using
    End Sub

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetCycleNames() As List(Of String)
        Dim cycleNames As New List(Of String)()

        Try
            Using conn As New MySqlConnection(ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString)
                ' Get ALL cycle names, not just active ones
                Dim sql As String = "SELECT DISTINCT CycleName FROM EvaluationCycles ORDER BY CycleName"

                Using cmd As New MySqlCommand(sql, conn)
                    conn.Open()
                    Using reader As MySqlDataReader = cmd.ExecuteReader()
                        While reader.Read()
                            cycleNames.Add(reader("CycleName").ToString())
                        End While
                    End Using
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetCycleNames: " & ex.Message)
        End Try

        Return cycleNames
    End Function

    Private Sub LoadEvaluationList(Optional cycleFilter As String = "", Optional departmentFilter As String = "")
        Using conn As New MySqlConnection(ConnString)
            ' Base SQL with proper student counting and response rate calculation
            Dim sql As String = "
WITH faculty_submission_scores AS (
    SELECT 
        fl.FacultyID,
        es.CycleID,
        es.SubmissionID,
        ROUND(SUM((domain_avg.DomainAvg / 5) * domain_avg.Weight), 1) AS SubmissionWeightedScore,
        ROUND(AVG(domain_avg.DomainAvg), 2) AS SubmissionRawScore
    FROM FacultyLoad fl
    INNER JOIN EvaluationSubmissions es ON fl.LoadID = es.LoadID
    INNER JOIN EvaluationCycles ec ON es.CycleID = ec.CycleID
    LEFT JOIN (
        SELECT 
            es.SubmissionID,
            d.DomainID,
            d.Weight,
            AVG(e.Score) AS DomainAvg
        FROM Evaluations e
        INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
        INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
        INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
        WHERE e.Score IS NOT NULL AND e.Score > 0
        GROUP BY es.SubmissionID, d.DomainID, d.Weight
    ) domain_avg ON es.SubmissionID = domain_avg.SubmissionID
    WHERE fl.IsDeleted = 0
    GROUP BY fl.FacultyID, es.CycleID, es.SubmissionID
),
faculty_aggregated_scores AS (
    SELECT 
        FacultyID,
        CycleID,
        ROUND(AVG(SubmissionWeightedScore), 1) AS WeightedScore,
        ROUND(AVG(SubmissionRawScore), 2) AS RawScore,
        COUNT(SubmissionID) AS EvaluationsCount
    FROM faculty_submission_scores
    GROUP BY FacultyID, CycleID
    HAVING EvaluationsCount > 0
),
faculty_student_counts AS (
    SELECT 
        fl.FacultyID,
        ec.CycleID,
        COUNT(DISTINCT s.StudentID) AS TotalStudents
    FROM FacultyLoad fl
    INNER JOIN Classes c ON fl.ClassID = c.ClassID
    INNER JOIN Students s ON c.ClassID = s.ClassID
    INNER JOIN EvaluationCycles ec ON fl.Term = ec.Term
    WHERE fl.IsDeleted = 0
    AND s.Status = 'Active'
    GROUP BY fl.FacultyID, ec.CycleID
)
SELECT 
    fas.FacultyID,
    CONCAT(u.LastName, ', ', u.FirstName, 
        CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial <> '' 
             THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
        CASE WHEN u.Suffix IS NOT NULL AND u.Suffix <> '' 
             THEN CONCAT(' ', u.Suffix) ELSE '' END
    ) AS FacultyName,
    d.DepartmentName,
    d.DepartmentID,
    fas.WeightedScore,
    fas.RawScore,
    (SELECT COUNT(DISTINCT fl2.SubjectID) 
     FROM FacultyLoad fl2 
     INNER JOIN EvaluationCycles ec2 ON fl2.Term = ec2.Term
     WHERE fl2.FacultyID = fas.FacultyID AND fl2.IsDeleted = 0) AS SubjectsCount,
    fas.EvaluationsCount,
    COALESCE(fsc.TotalStudents, 0) AS TotalStudents,
    CASE 
        WHEN COALESCE(fsc.TotalStudents, 0) = 0 THEN 0
        ELSE LEAST(ROUND((fas.EvaluationsCount / fsc.TotalStudents) * 100, 1), 100)
    END AS ResponseRate,
    ec.CycleName,
    ec.Term,
    ec.CycleID,
    ec.Status
FROM faculty_aggregated_scores fas
INNER JOIN Users u ON fas.FacultyID = u.UserID
LEFT JOIN Departments d ON u.DepartmentID = d.DepartmentID
INNER JOIN EvaluationCycles ec ON fas.CycleID = ec.CycleID
LEFT JOIN faculty_student_counts fsc ON fas.FacultyID = fsc.FacultyID AND fas.CycleID = fsc.CycleID
WHERE u.Role = 'Faculty' AND u.Status = 'Active'"

            ' Add filters
            Dim whereConditions As New List(Of String)()

            ' Always show latest cycle by default unless specifically filtered
            If String.IsNullOrEmpty(cycleFilter) Then
                Dim currentCycle As DataRow = GetCurrentCycle()
                If currentCycle IsNot Nothing Then
                    whereConditions.Add($"ec.CycleID = {SafeInteger(currentCycle("CycleID"))}")
                End If
            Else
                whereConditions.Add($"(ec.CycleName LIKE '%{MySqlHelper.EscapeString(cycleFilter)}%' OR ec.Term LIKE '%{MySqlHelper.EscapeString(cycleFilter)}%')")
            End If

            ' Add department filter if specified
            If Not String.IsNullOrEmpty(departmentFilter) Then
                whereConditions.Add($"(u.DepartmentID = {SafeInteger(departmentFilter)} OR d.DepartmentID = {SafeInteger(departmentFilter)})")
            End If

            ' Combine all conditions
            If whereConditions.Count > 0 Then
                sql &= " AND " & String.Join(" AND ", whereConditions)
            End If

            sql &= " ORDER BY ec.CycleName DESC, ec.Term DESC, d.DepartmentName, fas.WeightedScore DESC"

            Using cmd As New MySqlCommand(sql, conn)
                Dim dt As New DataTable()
                Dim da As New MySqlDataAdapter(cmd)
                da.Fill(dt)

                rptEvaluationList.DataSource = dt
                rptEvaluationList.DataBind()
                pnlNoEvaluations.Visible = dt.Rows.Count = 0
                ViewState("ExportData") = dt

                UpdateStatistics(dt)
            End Using
        End Using
    End Sub
    Protected Sub btnApplyFilters_Click(sender As Object, e As EventArgs)
        ApplyFilters()
    End Sub


    Private Sub ApplyFilters()
        Dim facultyFilter As String = txtSearchFaculty.Text.Trim()
        Dim departmentFilter As String = ddlFilterDepartment.SelectedValue
        Dim cycleFilter As String = txtFilterCycle.Text.Trim()

        ' Pass both cycle and department filters
        LoadEvaluationList(cycleFilter, departmentFilter)
    End Sub

    Public Function IsLatestCycle(cycleID As Object) As Boolean
        Dim currentCycle As DataRow = GetCurrentCycle()
        If currentCycle IsNot Nothing Then
            Return SafeInteger(cycleID) = SafeInteger(currentCycle("CycleID"))
        End If
        Return False
    End Function
    Private Function GetCurrentCycle() As DataRow
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "SELECT CycleID, CycleName, Term FROM EvaluationCycles WHERE IsActive = 1 AND Status = 'Active' ORDER BY StartDate DESC LIMIT 1"

            Using cmd As New MySqlCommand(sql, conn)
                Dim dt As New DataTable()
                Dim da As New MySqlDataAdapter(cmd)
                da.Fill(dt)

                If dt.Rows.Count > 0 Then
                    Return dt.Rows(0)
                End If
            End Using
        End Using

        Return Nothing
    End Function
    Private Sub UpdateStatistics(dt As DataTable)
        If dt.Rows.Count > 0 Then
            Dim totalEvaluations As Integer = dt.Rows.Count
            Dim totalWeightedRating As Decimal = 0
            Dim totalResponseRate As Decimal = 0
            Dim validRowsCount As Integer = 0

            For Each row As DataRow In dt.Rows
                Dim weightedScore As Decimal = SafeDecimal(row("WeightedScore"))
                Dim responseRate As Decimal = SafeDecimal(row("ResponseRate"))

                If weightedScore > 0 Then
                    totalWeightedRating += weightedScore
                    totalResponseRate += responseRate
                    validRowsCount += 1
                End If
            Next

        End If
    End Sub

    Protected Sub rptEvaluationList_ItemCommand(source As Object, e As RepeaterCommandEventArgs)
        If e.CommandName = "SelectEvaluation" Then
            Dim args As String() = e.CommandArgument.ToString().Split("|"c)
            If args.Length >= 4 Then
                Dim facultyID As Integer = SafeInteger(args(0))
                Dim cycleID As Integer = SafeInteger(args(1))
                Dim cycleName As String = args(2)
                Dim term As String = args(3)

                pnlSubjectSelection.Visible = True
                pnlEvaluationList.Visible = False
                pnlDetailedReport.Visible = False

                ViewState("CurrentFacultyID") = facultyID
                ViewState("CurrentCycleID") = cycleID
                ViewState("CurrentCycleName") = cycleName
                ViewState("CurrentTerm") = term

                LoadFacultyInfo(facultyID)
                LoadFacultySubjects(facultyID, cycleID, term)
            End If
        End If
    End Sub

    Private Sub LoadFacultyInfo(facultyID As Integer)
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "
            SELECT CONCAT(u.LastName, ', ', u.FirstName, 
                CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial <> '' 
                     THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
                CASE WHEN u.Suffix IS NOT NULL AND u.Suffix <> '' 
                     THEN CONCAT(' ', u.Suffix) ELSE '' END
            ) AS FullName, d.DepartmentName
            FROM Users u
            LEFT JOIN Departments d ON u.DepartmentID = d.DepartmentID
            WHERE u.UserID = @FacultyID"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                conn.Open()
                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    If reader.Read() Then
                        litSelectedFaculty.Text = SafeString(reader("FullName"))
                        litSelectedDepartment.Text = SafeString(reader("DepartmentName"))
                        litSelectedTerm.Text = SafeString(ViewState("CurrentTerm"))
                        litCurrentCycle.Text = $"{SafeString(ViewState("CurrentCycleName"))} ({SafeString(ViewState("CurrentTerm"))})"
                    End If
                End Using
            End Using
        End Using
    End Sub

    Private Sub LoadFacultySubjects(facultyID As Integer, cycleID As Integer, term As String)
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "
WITH subject_submission_scores AS (
    SELECT 
        fl.SubjectID,
        es.SubmissionID,
        ROUND(SUM((domain_avg.DomainAvg / 5) * domain_avg.Weight), 1) AS SubmissionWeightedScore
    FROM FacultyLoad fl
    INNER JOIN EvaluationSubmissions es ON fl.LoadID = es.LoadID
    LEFT JOIN (
        SELECT 
            es.SubmissionID,
            d.DomainID,
            d.Weight,
            AVG(e.Score) AS DomainAvg
        FROM Evaluations e
        INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
        INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
        INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
        WHERE e.Score IS NOT NULL AND e.Score > 0
        GROUP BY es.SubmissionID, d.DomainID, d.Weight
    ) domain_avg ON es.SubmissionID = domain_avg.SubmissionID
    WHERE fl.FacultyID = @FacultyID 
    AND es.CycleID = @CycleID
    AND fl.IsDeleted = 0
    GROUP BY fl.SubjectID, es.SubmissionID
),
subject_student_counts AS (
    SELECT 
        fl.SubjectID,
        COUNT(DISTINCT s.StudentID) AS TotalStudents
    FROM FacultyLoad fl
    INNER JOIN Classes c ON fl.ClassID = c.ClassID
    INNER JOIN Students s ON c.ClassID = s.ClassID
    WHERE fl.FacultyID = @FacultyID 
    AND fl.Term = @Term
    AND fl.IsDeleted = 0
    AND s.Status = 'Active'
    GROUP BY fl.SubjectID
),
subject_evaluation_counts AS (
    SELECT 
        fl.SubjectID,
        COUNT(DISTINCT es.SubmissionID) AS EvaluationCount
    FROM FacultyLoad fl
    INNER JOIN EvaluationSubmissions es ON fl.LoadID = es.LoadID
    WHERE fl.FacultyID = @FacultyID 
    AND es.CycleID = @CycleID
    AND fl.IsDeleted = 0
    GROUP BY fl.SubjectID
)
SELECT 
    s.SubjectID, 
    s.SubjectName, 
    s.SubjectCode,
    COALESCE(sec.EvaluationCount, 0) as EvaluationCount,
    COALESCE(ROUND(AVG(sss.SubmissionWeightedScore), 1), 0) as WeightedScore,
    COALESCE(ssc.TotalStudents, 0) as TotalStudents,
    CASE 
        WHEN COALESCE(ssc.TotalStudents, 0) = 0 THEN 0
        ELSE LEAST(ROUND((COALESCE(sec.EvaluationCount, 0) / ssc.TotalStudents) * 100, 1), 100)
    END as ResponseRate
FROM FacultyLoad fl
INNER JOIN Subjects s ON fl.SubjectID = s.SubjectID
LEFT JOIN subject_submission_scores sss ON fl.SubjectID = sss.SubjectID
LEFT JOIN subject_student_counts ssc ON fl.SubjectID = ssc.SubjectID
LEFT JOIN subject_evaluation_counts sec ON fl.SubjectID = sec.SubjectID
WHERE fl.FacultyID = @FacultyID 
AND fl.Term = @Term
AND fl.IsDeleted = 0
AND COALESCE(sec.EvaluationCount, 0) > 0
GROUP BY s.SubjectID, s.SubjectName, s.SubjectCode, ssc.TotalStudents, sec.EvaluationCount
ORDER BY s.SubjectName"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@CycleID", cycleID)
                cmd.Parameters.AddWithValue("@Term", term)

                Dim dt As New DataTable()
                Dim da As New MySqlDataAdapter(cmd)
                da.Fill(dt)

                rptSubjectCards.DataSource = dt
                rptSubjectCards.DataBind()
                pnlNoSubjects.Visible = dt.Rows.Count = 0
            End Using
        End Using
    End Sub

    Protected Sub btnGenerateReportHidden_Click(sender As Object, e As EventArgs)
        GenerateSubjectReport()
    End Sub

    Private Sub GenerateSubjectReport()
        Dim subjectID As String = hfSelectedSubjectID.Value
        Dim subjectName As String = hfSelectedSubjectName.Value

        If Not String.IsNullOrEmpty(subjectID) Then
            Dim facultyID As Integer = SafeInteger(ViewState("CurrentFacultyID"))
            Dim cycleName As String = SafeString(ViewState("CurrentCycleName"))
            Dim term As String = SafeString(ViewState("CurrentTerm"))

            ViewState("CurrentSubjectID") = subjectID
            ViewState("CurrentSubjectName") = subjectName

            pnlSubjectSelection.Visible = False
            pnlDetailedReport.Visible = True

            If subjectID = "all" Then
                LoadAllSubjectsReport(facultyID, cycleName, term)
            Else
                LoadDetailedReport(facultyID, cycleName, term, SafeInteger(subjectID))
            End If
        End If
    End Sub

    Private Sub LoadAllSubjectsReport(facultyID As Integer, cycleName As String, term As String)
        Using conn As New MySqlConnection(ConnString)
            Dim facultySql As String = "
            SELECT DISTINCT CONCAT(u.LastName, ', ', u.FirstName, 
                CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial <> '' 
                     THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
                CASE WHEN u.Suffix IS NOT NULL AND u.Suffix <> '' 
                     THEN CONCAT(' ', u.Suffix) ELSE '' END
            ) AS FullName, d.DepartmentName
            FROM Users u
            INNER JOIN FacultyLoad fl ON u.UserID = fl.FacultyID
            INNER JOIN Departments d ON fl.DepartmentID = d.DepartmentID
            WHERE u.UserID = @FacultyID"

            Using cmd As New MySqlCommand(facultySql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                conn.Open()
                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    If reader.Read() Then
                        litFacultyName.Text = SafeString(reader("FullName"))
                        litDept.Text = SafeString(reader("DepartmentName"))
                        litSubjectName.Text = "All Subjects (Weighted Average)"
                    End If
                End Using
            End Using

            litTerm.Text = $"{cycleName} ({term})"
            LoadAllSubjectsDomainSummary(facultyID, cycleName, term)
            LoadAllSubjectsQuestionBreakdown(facultyID, cycleName, term)
            LoadAllSubjectsExecutiveSummary(facultyID, cycleName, term)
            LoadAllSubjectsStudentComments(facultyID, cycleName, term)
        End Using
    End Sub

    Private Sub LoadAllSubjectsDomainSummary(facultyID As Integer, cycleName As String, term As String)
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "
            WITH current_cycle AS (
                SELECT CycleID FROM EvaluationCycles WHERE IsActive = 1 ORDER BY StartDate DESC LIMIT 1
            )
            SELECT 
                d.DomainName,
                d.Weight,
                ROUND(AVG(domain_scores.DomainAvg), 2) AS RawScore,
                ROUND((AVG(domain_scores.DomainAvg) / 5) * d.Weight, 1) AS WeightedScore
            FROM (
                SELECT 
                    es.SubmissionID,
                    d.DomainID,
                    AVG(e.Score) AS DomainAvg
                FROM Evaluations e
                INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
                INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
                INNER JOIN current_cycle cc ON es.CycleID = cc.CycleID
                INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
                INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
                WHERE fl.FacultyID = @FacultyID 
                AND fl.Term = @Term
                AND e.Score IS NOT NULL 
                AND e.Score > 0
                GROUP BY es.SubmissionID, d.DomainID
            ) domain_scores
            INNER JOIN EvaluationDomains d ON domain_scores.DomainID = d.DomainID
            GROUP BY d.DomainID, d.DomainName, d.Weight
            ORDER BY d.DomainName"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@Term", term)

                Dim dt As New DataTable()
                Dim da As New MySqlDataAdapter(cmd)
                da.Fill(dt)

                gvDomainSummary.DataSource = dt
                gvDomainSummary.DataBind()
                ViewState("DomainSummary") = dt

                If dt.Rows.Count > 0 Then
                    Dim validRows = dt.AsEnumerable().Where(Function(r) SafeDecimal(r("RawScore")) > 0).ToList()

                    If validRows.Count > 0 Then
                        Dim maxRow = validRows.OrderByDescending(Function(r) SafeDecimal(r("RawScore"))).First()
                        Dim minRow = validRows.OrderBy(Function(r) SafeDecimal(r("RawScore"))).First()



                        Dim overallWeighted As Decimal = validRows.Sum(Function(r) SafeDecimal(r("WeightedScore")))
                        litWeightedAverage.Text = overallWeighted.ToString("N1") & "%"
                    Else

                        litWeightedAverage.Text = "0.0%"
                    End If
                Else

                    litWeightedAverage.Text = "0.0%"
                End If
            End Using
        End Using
    End Sub
    Public Function CalculateResponseRate(evaluationsCount As Integer, totalStudents As Integer) As Decimal
        If totalStudents <= 0 Then
            Return 0
        End If

        Dim rate As Decimal = (evaluationsCount / totalStudents) * 100D
        Return Math.Min(Math.Round(rate, 1), 100D)
    End Function
    Private Sub LoadAllSubjectsQuestionBreakdown(facultyID As Integer, cycleName As String, term As String)
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "
            WITH current_cycle AS (
                SELECT CycleID FROM EvaluationCycles WHERE IsActive = 1 ORDER BY StartDate DESC LIMIT 1
            )
            SELECT 
                d.DomainName AS DomainName,
                q.QuestionText AS QuestionText,
                ROUND(AVG(e.Score), 2) AS AverageScore
            FROM Evaluations e
            INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
            INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
            INNER JOIN current_cycle cc ON es.CycleID = cc.CycleID
            INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
            INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
            WHERE fl.FacultyID = @FacultyID 
            AND fl.Term = @Term
            AND e.Score IS NOT NULL 
            AND e.Score > 0
            GROUP BY d.DomainName, q.QuestionText, d.DomainID, q.QuestionID
            ORDER BY d.DomainID, q.QuestionID"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@Term", term)

                Dim dt As New DataTable()
                Dim da As New MySqlDataAdapter(cmd)
                da.Fill(dt)

                If dt.Rows.Count > 0 Then
                    Dim domainGroups = From row In dt.AsEnumerable()
                                       Group row By DomainName = row.Field(Of String)("DomainName") Into DomainGroup = Group
                                       Select New With {
                                          .DomainName = DomainName,
                                          .Questions = DomainGroup.ToList()
                                      }

                    rptDomains.DataSource = domainGroups
                    rptDomains.DataBind()
                    pnlNoQuestions.Visible = False
                Else
                    rptDomains.DataSource = Nothing
                    rptDomains.DataBind()
                    pnlNoQuestions.Visible = True
                End If
            End Using
        End Using
    End Sub

    Private Sub LoadAllSubjectsStudentComments(facultyID As Integer, cycleName As String, term As String)
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "
            WITH current_cycle AS (
                SELECT CycleID FROM EvaluationCycles WHERE IsActive = 1 ORDER BY StartDate DESC LIMIT 1
            )
            SELECT 
                es.Strengths,
                es.Weaknesses,
                es.AdditionalMessage
            FROM EvaluationSubmissions es
            INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
            INNER JOIN current_cycle cc ON es.CycleID = cc.CycleID
            WHERE fl.FacultyID = @FacultyID 
            AND fl.Term = @Term
            AND (es.Strengths IS NOT NULL AND es.Strengths <> '' 
                 OR es.Weaknesses IS NOT NULL AND es.Weaknesses <> '' 
                 OR es.AdditionalMessage IS NOT NULL AND es.AdditionalMessage <> '')"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@Term", term)

                Dim dt As New DataTable()
                Dim da As New MySqlDataAdapter(cmd)
                da.Fill(dt)

                Dim strengths = New List(Of String)()
                Dim weaknesses = New List(Of String)()
                Dim additionalMessages = New List(Of String)()

                For Each row As DataRow In dt.Rows
                    If Not String.IsNullOrWhiteSpace(row("Strengths").ToString()) Then
                        strengths.Add(row("Strengths").ToString().Trim())
                    End If
                    If Not String.IsNullOrWhiteSpace(row("Weaknesses").ToString()) Then
                        weaknesses.Add(row("Weaknesses").ToString().Trim())
                    End If
                    If Not String.IsNullOrWhiteSpace(row("AdditionalMessage").ToString()) Then
                        additionalMessages.Add(row("AdditionalMessage").ToString().Trim())
                    End If
                Next

                ViewState("Strengths") = strengths
                ViewState("Weaknesses") = weaknesses
                ViewState("AdditionalMessages") = additionalMessages

                pnlNoComments.Visible = (strengths.Count = 0 AndAlso weaknesses.Count = 0 AndAlso additionalMessages.Count = 0)
            End Using
        End Using
    End Sub

    Private Sub LoadAllSubjectsExecutiveSummary(facultyID As Integer, cycleName As String, term As String)
        Try
            LoadFacultyExecutiveInfo(facultyID)
            CalculateAllSubjectsKPIs(facultyID, term)
            LoadAllSubjectsDomainSummary(facultyID, cycleName, term)
            LoadAllSubjectsQuestionBreakdown(facultyID, cycleName, term)
            LoadAllSubjectsStudentComments(facultyID, cycleName, term)
            BindGroupedComments()

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"Error in LoadAllSubjectsExecutiveSummary: {ex.Message}")
            ShowErrorMessage("Unable to load executive summary data.")
        End Try
    End Sub

    Private Sub LoadFacultyExecutiveInfo(facultyID As Integer, Optional subjectID As Integer = 0)
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "
        SELECT 
            CONCAT(u.LastName, ', ', u.FirstName, 
                CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial <> '' 
                     THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
                CASE WHEN u.Suffix IS NOT NULL AND u.Suffix <> '' 
                     THEN CONCAT(' ', u.Suffix) ELSE '' END
            ) AS FullName,
            d.DepartmentName
        FROM Users u
        INNER JOIN FacultyLoad fl ON u.UserID = fl.FacultyID
        INNER JOIN Departments d ON fl.DepartmentID = d.DepartmentID
        WHERE u.UserID = @FacultyID
        LIMIT 1"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)

                conn.Open()
                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    If reader.Read() Then
                        litFacultyName.Text = SafeString(reader("FullName"))
                        litDept.Text = SafeString(reader("DepartmentName"))
                    End If
                End Using
            End Using
        End Using

        litTerm.Text = $"{SafeString(ViewState("CurrentCycleName"))} ({SafeString(ViewState("CurrentTerm"))})"
    End Sub
    Private Sub CalculateAllSubjectsKPIs(facultyID As Integer, term As String)
        Using conn As New MySqlConnection(ConnString)
            conn.Open()



            ' Get actual response counts for display
            Dim totalStudents As Integer = 0
            Dim submittedStudents As Integer = 0

            Dim sqlTotal As String = "
        WITH current_cycle AS (
            SELECT CycleID FROM EvaluationCycles WHERE IsActive = 1 AND Status = 'Active' ORDER BY StartDate DESC LIMIT 1
        )
        SELECT COUNT(DISTINCT s.StudentID) as TotalStudents
        FROM Students s
        INNER JOIN Classes c ON s.ClassID = c.ClassID
        INNER JOIN FacultyLoad fl ON c.ClassID = fl.ClassID
        INNER JOIN current_cycle cc ON fl.Term = @Term
        WHERE fl.FacultyID = @FacultyID"

            Dim sqlSubmitted As String = "
        WITH current_cycle AS (
            SELECT CycleID FROM EvaluationCycles WHERE IsActive = 1 AND Status = 'Active' ORDER BY StartDate DESC LIMIT 1
        )
        SELECT COUNT(DISTINCT es.StudentID) as SubmittedStudents
        FROM EvaluationSubmissions es
        INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
        INNER JOIN current_cycle cc ON es.CycleID = cc.CycleID
        WHERE fl.FacultyID = @FacultyID
        AND fl.Term = @Term"

            Using cmd As New MySqlCommand(sqlTotal, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@Term", term)
                Dim result = cmd.ExecuteScalar()
                If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                    totalStudents = Convert.ToInt32(result)
                End If
            End Using

            Using cmd As New MySqlCommand(sqlSubmitted, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@Term", term)
                Dim result = cmd.ExecuteScalar()
                If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                    submittedStudents = Convert.ToInt32(result)
                End If
            End Using



            CalculateDomainExtremes(facultyID, term)
        End Using
    End Sub

    Private Function CalculateOverallWeightedRating(facultyID As Integer, term As String) As Decimal
        Dim sql As String = "
        WITH current_cycle AS (
            SELECT CycleID FROM EvaluationCycles WHERE IsActive = 1 ORDER BY StartDate DESC LIMIT 1
        ),
        domain_avg AS (
            SELECT 
                es.SubmissionID,
                d.DomainID,
                d.Weight,
                AVG(e.Score) AS DomainAvg
            FROM Evaluations e
            INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
            INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
            INNER JOIN current_cycle cc ON es.CycleID = cc.CycleID
            INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
            INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
            WHERE fl.FacultyID = @FacultyID 
            AND fl.Term = @Term
            AND e.Score IS NOT NULL 
            AND e.Score > 0
            GROUP BY es.SubmissionID, d.DomainID, d.Weight
        ),
        submission_scores AS (
            SELECT 
                SubmissionID,
                ROUND(SUM((DomainAvg / 5) * Weight), 1) AS SubmissionWeightedScore
            FROM domain_avg
            GROUP BY SubmissionID
        )
        SELECT COALESCE(ROUND(AVG(SubmissionWeightedScore), 1), 0) AS OverallWeightedRating
        FROM submission_scores"

        Using conn As New MySqlConnection(ConnString)
            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@Term", term)
                conn.Open()
                Dim result = cmd.ExecuteScalar()
                Return If(result IsNot Nothing AndAlso Not IsDBNull(result), Convert.ToDecimal(result), 0)
            End Using
        End Using
    End Function

    Private Function CalculateResponseRate(facultyID As Integer, term As String) As Decimal
        Dim totalStudents As Integer = 0
        Dim submittedStudents As Integer = 0

        Dim sqlTotal As String = "
    WITH current_cycle AS (
        SELECT CycleID FROM EvaluationCycles WHERE IsActive = 1 AND Status = 'Active' ORDER BY StartDate DESC LIMIT 1
    )
    SELECT COUNT(DISTINCT s.StudentID) as TotalStudents
    FROM Students s
    INNER JOIN Classes c ON s.ClassID = c.ClassID
    INNER JOIN FacultyLoad fl ON c.ClassID = fl.ClassID
    INNER JOIN current_cycle cc ON fl.Term = @Term
    WHERE fl.FacultyID = @FacultyID"

        Dim sqlSubmitted As String = "
    WITH current_cycle AS (
        SELECT CycleID FROM EvaluationCycles WHERE IsActive = 1 AND Status = 'Active' ORDER BY StartDate DESC LIMIT 1
    )
    SELECT COUNT(DISTINCT es.StudentID) as SubmittedStudents
    FROM EvaluationSubmissions es
    INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
    INNER JOIN current_cycle cc ON es.CycleID = cc.CycleID
    WHERE fl.FacultyID = @FacultyID
    AND fl.Term = @Term"

        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            Using cmd As New MySqlCommand(sqlTotal, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@Term", term)
                Dim result = cmd.ExecuteScalar()
                If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                    totalStudents = Convert.ToInt32(result)
                End If
            End Using

            Using cmd As New MySqlCommand(sqlSubmitted, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@Term", term)
                Dim result = cmd.ExecuteScalar()
                If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                    submittedStudents = Convert.ToInt32(result)
                End If
            End Using
        End Using

        If totalStudents > 0 Then
            Return Math.Round((submittedStudents / totalStudents) * 100, 1)
        End If

        Return 0
    End Function

    Private Sub CalculateDomainExtremes(facultyID As Integer, term As String)
        Dim dt As DataTable = TryCast(ViewState("DomainSummary"), DataTable)

        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            Dim validRows = dt.AsEnumerable().Where(Function(r) SafeDecimal(r("RawScore")) > 0).ToList()

            If validRows.Count > 0 Then
                Dim maxRow = validRows.OrderByDescending(Function(r) SafeDecimal(r("RawScore"))).First()
                Dim minRow = validRows.OrderBy(Function(r) SafeDecimal(r("RawScore"))).First()


            Else

            End If
        Else

        End If
    End Sub

    Private Sub LoadDetailedReport(facultyID As Integer, cycleName As String, term As String, subjectID As Integer)
        Using conn As New MySqlConnection(ConnString)
            ' First get faculty and subject info
            Dim facultySql As String = "
        SELECT DISTINCT 
            CONCAT(u.LastName, ', ', u.FirstName, 
                CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial <> '' 
                     THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
                CASE WHEN u.Suffix IS NOT NULL AND u.Suffix <> '' 
                     THEN CONCAT(' ', u.Suffix) ELSE '' END
            ) AS FullName, 
            d.DepartmentName, 
            s.SubjectName,
            s.SubjectCode
        FROM Users u
        INNER JOIN FacultyLoad fl ON u.UserID = fl.FacultyID
        INNER JOIN Departments d ON fl.DepartmentID = d.DepartmentID
        INNER JOIN Subjects s ON fl.SubjectID = s.SubjectID
        WHERE u.UserID = @FacultyID AND s.SubjectID = @SubjectID
        LIMIT 1"

            Using cmd As New MySqlCommand(facultySql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@SubjectID", subjectID)
                conn.Open()
                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    If reader.Read() Then
                        litFacultyName.Text = SafeString(reader("FullName"))
                        litDept.Text = SafeString(reader("DepartmentName"))
                        litSubjectName.Text = $"{SafeString(reader("SubjectName"))} ({SafeString(reader("SubjectCode"))})"
                    End If
                End Using
            End Using

            litTerm.Text = $"{cycleName} ({term})"
            LoadDomainSummary(facultyID, cycleName, term, subjectID)
            LoadQuestionBreakdown(facultyID, cycleName, term, subjectID)
            LoadExecutiveSummary(facultyID, cycleName, term, subjectID)
            LoadStudentComments(facultyID, cycleName, term, subjectID)
        End Using
    End Sub

    Private Sub LoadDomainSummary(facultyID As Integer, cycleName As String, term As String, subjectID As Integer)
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "
            WITH current_cycle AS (
                SELECT CycleID FROM EvaluationCycles WHERE IsActive = 1 ORDER BY StartDate DESC LIMIT 1
            )
            SELECT 
                d.DomainName,
                d.Weight,
                ROUND(AVG(domain_scores.DomainAvg), 2) AS RawScore,
                ROUND((AVG(domain_scores.DomainAvg) / 5) * d.Weight, 1) AS WeightedScore
            FROM (
                SELECT 
                    es.SubmissionID,
                    d.DomainID,
                    AVG(e.Score) AS DomainAvg
                FROM Evaluations e
                INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
                INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
                INNER JOIN current_cycle cc ON es.CycleID = cc.CycleID
                INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
                INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
                WHERE fl.FacultyID = @FacultyID 
                AND fl.Term = @Term
                AND fl.SubjectID = @SubjectID
                AND e.Score IS NOT NULL 
                AND e.Score > 0
                GROUP BY es.SubmissionID, d.DomainID
            ) domain_scores
            INNER JOIN EvaluationDomains d ON domain_scores.DomainID = d.DomainID
            GROUP BY d.DomainID, d.DomainName, d.Weight
            ORDER BY d.DomainName"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@Term", term)
                cmd.Parameters.AddWithValue("@SubjectID", subjectID)

                Dim dt As New DataTable()
                Dim da As New MySqlDataAdapter(cmd)
                da.Fill(dt)

                gvDomainSummary.DataSource = dt
                gvDomainSummary.DataBind()
                ViewState("DomainSummary") = dt

                If dt.Rows.Count > 0 Then
                    Dim validRows = dt.AsEnumerable().Where(Function(r) SafeDecimal(r("RawScore")) > 0).ToList()

                    If validRows.Count > 0 Then
                        Dim maxRow = validRows.OrderByDescending(Function(r) SafeDecimal(r("RawScore"))).First()
                        Dim minRow = validRows.OrderBy(Function(r) SafeDecimal(r("RawScore"))).First()



                        Dim overallWeighted As Decimal = validRows.Sum(Function(r) SafeDecimal(r("WeightedScore")))
                        litWeightedAverage.Text = overallWeighted.ToString("N1") & "%"
                    Else

                        litWeightedAverage.Text = "0.0%"
                    End If
                Else

                    litWeightedAverage.Text = "0.0%"
                End If
            End Using
        End Using
    End Sub

    Private Sub LoadQuestionBreakdown(facultyID As Integer, cycleName As String, term As String, subjectID As Integer)
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "
            WITH current_cycle AS (
                SELECT CycleID FROM EvaluationCycles WHERE IsActive = 1 ORDER BY StartDate DESC LIMIT 1
            )
            SELECT 
                d.DomainName AS DomainName,
                q.QuestionText AS QuestionText,
                ROUND(AVG(e.Score), 2) AS AverageScore
            FROM Evaluations e
            INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
            INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
            INNER JOIN current_cycle cc ON es.CycleID = cc.CycleID
            INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
            INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
            WHERE fl.FacultyID = @FacultyID 
            AND fl.Term = @Term
            AND fl.SubjectID = @SubjectID
            AND e.Score IS NOT NULL 
            AND e.Score > 0
            GROUP BY d.DomainName, q.QuestionText, d.DomainID, q.QuestionID
            ORDER BY d.DomainID, q.QuestionID"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@Term", term)
                cmd.Parameters.AddWithValue("@SubjectID", subjectID)

                Dim dt As New DataTable()
                Dim da As New MySqlDataAdapter(cmd)
                da.Fill(dt)

                If dt.Rows.Count > 0 Then
                    Dim domainGroups = From row In dt.AsEnumerable()
                                       Group row By DomainName = row.Field(Of String)("DomainName") Into DomainGroup = Group
                                       Select New With {
                                          .DomainName = DomainName,
                                          .Questions = DomainGroup.ToList()
                                      }

                    rptDomains.DataSource = domainGroups
                    rptDomains.DataBind()
                    pnlNoQuestions.Visible = False
                Else
                    rptDomains.DataSource = Nothing
                    rptDomains.DataBind()
                    pnlNoQuestions.Visible = True
                End If
            End Using
        End Using
    End Sub

    Private Sub LoadStudentComments(facultyID As Integer, cycleName As String, term As String, subjectID As Integer)
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "
            WITH current_cycle AS (
                SELECT CycleID FROM EvaluationCycles WHERE IsActive = 1 ORDER BY StartDate DESC LIMIT 1
            )
            SELECT 
                es.Strengths,
                es.Weaknesses,
                es.AdditionalMessage
            FROM EvaluationSubmissions es
            INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
            INNER JOIN current_cycle cc ON es.CycleID = cc.CycleID
            WHERE fl.FacultyID = @FacultyID 
            AND fl.Term = @Term
            AND fl.SubjectID = @SubjectID
            AND (es.Strengths IS NOT NULL AND es.Strengths <> '' 
                 OR es.Weaknesses IS NOT NULL AND es.Weaknesses <> '' 
                 OR es.AdditionalMessage IS NOT NULL AND es.AdditionalMessage <> '')"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@Term", term)
                cmd.Parameters.AddWithValue("@SubjectID", subjectID)

                Dim dt As New DataTable()
                Dim da As New MySqlDataAdapter(cmd)
                da.Fill(dt)

                Dim strengths = New List(Of String)()
                Dim weaknesses = New List(Of String)()
                Dim additionalMessages = New List(Of String)()

                For Each row As DataRow In dt.Rows
                    If Not String.IsNullOrWhiteSpace(row("Strengths").ToString()) Then
                        strengths.Add(row("Strengths").ToString().Trim())
                    End If
                    If Not String.IsNullOrWhiteSpace(row("Weaknesses").ToString()) Then
                        weaknesses.Add(row("Weaknesses").ToString().Trim())
                    End If
                    If Not String.IsNullOrWhiteSpace(row("AdditionalMessage").ToString()) Then
                        additionalMessages.Add(row("AdditionalMessage").ToString().Trim())
                    End If
                Next

                ViewState("Strengths") = strengths
                ViewState("Weaknesses") = weaknesses
                ViewState("AdditionalMessages") = additionalMessages

                pnlNoComments.Visible = (strengths.Count = 0 AndAlso weaknesses.Count = 0 AndAlso additionalMessages.Count = 0)
            End Using
        End Using
    End Sub

    Private Sub LoadExecutiveSummary(facultyID As Integer, cycleName As String, term As String, subjectID As Integer)
        Try
            ' Just load basic info without KPI calculations
            LoadFacultyExecutiveInfo(facultyID, subjectID)
            LoadDomainSummary(facultyID, cycleName, term, subjectID)
            LoadQuestionBreakdown(facultyID, cycleName, term, subjectID)
            LoadStudentComments(facultyID, cycleName, term, subjectID)
            BindGroupedComments()

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"Error in LoadExecutiveSummary: {ex.Message}")
            ShowErrorMessage("Unable to load executive summary data.")
        End Try
    End Sub

    Private Sub CalculateSubjectKPIs(facultyID As Integer, term As String, subjectID As Integer)
        Using conn As New MySqlConnection(ConnString)
            conn.Open()


            ' Get actual response counts for display
            Dim totalStudents As Integer = 0
            Dim submittedStudents As Integer = 0

            Dim sqlTotal As String = "
        WITH current_cycle AS (
            SELECT CycleID FROM EvaluationCycles WHERE IsActive = 1 AND Status = 'Active' ORDER BY StartDate DESC LIMIT 1
        )
        SELECT COUNT(DISTINCT s.StudentID) as TotalStudents
        FROM Students s
        INNER JOIN Classes c ON s.ClassID = c.ClassID
        INNER JOIN FacultyLoad fl ON c.ClassID = fl.ClassID
        INNER JOIN current_cycle cc ON fl.Term = @Term
        WHERE fl.FacultyID = @FacultyID 
        AND fl.SubjectID = @SubjectID"

            Dim sqlSubmitted As String = "
        WITH current_cycle AS (
            SELECT CycleID FROM EvaluationCycles WHERE IsActive = 1 AND Status = 'Active' ORDER BY StartDate DESC LIMIT 1
        )
        SELECT COUNT(DISTINCT es.StudentID) as SubmittedStudents
        FROM EvaluationSubmissions es
        INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
        INNER JOIN current_cycle cc ON es.CycleID = cc.CycleID
        WHERE fl.FacultyID = @FacultyID 
        AND fl.SubjectID = @SubjectID
        AND fl.Term = @Term"

            Using cmd As New MySqlCommand(sqlTotal, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@SubjectID", subjectID)
                cmd.Parameters.AddWithValue("@Term", term)
                Dim result = cmd.ExecuteScalar()
                If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                    totalStudents = Convert.ToInt32(result)
                End If
            End Using

            Using cmd As New MySqlCommand(sqlSubmitted, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@SubjectID", subjectID)
                cmd.Parameters.AddWithValue("@Term", term)
                Dim result = cmd.ExecuteScalar()
                If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                    submittedStudents = Convert.ToInt32(result)
                End If
            End Using



            CalculateSubjectDomainExtremes(facultyID, term, subjectID)
        End Using
    End Sub

    Private Function CalculateSubjectWeightedRating(facultyID As Integer, term As String, subjectID As Integer) As Decimal
        Dim sql As String = "
        WITH current_cycle AS (
            SELECT CycleID FROM EvaluationCycles WHERE IsActive = 1 ORDER BY StartDate DESC LIMIT 1
        ),
        domain_avg AS (
            SELECT 
                es.SubmissionID,
                d.DomainID,
                d.Weight,
                AVG(e.Score) AS DomainAvg
            FROM Evaluations e
            INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
            INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
            INNER JOIN current_cycle cc ON es.CycleID = cc.CycleID
            INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
            INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
            WHERE fl.FacultyID = @FacultyID 
            AND fl.Term = @Term
            AND fl.SubjectID = @SubjectID
            AND e.Score IS NOT NULL 
            AND e.Score > 0
            GROUP BY es.SubmissionID, d.DomainID, d.Weight
        ),
        submission_scores AS (
            SELECT 
                SubmissionID,
                ROUND(SUM((DomainAvg / 5) * Weight), 1) AS SubmissionWeightedScore
            FROM domain_avg
            GROUP BY SubmissionID
        )
        SELECT COALESCE(ROUND(AVG(SubmissionWeightedScore), 1), 0) AS OverallWeightedRating
        FROM submission_scores"

        Using conn As New MySqlConnection(ConnString)
            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@Term", term)
                cmd.Parameters.AddWithValue("@SubjectID", subjectID)
                conn.Open()
                Dim result = cmd.ExecuteScalar()
                Return If(result IsNot Nothing AndAlso Not IsDBNull(result), Convert.ToDecimal(result), 0)
            End Using
        End Using
    End Function

    Private Function CalculateSubjectResponseRate(facultyID As Integer, term As String, subjectID As Integer) As Decimal
        Dim totalStudents As Integer = 0
        Dim submittedStudents As Integer = 0

        Dim sqlTotal As String = "
    WITH current_cycle AS (
        SELECT CycleID FROM EvaluationCycles WHERE IsActive = 1 AND Status = 'Active' ORDER BY StartDate DESC LIMIT 1
    )
    SELECT COUNT(DISTINCT s.StudentID) as TotalStudents
    FROM Students s
    INNER JOIN Classes c ON s.ClassID = c.ClassID
    INNER JOIN FacultyLoad fl ON c.ClassID = fl.ClassID
    INNER JOIN current_cycle cc ON fl.Term = @Term
    WHERE fl.FacultyID = @FacultyID 
    AND fl.SubjectID = @SubjectID"

        Dim sqlSubmitted As String = "
    WITH current_cycle AS (
        SELECT CycleID FROM EvaluationCycles WHERE IsActive = 1 AND Status = 'Active' ORDER BY StartDate DESC LIMIT 1
    )
    SELECT COUNT(DISTINCT es.StudentID) as SubmittedStudents
    FROM EvaluationSubmissions es
    INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
    INNER JOIN current_cycle cc ON es.CycleID = cc.CycleID
    WHERE fl.FacultyID = @FacultyID 
    AND fl.SubjectID = @SubjectID
    AND fl.Term = @Term"

        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            Using cmd As New MySqlCommand(sqlTotal, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@SubjectID", subjectID)
                cmd.Parameters.AddWithValue("@Term", term)
                Dim result = cmd.ExecuteScalar()
                If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                    totalStudents = Convert.ToInt32(result)
                End If
            End Using

            Using cmd As New MySqlCommand(sqlSubmitted, conn)
                cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                cmd.Parameters.AddWithValue("@SubjectID", subjectID)
                cmd.Parameters.AddWithValue("@Term", term)
                Dim result = cmd.ExecuteScalar()
                If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                    submittedStudents = Convert.ToInt32(result)
                End If
            End Using
        End Using

        If totalStudents > 0 Then
            Return Math.Round((submittedStudents / totalStudents) * 100, 1)
        End If

        Return 0
    End Function

    Private Sub CalculateSubjectDomainExtremes(facultyID As Integer, term As String, subjectID As Integer)
        CalculateDomainExtremes(facultyID, term)
    End Sub



    Private Sub ShowErrorMessage(message As String)
        System.Diagnostics.Debug.WriteLine($"User Error: {message}")
    End Sub

    Protected Function HasStrengths(commentObj As Object) As Boolean
        Return Not String.IsNullOrWhiteSpace(SafeString(commentObj))
    End Function

    Protected Function HasWeaknesses(commentObj As Object) As Boolean
        Return Not String.IsNullOrWhiteSpace(SafeString(commentObj))
    End Function

    Protected Function HasAdditionalMessage(commentObj As Object) As Boolean
        Return Not String.IsNullOrWhiteSpace(SafeString(commentObj))
    End Function

    Protected Function FormatCommentText(commentObj As Object) As String
        Dim comment = SafeString(commentObj)
        If String.IsNullOrWhiteSpace(comment) Then
            Return "No comment provided."
        End If
        Return comment
    End Function

    Private Sub BindGroupedComments()
        Dim strengths As List(Of String) = TryCast(ViewState("Strengths"), List(Of String))
        Dim weaknesses As List(Of String) = TryCast(ViewState("Weaknesses"), List(Of String))
        Dim additionalMessages As List(Of String) = TryCast(ViewState("AdditionalMessages"), List(Of String))

        If strengths IsNot Nothing AndAlso strengths.Count > 0 Then
            rptStrengths.DataSource = strengths
            rptStrengths.DataBind()

            pnlStrengths.Visible = True
        Else
            pnlStrengths.Visible = False
        End If

        If weaknesses IsNot Nothing AndAlso weaknesses.Count > 0 Then
            rptWeaknesses.DataSource = weaknesses
            rptWeaknesses.DataBind()

            pnlWeaknesses.Visible = True
        Else
            pnlWeaknesses.Visible = False
        End If

        If additionalMessages IsNot Nothing AndAlso additionalMessages.Count > 0 Then
            rptAdditionalMessages.DataSource = additionalMessages
            rptAdditionalMessages.DataBind()

            pnlAdditionalMessages.Visible = True
        Else
            pnlAdditionalMessages.Visible = False
        End If
    End Sub

    ' Navigation Methods
    Protected Sub btnBackToSubjectList_Click(sender As Object, e As EventArgs)
        pnlSubjectSelection.Visible = False
        pnlEvaluationList.Visible = True
    End Sub

    Protected Sub btnBackToSubject_Click(sender As Object, e As EventArgs)
        pnlDetailedReport.Visible = False
        pnlSubjectSelection.Visible = True
    End Sub

    Protected Sub btnBackToList_Click(sender As Object, e As EventArgs)
        pnlDetailedReport.Visible = False
        pnlEvaluationList.Visible = True
    End Sub

    ' Refresh Data Method
    Protected Sub btnRefreshData_Click(sender As Object, e As EventArgs)
        ViewState.Remove("ExportData")
        ViewState.Remove("CurrentFacultyID")
        ViewState.Remove("CurrentCycleName")
        ViewState.Remove("CurrentTerm")
        ViewState.Remove("CurrentSubjectID")
        ViewState.Remove("CurrentSubjectName")
        ViewState.Remove("CurrentCycleID")

        LoadEvaluationList()
    End Sub

    ' Export and Other Existing Methods
    Protected Sub btnExportExcel_Click(sender As Object, e As EventArgs)
        Try
            Dim dt As DataTable = TryCast(ViewState("ExportData"), DataTable)
            If dt Is Nothing OrElse dt.Rows.Count = 0 Then
                ClientScript.RegisterStartupScript(Me.GetType(), "NoData", "alert('No data available to export.');", True)
                Return
            End If

            Using workbook As New XLWorkbook()
                Dim worksheet = workbook.Worksheets.Add("Faculty Evaluation Summary")

                ' Title
                worksheet.Cell(1, 1).Value = "FACULTY EVALUATION SUMMARY REPORT"
                worksheet.Cell(1, 1).Style.Font.Bold = True
                worksheet.Cell(1, 1).Style.Font.FontSize = 16
                worksheet.Range(1, 1, 1, 9).Merge()

                ' Date
                worksheet.Cell(2, 1).Value = "Generated on: " & DateTime.Now.ToString("MMMM dd, yyyy")
                worksheet.Cell(2, 1).Style.Font.Italic = True

                ' Headers
                Dim headers() As String = {"Faculty Name", "Department", "Weighted Score", "Raw Score", "Subjects", "Evaluations", "Response Rate", "Cycle", "Term"}
                For i As Integer = 0 To headers.Length - 1
                    worksheet.Cell(4, i + 1).Value = headers(i)
                    worksheet.Cell(4, i + 1).Style.Font.Bold = True
                    worksheet.Cell(4, i + 1).Style.Fill.BackgroundColor = XLColor.LightGray
                    worksheet.Cell(4, i + 1).Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Center
                Next

                ' Data
                For row As Integer = 0 To dt.Rows.Count - 1
                    worksheet.Cell(row + 5, 1).Value = SafeString(dt.Rows(row)("FacultyName"))
                    worksheet.Cell(row + 5, 2).Value = SafeString(dt.Rows(row)("DepartmentName"))

                    Dim weightedScore As Decimal = SafeDecimal(dt.Rows(row)("WeightedScore"))
                    worksheet.Cell(row + 5, 3).Value = weightedScore / 100D

                    worksheet.Cell(row + 5, 4).Value = SafeDecimal(dt.Rows(row)("RawScore"))
                    worksheet.Cell(row + 5, 5).Value = SafeInteger(dt.Rows(row)("SubjectsCount"))
                    worksheet.Cell(row + 5, 6).Value = SafeInteger(dt.Rows(row)("EvaluationsCount"))

                    Dim responseRate As Decimal = SafeDecimal(dt.Rows(row)("ResponseRate"))
                    worksheet.Cell(row + 5, 7).Value = responseRate / 100D

                    worksheet.Cell(row + 5, 8).Value = SafeString(dt.Rows(row)("CycleName"))
                    worksheet.Cell(row + 5, 9).Value = SafeString(dt.Rows(row)("Term"))
                Next

                ' Format
                worksheet.Column(3).Style.NumberFormat.Format = "0.0%"
                worksheet.Column(4).Style.NumberFormat.Format = "0.00"
                worksheet.Column(7).Style.NumberFormat.Format = "0.0%"
                worksheet.Columns().AdjustToContents()

                ' Response
                Response.Clear()
                Response.Buffer = True
                Response.Charset = ""
                Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                Response.AddHeader("content-disposition", "attachment;filename=Faculty_Evaluation_Summary_" & DateTime.Now.ToString("yyyyMMddHHmmss") & ".xlsx")

                Using memoryStream As New MemoryStream()
                    workbook.SaveAs(memoryStream)
                    memoryStream.WriteTo(Response.OutputStream)
                End Using

                Response.Flush()
                Response.End()
            End Using

        Catch ex As Exception
            ClientScript.RegisterStartupScript(Me.GetType(), "ExportError", "alert('Error exporting data: " & ex.Message.Replace("'", "\'") & "');", True)
        End Try
    End Sub

    ' Helper Methods
    Private Sub UpdatePrintHeaderLiterals()
        ' litPrintInstitution.Text = "Golden West Colleges"
    End Sub

    Protected Sub gvDomainSummary_RowDataBound(sender As Object, e As GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim lblWeighted As Label = TryCast(e.Row.FindControl("lblWeighted"), Label)
            If lblWeighted IsNot Nothing Then
                Dim weighted As Decimal = SafeDecimal(DataBinder.Eval(e.Row.DataItem, "WeightedScore"))
                lblWeighted.Text = Math.Round(weighted, 1).ToString("N1") & "%"
            End If
        End If
    End Sub

    Protected Sub rptDomains_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            Dim questions As List(Of DataRow) = TryCast(DataBinder.Eval(e.Item.DataItem, "Questions"), List(Of DataRow))
            Dim rptDomainQuestions As Repeater = TryCast(e.Item.FindControl("rptDomainQuestions"), Repeater)

            If questions IsNot Nothing AndAlso rptDomainQuestions IsNot Nothing Then
                Dim questionDt As DataTable = If(questions.Count > 0, questions(0).Table.Clone(), New DataTable())
                For Each row As DataRow In questions
                    questionDt.ImportRow(row)
                Next

                rptDomainQuestions.DataSource = questionDt
                rptDomainQuestions.DataBind()
            End If
        End If
    End Sub

    Public Overrides Sub VerifyRenderingInServerForm(control As Control)
        ' Required for GridView export
    End Sub

    ' ========== HELPER METHODS ==========
    Private Function SafeString(obj As Object) As String
        If obj Is Nothing OrElse IsDBNull(obj) Then
            Return String.Empty
        End If
        Return obj.ToString()
    End Function

    Private Function SafeInteger(obj As Object) As Integer
        If obj Is Nothing OrElse IsDBNull(obj) Then
            Return 0
        End If
        Dim result As Integer
        If Integer.TryParse(obj.ToString(), result) Then
            Return result
        End If
        Return 0
    End Function

    Private Function SafeDecimal(obj As Object) As Decimal
        If obj Is Nothing OrElse IsDBNull(obj) Then
            Return 0D
        End If
        Dim result As Decimal
        If Decimal.TryParse(obj.ToString(), result) Then
            Return result
        End If
        Return 0D
    End Function

    Public Function FormatNumber(number As Object, decimals As Integer) As String
        If number Is Nothing OrElse IsDBNull(number) Then
            Return "0." & New String("0"c, decimals)
        End If
        Dim numericValue As Decimal
        If Decimal.TryParse(number.ToString(), numericValue) Then
            Return numericValue.ToString("N" & decimals)
        End If
        Return "0." & New String("0"c, decimals)
    End Function

    Public Function FormatDate(dateObj As Object) As String
        If dateObj Is Nothing OrElse IsDBNull(dateObj) Then
            Return "N/A"
        End If
        Try
            Dim dateValue As DateTime = Convert.ToDateTime(dateObj)
            Return dateValue.ToString("MMM dd, yyyy")
        Catch ex As Exception
            Return "N/A"
        End Try
    End Function

    Public Function GetCommandArgument(facultyID As Object, cycleID As Object, cycleName As Object, term As Object) As String
        Return $"{SafeInteger(facultyID)}|{SafeInteger(cycleID)}|{SafeString(cycleName)}|{SafeString(term)}"
    End Function

    Public Function GetScoreClass(score As Object) As String
        Dim numericScore As Decimal = SafeDecimal(score)
        If numericScore >= 85 Then
            Return "badge bg-success"
        ElseIf numericScore >= 75 Then
            Return "badge bg-warning"
        Else
            Return "badge bg-danger"
        End If
    End Function
End Class

