<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="com.VolunteerCoordinatorApp.PMF" %>
<%@ page import="com.VolunteerCoordinatorApp.Category" %>

<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<link rel="stylesheet" type="text/css" href="stylesheets/layout.css" />
<link rel="stylesheet" type="text/css" href="stylesheets/colors.css" />
<link type="text/css" href="stylesheets/jquery-ui-1.8.6.custom.css" rel="Stylesheet" />

<script src="http://code.jquery.com/jquery-1.4.3.min.js"> </script>
<script src="javascript/jquery-ui-1.8.6.custom.min.js"> </script>
<script src="javascript/addEvent.js"> </script>

<title>Add Job</title>
</head>

<body>

<% String name = request.getParameter("name"); 
String desc = request.getParameter("desc"); 
String forWho = request.getParameter("for"); 
String who = request.getParameter("who"); 
String why = request.getParameter("why"); 
String cat = request.getParameter("cat"); 
String fromHrs = request.getParameter("fromHrs"); 
String fromMins = request.getParameter("fromMins"); 
String tillHrs = request.getParameter("tillHrs"); 
String tillMins = request.getParameter("tillMins"); 
String fromAMPM = request.getParameter("fromAMPM"); 
String toAMPM = request.getParameter("toAMPM"); 
String date = request.getParameter("when"); 
String recur = request.getParameter("recur"); 

// deal with null parameters
if (desc == null) {
	desc = "";
} if (forWho == null) {
	forWho = "";
} if (who == null) {
	who = "";
} if (why == null) {
	why = "";
} if (cat == null) {
	cat = "";
} if (fromHrs == null) {
	fromHrs = "";
} if (fromMins == null) {
	fromMins = "";
} if (tillHrs == null) {
	tillHrs = "";
} if (tillMins == null) {
	tillMins = "";
} if (fromAMPM == null) {
	fromAMPM = "";
} if (toAMPM == null) {
	toAMPM = "";
} if (date == null) {
	date = "";
} if (recur == null) {
	recur = "";
}

if(fromAMPM.equals("PM")) { 
        fromHrs = Integer.toString(Integer.parseInt(fromHrs) - 12);
}
if(toAMPM.equals("PM")) { 
        tillHrs = Integer.toString(Integer.parseInt(tillHrs) - 12);
}

System.err.println(fromHrs + " " + tillHrs); %>

<ul class="navigation" style="width: 29.5em;">
<%@ include file="LinkHome.jsp" %>
</ul>

<%
    PersistenceManager pm = PMF.get().getPersistenceManager();
    String query = "select from " + Category.class.getName();
    List<Category> categories = (List<Category>) pm.newQuery(query).execute();
%>

<div class="content" id="addEvent">
    <form method="post" action="/makeevent">
    	<div class="inputItem"> 
        Job Name: <input type="text" name="title" class="textfield" value="<%= name %>" />
        </div> 
        
        <div class="inputItem">
        	Category: 
        	<div class="dropdown"> 
        		<select name="cat" >
        		    <option>None</option>
        		    <% for (Category c : categories) { %>
        			<option <% if (cat.equals(c.getName())) %>selected="selected"<% ; %>><%= c.getName() %></option>
        			<% } %>
        		</select>
        	</div> 
        </div> 
        
        <div class="inputItem">
        	Description: 
        	<div class="dropdown"> 
        		<input type="text" name="what" class="textfield" value="<%= desc %>" />
        	</div> 
        </div> 
        
        <div class="inputItem">
        	When: 
	        <div class="dropdown">
		        <input id="date" type="text" name="when" size="10" class="textField" value="<%= date %>" />
	        </div>
        </div>
        
        <%         
        if (request.getParameter("errordate") != null) {
            out.println( "<b>Start time must be less than or equal to end time.</b>" );
        }
        %>
        
        <div class="inputItem"> 
        	From
	        <div class="dropdown">
		        <select name="fromHrs">
		        	<option value="00" <% if (fromHrs.equals("00") || fromHrs.equals("0")) %>selected="selected"<% ; %>>12</option>
		            <% for (int i = 1; i < 12; i++) {%>
		                    <option value="<% if (i<10) %>0<% ; %><%= i %>" <% if (fromHrs.equals("0" + i) || fromHrs.equals(Integer.toString(i))) %>selected="selected"<% ; %>>
		                    <%= i %></option>
		            <% } %>
		        </select> :
		        
		        <select name="fromMins">
		            <% for (int i = 0; i < 60; i += 5) {%>
		                    <option value="<% if (i<10) %>0<% ; %><%= i %>" <% if (fromMins.equals("0" + i) || fromMins.equals(Integer.toString(i))) %>selected="selected"<% ; %>>
		                    <% if (i<10) %>0<% ; %><%= i %></option>
		            <% } %>
		        </select>
		        
		        <select name="fromAMPM">
		        	<option value="AM" <% if (fromAMPM.equals("AM")) %>selected="selected"<% ; %>>AM</option> 
		        	<option value="PM" <% if (fromAMPM.equals("PM")) %>selected="selected"<% ; %>>PM</option>
		        </select>	
	        </div> 
        </div>
        
        <div class="inputItem">
        	Until
	        <div class="dropdown"> 
		        <select name="tillHrs">
		        <option value="00" <% if (tillHrs.equals("00")) %>selected="selected"<% ; %>> 12 </option>
		            <% for (int i = 1; i < 12; i++) {%>
		                    <option value="<% if (i<10) %>0<% ; %><%= i %>" <% if (tillHrs.equals("0" + i) || tillHrs.equals(Integer.toString(i))) %>selected="selected"<% ; %>>
		                    <%= i %></option>
		            <% } %>
		        </select> :
		        <select name="tillMins">
		            <% for (int i = 0; i < 60; i += 5) {%>
		                    <option value="<% if (i<10) %>0<% ; %><%= i %>" <% if (tillMins.equals("0" + i) || tillMins.equals(Integer.toString(i))) %>selected="selected"<% ; %>>
		                    <% if (i<10) %>0<% ; %><%= i %></option>
		            <% } %>
		        </select>
		        
		        <select name="toAMPM">
		        	<option value="AM" <% if (toAMPM.equals("AM")) %>selected="selected"<% ; %>>AM</option> 
		        	<option value="PM" <% if (toAMPM.equals("PM")) %>selected="selected"<% ; %>>PM</option>
		        </select>
	        </div>
        </div>
        
        
        <div class="inputItem">
	        For whom:
	        <div class="dropdown"> 
	        	<input type="text" name="for" class="textfield" value="<%= forWho %>" />
	        </div> 
        </div> 
        
        <div class="inputItem">
	        Who should do it:
	        <div class="dropdown">
	        	<input type="text" name="who" class="textfield" value="<%= who %>" />
	        </div> 
        </div>
        
        <div class="inputItem">
	        Why: 
	        <div class="dropdown"> 
	        	<input type="text" name="why" class="textfield" value="<%= why %>" />
	        </div> 
        </div>
        
        <div class="inputItem">
	        Recurring: 
	        <div class="dropdown"> 
		        <select name="recur" class="dropdown">
		            <option value="none" <% if (recur.equals("none")) %>selected="selected"<% ; %>>None</option>
		            <option value="week"<% if (recur.equals("week")) %>selected="selected"<% ; %>>Weekly</option>
		            <option value="biweek"<% if (recur.equals("biweek")) %>selected="selected"<% ; %>>Bi-weekly</option>
		            <option value="month"<% if (recur.equals("month")) %>selected="selected"<% ; %>>Monthly</option>
		        </select>
	        </div>
        </div> 
        
        <input type="hidden" name="name" value="<%=name%>">
       
        <div class="submit">
        	<input type="submit" class="submitButton" value="Submit"/>
        </div>
    </form>
</div>
</body>
</html>