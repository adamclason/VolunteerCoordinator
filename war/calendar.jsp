<html>

<head>
<link rel="stylesheet" href="stylesheets/layout.css" type="text/css">
    <link rel="stylesheet" type="text/css" href="stylesheets/colors.css">
    
<%@ page import="java.util.*,
    java.net.URL, javax.jdo.PersistenceManager, 
    com.VolunteerCoordinatorApp.PMF,
    com.VolunteerCoordinatorApp.Volunteer,
    com.google.appengine.api.datastore.Key,
    com.google.appengine.api.datastore.KeyFactory"
%>
</head>

<%@ include file="getCalendarService.jsp" %>

<% String name = request.getParameter("name");
    String usrCalUrl = null;

    //If no user in query string, prompt to log in.
    if (name == null || name.equalsIgnoreCase("null") || name.equals(""))
    {
        String newURL = "/index.jsp?name=none";
        response.sendRedirect( newURL );
        usrCalUrl = "rockcreekvolunteercoordinator%40gmail.com";
    }
    //Otherwise proceed normally.
    else
    {
        //Checks the datastore for the calendar ID associated with this user.
        PersistenceManager pm = PMF.get().getPersistenceManager(); 

        Key k = KeyFactory.createKey(Volunteer.class.getSimpleName(), name);
        Volunteer v = pm.getObjectById(Volunteer.class, k);
        
        usrCalUrl = v.getCalendarId();
        
        //If there was no Url stored in the Volunteer, it calls calendarIdSetter
        //to get one and add it to the volunteer object in the datastore.
        if( usrCalUrl == null )
        {
        %>
            <%@include file="calendarIdSetter.jsp"%>
      <%
            usrCalUrl = volunteer.getCalendarId();
        }
    }
%>

<body>
  
  <ul class="navigation">
    <li><a href="/volunteer.jsp?pageNumber=1&resultIndex=1&name=<%=name%>"> Jobs </a></li>
    <li><a href="/underConstruction.jsp"> My Jobs </a></li>
    <li><a href="/calendar.jsp?name=<%=name%>"> My Calendar </a></li>
    <%@ include file="LinkHome.jsp" %>
  </ul>
  
<div class="content" id="calendar">
<iframe src="http://www.google.com/calendar/embed?height=500&amp;wkst=1&amp;bgcolor=%23FFFFFF&amp;src=<%=usrCalUrl%>&amp;color=%23691426&amp;ctz=America%2FNew_York" style=" border-width:0 " width="700" height="500" frameborder="0" scrolling="no"></iframe>
</div>

</body>

</html>