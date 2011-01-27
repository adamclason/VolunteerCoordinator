<html>

<head> 
	<link rel="stylesheet" href="stylesheets/layout.css" type="text/css"> 
    <link rel="stylesheet" type="text/css" href="stylesheets/colors.css">
    
<%@ page import="java.util.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
	


</head> 

<%@ include file="getCalendarService.jsp" %>

<%  String name = request.getParameter("name");
    String usrCalUrl;

    //If no user in query string, prompt to log in.
    if (name == null || name.equalsIgnoreCase("null") || name.equals("")) 
    {
        String newURL = "/index.jsp?name=none";
        response.sendRedirect( newURL );
    } 
    //Otherwise proceed normally.
    else 
    {
        CalendarEntry calendar = new CalendarEntry();
        calendar.setTitle(new PlainTextConstruct(name + "'s Jobs"));
        calendar.setSummary(new PlainTextConstruct("This calendar contains the jobs " + name + " has volunteered for."));
        calendar.setTimeZone(new TimeZoneProperty("America/New_York"));
        calendar.setHidden(HiddenProperty.FALSE);

        // Insert the calendar
        URL postUrl = new URL("https://www.google.com/calendar/feeds/default/owncalendars/full");
        CalendarEntry returnedCalendar = myService.insert(postUrl, calendar);
        
        // Get the calender's url
        usrCalUrl = returnedCalendar.getId();
        int splitHere = usrCalUrl.lastIndexOf("/") + 1;
        usrCalUrl = usrCalUrl.substring(splitHere);
        
        //Get feed of results
        URL feedUrl = new URL("https://www.google.com/calendar/feeds/default/private/full");
        CalendarQuery myQuery = new CalendarQuery(feedUrl);
        myQuery.setFullTextQuery(name);
        myQuery.setStringCustomParameter("orderby", "starttime");
        myQuery.setStringCustomParameter("sortorder", "ascending"); 
        CalendarEventFeed resultFeed = myService.query(myQuery, CalendarEventFeed.class);
        List<CalendarEventEntry> results = (List<CalendarEventEntry>)resultFeed.getEntries();
        
        if (!results.isEmpty()) {
        	for (CalendarEventEntry entry : results) {
                //Get the event's details  
                TextConstruct title = entry.getTitle();
                String content = entry.getPlainTextContent(); 
                When time = entry.getTimes().get(0); 
                DateTime start = time.getStartTime(); 
                DateTime end = time.getEndTime();

                //Create a new entry and add it
                URL newUrl = new URL(
                		"http://www.google.com/calendar/feeds/" + usrCalUrl + "/private/full");
                CalendarEventEntry myEntry = new CalendarEventEntry();
                myEntry.setTitle(title);
                myEntry.setContent(new PlainTextConstruct(content));
                When eventTimes = new When();
                eventTimes.setStartTime(start);
                eventTimes.setEndTime(end);
                myEntry.addTime(eventTimes);
                
                // Send the request and receive the response:
                CalendarEventEntry insertedEntry = myService.insert(newUrl, myEntry);
        	}
        }    
    
    

    // The date and time formats used to display the event 
    // dates and times 
    String datePattern = "MM-dd-yyyy"; 
    SimpleDateFormat dateFormat = new SimpleDateFormat(datePattern);   
      
    String hourPattern = "hh:mma"; 
    SimpleDateFormat timeFormat = new SimpleDateFormat(hourPattern); 
    %>

<body>
  
  <ul class="navigation"> 
    <li><a href="/volunteer.jsp?pageNumber=1&resultIndex=1&name=<%=name%>"> Jobs </a></li>
    <li><a href="/underConstruction.jsp"> My Jobs </a></li>
    <li><a href="/calendar.jsp?name=<%=name%>"> My Calendar </a></li>
    <%@ include file="LinkHome.jsp" %>
  </ul>
  
<div class="content" id ="myJobs">  
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
           
           // TODO Automate this switch.
           //(Offset is in minutes)
           //start.setTzShift(-240); 
           //end.setTzShift(-240); 
           
           //Set offset to -300 for non-Daylight Savings time.
           start.setTzShift(-300); 
           end.setTzShift(-300); 
           
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
       <a> 
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
</div>   
   
   
   	
</body> 
<%
    }
%>
</html>