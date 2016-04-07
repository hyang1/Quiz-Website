<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="user.User, dbconnection.UserManager, user.HistoryItem, java.util.*, dbconnection.QuizManager" %>

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

</style>


<head>
    <meta charset="utf-8">
   	<meta http-equiv="X-UA-Compatible" content="IE=edge">
   	<meta name="viewport" content="width=device-width, initial-scale=1">
   	<!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

	<title>Quizard</title>
	
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
QuizManager qm = (QuizManager) request.getServletContext().getAttribute("QuizManager");

String username = request.getParameter("username");
if (username == null) {
	username = ((User)request.getSession().getAttribute("currentUser")).getUsername();
}
boolean userExists = accounts.accountExists(username);
User userToDisplay = null;
if (userExists) {
	userToDisplay = accounts.getUserPublicInfo(username);
	if (username.equals(((User)request.getSession().getAttribute("currentUser")).getUsername())) {
		request.getSession().setAttribute("currentUser", userToDisplay);
	}
	username = userToDisplay.getUsername();
}
%>

<!-- Profile Content -->
<div class="container">
	<div class="row">
		<%
		if (!userExists) {
			out.print("<h1 align=\"center\"><span class=\"glyphicon glyphicon-user\" aria-hidden=\"true\"></span> " + username + " does not exist</h1>");
		} else {
			out.print("<h1 align=\"center\"><span class=\"glyphicon glyphicon-user\" aria-hidden=\"true\"></span> " + 
					"<a href=\"user_profile.jsp?username=" + username + "\">" + username + "</a>'s profile</h1>");
		}
		%>
	</div>
	
	<div class="row form-group">
		<div class="message-options" style="text-align:center">
			<% 
			
			if (!username.equals(((User)request.getSession().getAttribute("currentUser")).getUsername())) {
				
				if (request.getAttribute("message") != null) {
					out.print("<p style=\"color:red\">" + request.getAttribute("message") + "</p>");
				}
				
				out.print("<form id=\"remove-user-form\" action=\"RemoveUserServlet\" method=\"post\">" +
						"<input type=\"hidden\" name=\"recipient\" value=\"" + username + "\"></form>");
				out.print("<form id=\"promote-user-form\" action=\"PromoteUserServlet\" method=\"post\">" +
						"<input type=\"hidden\" name=\"recipient\" value=\"" + username + "\"></form>");
				out.print("<form id=\"add-friend-form\" action=\"AddFriendServlet\" method=\"post\">" +
					"<input type=\"hidden\" name=\"recipient\" value=\"" + username + "\">" + "</form>" +
					"<a href=\"javascript:document.getElementById('add-friend-form').submit();\" class=\"btn btn-default add_friend_button\">" +
						"<span class=\"glyphicon glyphicon-plus\" aria-hidden=\"true\"></span> Add Friend</a>" +
					"<a href=\"javascript:updateForms('message');\" class=\"btn btn-default message_button\">" +
					"<span class=\"glyphicon glyphicon-envelope\" aria-hidden=\"true\"></span> Send Message</a>" +
					"<a href=\"javascript:updateForms('challenge');\" class=\"btn btn-default challenge_button\">" +
						"<span class=\"glyphicon glyphicon-screenshot\" aria-hidden=\"true\"></span> Challenge</a>"
				);
				if (((User)request.getSession().getAttribute("currentUser")).getUserStatus() == 1) {
					/* promote user form for administrator */
					out.print("<a href=\"javascript:document.getElementById('promote-user-form').submit();\" class=\"btn btn-default promote_button\">" +
							"<span class=\"glyphicon glyphicon-arrow-up\" aria-hidden=\"true\"></span> Promote User</a>");
					/* remove user form for administrator */
					out.print("<a href=\"javascript:document.getElementById('remove-user-form').submit();\" class=\"btn btn-default remove_button\">" +
							"<span class=\"glyphicon glyphicon-remove\" aria-hidden=\"true\"></span> Remove User</a>");
				}
			} else {
				if (((User)request.getSession().getAttribute("currentUser")).getUserStatus() == 1) {
					out.print("<a href=\"javascript:updateForms('announcement');\" class=\"btn btn-default promote_button\">" +
							"<span class=\"glyphicon glyphicon-envelope\" aria-hidden=\"true\"></span> Send Announcement</a>");
				}
			}
			
			%>
		</div>
	</div>
	<div class="row" style="text-align:center">
		<div class="col-md-3"></div>
		<div class="col-md-6 form-group message-forms">
			
			
		</div>
	</div>
	
	
	<div class="row">
		<div class="col-md-4">
			<h3><%= username %>'s Quizzes</h3>
			<div class="well">
				<%
				if (userExists) {
	                ArrayList<HistoryItem> recentQuizzesMade = userToDisplay.getRecentQuizzesMade(-1);
	                ArrayList<Integer> quizIds = new ArrayList<Integer>();
	                for (int i = 0; i < recentQuizzesMade.size(); i++) {
	                	HistoryItem item = recentQuizzesMade.get(i);
						quizIds.add(Integer.parseInt(item.getItemId()));
	                }
	                ArrayList<String> quizNames = qm.getQuizNames(quizIds);
	                for (int i = 0; i < recentQuizzesMade.size(); i++) {
	                	Date time = new Date(recentQuizzesMade.get(i).getStartTime());
	                	out.print("<div class=\"row\">" + 
									"<div class=\"col-md-6\">" + 
									"<p style=\"text-align:left;text-overflow: ellipsis;white-space: nowrap; " + 
									"overflow: hidden;\"><a href=\"quiz_summary.jsp?quiz_id=" + quizIds.get(i) + "\">"
									+ quizNames.get(i) + "</a>" +
									"</div>" +
								"<div class=\"col-md-6\">Created on " + time + "</div>" + 
								"</div>");
	      
	                }
				}
				%>
			</div>

		</div>
				
		<div class="col-md-4">
			<h3>Recent Scores</h3>
			<div class="well">
				<%
				if (userExists) {
	                ArrayList<HistoryItem> recentQuizzesTaken = userToDisplay.getRecentQuizzesTaken(10);
	                ArrayList<Integer> idstaken = new ArrayList<Integer>();
					for (int i = 0; i < recentQuizzesTaken.size(); i++) {
						idstaken.add(Integer.parseInt(recentQuizzesTaken.get(i).getItemId()));
					}
					ArrayList<String> recentTakenQuizNames = qm.getQuizNames(idstaken);
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
				}
				%>
			</div>
		</div>

			<div class="col-md-4">
				<h3>Achievements</h3>
				<div class="well">
					<%
				if (userExists) {
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
				}
				%>
				</div>

				<h3>Friends</h3>
				<div class="well">
					<%
				if (userExists) {
					ArrayList<String> friends = new ArrayList<String>(userToDisplay.getFriends());
		            Collections.sort(friends);
					if (friends.size() > 0) {
	                	for (String friend : friends) { 
		                	out.print("<div><span class=\"glyphicon glyphicon-user\" " + 
	                					"aria-hidden=\"true\"></span><a href=\"user_profile.jsp?username=" + 
	    		                				friend + "\"> " + friend + "</a></div>");
		                }
		            } else {
		            	out.print("<div><span class=\"glyphicon glyphicon-star\" aria-hidden=\"true\"></span> Friends? You don't have any friends! Nobody likes you >:)</div>");
		            }
				}
				%>
				</div>


				<%
					if (!username.equals(((User) request.getSession().getAttribute("currentUser")).getUsername())) {
						if (userExists) {

							out.print("<h3>Mutual Friends</h3><div class=\"well\">");
							
							HashSet<String> intersection = new HashSet<String>(userToDisplay.getFriends());
							intersection.retainAll(((User) request.getSession().getAttribute("currentUser")).getFriends());
	
							ArrayList<String> friends = new ArrayList<String>(intersection);
							Collections.sort(friends);
							if (friends.size() > 0) {
								for (String friend : friends) {
									out.print("<div><span class=\"glyphicon glyphicon-user\" "
											+ "aria-hidden=\"true\"></span><a href=\"user_profile.jsp?username=" + friend
											+ "\"> " + friend + "</a></div>");
								}
							} else {
								out.print(
										"<div><span class=\"glyphicon glyphicon-star\" aria-hidden=\"true\"></span> No mutual friends in common</div>");
							}
							out.print("</div>");
						}
					}
				%>

			</div>
		</div>
</div>


	<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
	<script
		src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
	<!-- Include all compiled plugins (below), or include individual files as needed -->
	
	<!-- script src="js/bootstrap.min.js"></script-->
	<script>
	updateForms = function(type) {
		var wrapper = $('.message-forms');
		wrapper.empty();
		if (type === "message") {
			console.log('asdf');
			$(wrapper).append(
				'<form id="message-form" action="MessageServlet" method="post">' +
					'<input type="hidden" name="recipient" value="<%= username %>">' +
					'<input type="hidden" name="source" value="<%= username %>">' +
					'<div class="form-group"><textarea class="form-control" name="message-body" placeholder="Message" required></textarea></div>' +
					'<input type="submit" class="btn btn-default" value="Send">' +
				'</form>'
			);
		} else if (type === "challenge") {
			$(wrapper).append(
					'<form id="message-form" action="ChallengeServlet" method="post">' +
					'<input type="hidden" name="recipient" value="<%= username %>">' +
					'<input type="hidden" name="source" value="<%= username %>">' +
					'<div class="form-group">' + 
					'<input type="text" class="btn btn-default" name="quiz-id" placeholder="Quiz ID" required></div>' +
					'<input type="submit" class="btn btn-default" value="Send">' +
				'</form>'
			);
		} else if (type === "announcement") {
			$(wrapper).append(
					'<form id="message-form" action="MessageServlet" method="post">' +
						'<input type="hidden" name="recipient" value="">' +
						'<input type="hidden" name="source" value="<%= username %>">' +
						'<div class="form-group"><textarea class="form-control" name="message-body" placeholder="Message" required></textarea></div>' +
						'<input type="submit" class="btn btn-default" value="Send">' +
					'</form>'
				);
		}
	};
	</script>

</body>
</html>