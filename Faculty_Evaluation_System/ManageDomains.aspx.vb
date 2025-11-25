Imports System.Configuration
Imports System.Runtime.InteropServices
Imports System.Web.ModelBinding
Imports MySql.Data.MySqlClient

Public Class ManageDomains
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    Private hasActiveCycle As Boolean = False

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            ' ✅ Admin only access
            If Session("Role") Is Nothing OrElse Session("Role").ToString() <> "Admin" Then
                Response.Redirect("Login.aspx")
            End If

            ' Check for active evaluation cycle
            hasActiveCycle = CheckActiveEvaluationCycle()

            LoadDomains()
            CalculateTotalWeight()
            UpdateUIForActiveCycle()
        End If
    End Sub

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
            txtDomain.Enabled = False
            txtWeight.Enabled = False
            btnAddDomain.Enabled = False
            btnAddDomain.CssClass = "btn btn-secondary w-100"

            ' Show warning message
            ShowMessage("⚠ Modifications are disabled during active evaluation cycles. Please wait until the current cycle ends.", "warning")
        Else
            ' Enable add form
            txtDomain.Enabled = True
            txtWeight.Enabled = True
            btnAddDomain.Enabled = True
            btnAddDomain.CssClass = "btn btn-primary w-100"
        End If
    End Sub

    ' =======================
    ' LOAD FUNCTIONS
    ' =======================
    Private Sub LoadDomains()
        Using conn As New MySqlConnection(ConnString)
            Dim sql As String = "SELECT DomainID, DomainName, Weight FROM EvaluationDomains WHERE IsActive = 1 ORDER BY DomainName"
            Dim da As New MySqlDataAdapter(sql, conn)
            Dim dt As New DataTable()
            da.Fill(dt)

            gvDomains.DataSource = dt
            gvDomains.DataBind()

            lblDomainCount.Text = dt.Rows.Count.ToString()
        End Using
    End Sub

    Private Sub CalculateTotalWeight()
        Using conn As New MySqlConnection(ConnString)
            conn.Open()
            Dim cmd As New MySqlCommand("SELECT COALESCE(SUM(Weight),0) FROM EvaluationDomains WHERE IsActive = 1", conn)
            lblTotalWeight.Text = cmd.ExecuteScalar().ToString()
        End Using
    End Sub

    ' =======================
    ' ADD DOMAIN
    ' =======================
    Protected Sub btnAddDomain_Click(sender As Object, e As EventArgs)
        ' Check for active evaluation cycle
        If CheckActiveEvaluationCycle() Then
            ShowMessage("⚠ Cannot add domains during active evaluation cycles. Please wait until the current cycle ends.", "danger")
            Return
        End If

        Dim domainName As String = txtDomain.Text.Trim()
        Dim weight As Integer

        If String.IsNullOrEmpty(domainName) Then
            ShowMessage("⚠ Domain name cannot be empty.", "danger")
            Return
        End If

        If Not Integer.TryParse(txtWeight.Text, weight) OrElse weight <= 0 OrElse weight > 100 Then
            ShowMessage("⚠ Weight must be between 1 and 100.", "danger")
            Return
        End If

        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' 🔍 Check if domain exists
            Dim checkSql As String = "SELECT IsActive FROM EvaluationDomains WHERE DomainName=@DomainName LIMIT 1"
            Using checkCmd As New MySqlCommand(checkSql, conn)
                checkCmd.Parameters.AddWithValue("@DomainName", domainName)
                Dim result = checkCmd.ExecuteScalar()

                If result IsNot Nothing Then
                    Dim isActive As Boolean = Convert.ToBoolean(result)

                    If isActive Then
                        ' Already active
                        ShowMessage("⚠ Domain name already exists and is active.", "danger")
                        Return
                    Else
                        ' 🟢 Reactivate if inactive
                        ' Check total weight before reactivating
                        Dim totalCmd As New MySqlCommand("SELECT COALESCE(SUM(Weight),0) FROM EvaluationDomains WHERE IsActive = 1", conn)
                        Dim currentTotal As Integer = Convert.ToInt32(totalCmd.ExecuteScalar())
                        If currentTotal + weight > 100 Then
                            ShowMessage($"⚠ Total weight cannot exceed 100%. Current total is {currentTotal}%.", "danger")
                            Return
                        End If

                        ' Reactivate domain
                        Dim reactivateSql As String = "UPDATE EvaluationDomains 
                                                   SET IsActive=1, Weight=@Weight 
                                                   WHERE DomainName=@DomainName"
                        Using reactivateCmd As New MySqlCommand(reactivateSql, conn)
                            reactivateCmd.Parameters.AddWithValue("@Weight", weight)
                            reactivateCmd.Parameters.AddWithValue("@DomainName", domainName)
                            reactivateCmd.ExecuteNonQuery()
                        End Using

                        ShowMessage("✅ Domain reactivated successfully!", "success")
                        txtDomain.Text = ""
                        txtWeight.Text = "20"
                        LoadDomains()
                        CalculateTotalWeight()
                        Return
                    End If
                End If
            End Using

            ' 🆕 Insert new domain (if it doesn't exist at all)
            Dim totalCmdNew As New MySqlCommand("SELECT COALESCE(SUM(Weight),0) FROM EvaluationDomains WHERE IsActive = 1", conn)
            Dim currentTotalNew As Integer = Convert.ToInt32(totalCmdNew.ExecuteScalar())
            If currentTotalNew + weight > 100 Then
                ShowMessage($"⚠ Total weight cannot exceed 100%. Current total is {currentTotalNew}%.", "danger")
                Return
            End If

            Dim insertSql As String = "INSERT INTO EvaluationDomains (DomainName, Weight, IsActive) VALUES (@DomainName, @Weight, 1)"
            Using cmd As New MySqlCommand(insertSql, conn)
                cmd.Parameters.AddWithValue("@DomainName", domainName)
                cmd.Parameters.AddWithValue("@Weight", weight)
                cmd.ExecuteNonQuery()
            End Using
        End Using

        ShowMessage("✅ Domain added successfully!", "success")
        txtDomain.Text = ""
        txtWeight.Text = "20"
        LoadDomains()
        CalculateTotalWeight()
    End Sub

    ' =======================
    ' GRIDVIEW EVENTS
    ' =======================
    Protected Sub gvDomains_PageIndexChanging(sender As Object, e As GridViewPageEventArgs)
        gvDomains.PageIndex = e.NewPageIndex
        LoadDomains()
    End Sub

    Protected Sub gvDomains_RowEditing(sender As Object, e As GridViewEditEventArgs)
        ' Check for active evaluation cycle
        If CheckActiveEvaluationCycle() Then
            ShowMessage("⚠ Cannot edit domains during active evaluation cycles. Please wait until the current cycle ends.", "danger")
            e.Cancel = True
            Return
        End If

        gvDomains.EditIndex = e.NewEditIndex
        LoadDomains()
    End Sub

    Protected Sub gvDomains_RowCancelingEdit(sender As Object, e As GridViewCancelEditEventArgs)
        gvDomains.EditIndex = -1
        LoadDomains()
    End Sub

    Protected Sub gvDomains_RowUpdating(sender As Object, e As GridViewUpdateEventArgs)
        ' Check for active evaluation cycle
        If CheckActiveEvaluationCycle() Then
            ShowMessage("⚠ Cannot update domains during active evaluation cycles. Please wait until the current cycle ends.", "danger")
            e.Cancel = True
            Return
        End If

        Dim domainID As Integer = Convert.ToInt32(gvDomains.DataKeys(e.RowIndex).Value)
        Dim row As GridViewRow = gvDomains.Rows(e.RowIndex)

        Dim domainName As String = CType(row.FindControl("txtEditDomainName"), TextBox).Text.Trim()
        Dim weight As Integer

        If Not Integer.TryParse(CType(row.FindControl("txtEditWeight"), TextBox).Text, weight) OrElse weight <= 0 OrElse weight > 100 Then
            ShowMessage("⚠ Weight must be between 1 and 100.", "danger")
            Return
        End If

        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' ✅ Check for duplicate active domain name
            Dim dupSql As String = "SELECT COUNT(*) FROM EvaluationDomains 
                                WHERE DomainName=@DomainName AND IsActive=1 AND DomainID<>@DomainID"
            Using dupCmd As New MySqlCommand(dupSql, conn)
                dupCmd.Parameters.AddWithValue("@DomainName", domainName)
                dupCmd.Parameters.AddWithValue("@DomainID", domainID)
                Dim exists As Integer = Convert.ToInt32(dupCmd.ExecuteScalar())
                If exists > 0 Then
                    ShowMessage("⚠ A domain with this name already exists and is active.", "warning")
                    Return
                End If
            End Using

            ' ✅ Check total weight excluding current domain
            Dim totalCmd As New MySqlCommand("SELECT COALESCE(SUM(Weight),0) FROM EvaluationDomains WHERE IsActive = 1 AND DomainID <> @DomainID", conn)
            totalCmd.Parameters.AddWithValue("@DomainID", domainID)
            Dim otherTotal As Integer = Convert.ToInt32(totalCmd.ExecuteScalar())
            If otherTotal + weight > 100 Then
                ShowMessage($"⚠ Total weight cannot exceed 100%. Current total without this domain is {otherTotal}%.", "danger")
                Return
            End If

            ' 🟡 Step 1: Archive old version
            Dim archiveSql As String = "UPDATE EvaluationDomains SET IsActive=0 WHERE DomainID=@DomainID"
            Using archiveCmd As New MySqlCommand(archiveSql, conn)
                archiveCmd.Parameters.AddWithValue("@DomainID", domainID)
                archiveCmd.ExecuteNonQuery()
            End Using

            ' 🟢 Step 2: Insert new version
            Dim insertSql As String = "INSERT INTO EvaluationDomains (DomainName, Weight, IsActive)
                                   VALUES (@DomainName, @Weight, 1)"
            Using insertCmd As New MySqlCommand(insertSql, conn)
                insertCmd.Parameters.AddWithValue("@DomainName", domainName)
                insertCmd.Parameters.AddWithValue("@Weight", weight)
                insertCmd.ExecuteNonQuery()
            End Using
        End Using

        gvDomains.EditIndex = -1
        ShowMessage("✅ Domain updated successfully (new version created)!", "success")
        LoadDomains()
        CalculateTotalWeight()
    End Sub

    Protected Sub gvDomains_RowDeleting(sender As Object, e As GridViewDeleteEventArgs)
        ' Check for active evaluation cycle
        If CheckActiveEvaluationCycle() Then
            ShowMessage("⚠ Cannot delete domains during active evaluation cycles. Please wait until the current cycle ends.", "danger")
            e.Cancel = True
            Return
        End If

        Dim domainID As Integer = Convert.ToInt32(gvDomains.DataKeys(e.RowIndex).Value)

        Using conn As New MySqlConnection(ConnString)
            conn.Open()

            ' Prevent delete if domain has active questions
            Dim checkCmd As New MySqlCommand("SELECT COUNT(*) FROM EvaluationQuestions WHERE DomainID=@DomainID AND IsActive=1", conn)
            checkCmd.Parameters.AddWithValue("@DomainID", domainID)
            Dim count As Integer = Convert.ToInt32(checkCmd.ExecuteScalar())
            If count > 0 Then
                ShowMessage("⚠ Cannot archive this domain because it has active questions.", "danger")
                Return
            End If

            ' Soft delete
            Dim sql As String = "UPDATE EvaluationDomains SET IsActive=0 WHERE DomainID=@DomainID"
            Using cmd As New MySqlCommand(sql, conn)
                cmd.Parameters.AddWithValue("@DomainID", domainID)
                cmd.ExecuteNonQuery()
            End Using
        End Using

        ShowMessage("✅ Domain archived successfully!", "success")
        LoadDomains()
        CalculateTotalWeight()
    End Sub

    ' =======================
    ' GRIDVIEW ROW DATA BOUND
    ' =======================
    Protected Sub gvDomains_RowDataBound(sender As Object, e As GridViewRowEventArgs)
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

    ' =======================
    ' HELPER
    ' =======================
    Private Sub ShowMessage(msg As String, type As String)
        lblMessage.Text = msg
        lblMessage.CssClass = $"alert alert-{type} d-block"
    End Sub

End Class