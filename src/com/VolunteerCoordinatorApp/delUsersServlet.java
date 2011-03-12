package com.VolunteerCoordinatorApp;

import java.io.IOException;
import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.google.gdata.client.calendar.CalendarService;
import com.google.gdata.data.calendar.*;
import com.google.gdata.util.*;
import java.util.List;
import javax.jdo.Query;
import java.net.URL;

@SuppressWarnings("serial")
public class delUsersServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		
	    CalendarService myService = new CalendarService("Volunteer-Coordinator-Calendar"); 
	    try {
			myService.setUserCredentials("rockcreekvolunteercoordinator@gmail.com", "G0covenant");
		} catch (AuthenticationException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		
		PersistenceManager pm = PMF.get().getPersistenceManager();
		Query query = pm.newQuery(Volunteer.class);

	    try {
	        List<Volunteer> results = (List<Volunteer>) query.execute();
	        if (!results.isEmpty()) {
	            for (Volunteer v : results) {
	                System.err.println(v.getFirstName() + " " + v.getLastName());
	                pm.deletePersistent(v);
	            }
	        } else {
	            // ... no results ...
	        	System.err.println("first no results");
	        }

	        //go again - should be empty
	        results = (List<Volunteer>) query.execute();
	        if (!results.isEmpty()) {
	            for (Volunteer v : results) {
	                System.err.println(v.getFirstName() + " " + v.getLastName());
	            }
	        } else {
	            // ... no results ...
	        	System.err.println("second no results");
	        }
	    } finally {
	        query.closeAll();
	    }
	}
}