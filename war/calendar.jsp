<html>

<head>
<link rel="stylesheet" href="stylesheets/layout.css" type="text/css">
    <link rel="stylesheet" type="text/css" href="stylesheets/colors.css">
    
<%@ page import="java.util.*"%>
</head>

<%@ include file="getCalendarService.jsp" %>

<% String name = request.getParameter("name");
    String usrCalUrl = null;

    //If no user in query string, prompt to log in.
    if (name == null || name.equalsIgnoreCase("null") || name.equals(""))
    {
        String newURL = "/index.jsp?name=none";
        response.sendRedirect( newURL );
        usrCalUrl = "rockcreekvolunteercoordinator%40gmail.com";
    }
    //Otherwise proceed normally.
    else
    {
        //Search for existing calendars under this user's name
        URL newFeedUrl = new URL("https://www.google.com/calendar/feeds/default/owncalendars/full");
        CalendarFeed newResultFeed = myService.getFeed(newFeedUrl, CalendarFeed.class);
        CalendarEntry returnedCalendar = null;
        for( int i = 0; i < newResultFeed.getEntries().size(); i++ )
        {
            CalendarEntry entry = newResultFeed.getEntries().get( i );
            //String compare is not a great way to do it, 
            //but I'm not sure there is another option.
            if( entry.getTitle().getPlainText().equals( name+"'s Jobs" ) )
            {
                returnedCalendar = entry;
                // Get the calender's url
                usrCalUrl = returnedCalendar.getId();
                int splitHere = usrCalUrl.lastIndexOf("/") + 1;
                usrCalUrl = usrCalUrl.substring(splitHere);
                break;
            }
        }
        //If we didn't find a calendar, a new one needs to be made.
        if( returnedCalendar == null )
        {
            CalendarEntry calendar = new CalendarEntry();
            calendar.setTitle(new PlainTextConstruct(name + "'s Jobs"));
            calendar.setSummary(new PlainTextConstruct("This calendar contains the jobs " + name + " has volunteered for."));
            calendar.setTimeZone(new TimeZoneProperty("America/New_York"));
            calendar.setHidden(HiddenProperty.FALSE);

            // Insert the calendar
            URL postUrl = new URL("https://www.google.com/calendar/feeds/default/owncalendars/full");
            returnedCalendar = myService.insert(postUrl, calendar);
            // Get the calender's url
            usrCalUrl = returnedCalendar.getId();
            int splitHere = usrCalUrl.lastIndexOf("/") + 1;
            usrCalUrl = usrCalUrl.substring(splitHere);

            //Find events on the calendar with this user's name attached
            URL feedUrl = new URL("https://www.google.com/calendar/feeds/default/private/full");
            CalendarQuery myQuery = new CalendarQuery(feedUrl);
            myQuery.setFullTextQuery(name);
            CalendarEventFeed resultFeed = myService.query(myQuery, CalendarEventFeed.class);
            List<CalendarEventEntry> results = (List<CalendarEventEntry>)resultFeed.getEntries();
            
            //Add all of those events to the new calendar
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
            // Access the Access Control List (ACL) for the calendar
            Link link = returnedCalendar.getLink(AclNamespace.LINK_REL_ACCESS_CONTROL_LIST,
                      Link.Type.ATOM);
            URL aclUrl = new URL(link.getHref());
            AclFeed aclFeed = myService.getFeed(aclUrl, AclFeed.class);

            // Set the default to "read-only" for all users
            AclEntry aclEntry = aclFeed.createEntry();
            aclEntry.setScope(new AclScope(AclScope.Type.DEFAULT, null));
            aclEntry.setRole(CalendarAclRole.READ);
            // Add it to the ACL  
            AclEntry insertedEntry = myService.insert(aclUrl, aclEntry);
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