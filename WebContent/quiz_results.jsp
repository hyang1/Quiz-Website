<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="quiz.*, quiz.QuestionTypes.*, java.util.*, user.*, dbconnection.*, servlet.TakeQuizServlet, java.text.*" %>

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

.btn-input {
   display: block;
}

.btn-input .btn.form-control {
    text-align: left;
}

.btn-input .btn.form-control span:first-child {
   left: 10px;
   overflow: hidden;
   position: absolute;
   right: 25px;
}

.btn-input .btn.form-control .caret {
   margin-top: -1px;
   position: absolute;
   right: 10px;
   top: 50%;
}

</style>

<head>
    <meta charset="utf-8">
   	<meta http-equiv="X-UA-Compatible" content="IE=edge">
   	<meta name="viewport" content="width=device-width, initial-scale=1">
   	<!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

    <link href="bootstrap/css/bootstrap.min.css" rel="stylesheet">

	<%
		Quiz currentQuiz = (Quiz)session.getAttribute("currentQuiz");
		int totalNumQuestions = currentQuiz.getLength();
		ArrayList<String> useranswers = (ArrayList<String>)request.getSession().getAttribute("userAnswers");
		ArrayList<Integer> scoreboard = new ArrayList<Integer>();

	%>

	<title>Quiz Results</title>

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

<h1 align="center"><%
	if (session.getAttribute("practiceMode") != null) {
		out.println("Practice Quiz Results - ");
	} else {
		out.println("Quiz Results - ");
	}
	out.println(currentQuiz.getName());
%></h1>

<%
if (session.getAttribute("practiceModeDone") != null) {
	out.println("<h3 align=\"center\">Congratulations! You did well enough to finish practice mode!</h2>");
}
%>

<hr>
<% 
if (session.getAttribute("prevQuestionFeedback") != null) {
	out.print("<p style=\"color:red\" align=\"center\">" + session.getAttribute("prevQuestionFeedback") + "</p>");
}
%>

<div class="container">
<form class="form-horizontal">
<%
	int totalscore = 0;
	boolean showAnswers = (session.getAttribute("practiceMode") != null && session.getAttribute("practiceModeDone") != null) ||
						   session.getAttribute("practiceMode") == null;
	for (int index = 0; index < currentQuiz.getLength(); index++) {
		Question currentQuestion = currentQuiz.getQuestion(index);
	
		String[] answers = useranswers.get(index).split("\\|");
		int score = currentQuestion.getCorrectNum(answers);
		
		String q_html = TakeQuizServlet.formQuizResult(currentQuestion, index + 1, useranswers.get(index), score, showAnswers);
		out.print(q_html);

		scoreboard.add(score);
		totalscore+=score;
	}
	long elapsedTime = System.currentTimeMillis() - ((Long)session.getAttribute("startTime")).longValue();
	long second = (elapsedTime / 1000) % 60;
	long minute = (elapsedTime / (1000 * 60)) % 60;
	long hour = (elapsedTime / (1000 * 60 * 60)) % 24;
	String time = String.format("%02d:%02d:%02d", hour, minute, second);
	
	out.println("<h3 align=\"center\">"+"Your Total Score is " + totalscore +"</h3>");
	out.println("<h4 align=\"center\">"+"Elapsed time in hours: " + time +"</h4>");


	if (session.getAttribute("practiceMode") != null) {
		// still in practice mode - print CONTINUE and QUIT buttons
		if (session.getAttribute("practiceModeDone") == null) {
			out.println( 
				"<div class=\"col-md-3\"></div>" + 
				// CONTINUE
				"<form action=\"TakeQuizServlet\" method=\"post\" class=\" col-md-4 form-inline\">" +
					"<input type=\"hidden\" name=\"StartQuiz\">" +
					"<input type=\"hidden\" name=\"quiz_id\" value=\"" + session.getAttribute("currentQuizID") + "\">" +
					"<input type=\"submit\" class=\"btn btn-default\" value=\"Retry (continue practice mode)\">" + 
				"</form>" + 
				// LEAVE PRACTICE MODE
				"<form action=\"TakeQuizServlet\" method=\"post\" class=\"col-md-4 form-inline\">" +
					"<input type=\"hidden\" name=\"LeavePracticeMode\">" +
					"<input type=\"submit\" class=\"btn btn-default\" value=\"Quit (return to quiz summary)\">" + 
				"</form>"
			);
		}
	} 
	else {
		out.println( // RETURN TO QUIZ SUMMARY PAGE
			"<p style=\"text-align:center\">" + 
			"<a href=\"quiz_summary.jsp?quiz_id=" + session.getAttribute("currentQuizID") + "\" class=\"btn btn-default\">Return to quiz summary page</a></p>"
		);
	}
	
%>
</form>
</div>


	<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
	<script
		src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
	<!-- Include all compiled plugins (below), or include individual files as needed -->
	
	<!-- script src="js/bootstrap.min.js"></script-->

</body>

</body>
</html>