<%
    String userName = request.getParameter("name"); 
    String url = "/index.jsp";
    if( userName != null && !userName.equals("null"))
    {
        url += "?name=" + userName;
    }
    else
    {
        url += "?name=none";
    }
%>
<a id="home" href="<%=url%>"><img src="/stylesheets/images/Home.png" alt="Home" width="32" height="32" border=0 /></a>