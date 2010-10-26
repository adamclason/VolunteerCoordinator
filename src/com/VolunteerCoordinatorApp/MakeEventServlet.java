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
		entry.setContent(new PlainTextConstruct(req.getParameter("what") + " " +
				req.getParameter("for") + " " + 
				req.getParameter("who") + " " +
				req.getParameter("why"))); // TODO format content correctly
		
		int day = Integer.parseInt(req.getParameter("day"));
		int month = Integer.parseInt(req.getParameter("month"));
		int year = Integer.parseInt(req.getParameter("year"));
		int fromHrs = Integer.parseInt(req.getParameter("fromHrs"));
		int fromMins = Integer.parseInt(req.getParameter("fromMins"));
		int tillHrs = Integer.parseInt(req.getParameter("tillHrs"));
		int tillMins = Integer.parseInt(req.getParameter("tillMins"));

		String fromTime = year + "-" + month + "-" + day + "T" + fromHrs
		            + ":" + fromMins + ":00" + "-05:00"; //-5:00 adjusts to correct time zone 
		String tillTime = year + "-" + month + "-" + day + "T" + tillHrs
		            + ":" + tillMins + ":00" + "-05:00"; //-5:00 adjusts to correct time zone 
		
		DateTime startTime = DateTime.parseDateTime(fromTime);
		DateTime endTime = DateTime.parseDateTime(tillTime);
		When eventTimes = new When();
		eventTimes.setStartTime(startTime);
		eventTimes.setEndTime(endTime);
		entry.addTime(eventTimes);

		cService.insert(postUrl, entry);	
		
		resp.sendRedirect("/index.jsp");
	}	
	
}

