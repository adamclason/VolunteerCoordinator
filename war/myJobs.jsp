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
    java.text.SimpleDateFormat,
    javax.jdo.PersistenceManager,
    com.VolunteerCoordinatorApp.PMF,
    com.VolunteerCoordinatorApp.Category"
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

   String name = request.getParameter("name");
%>
<%@ include file="getUserTimeZone.jsp" %>

<%

   // See if the user has selected some of the filter settings 
   String startRange = request.getParameter("startDate"); 
   String endRange = request.getParameter("endDate"); 
   String cat = request.getParameter("category");
  
   // Determine which page of job results should be displayed  
   String pageNumber = request.getParameter("pageNumber");  
   
   // Used as a label on the bottom of the page 
   String pageLabel = "Page " + request.getParameter("pageNumber"); 

   // The Date and time of an event are stored in Google Calendar 
   // because of its ease of use. 
   URL feedUrl = new URL("https://www.google.com/calendar/feeds/default/private/full"); //&max-results=10");
   
   CalendarQuery myQuery = new CalendarQuery(feedUrl);
 
   CalendarService myService = new CalendarService("Volunteer-Coordinator-Calendar"); 
   myService.setUserCredentials("rockcreekvolunteercoordinator@gmail.com", "G0covenant");

   String usrName = request.getParameter( "name" );
   PersistenceManager pManager = PMF.get().getPersistenceManager(); 
   Key k = KeyFactory.createKey(Volunteer.class.getSimpleName(), usrName);
   Volunteer vol = pManager.getObjectById(Volunteer.class, k);
   String nullString = null;
   URL entryUrl = new URL( "http://www.google.com/calendar/feeds/"
           + vol.getCalendarId() + "/private/full");
   CalendarQuery eventQuery = new CalendarQuery( entryUrl );   
   
   //CalendarEntry usrCal = myService.getEntry( usrCalUrl, CalendarEntry.class, nullString );
   //System.out.println( usrCal.getTitle().getPlainText() );
   
   if(startRange != null && endRange != null && !startRange.equals("null") && !endRange.equals("null")) { //request.getParameter("date") != null && 
      //Calendar curCal = Calendar.getInstance(); 
      SimpleDateFormat format = new SimpleDateFormat("MM/dd/yyyy");
      Date start = format.parse(startRange);
      Date end = format.parse(endRange);  
      DateTime startDT = new DateTime(start); 
      DateTime endDT = new DateTime(end); 

      // shift end date to midnight at end of day instead of beginning of day
      long endL = endDT.getValue();
      endL += 86399999;
      endDT.setValue(endL);
      
      myQuery.setMinimumStartTime(startDT); 
      myQuery.setMaximumStartTime(endDT); 
      eventQuery.setMinimumStartTime( startDT );
      eventQuery.setMaximumStartTime( endDT );
   } else if (request.getParameter("date") != null) {

   } else {
      myQuery.setStringCustomParameter("futureevents", "true"); 
      eventQuery.setStringCustomParameter( "futureevents", "true" );
   }

   if (cat != null && !cat.equals("null")) {
       myQuery.setExtendedPropertyQuery(new CalendarQuery.ExtendedPropertyMatch("category", cat) );
   }

   myQuery.setMaxResults(10); 
   myQuery.setStartIndex(Integer.parseInt(request.getParameter("resultIndex")));
   myQuery.setStringCustomParameter("orderby", "starttime");
   myQuery.setStringCustomParameter("sortorder", "ascending");
   myQuery.setStringCustomParameter("singleevents", "true");
   

   //eventQuery.setMaxResults(10); 
   //eventQuery.setStartIndex(Integer.parseInt(request.getParameter("resultIndex")));
   eventQuery.setStringCustomParameter("orderby", "starttime");
   eventQuery.setStringCustomParameter("sortorder", "ascending");
   //eventQuery.setStringCustomParameter("singleevents", "true");
   CalendarEventFeed usrCalResultFeed = myService.query( eventQuery, CalendarEventFeed.class );
   List<CalendarEventEntry> usrCalResults = ( List<CalendarEventEntry> ) usrCalResultFeed.getEntries();
   
   /*System.out.println( "********************" );
   for( CalendarEventEntry event : usrCalResults )
   {
       System.out.println( event.getTitle().getPlainText() );
   }
   System.out.println( "********************" );*/
   
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
<div class="navigation">
  <ul> 
    <li><a href="/volunteer.jsp?pageNumber=1&resultIndex=1&name=<%=name%>"> Jobs </a></li>
    <li><a href="/myJobs.jsp?pageNumber=1&resultIndex=1&name=<%=name%>"> My Jobs </a></li>
    <li><a href="/calendar.jsp?name=<%=name%>"> My Calendar </a></li>
  </ul>
    <%@ include file="LinkHome.jsp" %>
 </div>
<%
    PersistenceManager pm = PMF.get().getPersistenceManager();
    String query = "select from " + Category.class.getName();
    List<Category> categories = (List<Category>) pm.newQuery(query).execute(); 
%>
  
<div class="content" id ="myJobs">

    <div id="head">
      <h2> Jobs you have volunteered for: </h2>
      <div id="filterButton"><img src="stylesheets/images/filter_button.png"> </img></div>
      <div id="filterSettings"> 
        
        <form action="/navigate" method="post">
        
            <div class="filterSetting">
                <input id="rangeCheckbox" type="checkbox" name="date"> By Date </input>
                <div id="textboxes">
                    Start: <input id="startRange" name="startDate" type="text" size="10"></input>
                    End: <input id="endRange" name = "endDate" type="text" size="10"></input> 
                </div>
            </div>  
            
            <div class="filterSetting"> 
                <input id="categoryCheckbox" type="checkbox" name="catCheck">By Job Category </input>
                <div id="categorySelect">
                    <select name="category" class="dropdown"> 
                        <option>None</option>
                        <% for (Category c : categories) { %>
                        <option><%= c.getName() %></option>
                        <% } %>
                    </select>   
                </div>
            </div>
            
            <div class="filterSetting">
                <div id="submitFilter">
                        <input type="hidden" name="pageNum" value="<%=pageNumber%>">
                        <input type="hidden" name="name" value="<%=name%>">
                        <input type="hidden" name="navsubmit" value="">
                        <input type="hidden" name="src" value="volunteer">
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
    for (CalendarEventEntry entry : usrCalResults) { 
        %>
      <div class ="event">
         <%
           // Get the start and end times for the event 
           When time = entry.getTimes().get(0); 
           DateTime start = time.getStartTime(); 
           DateTime end = time.getEndTime();

           //timeZone was set in getUserTimeZone
           TimeZone TZ =  TimeZone.getTimeZone( timeZone );

           int startOffset = TZ.getOffset( start.getValue() );
           int endOffset = TZ.getOffset( end.getValue() );

           startOffset = ( startOffset / 60 ) / 1000;
           endOffset = ( endOffset / 60 ) / 1000;
           
           start.setTzShift( startOffset );
           end.setTzShift( endOffset );
                      
           // Convert to milliseconds to get a date object, which can be formatted easier. 
           Date startDate = new Date(start.getValue() + 1000 * (start.getTzShift() * 60)); 
           Date endDate = new Date(end.getValue() + 1000 * (end.getTzShift() * 60)); 

           String startDay = dateFormat.format(startDate); 
           String startTime = timeFormat.format(startDate);
           //System.out.println( start.getTzShift() );
           
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
           
            List<ExtendedProperty> propList = entry.getExtendedProperty();
            String acceptedBy = "nobody";
            for (ExtendedProperty prop : propList) 
            {
                if (prop.getName().equals("category")) 
                {
                    category = prop.getValue();
                }
                else if (prop.getName().equals("for")) 
                {
                    forWho = prop.getValue();
                }
                else if (prop.getName().equals("who")) 
                {
                    who = prop.getValue();
                }
                else if (prop.getName().equals("why")) 
                {
                    why = prop.getValue();
                }
                else if( prop.getName().equals( "acceptedBy" ) )
                {
                    acceptedBy = prop.getValue();
                }
            }
         %>
      <% 
      if( acceptedBy.equals( name ) )
      {
      %>
      <div class="innerEvent">
      <div class="date"> 
         <%=startDay%>   
      </div><!-- /date -->  
      <div class="title"><%=title%></div> <!-- /title -->
      <div class="description">
         <%=description%>
      </div><!-- /description -->
      <div class="category">
         <%=category%>
      </div><!-- /category -->
      <div class="time">
         <%=startTime%> - <%=endTime%>
      </div><!-- /time -->
      </div><!-- /innerEvent -->
      <span class="volunteer">
          <a href="/unvolunteer?date=<%=startDay%>&title=<%=title%>&name=<%=name%>&id=<%=entry.getId()%>">Unvolunteer</a>
      </span><!-- /volunteer -->
       <%
       }
       %>
      </div><!-- /event -->
    <% } 
    } %> 
   </div><!-- /events -->
   
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
      <input type="hidden" name="startDate" value="<%=startRange%>">
      <input type="hidden" name="endDate" value="<%=endRange%>">
      <input type="hidden" name="category" value="<%=cat%>">
      <input type="hidden" name="src" value="volunteer">
   </form>
   </div>
   <% if (!(results.size() < 10 && Integer.parseInt(pageNumber) == 1)) { %>
      <div id="pageLabel"> <%=pageLabel%> </div>
   <% }   %>
</div>

</body>
</html>