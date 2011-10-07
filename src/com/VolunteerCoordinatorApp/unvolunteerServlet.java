package com.VolunteerCoordinatorApp;

import java.io.*;
import java.net.URL;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.*;

import javax.jdo.PersistenceManager;
import javax.jdo.Transaction;
import javax.servlet.http.*;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.gdata.client.Query;
import com.google.gdata.client.calendar.CalendarQuery;
import com.google.gdata.client.calendar.CalendarService;
import com.google.gdata.data.*;
import com.google.gdata.data.acl.*;
import com.google.gdata.data.calendar.*;
import com.google.gdata.data.extensions.*;
import com.google.gdata.util.AuthenticationException;
import com.google.gdata.util.ServiceException;

@SuppressWarnings("serial")
public class unvolunteerServlet extends HttpServlet 
{
    public void doPost(HttpServletRequest req, HttpServletResponse resp)
    throws IOException 
    {
        doGet(req, resp); 
    }

    public void doGet(HttpServletRequest req, HttpServletResponse resp)
    throws IOException 
    {
        String date = req.getParameter("date");
        String title = req.getParameter("title");
        String usrName = req.getParameter("name");
        String eventId = req.getParameter( "id" );

        //If no user in query string, prompt to log in.
        if (usrName == null || usrName.equalsIgnoreCase("null") || usrName.equals(""))
        {
            resp.sendRedirect("/loginredirect?url=" + req.getRequestURI() + "?" 
                    + req.getQueryString());
        }
        //Otherwise proceed normally.
        else
        {
            URL feedUrl = new URL("https://www.google.com/calendar/feeds/default/private/full");
            //String idSplit[] = id.split( "/" );
            //URL feedUrl = new URL( "https://www.google.com/calendar/feeds/default/" + 
            //                        "visibility/full/" + idSplit[idSplit.length-1] );
            CalendarQuery myQuery = new CalendarQuery(feedUrl);
            myQuery.setStringCustomParameter("futureevents", "true");
            myQuery.setStringCustomParameter("singleevents", "true");

            CalendarService myService = new CalendarService("Volunteer-Coordinator-Calendar");
            try 
            {
                myService.setUserCredentials("rockcreekvolunteercoordinator@gmail.com", "G0covenant");
            } 
            catch (AuthenticationException e) 
            {
                // TODO Auto-generated catch block
                System.err.println( "Failed to authenticate service." );
                e.printStackTrace();
            }
            //Fetch the copy of the event existing in the User's calendar
            PersistenceManager pManager = PMF.get().getPersistenceManager(); 
            Key k = KeyFactory.createKey(Volunteer.class.getSimpleName(), usrName);
            Volunteer vol = pManager.getObjectById(Volunteer.class, k);
            URL entryUrl = new URL( "http://www.google.com/calendar/feeds/"
                    + vol.getCalendarId() + "/private/full");
            CalendarQuery eventQuery = new CalendarQuery( entryUrl ); 
            
            CalendarEventFeed eventFeed = null;
            try 
            {
                eventFeed  = myService.getFeed(eventQuery, CalendarEventFeed.class);
            } 
            catch (ServiceException e) 
            {
                // TODO Auto-generated catch block
                try
                {
                    eventFeed = myService.getFeed(eventQuery, CalendarEventFeed.class );
                }
                catch(ServiceException e1)
                {
                    System.err.println( "Error trying to get the entry information." );
                    e1.printStackTrace();
                }
            }

            int splitHere = eventId.lastIndexOf("/") + 1;
            eventId = eventId.substring( splitHere );
            
            eventId = URLEncoder.encode( eventId, "UTF-8" );
            
            List<CalendarEventEntry> events = eventFeed.getEntries();
            for( CalendarEventEntry event : events )
            {
                splitHere = event.getId().lastIndexOf("/") + 1;
                String substrungEventId = event.getId().substring( splitHere );
                
                //System.out.println( event.getTitle().getPlainText() );
                //System.out.println( title );
                if( substrungEventId.equals( eventId ) )
                {
                    try
                    {
                        event.delete();
                    }
                    catch( ServiceException e )
                    {
                        try
                        {
                            event.delete();
                        }
                        catch( ServiceException e1 )
                        {
                            System.out.println( "Error trying to delete entry." );
                            e1.printStackTrace();
                        }
                    }
                }
            }
            
            resp.sendRedirect( "/myJobs.jsp?pageNumber=1&resultIndex=1&name=" + usrName );
        }
    }
}