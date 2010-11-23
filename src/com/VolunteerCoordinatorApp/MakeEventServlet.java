

package com.VolunteerCoordinatorApp;

import java.io.IOException;
import javax.servlet.http.*;
import com.google.gdata.client.calendar.*;
import com.google.gdata.data.*;
import com.google.gdata.data.calendar.*;
import com.google.gdata.data.extensions.*;
import com.google.gdata.util.AuthenticationException;
import com.google.gdata.util.ServiceException;

import java.net.URL;

@SuppressWarnings("serial")
public class MakeEventServlet extends HttpServlet {
public void doPost(HttpServletRequest req, HttpServletResponse resp)
throws IOException {

	String name = req.getParameter("name");
	
	CalendarService cService = new CalendarService("Volunteer-Coordinator-Calendar");
	try {
		cService.setUserCredentials("rockcreekvolunteercoordinator@gmail.com", "G0covenant");
	} catch (AuthenticationException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
	
	URL postUrl =
		new URL("https://www.google.com/calendar/feeds/default/private/full");
	CalendarEventEntry entry = new CalendarEventEntry();
	//CalendarQuery q = new CalendarQuery(new URL("hello")); 
	
	entry.setTitle(new PlainTextConstruct(req.getParameter("title")));
	entry.setContent(new PlainTextConstruct("<description> "
			+ req.getParameter("what") + " "
			+ "\nFor: " + req.getParameter("for") + " "
			+ "\nWho should do it: " + req.getParameter("who") + " "
			+ "\nWhy: " + req.getParameter("why") + " </description>"
			+ " <category> " + req.getParameter("cat")
			+ " </category>")); // TODO format content better?
	
//	int day = Integer.parseInt(req.getParameter("day"));
//	int month = Integer.parseInt(req.getParameter("month"));
//	int year = Integer.parseInt(req.getParameter("year"));

	// TODO validate input
	int fromHrs = Integer.parseInt(req.getParameter("fromHrs"));
	int fromMins = Integer.parseInt(req.getParameter("fromMins"));
	int tillHrs = Integer.parseInt(req.getParameter("tillHrs"));
	int tillMins = Integer.parseInt(req.getParameter("tillMins"));
	
	if(req.getParameter("fromAMPM").equals("PM")) { 
		fromHrs += 12;
	}
	if(req.getParameter("toAMPM").equals("PM")) { 
		tillHrs += 12;
	}
	
	String date = req.getParameter("when");
	String month = date.substring(0, date.indexOf("/")); 
	String day = date.substring(date.indexOf("/") + 1, date.indexOf("/") + 3); 
	String year = date.substring(date.indexOf("/") + 4, date.length()); 
	String formattedDate = year + "-" + month + "-" + day; 
	
	String fromTime = formattedDate + "T" + req.getParameter("fromHrs")
		+ ":" + req.getParameter("fromMins") + ":00";  // + "-05:00"; //-5:00 adjusts to correct time zone
		String tillTime = formattedDate + "T" + req.getParameter("tillHrs")
		+ ":" + req.getParameter("tillMins") + ":00"; // + "-05:00"; //-5:00 adjusts to correct time zone
	
	System.out.println(fromTime); 
	System.out.println(tillTime); 
		
		
	DateTime startTime = DateTime.parseDateTime(fromTime);
	DateTime endTime = DateTime.parseDateTime(tillTime);
	When eventTimes = new When();
	eventTimes.setStartTime(startTime);
	eventTimes.setEndTime(endTime);
	entry.addTime(eventTimes);
	
	/*
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
	*/
	
	try {
		cService.insert(postUrl, entry);
	} catch (ServiceException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
	
	resp.sendRedirect("/index.jsp?name=" + name);
}

}