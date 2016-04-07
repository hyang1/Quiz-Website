<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="user.User, dbconnection.UserManager, user.HistoryItem, java.util.*" %>

<!DOCTYPE html>

<%

Cookie usernameCookie = null;
Cookie passwordCookie = null;
Cookie[] cookies = request.getCookies(); 
if (cookies != null) {
	for (Cookie cookie : cookies)  {
		if (cookie.getName().equals("username")) usernameCookie = cookie;
		if (cookie.getName().equals("encryptedPassword")) passwordCookie = cookie;
	}
}
if (usernameCookie != null && passwordCookie != null) {	
	UserManager accounts = (UserManager) request.getServletContext().getAttribute("UserManager");
	User currentUser = accounts.getUser(usernameCookie.getValue(), passwordCookie.getValue());
	if (currentUser != null) {
		request.getSession().setAttribute("currentUser", currentUser);

		usernameCookie.setMaxAge(60 * 60 * 24);
		passwordCookie.setMaxAge(60 * 60 * 24);
		response.addCookie(usernameCookie);
		response.addCookie(passwordCookie);
	}
}

%>

<html>
<style>
body {
    padding-top: 70px; /* Required padding for .navbar-fixed-top. Remove if using .navbar-static-top. Change if height of navigation changes. */
}

footer {
    margin: 50px 0;
}

.stats-cell {
	text-align: center;
}

.stats-info {
	font-size: 55pt;
	font-weight: bold;
}

.stats-description {
	font-size: 24pt;
}



</style>


<head>
    <meta charset="utf-8">
   	<meta http-equiv="X-UA-Compatible" content="IE=edge">
   	<meta name="viewport" content="width=device-width, initial-scale=1">
   	<!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

	<title>Statistics</title>
	
    <link href="bootstrap/css/bootstrap.min.css" rel="stylesheet">
</head>


<body>

<!-- Navigation -->
<nav class="navbar navbar-inverse navbar-fixed-top" role="navigation">
    <div class="container">
        <!-- Brand and toggle get grouped for better mobile display -->
        <div class="navbar-header">
            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <ul class="nav navbar-nav navbar-left">
            	<li>
            		<a class="navbar-brand" href="user_homepage.jsp">
            			<span class="glyphicon glyphicon-home" aria-hidden="true"></span> Quizard
            		</a>
            	</li>
            	<li>
            		<a href="user_profile.jsp"><span class="glyphicon glyphicon-user" aria-hidden="true"></span> 
            			<%= ((User)request.getSession().getAttribute("currentUser")).getUsername() %></a>
            	</li>
            </ul>
        </div>
        <!-- Collect the nav links, forms, and other content for toggling -->
        <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
            <ul class="nav navbar-nav navbar-right">
                <li>
                    <a href="search.jsp"><span class="glyphicon glyphicon-search" aria-hidden="true"></span> Search</a>
                </li>
                <li>
                    <a href="inbox.jsp"><span class="glyphicon glyphicon-envelope" aria-hidden="true"></span> Messages</a>
                </li>
                <%
                if (((User) request.getSession().getAttribute("currentUser")).getUserStatus() == 1) {
                	out.print("<li>");
                	out.print("<a href=\"statistics.jsp\"><span class=\"glyphicon glyphicon-stats\" aria-hidden=\"true\"></span> Site Statistics</a>");
                	out.print("</li>");
                }
                %>
                <li>
                	<form id="logout-form" action="LogoutServlet" method="post">
						<input type="hidden" name="logout">
					</form>
					<a href="javascript:;" onclick="document.getElementById('logout-form').submit();">
					    <span class="glyphicon glyphicon-off" aria-hidden="true"></span> Logout</a>
					
				</li>
            </ul>
        </div>
        <!-- /.navbar-collapse -->
    </div>
    <!-- /.container -->
</nav>


	<%
	UserManager accounts = (UserManager) request.getServletContext().getAttribute("UserManager");
	User currentUser = ((User) request.getSession().getAttribute("currentUser"));
	ArrayList<Integer> results = accounts.seeStats(currentUser);
	if (results != null) {
				
		out.print("<h1 align=\"center\"><span class=\"glyphicon glyphicon-stats\" aria-hidden=\"true\">" + 
					"</span> Site Statistics</h1>");

		out.print("<hr>");
		
		out.print("<div class=\"container\">");
		
		out.print("<div class=\"row\">"); 
		
		out.print("<div class=\"col-md-4\"><div class=\"well\">");
		out.print("<div class=\"stats-cell\"><div class=\"stats-info\">");
		out.print(results.get(0) + "</div><div class=\"stats-description\">User accounts</div></div>");
		out.print("</div></div>");
	
		out.print("<div class=\"col-md-4\"><div class=\"well\">");
		out.print("<div class=\"stats-cell\"><div class=\"stats-info\">");
		out.print(results.get(1) + "</div><div class=\"stats-description\">Friendships</div></div>");
		out.print("</div></div>");
	
	
		out.print("<div class=\"col-md-4\"><div class=\"well\">");
		out.print("<div class=\"stats-cell\"><div class=\"stats-info\">");
		out.print(results.get(2) + "</div><div class=\"stats-description\">Messages sent</div></div>");
		out.print("</div></div>");
		
		out.print("</div>");
			
		out.print("<div class=\"row\">"); 
		out.print("<div class=\"col-md-4\"><div class=\"well\">");
		out.print("<div class=\"stats-cell\"><div class=\"stats-info\">");
		out.print(results.get(3) + "</div><div class=\"stats-description\">Quizzes made</div></div>");
		out.print("</div></div>");
	
		out.print("<div class=\"col-md-4\"><div class=\"well\">");
		out.print("<div class=\"stats-cell\"><div class=\"stats-info\">");
		out.print(results.get(4) + "</div><div class=\"stats-description\">Questions created</div></div>");
		out.print("</div></div>");
	
		out.print("<div class=\"col-md-4\"><div class=\"well\">");
		out.print("<div class=\"stats-cell\"><div class=\"stats-info\">");
		out.print(results.get(5) + "</div><div class=\"stats-description\">Quizzes taken</div></div>");
		out.print("</div></div>");
		out.print("</div>");
		out.print("</div>");
		
	} else {
		out.print("<h1 align=\"center\">Sorry. You are not authorized to see this page</h1>");
		out.print("<hr>");
	}
	
	%>
	
	<script
		src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
	<script
		src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>


	<script type="text/javascript">
		$(document).ready(function() {
			var searchType = $(".search-type");
			$(searchType).change(function() {
				$(".quiz-search-field").toggle();
				$(".quiz-search-query").show();
				$("#search-query").prop("required", true);
				$(".quiz-category-option").hide();
			});
			$(".quiz-search-field").change(function() {
				console.log($(".search-field-choice option:selected").text());
				if ($(".search-field-choice option:selected").text() === "Category") {
					$(".quiz-search-query").hide();
					$(".quiz-category-option").show();
					$('#search-query').removeAttr("required");
				} else {
					$(".quiz-search-query").show();
					$("#search-query").prop("required", true);
					$(".quiz-category-option").hide();
				}
			});
		});
	</script>

</body>
</html>