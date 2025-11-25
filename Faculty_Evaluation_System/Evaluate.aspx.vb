Imports System.Configuration
Imports System.Data
Imports MySql.Data.MySqlClient
Imports System.Text

Public Class Evaluate
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    Private Property ActiveTerm As String
        Get
            If ViewState("ActiveTerm") IsNot Nothing Then
                Return ViewState("ActiveTerm").ToString()
            End If
            Return ""
        End Get
        Set(value As String)
            ViewState("ActiveTerm") = value
        End Set
    End Property

    Private Property ActiveCycleID As Integer
        Get
            If ViewState("ActiveCycleID") IsNot Nothing Then
                Return Convert.ToInt32(ViewState("ActiveCycleID"))
            End If
            Return 0
        End Get
        Set(value As Integer)
            ViewState("ActiveCycleID") = value
        End Set
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Session("Role") Is Nothing OrElse Session("Role").ToString() <> "Student" Then
                Response.Redirect("Login.aspx")
            End If

            ' Load active cycle first
            If Not LoadActiveCycle() Then
                ShowError("⚠ No active evaluation cycle. You cannot evaluate right now.")
                pnlEvaluate.Visible = False
                pnlNoEvaluation.Visible = True
                Return
            End If

            ' Check if student is irregular and needs to enroll first
            If IsIrregularStudent() AndAlso Not HasApprovedEnrollment() Then
                Response.Redirect("IrregularStudentEnrollment.aspx")
                Return
            End If

            ' Check if student has already submitted any evaluation in current cycle
            If HasSubmittedInCurrentCycle() Then
                ' Already submitted in this cycle, load evaluation data directly
                LoadEvaluationData()
            Else
                ' Check if terms have been accepted in this session
                If Session("EvaluationTermsAccepted") Is Nothing Then
                    ' Show terms modal and hide evaluation content
                    pnlEvaluate.Visible = False
                    pnlNoEvaluation.Visible = False
                    ' The modal will be shown via JavaScript on page load
                Else
                    ' Terms already accepted in this session, load evaluation data
                    LoadEvaluationData()
                End If
            End If
        End If
    End Sub

    ' ---------------------------
    ' Check if student is irregular
    ' ---------------------------
    Private Function IsIrregularStudent() As Boolean
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim cmd As New MySqlCommand("SELECT StudentType FROM Students WHERE StudentID = @StudentID", conn)
            cmd.Parameters.AddWithValue("@StudentID", Session("UserID"))
            Dim result = cmd.ExecuteScalar()
            Return result IsNot Nothing AndAlso result.ToString() = "Irregular"
        End Using
    End Function

    ' ---------------------------
    ' Check if irregular student has approved enrollment
    ' ---------------------------
    Private Function HasApprovedEnrollment() As Boolean
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim cmd As New MySqlCommand("
                SELECT COUNT(*) 
                FROM irregular_student_enrollments 
                WHERE StudentID = @StudentID 
                AND CycleID = @CycleID
                AND IsApproved = 1", conn)
            cmd.Parameters.AddWithValue("@StudentID", Session("UserID"))
            cmd.Parameters.AddWithValue("@CycleID", ActiveCycleID)

            Dim count As Integer = Convert.ToInt32(cmd.ExecuteScalar())
            System.Diagnostics.Debug.WriteLine($"Approved enrollments for student {Session("UserID")} in cycle {ActiveCycleID}: {count}")
            Return count > 0
        End Using
    End Function

    ' ---------------------------
    ' Check if student has already submitted any evaluation in current cycle
    ' ---------------------------
    Private Function HasSubmittedInCurrentCycle() As Boolean
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim cmd As New MySqlCommand("
                SELECT COUNT(*) 
                FROM EvaluationSubmissions 
                WHERE StudentID = @StudentID 
                AND CycleID = @CycleID", conn)
            cmd.Parameters.AddWithValue("@StudentID", Session("UserID"))
            cmd.Parameters.AddWithValue("@CycleID", ActiveCycleID)

            Dim count As Integer = Convert.ToInt32(cmd.ExecuteScalar())
            Return count > 0
        End Using
    End Function

    ' ---------------------------
    ' Load Evaluation Data (after terms acceptance or if already submitted in cycle)
    ' ---------------------------
    Private Sub LoadEvaluationData()
        LoadFacultyLoad()

        ' Only load questions if there are faculty members to evaluate
        If pnlEvaluate.Visible Then
            LoadQuestionsByDomain()
        End If

        lblMessage.CssClass = "d-none"
    End Sub

    ' ---------------------------
    ' Accept Terms Button Click
    ' ---------------------------
    Protected Sub btnAcceptTerms_Click(sender As Object, e As EventArgs)
        If chkAgreeTerms.Checked Then
            ' Store acceptance in session for current browsing session
            Session("EvaluationTermsAccepted") = True
            ' Load evaluation data
            LoadEvaluationData()

            ' Hide the modal
            ScriptManager.RegisterStartupScript(Me, Me.GetType(), "HideModal", "hideTermsModal();", True)
        Else
            ShowError("⚠ You must agree to the terms and conditions to proceed with the evaluation.")
            ' Keep the modal open
            ScriptManager.RegisterStartupScript(Me, Me.GetType(), "ShowTermsModal", "$('#termsModal').modal('show');", True)
        End If
    End Sub

    ' ---------------------------
    ' Cancel Evaluation Button Click
    ' ---------------------------
    Protected Sub btnCancel_Click(sender As Object, e As EventArgs)
        Response.Redirect("StudentDashboard.aspx")
    End Sub

    ' ---------------------------
    ' Load Active Evaluation Cycle
    ' ---------------------------
    Private Function LoadActiveCycle() As Boolean
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim cmd As New MySqlCommand("
                SELECT CycleID, Term 
                FROM EvaluationCycles 
                WHERE Status='Active' 
                LIMIT 1", conn)

            Using reader = cmd.ExecuteReader()
                If reader.Read() Then
                    ActiveCycleID = Convert.ToInt32(reader("CycleID"))
                    ActiveTerm = reader("Term").ToString()
                    System.Diagnostics.Debug.WriteLine($"Active Cycle Loaded: ID={ActiveCycleID}, Term={ActiveTerm}")
                    Return True
                End If
            End Using
        End Using
        ActiveCycleID = 0
        ActiveTerm = ""
        System.Diagnostics.Debug.WriteLine("No active cycle found")
        Return False
    End Function

    ' ---------------------------
    ' Load Faculty subjects the student can evaluate
    ' ---------------------------
    Private Sub LoadFacultyLoad()
        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Get student info including student type
            Dim studentCmd As New MySqlCommand("
                SELECT ClassID, CourseID, DepartmentID, StudentType
                FROM Students
                WHERE StudentID=@StudentID", conn)
            studentCmd.Parameters.AddWithValue("@StudentID", Session("UserID"))

            Dim classID As Integer = 0, courseID As Integer = 0, deptID As Integer = 0
            Dim studentType As String = ""
            Using reader = studentCmd.ExecuteReader()
                If reader.Read() Then
                    classID = Convert.ToInt32(reader("ClassID"))
                    courseID = Convert.ToInt32(reader("CourseID"))
                    deptID = Convert.ToInt32(reader("DepartmentID"))
                    studentType = reader("StudentType").ToString()
                End If
            End Using

            System.Diagnostics.Debug.WriteLine($"Student Type: {studentType}, ClassID: {classID}, CourseID: {courseID}")

            Dim sql As String = ""

            If studentType = "Irregular" Then
                ' For irregular students - load approved irregular enrollments
                sql = "
                SELECT DISTINCT fl.LoadID,
                       CONCAT(
                           CONCAT(u.LastName, ', ', u.FirstName, 
                               CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial <> '' 
                                    THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
                               CASE WHEN u.Suffix IS NOT NULL AND u.Suffix <> '' 
                                    THEN CONCAT(' ', u.Suffix) ELSE '' END
                           ), 
                           ' - ', 
                           sub.SubjectName, 
                           ' (', c.YearLevel, ' ', c.Section, ') - ', fl.Term
                       ) AS DisplayName,
                       CONCAT(u.LastName, ', ', u.FirstName, 
                           CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial <> '' 
                                THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
                           CASE WHEN u.Suffix IS NOT NULL AND u.Suffix <> '' 
                                THEN CONCAT(' ', u.Suffix) ELSE '' END
                       ) AS FacultyName,
                       sub.SubjectName,
                       d.DepartmentName
                FROM FacultyLoad fl
                INNER JOIN Users u ON fl.FacultyID = u.UserID
                INNER JOIN Subjects sub ON fl.SubjectID = sub.SubjectID
                INNER JOIN Classes c ON fl.ClassID = c.ClassID
                INNER JOIN Departments d ON fl.DepartmentID = d.DepartmentID
                INNER JOIN irregular_student_enrollments ise ON fl.LoadID = ise.LoadID
                WHERE fl.Term=@ActiveTerm
                  AND ise.StudentID=@StudentID 
                  AND ise.CycleID=@CycleID
                  AND ise.IsApproved = 1
                  AND fl.IsDeleted = 0
                  AND fl.LoadID NOT IN (
                      SELECT LoadID FROM EvaluationSubmissions 
                      WHERE StudentID=@StudentID AND CycleID=@CycleID                     
                  )
                ORDER BY FacultyName, sub.SubjectName"
            Else
                ' For regular students - original logic
                sql = "
                SELECT fl.LoadID,
                       CONCAT(
                           CONCAT(u.LastName, ', ', u.FirstName, 
                               CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial <> '' 
                                    THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
                               CASE WHEN u.Suffix IS NOT NULL AND u.Suffix <> '' 
                                    THEN CONCAT(' ', u.Suffix) ELSE '' END
                           ), 
                           ' - ', 
                           sub.SubjectName, 
                           ' (', c.YearLevel, ' ', c.Section, ') - ', fl.Term
                       ) AS DisplayName,
                       CONCAT(u.LastName, ', ', u.FirstName, 
                           CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial <> '' 
                                THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
                           CASE WHEN u.Suffix IS NOT NULL AND u.Suffix <> '' 
                                THEN CONCAT(' ', u.Suffix) ELSE '' END
                       ) AS FacultyName,
                       sub.SubjectName,
                       d.DepartmentName
                FROM FacultyLoad fl
                INNER JOIN Users u ON fl.FacultyID = u.UserID
                INNER JOIN Subjects sub ON fl.SubjectID = sub.SubjectID
                INNER JOIN Classes c ON fl.ClassID = c.ClassID
                INNER JOIN Departments d ON fl.DepartmentID = d.DepartmentID
                WHERE fl.Term=@ActiveTerm
                  AND fl.ClassID=@ClassID
                  AND fl.CourseID=@CourseID
                  AND fl.DepartmentID=@DeptID
                  AND fl.IsDeleted = 0
                  AND fl.LoadID NOT IN (
                      SELECT LoadID FROM EvaluationSubmissions 
                      WHERE StudentID=@StudentID AND CycleID=@CycleID                     
                  )
                ORDER BY FacultyName, sub.SubjectName"
            End If

            Dim cmd As New MySqlCommand(sql, conn)
            cmd.Parameters.AddWithValue("@ActiveTerm", ActiveTerm)
            cmd.Parameters.AddWithValue("@CycleID", ActiveCycleID)
            cmd.Parameters.AddWithValue("@StudentID", Session("UserID"))

            ' Only add these parameters for regular students
            If studentType <> "Irregular" Then
                cmd.Parameters.AddWithValue("@ClassID", classID)
                cmd.Parameters.AddWithValue("@CourseID", courseID)
                cmd.Parameters.AddWithValue("@DeptID", deptID)
            End If

            Dim da As New MySqlDataAdapter(cmd)
            Dim dt As New DataTable()
            da.Fill(dt)

            System.Diagnostics.Debug.WriteLine($"Found {dt.Rows.Count} subjects for evaluation")

            ddlFacultyLoad.DataSource = dt
            ddlFacultyLoad.DataTextField = "DisplayName"
            ddlFacultyLoad.DataValueField = "LoadID"
            ddlFacultyLoad.DataBind()

            If dt.Rows.Count > 0 Then
                ddlFacultyLoad.Items.Insert(0, New ListItem("-- Select Subject/Instructor --", "-1"))
                pnlEvaluate.Visible = True
                pnlNoEvaluation.Visible = False

                ' Show faculty info for first item by default
                ShowFacultyInfo(dt.Rows(0))
            Else
                ddlFacultyLoad.Items.Clear()
                ddlFacultyLoad.Items.Add(New ListItem("-- No subjects available for evaluation --", "-1"))
                pnlEvaluate.Visible = False
                pnlNoEvaluation.Visible = True

                ' Show appropriate message based on student type
                If studentType = "Irregular" Then
                    ShowError("No approved subjects found for evaluation. Please ensure your irregular enrollment has been approved by the administrator.")
                Else
                    ShowError("No subjects available for evaluation at this time.")
                End If
            End If
        End Using
    End Sub

    ' ---------------------------
    ' Show Faculty Information
    ' ---------------------------
    Private Sub ShowFacultyInfo(row As DataRow)
        lblFacultyName.Text = row("FacultyName").ToString()
        lblSubject.Text = row("SubjectName").ToString()
        lblDepartment.Text = row("DepartmentName").ToString()
        pnlFacultyInfo.Visible = True
    End Sub

    Protected Sub ddlFacultyLoad_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ddlFacultyLoad.SelectedIndexChanged
        If ddlFacultyLoad.SelectedValue <> "-1" Then
            Using conn As New MySqlConnection(ConnString)
                conn.Open()
                Dim sql As String = "
                SELECT CONCAT(u.LastName, ', ', u.FirstName, 
                    CASE WHEN u.MiddleInitial IS NOT NULL AND u.MiddleInitial <> '' 
                         THEN CONCAT(' ', u.MiddleInitial, '.') ELSE '' END,
                    CASE WHEN u.Suffix IS NOT NULL AND u.Suffix <> '' 
                         THEN CONCAT(' ', u.Suffix) ELSE '' END
                ) AS FacultyName, 
                       u.Status,
                       sub.SubjectName, 
                       d.DepartmentName
                FROM FacultyLoad fl
                INNER JOIN Users u ON fl.FacultyID = u.UserID
                INNER JOIN Subjects sub ON fl.SubjectID = sub.SubjectID
                INNER JOIN Departments d ON fl.DepartmentID = d.DepartmentID
                WHERE fl.LoadID = @LoadID 
                  AND u.Status = 'Active' 
                  AND fl.IsDeleted = 0"

                Dim cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@LoadID", ddlFacultyLoad.SelectedValue)

                Using reader = cmd.ExecuteReader()
                    If reader.Read() Then
                        lblFacultyName.Text = reader("FacultyName").ToString()
                        lblSubject.Text = reader("SubjectName").ToString()
                        lblDepartment.Text = reader("DepartmentName").ToString()
                        pnlFacultyInfo.Visible = True
                    Else
                        ' If the faculty load was deleted between page load and selection
                        ShowError("⚠ This faculty assignment is no longer available.")
                        LoadFacultyLoad() ' Reload the list
                    End If
                End Using
            End Using
        Else
            pnlFacultyInfo.Visible = False
        End If
    End Sub

    ' ---------------------------
    ' Load Questions by Domain
    ' ---------------------------
    Private Sub LoadQuestionsByDomain()
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "
            SELECT q.QuestionID, q.QuestionText, d.DomainID, d.DomainName, d.Weight
            FROM EvaluationQuestions q
            INNER JOIN EvaluationDomains d ON q.DomainID = d.DomainID
            WHERE q.IsActive = 1 AND d.IsActive = 1
            ORDER BY d.DomainID, q.QuestionID"
            Dim da As New MySqlDataAdapter(sql, conn)
            Dim dt As New DataTable()
            da.Fill(dt)

            If dt.Rows.Count = 0 Then
                ShowError("⚠ No active questions found. Please check your database.")
                Return
            End If

            ' Group by Domain
            Dim domains As New List(Of Domain)
            For Each grp In dt.AsEnumerable().GroupBy(Function(r) New With {
            Key .DomainID = r.Field(Of Integer)("DomainID"),
            Key .DomainName = r.Field(Of String)("DomainName"),
            Key .Weight = r.Field(Of Integer)("Weight")
        })
                domains.Add(New Domain With {
                .DomainID = grp.Key.DomainID,
                .DomainName = grp.Key.DomainName & " (" & grp.Key.Weight & "%)",
                .Weight = grp.Key.Weight,
                .Questions = grp.Select(Function(r) New Question With {
                    .QuestionID = r.Field(Of Integer)("QuestionID"),
                    .QuestionText = r.Field(Of String)("QuestionText")
                }).ToList()
            })
            Next

            ' Store domains in ViewState for postback access
            ViewState("Domains") = domains

            rptDomains.DataSource = domains
            rptDomains.DataBind()
        End Using
    End Sub

    Protected Sub rptDomains_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            Dim rptQuestions As Repeater = CType(e.Item.FindControl("rptDomainQuestions"), Repeater)
            Dim domainObj As Domain = CType(e.Item.DataItem, Domain)
            rptQuestions.DataSource = domainObj.Questions
            rptQuestions.DataBind()
        End If
    End Sub

    ' ---------------------------
    ' Submit Evaluation
    ' ---------------------------
    Protected Sub btnSubmit_Click(sender As Object, e As EventArgs)
        ' Validate that we have an active cycle
        If ActiveCycleID = 0 Then
            ShowError("⚠ No active evaluation cycle found.")
            Return
        End If

        If ddlFacultyLoad.SelectedValue = "-1" Then
            ShowError("⚠ Please select a subject/instructor.")
            Return
        End If

        ' Validate that all questions are answered
        If Not ValidateAllQuestionsAnswered() Then
            ShowError("⚠ Please answer all questions before submitting.")
            Return
        End If

        Dim loadID = Convert.ToInt32(ddlFacultyLoad.SelectedValue)
        Dim strength = txtStrength.Text.Trim()
        Dim weakness = txtWeakness.Text.Trim()
        Dim message = txtMessage.Text.Trim()

        If String.IsNullOrWhiteSpace(strength) Then
            ShowError("⚠ Please describe the instructor's strengths.")
            Return
        End If

        If String.IsNullOrWhiteSpace(weakness) Then
            ShowError("⚠ Please provide constructive feedback on areas for improvement.")
            Return
        End If

        If String.IsNullOrWhiteSpace(message) Then
            ShowError("⚠ Please provide an additional message about your learning experience.")
            Return
        End If

        If strength.Trim().Length < 10 Then
            ShowError("⚠ Please provide more detailed feedback for strengths (minimum 10 characters).")
            Return
        End If

        If weakness.Trim().Length < 10 Then
            ShowError("⚠ Please provide more detailed feedback for areas of improvement (minimum 10 characters).")
            Return
        End If

        If message.Trim().Length < 10 Then
            ShowError("⚠ Please provide a more detailed additional message (minimum 10 characters).")
            Return
        End If

        ' PROFANITY FILTER CHECK
        If ContainsBadWords(strength) OrElse ContainsBadWords(weakness) OrElse ContainsBadWords(message) Then
            ShowError("⚠ Your comments contain inappropriate language. Please remove offensive words and try again.")
            Return
        End If

        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Double-check that the cycle still exists and is active
            Dim cycleCheckCmd As New MySqlCommand("
            SELECT COUNT(*) FROM EvaluationCycles 
            WHERE CycleID = @CycleID AND Status = 'Active'", conn)
            cycleCheckCmd.Parameters.AddWithValue("@CycleID", ActiveCycleID)
            Dim cycleExists As Integer = Convert.ToInt32(cycleCheckCmd.ExecuteScalar())

            If cycleExists = 0 Then
                ShowError("⚠ The evaluation cycle is no longer active. Please refresh the page.")
                Return
            End If

            Dim tr = conn.BeginTransaction()
            Try
                ' Calculate weighted average score
                Dim weightedAverage As Decimal = CalculateWeightedAverage()

                ' Save submission with CycleID, AverageScore, and new comment fields
                Dim subCmd As New MySqlCommand("
               INSERT INTO EvaluationSubmissions (LoadID, StudentID, Strengths, Weaknesses, AdditionalMessage, SubmissionDate, CycleID, AverageScore)
VALUES (@LoadID, @StudentID, @Strengths, @Weaknesses, @AdditionalMessage, NOW(), @CycleID, @AverageScore);
SELECT LAST_INSERT_ID();", conn, tr)
                subCmd.Parameters.AddWithValue("@LoadID", loadID)
                subCmd.Parameters.AddWithValue("@StudentID", Session("UserID"))
                subCmd.Parameters.AddWithValue("@Strengths", strength)
                subCmd.Parameters.AddWithValue("@Weaknesses", weakness)
                subCmd.Parameters.AddWithValue("@AdditionalMessage", message)
                subCmd.Parameters.AddWithValue("@CycleID", ActiveCycleID)
                subCmd.Parameters.AddWithValue("@AverageScore", weightedAverage)

                ' Get the SubmissionID
                Dim submissionID As Integer = Convert.ToInt32(subCmd.ExecuteScalar())

                ' Save individual question scores with CycleID
                For Each domainItem As RepeaterItem In rptDomains.Items
                    Dim rptQuestions As Repeater = CType(domainItem.FindControl("rptDomainQuestions"), Repeater)
                    If rptQuestions IsNot Nothing Then
                        For Each qItem As RepeaterItem In rptQuestions.Items
                            Dim hfQ As HiddenField = CType(qItem.FindControl("hfQuestionID"), HiddenField)
                            Dim rbl As RadioButtonList = CType(qItem.FindControl("rblRating"), RadioButtonList)

                            If hfQ IsNot Nothing AndAlso rbl IsNot Nothing AndAlso rbl.SelectedValue <> "" Then
                                Dim questionID As Integer = Convert.ToInt32(hfQ.Value)
                                Dim score As Integer = Convert.ToInt32(rbl.SelectedValue)

                                Dim evalCmd As New MySqlCommand("
                                INSERT INTO evaluations (LoadID, QuestionID, Score, SubmissionDate, SubmissionID, CycleID)
                                VALUES (@LoadID, @QuestionID, @Score, NOW(), @SubmissionID, @CycleID)", conn, tr)
                                evalCmd.Parameters.AddWithValue("@LoadID", loadID)
                                evalCmd.Parameters.AddWithValue("@QuestionID", questionID)
                                evalCmd.Parameters.AddWithValue("@Score", score)
                                evalCmd.Parameters.AddWithValue("@SubmissionID", submissionID)
                                evalCmd.Parameters.AddWithValue("@CycleID", ActiveCycleID)
                                evalCmd.ExecuteNonQuery()
                            End If
                        Next
                    End If
                Next

                tr.Commit()
                ShowSuccess("✅ Evaluation submitted successfully!")

                ' Clear form and reload
                txtStrength.Text = ""
                txtWeakness.Text = ""
                txtMessage.Text = ""
                LoadFacultyLoad()
                LoadQuestionsByDomain()

            Catch ex As MySqlException
                tr.Rollback()
                If ex.Number = 1452 Then ' Foreign key constraint violation
                    ShowError("❌ Database error: Invalid evaluation cycle. Please contact administrator.")
                Else
                    ShowError("❌ Error submitting evaluation: " & ex.Message)
                End If
            Catch ex As Exception
                tr.Rollback()
                ShowError("❌ Error submitting evaluation: " & ex.Message)
            End Try
        End Using
    End Sub

    ' ---------------------------
    ' Calculate Weighted Average Score
    ' ---------------------------
    Private Function CalculateWeightedAverage() As Decimal
        ' Retrieve domains from ViewState
        Dim domains As List(Of Domain) = CType(ViewState("Domains"), List(Of Domain))

        If domains Is Nothing OrElse domains.Count = 0 Then
            Return 0
        End If

        Dim totalWeightedScore As Decimal = 0
        Dim totalWeight As Integer = 0

        ' Create a dictionary to map domain IDs to their weights for easy lookup
        Dim domainWeights As New Dictionary(Of Integer, Integer)()
        For Each domain In domains
            domainWeights(domain.DomainID) = domain.Weight
        Next

        ' Calculate weighted average for each domain
        For Each domainItem As RepeaterItem In rptDomains.Items
            Dim hfDomainID As HiddenField = CType(domainItem.FindControl("hfDomainID"), HiddenField)
            If hfDomainID IsNot Nothing Then
                Dim domainID As Integer = Convert.ToInt32(hfDomainID.Value)
                Dim domainWeight As Integer = domainWeights(domainID)

                Dim rptQuestions As Repeater = CType(domainItem.FindControl("rptDomainQuestions"), Repeater)
                If rptQuestions IsNot Nothing Then
                    Dim domainScoreSum As Decimal = 0
                    Dim questionCount As Integer = 0

                    ' Calculate total score for this domain
                    For Each qItem As RepeaterItem In rptQuestions.Items
                        Dim rbl As RadioButtonList = CType(qItem.FindControl("rblRating"), RadioButtonList)
                        If rbl IsNot Nothing AndAlso rbl.SelectedValue <> "" Then
                            domainScoreSum += Convert.ToInt32(rbl.SelectedValue)
                            questionCount += 1
                        End If
                    Next

                    If questionCount > 0 Then
                        ' Calculate maximum possible score for this domain
                        Dim maxPossibleScore As Decimal = questionCount * 5

                        ' Calculate domain score as percentage
                        Dim domainPercentage As Decimal = (domainScoreSum / maxPossibleScore) * 100

                        ' Apply domain weight to the percentage
                        totalWeightedScore += domainPercentage * domainWeight
                        totalWeight += domainWeight
                    End If
                End If
            End If
        Next

        If totalWeight > 0 Then
            ' Calculate final weighted average percentage
            Return Math.Round(totalWeightedScore / totalWeight, 2)
        Else
            Return 0
        End If
    End Function

    ' ---------------------------
    ' Validate that all questions are answered
    ' ---------------------------
    Private Function ValidateAllQuestionsAnswered() As Boolean
        For Each domainItem As RepeaterItem In rptDomains.Items
            Dim rptQuestions As Repeater = CType(domainItem.FindControl("rptDomainQuestions"), Repeater)
            For Each qItem As RepeaterItem In rptQuestions.Items
                Dim rbl As RadioButtonList = CType(qItem.FindControl("rblRating"), RadioButtonList)
                If rbl.SelectedValue = "" Then
                    Return False
                End If
            Next
        Next
        Return True
    End Function

    ' ---------------------------
    ' Helpers
    ' ---------------------------
    Private Sub ShowError(msg As String)
        lblMessage.Text = msg
        lblMessage.CssClass = "alert alert-danger d-block alert-slide"
        ClientScript.RegisterStartupScript(Me.GetType(), "ScrollToTop", "window.scrollTo(0, 0);", True)
    End Sub

    Private Sub ShowSuccess(msg As String)
        lblMessage.Text = msg
        lblMessage.CssClass = "alert alert-success d-block alert-slide"
        ClientScript.RegisterStartupScript(Me.GetType(), "ScrollToTop", "window.scrollTo(0, 0);", True)
    End Sub

    ' ---------------------------
    ' Models
    ' ---------------------------
    <Serializable()>
    Public Class Domain
        Public Property DomainID As Integer
        Public Property DomainName As String
        Public Property Weight As Integer
        Public Property Questions As List(Of Question)
    End Class

    <Serializable()>
    Public Class Question
        Public Property QuestionID As Integer
        Public Property QuestionText As String
    End Class

    Private Function ContainsBadWords(text As String) As Boolean
        If String.IsNullOrWhiteSpace(text) Then Return False

        ' Common profanity words - customize this list as needed
        Dim badWords As String() = {
        "shit", "fuck", "asshole", "bitch", "damn", "crap", "piss", "pisswizard", "son of a bitch", "fuckwit", "horny",
        "arsebarger", "bawbag", "pissflaps", "rubbish", "dick", "cock", "pussy", "bastard", "slut", "whore",
        "nigga", "nigger", "fag", "faggot", "retard", "idiot", "moron", "stupid", "dumbass", "jackass",
        "wanker", "bollocks", "tosser", "prick", "jerk", "hoe", "screw you", "motherfucker", "sucker", "dipshit",
        "cunt", "douche", "douchebag", "twat", "skank", "fuckers", "bullshit", "fuckshit", "goddamn",
        "arsehole", "shithead", "shitface", "craphole", "dickhead", "freak", "nutjob", "psycho", "scumbag",
        "bobo", "tanga", "pangit", "tarantado", "kupal", "kumag", "puta", "tangina", "engot", "gago", "gaga",
        "tae", "bwisit", "walang hiya", "punyeta", "mabaho", "yawa", "inutil", "ogag", "amputa", "kingina",
        "pisting yawa", "pisting ina", "pisting ama", "pisting yawa nimo", "ulol", "kaululan", "kagaguhan",
        "gagi", "busit", "burat", "ratbu", "tarub", "nakakaburat", "leche", "ungas", "hinayupak", "hayup",
        "hayop", "pesteng yawa", "pakshet", "nak ng puta", "anak ka ng puta", "pakingina", "taena", "amputa",
        "bwakanangina", "bwakanang ina", "bwakanang ama", "lintik", "lintian", "putragis", "yot", "pokpok", "bading", "bakla", "tomboy", "butiki", "baboy", "chanak", "onggoy",
        "malandi", "tukmol", "gunggong", "ulul", "bobong", "abnoy", "kulangot", "epal", "siraulo", "ulol ka", "duldog", "buwaya", "paku", "amputa",
        "sira ulo", "tarantadong", "putragis", "hudas", "demonyo", "shet", "pucha", "paksit", "buwisit", "balasobas", "engeng", "qpal", "eat", "ekup",
        "nakakainis", "bwakanang", "buang", "bakla", "baklang kanal", "baklang unggoy", "b0b0", "vovo", "8o8o", "obob", "agnat", "gnitap", "tarub", "tewup",
        "noob", "noobs", "trash", "garbage", "ez win", "ez clap", "loser", "get rekt", "rekt", "die", "kms", "t@nga", "kup@l", "sugapa", "itit", "v0v0",
        "kys", "kill yourself", "stfu", "gtfo", "idiota", "bastardo", "puta madre", "coño", "kabayo", "animal", "tamad",
        "batoninam", "anac na lasi ka", "taim", "utin mo", "paltak mo", "baum", "manyakol", "jakolero", "salsalero", "okinnam", "okitnam", "kitnam", "Ag bagtit ka", "Nagbangsit", "Bagaas ti ukim", "Bangsit",
        "agabangatan", "agka ambaing", "makapal so lupam", "magantil", "atapis", "singa ka palpalama, anggapoy amtam ed bilay",
        "Lotdiit ", "lastog", "iyot", "pangso", "anglit", "anghit", "Muting", "ampep", "galas", "nagalas", "Ukininam", "yot ni inam", "Yot ni nam", "Lotdiit",
        "oleg", "buwaya", "baboy", "bakes", "ayep ka", "animal ka", "Binuang", "Ikawng buaanga ka", "Ka boang", "Binuang ra", "Buang", "Buing", " Piste", "Amaw", "Kayata",
        "naragas ka la kumon", "nakirmatan ka kumon", "unsa sawa ka la amo'd baaw"
    }

        Dim cleanText = text.ToLower()

        ' Add word boundaries to prevent false positives
        cleanText = " " & cleanText & " "

        For Each word In badWords
            ' Look for the word with word boundaries (surrounded by non-letter characters)
            If System.Text.RegularExpressions.Regex.IsMatch(cleanText, "\b" & Regex.Escape(word) & "\b", System.Text.RegularExpressions.RegexOptions.IgnoreCase) Then
                Return True
            End If
        Next

        Return False
    End Function

End Class