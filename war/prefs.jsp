<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" type="text/css" href="stylesheets/layout.css">
<link rel="stylesheet" type="text/css" href="stylesheets/colors.css">

<title>Edit Your Settings</title>
</head>
<body>

<ul class="navigation" style="width: 24.5em;">
<%@ include file="LinkHome.jsp" %>
</ul>

<div id="main"> 
<% 
    String name = request.getParameter("name");
    if( name == null )
    {
        response.sendRedirect( "/index.jsp?name=none&task=preferences" );
    }
%>
<%@ include file="getUserTimeZone.jsp"%>
<%
PersistenceManager pManager = PMF.get().getPersistenceManager(); 

Key k = KeyFactory.createKey(Volunteer.class.getSimpleName(), name);
Volunteer vol = pManager.getObjectById(Volunteer.class, k);

String estOption = "value=\"America/New_York\"";
String cstOption = "value=\"America/Chicago\"";
String mstOption = "value=\"America/Denver\"";
String pstOption = "value=\"America/Los_Angeles\"";

if( vol.getTimeZone().equals( "America/New_York" ) )
    estOption += " selected";
if( vol.getTimeZone().equals( "America/Chicago" ) )
    cstOption += " selected";
if( vol.getTimeZone().equals( "America/Denver" ) )
    mstOption += " selected";
if( vol.getTimeZone().equals( "America/Los_Angeles" ) )
    pstOption += " selected";

%>
<h2> Edit Preferences: </h2>
<form action="/editprefs" method="post">
    E-mail: <input type="text" class="textfield" id="email" value="<%= vol.getEmail() %>" name="email" size="23" /><br /><br />
    Phone: <input type="text" class="textfield" id="phone" value="<%= vol.getPhone() %>" name="phone" size="23" /><br /><br />
    Reminder: 
    <select name="reminder" class="dropdown">
        <option value="oneDay">One day before events</option>
        <option value="twoDay">Two days before events</option>
        <option value="threeDay">Three days before events</option>
    </select> 
    <br /> <br />
    Time Zone:
    <select name="timeZone" class="dropdown">
        <option <%= estOption %>>Eastern Time</option>
        <option <%= cstOption %>>Central Time</option>
        <option <%= mstOption %>>Mountain Time</option>
        <option <%= pstOption %>>Pacific Time</option>
    </select>
<br />
    <input type="hidden" name="origName" value="<%= name %>"/>
    <div class="submit">
        <input type="submit" class="submitButton" value="Submit"/>
    </div>
</form>
 </div>
 
</body>
</html>