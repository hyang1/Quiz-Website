<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page
	import="java.util.*, dbconnection.*,user.User, user.HistoryItem, user.Message"%>
<%
	Cookie usernameCookie = null;
	Cookie passwordCookie = null;
	Cookie[] cookies = request.getCookies();
	if (cookies != null) {
		for (Cookie cookie : cookies) {
			if (cookie.getName().equals("username"))
				usernameCookie = cookie;
			if (cookie.getName().equals("encryptedPassword"))
				passwordCookie = cookie;
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


<%
	DBConnection con = (DBConnection) request.getServletContext().getAttribute("DBConnection");
	QuizManager quizzes = (QuizManager) request.getServletContext().getAttribute("QuizManager");
	User currentUser = (User) session.getAttribute("currentUser");
	String username = currentUser.getUsername();

	ArrayList<Integer> popular_quizzes = quizzes.getPopularQuizzes();
	ArrayList<Integer> new_quizzes = quizzes.getRecentQuizzes();
	ArrayList<String> popular_quiz_names = quizzes.getQuizNames(popular_quizzes);
	ArrayList<String> new_quiz_names = quizzes.getQuizNames(new_quizzes);
%>

<html lang="en">

<style>
body {
	padding-top: 70px;
	/* Required padding for .navbar-fixed-top. Remove if using .navbar-static-top. Change if height of navigation changes. */
}

footer {
	margin: 50px 0;
}

/* div.container { This was creating inconsistency with the banner for hompage vs the different pages
	padding-left:25px;
	padding-right:25px
} */
.recent-scores {
	text-align: center;
}

.recent-quizzes {
	text-align: center;
}
</style>

<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

<title>Quizard</title>

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
				<button type="button" class="navbar-toggle" data-toggle="collapse"
					data-target="#bs-example-navbar-collapse-1">
					<span class="sr-only">Toggle navigation</span> <span
						class="icon-bar"></span> <span class="icon-bar"></span> <span
						class="icon-bar"></span>
				</button>
				<ul class="nav navbar-nav navbar-left">
					<li><a class="navbar-brand" href="user_homepage.jsp"> <span
							class="glyphicon glyphicon-home" aria-hidden="true"></span>
							Quizard
					</a></li>
					<li><a href="user_profile.jsp"><span
							class="glyphicon glyphicon-user" aria-hidden="true"></span> <%=((User) request.getSession().getAttribute("currentUser")).getUsername()%></a>
					</li>
				</ul>
			</div>
			<!-- Collect the nav links, forms, and other content for toggling -->
			<div class="collapse navbar-collapse"
				id="bs-example-navbar-collapse-1">
				<ul class="nav navbar-nav navbar-right">
					<li><a href="search.jsp"><span
							class="glyphicon glyphicon-search" aria-hidden="true"></span>
							Search</a></li>
					<li><a href="inbox.jsp"><span
							class="glyphicon glyphicon-envelope" aria-hidden="true"></span>
							Messages</a></li>
					<%
						if (((User) request.getSession().getAttribute("currentUser")).getUserStatus() == 1) {
							out.print("<li>");
							out.print(
									"<a href=\"statistics.jsp\"><span class=\"glyphicon glyphicon-stats\" aria-hidden=\"true\"></span> Site Statistics</a>");
							out.print("</li>");
						}
					%>
					<li>
						<form id="logout-form" action="LogoutServlet" method="post">
							<input type="hidden" name="logout">
						</form> <a href="javascript:;"
						onclick="document.getElementById('logout-form').submit();"> <span
							class="glyphicon glyphicon-off" aria-hidden="true"></span> Logout
					</a>

					</li>
				</ul>
			</div>
			<!-- /.navbar-collapse -->
		</div>
		<!-- /.container -->
	</nav>


	<!-- Page Content -->
	<div class="container">
		<div class="row">

			<!-- Your activities -->
			<div class="col-md-3">

				<h4>Your Recent Scores</h4>
				<div class="well recent-scores">
					<%
						ArrayList<HistoryItem> recentQuizzesTaken = user.getRecentQuizzesTaken(10);
						ArrayList<Integer> idstaken = new ArrayList<Integer>();
						for (int i = 0; i < recentQuizzesTaken.size(); i++) {
							idstaken.add(Integer.parseInt(recentQuizzesTaken.get(i).getItemId()));
						}
						ArrayList<String> recentTakenQuizNames = quizzes.getQuizNames(idstaken);
						for (int i = 0; i < recentQuizzesTaken.size(); i++) {
							out.print(
								"<div class=\"row\">" + 
									"<div class=\"col-md-10\">" + 
										"<p style=\"text-align:left\"><a href=\"quiz_summary.jsp?quiz_id=" + recentQuizzesTaken.get(i).getItemId() + "\">"
											+ recentTakenQuizNames.get(i) + "</a>" +
									"</div>" +
									"<div class=\"col-md-2\">" + recentQuizzesTaken.get(i).getScore() + "</div>" + 
								"</div>"
							);
						}
					%>
				</div>

				<h4>Your Recent Quizzes</h4>
				<div class="well recent-quizzes">
					<p align="center">
						<a href="create_quiz.jsp"><span
							class="glyphicon glyphicon-pencil" aria-hidden="true"></span>
							Create a new quiz</a>
					</p>
					<%
						ArrayList<HistoryItem> recentQuizzesMade = user.getRecentQuizzesMade(-1);
		                ArrayList<Integer> quizIds = new ArrayList<Integer>();
		                for (int i = 0; i < recentQuizzesMade.size(); i++) {
		                	HistoryItem item = recentQuizzesMade.get(i);
							quizIds.add(Integer.parseInt(item.getItemId()));
		                }
		                ArrayList<String> quizNames = quizzes.getQuizNames(quizIds);
		                for (int i = 0; i < recentQuizzesMade.size(); i++) {
		                	Date time = new Date(recentQuizzesMade.get(i).getStartTime());
		                	out.print("<div class=\"row\">" + 
										"<div class=\"col-md-6\">" + 
										"<p style=\"text-align:left;text-overflow: ellipsis;white-space: nowrap; " + 
										"overflow: hidden;\"><a href=\"quiz_summary.jsp?quiz_id=" + quizIds.get(i) + "\">"
										+ quizNames.get(i) + "</a>" +
										"</div>" +
									"<div style=\"font-size:10px\" class=\"col-md-6\">Created on " + time + "</div>" + 
									"</div>");
		      
		                }
					%>
				</div>

			</div>


			<!-- Feed -->
			<div class="col-md-6">

				<h1 align="center" style="font-size: 350%">
					Welcome
					<%=((User) request.getSession().getAttribute("currentUser")).getUsername()%>!
				</h1>

				<h2>Announcements</h2>
				<div class="well">
					<%
						ArrayList<Message> announcements = accounts.getAnnouncements(10);
						for (int i = 0; i < announcements.size(); i++) {
							Date d = new Date(announcements.get(i).getTime());
							out.print("<p>" + d + "\n<a href=\"user_profile.jsp?username=" + announcements.get(i).getSender() + 
									"\">" + announcements.get(i).getSender() + "</a>: " + announcements.get(i).getMessage()
									+ "</a></p>");
						}
					%>

				</div>

				<h2>Recent Activity</h2>
				<div class="well">
					<!-- TODO: add recent activity to backend -->

					<%
						ArrayList<HistoryItem> activities = accounts.getRecentFriendsHistory(user, 10);
						for (int i = 0; i < activities.size(); i++) {
							if (activities.get(i).getType() == 2)
								out.print("<p> Your friend " + "<a href=\"user_profile.jsp?username=" + activities.get(i).getUser()
										+ "\">" + activities.get(i).getUser() + "</a>" + " just earned the "
										+ activities.get(i).getItemId() + " achievement." + "</p>");
							else if (activities.get(i).getType() == 1)
								out.print("<p> Your friend " + "<a href=\"user_profile.jsp?username=" + activities.get(i).getUser()
										+ "\">" + activities.get(i).getUser() + "</a>" + " just scored "
										+ activities.get(i).getScore() + " on this quiz: " + "<a href=\"quiz_summary.jsp?quiz_id="
										+ activities.get(i).getItemId() + "\">"
										+ quizzes.getQuizNameById(activities.get(i).getItemId()) + "</a></p>");
							else if (activities.get(i).getType() == 0)
								out.print("<p> Your friend " + "<a href=\"user_profile.jsp?username=" + activities.get(i).getUser()
										+ "\">" + activities.get(i).getUser() + "</a> just created this quiz: "
										+ "<a href=\"quiz_summary.jsp?quiz_id=" + activities.get(i).getItemId() + "\">"
										+ quizzes.getQuizNameById(activities.get(i).getItemId()) + "</a>, try it out!" + "</p>");
						}
					%>

				</div>


			</div>

			<!-- Blog Sidebar Widgets Column -->
			<div class="col-md-3">

				<h4>Your achievements</h4>
				<div class="well">
					<!-- TODO: generate achievements -->
					<%
						username = request.getParameter("username");
						if (username == null) {
							username = ((User) request.getSession().getAttribute("currentUser")).getUsername();
						}
						User userToDisplay = accounts.getUserPublicInfo(username);
						String[] achievementsArray = userToDisplay.getAchievements().split(",");
						ArrayList<String> achievements = new ArrayList<String>(Arrays.asList(achievementsArray));
						Collections.sort(achievements);
			            if (!userToDisplay.getAchievements().equals("")) {
		                	for (String achievement : achievements) { 
			                	out.print("<div><span class=\"glyphicon glyphicon-star\" aria-hidden=\"true\"></span> " + achievement + "</div>");
			                }
			            } else {
			            	out.print("<div><span class=\"glyphicon glyphicon-star\" aria-hidden=\"true\"></span> Achievements? You don't have any Achievements!</div>");
			            }
					%>
				</div>

				<h4>Popular Quizzes</h4>
				<div class="well">
					<!-- TODO: generate achievements -->
					<%
						for (int i = 0; i < popular_quizzes.size(); i++) {
							out.print("<p><a href=\"quiz_summary.jsp?quiz_id=" + popular_quizzes.get(i) + "\">"
									+ popular_quiz_names.get(i) + "</a></p>");
						}
					%>
				</div>

				<h4>New Quizzes</h4>
				<div class="well">
					<!-- TODO: generate achievements -->
					<%
						for (int i = 0; i < new_quizzes.size() && i < 10; i++) {
							out.print("<p><a href=\"quiz_summary.jsp?quiz_id=" + new_quizzes.get(i) + "\">" + new_quiz_names.get(i)
									+ "</a></p>");
						}
					%>
				</div>


			</div>
		</div>

		<!-- Footer -->
		<footer>
			<div class="row">
				<div class="col-lg-12">
					<p>Copyright &copy; Quizard</p>
				</div>
				<!-- /.col-lg-12 -->
			</div>
			<!-- /.row -->
		</footer>
	</div>

</body>

</html>