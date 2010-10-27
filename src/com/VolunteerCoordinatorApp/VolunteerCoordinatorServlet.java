package com.VolunteerCoordinatorApp;

import java.util.List;
import java.io.IOException;
import javax.servlet.http.*;
import javax.jdo.Query; 
import javax.jdo.PersistenceManager;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;

@SuppressWarnings("serial")
public class VolunteerCoordinatorServlet extends HttpServlet {
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		String name = req.getParameter("name"); 
		String task = req.getParameter("task"); 
		if(!userExists(name)) {
			resp.sendRedirect("/newUser.jsp?name=" 
					+ name.substring(0, name.indexOf(" ")) + "+"
					+ name.substring(name.indexOf(" "), name.length()).trim()
					+ "&task=" + task);
		}
		else if(task.equals("volunteer")) {
			resp.sendRedirect("/volunteer.jsp");
		} else if(task.equals("initiate")) {
			resp.sendRedirect("/add.jsp"); 
		} else if(task.equals("manage")) {
			resp.sendRedirect("/manProj.html"); 
		} else if(task.equals("dashboard")) {
			resp.sendRedirect("/dashboard.html"); 
		} else if(task.equals("preferences")) {
			resp.sendRedirect("/prefs.jsp?name=" 
				+ name.substring(0, name.indexOf(" ")) + "+"
				+ name.substring(name.indexOf(" "), name.length()).trim()
				+ "&email=" + getEmail(name)
				+ "&phone=" + getPhone(name)
				+ "&reminder=" + getReminder(name)); 
		}

	}
	
	private boolean userExists(String name) { 
		PersistenceManager pm = PMF.get().getPersistenceManager(); 
		Query query = pm.newQuery(Volunteer.class); 
		query.setFilter("name == nameParam"); 
		query.declareParameters("String nameParam"); 
		
		List<Volunteer> results = (List<Volunteer>)query.execute(name); 
		
		if(results.isEmpty()) {
			return false; 
		} else {
			return true; 
		}
	}
	
	private String getEmail(String name) {
		PersistenceManager pm = PMF.get().getPersistenceManager(); 

	    Key k = KeyFactory.createKey(Volunteer.class.getSimpleName(), name);
	    Volunteer v = pm.getObjectById(Volunteer.class, k);
	    
		return v.getEmail();
	}
	
	private String getPhone(String name) {
		PersistenceManager pm = PMF.get().getPersistenceManager(); 

	    Key k = KeyFactory.createKey(Volunteer.class.getSimpleName(), name);
	    Volunteer v = pm.getObjectById(Volunteer.class, k);
	    
		return v.getPhone();
	}
	
	private String getReminder(String name) {
		PersistenceManager pm = PMF.get().getPersistenceManager(); 

	    Key k = KeyFactory.createKey(Volunteer.class.getSimpleName(), name);
	    Volunteer v = pm.getObjectById(Volunteer.class, k);
	    
		return v.getReminder();
	}
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
	        throws IOException {
	    doPost(req, resp);
	}
}
