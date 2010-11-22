<%
    String userName = request.getParameter("name"); 
    String url = "/index.jsp";
    if( userName != null )
    {
        url += "?name=" + userName;
    }
%>
<a id="home" href="<%=url%>"><img src="/stylesheets/images/Home.png" alt="Home" width="32" height="32" /></a>