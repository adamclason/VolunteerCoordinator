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
import com.google.gdata.util.ServiceForbiddenException;

import java.net.URL;
import java.util.List;

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
        {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        String title = request.getParameter( "title" );
        String newTitle = request.getParameter( "newTitle" );
        String name = request.getParameter( "name" );

        URL feedUrl = new URL("https://www.google.com/calendar/feeds/default/allcalendars/full");

        Query calendarQuery = new Query( feedUrl );
        try
        {
            CalendarFeed myResultsFeed = null;
            try
            {
                myResultsFeed = myService.query( calendarQuery, CalendarFeed.class );
            }
            catch( ServiceForbiddenException e )
            {
                System.out.println( "Caught exception trying to query myService." );
                e.printStackTrace();
            }
            if (myResultsFeed.getEntries().size() > 0) 
            {   
                List<CalendarEntry> list = myResultsFeed.getEntries();
                for( CalendarEntry entry : list )
                {
                    String entryId = entry.getId();
                    int splitHere = entryId.lastIndexOf("/") + 1;
                    entryId = entryId.substring(splitHere);
                    //System.out.println( entry.getId() );
                    URL entryUrl = new URL( "http://www.google.com/calendar/feeds/"
                            + entryId + "/private/full");
                    Query eventQuery = new Query( entryUrl );
                    eventQuery.setFullTextQuery( title );
                    CalendarEventFeed eventFeed = myService.query( eventQuery, CalendarEventFeed.class );
                    for( CalendarEventEntry eventEntry : eventFeed.getEntries() )
                    {
                        if( eventEntry.getTitle().getPlainText().equals( title ) )
                        {
                            String volunteers = eventEntry.getPlainTextContent(); 
                            int beginVolunteerList = volunteers.indexOf( "<volunteers>" );
                            if( beginVolunteerList > -1 )
                            {
                                volunteers = volunteers.substring( beginVolunteerList );
                            }
                            else 
                            {
                                volunteers = "<volunteers>  </volunteers>";
                            }
                            try
                            {
                                eventEntry.delete();
                            }
                            catch( ServiceException e )
                            {
                                System.out.println( "Exception trying to delete calendarEventEntry" );
                                e.printStackTrace();
                            }

                            CalendarEventEntry newEntry = new CalendarEventEntry();

                            newEntry.setTitle(new PlainTextConstruct( newTitle ));
                            String description = request.getParameter( "what" );
                            String forWho = request.getParameter( "for" );
                            String who = request.getParameter( "who" );
                            String why = request.getParameter( "why" );
                            String cat = request.getParameter( "category" );
                            System.err.println(cat);
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

                            String fromTime = formattedDate + "T" + fromHrsStr
                            + ":" + fromMins + ":00" + "-05:00"; //-5:00 adjusts to correct time zone
                            String tillTime = formattedDate + "T" + tillHrsStr
                            + ":" + tillMins + ":00" + "-05:00"; //-5:00 adjusts to correct time zone

                            DateTime startTime = DateTime.parseDateTime(fromTime);
                            DateTime endTime = DateTime.parseDateTime(tillTime);
                            When eventTimes = new When();
                            eventTimes.setStartTime(startTime);
                            eventTimes.setEndTime(endTime);
                            newEntry.addTime(eventTimes);
                            try
                            {
                                myService.insert( entryUrl, newEntry );
                            }
                            catch ( ServiceException e )
                            {
                                System.out.println( "Error inserting new calendar." );
                                //Actual error handling one of these days.
                                e.printStackTrace();
                            }
                        }
                    }

                }

            }

            response.sendRedirect("/manProj.jsp?pageNumber=1&resultIndex=1&name=" + name);
        }
        catch( ServiceException e )
        {
            System.out.println( e.getMessage() );
            e.printStackTrace();
        }        
    }
}
