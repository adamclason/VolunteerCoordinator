<html>

<head>
<link rel="stylesheet" href="stylesheets/layout.css" type="text/css">
<link rel="stylesheet" type="text/css" href="stylesheets/colors.css">

<%@ page import="java.util.*,
    java.net.URL, javax.jdo.PersistenceManager, 
    javax.jdo.Transaction,
    com.VolunteerCoordinatorApp.PMF,
    com.VolunteerCoordinatorApp.Volunteer,
    com.google.appengine.api.datastore.Key,
    com.google.appengine.api.datastore.KeyFactory,
    com.google.gdata.client.calendar.*,
    com.google.gdata.data.calendar.*,
    java.net.URL,
    java.io.IOException"
    %>
</head>

<%@ include file="getCalendarService.jsp" %>

<% String name = request.getParameter("name"); %>

<%@ include file="getUserTimeZone.jsp" %>

<%
//Declared here so i in-scope for the iFrame at the bottom
String usrCalUrl = null;

//If no user in query string, prompt to log in.
if (name == null || name.equalsIgnoreCase("null") || name.equals(""))
{
	response.sendRedirect("/loginredirect?url=" + request.getRequestURI() + "?" 
			+ request.getQueryString());
}
//Otherwise proceed normally.
else
{
    //Checks the datastore for the calendar ID associated with this user.
    PersistenceManager pm = PMF.get().getPersistenceManager(); 

    Key k = KeyFactory.createKey(Volunteer.class.getSimpleName(), name);
    Volunteer v = pm.getObjectById(Volunteer.class, k);

    usrCalUrl = v.getCalendarId();

    boolean calendarAccessible = true;
    //Check to see if we can access the calendar usrCalUrl links to.
    if( usrCalUrl != null )
    {
        String nullString = null;
        try
        {
            URL testUrl = new URL("https://www.google.com/calendar/feeds/default/allcalendars/full/" + usrCalUrl);
            myService.getEntry( testUrl, CalendarEntry.class, nullString );
        }
        catch( Exception e1 )
        {
            calendarAccessible = false;
        }
    }
    //If calendar is inaccessible, we start looking to replace the stored URL.
    if( !calendarAccessible )
    {
        URL newFeedUrl = new URL("https://www.google.com/calendar/feeds/default/owncalendars/full");
        CalendarFeed newResultFeed = null;
        try
        {
            newResultFeed = myService.getFeed(newFeedUrl, CalendarFeed.class);
        }
        catch ( ServiceException e3 )
        {
            // TODO Auto-generated catch block
            e3.printStackTrace();
        } catch (IOException e) {
			// Retry
			try {
				newResultFeed = myService.getFeed(newFeedUrl, CalendarFeed.class);
			} catch (ServiceException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
        for( int i = 0; i < newResultFeed.getEntries().size(); i++ )
        {
            CalendarEntry newEntry = newResultFeed.getEntries().get( i );
            //String compare is not a great way to do it, 
            //but I'm not sure there is another option.
            if( newEntry.getTitle().getPlainText().equals( name+"'s Jobs" ) )
            {
                CalendarEntry calendar = newEntry;
                // Get the calender's url
                usrCalUrl = calendar.getId();
                int splitHere = usrCalUrl.lastIndexOf("/") + 1;
                usrCalUrl = usrCalUrl.substring(splitHere);
                break;
            }
        }
        boolean calendarDeleted = false;
        //Check to see if we can access the calendar usrCalUrl links to.
        //If we can't, it's assumed to have been deleted, and we proceed to make a new one.
        if( usrCalUrl != null )
        {
            String nullString = null;
            try
            {
                URL testUrl = new URL("https://www.google.com/calendar/feeds/default/allcalendars/full/" + usrCalUrl);
                myService.getEntry( testUrl, CalendarEntry.class, nullString );
            }
            catch( Exception e1 )
            {
                calendarDeleted = true;
            }
        }

        //No extant calendars for this user; make a new one.
        if( usrCalUrl == null || calendarDeleted )
        {               
            CalendarEntry calendar = new CalendarEntry();
            calendar.setTitle(new PlainTextConstruct(name + "'s Jobs"));
            calendar.setSummary(new PlainTextConstruct("This calendar contains the jobs " + name + " has volunteered for."));
            calendar.setTimeZone(new TimeZoneProperty(timeZone));
            calendar.setHidden(HiddenProperty.FALSE);
            

            // Insert the calendar
            URL postUrl = new URL("https://www.google.com/calendar/feeds/default/owncalendars/full");
            CalendarEntry newCalendar = null;
            try
            {
                newCalendar = myService.insert(postUrl, calendar);
            }
            catch ( ServiceException e2 )
            {
                // TODO Auto-generated catch block
                e2.printStackTrace();
            }
            catch (IOException e) {
            	//Retry
	            try
	            {
	                newCalendar = myService.insert(postUrl, calendar);
	            }
	            catch ( ServiceException e2 )
	            {
	                // TODO Auto-generated catch block
	                e2.printStackTrace();
	            }
            }
                        
            // Get the calender's url
            usrCalUrl = newCalendar.getId();
            int splitHere = usrCalUrl.lastIndexOf("/") + 1;
            usrCalUrl = usrCalUrl.substring(splitHere);

            //Find events on the calendar with this user's name attached
            newFeedUrl = new URL("https://www.google.com/calendar/feeds/default/private/full");
            CalendarQuery myQuery = new CalendarQuery(newFeedUrl);
            myQuery.setFullTextQuery(name);
            CalendarEventFeed resultFeed = null;
            try
            {
                resultFeed = myService.query(myQuery, CalendarEventFeed.class);
            }
            catch ( ServiceException e1 )
            {
                // TODO Auto-generated catch block
                e1.printStackTrace();
            } catch (IOException e) {
    			// Retry
    			try {
    				resultFeed = myService.query(myQuery, CalendarEventFeed.class);
    			} catch (ServiceException e1) {
    				// TODO Auto-generated catch block
    				e1.printStackTrace();
    			}
    		}
            List<CalendarEventEntry> entries = (List<CalendarEventEntry>)resultFeed.getEntries();

            //Add all of those events to the new calendar
            if (!entries.isEmpty()) {
                for (CalendarEventEntry singleEntry : entries) {
                    //Get the event's details
                    TextConstruct entryTitle = singleEntry.getTitle();
                    String entryContent = singleEntry.getPlainTextContent();
                    When entryTime = singleEntry.getTimes().get(0);
                    DateTime entryStart = entryTime.getStartTime();
                    DateTime entryEnd = entryTime.getEndTime();
                    
                    Date startDate = new Date(entryStart.getValue());
                    Date endDate = new Date(entryEnd.getValue());
                    
                    //timeZone was set in getUserTimeZone
                    TimeZone TZ =  TimeZone.getTimeZone( timeZone );

                    int startOffset = TZ.getOffset( entryStart.getValue() );
                    int endOffset = TZ.getOffset( entryEnd.getValue() );

                    startOffset = ( startOffset / 60 ) / 1000;
                    endOffset = ( endOffset / 60 ) / 1000;
                    
                    entryStart.setTzShift( startOffset );
                    entryEnd.setTzShift( endOffset );

                    //Create a new entry and add it
                    URL newEntryUrl = new URL(
                            "http://www.google.com/calendar/feeds/" + usrCalUrl + "/private/full");
                    CalendarEventEntry myEntry = new CalendarEventEntry();
                    myEntry.setTitle(entryTitle);
                    myEntry.setContent(new PlainTextConstruct(entryContent));
                    When eventTimes = new When();
                    eventTimes.setStartTime(entryStart);
                    eventTimes.setEndTime(entryEnd);
                    myEntry.addTime(eventTimes);

                    // Send the request and receive the response:
                    try
                    {
                        myService.insert(newEntryUrl, myEntry);
                    }
                    catch ( ServiceException e1 )
                    {
                        // TODO Auto-generated catch block
                        e1.printStackTrace();
                    } catch (IOException e) {
                    	//Retry
	                    try
	                    {
	                        myService.insert(newEntryUrl, myEntry);
	                    }
	                    catch ( ServiceException e1 )
	                    {
	                        // TODO Auto-generated catch block
	                        e1.printStackTrace();
	                    }
                    }
                }
            }
            // Access the Access Control List (ACL) for the calendar
            Link link = newCalendar.getLink(AclNamespace.LINK_REL_ACCESS_CONTROL_LIST,
                    Link.Type.ATOM);
            URL aclUrl = new URL(link.getHref());
            AclFeed aclFeed = null;
            try
            {
                aclFeed = myService.getFeed(aclUrl, AclFeed.class);
            }
            catch ( ServiceException e1 )
            {
                // TODO Auto-generated catch block
                e1.printStackTrace();
            } catch (IOException e) {
    			// Retry
    			try {
    				aclFeed = myService.getFeed(aclUrl, AclFeed.class);
    			} catch (ServiceException e1) {
    				// TODO Auto-generated catch block
    				e1.printStackTrace();
    			}
    		}

            // Set the default to "read-only" for all users
            AclEntry aclEntry = aclFeed.createEntry();
            aclEntry.setScope(new AclScope(AclScope.Type.DEFAULT, null));
            aclEntry.setRole(CalendarAclRole.READ);
            // Add it to the ACL  
            try
            {
                myService.insert(aclUrl, aclEntry);
            }
            catch ( ServiceException e1 )
            {
                // TODO Auto-generated catch block
                e1.printStackTrace();
            }
            catch (IOException e2) {
            	//Retry
            	try
	            {
	                myService.insert(aclUrl, aclEntry);
	            }
	            catch ( ServiceException e1 )
	            {
	                // TODO Auto-generated catch block
	                e1.printStackTrace();
	            }
            }
        }

        //Assign calendar ID to the Volunteer object for the user in question.
        Volunteer volunteer = null;
        PersistenceManager persistenceManager = PMF.get().getPersistenceManager(); 
        Transaction tx = persistenceManager.currentTransaction();
        try
        {
            tx.begin();

            Key key = KeyFactory.createKey(Volunteer.class.getSimpleName(), name);
            volunteer = persistenceManager.getObjectById(Volunteer.class, key);
            volunteer.setCalendarId( usrCalUrl );
            tx.commit();
        }
        catch (Exception e1)
        {
            if (tx.isActive())
            {
                tx.rollback();
            }
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
<iframe src="http://www.google.com/calendar/embed?height=500&amp;wkst=1&amp;bgcolor=%23FFFFFF&amp;src=<%=usrCalUrl%>&amp;color=%23691426&amp;ctz=<%=timeZone%>" style=" border-width:0 " width="700" height="500" frameborder="0" scrolling="no"></iframe>
</div>

</body>

</html>