<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="quiz.*, quiz.QuestionTypes.*, java.util.*, servlet.TakeQuizServlet, dbconnection.UserManager, user.User"%>
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
<html>

<style>

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


body {
    padding-top: 70px; /* Required padding for .navbar-fixed-top. Remove if using .navbar-static-top. Change if height of navigation changes. */
}

footer {
    margin: 50px 0;
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
		boolean allQuestionsAtOnce = currentQuiz.isSinglePage();
		int currentQuestionNumber = -1;
		if (!allQuestionsAtOnce) {
			currentQuestionNumber = (int)session.getAttribute("questionIndex") + 1;
		}

		/*ArrayList<String> answers = new ArrayList<String>();
		answers.add("Quizlet");
		Question q = new ResponseQuestion("What is the name of this website?", answers);
		request.setAttribute("currentquestion", q);
		*/
	%>

	<title>Quiz In Progress - <%= currentQuiz.getName() %></title>

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
	if (session.getAttribute("practiceMode") != null) 
		out.print("Practice Mode: ");
	out.print(currentQuiz.getName());
%>
</h1>
<% 
if (!allQuestionsAtOnce) {
	out.print("<h3 align=\"center\">Question " + currentQuestionNumber + " of " + totalNumQuestions + "</h3>");
}
%>

<hr>
<% 
if (session.getAttribute("prevQuestionFeedback") != null) {
	out.print("<p style=\"color:red\" align=\"center\">" + session.getAttribute("prevQuestionFeedback") + "</p>");
}
%>

<div class="container">
<form action="TakeQuizServlet" class="form-horizontal" method="post">
	<%
		if (allQuestionsAtOnce) {
			for (int index = 0; index < currentQuiz.getLength(); index++) {
				Question currentQuestion = currentQuiz.getQuestion(index);
				String q_html = TakeQuizServlet.formQuestion(currentQuestion, index + 1);
				out.print(q_html);
			}
			out.print("<input type=\"submit\" class=\"btn btn-default\" name=\"FinishQuiz\" value=\"Submit Quiz\">");
		}
		else {
			int index = (int)session.getAttribute("questionIndex");
			Question currentQuestion = currentQuiz.getQuestion(index);
			String q_html = TakeQuizServlet.formQuestion(currentQuestion, index + 1);
			out.print(q_html);
			if (index + 1 < currentQuiz.getLength()) {
				out.println("<input type=\"submit\" class=\"btn btn-default\" name=\"NextQuestion\" value=\"Next Question\">");
			}
			else {
				out.println("<input type=\"submit\" class=\"btn btn-default\" name=\"FinishQuiz\" value=\"Submit Quiz\">"); 
			}
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
</html>