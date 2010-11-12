package com.VolunteerCoordinatorApp;

import java.io.IOException;
import javax.jdo.PersistenceManager;
import javax.servlet.http.*;
import java.util.List;

@SuppressWarnings("serial")
public class EditCategoryServlet extends HttpServlet {
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
	        throws IOException {
		String cat = req.getParameter("cat");
		String title = req.getParameter("title");
		String action = req.getParameter("submit");
		
	    PersistenceManager pm = PMF.get().getPersistenceManager();
	    String query = "select from " + Category.class.getName();
	    List<Category> categories = (List<Category>) pm.newQuery(query).execute();
	    
        for (Category c : categories) {
            if (c.getName().equals(cat)) {
            	if (action.equals("Rename Category")) {
                	c.setName(title);
            	}
        	    else if (action.equals("Delete Category")) {
        	    	pm.deletePersistent(c);
        	    }
            }
        }
	    
	    pm.close();
		
		resp.sendRedirect("/catMaint.jsp");
		
	}	
	
}

