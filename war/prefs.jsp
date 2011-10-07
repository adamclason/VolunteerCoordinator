<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" type="text/css" href="stylesheets/layout.css">
<link rel="stylesheet" type="text/css" href="stylesheets/colors.css">

<%@ include file="errorStyle.jsp"  %>

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

<script type="text/javascript">
function handleErrors() { //Checks for errors in the form before sending to the servlet
	var noErrs = true;
	var div;

	//Make sure an email is provided, and that it is a valid email address, 
	//so email reminders can be sent 
	var emailRegEx = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i;
	var eml = document.forms["prefForm"]["email"].value;
	if (eml==null || eml=="") {
		div = document.getElementById("emailError");
		div.innerHTML = "Please provide an email address.";
	    noErrs = false;
	} else if (document.forms["prefForm"]["email"].value.search(emailRegEx) == -1) {
		div = document.getElementById("emailError");
		div.innerHTML = "Please provide a valid email address.";
	    noErrs = false;
	} else {
		div = document.getElementById("emailError");
		div.innerHTML = "";
	}
	
	if (noErrs) { //If no errors, go to servlet and update event 
		document.forms["prefForm"].submit();
	}
}
</script>
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

String remind1 = new String("\"1\"");
String remind2 = new String("\"2\"");
String remind3 = new String("\"3\"");

if (vol.getReminder().equals("1"))
	remind1 += " selected";
if (vol.getReminder().equals("2"))
	remind2 += " selected";
if (vol.getReminder().equals("3"))
	remind3 += " selected";

%>
<h2> Edit Preferences: </h2>
<form action="/editprefs" method="post" id="prefForm"> 
	<div id="emailError" <%=errorStyle%>></div> 
    E-mail: <input type="text" class="textfield" id="email" value="<%= vol.getEmail() %>" name="email" size="23" /><br /><br />
    Phone: <input type="text" class="textfield" id="phone" value="<%= vol.getPhone() %>" name="phone" size="23" /><br /><br />
    Reminder: 
    <select name="reminder" class="dropdown">
        <option value=<%=remind1%>>One day before events</option>
        <option value=<%=remind2%>>Two days before events</option>
        <option value=<%=remind3%>>Three days before events</option>
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
        <input type="button" class="submitButton" value="Submit" onclick="handleErrors()"/>
    </div>
</form>
 </div>
 
</body>
</html>