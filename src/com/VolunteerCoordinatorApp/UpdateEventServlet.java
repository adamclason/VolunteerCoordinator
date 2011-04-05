package com.VolunteerCoordinatorApp;

import java.io.IOException;
import javax.servlet.http.*;
import com.google.gdata.client.Query;
import com.google.gdata.client.calendar.*;
import com.google.gdata.data.*;
import com.google.gdata.data.calendar.*;
import com.google.gdata.data.extensions.*;
import com.google.gdata.util.AuthenticationException;
import com.google.gdata.util.ServiceException;
import java.net.URL;
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
            e.printStackTrace();
        }
        String title = request.getParameter( "title" );
        String newTitle = request.getParameter( "newTitle" );
        String name = request.getParameter( "name" );
        String recurring = request.getParameter( "recurring" );
        String volunteers = "";

        URL feedUrl = new URL("https://www.google.com/calendar/feeds/default/private/full");

        Query calendarQuery = new Query( feedUrl );
        
        CalendarEventFeed resultFeed = null;
		try {
			resultFeed = myService.query(calendarQuery, CalendarEventFeed.class);
		} catch (ServiceException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		List<CalendarEventEntry> results = (List<CalendarEventEntry>)resultFeed.getEntries();
		CalendarEventEntry event = null; //References the event to be updated
		
		if (recurring.equals("yes")) { //Select recurring event
			ArrayList<CalendarEventEntry> recurList = new ArrayList<CalendarEventEntry>();
			//Get the events in the series of recurring events
			for (CalendarEventEntry entry : results) {
				String eventTitle = new String(entry.getTitle().getPlainText());
				if (eventTitle.equals(title)) { //Check title to see if it's the correct event
					recurList.add(entry);
				}
			}
			event = recurList.get(0); //Set the first one (holds recurring data) to be deleted
		} else { //Select normal event
			for (CalendarEventEntry entry : results) {
				if( entry.getTitle().getPlainText().equals( title ) ) {
					event = entry;
					volunteers = event.getPlainTextContent(); 
                    int beginVolunteerList = volunteers.indexOf( "<volunteers>" );
                    if( beginVolunteerList > -1 )
                    {
                        volunteers = volunteers.substring( beginVolunteerList );
                    }
                    else 
                    {
                        volunteers = "<volunteers>  </volunteers>";
                    }
				}
			}
		}
        
		String entryId = event.getId();
        int splitHere = entryId.lastIndexOf("/") + 1;
        entryId = entryId.substring(splitHere);
        URL entryUrl = new URL( "https://www.google.com/calendar/feeds/default/private/full");
        
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

        newEntry.setContent(new PlainTextConstruct("<description> "
                + description + " </description> "
                + "<for> " + forWho + " </for> "
                + "<who> " + who + " </who> "
                + "<why> " + why + " </why> " 
                + volunteers ) );

        // set category property
        ExtendedProperty category = new ExtendedProperty();
        category.setName("category");
        category.setValue(cat);
        newEntry.addExtendedProperty(category);

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

        String date = request.getParameter("when");		
        String month = date.substring(0, date.indexOf("/")); 
        String day = date.substring(date.indexOf("/") + 1, date.indexOf("/") + 3); 
        String year = date.substring(date.indexOf("/") + 4, date.length()); 
        String formattedDate = year + "-" + month + "-" + day;  
		
		newEntry.setTitle(new PlainTextConstruct( newTitle ));

        String fromTime = formattedDate + "T" + fromHrsStr
        + ":" + fromMins + ":00" + "-05:00"; //-5:00 adjusts to correct time zone
        String tillTime = formattedDate + "T" + tillHrsStr
        + ":" + tillMins + ":00" + "-05:00"; //-5:00 adjusts to correct time zone

        DateTime startTime = DateTime.parseDateTime(fromTime);
        DateTime endTime = DateTime.parseDateTime(tillTime);
        
        TimeZone estTZ =  TimeZone.getTimeZone("America/New_York");
        Date startDate = new Date(startTime.getValue());
        Date endDate = new Date(endTime.getValue());
        //Determine timezone offset in minutes, depending on whether or not
        //Daylight Savings Time is in effect
        if (estTZ.inDaylightTime(startDate)) {
            startTime.setTzShift(-240); 
        } else {
          startTime.setTzShift(-300); 
        }
        if (estTZ.inDaylightTime(endDate)) { 
            endTime.setTzShift(-240);
        } else {
            endTime.setTzShift(-300);
        }
        
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
    	
		try //Try to delete old event
        {
			event.delete();
        }
        catch( ServiceException e )
        {
            System.err.println( "Exception trying to delete calendarEventEntry" );
            e.printStackTrace();
        }
        
        try //Try to post the new one
        {
            myService.insert( entryUrl, newEntry );
        }
        catch ( ServiceException e )
        {
            System.err.println( "Exception inserting new calendar." );
            //Actual error handling one of these days.
            e.printStackTrace();
        }
        
        response.sendRedirect("/manProj.jsp?pageNumber=1&resultIndex=1&name=" + name);
    }
}
