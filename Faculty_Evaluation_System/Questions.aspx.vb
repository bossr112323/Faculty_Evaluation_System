Imports System.Configuration
Imports MySql.Data.MySqlClient

Public Class Questions
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    Private hasActiveCycle As Boolean = False

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            ' ✅ Only Admin can access
            If Session("Role") Is Nothing OrElse Session("Role").ToString() <> "Admin" Then
                Response.Redirect("Login.aspx")
            End If

            lblWelcome.Text = Session("FullName")

            ' Check for active evaluation cycle
            hasActiveCycle = CheckActiveEvaluationCycle()

            ' ✅ check ddlDomain exists before binding
            If ddlDomain IsNot Nothing Then
                LoadDomainsDropdown()
            End If

            LoadQuestionsByDomain()
            UpdateUIForActiveCycle()
            UpdateSidebarBadges()
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

                    ' Pending release count by faculty
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
    ' =======================
    ' CHECK ACTIVE CYCLE
    ' =======================
    Private Function CheckActiveEvaluationCycle() As Boolean
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim sql As String = "SELECT COUNT(*) FROM EvaluationCycles WHERE Status = 'Active' AND IsActive = 1"
            Using cmd As New MySqlCommand(sql, conn)
                Return Convert.ToInt32(cmd.ExecuteScalar()) > 0
            End Using
        End Using
    End Function

    ' =======================
    ' UPDATE UI BASED ON ACTIVE CYCLE
    ' =======================
    Private Sub UpdateUIForActiveCycle()
        If hasActiveCycle Then
            ' Disable add form
            txtQuestion.Enabled = False
            ddlDomain.Enabled = False
            btnAddQuestion.Enabled = False
            btnAddQuestion.CssClass = "btn btn-secondary w-100"

            ' Show warning message
            lblMessage.Text = "⚠ Modifications are disabled during active evaluation cycles. Please wait until the current cycle ends."
            lblMessage.CssClass = "alert alert-warning d-block alert-slide"
        Else
            ' Enable add form
            txtQuestion.Enabled = True
            ddlDomain.Enabled = True
            btnAddQuestion.Enabled = True
            btnAddQuestion.CssClass = "btn btn-primary w-100"
        End If
    End Sub

    ' Load domains into Add Question dropdown
    Private Sub LoadDomainsDropdown()
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "SELECT DomainID, DomainName FROM evaluationdomains  WHERE IsActive = 1 ORDER BY DomainName"
            Dim da As New MySqlDataAdapter(sql, conn)
            Dim dt As New DataTable()
            da.Fill(dt)

            ddlDomain.DataSource = dt
            ddlDomain.DataTextField = "DomainName"
            ddlDomain.DataValueField = "DomainID"
            ddlDomain.DataBind()
        End Using

        ddlDomain.Items.Insert(0, New ListItem("Select Domain", ""))
    End Sub

    ' Load all domains (for repeater)
    Private Sub LoadQuestionsByDomain()
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "SELECT DomainID, DomainName, Weight FROM evaluationdomains WHERE IsActive = 1 ORDER BY DomainID"
            Dim da As New MySqlDataAdapter(sql, conn)
            Dim dt As New DataTable()
            da.Fill(dt)

            rptDomains.DataSource = dt
            rptDomains.DataBind()
        End Using
    End Sub

    ' Bind questions for each domain
    Protected Sub rptDomains_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            Dim hf As HiddenField = CType(e.Item.FindControl("hfDomainID"), HiddenField)
            Dim gv As GridView = CType(e.Item.FindControl("gvDomainQuestions"), GridView)

            Using conn As New MySqlConnection(ConnString)
                Dim sql As String = "SELECT QuestionID, QuestionText, Scale FROM evaluationquestions WHERE DomainID=@DomainID AND IsActive = 1  ORDER BY QuestionID"
                Using cmd As New MySqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@DomainID", hf.Value)
                    Dim da As New MySqlDataAdapter(cmd)
                    Dim dt As New DataTable()
                    da.Fill(dt)

                    ' ✅ Set EditIndex if stored in ViewState
                    Dim key As String = "EditIndex_" & hf.Value
                    If ViewState(key) IsNot Nothing Then
                        gv.EditIndex = Convert.ToInt32(ViewState(key))
                    End If

                    gv.DataSource = dt
                    gv.DataBind()
                End Using
            End Using
        End If
    End Sub

    ' Add new question
    Protected Sub btnAddQuestion_Click(sender As Object, e As EventArgs)
        ' Check for active evaluation cycle
        If CheckActiveEvaluationCycle() Then
            lblMessage.Text = "⚠ Cannot add questions during active evaluation cycles. Please wait until the current cycle ends."
            lblMessage.CssClass = "alert alert-danger d-block alert-slide"
            Return
        End If

        If String.IsNullOrWhiteSpace(txtQuestion.Text) OrElse ddlDomain.SelectedValue = "" Then
            lblMessage.Text = "⚠ Question and Domain are required."
            lblMessage.CssClass = "alert alert-danger d-block alert-slide"
            Return
        End If

        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' 🔍 Check if the question exists in the same domain
            Dim checkSql As String = "SELECT IsActive FROM evaluationquestions 
                                  WHERE QuestionText=@QuestionText AND DomainID=@DomainID LIMIT 1"
            Using checkCmd As New MySqlCommand(checkSql, conn)
                checkCmd.Parameters.AddWithValue("@QuestionText", txtQuestion.Text.Trim())
                checkCmd.Parameters.AddWithValue("@DomainID", ddlDomain.SelectedValue)

                Dim result = checkCmd.ExecuteScalar()

                ' ✅ If the question exists
                If result IsNot Nothing Then
                    Dim isActive As Boolean = Convert.ToBoolean(result)

                    If isActive Then
                        ' Already active — do not insert again
                        lblMessage.Text = "⚠ This question already exists and is active."
                        lblMessage.CssClass = "alert alert-warning d-block alert-slide"
                        Return
                    Else
                        ' 🟢 Reactivate if inactive
                        Dim updateSql As String = "UPDATE evaluationquestions 
                                               SET IsActive=1 
                                               WHERE QuestionText=@QuestionText AND DomainID=@DomainID"
                        Using updateCmd As New MySqlCommand(updateSql, conn)
                            updateCmd.Parameters.AddWithValue("@QuestionText", txtQuestion.Text.Trim())
                            updateCmd.Parameters.AddWithValue("@DomainID", ddlDomain.SelectedValue)
                            updateCmd.ExecuteNonQuery()
                        End Using

                        lblMessage.Text = "✅ Question reactivated successfully!"
                        lblMessage.CssClass = "alert alert-success d-block alert-slide"
                        txtQuestion.Text = ""
                        LoadQuestionsByDomain()
                        Return
                    End If
                End If
            End Using

            ' 🆕 Insert new question (if it doesn't exist)
            Dim insertSql As String = "INSERT INTO evaluationquestions (QuestionText, Scale, DomainID, IsActive) 
                                   VALUES (@QuestionText, 5, @DomainID, 1)"
            Using cmd As New MySqlCommand(insertSql, conn)
                cmd.Parameters.AddWithValue("@QuestionText", txtQuestion.Text.Trim())
                cmd.Parameters.AddWithValue("@DomainID", ddlDomain.SelectedValue)
                cmd.ExecuteNonQuery()
            End Using
        End Using

        txtQuestion.Text = ""
        lblMessage.Text = "✅ Question added successfully!"
        lblMessage.CssClass = "alert alert-success d-block alert-slide"
        LoadQuestionsByDomain()
    End Sub

#Region "GridView Events"

    Protected Sub gvDomainQuestions_PageIndexChanging(sender As Object, e As GridViewPageEventArgs)
        Dim gv As GridView = CType(sender, GridView)
        gv.PageIndex = e.NewPageIndex
        LoadQuestionsByDomain()
    End Sub

    Protected Sub gvDomainQuestions_RowEditing(sender As Object, e As GridViewEditEventArgs)
        ' Check for active evaluation cycle
        If CheckActiveEvaluationCycle() Then
            lblMessage.Text = "⚠ Cannot edit questions during active evaluation cycles. Please wait until the current cycle ends."
            lblMessage.CssClass = "alert alert-danger d-block alert-slide"
            e.Cancel = True
            Return
        End If

        Dim gv As GridView = CType(sender, GridView)
        Dim container As RepeaterItem = CType(gv.NamingContainer, RepeaterItem)
        Dim hfDomainID As HiddenField = CType(container.FindControl("hfDomainID"), HiddenField)

        Dim key As String = "EditIndex_" & hfDomainID.Value
        ViewState(key) = e.NewEditIndex

        LoadQuestionsByDomain()
    End Sub

    Protected Sub gvDomainQuestions_RowCancelingEdit(sender As Object, e As GridViewCancelEditEventArgs)
        Dim gv As GridView = CType(sender, GridView)
        Dim container As RepeaterItem = CType(gv.NamingContainer, RepeaterItem)
        Dim hfDomainID As HiddenField = CType(container.FindControl("hfDomainID"), HiddenField)

        Dim key As String = "EditIndex_" & hfDomainID.Value
        ViewState.Remove(key)

        LoadQuestionsByDomain()
    End Sub

    Protected Sub gvDomainQuestions_RowUpdating(sender As Object, e As GridViewUpdateEventArgs)
        ' Check for active evaluation cycle
        If CheckActiveEvaluationCycle() Then
            lblMessage.Text = "⚠ Cannot update questions during active evaluation cycles. Please wait until the current cycle ends."
            lblMessage.CssClass = "alert alert-danger d-block alert-slide"
            e.Cancel = True
            Return
        End If

        Dim gv As GridView = CType(sender, GridView)
        Dim row As GridViewRow = gv.Rows(e.RowIndex)
        Dim QuestionID As Integer = Convert.ToInt32(gv.DataKeys(e.RowIndex).Value)

        Dim txtEditQuestion As TextBox = CType(row.FindControl("txtEditQuestion"), TextBox)
        Dim ddlEditScale As DropDownList = CType(row.FindControl("ddlEditScale"), DropDownList)

        Dim container As RepeaterItem = CType(gv.NamingContainer, RepeaterItem)
        Dim hfDomainID As HiddenField = CType(container.FindControl("hfDomainID"), HiddenField)
        Dim domainID As Integer = Convert.ToInt32(hfDomainID.Value)

        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' ✅ Check for duplicates (exclude current question being updated)
            Dim checkSql As String = "SELECT COUNT(*) FROM evaluationquestions 
                                  WHERE QuestionText=@QuestionText 
                                  AND DomainID=@DomainID 
                                  AND QuestionID<>@QuestionID"
            Using checkCmd As New MySqlCommand(checkSql, conn)
                checkCmd.Parameters.AddWithValue("@QuestionText", txtEditQuestion.Text.Trim())
                checkCmd.Parameters.AddWithValue("@DomainID", domainID)
                checkCmd.Parameters.AddWithValue("@QuestionID", QuestionID)

                Dim exists As Integer = Convert.ToInt32(checkCmd.ExecuteScalar())
                If exists > 0 Then
                    lblMessage.Text = "⚠ This question already exists in the selected domain."
                    lblMessage.CssClass = "alert alert-warning d-block alert-slide"
                    Return
                End If
            End Using

            ' ✅ Proceed with update only if no duplicate
            Dim sql As String = "UPDATE evaluationquestions 
                             SET QuestionText=@QuestionText, Scale=@Scale 
                             WHERE QuestionID=@QuestionID"
            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@QuestionText", txtEditQuestion.Text.Trim())
                cmd.Parameters.AddWithValue("@Scale", ddlEditScale.SelectedValue)
                cmd.Parameters.AddWithValue("@QuestionID", QuestionID)
                cmd.ExecuteNonQuery()
            End Using
        End Using

        ' ✅ Reset edit mode
        Dim key As String = "EditIndex_" & domainID
        ViewState.Remove(key)

        LoadQuestionsByDomain()
        lblMessage.Text = "✅ Question updated successfully!"
        lblMessage.CssClass = "alert alert-success d-block alert-slide"
    End Sub

    Protected Sub gvDomainQuestions_RowDeleting(sender As Object, e As GridViewDeleteEventArgs)
        ' Check for active evaluation cycle
        If CheckActiveEvaluationCycle() Then
            lblMessage.Text = "⚠ Cannot delete questions during active evaluation cycles. Please wait until the current cycle ends."
            lblMessage.CssClass = "alert alert-danger d-block alert-slide"
            e.Cancel = True
            Return
        End If

        Dim gv As GridView = CType(sender, GridView)
        Dim QuestionID As Integer = Convert.ToInt32(gv.DataKeys(e.RowIndex).Value)

        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim sql As String = "UPDATE evaluationquestions SET IsActive=0 WHERE QuestionID=@QuestionID"
            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@QuestionID", QuestionID)
                cmd.ExecuteNonQuery()
            End Using
        End Using

        LoadQuestionsByDomain()
        lblMessage.Text = "✅ Question archived successfully!"
        lblMessage.CssClass = "alert alert-success d-block alert-slide"
    End Sub

    Protected Sub gvDomainQuestions_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        Dim gv As GridView = CType(sender, GridView)
        If e.CommandName = "Edit" Then
            gv.EditIndex = Convert.ToInt32(e.CommandArgument)
            LoadQuestionsByDomain()
        ElseIf e.CommandName = "Cancel" Then
            gv.EditIndex = -1
            LoadQuestionsByDomain()
        End If
    End Sub

    ' Hide edit/delete buttons when there's an active evaluation cycle
    Protected Sub gvDomainQuestions_RowDataBound(sender As Object, e As GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            ' Hide edit/delete buttons if there's an active evaluation cycle
            If CheckActiveEvaluationCycle() Then
                Dim btnEdit As LinkButton = TryCast(e.Row.FindControl("btnEdit"), LinkButton)
                Dim btnDelete As LinkButton = TryCast(e.Row.FindControl("btnDelete"), LinkButton)

                If btnEdit IsNot Nothing Then
                    btnEdit.Visible = False
                End If
                If btnDelete IsNot Nothing Then
                    btnDelete.Visible = False
                End If
            End If
        End If
    End Sub

#End Region

End Class