package com.VolunteerCoordinatorApp;

import java.io.IOException;
import javax.servlet.http.*;
import javax.jdo.PersistenceManager;

@SuppressWarnings("serial")
public class MakeUserServlet extends HttpServlet {
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
	        throws IOException {
		String firstName = req.getParameter("firstName"); 
		String lastName = req.getParameter("lastName");  
		String email = req.getParameter("email");  
		String phone = req.getParameter("phone");  
		String reminder = req.getParameter("reminder");

        PersistenceManager pm = PMF.get().getPersistenceManager();

        Volunteer e = new Volunteer(firstName, lastName, email, phone, reminder);

        try {
            pm.makePersistent(e);
        } finally {
            pm.close();
        }
		
        resp.sendRedirect("/index.jsp?first=" + firstName
        		+ "&" + "last=" + lastName);
		
	}	
	
}

