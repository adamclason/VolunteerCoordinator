package com.VolunteerCoordinatorApp;

import java.io.IOException;
import javax.servlet.http.*;
import com.google.gdata.client.calendar.*;
import com.google.gdata.data.*;
import com.google.gdata.data.calendar.*;
import com.google.gdata.data.extensions.*;
import java.net.URL;

@SuppressWarnings("serial")
public class MakeEventServlet extends HttpServlet {
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
	        throws IOException {
		
		CalendarService cService = new CalendarService("Volunteer-Coordinator-Calendar");
		cService.setUserCredentials("rockcreekvolunteercoordinator@gmail.com", "G0covenant");
		
		URL postUrl =
		  new URL("https://www.google.com/calendar/feeds/default/private/full");
		CalendarEventEntry entry = new CalendarEventEntry();

		entry.setTitle(new PlainTextConstruct(req.getParameter("title")));
		entry.setContent(new PlainTextConstruct("<description>"
				+ req.getParameter("what") + " "
				+ "\nFor: " + req.getParameter("for") + " " 
				+ "\nWho should do it: " + req.getParameter("who") + " "
				+ "\nWhy: " + req.getParameter("why") + "</description>")); // TODO format content better?
		
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

		String recurStr = req.getParameter("recur");
		if (!recurStr.equals("none")) {
			String recurData = new String("");
			if (recurStr.equals("week")) {
				recurData = "DTSTART;VALUE=DATE:" + year + month + day + "\r\n"
		            + "DTEND;VALUE=DATE:" + year + month + day + "\r\n"
		            + "RRULE:FREQ=WEEKLY\r\n";
			}
			else if (recurStr.equals("biweek")) {
				recurData = "DTSTART;VALUE=DATE:" + year + month + day + "\r\n"
	                + "DTEND;VALUE=DATE:" + year + month + day + "\r\n"
	                + "RRULE:FREQ=WEEKLY;INTERVAL=2\r\n";
			}
			else if (recurStr.equals("month")) {
				recurData = "DTSTART;VALUE=DATE:" + year + month + day + "\r\n"
	                + "DTEND;VALUE=DATE:" + year + month + day + "\r\n"
	                + "RRULE:FREQ=MONTHLY\r\n";
			}
			Recurrence recur = new Recurrence();
			recur.setValue(recurData);
			entry.setRecurrence(recur);
		}
				
		cService.insert(postUrl, entry);	
		
		resp.sendRedirect("/index.jsp");
	}	
	
}

