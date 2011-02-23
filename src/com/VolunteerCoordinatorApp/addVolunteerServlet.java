package com.VolunteerCoordinatorApp;

import java.io.*;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.*;

import javax.jdo.PersistenceManager;
import javax.jdo.Transaction;
import javax.servlet.http.*;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.gdata.client.calendar.CalendarQuery;
import com.google.gdata.client.calendar.CalendarService;
import com.google.gdata.data.*;
import com.google.gdata.data.acl.*;
import com.google.gdata.data.calendar.*;
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

		//If no user in query string, prompt to log in.
		if (name == null || name.equalsIgnoreCase("null") || name.equals(""))
		{
			//get url being used
			String url = req.getRequestURI().toString();
			String params = req.getQueryString();
			if (params != null) {
				url += "?" + params;
			}

			url = "/index.jsp?name=none&url=" + url;
			resp.sendRedirect( url );
		}        
		//Otherwise proceed normally.
		else
		{
			URL feedUrl = new URL("https://www.google.com/calendar/feeds/default/private/full"); //&max-results=10");


			CalendarQuery myQuery = new CalendarQuery(feedUrl);
			myQuery.setStringCustomParameter("futureevents", "true"); 

			CalendarService myService = new CalendarService("Volunteer-Coordinator-Calendar");
			try {
				myService.setUserCredentials("rockcreekvolunteercoordinator@gmail.com", "G0covenant");
			} catch (AuthenticationException e) {
				// TODO Auto-generated catch block
				System.out.println( "Failed to authenticate service." );
				e.printStackTrace();
			}
			// Send the request and receive the response:
			CalendarEventFeed resultFeed = null;
			try {
				resultFeed = myService.query(myQuery, CalendarEventFeed.class);
			} catch (ServiceException e) {
				// TODO Auto-generated catch block
				System.out.println( "Failed to send query." );
				e.printStackTrace();
			}

			List<CalendarEventEntry> results = (List<CalendarEventEntry>)resultFeed.getEntries();
			for (CalendarEventEntry entry : results) 
			{
				// Get the start time for the event 
				When time = entry.getTimes().get(0); 
				DateTime start = time.getStartTime(); 
				TimeZone estTZ =  TimeZone.getTimeZone("GMT-5");
				Date startDate = new Date(start.getValue());
				//Determine timezone offset in minutes, depending on whether or not
				//Daylight Savings Time is in effect
				if (estTZ.inDaylightTime(startDate)) { 
					start.setTzShift(-240); 
				} else {
					start.setTzShift(-300); 
				}

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
							content = contentArray[0] + "<volunteers>" + volList;
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
						System.out.println( "Failed to successfully set content." );
						e.printStackTrace();
					}

					//Get the ID of this user's calendar from the datastore.
					PersistenceManager pm = PMF.get().getPersistenceManager(); 

					Key k = KeyFactory.createKey(Volunteer.class.getSimpleName(), name);
					Volunteer v = pm.getObjectById(Volunteer.class, k);

					String usrCalUrl = v.getCalendarId();
					URL newUrl = new URL("http://www.google.com/calendar/feeds/" 
							+ usrCalUrl + "/private/full");
					//If insert is unsuccessful, we look for a way to replace the stored
					//calendar URL, up to and including making a new calendar.

					try
					{
						myService.insert(newUrl, entry);
					}
					catch ( ServiceException e )
					{
						System.out.println( "Failed to insert into calendar at " + usrCalUrl );
						URL newFeedUrl = new URL("https://www.google.com/calendar/feeds/default/owncalendars/full");
						CalendarFeed newResultFeed = null;
						try
						{
							newResultFeed = myService.getFeed(newFeedUrl, CalendarFeed.class);
						}
						catch ( ServiceException e3 )
						{
							// TODO Auto-generated catch block
							System.out.println( "Failed to fetch feed of calendars." );
							e3.printStackTrace();
						}
						String calUrl = null;
						for( int i = 0; i < newResultFeed.getEntries().size(); i++ )
						{
							CalendarEntry newEntry = newResultFeed.getEntries().get( i );
							//String compare is not a great way to do it, 
							//but I'm not sure there is another option.
							if( newEntry.getTitle().getPlainText().equals( name+"'s Jobs" ) )
							{
								CalendarEntry calendar = newEntry;
								// Get the calender's url
								calUrl = calendar.getId();
								int splitHere = calUrl.lastIndexOf("/") + 1;
								calUrl = calUrl.substring(splitHere);
								break;
							}
						}
						boolean calendarDeleted = false;
						//Check to see if we can access the calendar calUrl links to.
						//If we can't, it's assumed to have been deleted, and we proceed to make a new one.
						if( calUrl != null )
						{
							String nullString = null;
							try
							{
								URL testUrl = new URL("https://www.google.com/calendar/feeds/default/allcalendars/full/" + usrCalUrl);
								myService.getEntry( testUrl, CalendarEntry.class, nullString );
							}
							catch( Exception e1 )
							{
								System.out.println( "Failed to access calendar at " + calUrl );
								calendarDeleted = true;
							}
						}

						//No extant calendars for this user; make a new one.
						if( calUrl == null || calendarDeleted )
						{
							CalendarEntry calendar = new CalendarEntry();
							calendar.setTitle(new PlainTextConstruct(name + "'s Jobs"));
							calendar.setSummary(new PlainTextConstruct("This calendar contains the jobs " + name + " has volunteered for."));
							calendar.setTimeZone(new TimeZoneProperty("America/New_York"));
							calendar.setHidden(HiddenProperty.FALSE);

							// Insert the calendar
							URL postUrl = new URL("https://www.google.com/calendar/feeds/default/owncalendars/full");
							CalendarEntry newCalendar = null;
							try
							{
								newCalendar = myService.insert(postUrl, calendar);
							}
							catch ( ServiceException e2 )
							{
								// TODO Auto-generated catch block
								System.out.println( "Failed at getting inserting new calendar." );
								e2.printStackTrace();
							}
							// Get the calender's url
							calUrl = newCalendar.getId();
							int splitHere = calUrl.lastIndexOf("/") + 1;
							calUrl = calUrl.substring(splitHere);

							//Find events on the calendar with this user's name attached
							newFeedUrl = new URL("https://www.google.com/calendar/feeds/default/private/full");
							myQuery = new CalendarQuery(feedUrl);
							myQuery.setFullTextQuery(name);
							resultFeed = null;
							try
							{
								resultFeed = myService.query(myQuery, CalendarEventFeed.class);
							}
							catch ( ServiceException e1 )
							{
								// TODO Auto-generated catch block
								System.out.println( "Failed at getting a query." );
								e1.printStackTrace();
							}
							List<CalendarEventEntry> entries = (List<CalendarEventEntry>)resultFeed.getEntries();

							//Add all of those events to the new calendar
							if (!entries.isEmpty()) {
								for (CalendarEventEntry singleEntry : entries) {
									//Get the event's details
									TextConstruct entryTitle = singleEntry.getTitle();
									String entryContent = singleEntry.getPlainTextContent();
									When entryTime = singleEntry.getTimes().get(0);
									DateTime entryStart = entryTime.getStartTime();
									DateTime entryEnd = entryTime.getEndTime();

									//Create a new entry and add it
									URL newEntryUrl = new URL(
											"http://www.google.com/calendar/feeds/" + calUrl + "/private/full");
									CalendarEventEntry myEntry = new CalendarEventEntry();
									myEntry.setTitle(entryTitle);
									myEntry.setContent(new PlainTextConstruct(entryContent));
									When eventTimes = new When();
									eventTimes.setStartTime(entryStart);
									eventTimes.setEndTime(entryEnd);
									myEntry.addTime(eventTimes);

									// Send the request and receive the response:
									try
									{
									    myService.insert(newEntryUrl, myEntry);
									}
									catch ( ServiceException e1 )
									{
									    // TODO Auto-generated catch block
									    System.out.println( "Error inserting new entry into CalendarService." );
									    e1.printStackTrace();
									}
								}
							}
							// Access the Access Control List (ACL) for the calendar
							Link link = newCalendar.getLink(AclNamespace.LINK_REL_ACCESS_CONTROL_LIST,
									Link.Type.ATOM);
							//System.out.println( link.getHref() );
							URL aclUrl = new URL( link.getHref() );
							AclFeed aclFeed = null;
							try
							{
								aclFeed = myService.getFeed(aclUrl, AclFeed.class);
							}
							catch ( ServiceException e1 )
							{
								// TODO Auto-generated catch block
								System.out.println( "Failed at getting ACL Feed." );
								e1.printStackTrace();
							}

							// Set the default to "read-only" for all users
							AclEntry aclEntry = aclFeed.createEntry();
							aclEntry.setScope(new AclScope(AclScope.Type.DEFAULT, null));
							aclEntry.setRole(CalendarAclRole.READ);
							// Add it to the ACL  
							try
							{
								myService.insert(aclUrl, aclEntry);
							}
							catch ( ServiceException e1 )
							{
								// TODO Auto-generated catch block
	                            System.out.println( "Error inserting new entries into ACL." );
								e1.printStackTrace();
							}
						}

						//Assign calendar ID to the Volunteer object for the user in question.
						Volunteer volunteer = null;
						PersistenceManager persistenceManager = PMF.get().getPersistenceManager(); 
						Transaction tx = persistenceManager.currentTransaction();
						try
						{
							tx.begin();

							Key key = KeyFactory.createKey(Volunteer.class.getSimpleName(), name);
							volunteer = persistenceManager.getObjectById(Volunteer.class, key);
							volunteer.setCalendarId( calUrl );
							tx.commit();
						}
						catch (Exception e1)
						{
							if (tx.isActive())
							{
								tx.rollback();
							}
						}
					}
				}
			}        
			resp.sendRedirect("/calendar.jsp?name=" + name);
		}
	}
}

