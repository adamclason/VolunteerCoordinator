<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<META http-equiv="Content-Style-Type" content="text/css">

<link rel="stylesheet" type="text/css" href="stylesheets/layout.css" />
<link rel="stylesheet" type="text/css" href="stylesheets/colors.css" />
<link type="text/css" href="stylesheets/jquery-ui-1.8.6.custom.css" rel="Stylesheet" />

<script src="http://code.jquery.com/jquery-1.4.3.min.js"> </script>
<script src="javascript/jquery-ui-1.8.6.custom.min.js"> </script>
<script src="javascript/addEvent.js"> </script>

<title>Add Category</title>
</head>

<body>

  <ul class="navigation" id="catnav"> 
    <li><a href="/manProj.jsp?pageNumber=1&resultIndex=1"> Manage Jobs </a></li>
    <li><a href="/newCat.jsp"> New Category </a></li>
    <li><a href="/catMaint.jsp"> Category Maintennance </a></li>
    <%@ include file="LinkHome.jsp" %>
  </ul>

<div class="category" id="page">
    <form method="post" action="/makecategory">
    	<div class="inputItem"> 
        Category Title: <input type="text" name="title" class="textfield" size="30" maxlength="30" />
        </div> 
       
        <div class="submit">
        	<input type="submit" class="submitButton" value="Submit"/>
        </div>
    </form>
</div>
</body>
</html>