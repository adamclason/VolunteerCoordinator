<%@ page import="javax.jdo.PersistenceManager, 
javax.jdo.Transaction,
com.VolunteerCoordinatorApp.PMF,
com.VolunteerCoordinatorApp.Volunteer,
com.google.appengine.api.datastore.Key,
com.google.appengine.api.datastore.KeyFactory"
%>
<%
String timeZone = null;
if( name != null )
{
    PersistenceManager pManager = PMF.get().getPersistenceManager(); 

    Key k = KeyFactory.createKey(Volunteer.class.getSimpleName(), name);
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