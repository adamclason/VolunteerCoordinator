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

	//Make sure a first name is provided 
	var fname = document.forms["userForm"]["firstName"].value;
	if (fname==null || fname=="") {
		div = document.getElementById("firstNameError");
		div.innerHTML = "Please provide a first name.";
	    noErrs = false;
	} else {
		div = document.getElementById("firstNameError");
		div.innerHTML = "";
	}
	
	//Make sure a last name is provided, otherwise it'll 
	//give an error when retrieving the user from the datastore 
	var lname = document.forms["userForm"]["lastName"].value;
	if (lname==null || lname=="") {
		div = document.getElementById("lastNameError");
		div.innerHTML = "Please provide a last name.";
	    noErrs = false;
	} else {
		div = document.getElementById("lastNameError");
		div.innerHTML = "";
	}

	//Make sure an email is provided, and that it is a valid email address, 
	//so email reminders can be sent 
	var emailRegEx = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i;
	var eml = document.forms["userForm"]["email"].value;
	if (eml==null || eml=="") {
		div = document.getElementById("emailError");
		div.innerHTML = "Please provide an email address.";
	    noErrs = false;
	} else if (document.forms["userForm"]["email"].value.search(emailRegEx) == -1) {
		div = document.getElementById("emailError");
		div.innerHTML = "Please provide a valid email address.";
	    noErrs = false;
	} else {
		div = document.getElementById("emailError");
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
	<div id="firstNameError" <%=errorStyle%>></div> 
	First Name: <input type="text" class="textfield" id="firstName" value="<%= first %>" name="firstName" size="23" /> <br /><br />
	<div id="lastNameError" <%=errorStyle%>></div> 
	Last Name: <input type="text" class="textfield" id="lastName" value="<%= last %>" name="lastName" size="23" /> <br /><br /> 
	<div id="emailError" <%=errorStyle%>></div> 
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