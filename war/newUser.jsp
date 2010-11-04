<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" type="text/css" href="stylesheets/layout.css">
<link rel="stylesheet" type="text/css" href="stylesheets/colors.css">

<title>New User Setup</title>
</head>
<body>

<div id="main"> 
<% 
	String name = request.getParameter("name");
	String first = name.substring(0, name.indexOf(" "));
	String last = name.substring(name.indexOf(" ") + 1, name.length()); 
	String task = request.getParameter("task");
%>
<form action="/makeuser" method="post">
	First Name: <input type="text" class="textfield" id="firstName" value="<%= first %>" name="firstName" size="23" /> <br /><br />
	Last Name: <input type="text" class="textfield" id="lastName" value="<%= last %>" name="lastName" size="23" /> <br /><br /> 
	E-mail: <input type="text" class="textfield" id="email" name="email" size="23" /><br /><br />
	Phone: <input type="text" class="textfield" id="phone" name="phone" size="23" /><br /><br />
	<input type="hidden" name="task" value="<%=task%>">
	Reminder: 
	<select name="reminder" class="dropdown">
	    <option value="oneDay">One day before events</option>
	    <option value="twoDay">Two days before events</option>
	    <option value="threeDay">Three days before events</option>
	</select>
<br />
	<div class="submit">
		<input type="submit" class="submitButton" value="Submit"/>
	</div>
</form>
 </div>
 
</body>
</html>