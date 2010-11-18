<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" type="text/css" href="stylesheets/layout.css">
<link rel="stylesheet" type="text/css" href="stylesheets/colors.css">

<title>Change Preferences</title>
</head>

<body>

<%@ include file="LinkHome.html" %>

<div class="content" id="main">
<%
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String phone = request.getParameter("phone");
    String reminder = request.getParameter("reminder");    
%>
<form action="/editprefs" method="post">
    <input type="hidden" name="name" value="<%= name %>">
	E-mail: <input type="text" class="textfield" id="email" name="email" value="<%= email %>" size="23" /><br /><br />
	Phone: <input type="text" class="textfield" id="phone" name="phone" value="<%= phone %>" size="23" /><br /><br />
    Reminder:
    <select name="reminder" class="dropdown">
	    <option value="oneDay" <% if (reminder.equals("oneDay")) { %>selected="selected"<% } %>>One day before events</option>
	    <option value="twoDay" <% if (reminder.equals("twoDay")) { %>selected="selected"<% } %>>Two days before events</option>
	    <option value="threeDay" <% if (reminder.equals("threeDay")) { %>selected="selected"<% } %>>Three days before events</option>
    </select>
<br />
	<div class="submit">
		<input type="submit" class="submitButton" value="Submit"/>
	</div>
</form>
</div>

</body>
</html>