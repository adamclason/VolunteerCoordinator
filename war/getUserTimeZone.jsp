<%@ page import="javax.jdo.PersistenceManager, 
javax.jdo.Transaction,
com.VolunteerCoordinatorApp.PMF,
com.VolunteerCoordinatorApp.Volunteer,
com.google.appengine.api.datastore.Key,
com.google.appengine.api.datastore.KeyFactory"
%>
<%
String tzName = request.getParameter("name");
String timeZone = null;
System.err.println("getTimeZone name="+tzName);
if( tzName != null )
{
    PersistenceManager pManager = PMF.get().getPersistenceManager(); 

    Key k = KeyFactory.createKey(Volunteer.class.getSimpleName(), tzName);
    Volunteer vol = pManager.getObjectById(Volunteer.class, k);
    
    timeZone = vol.getTimeZone();
    if( timeZone == null )
    {
        timeZone = "America/New_York";
    }
}
else
{
    timeZone = "America/New_York";
}

%>