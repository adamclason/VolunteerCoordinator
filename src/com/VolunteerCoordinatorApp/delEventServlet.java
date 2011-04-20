package com.VolunteerCoordinatorApp;

import java.io.*;
import java.net.URL;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

import javax.jdo.PersistenceManager;
import javax.servlet.http.*;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.gdata.client.calendar.CalendarQuery;
import com.google.gdata.client.calendar.CalendarService;
import com.google.gdata.data.DateTime;
import com.google.gdata.data.calendar.CalendarEventEntry;
import com.google.gdata.data.calendar.CalendarEventFeed;
import com.google.gdata.data.extensions.*;
import com.google.gdata.util.AuthenticationException;
import com.google.gdata.util.ServiceException;

@SuppressWarnings("serial")
public class delEventServlet extends HttpServlet {
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
    throws IOException {
		doGet(req, resp); 
	}
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		String name = req.getParameter("name"); 
		String date = req.getParameter("date");
		String title = req.getParameter("title");
		String cat = req.getParameter("category"); 
		String pageNumber = req.getParameter("pageNum"); 
		String startRange = req.getParameter("startDate"); 
		String endRange = req.getParameter("endDate"); 
		String resultIndex = req.getParameter("resultIndex"); 
		String del = req.getParameter("del"); 

		if (req.getParameter("catCheck") == null) {
			cat = "null";
		}
		if ( date == null || date.equals("") || date.equals("null")) {
			date = "null";
		}
		if (endRange == null || endRange.equals("") || endRange.equals("null")) {
			endRange = "null";
		}

	    //If no user in query string, prompt to log in.
	    if (name == null || name.equalsIgnoreCase("null") || name.equals(""))
	    {
	    	resp.sendRedirect("/loginredirect?url=" + req.getRequestURI() + "?" 
	    			+ req.getQueryString());
	    }
		
		URL feedUrl = new URL("https://www.google.com/calendar/feeds/default/" +
		        "private/full");
		  
		CalendarQuery myQuery = new CalendarQuery(feedUrl);
		myQuery.setStringCustomParameter("orderby", "starttime");
		myQuery.setStringCustomParameter("sortorder", "ascending");
		if (del == null) {
			del = "";
		}
		if (del.equals("this")) {
		    myQuery.setStringCustomParameter("singleevents", "true");
		}
		
		if (date != "null") {
		      SimpleDateFormat format = new SimpleDateFormat("MM-dd-yyyy");
			try {
				Date start = format.parse(date);
			    DateTime startDT = new DateTime(start);
			    myQuery.setMinimumStartTime(startDT); 
			} catch (ParseException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		 }
		   
		CalendarService myService = new CalendarService("Volunteer-Coordinator-Calendar"); 
		try {
			myService.setUserCredentials("rockcreekvolunteercoordinator@gmail.com", "G0covenant");
		} catch (AuthenticationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		// Send the request and receive the response:
		CalendarEventFeed resultFeed = null;
		try {
			resultFeed = myService.query(myQuery, CalendarEventFeed.class);
		} catch (ServiceException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		  
		List<CalendarEventEntry> results = (List<CalendarEventEntry>)resultFeed.getEntries();
		CalendarEventEntry event = null; //References the event to be deleted
		
		if (del.equals("all")) {
			ArrayList<CalendarEventEntry> recurList = new ArrayList<CalendarEventEntry>();
			//Get the events in the series of recurring events
			for (CalendarEventEntry entry : results) {
				String eventTitle = new String(entry.getTitle().getPlainText());
				if (eventTitle.equals(title)) { //Check title to see if it's the correct event
					recurList.add(entry);
				}
			}
			event = recurList.get(0); //Set the first one (holds recurring data) to be deleted
		} else { //Select event to delete as normal
		    PersistenceManager pManager = PMF.get().getPersistenceManager(); 

		    Key k = KeyFactory.createKey(Volunteer.class.getSimpleName(), name);
		    Volunteer vol = pManager.getObjectById(Volunteer.class, k);
		    
		    String timeZone = vol.getTimeZone();
		    
		    TimeZone TZ =  TimeZone.getTimeZone( timeZone );
		    
			for (CalendarEventEntry entry : results) {
				// Get the start time for the event 
				When time = entry.getTimes().get(0); 
				DateTime start = time.getStartTime(); 

				Date startDate = new Date(start.getValue());
				//Determine timezone offset in minutes, depending on whether or not
				//Daylight Savings Time is in effect
				if (TZ.inDaylightTime(startDate)) { 
					start.setTzShift(-240); 
				} else {
					start.setTzShift(-300); 
				}

				// Convert to milliseconds to get a date object, which can be formatted easier. 
				Date entryDate = new Date(start.getValue() + 1000 * (start.getTzShift() * 60)); 

				String datePattern = "MM-dd-yyyy"; 
				SimpleDateFormat dateFormat = new SimpleDateFormat(datePattern);
				String startDay = dateFormat.format(entryDate);

				String eventTitle = new String(entry.getTitle().getPlainText());
				
				if (startDay.equals(date) && eventTitle.equals(title)) {
					event = entry;
				}
			}
		}
		
		if (event != null) { //Delete the event
			try {
				event.delete();
			} catch (ServiceException e) {
				e.printStackTrace();
			}
		}
        
        resp.sendRedirect("/manProj.jsp?name=" + name + "&startDate=" + startRange + "&endDate="
        		+ endRange + "&category=" + cat + "&pageNumber=" + pageNumber
        		+ "&resultIndex=" + resultIndex);
	}
}
	