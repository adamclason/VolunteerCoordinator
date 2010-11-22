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

   // See if the user has selected some of the filter settings 
   String startRange = request.getParameter("startDate"); 
   String endRange = request.getParameter("endDate");  

   String name = request.getParameter("name");

  
   // Determine which page of job results should be displayed  
   String pageNumber = request.getParameter("pageNumber");  
   
   // Used as a label on the bottom of the page 
   String pageLabel = "Page " + request.getParameter("pageNumber"); 

   // The Date and time of an event are stored in Google Calendar 
   // because of its ease of use. 
   URL feedUrl = new URL("https://www.google.com/calendar/feeds/default/private/full"); //&max-results=10");
  
   CalendarQuery myQuery = new CalendarQuery(feedUrl);
   
   if(request.getParameter("date") != null && startRange  != null  && endRange != null) {
   	  System.out.println(request.getParameter("date"));
   	  Calendar curCal = Calendar.getInstance(); 
      SimpleDateFormat format = new SimpleDateFormat("MM/dd/yyyy");
      Date start = format.parse(startRange);
      Date end = format.parse(endRange);  
      DateTime startDT = new DateTime(start); 
      DateTime endDT = new DateTime(end); 
      myQuery.setMinimumStartTime(startDT); 
      myQuery.setMaximumStartTime(endDT); 
   } else if (request.getParameter("date") != null) {
   	  
   } else {
      myQuery.setStringCustomParameter("futureevents", "true"); 
   }

   myQuery.setMaxResults(10); 
   myQuery.setStartIndex(Integer.parseInt(request.getParameter("resultIndex")));
   myQuery.setStringCustomParameter("orderby", "starttime");
   myQuery.setStringCustomParameter("sortorder", "ascending");  
 
   
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
  <ul class="navigation"> 
    <li><a href="/volunteer.jsp?pageNumber=1&resultIndex=1&name=<%=name%>"> Jobs </a></li>
    <li><a href="/underConstruction.jsp"> My Jobs </a></li>
    <li><a href="/calendar.jsp"> My Calendar </a></li>
    <%@ include file="LinkHome.jsp" %>
    <li><a href="/calendar.jsp&name=<%=name%>"> My Calendar </a></li>
  </ul>
 
  
<div class="content" id ="myJobs">

	<div id="head">
      <h2> Jobs Needing Volunteers: </h2>
      <div id="filterButton"><img src="stylesheets/images/filter_button.png"> </img></div>
      <div id="filterSettings"> 
      	
      	<form action="/volunteer.jsp?pageNumber=1&resultIndex=1" method="post">
      	
	      	<div class="filterSetting">
	      		<input id="rangeCheckbox" type="checkbox" name="date"> By Date </input>
	      		<div id="textboxes"> 
	      			Start: <input id="startRange" name="startDate" type="text" size="10"></input>
	      			End: <input id="endRange" name = "endDate" type="text" size="10"></input> 
	      		</div>
	      	</div>	
	      	
	      	<div class="filterSetting"> 
	      		<input id="categoryCheckbox" type="checkbox">By Job Category </input>
	      		<div id="categorySelect">
		      		<select name="category" class="dropdown"> 
		      			<option value="Category 1">Category 1 </option> 
		      			<option value="Category 2">Category 2 </option> 
		      			<option value="Category 3">Category 3 </option> 
		      		</select> 	
	      		</div>
	      	</div>
	      	
	      	<div class="filterSetting">
		      	<div id="submitFilter">
		      		<input id="submitButton" type="submit" value="Submit"> </input> 
		      	</div>
	      	</div>
      	
      	</form>
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
           
           String title = entry.getTitle().getPlainText();
           
           // Access the description field of the calendar 
           // event, where the event description and a list 
           // of volunteers is stored. 
           String content = entry.getPlainTextContent(); 
           Scanner sc = new Scanner(content); 
           String description = "";
           String forWho = "";
           String who = "";
           String why = "";
           String category = "";
           String volList = "";
           
           String cur = sc.next().trim();
           if(cur.equals("<description>")) 
           {
              cur = sc.next(); 
              while(!cur.equals("</description>")) 
              {
                 description += cur + " ";
                 cur = sc.next(); 
              }
              if (sc.hasNext()) 
              {
                  cur = sc.next();
              }
           }
           if( cur.equals( "<for>" ) )
           {
               cur = sc.next();
               while( !cur.equals( "</for>" ) )
               {
                   forWho += cur + " ";
                   cur = sc.next(); 
                }
                if (sc.hasNext()) 
                {
                    cur = sc.next();
                }
           }
           if( cur.equals( "<who>" ) )
           {
               cur = sc.next();
               while( !cur.equals( "</who>" ) )
               {
                   who += cur + " ";
                   cur = sc.next(); 
                }
                if (sc.hasNext()) 
                {
                    cur = sc.next();
                }
           }
           if( cur.equals( "<why>" ) )
           {
               cur = sc.next();
               while( !cur.equals( "</why>" ) )
               {
                   why += cur + " ";
                   cur = sc.next(); 
                }
                if (sc.hasNext()) 
                {
                    cur = sc.next();
                }
           }
           if(cur.equals("<category>")) 
           {
               cur = sc.next();
               while(!cur.equals("</category>")) 
               {
                  category += cur + " "; 
                  cur = sc.next(); 
               }
               if (sc.hasNext()) 
               {
                   cur = sc.next();
               }
           } 
           if(cur.equals("<volunteers>")) 
           {
               cur = sc.next();
               while(!cur.equals("</volunteers>")) 
               {
                  volList += cur + " "; 
                  cur = sc.next(); 
               }
               if (sc.hasNext()) 
               {
                   cur = sc.next();
               }
           }
         %>
       <a href = "/addvolunteer?date=<%=startDay%>&title=<%=title%>&name=<%=name%>"> 
       <div class="date"> 
          <%=startDay%>   
       </div>  
       <div class="title"><%=title%></div> 
       <div class="description">
          <%=description%>
       </div>
       <div class="category">
          <%=category%>
       </div>
       <div class="time">
          <%=startTime%> - <%=endTime%>
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
      <input type="hidden" name="name" value="<%=name%>">
   </form>
   </div>
   <% if (!(results.size() < 10 && Integer.parseInt(pageNumber) == 1)) { %>
      <div id="pageLabel"> <%=pageLabel%> </div>
   <% }   %>
 
</div>

</body>
</html>