<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" type="text/css" href="stylesheets/layout.css">
<link rel="stylesheet" type="text/css" href="stylesheets/colors.css">

<title>Volunteer Coordinator</title>
</head>

<body>
<div id="main"> 
<%

    String name = request.getParameter("name"); 

    
    if (name != null) {
        if( name.equals( "none" ) )
        {
            out.println( "<b>Please enter a name.</b>" );
            name = "";
        }
    }
    else {
        name = "";
    }
%>
	<form action="/volunteercoordinator" method="post">	
		I am: <input type="text" name="name" class="textfield" value="<%= name %>" size ="22"><br><br>
		I want to: <select name="task" class ="dropdown">
			<option value="volunteer" selected="selected">Volunteer</option>
			<option value="initiate">Initiate a Job</option>
			<option value="manage">Manage Jobs</option>
			<option value="dashboard">View Dashboard</option>
			<option value="preferences">View/Change Preferences</option>
		</select>
		<div class="submit">
		<input type="submit" class="submitButton" value="Submit"/>
		</div>
	</form>
</div>
</body>
</html>