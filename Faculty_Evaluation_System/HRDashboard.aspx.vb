Imports MySql.Data.MySqlClient
Imports System.Configuration
Imports System.Web
Imports System.Web.UI.HtmlControls
Public Class HRDashboard
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnString As String
        Get
            Return ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString
        End Get
    End Property

    Public Shared Property Newtonsoft As Object

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            ' ✅ Enhanced security check
            If Not IsAuthorized() Then
                Response.Redirect("~/Login.aspx", True)
                Return
            End If

            lblWelcome.Text = HttpUtility.HtmlEncode(Session("FullName"))
            LoadDashboard()
            UpdateSidebarBadges() ' Add this line to update sidebar badges

        End If
    End Sub

    Private Function IsAuthorized() As Boolean
        Return Session("Role") IsNot Nothing AndAlso Session("Role").ToString() = "Admin"
    End Function

    Private Sub LoadDashboard()
        Try
            Using conn As New MySqlConnection(ConnString)
                conn.Open()

                ' ✅ Use parameterized queries for security
                ' Count Students
                Using cmd As New MySqlCommand("SELECT COUNT(*) FROM students WHERE Status = 'Active'", conn)
                    lblStudentsCount.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0")
                End Using

                ' Active Cycle with better error handling
                Using cmd As New MySqlCommand("SELECT Term, CycleName, StartDate, EndDate FROM evaluationcycles WHERE Status = 'Active' LIMIT 1", conn)
                    Using reader As MySqlDataReader = cmd.ExecuteReader()
                        If reader.Read() Then
                            Dim term As String = reader("Term").ToString()
                            Dim cycleName As String = reader("CycleName").ToString()
                            Dim endDate As Date = Convert.ToDateTime(reader("EndDate"))

                            ' Display both Term and CycleName
                            If Not String.IsNullOrEmpty(cycleName) Then
                                lblCycle.Text = $"{term} - {cycleName}"
                            Else
                                lblCycle.Text = term
                            End If

                            ' Add warning if cycle ending soon (within 3 days)
                            If endDate <= Date.Now.AddDays(3) Then
                                lblAlert.Text = $"⚠ Evaluation cycle '{If(Not String.IsNullOrEmpty(cycleName), cycleName, term)}' ending soon: {endDate:MMM dd, yyyy}"
                                lblAlert.CssClass = "alert alert-warning d-block alert-slide"
                            End If
                        Else
                            lblCycle.Text = "No Active Cycle"
                            lblAlert.Text = "⚠ No active evaluation cycle. Activate one to start evaluations."
                            lblAlert.CssClass = "alert alert-warning d-block alert-slide"
                        End If
                    End Using
                End Using

                ' Classes count (only active classes)
                Using cmd As New MySqlCommand("SELECT COUNT(*) FROM classes WHERE IsActive = 1", conn)
                    lblClassesCount.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0")
                End Using

                ' Additional: Faculty count
                Using cmd As New MySqlCommand("SELECT COUNT(*) FROM users WHERE Role = 'Faculty' AND Status = 'Active'", conn)
                    lblFacultyCount.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0")
                End Using
            End Using

        Catch ex As Exception
            ' ✅ Log error and show user-friendly message
            lblAlert.Text = "❌ Error loading dashboard data. Please try again."
            lblAlert.CssClass = "alert alert-danger d-block alert-slide"
            ' Log the actual error (implement your logging mechanism)
            ' Logger.LogError(ex, "Error in LoadDashboard")
        End Try
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

                Dim query = "
            SELECT COUNT(DISTINCT fl.FacultyID) as PendingReleaseCount 
            FROM gradesubmissions gs
            INNER JOIN facultyload fl ON gs.LoadID = fl.LoadID
            WHERE gs.CycleID = @CycleID 
            AND gs.Status = 'Confirmed'
            -- Exclude faculty who already have results released
            AND NOT EXISTS (
                SELECT 1 FROM evaluations e
                INNER JOIN facultyload fl2 ON e.LoadID = fl2.LoadID
                WHERE fl2.FacultyID = fl.FacultyID 
                AND e.CycleID = @CycleID 
                AND e.IsReleased = 2
                LIMIT 1
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

    ' ✅ New method to refresh dashboard data via AJAX
    <System.Web.Services.WebMethod()>
    Public Shared Function GetDashboardStats() As String
        Try
            Dim stats As New Dictionary(Of String, String)
            Dim connString As String = ConfigurationManager.ConnectionStrings("EvalConn").ConnectionString

            Using conn As New MySqlConnection(connString)
                conn.Open()

                ' Students count
                Using cmd As New MySqlCommand("SELECT COUNT(*) FROM students WHERE Status = 'Active'", conn)
                    stats("Students") = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0")
                End Using

                ' Active cycle - now including CycleName
                Using cmd As New MySqlCommand("SELECT Term, CycleName FROM evaluationcycles WHERE Status = 'Active' LIMIT 1", conn)
                    Using reader As MySqlDataReader = cmd.ExecuteReader()
                        If reader.Read() Then
                            Dim term As String = reader("Term").ToString()
                            Dim cycleName As String = reader("CycleName").ToString()

                            If Not String.IsNullOrEmpty(cycleName) Then
                                stats("Cycle") = $"{term} - {cycleName}"
                            Else
                                stats("Cycle") = term
                            End If
                        Else
                            stats("Cycle") = "No Active Cycle"
                        End If
                    End Using
                End Using

                ' Submissions
                Using cmd As New MySqlCommand("SELECT COUNT(*) FROM evaluationsubmissions", conn)
                    stats("Submissions") = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0")
                End Using

                ' Classes count
                Using cmd As New MySqlCommand("SELECT COUNT(*) FROM classes WHERE IsActive = 1", conn)
                    stats("Classes") = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0")
                End Using

                ' Pending requests
                Using cmd As New MySqlCommand("SELECT COUNT(*) FROM passwordresetrequests WHERE Status = 'Pending'", conn)
                    stats("PendingRequests") = Convert.ToInt32(cmd.ExecuteScalar()).ToString()
                End Using
            End Using

            Return Newtonsoft.Json.JsonConvert.SerializeObject(stats)
        Catch ex As Exception
            Return "{}"
        End Try
    End Function

    ' ✅ WebMethod for getting sidebar badge counts
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

End Class

