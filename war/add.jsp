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

<ul class="navigation">
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
        Job Name: <input type="text" name="title" class="textfield" />
        </div> 
        
        <div class="inputItem">
        	Category: 
        	<div class="dropdown"> 
        		<select name="cat" >
        		    <% for (Category c : categories) { %>
        			<option><%= c.getName() %></option>
        			<% } %>
        		</select>
        	</div> 
        </div> 
        
        <div class="inputItem">
        	Description: 
        	<div class="dropdown"> 
        		<input type="text" name="what" class="textfield" />
        	</div> 
        </div> 
        
        <div class="inputItem">
        	When: 
	        <div class="dropdown">
		        <input id="date" type="text" name="when" size="10" class="textField" />
	        </div>
        </div>
        
        <div class="inputItem"> 
        	From
	        <div class="dropdown">
		        <select name="fromHrs">
		        	<option value="00"> 12 </option>
		            <% for (int i = 1; i < 12; i++) {%>
		                    <option value="<% if (i<10) %>0<% ; %><%= i %>">
		                    <%= i %></option>
		            <% } %>
		        </select> :
		        
		        <select name="fromMins">
		            <% for (int i = 0; i < 60; i += 5) {%>
		                    <option value="<% if (i<10) %>0<% ; %><%= i %>">
		                    <% if (i<10) %>0<% ; %><%= i %></option>
		            <% } %>
		        </select>
		        
		        <select name="fromAMPM">
		        	<option value="AM">AM</option> 
		        	<option value="PM">PM</option>
		        </select>	
	        </div> 
        </div>
        
        <div class="inputItem">
        	Until
	        <div class="dropdown"> 
		        <select name="tillHrs">
		        <option value="00"> 12 </option>
		            <% for (int i = 1; i < 12; i++) {%>
		                    <option value="<% if (i<10) %>0<% ; %><%= i %>">
		                    <%= i %></option>
		            <% } %>
		        </select> :
		        <select name="tillMins">
		            <% for (int i = 0; i < 60; i += 5) {%>
		                    <option value="<% if (i<10) %>0<% ; %><%= i %>">
		                    <% if (i<10) %>0<% ; %><%= i %></option>
		            <% } %>
		        </select>
		        
		        <select name="toAMPM">
		        	<option value="AM">AM</option> 
		        	<option value="PM">PM</option>
		        </select>
	        </div>
        </div>
        
        
        <div class="inputItem">
	        For whom:
	        <div class="dropdown"> 
	        	<input type="text" name="for" class="textfield" />
	        </div> 
        </div> 
        
        <div class="inputItem">
	        Who should do it:
	        <div class="dropdown">
	        	<input type="text" name="who" class="textfield" />
	        </div> 
        </div>
        
        <div class="inputItem">
	        Why: 
	        <div class="dropdown"> 
	        	<input type="text" name="why" class="textfield" />
	        </div> 
        </div>
        
        <div class="inputItem">
	        Recurring: 
	        <div class="dropdown"> 
		        <select name="recur" class="dropdown">
		            <option value="none" selected="selected">None</option>
		            <option value="week">Weekly</option>
		            <option value="biweek">Bi-weekly</option>
		            <option value="month">Monthly</option>
		        </select>
	        </div>
        </div> 
       
        <div class="submit">
        	<input type="submit" class="submitButton" value="Submit"/>
        </div>
    </form>
</div>
</body>
</html>