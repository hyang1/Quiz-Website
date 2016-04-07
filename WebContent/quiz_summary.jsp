<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page
	import="quiz.Quiz, dbconnection.*, java.util.*, java.util.concurrent.TimeUnit, user.HistoryItem, user.User"%>
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
<html>

<style>
body {
    padding-top: 70px; /* Required padding for .navbar-fixed-top. Remove if using .navbar-static-top. Change if height of navigation changes. */
}

footer {
    margin: 50px 0;
}

.administrator-actions {
	text-align: center;
}

.actions {
	text-align: center;
}

.history-item {
	margin-top: 15px;
	text-align: center;
}

</style>

<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

<title>Quiz Summary</title>

<link href="bootstrap/css/bootstrap.min.css" rel="stylesheet">
<%
	// Get the necessary variables to use in this JSP
	int quiz_id = Integer.parseInt(request.getParameter("quiz_id"));
	//int quiz_id = Integer.parseInt("2");
	DBConnection con = (DBConnection) request.getServletContext().getAttribute("DBConnection");
	QuizManager quizzes = (QuizManager) request.getServletContext().getAttribute("QuizManager");
	Quiz q = quizzes.getQuiz(new Integer(quiz_id));
	boolean quizExists = (q != null);

	User currentUser = (User) session.getAttribute("currentUser");
	String username = currentUser.getUsername();

	ArrayList<HistoryItem> userhistory = new ArrayList<HistoryItem>();//con.getUserQuizHistory(username, ""+quiz_id);
	ArrayList<HistoryItem> userhistory_byscore = con.getUserQuizHistory(username, quiz_id + "", "score");
	ArrayList<HistoryItem> userhistory_bydate = con.getUserQuizHistory(username, quiz_id + "", "starttime");
	ArrayList<HistoryItem> userhistory_bytime = con.getQuizByTimeSpent(username, quiz_id + "");
	/*
	for(int x = 0; x < userhistory_bytime.size(); x ++) {
		for(int y = x + 1; y < userhistory_bytime.size(); y ++) {
			long timey = userhistory_bytime.get(y).getEndTime() - userhistory_bytime.get(y).getStartTime();
			long timex = userhistory_bytime.get(x).getEndTime() - userhistory_bytime.get(x).getStartTime();
			if(timex > timey)
				Collections.swap(userhistory_bytime, x, y);
		}
	}*/
	ArrayList<HistoryItem> topplayers = con.getTopPlayers(quiz_id + "", 5);
	ArrayList<HistoryItem> recentplayers = con.getQuizHistory(quiz_id + "", "starttime", 5);
	ArrayList<HistoryItem> recenttopplayers = con.getQuizRecentPerformance(quiz_id + "");
	ArrayList<HistoryItem> pastplayers = con.getPastPlayers(quiz_id + "");

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


	<div class="container">

		<div class="row">
			<h1 align="center" style="font-size: 300%">
				<%
					if (quizExists) {
						out.print("<a href=\"quiz_summary.jsp?quiz_id=" + quiz_id + "\">" + q.getName() + "</a>");
					} else {
						out.print("Sorry, this quiz does not exist!");
					}
				%>
			</h1>

			<h4 align="center">
				<%
					if (quizExists) {
						out.print("by <span class=\"glyphicon glyphicon-user\" aria-hidden=\"true\"></span> "
								+ "<a href=\"user_profile.jsp?username=" + q.getCreator() + "\">" + q.getCreator() + "</a>");
					}
				%>
			</h4>
		</div>

		<div class="row">

			<div class="col-md-3">
				<h4>Quiz Description</h4>
				<div class="well">
					<%
						if (quizExists)
							out.print(q.getDescription());
					%>
				</div>

				<h4>Actions</h4>
				<div class="well actions">
					<%
						if (quizExists) {
							out.print("<form action=\"TakeQuizServlet\" method=\"post\" class=\"form-inline\">"
									+ "<input type=\"hidden\" name=\"StartQuiz\">"
									+ "<input type=\"hidden\" name=\"quiz_id\" value=" + quiz_id + ">"
									+ "<input type=\"submit\" class=\"btn btn-default\" value=\"Take Quiz\"></form>");
							if (q.isPractice()) {
								out.print("<br>");
								out.print("<form action=\"TakeQuizServlet\" method=\"post\" class=\"form-inline\">"
										+ "<input type=\"hidden\" name=\"StartQuiz\">"
										+ "<input type=\"hidden\" name=\"PracticeMode\">"
										+ "<input type=\"hidden\" name=\"quiz_id\" value=\"" + quiz_id + "\">"
										+ "<input type=\"submit\" class=\"btn btn-default\" value=\"Practice\"></form>");
							}
							if ((currentUser.getUsername().equals(q.getCreator()))) {
								out.print("<br>");
								out.print("<form action=\"EditQuizServlet\" method=\"post\" class=\"form-inline\">"
										+ "<input type=\"hidden\" name=\"EditQuiz\" value=\"EditQuiz\">"
										+ "<input type=\"hidden\" name=\"quiz_id\" value=\"" + quiz_id + "\">"
										+ "<input type=\"submit\" class=\"btn btn-default\" value=\"Edit Quiz\"></form>"
										);
							}
						}
					%>
				</div>
				<%
	
				if (currentUser.getUserStatus() == 1) { // an administrator
					out.print("<h4>Administrator Actions</h4><div class=\"well administrator-actions\">");
					if (quizExists) {
						out.print("<form action=\"ClearQuizHistoryServlet\" method=\"post\" class=\"form-inline\">"
								+ "<input type=\"hidden\" name = \"ClearQuizHistory\" value=\"ClearQuizHistory\">"
								+ "<input type=\"hidden\" name=\"quiz_id\" value=" + quiz_id + ">"
								+ "<input type=\"submit\" class=\"btn btn-default\" value=\"Clear Quiz History\"></form>");
						out.print("<br>");
						out.print("<form action=\"RemoveQuizServlet\" method=\"post\" class=\"form-inline\">"
								+ "<input type=\"hidden\" name = \"RemoveQuiz\" value=\"RemoveQuiz\">"
								+ "<input type=\"hidden\" name=\"quiz_id\" value=" + quiz_id + ">"
								+ "<input type=\"submit\" class=\"btn btn-default\" value=\"Remove Quiz\"></form>");
					}
					out.print("</div>");
				}
				
				%>
			</div>



			<div class="col-md-6">
				<h4>Quiz Statistics</h4>
				<div class="well">
					<%
						if (pastplayers != null && pastplayers.size() > 0) {
							out.println("The Highest Score is " + pastplayers.get(0).getScore() + "<br>");
							out.println("The Lowest Score is " + pastplayers.get(pastplayers.size() - 1).getScore() + "<br>");
							out.println("25% of the Players Get More than " + pastplayers.get(pastplayers.size() / 4).getScore()
									+ "<br>");
							out.println("50% of the Players Get More than " + pastplayers.get(pastplayers.size() / 2).getScore()
									+ "<br>");
							out.println("75% of the Players Get More than " + pastplayers.get(pastplayers.size() / 4 * 3).getScore()
									+ "<br>");
						}
					%>
				</div>

				<h4>Top Players</h4>
				<div class="well">
					<%
						if (topplayers != null) {
							for (int i = 0; i < topplayers.size(); i++) {
								out.print("User: "+ "<a href=\"user_profile.jsp?username=" + topplayers.get(i).getUser()
										+ "\">" + topplayers.get(i).getUser() + "</a>" + "   ");
								out.print("Score: "+topplayers.get(i).getScore() + "<br>");
							}
						}
					%>
				</div>

				<h4>Recent Players</h4>
				<div class="well">
					<%
						if (recentplayers != null) {
							for (int i = 0; i < recentplayers.size(); i++) {
								out.print("User: "+ "<a href=\"user_profile.jsp?username=" + recentplayers.get(i).getUser()
										+ "\">" + recentplayers.get(i).getUser() + "</a>" + "   ");
								long millis = recentplayers.get(i).getEndTime() - recentplayers.get(i).getStartTime();
								String min = millis/60000 + ":";
								String sec = (millis/1000)%60 + "";
								String time = min+sec;
								out.println("Time spent: " + time + "<br>");
							}
						}
					%>
				</div>


				<h4>Performers in Past 24 Hours</h4>
				<div class="well">
					<%
						if (recenttopplayers != null) {
							for (int i = 0; i < recenttopplayers.size(); i++) {
								out.print("User: "+ "<a href=\"user_profile.jsp?username=" + recenttopplayers.get(i).getUser()
										+ "\">" + recenttopplayers.get(i).getUser() + "</a>" + "   ");
								out.print("Score: " + recenttopplayers.get(i).getScore() + ",   ");
								long millis = recenttopplayers.get(i).getEndTime() - recenttopplayers.get(i).getStartTime();
								String min = millis/60000 + ":";
								String sec = (millis/1000)%60 + "";
								String time = min+sec;
								out.println("Time spent: " + time + "<br>");
							}
						}
					%>
				</div>
			</div>

			<div class="col-md-3">
				<h4>Your History on This Quiz</h4>
				<div class="well">
					<label class="control-label col-md-6" for="view-dropdown">Order
						By:</label> <select id="view-dropdown" name="quiz-display"
						class="form-control" onchange="javascript:modify();">
						<option value=""></option>
						<option value="date">Date</option>
						<option value="percentagecorrect">Percentage Correct</option>
						<option value="timespent">Time Spent</option>
					</select>
					<div class="userhistory"></div>
				</div>
			</div>

			<script
				src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>


			<%
			String builder_byscore = "";
			if (userhistory_byscore != null) {
				for (int i = 0; i < userhistory_byscore.size(); i++) {
					builder_byscore += "<div class=\"history-item\">";
					builder_byscore += "<div class=\"\">Percentage Correct: " + (int)((double)userhistory_byscore.get(i).getScore()/q.getTotalScore()*100) +"%</div>";
					builder_byscore += "<div class=\"\">Date: " + 	new Date(userhistory_byscore.get(i).getStartTime()) + "</div>";
					long millis = userhistory_byscore.get(i).getEndTime() - userhistory_byscore.get(i).getStartTime();
					String min = millis/60000 + ":";
					String sec = (millis/1000)%60 + "";
					String time = min+sec;
					builder_byscore += "<div class=\"\">Time Spent: "
							+ time
							+ "</div></div>";
				}
			}
			
			String builder_bydate = "";
			if (userhistory_bydate != null) {
				for (int i = 0; i < userhistory_bydate.size(); i++) {
					builder_bydate += "<div class=\"history-item\">";
					builder_bydate += "<div class=\"\">Percentage Correct: " + (int)((double)userhistory_bydate.get(i).getScore()/q.getTotalScore()*100) +"%</div>";
					builder_bydate += "<div class=\"\">Date: " + new Date(userhistory_bydate.get(i).getStartTime()) + "</div>";
					long millis = userhistory_bydate.get(i).getEndTime() - userhistory_bydate.get(i).getStartTime();
					String min = millis/60000 + ":";
					String sec = (millis/1000)%60 + "";
					String time = min+sec;
					builder_bydate += "<div class=\"\">Time Spent: "
							+ time
							+ "</div></div>";
				}
			}
			
			String builder_bytime = "";
			if (userhistory_bytime != null) {
				for (int i = 0; i < userhistory_bytime.size(); i++) {
					builder_bytime += "<div class=\"history-item\">";
					builder_bytime += "<div class=\"\">Percentage Correct: " + (int)((double)userhistory_bytime.get(i).getScore()/q.getTotalScore()*100) +"%</div>";
					builder_bytime += "<div class=\"\">Date: " + new Date(userhistory_bytime.get(i).getStartTime()) + "</div>";
					long millis = userhistory_bytime.get(i).getEndTime() - userhistory_bytime.get(i).getStartTime();
					String min = millis/60000 + ":";
					String sec = (millis/1000)%60 + "";
					String time = min+sec;
					builder_bytime += "<div class=\"\">Time Spent: "
							+ time
							+ "</div></div>";
				}
			}
			%>

			<script>
				
				var modify = function() {
					var order_standard = document
							.getElementById("view-dropdown");
					var order_standard = order_standard.options[order_standard.selectedIndex].text;
					console.log(order_standard);
					var userhistory = $('.userhistory');
					userhistory.empty();
					if (order_standard == "Percentage Correct") {
						$(userhistory).append('<%= builder_byscore %>');
					} else if (order_standard == "Date") {
						$(userhistory).append('<%= builder_bydate %>');
					} else if (order_standard == "Time Spent") {
						$(userhistory).append('<%= builder_bytime %>');
					}
				};
			</script>









		</div>

	</div>




</body>
</html>