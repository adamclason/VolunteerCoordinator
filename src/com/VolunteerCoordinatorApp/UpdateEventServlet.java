package com.VolunteerCoordinatorApp;

import java.io.IOException;

import javax.jdo.PersistenceManager;
import javax.servlet.http.*;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.gdata.client.Query;
import com.google.gdata.client.calendar.*;
import com.google.gdata.data.*;
import com.google.gdata.data.calendar.*;
import com.google.gdata.data.extensions.*;
import com.google.gdata.util.AuthenticationException;
import com.google.gdata.util.ServiceException;
import java.net.URL;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.TimeZone;

@SuppressWarnings("serial")
public class UpdateEventServlet extends HttpServlet
{
    public void doPost( HttpServletRequest request, HttpServletResponse response ) throws IOException
    {
        CalendarService myService = new CalendarService("Volunteer-Coordinator-Calendar"); 
        try 
        {
            myService.setUserCredentials("rockcreekvolunteercoordinator@gmail.com", "G0covenant");
        } 
        catch (AuthenticationException e) 
        { // TODO Auto-generated catch block
            System.out.println( "Failed to authenticate." );
            e.printStackTrace();
        }
        String title = request.getParameter( "title" );
        String newTitle = request.getParameter( "newTitle" );
        String name = request.getParameter( "name" );
        String recurring = request.getParameter( "recurring" );
        String date = request.getParameter("when");
        //String entryId = request.getParameter( "id" );
        String acceptedBy = "";

        URL feedUrl = new URL("https://www.google.com/calendar/feeds/default/allcalendars/full");

        CalendarQuery calendarQuery = new CalendarQuery( feedUrl );
        CalendarFeed myResultsFeed = null;
        try 
        {
            myResultsFeed = myService.query(calendarQuery, CalendarFeed.class);
        } 
        catch (Exception e) 
        {
            try
            {
                myResultsFeed = myService.query(calendarQuery, CalendarFeed.class);
            }
            catch( Exception e1 )
            {
                System.out.println( "Caught exception trying to fetch calendar feed." );
                e1.printStackTrace();
            }
        }

        if (myResultsFeed.getEntries().size() > 0) 
        {

            List<CalendarEntry> list = (List<CalendarEntry>)myResultsFeed.getEntries();
            for( CalendarEntry entry : list )
            {
                String entryId = entry.getId();
                int splitHere = entryId.lastIndexOf("/") + 1;
                entryId = entryId.substring(splitHere);
                URL entryUrl = new URL( "http://www.google.com/calendar/feeds/"
                        + entryId + "/private/full");
                CalendarQuery eventQuery = new CalendarQuery( entryUrl );
                eventQuery.setFullTextQuery( title );
                String datePattern = "MM/dd/yyyy"; 
                SimpleDateFormat dateFormat = new SimpleDateFormat(datePattern);
                
                //set maxTime
                DateTime searchMaxDate = null;
                long searchMaxTime = 0;
                try 
                {
                    searchMaxDate = new DateTime(dateFormat.parse(date));
                    searchMaxTime = searchMaxDate.getValue();
                    searchMaxTime += 86400000; //86400000 milliseconds = 1 day
                    searchMaxDate.setValue(searchMaxTime);
                } 
                catch (ParseException e6) 
                {
                    // TODO Auto-generated catch block
                    e6.printStackTrace();
                }
                if (searchMaxDate != null) 
                {
                    eventQuery.setMaximumStartTime(searchMaxDate);
                }
                //end set maxTime
                
                //set minTime
                DateTime searchMinDate = null;
                long searchMinTime = 0;
                try 
                {
                    searchMinDate = new DateTime(dateFormat.parse(date));
                    searchMinTime = searchMinDate.getValue();
                    searchMinDate.setValue(searchMinTime);
                } 
                catch (ParseException e6) 
                {
                    // TODO Auto-generated catch block
                    e6.printStackTrace();
                }
                if (searchMinDate != null) 
                {
                    eventQuery.setMinimumStartTime(searchMinDate);
                }
                //end set minTime
                
                CalendarEventFeed eventFeed = null;
                try
                {
                    eventFeed = myService.query( eventQuery, CalendarEventFeed.class );
                }
                catch ( Exception e )
                {
                    System.out.println( "Failed the first try to fetch Calendar Events; trying again." );
                    try
                    {
                        eventFeed = myService.query( eventQuery, CalendarEventFeed.class );
                    }
                    catch( Exception e1 )
                    {
                        // TODO Auto-generated catch block
                        System.out.println( "Error attepting to fetch events in a calendar." );
                        e1.printStackTrace();
                    }
                }

                List<CalendarEventEntry> results = (List<CalendarEventEntry>) eventFeed.getEntries();

                CalendarEventEntry updatingEvent = null; //References the event to be updated

                if (recurring.equals("yes")) 
                { //Select recurring event
                    ArrayList<CalendarEventEntry> recurList = new ArrayList<CalendarEventEntry>();
                    //Get the events in the series of recurring events
                    for (CalendarEventEntry foundEvent : results) 
                    {
                        String eventTitle = new String(foundEvent.getTitle().getPlainText());
                        //System.out.println( "|" + foundEvent.getTitle().getPlainText() + "|" );
                        if (eventTitle.equals(title)) 
                        { //Check title to see if it's the correct event
                            recurList.add(foundEvent);
                        }
                    }
                    //If the calendar being examined doesn't have this event, skip to next calendar
                    if( recurList.size() > 0 )
                        updatingEvent = recurList.get(0); //Set the first one (holds recurring data) to be deleted
                    else
                        continue;
                    //Get the volunteers
                    List<ExtendedProperty> propList = updatingEvent.getExtendedProperty();
                    for (ExtendedProperty prop : propList) 
                    {
                        if( prop.getName().equals( "acceptedBy" ) )
                        {
                            acceptedBy = prop.getValue();
                        }
                    }

                    try //Try to delete old event
                    {
                        updatingEvent.delete();
                    }
                    catch( Exception e )
                    {
                        try
                        {
                            updatingEvent.delete();
                        }
                        catch( Exception e1 )
                        {
                            System.out.println( "Exception trying to delete recurring calendarEventEntry" );
                            e1.printStackTrace();
                        }
                    }
                } 
                else 
                { //Select normal event
                    for (CalendarEventEntry foundEvent : results) 
                    {
                        if( foundEvent.getTitle().getPlainText().equals( title ) ) 
                        {
                            updatingEvent = foundEvent;
                            //Get the volunteers
                            List<ExtendedProperty> propList = updatingEvent.getExtendedProperty();
                            for (ExtendedProperty prop : propList) {
                                if( prop.getName().equals( "acceptedBy" ) )
                                {
                                    acceptedBy = prop.getValue();
                                }
                            }
                            try //Try to delete old event
                            {
                                updatingEvent.delete();
                            }
                            catch( ServiceException e )
                            {
                                System.err.println( "Exception trying to delete non-recurring calendarEventEntry" );
                                e.printStackTrace();
                            }
                        }
                    }
                }

                CalendarEventEntry newEntry = new CalendarEventEntry();

                String description = request.getParameter( "what" );
                String forWho = request.getParameter( "for" );
                String who = request.getParameter( "who" );
                String why = request.getParameter( "why" );
                String cat = request.getParameter( "category" );

                if( cat.equals( "None" ) || cat == null )
                {
                    cat = "None";
                }

                //set description
                newEntry.setContent(new PlainTextConstruct( description ));

                //set "for whom" property
                ExtendedProperty forProp = new ExtendedProperty();
                forProp.setName("for");
                forProp.setValue(forWho);
                newEntry.addExtendedProperty(forProp);

                //set "who should do it" property
                ExtendedProperty whoProp = new ExtendedProperty();
                whoProp.setName("who");
                whoProp.setValue(who);
                newEntry.addExtendedProperty(whoProp);

                //set why property
                ExtendedProperty whyProp = new ExtendedProperty();
                whyProp.setName("why");
                whyProp.setValue(why);
                newEntry.addExtendedProperty(whyProp);

                // set category property
                ExtendedProperty catProp = new ExtendedProperty();
                catProp.setName("category");
                catProp.setValue(cat);
                newEntry.addExtendedProperty(catProp);

                //set propertry of who accepted to coordinate the job
                ExtendedProperty acceptedByProp = new ExtendedProperty();
                acceptedByProp.setName( "acceptedBy" );
                acceptedByProp.setValue( acceptedBy );
                newEntry.addExtendedProperty( acceptedByProp );

                newEntry.setTitle(new PlainTextConstruct( newTitle ));

                int fromHrs = Integer.parseInt(request.getParameter("fromHrs"));
                String fromMins = request.getParameter("fromMins");
                int tillHrs = Integer.parseInt(request.getParameter("tillHrs"));
                String tillMins = request.getParameter("tillMins");

                if(request.getParameter("fromAMPM").equals("PM")) 
                { 
                    fromHrs += 12;
                }
                if(request.getParameter("toAMPM").equals("PM")) 
                { 
                    tillHrs += 12;
                }
                String fromHrsStr = "";
                if( fromHrs / 10 > 0 )
                    fromHrsStr = String.valueOf( fromHrs );
                else
                    fromHrsStr = "0" + String.valueOf( fromHrs );

                String tillHrsStr = "";
                if( tillHrs / 10 > 0 )
                    tillHrsStr = String.valueOf( tillHrs );
                else
                    tillHrsStr = "0" + String.valueOf( tillHrs );
		
                String month = date.substring(0, date.indexOf("/")); 
                String day = date.substring(date.indexOf("/") + 1, date.indexOf("/") + 3); 
                String year = date.substring(date.indexOf("/") + 4, date.length()); 
                String formattedDate = year + "-" + month + "-" + day;  

                PersistenceManager pManager = PMF.get().getPersistenceManager(); 

                Key k = KeyFactory.createKey(Volunteer.class.getSimpleName(), name);
                Volunteer vol = pManager.getObjectById(Volunteer.class, k);

                String timeZone = vol.getTimeZone();
                if( timeZone == null )
                {
                    timeZone = "America/New_York";
                }

                TimeZone TZ =  TimeZone.getTimeZone( timeZone );

                int offset = TZ.getOffset( DateTime.parseDate( formattedDate ).getValue() );

                //Converts milisecond offset to positive hour offset.
                offset = Math.abs( ( ( ( offset / 60 ) / 60 ) / 1000 ) );
                String offsetString;
                //It's a 2-digit offset; no leading zero needed
                if( offset > 9 )
                {
                    offsetString = "-" + offset + ":00";
                }
                //Single-digit offset; leading zero req'd.  Or we've royally screwed up input somehow,
                //but how likely is *that*?
                else
                {
                    offsetString = "-0" + offset + ":00";
                }

                String fromTime = formattedDate + "T" + fromHrsStr
                + ":" + fromMins + ":00" + offsetString; //Should adjust to the user's TZ
                String tillTime = formattedDate + "T" + tillHrsStr
                + ":" + tillMins + ":00" + offsetString; //Should adjust to the user's TZ

                DateTime startTime = DateTime.parseDateTime(fromTime);
                DateTime endTime = DateTime.parseDateTime(tillTime);
                /*
        //TODO figure out if this is the right way to do timezone handling
        Date startDate = new Date(startTime.getValue());
        Date endDate = new Date(endTime.getValue());
        //If Daylight Savings is in effect, shift times an hour forward (60 minutes)
        if (TZ.inDaylightTime(startDate)) {
            startTime.setTzShift(+60); 
        }
        if (TZ.inDaylightTime(endDate)) { 
            endTime.setTzShift(+60);
        }*/

                When eventTimes = new When();
                eventTimes.setStartTime(startTime);
                eventTimes.setEndTime(endTime);

                String recurStr = request.getParameter("recur");
                ExtendedProperty recurrence = new ExtendedProperty();
                recurrence.setName("recurrence");
                recurrence.setValue(recurStr);
                newEntry.addExtendedProperty(recurrence);

                if (recurStr.equals("none")) { //If no recurrence, add the date/times
                    newEntry.addTime(eventTimes);
                } else { //If recurrence selected, apply it
                    String recurData = "DTSTART;TZID=America/New_York" + ":" + year + month + day + "T" + fromHrsStr
                    + fromMins + "00\r\n"
                    + "DTEND;TZID=America/New_York" + ":" + year + month + day + "T" + tillHrsStr
                    + tillMins + "00\r\n";
                    if (recurStr.equals("week")) {
                        recurData += "RRULE:FREQ=WEEKLY\r\n";
                    }
                    else if (recurStr.equals("biweek")) {
                        recurData += "RRULE:FREQ=WEEKLY;INTERVAL=2\r\n";
                    }
                    else if (recurStr.equals("month")) {
                        recurData += "RRULE:FREQ=MONTHLY\r\n";
                    }
                    Recurrence recur = new Recurrence();
                    recur.setValue(recurData);
                    newEntry.setRecurrence(recur);
                }

                try //Try to post the new one
                {
                    newEntry = myService.insert( entryUrl, newEntry );
                }
                catch ( Exception e )
                {
                    //Retry
                    try
                    {
                        newEntry = myService.insert( entryUrl, newEntry );
                    }
                    catch ( Exception e1 )
                    {
                        System.err.println( "Exception inserting new event entry." );
                        //Actual error handling one of these days.
                        e.printStackTrace();
                        System.out.println( newEntry.getTitle().getPlainText() );
                    }
                }
            }
        }
        response.sendRedirect("/manProj.jsp?pageNumber=1&resultIndex=1&name=" + name);
    }
}
