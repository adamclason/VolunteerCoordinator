package com.VolunteerCoordinatorApp;

import java.io.IOException;
import java.util.*;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class ValidateFilterInput extends HttpServlet {
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
    	throws IOException {
		
		Map<String, String> errors = new HashMap<String, String>(); 
		
		String startDate = req.getParameter("startDate"); 
		
	}
}
