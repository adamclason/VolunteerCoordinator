<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" type="text/css" href="stylesheets/layout.css">
<link rel="stylesheet" type="text/css" href="stylesheets/colors.css">

<%@ include file="errorStyle.jsp"  %>

<title>Volunteer Coordinator</title>
</head>

<body>
<div class="navigation"></div>
<div id="main"> 
<%
String name = request.getParameter("name"); 
String task = request.getParameter("task");
if (task == null) {
	task = "";
}
    
    if (name != null) {
        if( name.equals( "none" ) )
        {
            out.println( "<div " + errorStyle + ">Please enter a name.</div>" );
            name = "";
        } else if ( name.equals( "null" ) ) {
        	name = "";
        }
    }
    else {
        name = "";
    }
    
    // if no url given, let user pick where to go
    if (request.getParameter("url") == null) { 
    %>
	<form action="/volunteercoordinator" method="post">	
		I am: <input type="text" name="name" class="textfield" value="<%= name %>" size ="22"><br><br>
		I want to: <select name="task" class ="dropdown">
			<option value="volunteer">Volunteer</option>
			<option value="initiate"<% if (task.equals("initiate")) %>selected="selected"<% ; %>>Initiate a Job</option>
			<option value="manage"<% if (task.equals("manage")) %>selected="selected"<% ; %>>Manage Jobs</option>
		<!-- <option value="dashboard"<% if (task.equals("dashboard")) %>selected="selected"<% ; %>>View Dashboard</option>  -->
			<option value="preferences"<% if (task.equals("preferences")) %>selected="selected"<% ; %>>View/Change Preferences</option>
		</select>
	
<% } else { // if url given, have a button to take user there
	//get url that brought user here and extract the redirect url from it, removing name=null from it in the process
    String url = "";
	String params = request.getQueryString();
	if (params != null) {
		String urlPart = params.split("url=")[1];
		String urlPieces[] = urlPart.split("\\?");
		url = urlPieces[0] + "?"; // /servlet?
		if (urlPieces.length > 1) {
			urlPart = urlPieces[1]; // query1=param&name=null&query2=param
			if (urlPart.contains("name=")) { //Make sure a name parameter exists to be extracted
				int urlTwo = urlPart.indexOf("name=");
				url += urlPart.substring(0, urlTwo); // /servlet?query1=param&
				int urlThree = urlPart.indexOf("&", urlTwo) + 1; //+1 so doesn't include a second '&'
				if (urlThree != -1) {
					url += urlPart.substring(urlThree); // /servlet?query1=param&query2=param
				}
			} else {
				url += urlPart;
			}
		}
	} %>
	<form action="/volunteercoordinator?task=<%=url%>" method="post">	
		I am: <input type="text" name="name" class="textfield" value="<%= name %>" size ="22"><br><br>
<% } %>
	  <div class="submit">
		<input type="submit" id="submitButton" value="Continue"/>
	  </div>
	</form> 	

</div>
</body>
</html>