package com.VolunteerCoordinatorApp;

import java.io.IOException;
import javax.servlet.http.*;
import javax.jdo.PersistenceManager;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;

@SuppressWarnings("serial")
public class MakeCategoryServlet extends HttpServlet {
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
    throws IOException {
		doGet(req, resp); 
	}
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
	        throws IOException {
		String name = req.getParameter("name"); 
		String title = req.getParameter("title"); 
		

        PersistenceManager pm = PMF.get().getPersistenceManager();

        Category c = new Category(title);
        
        Key key = KeyFactory.createKey(Category.class.getSimpleName(), title);
        c.setKey(key);
       
        try {
            pm.makePersistent(c);
        } finally {
            pm.close();
        }
        
        resp.sendRedirect("/newCat.jsp?name=" + name);
		
	}	
	

}
