Public Class Logout
    Inherits System.Web.UI.Page


    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
            ' Clear all session variables
            Session.Clear()
            Session.Abandon()
            ' Optional: Clear authentication cookies if any
            If Request.Cookies("ASP.NET_SessionId") IsNot Nothing Then
                Dim cookie As New HttpCookie("ASP.NET_SessionId")
                cookie.Expires = DateTime.Now.AddDays(-1)
                Response.Cookies.Add(cookie)
            End If
        ' Redirect to login page
        Response.Redirect("Login.aspx")
    End Sub
    End Class
