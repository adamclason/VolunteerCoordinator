<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>

<%@ page import="java.net.*,
	java.util.*, 
	com.google.gdata.client.*, 
	com.google.gdata.client.calendar.*,
	com.google.gdata.data.*,
	com.google.gdata.data.acl.*,
	com.google.gdata.data.calendar.*,
	com.google.gdata.data.extensions.*,
	com.google.gdata.util.*,
	com.google.common.collect.Maps,
	java.io.*,
	java.text.SimpleDateFormat"
	
%>

<link rel="stylesheet" type="text/css" href="stylesheets/layout.css" />
<link rel="stylesheet" type="text/css" href="stylesheets/colors.css" />
<link rel="stylesheet" type="text/css" href="stylesheets/jquery-ui-1.8.6.custom.css" />



<script src="javascript/jquery-1.4.2.min.js"> </script>
<script src="javascript/jquery-ui-1.8.6.custom.min.js"> </script>
<script src="javascript/volunteer.js"> </script>	

<title>Volunteer</title>

</head>
<body>

<%
  
   // Determine which page of job results should be displayed  
   String pageNumber = request.getParameter("pageNumber");  
   
   // Used as a label on the bottom of the page 
   String pageLabel = "Page " + request.getParameter("pageNumber"); 

   // The Date and time of an event are stored in Google Calendar 
   // because of its ease of use. Each Google Calendar event has an
   // Event key which corresponds to its event object in the datastore 
   URL feedUrl = new URL("https://www.google.com/calendar/feeds/default/" +
        "private/full?futureevents=true&start-index=" + request.getParameter("resultIndex") + 
        "&orderby=starttime&sortorder=ascending&max-results=10");
  
   CalendarQuery myQuery = new CalendarQuery(feedUrl);
   
   CalendarService myService = new CalendarService("Volunteer-Coordinator-Calendar"); 
   myService.setUserCredentials("rockcreekvolunteercoordinator@gmail.com", "G0covenant");

   // Send the request and receive the response:
   CalendarEventFeed resultFeed = myService.query(myQuery, CalendarEventFeed.class);
  
   List<CalendarEventEntry> results = (List<CalendarEventEntry>)resultFeed.getEntries(); 
   
   // The date and time formats used to display the event 
   // dates and times 
   String datePattern = "MM-dd-yyyy"; 
   SimpleDateFormat dateFormat = new SimpleDateFormat(datePattern);   
  
   String hourPattern = "hh:mma"; 
   SimpleDateFormat timeFormat = new SimpleDateFormat(hourPattern);  
%> 
  <ul class="navigation" id="catnav" style="width: 44.5em"> 
    <li><a href="/manProj.jsp?pageNumber=1&resultIndex=1"> Manage Jobs </a></li>
    <li><a href="/newCat.jsp"> New Category </a></li>
    <li><a href="/catMaint.jsp"> Category Maintennance </a></li>
    <%@ include file="LinkHome.jsp" %>
  </ul>
 
  
<div class="content" id ="myJobs">

	<div id="head">
      <h2> Jobs Needing Volunteers: </h2>
      <div id="filter"><img src="stylesheets/images/filter_button.png"> </img></div>
      <div id="filterSettings" width="300" height = "100"> 
      	<input id="range" type="checkbox"> By Date </input>
      	<div id="textboxes"> 
      		Start: <input id="startRange" type="text" size="10"></input>
      		End: <input id="endRange" type="text" size="10"></input> 
      	</div>
      	<div id="category"> <input type="checkbox"> By Job Category </input></div>
      </div> 
	</div>
	

  <div class="events">
    <% 
    if(results.isEmpty()) {
       %>
       <div class="event"> There are no jobs to display. </div>
       <%
    }  
    else {
    for (CalendarEventEntry entry : results) { %>
      <div class ="event">
       <a href = "/underConstruction.jsp"> 
         <%
           // Get the start and end times for the event 
           When time = entry.getTimes().get(0); 
           DateTime start = time.getStartTime(); 
           DateTime end = time.getEndTime();
           
           start.setTzShift(-240); 
           end.setTzShift(-240); 
           
           // Concert to milliseconds to get a date object, which can be formatted easier. 
           Date startDate = new Date(start.getValue() + 1000 * (start.getTzShift() * 60)); 
           Date endDate = new Date(end.getValue() + 1000 * (end.getTzShift() * 60)); 

           String startDay = dateFormat.format(startDate); 
           String startTime = timeFormat.format(startDate);
           
           String endTime = timeFormat.format(endDate); 
           
           // Access the description field of the calendar 
           // event, where the event description and a list 
           // of volunteers is stored. 
           String content = entry.getPlainTextContent(); 
           Scanner sc = new Scanner(content); 
           String description = "";
           
           String cur = sc.next().trim(); 
           if(cur.equals("<description>")) {
              cur = sc.next(); 
              while(!cur.equals("</description>")) {
                 description += cur + " "; 
                 cur = sc.next(); 
              }
           } if(cur.equals("<volunteers>")) {
           }
         %>
       <div class="date"> 
          <%=startDay%>   
       </div>  
       <div class="title"><%=entry.getTitle().getPlainText()%></div> 
       <div class="description">
          <%=description%> 
       </div>
       <div class="time">
          <%=startTime%><%=" - "%><%=endTime%>
       </div>
       </a>
      </div>
    <% } 
    } %> 
   </div>
   
   <div class="footer">
   <form action="/navigate" method="post">
      <% if (Integer.parseInt(pageNumber) > 1) { %>
         <div id="prevB"> <input type="submit" id="prev" name="navsubmit" value="Prev"></div> 
      <% } %>
      <% if (results.size() == 10) { %> 
         <div id="nextB"> <input type="submit" id="next" name="navsubmit" value="Next"></div> 
      <% } %>
      <input type="hidden" name="pageNum" value="<%=pageNumber%>">
   </form>
   </div>
   <% if (!(results.size() < 10 && Integer.parseInt(pageNumber) == 1)) { %>
      <div id="pageLabel"> <%=pageLabel%> </div>
   <% }   %>
 
</div>

</body>
</html>