<html>

<head> 
	<link rel="stylesheet" href="stylesheets/layout.css" type="text/css"> 
    <link rel="stylesheet" type="text/css" href="stylesheets/colors.css">
    
<%@ page import="java.util.*"%>
</head> 

<%@ include file="getCalendarService.jsp" %>

<%  String name = request.getParameter("name");
    String usrCalUrl;
    System.err.println("here "+name);

    //Create the calendar
    if (name == null || name.equalsIgnoreCase("null") || name.equals("")) {
        System.err.println("here "+name);
    	usrCalUrl = "rockcreekvolunteercoordinator%40gmail.com";
    } else {
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
		<iframe src="http://www.google.com/calendar/embed?height=500&amp;wkst=1&amp;bgcolor=%23FFFFFF&amp;src=<%=usrCalUrl%>&amp;color=%23691426&amp;ctz=America%2FNew_York" style=" border-width:0 " width="700" height="500" frameborder="0" scrolling="no"></iframe>
	</div> 	

</body> 

</html>