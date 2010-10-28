package com.VolunteerCoordinatorApp;

import java.io.IOException;
import javax.jdo.PersistenceManager;
import javax.servlet.http.*;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;

@SuppressWarnings("serial")
public class EditPrefsServlet extends HttpServlet {
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
	        throws IOException {
		String name = req.getParameter("name");
		String email = req.getParameter("email");
		String phone = req.getParameter("phone");
	    String reminder = req.getParameter("reminder");

		PersistenceManager pm = PMF.get().getPersistenceManager(); 

	    Key k = KeyFactory.createKey(Volunteer.class.getSimpleName(), name);
	    Volunteer v = pm.getObjectById(Volunteer.class, k);
        
	    v.setEmail(email);
	    v.setPhone(phone);
	    v.setReminder(reminder);
	    pm.close();
		
		resp.sendRedirect("/index.jsp?name=" 
					+ name.substring(0, name.indexOf(" ")) + "+"
					+ name.substring(name.indexOf(" "), name.length()).trim());
		
	}	
	
}

