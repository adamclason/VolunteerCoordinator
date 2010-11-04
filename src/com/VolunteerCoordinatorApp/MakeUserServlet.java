package com.VolunteerCoordinatorApp;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import javax.jdo.PersistenceManager;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;

@SuppressWarnings("serial")
public class MakeUserServlet extends HttpServlet {
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
    throws IOException {
		doGet(req, resp); 
	}
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
	        throws IOException {
		String firstName = req.getParameter("firstName"); 
		String lastName = req.getParameter("lastName");
		String email = req.getParameter("email");  
		String phone = req.getParameter("phone");  
		String reminder = req.getParameter("reminder");
		String task = req.getParameter("task"); 
		String name = firstName + " " + lastName; 
		

        PersistenceManager pm = PMF.get().getPersistenceManager();

        Volunteer v = new Volunteer(firstName, lastName, email, phone, reminder);
        
        Key key = KeyFactory.createKey(Volunteer.class.getSimpleName(), (firstName + " " + lastName));
        v.setKey(key);
       
        try {
            pm.makePersistent(v);
        } finally {
            pm.close();
        }
        
        req.setAttribute("name", name);
		req.setAttribute("task", task); 
	
		RequestDispatcher rd= req.getRequestDispatcher("/volunteercoordinator");
		
		try {
			rd.forward(req, resp);
		} catch (ServletException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 
		
	}	
	

}
