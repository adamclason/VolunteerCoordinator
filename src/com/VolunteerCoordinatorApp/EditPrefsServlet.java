package com.VolunteerCoordinatorApp;

import java.io.IOException;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.*;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;

@SuppressWarnings("serial")
public class EditPrefsServlet extends HttpServlet {
    public void doPost(HttpServletRequest req, HttpServletResponse resp)
    throws IOException {
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String reminder = req.getParameter("reminder");
        String timeZone = req.getParameter( "timeZone" );
        String origName = req.getParameter( "origName" );

        PersistenceManager pm = PMF.get().getPersistenceManager(); 

        Key k = KeyFactory.createKey(Volunteer.class.getSimpleName(), origName);
        Volunteer v = pm.getObjectById(Volunteer.class, k);


        v.setEmail(email);
        v.setPhone(phone);
        v.setReminder(reminder);
        v.setTimeZone( timeZone );
        pm.close();

        resp.sendRedirect("/prefs.jsp?name=" + v.getFirstName() + " " + v.getLastName() );
    }	
}

