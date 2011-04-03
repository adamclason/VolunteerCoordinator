<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="com.VolunteerCoordinatorApp.PMF" %>
<%@ page import="com.VolunteerCoordinatorApp.Category" %>
<%@ page import="java.net.*,
    java.util.*, 
    com.google.gdata.client.*, 
    com.google.gdata.client.calendar.*,
    com.google.gdata.data.*,
    com.google.gdata.data.acl.*,
    com.google.gdata.data.calendar.*,
    com.google.gdata.data.extensions.*,
    com.google.gdata.util.*,
    com.google.common.collect.Maps,
    java.io.*,
    java.text.SimpleDateFormat"
%>

<link rel="stylesheet" type="text/css" href="stylesheets/layout.css" />
<link rel="stylesheet" type="text/css" href="stylesheets/colors.css" />
<link rel="stylesheet" type="text/css" href="stylesheets/jquery-ui-1.8.6.custom.css" />

<%@ include file="getCalendarService.jsp"  %>


<script src="javascript/jquery-1.4.2.min.js"> </script>
<script src="javascript/jquery-ui-1.8.6.custom.min.js"> </script>
<script src="javascript/addEvent.js"> </script>

<title>Edit Job</title>
</head>
<body>

<%
    PersistenceManager pm = PMF.get().getPersistenceManager();
    String query = "select from " + Category.class.getName();
    List<Category> categories = (List<Category>) pm.newQuery(query).execute();
    
    String title = request.getParameter( "title" ); System.err.println(title);
    String name = request.getParameter( "name" ); //null when used on an upated event
    String id = request.getParameter( "id" ); //null when used on an upated event
    String newTitle = request.getParameter( "newTitle" );

    if (title == null || title.equals("") || title.equals("null")) {
    	title = "";
    }
    if (newTitle == null || newTitle.equals("") || newTitle.equals("null")) {
    	newTitle = title;
    }
    %>
    <%@ include file="getUserTimeZone.jsp" %>
    
    <ul class="navigation" id="catnav" style="width: 25em">
        <li><a href="/manProj.jsp?pageNumber=1&resultIndex=1&name=<%=name%>"> Manage Jobs </a></li>
        <%@ include file="LinkHome.jsp" %>
    </ul>

    <% 
    URL feedUrl = new URL("https://www.google.com/calendar/feeds/default/private/full");

    CalendarQuery myQuery = new CalendarQuery( feedUrl );
    myQuery.setFullTextQuery( title );
	myQuery.setStringCustomParameter("orderby", "starttime");
	myQuery.setStringCustomParameter("sortorder", "ascending");
    myQuery.setStringCustomParameter( "singleevents", "true" );
    CalendarEventFeed myResultsFeed = myService.query( myQuery, CalendarEventFeed.class );
    List<CalendarEventEntry> results = (List<CalendarEventEntry>)myResultsFeed.getEntries();
    
    if (myResultsFeed.getEntries().size() > 0) 
    {
        CalendarEventEntry entry = null;//(CalendarEventEntry) myResultsFeed.getEntries().get(0);
        for (CalendarEventEntry e : results) {
        	//System.err.println(title +" || " + e.getTitle().getPlainText());
        	//System.err.println(id + " || " + e.getId());
        	//System.err.println("---------------------------");
        	if (e.getId().equals( id )) { //Get the right event based on id
        		entry = e;
        	}
        }//System.err.println("AAAAAAAAAAAAAAAAAAAAAAA");//entry is null
        
        String recurring;
        if (entry.getOriginalEvent() == null) { //If the entry is recurring
        	recurring = "no";
        } else {
        	recurring = "yes";
        }
        
        if (recurring.equals("yes")) { //If the entry is recurring
        	
        	ArrayList<CalendarEventEntry> recurList = new ArrayList<CalendarEventEntry>();
			//Get the events in the series of recurring events
			for (CalendarEventEntry event : results) {
				String eventTitle = new String(event.getTitle().getPlainText());
				if (eventTitle.equals(title)) { //Check title to see if it's the correct event
					recurList.add(event);
				}
			}
			entry = recurList.get(0); //Select the first one (which holds recurring data)
        }
        
        title = entry.getTitle().getPlainText();
        String content = entry.getPlainTextContent();
        
        String datePattern = "MM/dd/yyyy"; 
        SimpleDateFormat dateFormat = new SimpleDateFormat(datePattern);   

        String hourPattern = "hh:mma"; 
        SimpleDateFormat timeFormat = new SimpleDateFormat(hourPattern);  

        When time = entry.getTimes().get(0); 
        DateTime start = time.getStartTime(); 
        DateTime end = time.getEndTime();

        //timeZone was set in getUserTimeZone
        TimeZone TZ =  TimeZone.getTimeZone( timeZone );

        int startOffset = TZ.getOffset( start.getValue() );
        int endOffset = TZ.getOffset( end.getValue() );

        startOffset = ( startOffset / 60 ) / 1000;
        endOffset = ( endOffset / 60 ) / 1000;
        
        start.setTzShift( startOffset );
        end.setTzShift( endOffset );
                   
        // Convert to milliseconds to get a date object, which can be formatted easier. 
        Date startDate = new Date(start.getValue() + 1000 * (start.getTzShift() * 60)); 
        Date endDate = new Date(end.getValue() + 1000 * (end.getTzShift() * 60));

        String startDay = dateFormat.format(startDate); 
        String startTime = timeFormat.format(startDate);

        String startHour = startTime.substring( 0, startTime.indexOf( ":" ) );
        startTime = startTime.substring( startTime.indexOf( ":" ) + 1 );
        String startMinute = startTime.substring( 0, 2 );
        String startMeridiem = startTime.substring( 2 );

        String endTime = timeFormat.format(endDate);

        String endHour = endTime.substring( 0, endTime.indexOf( ":" ) );
        endTime = endTime.substring( endTime.indexOf( ":" ) + 1 );
        String endMinute = endTime.substring( 0, 2 );
        String endMeridiem = endTime.substring( 2 );
        
        Scanner sc = new Scanner(content); 
        String description = "";
        String forWho = "";
        String who = "";
        String why = "";
        String category = "";
        String volList = "";
        String recur = "";

        String cur = sc.next().trim(); 
        if(cur.equals("<description>")) 
        {
            cur = sc.next();
            while(!cur.equals("</description>")) 
            {
                description += cur + " ";
                cur = sc.next(); 
            }
            if( description.length() > 1 )
                description = description.substring( 0, description.length() - 1 );
            if (sc.hasNext()) 
            {
                cur = sc.next();
            }
        }
        description = description.trim();
        if( cur.equals( "<for>" ) )
        {
            cur = sc.next();
            while( !cur.equals( "</for>" ) )
            {
                forWho += cur + " ";
                cur = sc.next(); 
            }
            if (sc.hasNext()) 
            {
                cur = sc.next();
            }
            if( forWho.length() > 1 )
                forWho = forWho.substring( 0, forWho.length() - 1 );
        }
        forWho = forWho.trim();
        if( cur.equals( "<who>" ) )
        {
            cur = sc.next();
            while( !cur.equals( "</who>" ) )
            {
                who += cur + " ";
                cur = sc.next();
            }
            if (sc.hasNext()) 
            {
                cur = sc.next();
            }
            if( who.length() > 1 )
                who = who.substring( 0, who.length() - 1 );
        }
        who = who.trim();
        if( cur.equals( "<why>" ) )
        {
            cur = sc.next();
            while( !cur.equals( "</why>" ) )
            {
                why += cur + " ";
                cur = sc.next();
            }
            if (sc.hasNext()) 
            {
                cur = sc.next();
            }
            if( why.length() > 1 )
                why = why.substring( 0, why.length() - 1 );
        }
        why = why.trim();
        if(cur.equals("<category>")) 
        {
            cur = sc.next();
            while(!cur.equals("</category>")) 
            {
                category += cur + " "; 
                cur = sc.next(); 
            }
            if (sc.hasNext()) 
            {
                cur = sc.next();
            }
        } 
        category = category.trim();
        if(cur.equals("<volunteers>")) 
        {
            cur = sc.next();
            while(!cur.equals("</volunteers>")) 
            {
                volList += cur + " "; 
                cur = sc.next(); 
            }
            if (sc.hasNext()) 
            {
                cur = sc.next();
            }
        }
        
        List<ExtendedProperty> propList = entry.getExtendedProperty();
		for (ExtendedProperty prop : propList) {
			if (prop.getName().equals("category")) {
				category = prop.getValue();
			}
			if (prop.getName().equals("recurrence")) {
				recur = prop.getValue();
			}
		}
%>
    <div class="content" id="addEvent">
    <form method="post" action="/updateevent">
	<h2> Edit Job: </h2>
                
        <%         
        if (request.getParameter("errortitle") != null) { //If title was blank, make it blank and print out an alert
        	newTitle = "";
            out.println( "<div id=\"error\">Please give the job a name.</div>" );
        }
        %>
        <div class="inputItem"> 
            Job Name: <input type="text" name="newTitle" class="textfield" value="<%=newTitle%>" />
        </div> 
        
        <div class="inputItem">
            Category: 
            <div class="dropdown"> 
                <select name="category">
                    <option selected>None</option>
                    <% for (Category c : categories) 
                    { %>
                    <option <% if( c.getName().equals( category ) ) { %>selected<% }%>>
                    <%= c.getName() %>
                    </option>
                    <% 
                    } 
                    %>
                </select>
            </div> 
        </div> 
        
        <div class="inputItem">
            Description: 
            <div class="dropdown"> 
                <input type="text" name="what" class="textfield" value="<%=description%>" />
            </div> 
        </div> 
        
        <%         
        if (request.getParameter("errordate") != null) {
        	startDay = "";
            out.println( "<div id=\"error\">Please enter a date.</div>" );
        }
        %>
        <div class="inputItem">
            When: 
            <div class="dropdown">
                <input id="date" type="text" name="when" size="10" class="textField" value="<%=startDay%>" />
            </div>
        </div>
        
        <%   
        boolean timeError = false;
        if (request.getParameter("errortime") != null) {
        	timeError = true;
            out.println( "<div id=\"error\">Start time must be less than or equal to end time.</div>" );
        }
        %>
        
        <div class="inputItem"> 
            From
            <div class="dropdown">
                <select name="fromHrs">
                    <% for (int i = 1; i < 13; i++) 
                       {
                            if( i == Integer.parseInt( startHour ) && !timeError )
                            {%>
                                <option value="<% if (i<10) %>0<% ; %><%= i %>" selected="selected"><%=i%></option>
                         <% }
                            else 
                            {%>
                                <option value="<% if (i<10) %>0<% ; %><%= i %>">
                                <%= i %></option>
                            <% }
                       } %>
                </select> :
                
                <select name="fromMins">
                    <% for (int i = 0; i < 60; i += 5) 
                    {
                        if( i == Integer.parseInt( startMinute ) && !timeError )
                        {%>
                            <option value="<% if (i<10) %>0<% ; %><%= i %>" selected="selected"><% if (i<10) %>0<% ; %><%= i %></option>
                     <% }
                        else 
                        {%>
                            <option value="<% if (i<10) %>0<% ; %><%= i %>">
                            <% if (i<10) %>0<% ; %><%= i %></option>
                      <%}
                    } %>
                </select>
                
                <select name="fromAMPM">
                    <option value="AM" <% if( startMeridiem.equals( "AM" ) && !timeError ) %> selected="selected" <% ; %> >AM</option> 
                    <option value="PM" <% if( startMeridiem.equals( "PM" ) && !timeError ) %> selected="selected" <% ; %> >PM</option>
                </select>   
            </div> 
        </div>
        
        <div class="inputItem">
            Until
            <div class="dropdown"> 
                <select name="tillHrs">
                <% for (int i = 1; i < 13; i++) 
                {
                     if( i == Integer.parseInt( endHour ) && !timeError )
                     {%>
                         <option value="<% if (i<10) %>0<% ; %><%= i %>" selected="selected"><%=i%></option>
                  <% }
                     else 
                     {%>
                         <option value="<% if (i<10) %>0<% ; %><%= i %>">
                         <%= i %></option>
                     <% }
                } %>
                </select> :
                <select name="tillMins">
                <% for (int i = 0; i < 60; i += 5) 
                {
                    if( i == Integer.parseInt( endMinute ) && !timeError )
                    {%>
                        <option value="<% if (i<10) %>0<% ; %><%= i %>" selected="selected"><% if (i<10) %>0<% ; %><%= i %></option>
                 <% }
                    else 
                    {%>
                        <option value="<% if (i<10) %>0<% ; %><%= i %>">
                        <% if (i<10) %>0<% ; %><%= i %></option>
                  <%}
                } %>
                </select>
                
                <select name="toAMPM">
                <option value="AM" <% if( endMeridiem.equals( "AM" ) && !timeError ) %> selected="selected" <% ; %> >AM</option> 
                <option value="PM" <% if( endMeridiem.equals( "PM" ) && !timeError ) %> selected="selected" <% ; %> >PM</option>
                </select>
            </div>
        </div>
        
        
        <div class="inputItem">
            For whom:
            <div class="dropdown"> 
                <input type="text" name="for" class="textfield" value="<%=forWho%>" />
            </div> 
        </div> 
        
        <div class="inputItem">
            Who should do it:
            <div class="dropdown">
                <input type="text" name="who" class="textfield" value="<%=who%>" />
            </div> 
        </div>
        
        <div class="inputItem">
            Why: 
            <div class="dropdown"> 
                <input type="text" name="why" class="textfield" value="<%=why%>" />
            </div> 
        </div>
        
        <div class="inputItem">
            Recurring: 
            <div class="dropdown"> 
                <select name="recur" class="dropdown">
                    <option value="none" <% if (recur.equals("none")) %>selected="selected"<% ; %>>None</option>
		            <option value="week"<% if (recur.equals("week")) %>selected="selected"<% ; %>>Weekly</option>
		            <option value="biweek"<% if (recur.equals("biweek")) %>selected="selected"<% ; %>>Bi-weekly</option>
		            <option value="month"<% if (recur.equals("month")) %>selected="selected"<% ; %>>Monthly</option>
                </select>
            </div>
        </div> 

            <input name="name" type="hidden" value="<%=name%>">
            <input name="title" type="hidden" value="<%=title%>">
            <input name="recurring" type="hidden" value="<%=recurring%>">
       
        <div class="submit">
            <input type="submit" class="submitButton" value="Submit"/>
        </div>
    </form>
    </div>
<%
    }
%>

</content>

</body>
</html>
