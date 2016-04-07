<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page
	import="java.util.*, dbconnection.UserManager, user.User, user.HistoryItem, user.Message, quiz.Quiz"%>
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
<!DOCTYPE html>

<html lang="en">

<style>
body {
	padding-top: 70px;
	/* Required padding for .navbar-fixed-top. Remove if using .navbar-static-top. Change if height of navigation changes. */
}

footer {
	margin: 50px 0;
}

.quiz-search-field {
	display: none;
}

.quiz-category-option {
	display: none;
}

.submit-search-button {
	text-align: center;
}

.entry {
	display: block;
	text-align: center;
	font-size: 18pt;
}

.names {
	font-size: 24pt;
	text-overflow: ellipsis;
	white-space: nowrap; 
    overflow: hidden;
}

.well {
	margin-left: 20px;
	margin-right: 20px;
}

.container.search-results {
	padding-left: 150px;
}
</style>

<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

<title>Search</title>

<link href="bootstrap/css/bootstrap.min.css" rel="stylesheet">

<%
	// Get the necessary variables to use in this JSP
	UserManager accounts = (UserManager) request.getServletContext().getAttribute("UserManager");
	User user = ((User) request.getSession().getAttribute("currentUser"));
%>

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


	<h1 align="center">
		<span class="glyphicon glyphicon-search" aria-hidden="true"></span>
		Search
	</h1>

	<hr>

	<div class="container form-horizontal">
		<form id="search-form" action="SearchServlet" method="post">
			<div class="form-group">
				<label class="control-label col-md-5" for="search-category">Query
					Type:</label>
				<div class="col-md-3">
					<select id="category-dropdown" name="search-category"
						class="form-control search-type">
						<option>Users</option>
						<option>Quizzes</option>
					</select>
				</div>
			</div>
			<div class="form-group quiz-search-field">
				<label class="control-label col-md-5" for="search-field">Field:</label>
				<div class="col-md-3">
					<select id="field-dropdown" name="search-field" class="form-control search-field-choice">
						<option>Name</option>
						<option>Category</option>
						<option>Tag</option>
					</select>
				</div>
			</div>
			<div class="form-group quiz-category-option">
				<label class="control-label col-md-5" for="category-field">Category:</label>
				<div class="col-md-3">
					<select id="field-dropdown" name="category-field" class="form-control category-field-choice">
						<option value="0">Other</option>
						<option value="1">Literature</option>
						<option value="2">English</option>
						<option value="3">Science</option>
						<option value="4">Geography</option>
						<option value="5">History</option>
					</select>
				</div>
			</div>
			<div class="form-group quiz-search-query">
				<label for="search-query" class="col-md-3 control-label">Query:</label>
				<div class="col-md-7">
					<input type="text" name="search-query" id="search-query"
						class="form-control" required>
				</div>
			</div>
			<div class="form-group submit-search-button">
				<input type="submit" class="btn btn-default" name="search-submit"
					value="Submit">
			</div>
		</form>

	</div>
	<%
		if (request.getAttribute("SearchResultsUsers") != null) {
			ArrayList<User> results = (ArrayList<User>) request.getAttribute("SearchResultsUsers");
			String output = "";
			int counter = 0;
			if (results.size() > 0) {
				out.print("<div class=\"container search-results\">");
				for (User personFound : results) {
					output += "<div class=\"entry well col-md-3\">";
					output += "<div class=\"names\">";
					output += "<span class=\"glyphicon glyphicon-user\" aria-hidden=\"true\"></span><br>";
					output += "<a class=\"names\" href=\"user_profile.jsp?username=" + personFound.getUsername() + "\">";
					output += personFound.getUsername() + "</a></div></div>";
				}
			} else {
				out.print("<div class=\"container\">");
				output = "<div class=\"entry well\"><p>No results found. Please try again.</p></div>";
			}
			out.print(output);
			out.print("</div>");
		} else if (request.getAttribute("SearchResultsQuizIds") != null && 
				request.getAttribute("SearchResultsQuizNames") != null) {
			ArrayList<Integer> quizIds = (ArrayList<Integer>) request.getAttribute("SearchResultsQuizIds");
			ArrayList<String> quizNames = (ArrayList<String>) request.getAttribute("SearchResultsQuizNames");
			String output = "";
			if (quizIds.size() > 0 && quizNames.size() > 0) {
				out.print("<div class=\"container search-results\">");
				for (int i = 0; i < quizIds.size(); i++) {
					output += "<div class=\"entry well col-md-3\">";
					output += "<div class=\"names\">";
					output += "<span class=\"glyphicon glyphicon-apple\" aria-hidden=\"true\"></span><br>";
					output += "<a href=\"quiz_summary.jsp?quiz_id=" + quizIds.get(i) + "\">";
					output += quizNames.get(i) + "</a></div></div>";
				}
			} else {
				out.print("<div class=\"container\">");
				output = "<div class=\"entry well\"><p>No results found. Please try again.</p></div>";
			}
			out.print(output);
			out.print("</div>");
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