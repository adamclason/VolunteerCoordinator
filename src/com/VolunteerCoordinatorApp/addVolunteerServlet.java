package com.VolunteerCoordinatorApp;

import java.io.*;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.*;
import javax.servlet.http.*;
import com.google.gdata.client.calendar.CalendarQuery;
import com.google.gdata.client.calendar.CalendarService;
import com.google.gdata.data.DateTime;
import com.google.gdata.data.PlainTextConstruct;
import com.google.gdata.data.calendar.CalendarEntry;
import com.google.gdata.data.calendar.CalendarEventEntry;
import com.google.gdata.data.calendar.CalendarEventFeed;
import com.google.gdata.data.calendar.CalendarFeed;
import com.google.gdata.data.extensions.*;
import com.google.gdata.util.AuthenticationException;
import com.google.gdata.util.ServiceException;

@SuppressWarnings("serial")
public class addVolunteerServlet extends HttpServlet {
    public void doPost(HttpServletRequest req, HttpServletResponse resp)
    throws IOException {
        doGet(req, resp); 
    }
    
    public void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String date = req.getParameter("date");
        String title = req.getParameter("title");
        String name = req.getParameter("name"); 
        
        System.out.println( "We do get *this* far, right?" );

        //If no user in query string, prompt to log in.
        if (name == null || name.equalsIgnoreCase("null") || name.equals(""))
        {
            String newURL = "/index.jsp?name=none";
            resp.sendRedirect( newURL );
        }
        
        URL feedUrl = new URL("https://www.google.com/calendar/feeds/default/" +
                "private/full");
          
        CalendarQuery myQuery = new CalendarQuery(feedUrl);
           
        CalendarService myService = new CalendarService("Volunteer-Coordinator-Calendar");
        System.out.println( "No?" );
        try {
            myService.setUserCredentials("rockcreekvolunteercoordinator@gmail.com", "G0covenant");
        } catch (AuthenticationException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        System.out.println( "Yes?" );

        // Send the request and receive the response:
        CalendarEventFeed resultFeed = null;
        try {
            resultFeed = myService.query(myQuery, CalendarEventFeed.class);
        } catch (ServiceException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
          
        List<CalendarEventEntry> results = (List<CalendarEventEntry>)resultFeed.getEntries(); 
                
        for (CalendarEventEntry entry : results) {
            // Get the start time for the event 
            When time = entry.getTimes().get(0); 
            DateTime start = time.getStartTime(); 
            
            // TODO Find a way to automate this switching.
            //(Offset is done in minutes)
            //start.setTzShift(-240);
            
            //Use an offset of -300 for non-Daylight Savings time.
            start.setTzShift(-300);
            
            // Concert to milliseconds to get a date object, which can be formatted easier. 
            Date entryDate = new Date(start.getValue() + 1000 * (start.getTzShift() * 60)); 
            
            String datePattern = "MM-dd-yyyy"; 
            SimpleDateFormat dateFormat = new SimpleDateFormat(datePattern);
            String startDay = dateFormat.format(entryDate);
            
            String eventTitle = new String(entry.getTitle().getPlainText());
            
            if (startDay.equals(date) && eventTitle.equals(title)) {
                String content = entry.getPlainTextContent(); 
                
                if (content.contains("<volunteers>")) {
                    String contentArray[] = content.split("<volunteers>");
                    StringBuffer volList = new StringBuffer(contentArray[1]);
                    //make sure the user isn't already in the list
                    if (!contentArray[1].contains(name.trim())) {
                        int end = volList.indexOf("</volunteers>");
                        volList.insert(end, name.trim() + " ; ");
                        content = contentArray[0] + volList;
                    }
                }
                else {
                    content += " <volunteers> " + name + " ; </volunteers>";
                }
                entry.setContent(new PlainTextConstruct(content));
                URL editUrl = new URL(entry.getEditLink().getHref());
                try {
                    myService.update(editUrl, entry);
                } catch (ServiceException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
                System.out.println( "Yes, we do run this." );
                
                //Search for existing calendars under this user's name
                URL newFeedUrl = new URL("https://www.google.com/calendar/feeds/default/owncalendars/full");
                CalendarFeed newResultFeed;
                try
                {
                    newResultFeed = myService.getFeed(newFeedUrl, CalendarFeed.class);
                    CalendarEntry returnedCalendar = null;
                    String usrCalUrl;
                    for( int i = 0; i < newResultFeed.getEntries().size(); i++ )
                    {
                        System.out.println( "One would hope at least this far." );
                        CalendarEntry newEntry = newResultFeed.getEntries().get( i );
                        //String compare is not a great way to do it, 
                        //but I'm not sure there is another option.
                        if( newEntry.getTitle().getPlainText().equals( name+"'s Jobs" ) )
                        {
                            returnedCalendar = newEntry;
                            // Get the calender's url
                            usrCalUrl = returnedCalendar.getId();
                            int splitHere = usrCalUrl.lastIndexOf("/") + 1;
                            usrCalUrl = usrCalUrl.substring(splitHere);
                            URL newUrl = new URL("http://www.google.com/calendar/feeds/" 
                                    + usrCalUrl + "/private/full");
                            myService.insert(newUrl, entry);
                            System.out.println("Even as far as this");
                            break;
                        }
                    }
                }
                catch ( ServiceException e )
                {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }
        }
        
        resp.sendRedirect("/calendar.jsp?name=" + name);
    }
}
    