<html>

<head> 
	<link rel="stylesheet" href="stylesheets/layout.css" type="text/css"> 
    <link rel="stylesheet" type="text/css" href="stylesheets/colors.css">
    
<%@ page import="java.util.*"%>
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
%>

<body>
  
  <ul class="navigation"> 
    <li><a href="/volunteer.jsp?pageNumber=1&resultIndex=1&name=<%=name%>"> Jobs </a></li>
    <li><a href="/underConstruction.jsp"> My Jobs </a></li>
    <li><a href="/calendar.jsp?name=<%=name%>"> My Calendar </a></li>
    <%@ include file="LinkHome.jsp" %>
  </ul>
  
	<div class="content" id="calendar"> 
		<iframe src="https://www.google.com/accounts/Logout?continue=https%3a%2f%2fwww.google.com%2faccounts%2fServiceLoginAuth%3fcontinue%3dhttp%3a%2f%2fmail.google.com%2fgmail%26service%3dmail%26Email%3drockcreekvolunteercoordinator%26Passwd%3dG0covenant%26null%3dSign%2bin" style=" border-width:0 " width="700" height="500" frameborder="0" scrolling="no"></iframe>
	</div> 	

</body> 
<%
    }
%>
</html>