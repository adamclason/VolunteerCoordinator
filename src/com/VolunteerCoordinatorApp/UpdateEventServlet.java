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
        
        URL feedUrl = new URL("https://www.google.com/calendar/feeds/default/private/full");

        Query myQuery = new Query( feedUrl );
        myQuery.setFullTextQuery( title );
        try
        {
            CalendarEventFeed myResultsFeed = myService.query( myQuery, CalendarEventFeed.class );
            if (myResultsFeed.getEntries().size() > 0) 
            {
                CalendarEventEntry retrievedEntry = (CalendarEventEntry) myResultsFeed.getEntries().get(0);
                
                retrievedEntry.setTitle(new PlainTextConstruct( newTitle ));
                String description = request.getParameter( "what" );
                String forWho = request.getParameter( "for" );
                String who = request.getParameter( "who" );
                String why = request.getParameter( "why" );
                String cat = request.getParameter( "cat" );
                
                retrievedEntry.setContent(new PlainTextConstruct("<description> "
                        + description + " </description> "
                        + "<for> " + forWho + " </for> "
                        + "<who> " + who + " </who> "
                        + "<why> " + why + " </why> "
                        + "<category> " + cat + " </category>"));
                int fromHrs = Integer.parseInt(request.getParameter("fromHrs"));
                int fromMins = Integer.parseInt(request.getParameter("fromMins"));
                int tillHrs = Integer.parseInt(request.getParameter("tillHrs"));
                int tillMins = Integer.parseInt(request.getParameter("tillMins"));
                
                if(request.getParameter("fromAMPM").equals("PM")) 
                { 
                    fromHrs += 12;
                }
                if(request.getParameter("toAMPM").equals("PM")) 
                { 
                    tillHrs += 12;
                }
                
                String date = request.getParameter("when");
                String month = date.substring(0, date.indexOf("-")); 
                String day = date.substring(date.indexOf("-") + 1, date.indexOf("-") + 3); 
                String year = date.substring(date.indexOf("-") + 4, date.length()); 
                String formattedDate = year + "-" + month + "-" + day; 
                
                String fromTime = formattedDate + "T" + request.getParameter("fromHrs")
                    + ":" + request.getParameter("fromMins") + ":00";  // + "-05:00"; //-5:00 adjusts to correct time zone
                    String tillTime = formattedDate + "T" + request.getParameter("tillHrs")
                    + ":" + request.getParameter("tillMins") + ":00"; // + "-05:00"; //-5:00 adjusts to correct time zone
                    
                DateTime startTime = DateTime.parseDateTime(fromTime);
                DateTime endTime = DateTime.parseDateTime(tillTime);
                When eventTimes = new When();
                eventTimes.setStartTime(startTime);
                eventTimes.setEndTime(endTime);
                retrievedEntry.addTime(eventTimes);
                
                URL editUrl = new URL(retrievedEntry.getEditLink().getHref());
                try
                {
                    CalendarEventEntry updatedEntry = (CalendarEventEntry)myService.update(editUrl, retrievedEntry);
                }
                catch ( ServiceException e )
                {
                    //Actual error handling one of these days.
                    System.out.print( "Inner" );
                    e.printStackTrace();
                }
            }
            
            response.sendRedirect("/manProj.jsp?pageNumber=1&resultIndex=1&name=" + name);
        }
        catch( ServiceException e )
        {
            System.out.print( "Outer" );
            e.printStackTrace();
        }        
    }
}
