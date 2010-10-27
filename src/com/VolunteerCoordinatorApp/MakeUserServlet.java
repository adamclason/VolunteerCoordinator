package com.VolunteerCoordinatorApp;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.http.*;
import javax.jdo.PersistenceManager;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;

@SuppressWarnings("serial")
public class MakeUserServlet extends HttpServlet {
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
	        throws IOException {
		String firstName = req.getParameter("firstName"); 
		String lastName = req.getParameter("lastName");
		String email = req.getParameter("email");  
		String phone = req.getParameter("phone");  
		String reminder = req.getParameter("reminder");
		String task = req.getParameter("task");  

        PersistenceManager pm = PMF.get().getPersistenceManager();

        Volunteer v = new Volunteer(firstName, lastName, email, phone, reminder);
        
        Key key = KeyFactory.createKey(Volunteer.class.getSimpleName(), (firstName + " " + lastName));
        v.setKey(key);
        
        try {
            pm.makePersistent(v);
        } finally {
            pm.close();
        }
		
        resp.sendRedirect("/volunteercoordinator?task=" + task 
        		+ "&name=" + firstName
        		+ "+" + lastName);
        
        
        //RequestDispatcher dispatch = getServletContext().getRequestDispatcher("/volunteercoordinator");
        //dispatch.forward(req, resp);
        
	}	
	
}

