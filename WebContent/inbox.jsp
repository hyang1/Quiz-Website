<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="user.User, dbconnection.UserManager, user.Message, java.util.*, java.text.*, dbconnection.QuizManager, quiz.Quiz"%>
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

body {
    padding-top: 70px; /* Required padding for .navbar-fixed-top. Remove if using .navbar-static-top. Change if height of navigation changes. */
}

footer {
    margin: 50px 0;
}

.vcenter {
    display: inline-block;
    vertical-align: middle;
    float: none;
}

</style>

<head>
    <meta charset="utf-8">
   	<meta http-equiv="X-UA-Compatible" content="IE=edge">
   	<meta name="viewport" content="width=device-width, initial-scale=1">
   	<!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

	<title>Inbox</title>
	
    <link href="bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <% // Get the necessary variables to use in this JSP
	UserManager accounts = (UserManager) request.getServletContext().getAttribute("UserManager");
    User user = ((User)request.getSession().getAttribute("currentUser"));
    
    Format timeFormat = new SimpleDateFormat("HH:mm:ss");
    Format dateFormat = new SimpleDateFormat("EEE, MMM. d, yyyy");
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


<div style="text-align:center"><h1 align="center">Inbox</h1></div>

<div class="container">
	<div class="col-md-2"></div>
	<div class="col-md-8 inbox-messages">
		<% 
		
		if (request.getAttribute("message") != null) {
			out.print("<p style=\"color:red\" align=\"center\">" + request.getAttribute("message") + "</p>");
		}
		
		ArrayList<Message> messages = accounts.getRecentRecievedMessages(user, 500);
		for (Message m : messages) {
			int type = m.getType();
		    String timeStr = timeFormat.format(new Date(m.getTime()));
		    String dateStr = dateFormat.format(new Date(m.getTime()));
			if (type == 0) { // friend requests
				out.print(
					"<div class=\"well\">" +
						"<div class=\"row\">" +
							"<div class=\"col-md-7\">" +
								"<h5><span class=\"glyphicon glyphicon-plus\" aria-hidden=\"true\"></span> " + 
									"<a href=\"user_profile.jsp?username=" + m.getSender() + "\">" + m.getSender() + 
								"</a> sent you a friend request</span></h5>" +
							"</div>" +
							"<div class=\"col-md-3\">" +
								"<form id=\"confirm-friend-form\" action=\"ConfirmFriendServlet\" method=\"post\">" +
									"<input type=\"hidden\" name=\"sender\" value=\"" + m.getSender() + "\">" +
								"</form>" +
								"<a href=\"javascript:document.getElementById('confirm-friend-form').submit();\" class=\"btn btn-default add_friend_button\"  style=\"float:right\">" +
									"<span class=\"glyphicon glyphicon-ok\" aria-hidden=\"true\"></span> Confirm Friend</a>" +
							"</div>" +
							"<div class=\"col-md-2\">" +
								"<form id=\"ignore-friend-form\" action=\"IgnoreFriendServlet\" method=\"post\">" +
									"<input type=\"hidden\" name=\"sender\" value=\"" + m.getSender() + "\">" +
								"</form>" +
								"<a href=\"javascript:document.getElementById('ignore-friend-form').submit();\" class=\"btn btn-default ignore_friend_button\"  style=\"float:right\">" +
									"<span class=\"glyphicon glyphicon-remove\" aria-hidden=\"true\"></span> Ignore</a>" +
							"</div>" +
						"</div>" +
					"</div>"
				);
			} else if (type == 2) { // notes
				out.print(
					"<div class=\"well\">" +
						"<form id=\"reply-message-form\" action=\"MessageServlet\" method=\"post\">" +
							"<input type=\"hidden\" name=\"source\" value=\"inbox\">" +
							"<input type=\"hidden\" name=\"recipient\" value=\"" + m.getSender() + "\">" +
							"<div class=\"row form-group\">" +
								"<div class=\"col-md-10\">" +
									"<h5><span class=\"glyphicon glyphicon-envelope\" aria-hidden=\"true\"></span> " + 
										"<a href=\"user_profile.jsp?username=" + m.getSender() + "\">" + m.getSender() + "</a> sent you a message at " + 
								    		timeStr + " on " + dateStr + ": " +
									"</h5>" +
								"</div>" +
								"<div class=\"col-md-2\">" +
									"<a href=\"javascript:document.getElementById('reply-message-form').submit();\" class=\"btn btn-default reply_message_button\" style=\"float:right\">" +
										"<span class=\"glyphicon glyphicon-share-alt\" aria-hidden=\"true\"></span> Send Reply</a>" +
								"</div>" +
							"</div>" +
							"<div class=\"row\">" +
								"<div class=\"form-group col-md-6\">" + 
									"<textarea class=\"form-control\" readonly>" + m.getMessage() + "</textarea>" +
								"</div>" + 
								"<div class=\"col-md-6\">" + 
									"<textarea class=\"form-control\" name=\"message-body\" placeholder=\"reply here\" required></textarea>" +
								"</div>" +
							"</form>" +
						"</div>" +
					"</div>"
				);
			} else if (type == 1) { // challenge
				String[] challengeInfo = m.getMessage().split("\\|");
				QuizManager qm = (QuizManager) request.getServletContext().getAttribute("QuizManager");
				int quizId = Integer.parseInt(challengeInfo[0]);
				Quiz quiz = qm.getQuiz(new Integer(quizId));
				out.print(
						"<div class=\"well\">" +
							"<div class=\"row\">" +
								"<div class=\"col-md-7\">" +
									"<h5><span class=\"glyphicon glyphicon-screenshot\" aria-hidden=\"true\"></span> " + 
										"<a href=\"user_profile.jsp?username=" + m.getSender() + "\">" + m.getSender() + 
									"</a> challenges you to beat a score of " + challengeInfo[1] + " on \"" + quiz.getName() + "\"</span></h5>" +
								"</div>" +
								"<div class=\"col-md-3\">" +
									"<form id=\"accept-challenge-form\" action=\"AcceptChallengeServlet\" method=\"post\">" +
										"<input type=\"hidden\" name=\"sender\" value=\"" + m.getSender() + "\">" +
										"<input type=\"hidden\" name=\"quiz-id\" value=\"" + challengeInfo[0] + "\">" +
										"<input type=\"hidden\" name=\"score\" value=\"" + challengeInfo[1] + "\">" +
									"</form>" +
									"<a href=\"javascript:document.getElementById('accept-challenge-form').submit();\" class=\"btn btn-default accept_challenge_button\"  style=\"float:right\">" +
										"<span class=\"glyphicon glyphicon-ok\" aria-hidden=\"true\"></span> Accept Challenge!</a>" +
								"</div>" +
								"<div class=\"col-md-2\">" +
									"<form id=\"ignore-challenge-form\" action=\"IgnoreChallengeServlet\" method=\"post\">" +
										"<input type=\"hidden\" name=\"sender\" value=\"" + m.getSender() + "\">" +
										"<input type=\"hidden\" name=\"quiz-id\" value=\"" + challengeInfo[0] + "\">" +
										"<input type=\"hidden\" name=\"score\" value=\"" + challengeInfo[1] + "\">" +
									"</form>" +
									"<a href=\"javascript:document.getElementById('ignore-challenge-form').submit();\" class=\"btn btn-default ignore_challenge_button\"  style=\"float:right\">" +
										"<span class=\"glyphicon glyphicon-remove\" aria-hidden=\"true\"></span> Ignore</a>" +
								"</div>" +
							"</div>" +
						"</div>"
					);
			}
		}
		%>
	</div>
</div>


	<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
	<script
		src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
	<!-- Include all compiled plugins (below), or include individual files as needed -->

</body>

</html>