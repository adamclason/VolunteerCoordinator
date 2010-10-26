<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" type="text/css" href="stylesheets/layout.css">
<link rel="stylesheet" type="text/css" href="stylesheets/colors.css">

<title>Add Job</title>
</head>

<body>
<div class="inputs"> 
    <form method="post" action="/makeevent">
        Job Name: <input type="text" name="title" class="textfield" /><br /><br />
        What: <input type="text" name="what" class="textfield" /><br /><br />
        When: <div class="dropdown">
        <select name="day">
        <% for (int i = 1; i <= 31; i++) { %>
            <option value="<% if (i<10) %>0<% ; %><%= i %>"><% if (i<10) %>0<% ; %><%= i %></option>
        <% } %>
        </select> 
        <select name="month">
            <option value="01">January</option>
            <option value="02">February</option>
            <option value="03">March</option>
            <option value="04">April</option>
            <option value="05">May</option>
            <option value="06">June</option>
            <option value="07">July</option>
            <option value="08">August</option>
            <option value="09">September</option>
            <option value="10">October</option>
            <option value="11">November</option>
            <option value="12">December</option>
        </select>
        <select name="year">
            <option value="2010">2010</option>
        </select>
        <br /><br /> from 
        <select name="fromHrs">
            <% for (int i = 0; i < 24; i++) {%>
                    <option value="<% if (i<10) %>0<% ; %><%= i %>">
                    <% if (i<10) %>0<% ; %><%= i %></option>
            <% } %>
        </select> : 
        <select name="fromMins">
            <% for (int i = 0; i < 60; i += 5) {%>
                    <option value="<% if (i<10) %>0<% ; %><%= i %>">
                    <% if (i<10) %>0<% ; %><%= i %></option>
            <% } %>
        </select>
        <br /><br /> until 
        <select name="tillHrs">
            <% for (int i = 0; i < 24; i++) {%>
                    <option value="<% if (i<10) %>0<% ; %><%= i %>">
                    <% if (i<10) %>0<% ; %><%= i %></option>
            <% } %>
        </select> : 
        <select name="tillMins">
            <% for (int i = 0; i < 60; i += 5) {%>
                    <option value="<% if (i<10) %>0<% ; %><%= i %>">
                    <% if (i<10) %>0<% ; %><%= i %></option>
            <% } %>
        </select>
        </div><br /><br /><br /><br /><br /><br />
        For whom: <input type="text" name="for" class="textfield" /><br /><br />
        Who should do it: <input type="text" name="who" class="textfield" /><br /><br />
        Why: <input type="text" name="why" class="textfield" /><br /><br />
        Recurring: <select name="recur" class="dropdown">
            <option value="none" selected="selected">None</option>
            <option value="week">Weekly</option>
            <option value="biweek">Bi-weekly</option>
            <option value="month">Monthly</option>
        </select><br /><br />
        <div class="submit">
        <input type="submit" class="submitButton" value="Submit"/>
        </div>
    </form>
</div>
</body>
</html>