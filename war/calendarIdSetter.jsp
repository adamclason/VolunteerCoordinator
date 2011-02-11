<%@ page import="java.util.*,
    java.net.URL, javax.jdo.PersistenceManager, 
    javax.jdo.Transaction,
    com.VolunteerCoordinatorApp.PMF,
    com.VolunteerCoordinatorApp.Volunteer,
    com.google.appengine.api.datastore.Key,
    com.google.appengine.api.datastore.KeyFactory,
    com.google.gdata.client.calendar.*,
    com.google.gdata.data.calendar.*,
    java.net.URL"
%>
<%
    URL newFeedUrl = new URL("https://www.google.com/calendar/feeds/default/owncalendars/full");
    CalendarFeed newResultFeed = myService.getFeed(newFeedUrl, CalendarFeed.class);
    CalendarEntry calendar = null;
    String calUrl = null;
    for( int i = 0; i < newResultFeed.getEntries().size(); i++ )
    {
        CalendarEntry newEntry = newResultFeed.getEntries().get( i );
        //String compare is not a great way to do it, 
        //but I'm not sure there is another option.
        if( newEntry.getTitle().getPlainText().equals( name+"'s Jobs" ) )
        {
            calendar = newEntry;
            // Get the calender's url
            calUrl = calendar.getId();
            int splitHere = calUrl.lastIndexOf("/") + 1;
            calUrl = calUrl.substring(splitHere);
            break;
        }
    }
    Volunteer volunteer = null;
    if( calUrl != null )
    {
        calendar = new CalendarEntry();
        PersistenceManager persistenceManager = PMF.get().getPersistenceManager(); 
        Transaction tx = persistenceManager.currentTransaction();
        try
        {
            tx.begin();

            Key key = KeyFactory.createKey(Volunteer.class.getSimpleName(), name);
            volunteer = persistenceManager.getObjectById(Volunteer.class, key);
            volunteer.setCalendarId( calUrl );
            tx.commit();
        }
        catch (Exception e)
        {
            if (tx.isActive())
            {
                tx.rollback();
            }
        }
    }
    else
    {
        out.println( "<strong>Unable to find a calendar for this user.</strong>" );
        System.out.println( "Unable to find calendar" );
    }
%>