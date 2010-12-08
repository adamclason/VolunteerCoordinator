package com.VolunteerCoordinatorApp;

import java.io.IOException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.google.gdata.client.calendar.CalendarService;
import com.google.gdata.data.calendar.*;
import com.google.gdata.util.*;

import java.net.URL;

@SuppressWarnings("serial")
public class delUsrCalendarsServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		
	    CalendarService myService = new CalendarService("Volunteer-Coordinator-Calendar"); 
	    try {
			myService.setUserCredentials("rockcreekvolunteercoordinator@gmail.com", "G0covenant");
		} catch (AuthenticationException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		
		URL feedUrl = new URL("https://www.google.com/calendar/feeds/default/owncalendars/full");
		CalendarFeed resultFeed;
		try {
			resultFeed = myService.getFeed(feedUrl, CalendarFeed.class);
			CalendarEntry calendar = resultFeed.getEntries().get(0);
			for (int i = 0; i < resultFeed.getEntries().size(); i++) {
			  CalendarEntry entry = resultFeed.getEntries().get(i);
			  System.err.println("Deleting calendar: " + entry.getTitle().getPlainText());
			  try {
			    entry.delete();
			  } catch (InvalidEntryException e) {
			    System.err.println("\tUnable to delete primary calendar");
			  }
		    }
		} catch (ServiceException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
		}
	}
}