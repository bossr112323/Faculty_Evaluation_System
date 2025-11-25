Imports System.Configuration
Imports MySql.Data.MySqlClient
Imports System.Text

Public Class MyEvaluations
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Session("SchoolID") Is Nothing OrElse Session("Role").ToString() <> "Student" Then
                Response.Redirect("Login.aspx")
            End If

            LoadSubmissions()
        End If
    End Sub

    Private Sub LoadSubmissions()
        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Get the active cycle ID
            Dim activeCycleQuery As String = "SELECT CycleID FROM evaluationcycles WHERE Status = 'Active'"
            Dim activeCycleCmd As New MySqlCommand(activeCycleQuery, conn)
            Dim activeCycleResult = activeCycleCmd.ExecuteScalar()

            If activeCycleResult Is Nothing Then
                pnlNoEvaluations.Visible = True
                Return
            End If

            Dim activeCycleID As Integer = Convert.ToInt32(activeCycleResult)

            ' Updated query that works with both old and new schema
            ' First, check if new columns exist
            Dim checkColumnsQuery As String = "
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_name = 'evaluationsubmissions' 
            AND column_name = 'AdditionalMessage' 
            AND table_schema = DATABASE()"

            Dim checkCmd As New MySqlCommand(checkColumnsQuery, conn)
            Dim newColumnsExist As Integer = Convert.ToInt32(checkCmd.ExecuteScalar())

            Dim submissionQuery As String = ""

            If newColumnsExist > 0 Then
                ' Use new columns if they exist
                submissionQuery = "
                SELECT 
                    es.SubmissionID,
                    CONCAT(u.LastName, ', ', u.FirstName, 
                        CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial <> '' 
                             THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
                        CASE WHEN u.Suffix IS NOT NULL AND u.Suffix <> '' 
                             THEN CONCAT(' ', u.Suffix) ELSE '' END
                    ) AS FacultyName,
                    s.SubjectName,
                    fl.Term,
                    es.SubmissionDate,
                    COALESCE(es.Strengths, '') AS Strengths,
                    COALESCE(es.Weaknesses, '') AS Weaknesses,
                    COALESCE(es.AdditionalMessage, '') AS AdditionalMessage,
                    ed.DomainName,
                    ed.Weight,
                    AVG(e.Score) AS DomainScore,
                    COUNT(e.Score) AS QuestionCount
                FROM evaluationsubmissions es
                INNER JOIN facultyload fl ON es.LoadID = fl.LoadID
                INNER JOIN users u ON fl.FacultyID = u.UserID
                INNER JOIN subjects s ON fl.SubjectID = s.SubjectID
                INNER JOIN evaluations e ON e.SubmissionID = es.SubmissionID
                INNER JOIN evaluationquestions q ON e.QuestionID = q.QuestionID
                INNER JOIN evaluationdomains ed ON q.DomainID = ed.DomainID
                WHERE es.StudentID = @StudentID 
                AND es.CycleID = @ActiveCycleID
                GROUP BY es.SubmissionID, ed.DomainID
                ORDER BY es.SubmissionDate DESC, ed.DomainID;"
            Else
                ' Fallback to old schema (using Comments column for all feedback)
                submissionQuery = "
                SELECT 
                    es.SubmissionID,
                    CONCAT(u.LastName, ', ', u.FirstName, 
                        CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial <> '' 
                             THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
                        CASE WHEN u.Suffix IS NOT NULL AND u.Suffix <> '' 
                             THEN CONCAT(' ', u.Suffix) ELSE '' END
                    ) AS FacultyName,
                    s.SubjectName,
                    fl.Term,
                    es.SubmissionDate,
                    '' AS Strengths,
                    '' AS Weaknesses,
                    COALESCE(es.Comments, '') AS AdditionalMessage,
                    ed.DomainName,
                    ed.Weight,
                    AVG(e.Score) AS DomainScore,
                    COUNT(e.Score) AS QuestionCount
                FROM evaluationsubmissions es
                INNER JOIN facultyload fl ON es.LoadID = fl.LoadID
                INNER JOIN users u ON fl.FacultyID = u.UserID
                INNER JOIN subjects s ON fl.SubjectID = s.SubjectID
                INNER JOIN evaluations e ON e.SubmissionID = es.SubmissionID
                INNER JOIN evaluationquestions q ON e.QuestionID = q.QuestionID
                INNER JOIN evaluationdomains ed ON q.DomainID = ed.DomainID
                WHERE es.StudentID = @StudentID 
                AND es.CycleID = @ActiveCycleID
                GROUP BY es.SubmissionID, ed.DomainID
                ORDER BY es.SubmissionDate DESC, ed.DomainID;"
            End If

            Dim cmd As New MySqlCommand(submissionQuery, conn)
            cmd.Parameters.AddWithValue("@StudentID", Session("UserID"))
            cmd.Parameters.AddWithValue("@ActiveCycleID", activeCycleID)

            Dim dt As New DataTable()
            Dim da As New MySqlDataAdapter(cmd)
            da.Fill(dt)

            If dt.Rows.Count > 0 Then
                ' Group by SubmissionID and calculate weighted total without rounding
                Dim submissions = dt.AsEnumerable() _
                    .GroupBy(Function(r) r.Field(Of Integer)("SubmissionID")) _
                    .Select(Function(g) New With {
                        .SubmissionID = g.Key,
                        .FacultyName = g.First().Field(Of String)("FacultyName"),
                        .SubjectName = g.First().Field(Of String)("SubjectName"),
                        .Term = g.First().Field(Of String)("Term"),
                        .SubmissionDate = g.First().Field(Of DateTime)("SubmissionDate"),
                        .Strengths = g.First().Field(Of String)("Strengths"),
                        .Weaknesses = g.First().Field(Of String)("Weaknesses"),
                        .AdditionalMessage = g.First().Field(Of String)("AdditionalMessage"),
                        .Domains = g.Select(Function(d) New With {
                            .DomainName = d.Field(Of String)("DomainName"),
                            .Weight = Convert.ToInt32(d("Weight")),
                            .Score = Convert.ToDouble(d("DomainScore")),  ' Exact 1-5 scale score
                            .WeightedScore = Convert.ToDouble(d("DomainScore")) * Convert.ToInt32(d("Weight")) / 5  ' Exact calculation
                        }).ToList(),
                        .TotalScore = g.Sum(Function(d) Convert.ToDouble(d("DomainScore")) * Convert.ToInt32(d("Weight")) / 5)  ' Exact total
                    }).ToList()

                rptSubmissions.DataSource = submissions
                rptSubmissions.DataBind()
            Else
                pnlNoEvaluations.Visible = True
            End If
        End Using
    End Sub

    ' Helper function to determine score category for styling (using 1-5 scale)
    Public Function GetScoreClass(score As Double) As String
        If score >= 4.5 Then
            Return "score-high"
        ElseIf score >= 4.0 Then
            Return "score-high"
        ElseIf score >= 3.5 Then
            Return "score-good"
        ElseIf score >= 3.0 Then
            Return "score-medium"
        ElseIf score >= 2.5 Then
            Return "score-low"
        Else
            Return "score-poor"
        End If
    End Function

    ' Helper function to get rating category text (for overall percentage score)
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

    ' Helper function to get rating badge color (for overall percentage score)
    Public Function GetRatingBadgeClass(score As Double) As String
        If score >= 90 Then
            Return "bg-success"
        ElseIf score >= 80 Then
            Return "bg-info"
        ElseIf score >= 70 Then
            Return "bg-primary"
        ElseIf score >= 60 Then
            Return "bg-warning"
        Else
            Return "bg-danger"
        End If
    End Function

    ' Helper function to generate star rating HTML
    Public Function GetStarRatingHTML(score As Integer) As String
        Dim sb As New StringBuilder()

        For i As Integer = 1 To 5
            If i <= score Then
                sb.Append("<i class='bi bi-star-fill star-readonly star-filled'></i>")
            Else
                sb.Append("<i class='bi bi-star-fill star-readonly star-empty'></i>")
            End If
        Next

        Return sb.ToString()
    End Function

    ' ItemDataBound event handler for the main submissions repeater
    Protected Sub rptSubmissions_ItemDataBound(sender As Object, e As RepeaterItemEventArgs) Handles rptSubmissions.ItemDataBound
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            ' Find the nested repeater for domains
            Dim rptDomains As Repeater = CType(e.Item.FindControl("rptDomains"), Repeater)

            ' Get the domains data
            Dim domainsData = DataBinder.Eval(e.Item.DataItem, "Domains")

            If domainsData IsNot Nothing Then
                rptDomains.DataSource = domainsData
                rptDomains.DataBind()
            End If

            ' Set the score class for the total score
            Dim totalScore As Double = Convert.ToDouble(DataBinder.Eval(e.Item.DataItem, "TotalScore"))
            Dim totalScoreCell As HtmlControl = CType(e.Item.FindControl("totalScoreCell"), HtmlControl)

            If totalScoreCell IsNot Nothing Then
                totalScoreCell.Attributes("class") = $"score-cell {GetScoreClass(totalScore / 20)} fw-bold"  ' Convert percentage back to approximate 1-5 scale for coloring
            End If

            ' Load detailed questions for this submission
            Dim submissionID As Integer = Convert.ToInt32(DataBinder.Eval(e.Item.DataItem, "SubmissionID"))
            Dim rptQuestionDetails As Repeater = CType(e.Item.FindControl("rptQuestionDetails"), Repeater)
            LoadQuestionDetails(submissionID, rptQuestionDetails)
        End If
    End Sub


    ' Load detailed questions and scores for a specific submission
    Private Sub LoadQuestionDetails(submissionID As Integer, rptQuestionDetails As Repeater)
        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            Dim query As String = "
        SELECT 
            ed.DomainID,
            ed.DomainName,
            eq.QuestionID,
            eq.QuestionText,
            e.Score
        FROM evaluations e
        INNER JOIN evaluationquestions eq ON e.QuestionID = eq.QuestionID
        INNER JOIN evaluationdomains ed ON eq.DomainID = ed.DomainID
        WHERE e.SubmissionID = @SubmissionID
        ORDER BY ed.DomainID, eq.QuestionID"

            Dim cmd As New MySqlCommand(query, conn)
            cmd.Parameters.AddWithValue("@SubmissionID", submissionID)

            Dim dt As New DataTable()
            Dim da As New MySqlDataAdapter(cmd)
            da.Fill(dt)

            If dt.Rows.Count > 0 Then
                ' Create a list to hold domain data
                Dim domains As New List(Of Object)()

                ' Group by domain manually
                Dim domainGroups = dt.AsEnumerable() _
                .GroupBy(Function(r) New With {
                    Key .DomainID = Convert.ToInt32(r("DomainID")),
                    Key .DomainName = r("DomainName").ToString()
                })

                For Each domainGroup In domainGroups
                    Dim domain = New With {
                    .DomainID = domainGroup.Key.DomainID,
                    .DomainName = domainGroup.Key.DomainName,
                    .Questions = domainGroup.Select(Function(q) New With {
                        .QuestionID = Convert.ToInt32(q("QuestionID")),
                        .QuestionText = q("QuestionText").ToString(),
                        .Score = Convert.ToInt32(q("Score"))
                    }).ToList()
                }
                    domains.Add(domain)
                Next

                rptQuestionDetails.DataSource = domains
                rptQuestionDetails.DataBind()
            End If
        End Using
    End Sub

    ' ItemDataBound event handler for the question details repeater
    Protected Sub rptQuestionDetails_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            Dim rptDomainQuestions As Repeater = CType(e.Item.FindControl("rptDomainQuestions"), Repeater)

            ' Get the questions data for this domain
            Dim questionsData = DataBinder.Eval(e.Item.DataItem, "Questions")

            If questionsData IsNot Nothing Then
                rptDomainQuestions.DataSource = questionsData
                rptDomainQuestions.DataBind()
            End If
        End If
    End Sub
End Class

