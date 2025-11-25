Imports System.Collections.Generic
Imports System.Data
Imports System.Web.Script.Serialization
Imports System.Web.Script.Services
Imports System.Web.Services
Imports MySql.Data.MySqlClient

Public Class DepartmentResult
    Inherits System.Web.UI.Page

    ' Data classes
    Public Class DepartmentOverviewData
        Public Property OverallScore As Decimal
        Public Property TotalEvaluations As Integer
        Public Property CompletionRate As Decimal
        Public Property Trend As Decimal
    End Class

    Public Class DomainData
        Public Property DomainID As Integer
        Public Property DomainName As String
        Public Property Weight As Decimal
        Public Property AvgScore As Decimal  ' Weighted percentage
        Public Property RawAvg As Decimal    ' Raw average (1-5 scale)
    End Class
    Public Class TrendData
        Public Property Labels As List(Of String)
        Public Property Scores As List(Of Decimal)
    End Class

    Public Class CourseData
        Public Property CourseID As Integer
        Public Property CourseName As String
        Public Property AvgScore As Decimal
        Public Property EvaluationCount As Integer
        Public Property FacultyCount As Integer
        Public Property StudentCount As Integer
    End Class

    Public Class FacultyData
        Public Property FacultyID As Integer
        Public Property FullName As String
        Public Property AvgScore As Decimal
        Public Property EvaluationCount As Integer
        Public Property SubjectCount As Integer
    End Class

    Public Class SubjectData
        Public Property SubjectID As Integer
        Public Property SubjectCode As String
        Public Property SubjectName As String
        Public Property FacultyCount As Integer
        Public Property EvaluationCount As Integer
    End Class

    Public Class FacultyDetailsData
        Public Property Domains As List(Of DomainData)
        Public Property Questions As List(Of QuestionData)
        Public Property Comments As List(Of String)
        Public Property Subjects As List(Of SubjectData)
    End Class

    Public Class QuestionData
        Public Property QuestionText As String
        Public Property AvgScore As Decimal
        Public Property DomainID As Integer
        Public Property DomainName As String
    End Class

    Public Class CourseDetailsData
        Public Property CourseName As String
        Public Property AvgScore As Decimal
        Public Property EvaluationCount As Integer
        Public Property FacultyCount As Integer
        Public Property ClassCount As Integer
        Public Property StudentCount As Integer
        Public Property Domains As List(Of DomainData)
    End Class

    Public Class CycleData
        Public Property CycleID As Integer
        Public Property Term As String
        Public Property CycleName As String
        Public Property StartDate As String
        Public Property EndDate As String
        Public Property DisplayName As String
        Public Property Status As String
    End Class

    Public Class CourseDomainData
        Public Property CourseID As Integer
        Public Property CourseName As String
        Public Property Domains As List(Of DomainComparisonData)
    End Class

    Public Class DomainComparisonData
        Public Property DomainName As String
        Public Property Score As Decimal
        Public Property Weight As Decimal
    End Class

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Session("Role") Is Nothing OrElse Not Session("Role").ToString().Equals("Dean", StringComparison.OrdinalIgnoreCase) Then
            Response.Redirect("Login.aspx", False)
            Context.ApplicationInstance.CompleteRequest()
            Return
        End If

        If Not IsPostBack Then
            LoadDeanInfo()
            hdnDepartmentID.Value = Session("DepartmentID").ToString()
            LoadDefaultCycle()
        End If
    End Sub

    Private Sub LoadDeanInfo()
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim sql As String = "
                SELECT CONCAT(u.LastName, ', ', u.FirstName, 
                    CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial <> '' 
                         THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
                    CASE WHEN u.Suffix IS NOT NULL AND u.Suffix <> '' 
                         THEN CONCAT(' ', u.Suffix) ELSE '' END
                ) AS FullName, d.DepartmentName
                FROM Users u
                LEFT JOIN Departments d ON u.DepartmentID = d.DepartmentID
                WHERE u.UserID=@uid AND u.Role='Dean' LIMIT 1"
            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@uid", Session("UserID"))
                Using rdr As MySqlDataReader = cmd.ExecuteReader()
                    If rdr.Read() Then
                        lblDeanName.Text = rdr("FullName").ToString()
                        lblDepartment.Text = If(IsDBNull(rdr("DepartmentName")), "N/A", rdr("DepartmentName").ToString())
                    End If
                End Using
            End Using
        End Using
    End Sub

    Private Sub LoadDefaultCycle()
        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' MODIFIED: Get the latest cycle (by StartDate) regardless of status
            ' First try to get any cycle that has evaluation data for this department
            Dim sql As String = "
        SELECT DISTINCT ec.CycleID, ec.Term, ec.CycleName, ec.StartDate, ec.EndDate, ec.Status
        FROM EvaluationCycles ec
        INNER JOIN EvaluationSubmissions es ON ec.CycleID = es.CycleID
        INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
        WHERE fl.DepartmentID = @DepartmentID
          AND ec.IsActive = 1
        ORDER BY ec.StartDate DESC 
        LIMIT 1"

            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@DepartmentID", Session("DepartmentID"))
                Using rdr As MySqlDataReader = cmd.ExecuteReader()
                    If rdr.Read() Then
                        Dim cycle As New CycleData()
                        cycle.CycleID = Convert.ToInt32(rdr("CycleID"))
                        cycle.Term = rdr("Term").ToString()
                        cycle.CycleName = If(IsDBNull(rdr("CycleName")), "", rdr("CycleName").ToString())
                        cycle.StartDate = Convert.ToDateTime(rdr("StartDate")).ToString("yyyy-MM-dd")
                        cycle.EndDate = Convert.ToDateTime(rdr("EndDate")).ToString("yyyy-MM-dd")
                        cycle.Status = rdr("Status").ToString()

                        If String.IsNullOrEmpty(cycle.CycleName) Then
                            cycle.DisplayName = cycle.Term
                        Else
                            cycle.DisplayName = cycle.Term & " - " & cycle.CycleName
                        End If

                        hdnCycleID.Value = cycle.CycleID.ToString()
                        txtCycle.Text = cycle.DisplayName
                    Else
                        ' If no cycle with data found, try to get any active cycle
                        LoadFallbackCycle(conn)
                    End If
                End Using
            End Using
        End Using
    End Sub

    Private Sub LoadFallbackCycle(conn As MySqlConnection)
        ' Fallback: Get any active cycle ordered by most recent
        Dim fallbackSql As String = "
    SELECT CycleID, Term, CycleName, StartDate, EndDate, Status
    FROM EvaluationCycles 
    WHERE IsActive = 1
    ORDER BY StartDate DESC 
    LIMIT 1"

        Using cmd As New MySqlCommand(fallbackSql, conn)
            Using rdr As MySqlDataReader = cmd.ExecuteReader()
                If rdr.Read() Then
                    Dim cycle As New CycleData()
                    cycle.CycleID = Convert.ToInt32(rdr("CycleID"))
                    cycle.Term = rdr("Term").ToString()
                    cycle.CycleName = If(IsDBNull(rdr("CycleName")), "", rdr("CycleName").ToString())
                    cycle.StartDate = Convert.ToDateTime(rdr("StartDate")).ToString("yyyy-MM-dd")
                    cycle.EndDate = Convert.ToDateTime(rdr("EndDate")).ToString("yyyy-MM-dd")
                    cycle.Status = rdr("Status").ToString()

                    If String.IsNullOrEmpty(cycle.CycleName) Then
                        cycle.DisplayName = cycle.Term
                    Else
                        cycle.DisplayName = cycle.Term & " - " & cycle.CycleName
                    End If

                    hdnCycleID.Value = cycle.CycleID.ToString()
                    txtCycle.Text = cycle.DisplayName
                Else
                    ' No active cycle found, set to empty
                    hdnCycleID.Value = "0"
                    txtCycle.Text = "Select Evaluation Cycle"
                End If
            End Using
        End Using
    End Sub

    ' Web Methods
    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function SearchCycles(searchText As String) As List(Of CycleData)
        Dim cycles As New List(Of CycleData)()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()
                Dim query As String = "SELECT CycleID, Term, StartDate, EndDate, CycleName, Status 
                          FROM EvaluationCycles 
                          WHERE (Term LIKE @SearchText 
                             OR CycleName LIKE @SearchText
                             OR DATE_FORMAT(StartDate, '%M %Y') LIKE @SearchText 
                             OR DATE_FORMAT(EndDate, '%M %Y') LIKE @SearchText)
                             AND IsActive = 1
                          ORDER BY Status DESC, StartDate DESC LIMIT 10"

                Using cmd As New MySqlCommand(query, conn)
                    cmd.Parameters.AddWithValue("@SearchText", "%" & searchText & "%")

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        While rdr.Read()
                            Dim cycle As New CycleData()
                            cycle.CycleID = Convert.ToInt32(rdr("CycleID"))
                            cycle.Term = rdr("Term").ToString()
                            cycle.CycleName = If(IsDBNull(rdr("CycleName")), "", rdr("CycleName").ToString())
                            cycle.StartDate = If(IsDBNull(rdr("StartDate")), "", Convert.ToDateTime(rdr("StartDate")).ToString("yyyy-MM-dd"))
                            cycle.EndDate = If(IsDBNull(rdr("EndDate")), "", Convert.ToDateTime(rdr("EndDate")).ToString("yyyy-MM-dd"))
                            cycle.Status = rdr("Status").ToString()

                            If String.IsNullOrEmpty(cycle.CycleName) Then
                                cycle.DisplayName = cycle.Term
                            Else
                                cycle.DisplayName = cycle.Term & " - " & cycle.CycleName
                            End If

                            cycles.Add(cycle)
                        End While
                    End Using
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in SearchCycles: " & ex.Message)
        End Try

        Return cycles
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetActiveCycle() As CycleData
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        Dim cycle As CycleData = Nothing

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()

                ' MODIFIED: Get the latest active cycle regardless of status
                Dim query As String = "SELECT CycleID, Term, CycleName, StartDate, EndDate, Status
                          FROM EvaluationCycles 
                          WHERE IsActive = 1
                          ORDER BY StartDate DESC LIMIT 1"

                Using cmd As New MySqlCommand(query, conn)
                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        If rdr.Read() Then
                            cycle = New CycleData()
                            cycle.CycleID = Convert.ToInt32(rdr("CycleID"))
                            cycle.Term = rdr("Term").ToString()
                            cycle.CycleName = If(IsDBNull(rdr("CycleName")), "", rdr("CycleName").ToString())
                            cycle.StartDate = Convert.ToDateTime(rdr("StartDate")).ToString("yyyy-MM-dd")
                            cycle.EndDate = Convert.ToDateTime(rdr("EndDate")).ToString("yyyy-MM-dd")
                            cycle.Status = rdr("Status").ToString()

                            If String.IsNullOrEmpty(cycle.CycleName) Then
                                cycle.DisplayName = cycle.Term
                            Else
                                cycle.DisplayName = cycle.Term & " - " & cycle.CycleName
                            End If
                        End If
                    End Using
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetActiveCycle: " & ex.Message)
        End Try

        Return cycle
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetDepartmentOverview(departmentID As Integer, cycleID As Integer) As DepartmentOverviewData
        Dim overview As New DepartmentOverviewData()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()

                ' CORRECT CALCULATION: Use weighted average exactly like MyEvaluations page
                Dim scoreQuery As String = "
        WITH domain_scores AS (
            SELECT 
                es.SubmissionID,
                d.DomainID,
                d.DomainName,
                d.Weight,
                AVG(e.Score) AS DomainAvg, -- 1-5 scale
                (AVG(e.Score) / 5) * d.Weight AS WeightedPercentage -- Correct weighted calculation
            FROM Evaluations e
            INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
            INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
            INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
            INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
            WHERE fl.DepartmentID = @DepartmentID
                AND e.Score IS NOT NULL 
                AND e.Score > 0"

                If cycleID > 0 Then
                    scoreQuery &= " AND es.CycleID = @CycleID"
                End If

                scoreQuery &= "
            GROUP BY es.SubmissionID, d.DomainID, d.DomainName, d.Weight
        ),
        submission_totals AS (
            SELECT 
                SubmissionID,
                SUM(WeightedPercentage) AS TotalScore -- Sum of weighted percentages
            FROM domain_scores
            GROUP BY SubmissionID
        )
        SELECT 
            LEAST(ROUND(AVG(TotalScore), 1), 100.0) AS OverallScore, -- CORRECTED: Added bounds
            COUNT(DISTINCT SubmissionID) AS TotalEvaluations
        FROM submission_totals"

                Using cmd As New MySqlCommand(scoreQuery, conn)
                    cmd.Parameters.AddWithValue("@DepartmentID", departmentID)
                    If cycleID > 0 Then
                        cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    End If

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        If rdr.Read() Then
                            overview.OverallScore = If(IsDBNull(rdr("OverallScore")), 0, Convert.ToDecimal(rdr("OverallScore")))
                            overview.TotalEvaluations = Convert.ToInt32(rdr("TotalEvaluations"))
                        Else
                            overview.OverallScore = 0
                            overview.TotalEvaluations = 0
                        End If
                    End Using
                End Using

                ' Calculate completion rate
                Dim completionQuery As String = "SELECT 
            COUNT(DISTINCT es.StudentID) as StudentsEvaluated,
            (SELECT COUNT(*) FROM Students s WHERE s.DepartmentID = @DepartmentID AND s.Status = 'Active') as TotalStudents
        FROM EvaluationSubmissions es
        INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
        WHERE fl.DepartmentID = @DepartmentID"

                If cycleID > 0 Then
                    completionQuery &= " AND es.CycleID = @CycleID"
                End If

                Using cmd As New MySqlCommand(completionQuery, conn)
                    cmd.Parameters.AddWithValue("@DepartmentID", departmentID)
                    If cycleID > 0 Then
                        cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    End If

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        If rdr.Read() Then
                            Dim studentsEvaluated = Convert.ToInt32(rdr("StudentsEvaluated"))
                            Dim totalStudents = Convert.ToInt32(rdr("TotalStudents"))
                            overview.CompletionRate = If(totalStudents > 0, Math.Round((studentsEvaluated / totalStudents) * 100, 1), 0)
                        Else
                            overview.CompletionRate = 0
                        End If
                    End Using
                End Using

                ' Calculate trend using the FIXED function
                overview.Trend = CalculateWeightedTrend(departmentID, cycleID, connString)

            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetDepartmentOverview: " & ex.Message)
            overview.OverallScore = 0
            overview.TotalEvaluations = 0
            overview.CompletionRate = 0
            overview.Trend = 0
        End Try

        Return overview
    End Function
    Private Shared Function CalculateWeightedTrend(departmentID As Integer, currentCycleID As Integer, connString As String) As Decimal
        Dim trend As Decimal = 0

        If currentCycleID = 0 Then
            Return 0
        End If

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()

                ' Get current cycle weighted average
                Dim currentAvgQuery As String = "
                WITH domain_scores AS (
                    SELECT 
                        es.SubmissionID,
                        d.DomainID,
                        d.Weight,
                        AVG(e.Score) AS DomainAvg,
                        LEAST((AVG(e.Score) / 5) * d.Weight, d.Weight) AS WeightedPercentage
                    FROM Evaluations e
                    INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
                    INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
                    INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
                    INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
                    WHERE fl.DepartmentID = @DepartmentID
                        AND e.Score IS NOT NULL 
                        AND e.Score > 0
                        AND es.CycleID = @CycleID
                    GROUP BY es.SubmissionID, d.DomainID, d.Weight
                ),
                submission_totals AS (
                    SELECT 
                        SubmissionID,
                        SUM(WeightedPercentage) AS TotalScore
                    FROM domain_scores
                    GROUP BY SubmissionID
                )
                SELECT 
                    LEAST(ROUND(AVG(TotalScore), 1), 100.0) AS CurrentAvg
                FROM submission_totals"

                Dim currentAvg As Decimal = 0
                Using cmd As New MySqlCommand(currentAvgQuery, conn)
                    cmd.Parameters.AddWithValue("@DepartmentID", departmentID)
                    cmd.Parameters.AddWithValue("@CycleID", currentCycleID)

                    Dim result = cmd.ExecuteScalar()
                    currentAvg = If(IsDBNull(result) OrElse result Is Nothing, 0, Convert.ToDecimal(result))
                End Using

                ' If no current data, trend is 0
                If currentAvg = 0 Then
                    Return 0
                End If

                ' Get previous cycle (most recent cycle before current one)
                Dim prevCycleQuery As String = "
                SELECT ec.CycleID 
                FROM EvaluationCycles ec
                WHERE ec.CycleID < @CurrentCycleID 
                AND ec.Status IN ('Active', 'Inactive')
                ORDER BY ec.EndDate DESC 
                LIMIT 1"

                Dim prevCycleID As Integer = 0
                Using cmd As New MySqlCommand(prevCycleQuery, conn)
                    cmd.Parameters.AddWithValue("@CurrentCycleID", currentCycleID)
                    Dim result = cmd.ExecuteScalar()
                    If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                        prevCycleID = Convert.ToInt32(result)
                    End If
                End Using

                Dim previousAvg As Decimal = 0
                Dim hasPreviousData As Boolean = False

                If prevCycleID > 0 Then
                    ' Calculate previous cycle with same formula
                    Using cmd As New MySqlCommand(currentAvgQuery.Replace("@CycleID", "@PrevCycleID"), conn)
                        cmd.Parameters.AddWithValue("@DepartmentID", departmentID)
                        cmd.Parameters.AddWithValue("@PrevCycleID", prevCycleID)

                        Dim result = cmd.ExecuteScalar()
                        previousAvg = If(IsDBNull(result) OrElse result Is Nothing, 0, Convert.ToDecimal(result))
                        hasPreviousData = (previousAvg > 0)
                    End Using
                End If

                ' FIXED: Calculate trend as percentage points difference
                If hasPreviousData AndAlso previousAvg > 0 Then
                    trend = Math.Round(currentAvg - previousAvg, 1)
                Else
                    ' No previous data - no trend calculation
                    trend = 0
                End If

            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in CalculateWeightedTrend: " & ex.Message)
            trend = 0
        End Try

        Return trend
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetDomainPerformance(departmentID As Integer, cycleID As Integer) As List(Of DomainData)
        Dim domains As New List(Of DomainData)()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()

                ' CORRECT DOMAIN CALCULATION - Consistent with MyEvaluations
                Dim query As String = "
            SELECT 
                d.DomainID, 
                d.DomainName, 
                d.Weight,
                ROUND(AVG(e.Score), 2) AS DomainAvg, -- 1-5 scale average
                ROUND((AVG(e.Score) / 5) * d.Weight, 1) AS AvgScore -- Weighted percentage
            FROM Evaluations e
            INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
            INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
            INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
            INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
            WHERE fl.DepartmentID = @DepartmentID
                AND e.Score IS NOT NULL 
                AND e.Score > 0"

                If cycleID > 0 Then
                    query &= " AND es.CycleID = @CycleID"
                End If

                query &= " 
            GROUP BY d.DomainID, d.DomainName, d.Weight
            HAVING AVG(e.Score) > 0
            ORDER BY d.Weight DESC"

                Using cmd As New MySqlCommand(query, conn)
                    cmd.Parameters.AddWithValue("@DepartmentID", departmentID)
                    If cycleID > 0 Then
                        cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    End If

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        While rdr.Read()
                            domains.Add(New DomainData() With {
                            .DomainID = Convert.ToInt32(rdr("DomainID")),
                            .DomainName = rdr("DomainName").ToString(),
                            .Weight = Convert.ToDecimal(rdr("Weight")),
                            .AvgScore = Convert.ToDecimal(rdr("AvgScore")) ' This is now the weighted percentage
                        })
                        End While
                    End Using
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetDomainPerformance: " & ex.Message)
            domains = New List(Of DomainData)()
        End Try

        Return domains
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetTrendData(departmentID As Integer) As TrendData
        Dim trendData As New TrendData()
        trendData.Labels = New List(Of String)()
        trendData.Scores = New List(Of Decimal)()

        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()

                ' CORRECT TREND DATA with weighted calculations
                Dim query As String = "
        WITH cycle_scores AS (
            SELECT 
                ec.CycleID,
                ec.Term, 
                ec.CycleName,
                d.DomainID,
                d.Weight,
                AVG(e.Score) AS DomainAvg,
                (AVG(e.Score) / 5) * d.Weight AS WeightedPercentage
            FROM Evaluations e
            INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
            INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
            INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
            INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
            INNER JOIN EvaluationCycles ec ON es.CycleID = ec.CycleID
            WHERE fl.DepartmentID = @DepartmentID AND ec.IsActive = 1
            GROUP BY ec.CycleID, ec.Term, ec.CycleName, d.DomainID, d.Weight
        ),
        cycle_totals AS (
            SELECT 
                CycleID,
                Term,
                CycleName,
                SUM(WeightedPercentage) AS TotalScore
            FROM cycle_scores
            GROUP BY CycleID, Term, CycleName
        )
        SELECT 
            Term,
            CycleName,
            ROUND(TotalScore, 1) AS AvgScore
        FROM cycle_totals
        ORDER BY CycleID DESC
        LIMIT 6"

                Using cmd As New MySqlCommand(query, conn)
                    cmd.Parameters.AddWithValue("@DepartmentID", departmentID)

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        While rdr.Read()
                            Dim termName As String = rdr("Term").ToString()
                            Dim cycleName As String = If(IsDBNull(rdr("CycleName")), "", rdr("CycleName").ToString())
                            Dim label As String = If(String.IsNullOrEmpty(cycleName), termName, $"{termName} - {cycleName}")

                            ' CHANGED: Simply add to the list in the order they come from the database
                            trendData.Labels.Add(label)
                            trendData.Scores.Add(Convert.ToDecimal(rdr("AvgScore")))
                        End While
                    End Using
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetTrendData: " & ex.Message)
        End Try

        Return trendData
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetCourseData(departmentID As Integer, cycleID As Integer) As List(Of CourseData)
        Dim courses As New List(Of CourseData)()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()

                ' First get total evaluations for the department to calculate contribution
                Dim totalEvalsQuery As String = "SELECT COUNT(DISTINCT es.SubmissionID) as TotalEvaluations
                                      FROM EvaluationSubmissions es
                                      INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
                                      WHERE fl.DepartmentID = @DepartmentID"

                If cycleID > 0 Then
                    totalEvalsQuery &= " AND es.CycleID = @CycleID"
                End If

                Dim totalEvaluations As Integer = 0
                Using cmd As New MySqlCommand(totalEvalsQuery, conn)
                    cmd.Parameters.AddWithValue("@DepartmentID", departmentID)
                    If cycleID > 0 Then
                        cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    End If
                    Dim result = cmd.ExecuteScalar()
                    totalEvaluations = If(result Is Nothing Or IsDBNull(result), 0, Convert.ToInt32(result))
                End Using

                ' CORRECT COURSE CALCULATION with weighted scores
                Dim query As String = "
        WITH course_domains AS (
            SELECT 
                c.CourseID,
                c.CourseName,
                d.DomainID,
                d.Weight,
                AVG(e.Score) AS DomainAvg,
                (AVG(e.Score) / 5) * d.Weight AS WeightedPercentage
            FROM Courses c
            INNER JOIN FacultyLoad fl ON c.CourseID = fl.CourseID
            INNER JOIN EvaluationSubmissions es ON fl.LoadID = es.LoadID
            INNER JOIN Evaluations e ON es.SubmissionID = e.SubmissionID
            INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
            INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
            WHERE c.DepartmentID = @DepartmentID AND c.IsActive = 1
                AND e.Score IS NOT NULL"

                If cycleID > 0 Then
                    query &= " AND es.CycleID = @CycleID"
                End If

                query &= "
            GROUP BY c.CourseID, c.CourseName, d.DomainID, d.Weight
        ),
        course_totals AS (
            SELECT 
                CourseID,
                CourseName,
                SUM(WeightedPercentage) AS TotalScore,
                COUNT(DISTINCT DomainID) AS DomainCount
            FROM course_domains
            GROUP BY CourseID, CourseName
        ),
        course_stats AS (
            SELECT 
                fl.CourseID,
                COUNT(DISTINCT es.SubmissionID) AS EvaluationCount,
                COUNT(DISTINCT fl.FacultyID) AS FacultyCount,
                COUNT(DISTINCT s.StudentID) AS StudentCount
            FROM FacultyLoad fl
            LEFT JOIN EvaluationSubmissions es ON fl.LoadID = es.LoadID
            LEFT JOIN Students s ON fl.CourseID = s.CourseID AND s.Status = 'Active'"

                If cycleID > 0 Then
                    query &= " AND (es.CycleID = @CycleID OR es.CycleID IS NULL)"
                End If

                query &= "
            GROUP BY fl.CourseID
        )
        SELECT 
            ct.CourseID,
            ct.CourseName,
            ROUND(ct.TotalScore, 1) AS AvgScore,
            cs.EvaluationCount,
            cs.FacultyCount,
            cs.StudentCount
        FROM course_totals ct
        INNER JOIN course_stats cs ON ct.CourseID = cs.CourseID
        WHERE ct.DomainCount > 0
        ORDER BY ct.TotalScore DESC"

                Using cmd As New MySqlCommand(query, conn)
                    cmd.Parameters.AddWithValue("@DepartmentID", departmentID)
                    If cycleID > 0 Then
                        cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    End If

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        While rdr.Read()
                            Dim courseEvals = Convert.ToInt32(rdr("EvaluationCount"))
                            Dim contribution = If(totalEvaluations > 0, Math.Round((courseEvals / totalEvaluations) * 100, 1), 0)

                            courses.Add(New CourseData() With {
                            .CourseID = Convert.ToInt32(rdr("CourseID")),
                            .CourseName = rdr("CourseName").ToString(),
                            .AvgScore = If(IsDBNull(rdr("AvgScore")), 0, Convert.ToDecimal(rdr("AvgScore"))),
                            .EvaluationCount = courseEvals,
                            .FacultyCount = Convert.ToInt32(rdr("FacultyCount")),
                            .StudentCount = Convert.ToInt32(rdr("StudentCount"))
                        })
                        End While
                    End Using
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetCourseData: " & ex.Message)
        End Try

        Return courses
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetFacultyData(departmentID As Integer, cycleID As Integer) As List(Of FacultyData)
        Dim facultyData As New List(Of FacultyData)()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()

                ' CORRECT FACULTY CALCULATION with weighted scores
                Dim facultyQuery As String = "
            WITH faculty_domains AS (
                SELECT 
                    u.UserID,
                    CONCAT(u.LastName, ', ', u.FirstName, 
                        CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial <> '' 
                             THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
                        CASE WHEN u.Suffix IS NOT NULL AND u.Suffix <> '' 
                             THEN CONCAT(' ', u.Suffix) ELSE '' END
                    ) AS FullName,
                    d.DomainID,
                    d.Weight,
                    AVG(e.Score) AS DomainAvg,
                    (AVG(e.Score) / 5) * d.Weight AS WeightedPercentage
                FROM Users u
                INNER JOIN FacultyLoad fl ON u.UserID = fl.FacultyID
                INNER JOIN EvaluationSubmissions es ON fl.LoadID = es.LoadID
                INNER JOIN Evaluations e ON es.SubmissionID = e.SubmissionID
                INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
                INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
                WHERE u.DepartmentID = @DepartmentID 
                    AND u.Role = 'Faculty' 
                    AND u.Status = 'Active'
                    AND e.Score IS NOT NULL 
                    AND e.Score > 0"

                If cycleID > 0 Then
                    facultyQuery &= " AND es.CycleID = @CycleID"
                End If

                facultyQuery &= "
                GROUP BY u.UserID, FullName, d.DomainID, d.Weight
            ),
            faculty_totals AS (
                SELECT 
                    UserID,
                    FullName,
                    SUM(WeightedPercentage) AS TotalScore,
                    COUNT(DISTINCT DomainID) AS DomainCount
                FROM faculty_domains
                GROUP BY UserID, FullName
            ),
            faculty_subjects AS (
                SELECT 
                    fl.FacultyID,
                    COUNT(DISTINCT fl.SubjectID) AS SubjectCount,
                    COUNT(DISTINCT es.SubmissionID) AS EvaluationCount
                FROM FacultyLoad fl
                LEFT JOIN EvaluationSubmissions es ON fl.LoadID = es.LoadID"

                If cycleID > 0 Then
                    facultyQuery &= " AND es.CycleID = @CycleID"
                End If

                facultyQuery &= "
                GROUP BY fl.FacultyID
            )
            SELECT 
                ft.UserID AS FacultyID,
                ft.FullName,
                ROUND(ft.TotalScore, 1) AS AvgScore,
                fs.EvaluationCount,
                fs.SubjectCount
            FROM faculty_totals ft
            INNER JOIN faculty_subjects fs ON ft.UserID = fs.FacultyID
            WHERE ft.DomainCount > 0
            ORDER BY ft.TotalScore DESC"

                Using cmd As New MySqlCommand(facultyQuery, conn)
                    cmd.Parameters.AddWithValue("@DepartmentID", departmentID)
                    If cycleID > 0 Then
                        cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    End If

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        While rdr.Read()
                            Dim faculty As New FacultyData() With {
                            .FacultyID = Convert.ToInt32(rdr("FacultyID")),
                            .FullName = rdr("FullName").ToString(),
                            .AvgScore = Convert.ToDecimal(rdr("AvgScore")),
                            .EvaluationCount = Convert.ToInt32(rdr("EvaluationCount")),
                            .SubjectCount = Convert.ToInt32(rdr("SubjectCount"))
                        }
                            facultyData.Add(faculty)
                        End While
                    End Using
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetFacultyData: " & ex.Message)
            facultyData = New List(Of FacultyData)()
        End Try

        Return facultyData
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetCourseDetails(courseID As Integer, cycleID As Integer) As CourseDetailsData
        Dim details As New CourseDetailsData()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()

                ' Get basic course info
                Dim courseQuery As String = "SELECT CourseName FROM Courses WHERE CourseID = @CourseID"
                Using cmd As New MySqlCommand(courseQuery, conn)
                    cmd.Parameters.AddWithValue("@CourseID", courseID)
                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        If rdr.Read() Then
                            details.CourseName = rdr("CourseName").ToString()
                        Else
                            details.CourseName = "Unknown Course"
                        End If
                    End Using
                End Using

                ' Get domain performance
                details.Domains = GetDomainPerformanceForCourse(courseID, cycleID, conn)

                ' Get course statistics with SIMPLIFIED query
                Dim statsQuery As String = "
                SELECT 
                    COUNT(DISTINCT es.SubmissionID) AS EvaluationCount,
                    COUNT(DISTINCT fl.FacultyID) AS FacultyCount,
                    COUNT(DISTINCT fl.ClassID) AS ClassCount,
                    COUNT(DISTINCT s.StudentID) AS StudentCount
                FROM FacultyLoad fl
                LEFT JOIN EvaluationSubmissions es ON fl.LoadID = es.LoadID
                LEFT JOIN Students s ON fl.CourseID = s.CourseID AND s.Status = 'Active'
                WHERE fl.CourseID = @CourseID AND fl.IsDeleted = 0"

                If cycleID > 0 Then
                    statsQuery &= " AND (es.CycleID = @CycleID OR es.CycleID IS NULL)"
                End If

                Using cmd As New MySqlCommand(statsQuery, conn)
                    cmd.Parameters.AddWithValue("@CourseID", courseID)
                    If cycleID > 0 Then
                        cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    End If

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        If rdr.Read() Then
                            details.EvaluationCount = Convert.ToInt32(rdr("EvaluationCount"))
                            details.FacultyCount = Convert.ToInt32(rdr("FacultyCount"))
                            details.ClassCount = Convert.ToInt32(rdr("ClassCount"))
                            details.StudentCount = Convert.ToInt32(rdr("StudentCount"))
                        Else
                            ' Default values if no data
                            details.EvaluationCount = 0
                            details.FacultyCount = 0
                            details.ClassCount = 0
                            details.StudentCount = 0
                        End If
                    End Using
                End Using

                ' Calculate weighted average score
                Dim scoreQuery As String = "
                WITH domain_scores AS (
                    SELECT 
                        es.SubmissionID,
                        d.DomainID,
                        d.Weight,
                        AVG(e.Score) AS DomainAvg,
                        (AVG(e.Score) / 5) * d.Weight AS WeightedPercentage
                    FROM Evaluations e
                    INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
                    INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
                    INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
                    INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
                    WHERE fl.CourseID = @CourseID
                        AND e.Score IS NOT NULL"

                If cycleID > 0 Then
                    scoreQuery &= " AND es.CycleID = @CycleID"
                End If

                scoreQuery &= "
                    GROUP BY es.SubmissionID, d.DomainID, d.Weight
                ),
                submission_totals AS (
                    SELECT 
                        SubmissionID,
                        SUM(WeightedPercentage) AS TotalScore
                    FROM domain_scores
                    GROUP BY SubmissionID
                )
                SELECT ROUND(AVG(TotalScore), 1) AS OverallScore
                FROM submission_totals"

                Using cmd As New MySqlCommand(scoreQuery, conn)
                    cmd.Parameters.AddWithValue("@CourseID", courseID)
                    If cycleID > 0 Then
                        cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    End If

                    Dim result = cmd.ExecuteScalar()
                    details.AvgScore = If(result Is Nothing Or IsDBNull(result), 0, Convert.ToDecimal(result))
                End Using

            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetCourseDetails: " & ex.Message)
            ' Set default values on error
            details.AvgScore = 0
            details.EvaluationCount = 0
            details.FacultyCount = 0
            details.ClassCount = 0
            details.StudentCount = 0
            details.Domains = New List(Of DomainData)()
        End Try

        Return details
    End Function

    Private Shared Function GetDomainPerformanceForCourse(courseID As Integer, cycleID As Integer, conn As MySqlConnection) As List(Of DomainData)
        Dim domains As New List(Of DomainData)()

        Try
            Dim query As String = "
        SELECT 
            d.DomainID, 
            d.DomainName, 
            d.Weight,
            ROUND(AVG(e.Score), 2) AS RawAvg,
            ROUND((AVG(e.Score) / 5) * d.Weight, 1) AS AvgScore
        FROM Evaluations e
        INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
        INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
        INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
        INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
        WHERE fl.CourseID = @CourseID
            AND e.Score IS NOT NULL
            AND e.Score > 0"

            If cycleID > 0 Then
                query &= " AND es.CycleID = @CycleID"
            End If

            query &= " 
        GROUP BY d.DomainID, d.DomainName, d.Weight
        HAVING COUNT(e.Score) > 0
        ORDER BY d.Weight DESC"

            Using cmd As New MySqlCommand(query, conn)
                cmd.Parameters.AddWithValue("@CourseID", courseID)
                If cycleID > 0 Then
                    cmd.Parameters.AddWithValue("@CycleID", cycleID)
                End If

                Using rdr As MySqlDataReader = cmd.ExecuteReader()
                    While rdr.Read()
                        Dim rawAvg As Decimal = If(IsDBNull(rdr("RawAvg")), 0, Convert.ToDecimal(rdr("RawAvg")))
                        Dim avgScore As Decimal = If(IsDBNull(rdr("AvgScore")), 0, Convert.ToDecimal(rdr("AvgScore")))

                        ' Only add domains with valid data
                        If rawAvg > 0 Then
                            domains.Add(New DomainData() With {
                            .DomainID = Convert.ToInt32(rdr("DomainID")),
                            .DomainName = rdr("DomainName").ToString(),
                            .Weight = Convert.ToDecimal(rdr("Weight")),
                            .AvgScore = avgScore,
                            .RawAvg = rawAvg
                        })
                        End If
                    End While
                End Using
            End Using

            ' If no domains found, add a placeholder for debugging
            If domains.Count = 0 Then
                System.Diagnostics.Debug.WriteLine($"No domain data found for course {courseID} and cycle {cycleID}")

                ' Get all domains to show structure (for debugging)
                Dim allDomainsQuery As String = "SELECT DomainID, DomainName, Weight FROM EvaluationDomains WHERE IsActive = 1 ORDER BY Weight DESC"
                Using cmd As New MySqlCommand(allDomainsQuery, conn)
                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        While rdr.Read()
                            domains.Add(New DomainData() With {
                            .DomainID = Convert.ToInt32(rdr("DomainID")),
                            .DomainName = rdr("DomainName").ToString() + " (No Data)",
                            .Weight = Convert.ToDecimal(rdr("Weight")),
                            .AvgScore = 0,
                            .RawAvg = 0
                        })
                        End While
                    End Using
                End Using
            End If

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine($"Error in GetDomainPerformanceForCourse: {ex.Message}")
            domains = New List(Of DomainData)()
        End Try

        Return domains
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetFacultyDetails(facultyID As Integer, cycleID As Integer) As FacultyDetailsData
        Dim details As New FacultyDetailsData()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()

                ' Get REAL domain performance data with weighted calculations
                details.Domains = GetFacultyDomainPerformanceAllSubjects(facultyID, cycleID, conn)

                ' Get REAL questions data with weighted calculations
                details.Questions = GetRealFacultyQuestions(facultyID, cycleID, conn)

                ' Get REAL comments
                details.Comments = GetRealFacultyComments(facultyID, cycleID, conn)

                ' Get REAL subjects
                details.Subjects = GetRealFacultySubjects(facultyID, cycleID, conn)

            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetFacultyDetails: " & ex.Message)
            details.Domains = New List(Of DomainData)()
            details.Questions = New List(Of QuestionData)()
            details.Comments = New List(Of String)()
            details.Subjects = New List(Of SubjectData)()
        End Try

        Return details
    End Function

    ' FIXED: All subjects domain performance with correct raw averages
    Private Shared Function GetFacultyDomainPerformanceAllSubjects(facultyID As Integer, cycleID As Integer, conn As MySqlConnection) As List(Of DomainData)
        Dim domains As New List(Of DomainData)()

        Dim query As String = "
    SELECT 
        d.DomainID, 
        d.DomainName, 
        d.Weight,
        ROUND(AVG(e.Score), 2) AS RawAvg,           -- Actual 1-5 scale average
        ROUND((AVG(e.Score) / 5) * d.Weight, 1) AS AvgScore  -- Weighted percentage
    FROM Evaluations e
    INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
    INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
    INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
    INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
    WHERE fl.FacultyID = @FacultyID 
        AND e.Score IS NOT NULL 
        AND e.Score > 0"

        If cycleID > 0 Then
            query &= " AND es.CycleID = @CycleID"
        End If

        query &= " 
    GROUP BY d.DomainID, d.DomainName, d.Weight
    HAVING AVG(e.Score) > 0
    ORDER BY d.Weight DESC"

        Using cmd As New MySqlCommand(query, conn)
            cmd.Parameters.AddWithValue("@FacultyID", facultyID)
            If cycleID > 0 Then
                cmd.Parameters.AddWithValue("@CycleID", cycleID)
            End If

            Using rdr As MySqlDataReader = cmd.ExecuteReader()
                While rdr.Read()
                    domains.Add(New DomainData() With {
                    .DomainID = Convert.ToInt32(rdr("DomainID")),
                    .DomainName = rdr("DomainName").ToString(),
                    .Weight = Convert.ToDecimal(rdr("Weight")),
                    .AvgScore = Convert.ToDecimal(rdr("AvgScore")),
                    .RawAvg = Convert.ToDecimal(rdr("RawAvg"))  ' Include raw average
                })
                End While
            End Using
        End Using

        Return domains
    End Function

    Private Shared Function GetRealFacultyQuestions(facultyID As Integer, cycleID As Integer, conn As MySqlConnection) As List(Of QuestionData)
        Dim questions As New List(Of QuestionData)()

        Dim query As String = "
    SELECT 
        q.QuestionText, 
        d.DomainName,
        d.DomainID,
        ROUND(AVG(e.Score), 2) AS RawAvg,
        ROUND((AVG(e.Score) / 5) * 100, 1) AS AvgScore
    FROM Evaluations e
    INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
    INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
    INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
    INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
    WHERE fl.FacultyID = @FacultyID 
        AND e.Score IS NOT NULL 
        AND e.Score > 0"

        If cycleID > 0 Then
            query &= " AND es.CycleID = @CycleID"
        End If

        query &= " 
    GROUP BY q.QuestionID, q.QuestionText, d.DomainName, d.DomainID
    HAVING AVG(e.Score) > 0
    ORDER BY d.DomainName, AVG(e.Score) DESC"

        Using cmd As New MySqlCommand(query, conn)
            cmd.Parameters.AddWithValue("@FacultyID", facultyID)
            If cycleID > 0 Then
                cmd.Parameters.AddWithValue("@CycleID", cycleID)
            End If

            Using rdr As MySqlDataReader = cmd.ExecuteReader()
                While rdr.Read()
                    questions.Add(New QuestionData() With {
                    .QuestionText = rdr("QuestionText").ToString(),
                    .DomainName = rdr("DomainName").ToString(),
                    .DomainID = Convert.ToInt32(rdr("DomainID")),
                    .AvgScore = Convert.ToDecimal(rdr("AvgScore"))
                })
                End While
            End Using
        End Using

        Return questions
    End Function

    Private Shared Function GetRealFacultyComments(facultyID As Integer, cycleID As Integer, conn As MySqlConnection) As List(Of String)
        Dim comments As New List(Of String)()

        ' Get categorized student comments from evaluation submissions
        Dim query As String = "SELECT 
                          es.Strengths,
                          es.Weaknesses, 
                          es.AdditionalMessage,
                          es.SubmissionDate
                      FROM EvaluationSubmissions es
                      INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
                      WHERE fl.FacultyID = @FacultyID 
                        AND (es.Strengths IS NOT NULL OR es.Weaknesses IS NOT NULL OR es.AdditionalMessage IS NOT NULL)
                        AND (es.Strengths <> '' OR es.Weaknesses <> '' OR es.AdditionalMessage <> '')"

        If cycleID > 0 Then
            query &= " AND es.CycleID = @CycleID"
        End If

        query &= " ORDER BY es.SubmissionDate DESC"

        Using cmd As New MySqlCommand(query, conn)
            cmd.Parameters.AddWithValue("@FacultyID", facultyID)
            If cycleID > 0 Then
                cmd.Parameters.AddWithValue("@CycleID", cycleID)
            End If

            Using rdr As MySqlDataReader = cmd.ExecuteReader()
                While rdr.Read()
                    ' Add strengths if available
                    If Not IsDBNull(rdr("Strengths")) AndAlso Not String.IsNullOrWhiteSpace(rdr("Strengths").ToString()) Then
                        comments.Add("STRENGTHS: " & rdr("Strengths").ToString().Trim())
                    End If

                    ' Add weaknesses if available
                    If Not IsDBNull(rdr("Weaknesses")) AndAlso Not String.IsNullOrWhiteSpace(rdr("Weaknesses").ToString()) Then
                        comments.Add("AREAS FOR IMPROVEMENT: " & rdr("Weaknesses").ToString().Trim())
                    End If

                    ' Add additional messages if available
                    If Not IsDBNull(rdr("AdditionalMessage")) AndAlso Not String.IsNullOrWhiteSpace(rdr("AdditionalMessage").ToString()) Then
                        comments.Add("ADDITIONAL COMMENTS: " & rdr("AdditionalMessage").ToString().Trim())
                    End If
                End While
            End Using
        End Using

        Return comments
    End Function


    Private Shared Function GetRealFacultySubjects(facultyID As Integer, cycleID As Integer, conn As MySqlConnection) As List(Of SubjectData)
        Dim subjects As New List(Of SubjectData)()

        ' Get actual subjects taught by this faculty with evaluation data
        Dim query As String = "SELECT DISTINCT s.SubjectID, s.SubjectCode, s.SubjectName,
                          COUNT(DISTINCT es.SubmissionID) AS EvaluationCount
                          FROM Subjects s
                          INNER JOIN FacultyLoad fl ON s.SubjectID = fl.SubjectID
                          LEFT JOIN EvaluationSubmissions es ON fl.LoadID = es.LoadID
                          WHERE fl.FacultyID = @FacultyID 
                            AND s.IsActive = 1
                             AND fl.IsDeleted =0"

        If cycleID > 0 Then
            query &= " AND (es.CycleID = @CycleID OR es.CycleID IS NULL)"
        End If

        query &= " GROUP BY s.SubjectID, s.SubjectCode, s.SubjectName
              ORDER BY s.SubjectName"

        Using cmd As New MySqlCommand(query, conn)
            cmd.Parameters.AddWithValue("@FacultyID", facultyID)
            If cycleID > 0 Then
                cmd.Parameters.AddWithValue("@CycleID", cycleID)
            End If

            Using rdr As MySqlDataReader = cmd.ExecuteReader()
                While rdr.Read()
                    subjects.Add(New SubjectData() With {
                    .SubjectID = Convert.ToInt32(rdr("SubjectID")),
                    .SubjectCode = rdr("SubjectCode").ToString(),
                    .SubjectName = rdr("SubjectName").ToString(),
                    .EvaluationCount = Convert.ToInt32(rdr("EvaluationCount"))
                })
                End While
            End Using
        End Using

        Return subjects
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetCourseComparisonData(departmentID As Integer, cycleID As Integer) As List(Of CourseDomainData)
        Dim courseComparison As New List(Of CourseDomainData)()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()

                ' FIXED: Get course domain data with weighted scores
                Dim courseQuery As String = "
            SELECT 
                c.CourseID, 
                c.CourseName,
                d.DomainID,
                d.DomainName,
                d.Weight,
                ROUND((AVG(e.Score) / 5) * d.Weight, 1) AS WeightedScore
            FROM Courses c
            INNER JOIN FacultyLoad fl ON c.CourseID = fl.CourseID
            INNER JOIN EvaluationSubmissions es ON fl.LoadID = es.LoadID
            INNER JOIN Evaluations e ON es.SubmissionID = e.SubmissionID
            INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
            INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
            WHERE c.DepartmentID = @DepartmentID 
                AND c.IsActive = 1
                AND e.Score IS NOT NULL
                AND e.Score > 0"

                If cycleID > 0 Then
                    courseQuery &= " AND es.CycleID = @CycleID"
                End If

                courseQuery &= "
            GROUP BY c.CourseID, c.CourseName, d.DomainID, d.DomainName, d.Weight
            HAVING AVG(e.Score) > 0
            ORDER BY c.CourseName, d.DomainName"

                Using cmd As New MySqlCommand(courseQuery, conn)
                    cmd.Parameters.AddWithValue("@DepartmentID", departmentID)
                    If cycleID > 0 Then
                        cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    End If

                    Dim courseDomainDict As New Dictionary(Of Integer, CourseDomainData)()

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        While rdr.Read()
                            Dim courseID = Convert.ToInt32(rdr("CourseID"))
                            Dim courseName = rdr("CourseName").ToString()
                            Dim domainName = rdr("DomainName").ToString()
                            Dim weight = Convert.ToDecimal(rdr("Weight"))
                            Dim weightedScore = Convert.ToDecimal(rdr("WeightedScore"))

                            If Not courseDomainDict.ContainsKey(courseID) Then
                                courseDomainDict(courseID) = New CourseDomainData() With {
                                .CourseID = courseID,
                                .CourseName = courseName,
                                .Domains = New List(Of DomainComparisonData)()
                            }
                            End If

                            courseDomainDict(courseID).Domains.Add(New DomainComparisonData() With {
                            .DomainName = domainName,
                            .Score = weightedScore,
                            .Weight = weight
                        })
                        End While
                    End Using

                    courseComparison = courseDomainDict.Values.ToList()

                    ' Only include courses that have domain data
                    courseComparison = courseComparison.Where(Function(c) c.Domains.Count > 0).ToList()

                    ' Sort by overall weighted average
                    courseComparison = courseComparison.OrderByDescending(Function(c)
                                                                              If c.Domains.Count > 0 Then
                                                                                  Return c.Domains.Sum(Function(d) d.Score)
                                                                              Else
                                                                                  Return 0
                                                                              End If
                                                                          End Function).ToList()

                    Console.WriteLine($"Found {courseComparison.Count} courses with domain data for radar chart")
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetCourseComparisonData: " & ex.Message)
            courseComparison = New List(Of CourseDomainData)()
        End Try

        Return courseComparison
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetFacultySubjectDetails(facultyID As Integer, subjectID As Integer, cycleID As Integer) As FacultyDetailsData
        Dim details As New FacultyDetailsData()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()

                ' Get domain performance for specific subject with CORRECT calculations
                details.Domains = GetFacultyDomainPerformanceForSubject(facultyID, subjectID, cycleID, conn)

                ' Get questions for specific subject
                details.Questions = GetFacultyQuestionsForSubject(facultyID, subjectID, cycleID, conn)

                ' Get comments for specific subject
                details.Comments = GetFacultyCommentsForSubject(facultyID, subjectID, cycleID, conn)

                ' Get all subjects (for sidebar)
                details.Subjects = GetRealFacultySubjects(facultyID, cycleID, conn)

            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetFacultySubjectDetails: " & ex.Message)
            details.Domains = New List(Of DomainData)()
            details.Questions = New List(Of QuestionData)()
            details.Comments = New List(Of String)()
            details.Subjects = New List(Of SubjectData)()
        End Try

        Return details
    End Function

    Private Shared Function GetFacultyDomainPerformanceForSubject(facultyID As Integer, subjectID As Integer, cycleID As Integer, conn As MySqlConnection) As List(Of DomainData)
        Dim domains As New List(Of DomainData)()

        Dim query As String = "
    SELECT 
        d.DomainID, 
        d.DomainName, 
        d.Weight,
        ROUND(AVG(e.Score), 2) AS RawAvg,           -- Actual 1-5 scale average
        ROUND((AVG(e.Score) / 5) * d.Weight, 1) AS AvgScore  -- Weighted percentage
    FROM Evaluations e
    INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
    INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
    INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
    INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
    WHERE fl.FacultyID = @FacultyID 
        AND fl.SubjectID = @SubjectID
        AND e.Score IS NOT NULL 
        AND e.Score > 0"

        If cycleID > 0 Then
            query &= " AND es.CycleID = @CycleID"
        End If

        query &= " 
    GROUP BY d.DomainID, d.DomainName, d.Weight
    HAVING AVG(e.Score) > 0
    ORDER BY d.Weight DESC"

        Using cmd As New MySqlCommand(query, conn)
            cmd.Parameters.AddWithValue("@FacultyID", facultyID)
            cmd.Parameters.AddWithValue("@SubjectID", subjectID)
            If cycleID > 0 Then
                cmd.Parameters.AddWithValue("@CycleID", cycleID)
            End If

            Using rdr As MySqlDataReader = cmd.ExecuteReader()
                While rdr.Read()
                    domains.Add(New DomainData() With {
                    .DomainID = Convert.ToInt32(rdr("DomainID")),
                    .DomainName = rdr("DomainName").ToString(),
                    .Weight = Convert.ToDecimal(rdr("Weight")),
                    .AvgScore = Convert.ToDecimal(rdr("AvgScore")),
                    .RawAvg = Convert.ToDecimal(rdr("RawAvg"))
                })
                End While
            End Using
        End Using

        Return domains
    End Function

    Private Shared Function GetFacultyQuestionsForSubject(facultyID As Integer, subjectID As Integer, cycleID As Integer, conn As MySqlConnection) As List(Of QuestionData)
        Dim questions As New List(Of QuestionData)()

        Dim query As String = "
    SELECT 
        q.QuestionText, 
        d.DomainName,
        d.DomainID,
        ROUND(AVG(e.Score), 2) AS RawAvg,
        ROUND((AVG(e.Score) / 5) * 100, 1) AS AvgScore  -- Convert to percentage for questions
    FROM Evaluations e
    INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
    INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
    INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
    INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
    WHERE fl.FacultyID = @FacultyID 
        AND fl.SubjectID = @SubjectID
        AND e.Score IS NOT NULL 
        AND e.Score > 0"

        If cycleID > 0 Then
            query &= " AND es.CycleID = @CycleID"
        End If

        query &= " 
    GROUP BY q.QuestionID, q.QuestionText, d.DomainName, d.DomainID
    HAVING AVG(e.Score) > 0
    ORDER BY d.DomainName, AVG(e.Score) DESC"

        Using cmd As New MySqlCommand(query, conn)
            cmd.Parameters.AddWithValue("@FacultyID", facultyID)
            cmd.Parameters.AddWithValue("@SubjectID", subjectID)
            If cycleID > 0 Then
                cmd.Parameters.AddWithValue("@CycleID", cycleID)
            End If

            Using rdr As MySqlDataReader = cmd.ExecuteReader()
                While rdr.Read()
                    questions.Add(New QuestionData() With {
                    .QuestionText = rdr("QuestionText").ToString(),
                    .DomainName = rdr("DomainName").ToString(),
                    .DomainID = Convert.ToInt32(rdr("DomainID")),
                    .AvgScore = Convert.ToDecimal(rdr("AvgScore"))
                })
                End While
            End Using
        End Using

        Return questions
    End Function

    Private Shared Function GetFacultyCommentsForSubject(facultyID As Integer, subjectID As Integer, cycleID As Integer, conn As MySqlConnection) As List(Of String)
        Dim comments As New List(Of String)()

        Dim query As String = "SELECT 
                          es.Strengths,
                          es.Weaknesses, 
                          es.AdditionalMessage,
                          es.SubmissionDate
                      FROM EvaluationSubmissions es
                      INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
                      WHERE fl.FacultyID = @FacultyID 
                        AND fl.SubjectID = @SubjectID
                        AND (es.Strengths IS NOT NULL OR es.Weaknesses IS NOT NULL OR es.AdditionalMessage IS NOT NULL)
                        AND (es.Strengths <> '' OR es.Weaknesses <> '' OR es.AdditionalMessage <> '')"

        If cycleID > 0 Then
            query &= " AND es.CycleID = @CycleID"
        End If

        query &= " ORDER BY es.SubmissionDate DESC"

        Using cmd As New MySqlCommand(query, conn)
            cmd.Parameters.AddWithValue("@FacultyID", facultyID)
            cmd.Parameters.AddWithValue("@SubjectID", subjectID)
            If cycleID > 0 Then
                cmd.Parameters.AddWithValue("@CycleID", cycleID)
            End If

            Using rdr As MySqlDataReader = cmd.ExecuteReader()
                While rdr.Read()
                    ' Add strengths if available
                    If Not IsDBNull(rdr("Strengths")) AndAlso Not String.IsNullOrWhiteSpace(rdr("Strengths").ToString()) Then
                        comments.Add("STRENGTHS: " & rdr("Strengths").ToString().Trim())
                    End If

                    ' Add weaknesses if available
                    If Not IsDBNull(rdr("Weaknesses")) AndAlso Not String.IsNullOrWhiteSpace(rdr("Weaknesses").ToString()) Then
                        comments.Add("AREAS FOR IMPROVEMENT: " & rdr("Weaknesses").ToString().Trim())
                    End If

                    ' Add additional messages if available
                    If Not IsDBNull(rdr("AdditionalMessage")) AndAlso Not String.IsNullOrWhiteSpace(rdr("AdditionalMessage").ToString()) Then
                        comments.Add("ADDITIONAL COMMENTS: " & rdr("AdditionalMessage").ToString().Trim())
                    End If
                End While
            End Using
        End Using

        Return comments
    End Function
End Class

