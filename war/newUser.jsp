<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" type="text/css" href="stylesheets/layout.css">
<link rel="stylesheet" type="text/css" href="stylesheets/colors.css">

<%@ include file="errorStyle.jsp"  %>

<script type="text/javascript">
function handleErrors() { //Checks for errors in the form before sending to the servlet
	var noErrs = true;
	var div;

	//Make sure a last name is provided, otherwise it'll 
	//give an error when retrieving the user from the datastore 
	var lname = document.forms["userForm"]["lastName"].value;
	if (lname==null || lname=="") {
		div = document.getElementById("nameError");
		div.innerHTML = "Please provide a last name.";
	    noErrs = false;
	} else {
		div = document.getElementById("nameError");
		div.innerHTML = "";
	}
	
	if (noErrs) { //If no errors, go to servlet and update event 
		document.forms["userForm"].submit();
	}
}
</script>

<title>New User Setup</title>
</head>
<body>

<ul class="navigation" style="width: 24.5em;">
<%@ include file="LinkHome.jsp" %>
</ul>

<div id="main"> 
<% 
	String name = request.getParameter("name");
    String splitName[] = name.split( " " );
    String first = splitName[0];
    String last = "";
    if( splitName.length > 1 )
        last = splitName[splitName.length - 1];
	String task = request.getQueryString().split("task=")[1];
%>
    <h2> Create a New User: </h2>
<form action="/makeuser?task=<%=task%>" method="post" id="userForm">
	First Name: <input type="text" class="textfield" id="firstName" value="<%= first %>" name="firstName" size="23" /> <br /><br />
	<div id="nameError" <%=errorStyle%>></div> 
	Last Name: <input type="text" class="textfield" id="lastName" value="<%= last %>" name="lastName" size="23" /> <br /><br /> 
	E-mail: <input type="text" class="textfield" id="email" name="email" size="23" /><br /><br />
	Phone: <input type="text" class="textfield" id="phone" name="phone" size="23" /><br /><br />
	Reminder: 
	<select name="reminder" class="dropdown">
	    <option value="1">One day before events</option>
	    <option value="2">Two days before events</option>
	    <option value="3">Three days before events</option>
	</select> 
	<br /> <br />
	Time Zone:
	<select name="timezone" class="dropdown">
	    <option value="est">Eastern Time</option>
	    <option value="cst">Central Time</option>
	    <option value="mst">Mountain Time</option>
	    <option value="pst">Pacific Time</option>
	</select>
<br />
	<div class="submit">
		<input type="button" class="submitButton" value="Submit" onclick="handleErrors()"/>
	</div>
</form>
 </div>
 
</body>
</html>