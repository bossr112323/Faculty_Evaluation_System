Imports System.Configuration
Imports MySql.Data.MySqlClient
Imports System.Data
Imports System.Collections.Generic
Imports System.Web.Services
Imports System.Web.Script.Serialization
Imports System.Web.Script.Services

Public Class FacultyResult
    Inherits System.Web.UI.Page

    ' Your existing class definitions remain the same
    Public Class DomainData
        Public Property DomainName As String
        Public Property AvgScore As Decimal
        Public Property Weight As Decimal
    End Class

    Public Class QuestionData
        Public Property DomainName As String
        Public Property QuestionText As String
        Public Property AverageScore As Decimal
    End Class

    Public Class SubjectDetails
        Public Property Domains As List(Of DomainData)
        Public Property Questions As List(Of QuestionData)
        Public Property Comments As List(Of CommentGroup) ' Changed from List(Of String)
    End Class

    Public Class FacultyOverview
        Public Property OverallScore As Decimal
        Public Property Domains As List(Of DomainData)
    End Class

    Public Class EvaluationStatus
        Public Property SubjectsEvaluated As Integer
        Public Property TotalSubjects As Integer
        Public Property CurrentCycleScore As Decimal
        Public Property Trend As Decimal
        Public Property ResponseRate As Decimal
    End Class

    Public Class SubjectItem
        Public Property LoadID As Integer
        Public Property LoadIDs As String
        Public Property SubjectName As String
        Public Property SubjectCode As String
        Public Property Term As String
        Public Property OverallScore As Decimal
        Public Property CycleName As String
        Public Property CycleID As Integer
        Public Property StartDate As String
        Public Property EndDate As String
        Public Property EvaluationCount As Integer
        Public Property ClassCount As Integer
    End Class

    Public Class CycleGroup
        Public Property CycleID As Integer
        Public Property Term As String
        Public Property CycleName As String
        Public Property StartDate As String
        Public Property EndDate As String
        Public Property Subjects As List(Of SubjectItem)
        Public Property AverageScore As Decimal
        Public Property IsActive As Boolean
    End Class

    Public Class AutoCompleteItem
        Public Property ID As Integer
        Public Property Name As String
        Public Property StartDate As String
        Public Property EndDate As String
        Public Property TermName As String
        Public Property CycleName As String
        Public Property IsLatest As Boolean
    End Class

    Public Class SubjectAutoCompleteItem
        Public Property ID As Integer
        Public Property Name As String
        Public Property Code As String
        Public Property Term As String
        Public Property CycleName As String
    End Class
    Public Class CommentGroup
        Public Property CommentType As String
        Public Property Comments As List(Of CommentData)
        Public Property TotalCount As Integer
    End Class

    Public Class CommentData
        Public Property CommentText As String
    End Class
    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Session("Role") Is Nothing OrElse Not Session("Role").ToString().Equals("Faculty", StringComparison.OrdinalIgnoreCase) Then
            Response.Redirect("Login.aspx", False)
            Context.ApplicationInstance.CompleteRequest()
            Return
        End If

        If Not IsPostBack Then
            LoadFacultyInfo()
            SetDefaultCycle()
            LoadSubjectList(Convert.ToInt32(hdnCycleID.Value), "")

            ' Register startup script to initialize autocomplete
            Page.ClientScript.RegisterStartupScript(Me.GetType(), "InitAutocomplete",
            "setTimeout(function() { initializeAutocomplete(); }, 100);", True)
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

    Private Sub SetDefaultCycle()
        Dim latestCycle = GetLatestCycle()
        If latestCycle IsNot Nothing Then
            hdnCycleID.Value = latestCycle.ID.ToString()
            txtCycle.Text = latestCycle.Name
        Else
            hdnCycleID.Value = "0"
            txtCycle.Text = ""
        End If
    End Sub

    Private Function GetLatestCycle() As AutoCompleteItem
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim query As String = "SELECT CycleID, Term, StartDate, EndDate, CycleName 
                      FROM EvaluationCycles 
                      WHERE Status IN ('Active', 'Inactive')
                      ORDER BY EndDate DESC, StartDate DESC 
                      LIMIT 1"

            Using cmd As New MySqlCommand(query, conn)
                Using rdr As MySqlDataReader = cmd.ExecuteReader()
                    If rdr.Read() Then
                        Dim startDateValue As DateTime = GetSafeDateTime(rdr, "StartDate")
                        Dim endDateValue As DateTime = GetSafeDateTime(rdr, "EndDate")

                        Return New AutoCompleteItem() With {
                        .ID = GetSafeInt32(rdr, "CycleID"),
                        .TermName = GetSafeString(rdr, "Term"),
                        .CycleName = GetSafeString(rdr, "CycleName"),
                        .StartDate = If(startDateValue = DateTime.MinValue, "N/A", startDateValue.ToString("yyyy-MM-dd")),
                        .EndDate = If(endDateValue = DateTime.MinValue, "N/A", endDateValue.ToString("yyyy-MM-dd")),
                        .Name = $"{GetSafeString(rdr, "Term")} - {GetSafeString(rdr, "CycleName", "Current")}",
                        .IsLatest = True
                    }
                    End If
                End Using
            End Using
        End Using
        Return Nothing
    End Function

    Private Sub LoadSubjectList(Optional selectedCycleID As Integer = 0, Optional searchText As String = "")
        Dim subjects As New List(Of SubjectItem)()
        Dim cycleToUse As Integer = selectedCycleID
        If cycleToUse = 0 Then
            cycleToUse = Convert.ToInt32(hdnCycleID.Value)
        End If

        ' If no cycle selected, don't load any subjects
        If cycleToUse = 0 Then
            subjectList.InnerHtml = "<div class='text-center p-4 text-muted'><i class='bi bi-funnel display-4'></i><div class='mt-2'>Please select an evaluation cycle</div></div>"
            Return
        End If

        ' Modified query to group by subject name, code, and term
        Dim query As String = "SELECT 
        s.SubjectName,
        s.SubjectCode,
        ec.Term,
        ec.CycleName,
        ec.CycleID,
        GROUP_CONCAT(DISTINCT fl.LoadID) AS LoadIDs,
        COUNT(DISTINCT es.SubmissionID) AS EvaluationCount,
        COUNT(DISTINCT fl.ClassID) AS ClassCount
      FROM FacultyLoad fl
      INNER JOIN Subjects s ON fl.SubjectID = s.SubjectID
      INNER JOIN EvaluationSubmissions es ON fl.LoadID = es.LoadID
      INNER JOIN EvaluationCycles ec ON es.CycleID = ec.CycleID
      WHERE fl.FacultyID = @fid 
        AND fl.IsDeleted = 0 
        AND es.CycleID = @cycleID
         AND es.IsReleased = 2"

        Dim conditions As New List(Of String)()

        If Not String.IsNullOrEmpty(searchText) Then
            conditions.Add("(s.SubjectName LIKE @searchText OR s.SubjectCode LIKE @searchText)")
        End If

        If conditions.Count > 0 Then
            query &= " AND " & String.Join(" AND ", conditions)
        End If

        query &= " GROUP BY s.SubjectName, s.SubjectCode, ec.Term, ec.CycleName, ec.CycleID"
        query &= " HAVING COUNT(DISTINCT es.SubmissionID) > 0"
        query &= " ORDER BY s.SubjectName"

        Using conn As New MySqlConnection(ConnString)
            Using cmd As New MySqlCommand(query, conn)
                cmd.Parameters.AddWithValue("@fid", Session("UserID"))
                cmd.Parameters.AddWithValue("@cycleID", cycleToUse)

                If Not String.IsNullOrEmpty(searchText) Then
                    cmd.Parameters.AddWithValue("@searchText", "%" & searchText & "%")
                End If

                conn.Open()

                Using rdr As MySqlDataReader = cmd.ExecuteReader()
                    Dim recordCount As Integer = 0
                    While rdr.Read()
                        recordCount += 1
                        Dim loadIDs As String = GetSafeString(rdr, "LoadIDs")
                        Dim cycleID As Integer = GetSafeInt32(rdr, "CycleID")
                        Dim classCount As Integer = GetSafeInt32(rdr, "ClassCount")

                        ' Calculate combined weighted score for all LoadIDs
                        Dim overallScore = CalculateCombinedSubjectWeightedScore(loadIDs, cycleID)

                        ' Create a combined subject item
                        Dim subjectItem As New SubjectItem() With {
                        .LoadID = 0, ' Use 0 to indicate combined subject
                        .SubjectName = GetSafeString(rdr, "SubjectName"),
                        .SubjectCode = GetSafeString(rdr, "SubjectCode"),
                        .Term = GetSafeString(rdr, "Term"),
                        .CycleName = GetSafeString(rdr, "CycleName"),
                        .CycleID = cycleID,
                        .OverallScore = overallScore,
                        .EvaluationCount = GetSafeInt32(rdr, "EvaluationCount")
                    }

                        ' Store LoadIDs for later use
                        subjectItem.LoadIDs = loadIDs
                        subjectItem.ClassCount = classCount

                        subjects.Add(subjectItem)
                    End While

                    System.Diagnostics.Debug.WriteLine($"Found {recordCount} evaluated subjects")
                End Using
            End Using
        End Using

        BuildSubjectListHTML(subjects)
    End Sub
    Private Function CalculateCombinedSubjectWeightedScore(loadIDs As String, cycleID As Integer) As Decimal
        Dim score As Decimal = 0
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        If String.IsNullOrEmpty(loadIDs) Then Return 0

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()


                Dim loadIDList = loadIDs.Split(","c)
                Dim parameters = loadIDList.Select(Function(id, index) "@LoadID" & index).ToArray()
                Dim parameterPlaceholders = String.Join(",", parameters)

                Dim scoreQuery As String = $"
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
        WHERE fl.LoadID IN ({parameterPlaceholders})
        AND e.IsReleased = 2 AND es.IsReleased = 2"

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
                    ' Add LoadID parameters
                    For i As Integer = 0 To loadIDList.Length - 1
                        cmd.Parameters.AddWithValue("@LoadID" & i, loadIDList(i).Trim())
                    Next

                    If cycleID > 0 Then
                        cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    End If

                    Dim result = cmd.ExecuteScalar()
                    If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                        score = Convert.ToDecimal(result)
                    End If
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in CalculateCombinedSubjectWeightedScore: " & ex.Message)
        End Try

        Return score
    End Function


    Private Function GetSafeInt32(rdr As MySqlDataReader, columnName As String, Optional defaultValue As Integer = 0) As Integer
        Try
            Dim ordinal As Integer = rdr.GetOrdinal(columnName)
            If rdr.IsDBNull(ordinal) Then
                Return defaultValue
            Else
                Return Convert.ToInt32(rdr(columnName))
            End If
        Catch ex As Exception
            Return defaultValue
        End Try
    End Function

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

    Private Function GetSafeDecimal(rdr As MySqlDataReader, columnName As String, Optional defaultValue As Decimal = 0) As Decimal
        Try
            Dim ordinal As Integer = rdr.GetOrdinal(columnName)
            If rdr.IsDBNull(ordinal) Then
                Return defaultValue
            Else
                Return Convert.ToDecimal(rdr(columnName))
            End If
        Catch ex As Exception
            Return defaultValue
        End Try
    End Function

    Private Function GetSafeDateTime(rdr As MySqlDataReader, columnName As String, Optional defaultValue As DateTime = Nothing) As DateTime
        Try
            Dim ordinal As Integer = rdr.GetOrdinal(columnName)
            If rdr.IsDBNull(ordinal) Then
                Return If(defaultValue = Nothing, DateTime.MinValue, defaultValue)
            Else
                Return Convert.ToDateTime(rdr(columnName))
            End If
        Catch ex As Exception
            Return If(defaultValue = Nothing, DateTime.MinValue, defaultValue)
        End Try
    End Function


    Private Shared Function GetSafeInt32Shared(rdr As MySqlDataReader, columnName As String, Optional defaultValue As Integer = 0) As Integer
        Try
            Dim ordinal As Integer = rdr.GetOrdinal(columnName)
            If rdr.IsDBNull(ordinal) Then
                Return defaultValue
            Else
                Return Convert.ToInt32(rdr(columnName))
            End If
        Catch ex As Exception
            Return defaultValue
        End Try
    End Function

    Private Shared Function GetSafeStringShared(rdr As MySqlDataReader, columnName As String, Optional defaultValue As String = "") As String
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

    Private Shared Function GetSafeDecimalShared(rdr As MySqlDataReader, columnName As String, Optional defaultValue As Decimal = 0) As Decimal
        Try
            Dim ordinal As Integer = rdr.GetOrdinal(columnName)
            If rdr.IsDBNull(ordinal) Then
                Return defaultValue
            Else
                Return Convert.ToDecimal(rdr(columnName))
            End If
        Catch ex As Exception
            Return defaultValue
        End Try
    End Function

    Private Shared Function GetSafeDateTimeShared(rdr As MySqlDataReader, columnName As String, Optional defaultValue As DateTime = Nothing) As DateTime
        Try
            Dim ordinal As Integer = rdr.GetOrdinal(columnName)
            If rdr.IsDBNull(ordinal) Then
                Return If(defaultValue = Nothing, DateTime.MinValue, defaultValue)
            Else
                Return Convert.ToDateTime(rdr(columnName))
            End If
        Catch ex As Exception
            Return If(defaultValue = Nothing, DateTime.MinValue, defaultValue)
        End Try
    End Function

    Private Function CalculateSubjectWeightedScore(loadID As Integer, cycleID As Integer) As Decimal
        Dim score As Decimal = 0
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()

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
            WHERE fl.LoadID = @LoadID
            AND e.IsReleased = 2 AND es.IsReleased = 2"
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
                    cmd.Parameters.AddWithValue("@LoadID", loadID)
                    If cycleID > 0 Then
                        cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    End If

                    Dim result = cmd.ExecuteScalar()
                    If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                        score = Convert.ToDecimal(result)
                    End If
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in CalculateSubjectWeightedScore: " & ex.Message)
        End Try

        Return score
    End Function

    Private Sub BuildSubjectListHTML(subjects As List(Of SubjectItem))
        Dim html As New StringBuilder()

        ' Add Overview item
        html.AppendLine("<div class='subject-item active' onclick='showFacultyOverview()'>")
        html.AppendLine("    <div class='subject-name'><i class='bi bi-person-badge me-2 text-primary'></i>Overview</div>")
        html.AppendLine("</div>")

        If subjects.Count > 0 Then
            For Each subject In subjects
                Dim scoreDisplay As String = If(subject.EvaluationCount > 0, subject.OverallScore.ToString("0.0") & "%", "No Data")
                Dim scoreClass As String = If(subject.EvaluationCount > 0, "text-primary", "text-muted")
                Dim classInfo As String = If(subject.ClassCount > 1, $" ({subject.ClassCount} classes)", "")

                html.AppendLine("<div class='subject-item' onclick='selectCombinedSubject(""" & EscapeJavaScriptString(subject.LoadIDs) & """, """ & EscapeJavaScriptString(subject.SubjectName) & """, """ & EscapeJavaScriptString(subject.SubjectCode) & """, """ & EscapeJavaScriptString(subject.Term) & """, " & subject.OverallScore & ", """ & EscapeJavaScriptString(subject.CycleName) & """, " & subject.CycleID & ", " & subject.ClassCount & ")'>")
                html.AppendLine("    <div class='d-flex justify-content-between align-items-center'>")
                html.AppendLine("        <div class='subject-info'>")
                html.AppendLine("            <div class='subject-name small'>" & subject.SubjectName & classInfo & "</div>")
                html.AppendLine("            <div class='subject-code x-small text-muted'>" & subject.SubjectCode & " • " & subject.Term & "</div>")
                html.AppendLine("        </div>")
                html.AppendLine("        <div class='subject-score small fw-bold " & scoreClass & "'>" & scoreDisplay & "</div>")
                html.AppendLine("    </div>")
                html.AppendLine("</div>")
            Next
        Else
            html.AppendLine("<div class='text-center p-3 text-muted'>")
            html.AppendLine("    <i class='bi bi-journal-x'></i>")
            html.AppendLine("    <div class='mt-1 small'>No subjects found</div>")
            html.AppendLine("</div>")
        End If

        subjectList.InnerHtml = html.ToString()
    End Sub

    Private Function EscapeJavaScriptString(input As String) As String
        If String.IsNullOrEmpty(input) Then Return ""
        Return input.Replace("""", "\""").Replace("'", "\'").Replace(vbCrLf, "\n").Replace(vbCr, "\r").Replace(vbLf, "\n")
    End Function

    Protected Sub btnFilter_Click(sender As Object, e As EventArgs)
        ApplyFilters()
    End Sub

    Protected Sub txtSubjectSearch_TextChanged(sender As Object, e As EventArgs)
        ApplyFilters()
    End Sub

    Private Sub ApplyFilters()
        Dim cycleID As Integer = Convert.ToInt32(hdnCycleID.Value)
        Dim searchText As String = txtSubjectSearch.Text.Trim()

        ' If no cycle selected, don't load any subjects (avoid combined averages)
        If cycleID = 0 Then
            subjectList.InnerHtml = "<div class='text-center p-4 text-muted'><i class='bi bi-funnel display-4'></i><div class='mt-2'>Please select an evaluation cycle</div></div>"

            ' Clear the overview data since no cycle is selected
            Page.ClientScript.RegisterStartupScript(Me.GetType(), "ClearOverview",
        "$('#facultyOverallScore').text('0%'); $('#facultyScoreDisplay').text('0.0%'); $('#currentCycleScore').text('0%');", True)
            Return
        End If

        LoadSubjectList(cycleID, searchText)

        ' Reload the overview and status with the current cycle
        Page.ClientScript.RegisterStartupScript(Me.GetType(), "ReloadData",
    "loadFacultyOverview(); loadEvaluationStatus();", True)
    End Sub

    <WebMethod()>
    Public Shared Function GetSubjectDetails(loadIDs As String, cycleID As Integer) As SubjectDetails
        Dim details As New SubjectDetails()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        If String.IsNullOrEmpty(loadIDs) Then
            Return details
        End If

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()

                ' Split the comma-separated LoadIDs and create parameter placeholders
                Dim loadIDList = loadIDs.Split(","c)
                Dim parameters = loadIDList.Select(Function(id, index) "@LoadID" & index).ToArray()
                Dim parameterPlaceholders = String.Join(",", parameters)

                ' Domain Scores for combined subjects
                Dim domainQuery As String = $"
    SELECT 
        d.DomainName, 
        d.Weight,
        ROUND(AVG(e.Score), 2) AS RawAvg,
        ROUND((AVG(e.Score) / 5) * d.Weight, 1) AS AvgScore
    FROM Evaluations e
    INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
    INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
    INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
    INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
    WHERE fl.LoadID IN ({parameterPlaceholders}) AND fl.IsDeleted = 0
                 AND e.IsReleased = 2 AND es.IsReleased = 2"

                If cycleID > 0 Then
                    domainQuery &= " AND es.CycleID = @CycleID"
                End If

                domainQuery &= "
    GROUP BY d.DomainID, d.DomainName, d.Weight
    HAVING AVG(e.Score) > 0
    ORDER BY d.Weight DESC"

                Using cmd As New MySqlCommand(domainQuery, conn)
                    ' Add LoadID parameters
                    For i As Integer = 0 To loadIDList.Length - 1
                        cmd.Parameters.AddWithValue("@LoadID" & i, loadIDList(i).Trim())
                    Next

                    If cycleID > 0 Then
                        cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    End If

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        details.Domains = New List(Of DomainData)()
                        While rdr.Read()
                            details.Domains.Add(New DomainData() With {
                            .DomainName = GetSafeStringShared(rdr, "DomainName"),
                            .Weight = GetSafeDecimalShared(rdr, "Weight"),
                            .AvgScore = GetSafeDecimalShared(rdr, "AvgScore")
                        })
                        End While
                    End Using
                End Using

                ' Question Scores for combined subjects
                Dim questionQuery As String = $"
    SELECT 
        d.DomainName, 
        q.QuestionText,
        ROUND(AVG(e.Score), 2) AS AverageScore
    FROM Evaluations e
    INNER JOIN EvaluationSubmissions es ON e.SubmissionID = es.SubmissionID
    INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
    INNER JOIN EvaluationQuestions q ON e.QuestionID = q.QuestionID
    INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
    WHERE fl.LoadID IN ({parameterPlaceholders}) AND fl.IsDeleted = 0
                 AND e.IsReleased = 2 AND es.IsReleased = 2"
                If cycleID > 0 Then
                    questionQuery &= " AND es.CycleID = @CycleID"
                End If

                questionQuery &= "
    GROUP BY d.DomainName, q.QuestionID, q.QuestionText
    ORDER BY d.DomainName, q.QuestionID"

                Using cmd As New MySqlCommand(questionQuery, conn)
                    ' Add LoadID parameters
                    For i As Integer = 0 To loadIDList.Length - 1
                        cmd.Parameters.AddWithValue("@LoadID" & i, loadIDList(i).Trim())
                    Next

                    If cycleID > 0 Then
                        cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    End If

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        details.Questions = New List(Of QuestionData)()
                        While rdr.Read()
                            Dim avgScore As Decimal = GetSafeDecimalShared(rdr, "AverageScore")
                            If avgScore >= 1 AndAlso avgScore <= 5 Then
                                details.Questions.Add(New QuestionData() With {
                                .DomainName = GetSafeStringShared(rdr, "DomainName"),
                                .QuestionText = GetSafeStringShared(rdr, "QuestionText"),
                                .AverageScore = avgScore
                            })
                            End If
                        End While
                    End Using
                End Using

                ' Comments for combined subjects
                details.Comments = GetCombinedSubjectComments(conn, loadIDList, cycleID)

            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetSubjectDetails (combined): " & ex.Message)
        End Try

        Return details
    End Function
    Private Shared Function GetCombinedSubjectComments(conn As MySqlConnection, loadIDs As String(), cycleID As Integer) As List(Of CommentGroup)
        Dim commentGroups As New List(Of CommentGroup)()

        ' Initialize the three comment groups
        Dim strengthsGroup As New CommentGroup With {.CommentType = "Strengths", .Comments = New List(Of CommentData)(), .TotalCount = 0}
        Dim weaknessesGroup As New CommentGroup With {.CommentType = "Weaknesses", .Comments = New List(Of CommentData)(), .TotalCount = 0}
        Dim additionalGroup As New CommentGroup With {.CommentType = "Additional Comments", .Comments = New List(Of CommentData)(), .TotalCount = 0}

        Try
            ' Create parameter placeholders for the LoadIDs
            Dim parameters = loadIDs.Select(Function(id, index) "@LoadID" & index).ToArray()
            Dim parameterPlaceholders = String.Join(",", parameters)

            Dim sql As New StringBuilder()
            sql.AppendLine("SELECT ")
            sql.AppendLine("  es.Strengths, ")
            sql.AppendLine("  es.Weaknesses, ")
            sql.AppendLine("  es.AdditionalMessage ")
            sql.AppendLine("FROM evaluationsubmissions es")
            sql.AppendLine($"WHERE es.LoadID IN ({parameterPlaceholders}) ")
            sql.AppendLine("AND es.IsReleased = 2") ' ADDED RELEASE CONDITION
            sql.AppendLine("AND ((es.Strengths IS NOT NULL AND es.Strengths <> '') ")
            sql.AppendLine("   OR (es.Weaknesses IS NOT NULL AND es.Weaknesses <> '') ")
            sql.AppendLine("   OR (es.AdditionalMessage IS NOT NULL AND es.AdditionalMessage <> '')) ")

            If cycleID > 0 Then
                sql.AppendLine("AND es.CycleID = @CycleID")
            End If

            sql.AppendLine("ORDER BY es.SubmissionDate DESC")

            Using cmd As New MySqlCommand(sql.ToString(), conn)
                ' Add LoadID parameters
                For i As Integer = 0 To loadIDs.Length - 1
                    cmd.Parameters.AddWithValue("@LoadID" & i, loadIDs(i).Trim())
                Next

                If cycleID > 0 Then
                    cmd.Parameters.AddWithValue("@CycleID", cycleID)
                End If

                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    While reader.Read()
                        Dim strengths = If(reader("Strengths") Is DBNull.Value, String.Empty, reader("Strengths").ToString().Trim())
                        Dim weaknesses = If(reader("Weaknesses") Is DBNull.Value, String.Empty, reader("Weaknesses").ToString().Trim())
                        Dim additionalMessage = If(reader("AdditionalMessage") Is DBNull.Value, String.Empty, reader("AdditionalMessage").ToString().Trim())

                        ' Process Strengths
                        If Not String.IsNullOrWhiteSpace(strengths) Then
                            strengthsGroup.Comments.Add(New CommentData With {
                            .CommentText = strengths
                        })
                        End If

                        ' Process Weaknesses
                        If Not String.IsNullOrWhiteSpace(weaknesses) Then
                            weaknessesGroup.Comments.Add(New CommentData With {
                            .CommentText = weaknesses
                        })
                        End If

                        ' Process Additional Messages
                        If Not String.IsNullOrWhiteSpace(additionalMessage) Then
                            additionalGroup.Comments.Add(New CommentData With {
                            .CommentText = additionalMessage
                        })
                        End If
                    End While
                End Using
            End Using

            ' Set total counts
            strengthsGroup.TotalCount = strengthsGroup.Comments.Count
            weaknessesGroup.TotalCount = weaknessesGroup.Comments.Count
            additionalGroup.TotalCount = additionalGroup.Comments.Count

            ' Only add groups that have comments
            If strengthsGroup.TotalCount > 0 Then commentGroups.Add(strengthsGroup)
            If weaknessesGroup.TotalCount > 0 Then commentGroups.Add(weaknessesGroup)
            If additionalGroup.TotalCount > 0 Then commentGroups.Add(additionalGroup)

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetCombinedSubjectComments: " & ex.Message)
        End Try

        Return commentGroups
    End Function
    Private Shared Function GetSubjectComments(conn As MySqlConnection, loadID As Integer, cycleID As Integer) As List(Of CommentGroup)
        Dim commentGroups As New List(Of CommentGroup)()

        ' Initialize the three comment groups
        Dim strengthsGroup As New CommentGroup With {.CommentType = "Strengths", .Comments = New List(Of CommentData)(), .TotalCount = 0}
        Dim weaknessesGroup As New CommentGroup With {.CommentType = "Weaknesses", .Comments = New List(Of CommentData)(), .TotalCount = 0}
        Dim additionalGroup As New CommentGroup With {.CommentType = "Additional Comments", .Comments = New List(Of CommentData)(), .TotalCount = 0}

        Try
            Dim sql As New StringBuilder()
            sql.AppendLine("SELECT ")
            sql.AppendLine("  es.Strengths, ")
            sql.AppendLine("  es.Weaknesses, ")
            sql.AppendLine("  es.AdditionalMessage ")
            sql.AppendLine("FROM evaluationsubmissions es")
            sql.AppendLine("WHERE es.LoadID = @LoadID ")
            sql.AppendLine("AND ((es.Strengths IS NOT NULL AND es.Strengths <> '') ")
            sql.AppendLine("   OR (es.Weaknesses IS NOT NULL AND es.Weaknesses <> '') ")
            sql.AppendLine("   OR (es.AdditionalMessage IS NOT NULL AND es.AdditionalMessage <> '')) ")

            If cycleID > 0 Then
                sql.AppendLine("AND es.CycleID = @CycleID")
            End If

            sql.AppendLine("ORDER BY es.SubmissionDate DESC")

            Using cmd As New MySqlCommand(sql.ToString(), conn)
                cmd.Parameters.AddWithValue("@LoadID", loadID)
                If cycleID > 0 Then
                    cmd.Parameters.AddWithValue("@CycleID", cycleID)
                End If

                Using reader As MySqlDataReader = cmd.ExecuteReader()
                    While reader.Read()
                        Dim strengths = If(reader("Strengths") Is DBNull.Value, String.Empty, reader("Strengths").ToString().Trim())
                        Dim weaknesses = If(reader("Weaknesses") Is DBNull.Value, String.Empty, reader("Weaknesses").ToString().Trim())
                        Dim additionalMessage = If(reader("AdditionalMessage") Is DBNull.Value, String.Empty, reader("AdditionalMessage").ToString().Trim())

                        ' Process Strengths
                        If Not String.IsNullOrWhiteSpace(strengths) Then
                            strengthsGroup.Comments.Add(New CommentData With {
                            .CommentText = strengths
                        })
                        End If

                        ' Process Weaknesses
                        If Not String.IsNullOrWhiteSpace(weaknesses) Then
                            weaknessesGroup.Comments.Add(New CommentData With {
                            .CommentText = weaknesses
                        })
                        End If

                        ' Process Additional Messages
                        If Not String.IsNullOrWhiteSpace(additionalMessage) Then
                            additionalGroup.Comments.Add(New CommentData With {
                            .CommentText = additionalMessage
                        })
                        End If
                    End While
                End Using
            End Using

            ' Set total counts
            strengthsGroup.TotalCount = strengthsGroup.Comments.Count
            weaknessesGroup.TotalCount = weaknessesGroup.Comments.Count
            additionalGroup.TotalCount = additionalGroup.Comments.Count

            ' Only add groups that have comments
            If strengthsGroup.TotalCount > 0 Then commentGroups.Add(strengthsGroup)
            If weaknessesGroup.TotalCount > 0 Then commentGroups.Add(weaknessesGroup)
            If additionalGroup.TotalCount > 0 Then commentGroups.Add(additionalGroup)

            System.Diagnostics.Debug.WriteLine($"Found comments - Strengths: {strengthsGroup.TotalCount}, Weaknesses: {weaknessesGroup.TotalCount}, Additional: {additionalGroup.TotalCount}")

        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetSubjectComments: " & ex.Message)
            System.Diagnostics.Debug.WriteLine("Stack Trace: " & ex.StackTrace)
        End Try

        Return commentGroups
    End Function

    <WebMethod()>
    Public Shared Function GetEvaluationStatus(facultyID As Integer, cycleID As Integer) As EvaluationStatus
        Dim status As New EvaluationStatus()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        status.SubjectsEvaluated = 0
        status.TotalSubjects = 0
        status.CurrentCycleScore = 0
        status.Trend = 0
        status.ResponseRate = 0

        If cycleID = 0 Then
            Return status
        End If

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()

                ' First, get the current cycle's term
                Dim currentTerm As String = ""
                Dim termQuery As String = "SELECT Term FROM evaluationcycles WHERE CycleID = @CycleID"

                Using cmdTerm As New MySqlCommand(termQuery, conn)
                    cmdTerm.Parameters.AddWithValue("@CycleID", cycleID)
                    Dim result = cmdTerm.ExecuteScalar()
                    If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                        currentTerm = result.ToString()
                    End If
                End Using

                If String.IsNullOrEmpty(currentTerm) Then
                    Return status
                End If

                ' Response rate calculation - UPDATED to use current term
                Dim responseRateQuery As String = "
        SELECT 
            COUNT(DISTINCT es.StudentID) as RespondedStudents,
            (SELECT COUNT(*) FROM Students s 
             INNER JOIN FacultyLoad fl ON s.ClassID = fl.ClassID 
             WHERE fl.FacultyID = @FacultyID 
             AND fl.IsDeleted = 0 
             AND fl.Term = @CurrentTerm) as TotalStudents
        FROM EvaluationSubmissions es
        INNER JOIN FacultyLoad fl ON es.LoadID = fl.LoadID
        WHERE fl.FacultyID = @FacultyID 
        AND es.CycleID = @CycleID
        AND es.IsReleased = 2"

                Using cmd As New MySqlCommand(responseRateQuery, conn)
                    cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                    cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    cmd.Parameters.AddWithValue("@CurrentTerm", currentTerm)

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        If rdr.Read() Then
                            Dim respondedStudents = GetSafeInt32Shared(rdr, "RespondedStudents")
                            Dim totalStudents = GetSafeInt32Shared(rdr, "TotalStudents")

                            If totalStudents > 0 Then
                                status.ResponseRate = Math.Round((respondedStudents / totalStudents) * 100, 1)
                            Else
                                status.ResponseRate = 0
                            End If
                        End If
                    End Using
                End Using

                ' Current cycle score calculation - UPDATED WITH RELEASE CONDITION
                Dim scoreQuery As String = "
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
            WHERE fl.FacultyID = @FacultyID 
            AND fl.IsDeleted = 0
            AND fl.Term = @CurrentTerm
            AND es.CycleID = @CycleID
            AND e.IsReleased = 2 AND es.IsReleased = 2
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
            LEAST(ROUND(AVG(TotalScore), 1), 100.0) AS CurrentScore
        FROM submission_totals"

                Using cmd As New MySqlCommand(scoreQuery, conn)
                    cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                    cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    cmd.Parameters.AddWithValue("@CurrentTerm", currentTerm)

                    Dim result = cmd.ExecuteScalar()
                    If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                        status.CurrentCycleScore = Convert.ToDecimal(result)
                    End If
                End Using

                ' Get subject counts - UPDATED to only count subjects in current term
                Dim statusQuery As String = "
        SELECT 
            COUNT(DISTINCT CASE WHEN es.SubmissionID IS NOT NULL AND es.IsReleased = 2 THEN fl.LoadID END) AS SubjectsEvaluated,
            COUNT(DISTINCT fl.LoadID) AS TotalSubjects
        FROM FacultyLoad fl
        LEFT JOIN EvaluationSubmissions es ON fl.LoadID = es.LoadID AND es.CycleID = @CycleID AND es.IsReleased = 2
        WHERE fl.FacultyID = @FacultyID 
        AND fl.IsDeleted = 0 
        AND fl.Term = @CurrentTerm"

                Using cmd As New MySqlCommand(statusQuery, conn)
                    cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                    cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    cmd.Parameters.AddWithValue("@CurrentTerm", currentTerm)

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        If rdr.Read() Then
                            status.SubjectsEvaluated = GetSafeInt32Shared(rdr, "SubjectsEvaluated")
                            status.TotalSubjects = GetSafeInt32Shared(rdr, "TotalSubjects")
                        End If
                    End Using
                End Using

                ' Calculate trend - This uses the same weighted calculation with release condition and term filter
                If status.CurrentCycleScore > 0 Then
                    status.Trend = CalculateWeightedTrend(facultyID, cycleID, connString, currentTerm)
                End If
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetEvaluationStatus: " & ex.Message)
        End Try

        Return status
    End Function

    Private Shared Function CalculateWeightedTrend(facultyID As Integer, currentCycleID As Integer, connString As String, currentTerm As String) As Decimal
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
                WHERE fl.FacultyID = @FacultyID 
                AND fl.IsDeleted = 0
                AND fl.Term = @CurrentTerm
                AND es.CycleID = @CycleID
                AND e.IsReleased = 2 AND es.IsReleased = 2
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
                    cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                    cmd.Parameters.AddWithValue("@CycleID", currentCycleID)
                    cmd.Parameters.AddWithValue("@CurrentTerm", currentTerm)

                    Dim result = cmd.ExecuteScalar()
                    If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                        currentAvg = Convert.ToDecimal(result)
                    End If
                End Using

                If currentAvg = 0 Then
                    Return 0
                End If

                ' Get previous cycle with the same term
                Dim prevCycleQuery As String = "
            SELECT ec.CycleID 
            FROM EvaluationCycles ec
            WHERE ec.CycleID < @CurrentCycleID 
            AND ec.Term = @CurrentTerm
            AND ec.Status IN ('Active', 'Inactive')
            ORDER BY ec.EndDate DESC 
            LIMIT 1"

                Dim prevCycleID As Integer = 0
                Using cmd As New MySqlCommand(prevCycleQuery, conn)
                    cmd.Parameters.AddWithValue("@CurrentCycleID", currentCycleID)
                    cmd.Parameters.AddWithValue("@CurrentTerm", currentTerm)
                    Dim result = cmd.ExecuteScalar()
                    If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                        prevCycleID = Convert.ToInt32(result)
                    End If
                End Using

                Dim previousAvg As Decimal = 0
                Dim hasPreviousData As Boolean = False

                If prevCycleID > 0 Then
                    Using cmd As New MySqlCommand(currentAvgQuery.Replace("@CycleID", "@PrevCycleID"), conn)
                        cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                        cmd.Parameters.AddWithValue("@PrevCycleID", prevCycleID)
                        cmd.Parameters.AddWithValue("@CurrentTerm", currentTerm)

                        Dim result = cmd.ExecuteScalar()
                        If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                            previousAvg = Convert.ToDecimal(result)
                            hasPreviousData = (previousAvg > 0)
                        End If
                    End Using
                End If

                If hasPreviousData AndAlso previousAvg > 0 Then
                    trend = Math.Round(currentAvg - previousAvg, 1)
                Else
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
    Public Shared Function GetFacultyOverview(facultyID As Integer, cycleID As Integer) As FacultyOverview
        Dim overview As New FacultyOverview()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()

                ' Get the current cycle's term
                Dim currentTerm As String = ""
                Dim termQuery As String = "SELECT Term FROM evaluationcycles WHERE CycleID = @CycleID"

                Using cmdTerm As New MySqlCommand(termQuery, conn)
                    cmdTerm.Parameters.AddWithValue("@CycleID", cycleID)
                    Dim result = cmdTerm.ExecuteScalar()
                    If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                        currentTerm = result.ToString()
                    End If
                End Using

                If String.IsNullOrEmpty(currentTerm) Then
                    Return overview
                End If

                ' Overall Score Calculation - UPDATED WITH RELEASE CONDITION AND TERM FILTER
                Dim overallQuery As String = "
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
            WHERE fl.FacultyID = @FacultyID 
            AND fl.IsDeleted = 0
            AND fl.Term = @CurrentTerm
            AND e.IsReleased = 2 AND es.IsReleased = 2"

                If cycleID > 0 Then
                    overallQuery &= " AND es.CycleID = @CycleID"
                End If

                overallQuery &= "
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

                Using cmd As New MySqlCommand(overallQuery, conn)
                    cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                    cmd.Parameters.AddWithValue("@CurrentTerm", currentTerm)
                    If cycleID > 0 Then
                        cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    End If

                    Dim result = cmd.ExecuteScalar()
                    If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                        overview.OverallScore = Convert.ToDecimal(result)
                    End If
                End Using

                ' Domain Scores - UPDATED WITH RELEASE CONDITION AND TERM FILTER
                Dim domainQuery As String = "
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
        WHERE fl.FacultyID = @FacultyID 
        AND fl.IsDeleted = 0
        AND fl.Term = @CurrentTerm
        AND e.IsReleased = 2 AND es.IsReleased = 2"

                If cycleID > 0 Then
                    domainQuery &= " AND es.CycleID = @CycleID"
                End If

                domainQuery &= "
        GROUP BY d.DomainID, d.DomainName, d.Weight
        HAVING AVG(e.Score) > 0
        ORDER BY d.Weight DESC"

                Using cmd As New MySqlCommand(domainQuery, conn)
                    cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                    cmd.Parameters.AddWithValue("@CurrentTerm", currentTerm)
                    If cycleID > 0 Then
                        cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    End If

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        overview.Domains = New List(Of DomainData)()
                        While rdr.Read()
                            overview.Domains.Add(New DomainData() With {
                        .DomainName = GetSafeStringShared(rdr, "DomainName"),
                        .Weight = GetSafeDecimalShared(rdr, "Weight"),
                        .AvgScore = GetSafeDecimalShared(rdr, "AvgScore")
                    })
                        End While
                    End Using
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetFacultyOverview: " & ex.Message)
        End Try

        Return overview
    End Function
    Protected Sub btnLogout_Click(sender As Object, e As EventArgs)
        Session.Clear()
        Session.Abandon()
        Response.Redirect("~/Login.aspx")
    End Sub
    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetSubjectsForAutoComplete(facultyID As Integer, searchText As String, cycleID As Integer) As List(Of SubjectAutoCompleteItem)
        Dim subjects As New List(Of SubjectAutoCompleteItem)()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()

                Dim query As String = "SELECT DISTINCT 
                            fl.LoadID,
                            s.SubjectName,
                            s.SubjectCode,
                            ec.Term,
                            ec.CycleName
                          FROM FacultyLoad fl
                          INNER JOIN Subjects s ON fl.SubjectID = s.SubjectID
                          INNER JOIN EvaluationSubmissions es ON fl.LoadID = es.LoadID
                          INNER JOIN EvaluationCycles ec ON es.CycleID = ec.CycleID
                          WHERE fl.FacultyID = @FacultyID 
                            AND fl.IsDeleted = 0
                            AND (s.SubjectName LIKE @SearchText 
                                 OR s.SubjectCode LIKE @SearchText
                                 OR ec.Term LIKE @SearchText
                                 OR ec.CycleName LIKE @SearchText)"

                If cycleID > 0 Then
                    query &= " AND ec.CycleID = @CycleID"
                End If

                query &= " ORDER BY s.SubjectName, ec.Term
                  LIMIT 15"

                Using cmd As New MySqlCommand(query, conn)
                    cmd.Parameters.AddWithValue("@FacultyID", facultyID)
                    cmd.Parameters.AddWithValue("@SearchText", "%" & searchText & "%")

                    If cycleID > 0 Then
                        cmd.Parameters.AddWithValue("@CycleID", cycleID)
                    End If

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        While rdr.Read()
                            subjects.Add(New SubjectAutoCompleteItem() With {
                            .ID = GetSafeInt32Shared(rdr, "LoadID"),
                            .Name = GetSafeStringShared(rdr, "SubjectName"),
                            .Code = GetSafeStringShared(rdr, "SubjectCode"),
                            .Term = GetSafeStringShared(rdr, "Term"),
                            .CycleName = GetSafeStringShared(rdr, "CycleName")
                        })
                        End While
                    End Using
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetSubjectsForAutoComplete: " & ex.Message)
        End Try

        Return subjects
    End Function

    <WebMethod()>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json)>
    Public Shared Function GetCyclesWithDates(searchText As String) As List(Of AutoCompleteItem)
        Dim cycles As New List(Of AutoCompleteItem)()
        Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

        Try
            Using conn As New MySqlConnection(connString)
                conn.Open()

                ' Get the latest active cycle
                Dim latestCycleID As Integer = 0
                Dim latestQuery As String = "SELECT CycleID FROM EvaluationCycles 
                               WHERE Status = 'Active'
                               ORDER BY EndDate DESC, StartDate DESC 
                               LIMIT 1"

                Using cmdLatest As New MySqlCommand(latestQuery, conn)
                    Dim result = cmdLatest.ExecuteScalar()
                    If result IsNot Nothing AndAlso Not IsDBNull(result) Then
                        latestCycleID = Convert.ToInt32(result)
                    End If
                End Using

                ' Enhanced query to search by dates as well
                Dim query As String = "SELECT CycleID, Term, StartDate, EndDate, CycleName 
                      FROM EvaluationCycles 
                      WHERE (Term LIKE @SearchText 
                         OR CycleName LIKE @SearchText
                         OR DATE_FORMAT(StartDate, '%M %d, %Y') LIKE @SearchText 
                         OR DATE_FORMAT(EndDate, '%M %d, %Y') LIKE @SearchText
                         OR DATE_FORMAT(StartDate, '%M %Y') LIKE @SearchText 
                         OR DATE_FORMAT(EndDate, '%M %Y') LIKE @SearchText
                         OR DATE_FORMAT(StartDate, '%Y') LIKE @SearchText
                         OR DATE_FORMAT(EndDate, '%Y') LIKE @SearchText)
                         AND Status IN ('Active', 'Inactive')
                      ORDER BY StartDate DESC LIMIT 10"

                Using cmd As New MySqlCommand(query, conn)
                    cmd.Parameters.AddWithValue("@SearchText", "%" & searchText & "%")

                    Using rdr As MySqlDataReader = cmd.ExecuteReader()
                        While rdr.Read()
                            Dim cycleID As Integer = GetSafeInt32Shared(rdr, "CycleID")
                            Dim termName As String = GetSafeStringShared(rdr, "Term")
                            Dim cycleName As String = GetSafeStringShared(rdr, "CycleName")

                            Dim startDateValue As DateTime = GetSafeDateTimeShared(rdr, "StartDate")
                            Dim endDateValue As DateTime = GetSafeDateTimeShared(rdr, "EndDate")

                            Dim startDate As String = If(startDateValue = DateTime.MinValue, "N/A", startDateValue.ToString("yyyy-MM-dd"))
                            Dim endDate As String = If(endDateValue = DateTime.MinValue, "N/A", endDateValue.ToString("yyyy-MM-dd"))

                            Dim displayName As String
                            If Not String.IsNullOrEmpty(cycleName) Then
                                displayName = $"{termName} - {cycleName}"
                            Else
                                displayName = termName
                            End If

                            If cycleID = latestCycleID Then
                                displayName += " (Latest)"
                            End If

                            cycles.Add(New AutoCompleteItem() With {
                            .ID = cycleID,
                            .Name = displayName,
                            .TermName = termName,
                            .CycleName = cycleName,
                            .StartDate = startDate,
                            .EndDate = endDate,
                            .IsLatest = (cycleID = latestCycleID)
                        })
                        End While
                    End Using
                End Using
            End Using
        Catch ex As Exception
            System.Diagnostics.Debug.WriteLine("Error in GetCyclesWithDates: " & ex.Message)
        End Try

        Return cycles
    End Function

    Public Function GetRatingCategory(score As Double) As String
        If score >= 90 Then
            Return "Excellent"
        ElseIf score >= 80 Then
            Return "Very Good"
        ElseIf score >= 70 Then
            Return "Good"
        ElseIf score >= 60 Then
            Return "Average"
        Else
            Return "Needs Improvement"
        End If
    End Function

    Private Function GetRatingBadgeClass(score As Double) As String
        If score >= 90 Then Return "bg-success"
        If score >= 80 Then Return "bg-info"
        If score >= 70 Then Return "bg-primary"
        If score >= 60 Then Return "bg-warning"
        Return "bg-danger"
    End Function
End Class

