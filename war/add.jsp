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
        <select name="whenDay">
            <option value="01">01</option>
            <option value="02">02</option>
            <option value="03">03</option>
            <option value="04">04</option>
            <option value="05">05</option>
            <option value="06">06</option>
            <option value="07">07</option>
            <option value="08">08</option>
            <option value="09">09</option>
            <option value="10">10</option>
            <option value="11">11</option>
            <option value="12">12</option>
            <option value="13">13</option>
            <option value="14">14</option>
            <option value="15">15</option>
            <option value="16">16</option>
            <option value="17">17</option>
            <option value="18">18</option>
            <option value="19">19</option>
            <option value="20">20</option>
            <option value="21">21</option>
            <option value="22">22</option>
            <option value="23">23</option>
            <option value="24">24</option>
            <option value="25">25</option>
            <option value="26">26</option>
            <option value="27">27</option>
            <option value="28">28</option>
            <option value="29">29</option>
            <option value="30">30</option>
            <option value="31">31</option>
        </select> 
        <select name="whenMonth">
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
        <select name="whenYear">
            <option value="2010">2010</option>
        </select>
        <br /><br /> from 
        <select name="whenTimeFrom">
            <option value="01:00">01:00</option>
        </select>
        <select name="whenAmpm">
            <option value="AM">AM</option>
            <option value="PM">PM</option>
        </select>
        <br /><br /> until 
        <select name="whenTimeTill">
            <option value="01:00">01:00</option>
        </select>
        <select name="whenAmpm">
            <option value="AM">AM</option>
            <option value="PM">PM</option>
        </select>
        </div><br /><br /><br /><br /><br /><br />
        For whom: <input type="text" name="for" class="textfield" /><br /><br />
        Who should do it: <input type="text" name="who" class="textfield" /><br /><br />
        Why: <input type="text" name="why" class="textfield" /><br /><br />
        Recurring: <select name="task" class="dropdown"> <br /><br />
            <option value="notrecur" selected="selected">No</option>
            <option value="recur">Yes</option>
        </select>
        <div class="submit">
        <input type="submit" class="submitButton" value="Submit"/>
        </div>
    </form>
</div>
</body>
</html>