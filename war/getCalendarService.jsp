<%@ page import="com.google.gdata.client.*" %>
<%@ page import="com.google.gdata.client.calendar.*" %>
<%@ page import="com.google.gdata.data.*" %>
<%@ page import="com.google.gdata.data.acl.*" %>
<%@ page import="com.google.gdata.data.calendar.*" %>
<%@ page import="com.google.gdata.data.extensions.*" %>
<%@ page import="com.google.gdata.util.*" %>
<%@ page import="java.net.URL" %>

<%    
    CalendarService myService = new CalendarService("Volunteer-Coordinator-Calendar"); 
    myService.setUserCredentials("rockcreekvolunteercoordinator@gmail.com", "G0covenant");
%>