<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="quiz.*, dbconnection.*, quiz.QuestionTypes.*, java.util.*, user.User, servlet.TakeQuizServlet"%>

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

	<title>Edit Quiz</title>
	
    <link href="bootstrap/css/bootstrap.min.css" rel="stylesheet">
    
     <% // Get the necessary variables to use in this JSP
	int quiz_id = Integer.parseInt(request.getParameter("quiz_id"));
	QuizManager quizzes = (QuizManager) request.getServletContext().getAttribute("QuizManager");
	Quiz q = quizzes.getQuiz(new Integer(quiz_id));
	String currentUsername = ((User)request.getSession().getAttribute("currentUser")).getUsername();
	boolean canEdit = (q != null && q.getCreator().equals(currentUsername));
	ArrayList<Question> questions = new ArrayList<Question>();
	if (canEdit) {
		questions = q.getQuestions();
	}
	DBConnection con = new DBConnection();
	ArrayList<String> tags = quizzes.getTagByQuiz(quiz_id);
	String concattags = String.join("|", tags);
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


<h1 align="center" class="page-title">Edit Quiz</h1>

<hr>

<div class="container form-horizontal" id="everything">
	<fieldset id="edit-quiz-form-control">
	<form id="edit-quiz-form" action="CreateQuizServlet" method="post">
	
		<div class="form-group">
			<label for="quiz-name" class="col-md-3 control-label">Quiz Name:</label>
			<div class="col-md-6">
			    <input type="text" name="quiz-name" id="quiz-name" class="form-control" value = "<%=q.getName()%>" required>
			</div>
	    </div>
	    
	    <div class="form-group">
			<label for="quiz-description" class="col-md-3 control-label">Short description:</label>
			<div class="col-md-6">
			    <textarea name="quiz-description" id="quiz-description" class="form-control"required><%=q.getDescription() %></textarea>
			</div>
	    </div>
	    	    
	    <div class="form-group">
			<label for="quiz-tags" class="col-md-3 control-label">Tags</label>
			<div class="col-md-6">
			    <textarea name="quiz-tags" id="quiz-tags" class="form-control" placeholder="separate tags with |"><%=concattags%></textarea>
			</div>
	    </div>
	    
	    <div class="form-group">

			<label class="control-label col-md-3" for="category-dropdown">Category:</label>
			<div class="col-md-2">
				<select id="category-dropdown" name="quiz-category" class="form-control">
			    <option value = "0"<%if(q.getCategory()==0) out.print("selected"); %>>Other</option>
			    <option value = "1"<%if(q.getCategory()==1) out.print("selected"); %>>Literature</option>
			    <option value = "2"<%if(q.getCategory()==2) out.print("selected"); %>>English</option>
			    <option value = "3"<%if(q.getCategory()==3) out.print("selected"); %>>Science</option>
			    <option value = "4"<%if(q.getCategory()==4) out.print("selected"); %>>Geography</option>
			    <option value = "5"<%if(q.getCategory()==5) out.print("selected"); %>>History</option>
				</select> 
			</div>
			
			<label class="control-label col-md-1" for="view-dropdown">Display:</label>
			<div class="col-md-3">
				<select id="view-dropdown" name="quiz-display" class="form-control">
			    <option <%if(!q.isSinglePage()) out.print("selected"); %>>One question per page</option>
			    <option <%if(q.isSinglePage()) out.print("selected"); %>>All questions at once</option>
			    <!-- TODO: generate categories -->
				</select> 
			</div>
	
		</div>
		
		<div class="form-group">
			<label class="col-md-3 active"></label>
  			<label class="checkbox-inline col-md-2"><input type="checkbox" name="practice-mode-enabled" value="true" <%if(q.isPractice()==true) out.print("checked");%> >Allow practice mode</label>
			<label class="checkbox-inline col-md-2"><input type="checkbox" name="randomize-order" value="true" <%if(q.isRandomized()==true) out.print("checked");%>>Randomize order</label>
			<label class="checkbox-inline col-md-2"><input type="checkbox" name="immediate-scoring" value="true"<%if(q.isImmediateCorrection()==true) out.print("checked");%>>Immediate scoring</label>
		</div>
		
		<h2 align="center">Questions:</h2>
		
		<input id="max-questions" type="hidden" name="max-questions" value="1"/>
		
		<div class="field_wrapper">


		    <!-- single question -->
		    <div class="q1-wrapper well">
		    	<div class="row form-group">
				    <label class="control-label col-md-4" for="q1-type">Question Type:</label>
					<div class="col-md-4">
						<select id="q1-type" class="form-control q1-type" name="q1-type" onchange="modifyQ(1)">
					    <option value=0>Question-Response</option>
					    <option value=1>Fill in the Blank</option>
					    <option value=2>Multiple Choice</option>
					    <option value=3>Picture-Response Question</option>
					    <option value=4>Multi-Answer Question</option>
					    <option value=5>Multiple Choice with Multiple Answers</option>
						</select> 
					</div>
				</div>
				<hr>
				<div class="row form-group q1-content">
					<div class="form-group">
	    				<label for="q1-question" class="control-label col-md-2">Question:</label>
	    				<div class="col-md-8">
	    				    <textarea name="q1-question" class="form-control" required></textarea>
	    				</div>
	    		    </div>
	    		    <div class="form-group">
    					<label for="q1-answers" class="control-label col-md-2">Answer:</label>
    					<div class="col-md-8">
    				    	<input type="text" name="q1-answers" class="form-control" placeholder="separate acceptable answers with |" required/>
    					</div>
    		    	</div>
	    		</div>
		    </div>
		    
		    
		    
		</div>
				
		<div class="form-group">
			<div class="col-md-3"></div>
			<div class="col-md-3">
				<a href="javascript:void(0);" class="btn btn-default add_button" title="Add field">
					<span class="glyphicon glyphicon-plus" aria-hidden="true"></span> Add another question</a>	
			</div>
			

		
			<div class="col-md-3" style="text-align:center">

					<input type="hidden" name="quiz_id" value=<%=quiz_id%>>
					<input type="hidden" name="ReplaceQuiz" value = "ReplaceQuiz" >
					<input type="submit" class="btn btn-default" value="Create Quiz!">
			</div>
		</div>
		<input type="hidden" id="q_id" value=1>
		
	</form>	

			
		
	</fieldset>
	
</div>

	<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
	<script src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
	
	<script type="text/javascript">
	$(document).ready(function(){
		
		var canEdit = <%=canEdit%>;
		if (!canEdit) {
			alert("Sorry, you can't edit this quiz because you are not the original creator!");
			$('#edit-quiz-form-control').attr("disabled", "disabled");
			return;
		}
	
	    var addButton = $('.add_button'); //Add button selector
	    var wrapper = $('.field_wrapper'); //Input field wrapper
	    var x = 1; //Initial field counter is 1
	    $(addButton).click(function(){ //Once add button is clicked
	    	document.getElementById('max-questions').value++;
	    	x = document.getElementById('max-questions').value;
	    	$(wrapper).append(
	        	'<div class="q' + x + '-wrapper well">' +
	    			'<div class="row form-group">' +
		    			'<label class="control-label col-md-4" for="q' + x + '-type">Question Type:</label>' +
						'<div class="col-md-4">' +
							'<select id="q' + x + '-type" class="form-control q' + x + '-type" name="q' + x + '-type" onchange="modifyQ(' + x + ')">' +
					    	'<option value=0>Question-Response</option>' +
					    	'<option value=1>Fill in the Blank</option>' +
					    	'<option value=2>Multiple Choice</option>' +
					    	'<option value=3>Picture-Response Question</option>' +
					    	'<option value=4>Multi-Answer Question</option>' +
					    	'<option value=5>Multiple Choice with Multiple Answers</option>' +
							'</select>' +
						'</div>' +
					'</div>' +
					'<hr>' +
					'<div class="row form-group q' + x + '-content">' +
						'<div class="form-group">' +
							'<label for="q' + x + '-question" class="control-label col-md-2">Question:</label>' +
							'<div class="col-md-8">' +
							    '<textarea name="q' + x + '-question" class="form-control" required></textarea>' +
							'</div>' +
					    '</div>' +
				    '<div class="form-group">' +
						'<label for="q' + x + '-answers" class="control-label col-md-2">Answer:</label>' +
						'<div class="col-md-8">' +
				    		'<input type="text" name="q' + x + '-answers" class="form-control" placeholder="separate acceptable answers with |" required/>' +
						'</div>' +
		    		'</div>' +
				'</div>' +
				'<div style="text-align:center">' +
	        		'<a href="javascript:void(0);" class="btn btn-default remove_button"><span class="glyphicon glyphicon-remove" aria-hidden="true"></span> Remove question</a></div>' +
	        	'</div>'
	    	);
	    });
	    
	    $(wrapper).on('click', '.remove_button', function(e){ //Once remove button is clicked
	        e.preventDefault();
	        $(this).parent('div').parent('div').remove(); //Remove field html
	    });
	    
	    
	    <% 
	    
	    
	    
	    for (int i = 0; i < questions.size(); i++) {
	    	int q_id = i + 1;
	    	if (q_id > 1) {
	    		out.print("$(addButton).click();");
	    	}
	    	Question question = questions.get(i);
	    	out.print("$('.q" + q_id + "-type').val(" + question.getType() + ");");
	    	out.print("modifyQ(" + q_id + ");");
	    	if (question.getType() == 0) { // Question-Response
	    		out.print("$('[name=\"q" + q_id + "-question\"]').val('" + question.getQuestion() + "');");
	    		out.print("$('[name=\"q" + q_id + "-answers\"]').val('" + question.getAnswersStr() + "');");
	    	} 
	    	else if (question.getType() == 1) { // Fill in the Blank
	    		FillInBlankQuestion question_i = (FillInBlankQuestion)question;
	    		out.print("$('[name=\"q" + q_id + "-question\"]').val('" + question_i.getPart1() + "____" + question_i.getPart2() + "');");
	    		out.print("$('[name=\"q" + q_id + "-answers\"]').val('" + question_i.getAnswersStr() + "');");
	    	}
	    	else if (question.getType() == 2) { // Multiple Choice
	    		MultipleChoiceQuestion question_i = (MultipleChoiceQuestion)question;
	    		out.print("$('[name=\"q" + q_id + "-question\"]').val('" + question_i.getQuestion() + "');");
	    		out.print("$('[name=\"q" + q_id + "-correct\"]').val('" + question_i.getAnswer() + "');");
	    		out.print("$('[name=\"q" + q_id + "-wrong\"]').val('" + question_i.getWrongAnswersStr() + "');");
	    	}
	    	else if (question.getType() == 3) { // Picture-Response Question
	    		PictureResponseQuestion question_i = (PictureResponseQuestion)question;
	    		out.print("$('[name=\"q" + q_id + "-question\"]').val('" + question_i.getQuestion() + "');");
	    		out.print("$('[name=\"q" + q_id + "-image-url\"]').val('" + question_i.getURL() + "');");
	    		out.print("$('[name=\"q" + q_id + "-image-preview\"]').attr(\"src\",'" + question_i.getURL() + "');");
	    		out.print("$('[name=\"q" + q_id + "-answers\"]').val('" + question_i.getAnswersStr() + "');");
	    	} 
	    	else if (question.getType() == 4) { // Multi-Answer Question
	    		MultiAnswerQuestion question_i = (MultiAnswerQuestion)question;
	    		out.print("$('[name=\"q" + q_id + "-question\"]').val('" + question_i.getQuestion() + "');");
	    		out.print("$('[name=\"q" + q_id + "-answers\"]').val('" + question_i.getAnswersStr() + "');");
	    		out.print("$('[name=\"q" + q_id + "-num-answers\"]').val('" + question_i.getAnswerNumber() + "');");
	    		if (question_i.isInorder()) {
		    		out.print("$('[name=\"q" + q_id + "-answer-order\"]').prop('checked', true);");
	    		}
	    	} 
	    	else if (question.getType() == 5) { // Multiple Choice with Multiple Answers;
	    		MultipleAnswerMCQuestion question_i = (MultipleAnswerMCQuestion)question;
	    		out.print("$('[name=\"q" + q_id + "-question\"]').val('" + question_i.getQuestion() + "');");
	    		out.print("$('[name=\"q" + q_id + "-correct\"]').val('" + question_i.getAnswersStr() + "');");
	    		out.print("$('[name=\"q" + q_id + "-wrong\"]').val('" + question_i.getWrongAnswersStr() + "');");
	    	}
	    }
	    %>
	});

    function modifyQ(i) {
    	var q_types = document.getElementById("q" + i + "-type");
    	var q_type = q_types.options[q_types.selectedIndex].text;
    	
    	var q_content = $('.q' + i + '-content');
    	q_content.empty();
    	if (q_type === "Question-Response") {
    		$(q_content).append(
    			'<div class="form-group">' + 
    				'<label for="q' + i + '-question" class="control-label col-md-2">Question:</label>' +
    				'<div class="col-md-8">' +
    				    '<textarea name="q' + i + '-question" class="form-control" required></textarea>' +
    				'</div>' +
    		    '</div>' + 
    		    '<div class="form-group">' + 
   					'<label for="q' + i + '-answers" class="control-label col-md-2">Answer:</label>' +
   					'<div class="col-md-8">' +
   				    	'<input type="text" name="q' + i + '-answers" class="form-control" placeholder="separate acceptable answers with |" required/>' +
   					'</div>' +
   		    	'</div>'    
    		);
    	} else if (q_type === "Fill in the Blank") {
    		$(q_content).append(
    			'<div class="form-group">' + 
    				'<label for="q' + i + '-question" class="control-label col-md-2">Question:</label>' +
    				'<div class="col-md-8">' +
    				    '<input name="q' + i + '-question" class="form-control" pattern="(.+____.+)|(____.+)|(.+____)" placeholder="denote blank using ____ (4 underscores)" required/>' +
    				'</div>' +
    		    '</div>' + 
    		    '<div class="form-group">' + 
   					'<label for="q' + i + '-answers" class="control-label col-md-2">Answer:</label>' +
   					'<div class="col-md-8">' +
   				    	'<input type="text" name="q' + i + '-answers" class="form-control" placeholder="separate acceptable answers with |"/>' +
   					'</div>' +
   		    	'</div>'    
	    	);
    	} else if (q_type === "Multiple Choice") {
    		$(q_content).append(
	    		'<div class="form-group">' + 
    				'<label for="q' + i + '-question" class="control-label col-md-2">Question:</label>' +
    				'<div class="col-md-8">' +
    				    '<textarea name="q' + i + '-question" class="form-control" required></textarea>' +
    				'</div>' +
    		    '</div>' + 
    		    
    			'<div class="form-group"><div class="row">' +
		    		'<label for="q' + i + '-correct" class="control-label col-md-4">Correct Answer:</label>' + 
		    		'<div class="col-md-4" style="text-align:center">' + 
		    			'<input type="text" class="form-control" name="q' + i + '-correct" required/>' + 
		    		'</div>' +
	    		'</div></div>' +
				
				'<div class="form-group"><div class="row">' + 
	    			'<label for="q' + i + '-wrong" class="control-label col-md-4">Wrong Answers Choices:</label>' + 
	    			'<div class="col-md-4" style="text-align:center">' + 
	    				'<input type="text" class="form-control" name="q' + i + '-wrong" placeholder="Separate wrong answer choices with |" required/>' +
	    			'</div>' + 
	    		'</div></div>' 
	    	);
    	} else if (q_type === "Picture-Response Question") {
    		$(q_content).append(
        	    '<div class="form-group">' +
    				'<label for="q' + i + '-question" class="control-label col-md-2">Question:</label>' +
    				'<div class="col-md-8">' +
    				    '<textarea name="q' + i + '-question" class="form-control" required></textarea>' +
    				'</div>' +
    		    '</div>' +	
    			
				'<div class="form-group">' + 
	    			'<label for="q' + i + '-image-url" class="control-label col-md-3">Image URL:</label>' + 
	    			'<div class="col-md-6">' +
	    		    	'<input type="text" name="q' + i + '-image-url" id="q' + i + '-image-url" class="form-control" placeholder="Image URL here" oninput="reloadImage(' + i + ')" required/>' +			    		
	    			'</div>' +
	    		'</div>' + 
	    	
		    	'<div class="row form-group" style="text-align:center">' +
		    		'<label for="q' + i + '-image-preview" class="control-label col-md-3">Image preview:</label>' +
		    		'<img src="" alt="image cannot be loaded" name="q' + i + '-image-preview" id="q' + i + '-image-preview" class="col-md-6" style="max-width:100%;max-height:100%;">' +
		    	'</div>' +
		    	
    		    '<div class="form-group">' + 
   					'<label for="q' + i + '-answers" class="control-label col-md-3">Answer:</label>' +
   					'<div class="col-md-6">' +
   				    	'<input type="text" name="q' + i + '-answers" class="form-control" placeholder="separate acceptable answers with |" required/>' +
   					'</div>' +
   		    	'</div>'   
	    	);
   			reloadImage = function (i) {
   				document.getElementById('q' + i + '-image-preview').src=document.getElementById('q' + i + '-image-url').value;
   			};
    	} else if (q_type === "Multi-Answer Question") {
    		$(q_content).append(
				'<div class="form-group">' +
					'<label for="q' + i + '-question" class="control-label col-md-2">Question:</label>' +
					'<div class="col-md-8">' +
					    '<textarea name="q' + i + '-question" class="form-control" required></textarea>' +
					'</div>' +
			    '</div>' +
			    '<div class="form-group">' +
					'<label for="q' + i + '-answers" class="control-label col-md-2">Correct Answers:</label>' +
					'<div class="col-md-8">' +
				    	'<input type="text" name="q' + i + '-answers" class="form-control" placeholder="separate acceptable answers with |" required/>' +
					'</div>' +
		    	'</div>' +
		    	'<div class="form-group">' +
					'<label for="q' + i + '-num-answers" class="control-label col-md-5">Number of blanks to show (each worth a point):</label>' +
					'<div class="col-md-1">' +
				    	'<input type="number" name="q' + i + '-num-answers" class="form-control" placeholder="" required/>' +
					'</div>' +
					'<div class="col-md-1"></div>' +
					'<label class="checkbox-inline col-md-2"><input type="checkbox" name="q' + i + '-answer-order" value="true">Require answers in order</label>' +
		    	'</div>'
		    );
    	} else if (q_type === "Multiple Choice with Multiple Answers") {
    		$(q_content).append(
	    		'<div class="form-group">' + 
					'<label for="q' + i + '-question" class="control-label col-md-2">Question:</label>' +
					'<div class="col-md-8">' +
					    '<textarea name="q' + i + '-question" class="form-control" required></textarea>' +
					'</div>' +
			    '</div>' + 
			    
				'<div class="form-group"><div class="row">' +
		    		'<label for="q' + i + '-correct" class="control-label col-md-4">Correct Answers:</label>' + 
		    		'<div class="col-md-4" style="text-align:center">' + 
		    			'<input type="text" class="form-control" name="q' + i + '-correct" placeholder="Separate wrong answer choices with |" required/>' + 
		    		'</div>' +
				'</div></div>' +
				
				'<div class="form-group"><div class="row">' + 
					'<label for="q' + i + '-wrong" class="control-label col-md-4">Wrong Answers Choices:</label>' + 
					'<div class="col-md-4" style="text-align:center">' + 
						'<input type="text" class="form-control" name="q' + i + '-wrong" placeholder="Separate wrong answer choices with |" required/>' +
					'</div>' +
				'</div></div>' 
			);
    	}
    };
    </script>

</body>
</html>