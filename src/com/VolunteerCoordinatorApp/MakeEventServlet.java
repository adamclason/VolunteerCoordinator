package com.VolunteerCoordinatorApp;

import java.io.IOException;
import javax.servlet.http.*;
import javax.jdo.PersistenceManager;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.gdata.client.*;
import com.google.gdata.client.calendar.*;
import com.google.gdata.data.*;
import com.google.gdata.data.acl.*;
import com.google.gdata.data.calendar.*;
import com.google.gdata.data.extensions.*;
import com.google.gdata.util.*;
import java.net.URL;

@SuppressWarnings("serial")
public class MakeEventServlet extends HttpServlet {
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
	        throws IOException {
		
		CalendarService cService = new CalendarService("exampleCo-exampleApp-1");
		cService.setUserCredentials("jo@gmail.com", "mypassword"); // TODO change credentials and servicename
		
		URL postUrl = // TODO change url:
		  new URL("https://www.google.com/calendar/feeds/jo@gmail.com/private/full");
		CalendarEventEntry entry = new CalendarEventEntry();

		entry.setTitle(new PlainTextConstruct(req.getParameter("title")));
		entry.setContent(new PlainTextConstruct(req.getParameter("what")));

		DateTime startTime = DateTime.parseDateTime("2006-04-17T15:00:00-08:00");
		DateTime endTime = DateTime.parseDateTime("2006-04-17T17:00:00-08:00");
		When eventTimes = new When();
		eventTimes.setStartTime(startTime);
		eventTimes.setEndTime(endTime);
		entry.addTime(eventTimes);

		cService.insert(postUrl, entry);		
	}	
	
}

