<html>

<head> 
	<link rel="stylesheet" href="stylesheets/layout.css" type="text/css"> 
</head> 

<body>

<% 
String name = request.getParameter("name");
%>
  
  <ul class="navigation"> 
    <li><a href="/volunteer.jsp?pageNumber=1&resultIndex=1&name=<%=name%>"> Jobs </a></li>
    <li><a href="/underConstruction.jsp"> My Jobs </a></li>
    <li><a href="/calendar.jsp&name=<%=name%>"> My Calendar </a></li>
    <%@ include file="LinkHome.jsp" %>
  </ul>
  
	<div class="content" id="calendar"> 
		<iframe src="http://www.google.com/calendar/embed?height=500&amp;wkst=1&amp;bgcolor=%23FFFFFF&amp;src=rockcreekvolunteercoordinator%40gmail.com&amp;color=%23691426&amp;ctz=America%2FNew_York" style=" border-width:0 " width="700" height="500" frameborder="0" scrolling="no"></iframe>
		</iframe>
	</div> 	
</body> 

</html>