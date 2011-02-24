package com.VolunteerCoordinatorApp;

import java.io.IOException;
import java.net.URL;
import javax.servlet.http.*;
import java.text.SimpleDateFormat;
import java.util.*;
import javax.jdo.PersistenceManager;
import javax.mail.*;
import javax.mail.internet.*;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.gdata.client.calendar.CalendarQuery;
import com.google.gdata.client.calendar.CalendarService;
import com.google.gdata.data.DateTime;
import com.google.gdata.data.calendar.CalendarEventEntry;
import com.google.gdata.data.calendar.CalendarEventFeed;
import com.google.gdata.data.extensions.ExtendedProperty;
import com.google.gdata.data.extensions.When;
import com.google.gdata.util.AuthenticationException;
import com.google.gdata.util.ServiceException;

@SuppressWarnings("serial")
public class MailerServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {		
        CalendarService myService = new CalendarService("Volunteer-Coordinator-Calendar"); 
        try {
			myService.setUserCredentials("rockcreekvolunteercoordinator@gmail.com", "G0covenant");
		} catch (AuthenticationException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
        
		URL feedUrl = new URL("https://www.google.com/calendar/feeds/default/private/full");
		CalendarQuery myQuery = new CalendarQuery(feedUrl);

	    SimpleDateFormat format = new SimpleDateFormat("MM/dd/yyyy");
	    Date today = new Date();
	    Date tomorrow = new Date();
	    DateTime startDT = new DateTime(today); 
	    DateTime endDT = new DateTime(tomorrow); 

	    //shift end date to the next day (86400000 milliseconds = 1 day), then
	    // shift end date to midnight at end of day instead of beginning of day
	    // this assumes the MailerServlet is being run at midnight
	    long endL = endDT.getValue();
	    endL += 86400000 + 86399999;
	    endDT.setValue(endL);
	    
	    myQuery.setMinimumStartTime(startDT); 
	    myQuery.setMaximumStartTime(endDT); 
	    
	    // Send the request and get the list of events between today and tommorrow
	    CalendarEventFeed resultFeed = null;
		try {
			resultFeed = myService.query(myQuery, CalendarEventFeed.class);
		} catch (ServiceException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}	   
	    List<CalendarEventEntry> results = (List<CalendarEventEntry>)resultFeed.getEntries();
	    
	    if (!results.isEmpty()) {
	    	for (CalendarEventEntry entry : results) {
	    		// Get event details

	    		// Get the start and end times for the event 
	            When time = entry.getTimes().get(0); 
	            DateTime start = time.getStartTime(); 
	            DateTime end = time.getEndTime();

	            TimeZone estTZ =  TimeZone.getTimeZone("America/New_York");
	            Date startDate = new Date(start.getValue());
	            Date endDate = new Date(end.getValue());
	            //Determine timezone offset in minutes, depending on whether or not
	            //Daylight Savings Time is in effect
	            if (estTZ.inDaylightTime(startDate)) { 
	                start.setTzShift(-240); 
	            } else {
	         	   start.setTzShift(-300); 
	            }
	            if (estTZ.inDaylightTime(endDate)) { 
	                end.setTzShift(-240);
	            } else {
	                end.setTzShift(-300);
	            }
	            
	            // Convert to milliseconds to get a date object, which can be formatted easier. 
	            startDate = new Date(start.getValue() + 1000 * (start.getTzShift() * 60)); 
	            //Date endDate = new Date(end.getValue() + 1000 * (end.getTzShift() * 60)); 
	            
	            String hourPattern = "hh:mma"; 
	            SimpleDateFormat timeFormat = new SimpleDateFormat(hourPattern); 
	            String startDay = format.format(startDate); 
	            String startTime = timeFormat.format(startDate);
	            //String endTime = timeFormat.format(endDate); 
	            
	            String title = entry.getTitle().getPlainText();
	            
	            // Access the description field of the calendar 
	            // event, where the event description and a list 
	            // of volunteers is stored. 
	            String content = entry.getPlainTextContent(); 
	            Scanner sc = new Scanner(content); 
	            String description = "";
	            String forWho = "";
	            String who = "";
	            String why = "";
	            String category = "";
	            ArrayList<String> volList = new ArrayList<String>();
	            
	            String cur = sc.next().trim();
	            if(cur.equals("<description>")) 
	            {
	               cur = sc.next(); 
	               while(!cur.equals("</description>")) 
	               {
	                  description += cur + " ";
	                  cur = sc.next(); 
	               }
	               if (sc.hasNext()) 
	               {
	                   cur = sc.next();
	               }
	            }
	            if( cur.equals( "<for>" ) )
	            {
	                cur = sc.next();
	                while( !cur.equals( "</for>" ) )
	                {
	                    forWho += cur + " ";
	                    cur = sc.next(); 
	                 }
	                 if (sc.hasNext()) 
	                 {
	                     cur = sc.next();
	                 }
	            }
	            if( cur.equals( "<who>" ) )
	            {
	                cur = sc.next();
	                while( !cur.equals( "</who>" ) )
	                {
	                    who += cur + " ";
	                    cur = sc.next(); 
	                 }
	                 if (sc.hasNext()) 
	                 {
	                     cur = sc.next();
	                 }
	            }
	            if( cur.equals( "<why>" ) )
	            {
	                cur = sc.next();
	                while( !cur.equals( "</why>" ) )
	                {
	                    why += cur + " ";
	                    cur = sc.next(); 
	                 }
	                 if (sc.hasNext()) 
	                 {
	                     cur = sc.next();
	                 }
	            }
	            if(cur.equals("<category>")) 
	            {
	                cur = sc.next();
	                while(!cur.equals("</category>")) 
	                {
	                   category += cur + " "; 
	                   cur = sc.next(); 
	                }
	                if (sc.hasNext()) 
	                {
	                    cur = sc.next();
	                }
	            } 
	            if(cur.equals("<volunteers>")) 
	            {
	                cur = sc.next();
	                while(!cur.equals("</volunteers>")) 
	                {
	                	String curName = new String("");
	                	while (!cur.equals(";")) {
	                		curName += cur + " "; 
			                cur = sc.next();
	                	} 
	 	                volList.add(curName.trim());
		                cur = sc.next();
	                }
	                if (sc.hasNext()) 
	                {
	                    cur = sc.next();
	                }
	            }
	            
	       		List<ExtendedProperty> propList = entry.getExtendedProperty();
	       		for (ExtendedProperty prop : propList) {
	       			if (prop.getName().equals("category")) {
	       				category = prop.getValue();
	       			}
	       		}
	       		
	    		PersistenceManager pm = PMF.get().getPersistenceManager(); 
	          if (!volList.isEmpty()) {       		
	       		for (String vol : volList) {
		            Properties props = new Properties();
		            Session session = Session.getDefaultInstance(props, null);

	       			String msgSubj = new String("Volunteer Reminder");
	       			String msgBody = new String("Dear " + vol + ",\n" + 
	       					"This is a friendly reminder that you volunteered to " +
	       					"help out with \"" + title + "\" on " + startDay + " at " +
	       					startTime + ". Don't forget!\n" +
	       							"Thank you,\n" +
	       							"Rock Creek Fellowship");

	       			// Get volunteer's email address
	       		    Key k = KeyFactory.createKey(Volunteer.class.getSimpleName(), vol);
	       		    Volunteer v = pm.getObjectById(Volunteer.class, k);
	       	        String recip = v.getEmail();

	       	      //must be "address of a registered developer for the application" (Google documentation)
	       	        String senderAddress = new String("rockcreekvolunteercoordinator@gmail.com");
	       	        String senderName = new String("Rock Creek Fellowship"); //optional

	       	        try {
	       	            InternetAddress[] recipEmail = InternetAddress.parse(recip);
	       	            
	       	            Message msg = new MimeMessage(session);
	       	            msg.setFrom(new InternetAddress(senderAddress, senderName));
	       	            msg.addRecipients(Message.RecipientType.TO, recipEmail); //other possible types: cc, bcc
	       	            msg.setSubject(msgSubj);
	       	            msg.setText(msgBody);
	       	            Transport.send(msg);

	       	        } catch (AddressException e) {
	       	        	System.err.println("Address Exception");
	       	        } catch (MessagingException e) {
	       	        	System.err.println("Messaging Exception");
	       	        } 
	       		}
	       	  }    		
	            
	            
	            
	            
	            
	            
		    }
	    }
		
	}
    
}
