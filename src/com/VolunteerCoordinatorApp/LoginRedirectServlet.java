package com.VolunteerCoordinatorApp;

import java.io.IOException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

//This servlet takes you to index which prompts user to log in

@SuppressWarnings("serial")
public class LoginRedirectServlet extends HttpServlet {
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
    throws IOException {
        doPost(req, resp); 
    }
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
	throws IOException {
		//get url being used
		String url = req.getRequestURI().toString();
		String params = req.getQueryString();

		String urlPart = params.split("url=")[1];
		String urlPieces[] = urlPart.split("\\?");
		url = urlPieces[0] + "?"; // /servlet?
		if (urlPieces.length > 1) {
			urlPart = urlPieces[1]; // query1=param&name=null&query2=param
			if (urlPart.contains("name=")) { //Make sure a name parameter exists to be extracted
				int urlTwo = urlPart.indexOf("name=");
				url += urlPart.substring(0, urlTwo); // /servlet?query1=param&
				if (urlPart.contains("&")) {
					int urlThree = urlPart.indexOf("&", urlTwo) + 1; //+1 so doesn't include a second '&'
					if (urlThree != -1) {
						url += urlPart.substring(urlThree); // /servlet?query1=param&query2=param
					}
				}
			} else {
				url += urlPart;
			}
		}

	    url = "/index.jsp?name=none&url=" + url;
	    resp.sendRedirect( url );
	}
}
