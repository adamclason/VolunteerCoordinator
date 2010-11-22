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
<script src="javascript/volunteer.js"> </script>
<script src="javascript/addEvent.js"> </script>

<title>Edit Job</title>
</head>
<body>

<ul class="navigation">
<%@ include file="LinkHome.jsp" %>
</ul>

<%
    PersistenceManager pm = PMF.get().getPersistenceManager();
    String query = "select from " + Category.class.getName();
    List<Category> categories = (List<Category>) pm.newQuery(query).execute();
    
    String title = request.getParameter( "title" );
    String name = request.getParameter( "name" );
    
    URL feedUrl = new URL("https://www.google.com/calendar/feeds/default/private/full");

    Query myQuery = new Query( feedUrl );
    myQuery.setFullTextQuery( title );
    CalendarEventFeed myResultsFeed = myService.query( myQuery, CalendarEventFeed.class );
    
    if (myResultsFeed.getEntries().size() > 0) 
    {
      CalendarEventEntry firstMatchEntry = (CalendarEventEntry) myResultsFeed.getEntries().get(0); 
      title = firstMatchEntry.getTitle().getPlainText();
      String content = firstMatchEntry.getPlainTextContent();
      
      String datePattern = "MM-dd-yyyy"; 
      SimpleDateFormat dateFormat = new SimpleDateFormat(datePattern);   
     
      String hourPattern = "hh:mma"; 
      SimpleDateFormat timeFormat = new SimpleDateFormat(hourPattern);  
      
      When time = firstMatchEntry.getTimes().get(0); 
      DateTime start = time.getStartTime(); 
      DateTime end = time.getEndTime();
      
      start.setTzShift(-240); 
      end.setTzShift(-240); 
      
      // Concert to milliseconds to get a date object, which can be formatted easier. 
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
      
      String cur = sc.next().trim(); 
      if(cur.equals("<description>")) 
      {
         cur = sc.next();
         while(!cur.equals("</description>")) 
         {
            description += cur + " ";
            cur = sc.next(); 
         }
         description = description.substring( 0, description.length() - 1 );
         if (sc.hasNext()) 
         {
             cur = sc.next();
         }
      }
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
      }
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
      }
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
      }
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
    
%>
    <div class="content" id="addEvent">
    <form method="post" action="/updateevent">
        <div class="inputItem"> 
        Job Name: <input type="text" name="newTitle" class="textfield" value="<%=title%>" />
        </div> 
        
        <div class="inputItem">
            Category: 
            <div class="dropdown"> 
                <select name="<%=category%>" >
                    <% for (Category c : categories) { %>
                    <option><%= c.getName() %></option>
                    <% } %>
                </select>
            </div> 
        </div> 
        
        <div class="inputItem">
            Description: 
            <div class="dropdown"> 
                <input type="text" name="what" class="textfield" value="<%=description%>" />
            </div> 
        </div> 
        
        <div class="inputItem">
            When: 
            <div class="dropdown">
                <input id="date" type="text" name="when" size="10" class="textField hasDatepicker" value="<%=startDay%>" />
            </div>
        </div>
        
        <div class="inputItem"> 
            From
            <div class="dropdown">
                <select name="fromHrs">
                    <% for (int i = 1; i < 13; i++) 
                       {
                            if( i == Integer.parseInt( startHour ) )
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
                        if( i == Integer.parseInt( startMinute ) )
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
                    <option value="AM" <% if( startMeridiem.equals( "AM" ) ) %> selected="selected" <% ; %> >AM</option> 
                    <option value="PM" <% if( startMeridiem.equals( "PM" ) ) %> selected="selected" <% ; %> >PM</option>
                </select>   
            </div> 
        </div>
        
        <div class="inputItem">
            Until
            <div class="dropdown"> 
                <select name="tillHrs">
                <% for (int i = 1; i < 13; i++) 
                {
                     if( i == Integer.parseInt( endHour ) )
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
                    if( i == Integer.parseInt( endMinute ) )
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
                <option value="AM" <% if( endMeridiem.equals( "AM" ) ) %> selected="selected" <% ; %> >AM</option> 
                <option value="PM" <% if( endMeridiem.equals( "PM" ) ) %> selected="selected" <% ; %> >PM</option>
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
                    <option value="none" selected="selected">None</option>
                    <option value="week">Weekly</option>
                    <option value="biweek">Bi-weekly</option>
                    <option value="month">Monthly</option>
                </select>
            </div>
        </div> 
        <div class="inputItem" visibility="hidden">
            <input name="name" type="hidden" value="<%=name%>">
        </div>
        
        <div class="inputItem" visibility="hidden">
            <input name="title" type="hidden" value="<%=title%>">
        </div>
       
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
