package servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dbconnection.QuizManager;
import dbconnection.UserManager;
import quiz.Quiz;
import quiz.QuizInfo;
import quiz.QuestionTypes.*;
import user.User;

/**
 * Servlet implementation class StartQuizServlet
 */
@WebServlet("/TakeQuizServlet")
public class TakeQuizServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public TakeQuizServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		QuizManager qm = (QuizManager) request.getServletContext().getAttribute("QuizManager");
		HttpSession session = request.getSession();

		String nextPage = null;		
		
		/* starting quiz from beginning */
		if (request.getParameter("StartQuiz") != null) {
			String quiz_id = request.getParameter("quiz_id");
			Quiz currentQuiz = qm.getQuiz(Integer.valueOf(quiz_id));
			if(currentQuiz.isRandomized())
				currentQuiz.randomizeQuestions();
			session.setAttribute("currentQuizID", quiz_id);
			session.setAttribute("currentQuiz", currentQuiz);
			
			// starting practice mode
			if (request.getParameter("PracticeMode") != null) {
				session.setAttribute("practiceMode", "true");
				session.removeAttribute("practiceModeDone");
				session.removeAttribute("correctCounts");
				int[] correctCounts = new int[currentQuiz.getLength()];
				for (int i = 0; i < currentQuiz.getLength(); i++) {
					correctCounts[i] = 0;
				}
				session.setAttribute("correctCounts", correctCounts);
			}
			
			// one question at a time 
			if (!currentQuiz.isSinglePage()) {
				session.setAttribute("questionIndex", new Integer(0));
				if (currentQuiz.isImmediateCorrection()) {
					session.setAttribute("cumulativeScore", new Integer(0));
				}
			}
			
			session.setAttribute("userAnswers", new ArrayList<String>());
			session.setAttribute("scoreBoard", new int[currentQuiz.getLength()]);
			session.removeAttribute("prevQuestionFeedback");
			session.setAttribute("startTime", new Long(System.currentTimeMillis()));
			nextPage = "answer_question.jsp";
		}
		
		/* Continuing from previous question */
		else if (request.getParameter("NextQuestion") != null) {
			Quiz currentQuiz = (Quiz)session.getAttribute("currentQuiz");
			ArrayList<String> userAnswers = (ArrayList<String>)session.getAttribute("userAnswers");
			int prevQuestionIndex = (int)session.getAttribute("questionIndex");
			String answersToPrevQuestion = getAnswersString(request, currentQuiz, prevQuestionIndex);
			userAnswers.add(answersToPrevQuestion);
			
			// get corrections immediately
			if (currentQuiz.isImmediateCorrection()) {
				int scoreOnPrevQuestion = scoreAnswersToQuestion(currentQuiz, answersToPrevQuestion, prevQuestionIndex);
				session.setAttribute("prevQuestionFeedback", "You scored " + scoreOnPrevQuestion + " on the previous question.");
			}
			
			session.setAttribute("questionIndex", new Integer(prevQuestionIndex + 1));
			nextPage = "answer_question.jsp";
		}
		
		/* Finishing quiz and submitting scores */
		else if (request.getParameter("FinishQuiz") != null) {
			Quiz currentQuiz = (Quiz)session.getAttribute("currentQuiz");
			ArrayList<String> userAnswers = (ArrayList<String>)session.getAttribute("userAnswers");
			
			// if last question, add to answers board
			if (!currentQuiz.isSinglePage()) {
				int prevQuestionIndex = (int)session.getAttribute("questionIndex");
				String answersStr = getAnswersString(request, currentQuiz, prevQuestionIndex);
				userAnswers.add(answersStr);
				
				// get score to display if immediate
				if (currentQuiz.isImmediateCorrection()) {
					int scoreOnPrevQuestion = scoreAnswersToQuestion(currentQuiz, answersStr, prevQuestionIndex);
					session.setAttribute("prevQuestionFeedback", "You scored " + scoreOnPrevQuestion + " on the previous question. Full results for all questions below:");
				}
				session.setAttribute("questionIndex", new Integer(prevQuestionIndex + 1));
			} 
			
			// if everything on one page, populate answers board
			else {
				for (int index = 0; index < currentQuiz.getLength(); index++) {
					userAnswers.add(getAnswersString(request, currentQuiz, index));
				}
			}

			// score based on answers board
			int[] scoreBoard = (int[])session.getAttribute("scoreBoard");
			int score = scoreAnswersToQuiz(currentQuiz, userAnswers, scoreBoard);
			session.setAttribute("score", score);
			
			// if not practice mode, save history item
			if (session.getAttribute("practiceMode") == null) {
				UserManager accounts = (UserManager) request.getServletContext().getAttribute("UserManager");
				accounts.quizTaken((User)session.getAttribute("currentUser"), 
						           (String)session.getAttribute("currentQuizID"), 
						           ((Long)session.getAttribute("startTime")).longValue(), 
						           score);
			}
			
			// if practice mode, add achievement + check to see if any questions have been answered 
			// correctly 3 times and exits practice mode if true
			else {
				// add achievement for taking a quiz in practice mode
				UserManager accounts = (UserManager) request.getServletContext().getAttribute("UserManager");
				User currentUser = (User)session.getAttribute("currentUser");
				accounts.awardPracticeModeAchievement(currentUser);
				
				// gets updates correctCounts and checks if any questions were answered right 3 times
				int[] correctCounts = (int[])session.getAttribute("correctCounts");
				for (int index = 0; index < currentQuiz.getLength(); index++) {
					int maxScore = maxScoreForQuestion(currentQuiz, index);
					if (scoreBoard[index] == maxScore) {
						correctCounts[index] += 1;
					}
					if (correctCounts[index] >= 3) {
						session.setAttribute("practiceModeDone", "true");
						session.removeAttribute("practiceMode");
						session.removeAttribute("correctCounts");
					}
				}
			}
			
			nextPage = "quiz_results.jsp";

		} 
		
		/* Quitting practice mode - request.getParameter("LeavePracticeMode") != null */
		else {
			session.removeAttribute("practiceMode");
			session.removeAttribute("practiceModeDone");
			session.removeAttribute("correctCounts");
			nextPage = "quiz_summary.jsp?quiz_id=" + session.getAttribute("currentQuizID");
		}
		RequestDispatcher dispatcher = request.getRequestDispatcher(nextPage);
		dispatcher.forward(request, response);
	}
	
	/** 
	 * Returns "|" delimited String of answers entered by the user for a particular question
	 * of the current quiz
	 * @param request
	 * @param currentQuiz
	 * @param index
	 * @return
	 */
	public String getAnswersString(HttpServletRequest request, Quiz currentQuiz, int index) {
		int qType = currentQuiz.getQuestion(index).getType();
		if (qType == QuizInfo.MULTIPLE_CHOICE && request.getParameter("q" + (index + 1) + "-answer") == null) {
			return "";
		}
		if(qType == QuizInfo.QUESTION_RESPONSE || qType == QuizInfo.FILL_IN_THE_BLANK || 
		   qType == QuizInfo.MULTIPLE_CHOICE || qType == QuizInfo.PICTURE_RESPONSE_QUESTIONS) {
			return request.getParameter("q" + (index + 1) + "-answer");
		}
		String str = "";
		if (qType == QuizInfo.MULTI_ANSWER) {
			MultiAnswerQuestion question = (MultiAnswerQuestion)currentQuiz.getQuestion(index);
			for (int q = 1; q <= question.getAnswerNumber(); q++) {
				str += "|" + request.getParameter("q" + (index + 1) + "-answer" + q);
			}
		} else if (qType == QuizInfo.MULTIPLE_ANSWER_MC) {
			MultipleAnswerMCQuestion question = (MultipleAnswerMCQuestion)currentQuiz.getQuestion(index);
			for (String answer : question.getChoices()) {
				if (request.getParameter("q" + (index + 1) + "-answer-" + answer) != null) {
					str += "|" + answer;
				}
			}
		}
		if (str.length() > 0){
			str = str.substring(1);
		}
		return str;
	}
	
	/**
	 * Returns the maximum possible score one can get from a particular question
	 * @param currentQuiz
	 * @param index
	 * @return
	 */
	public int maxScoreForQuestion(Quiz currentQuiz, int index) {
		int qType = currentQuiz.getQuestion(index).getType();
		if (qType == QuizInfo.MULTI_ANSWER) {
			MultiAnswerQuestion question = (MultiAnswerQuestion)currentQuiz.getQuestion(index);
			return question.getAnswerNumber();
		}
		if (qType == QuizInfo.MULTIPLE_ANSWER_MC) {
			MultipleAnswerMCQuestion question = (MultipleAnswerMCQuestion)currentQuiz.getQuestion(index);
			return question.getAnswers().size();
		}
		return 1;
	}

	/**
	 * Given user's answer delimited with "|", returns the score that should be credited
	 * @param quiz
	 * @param userAnswer
	 * @param index
	 * @return
	 */
	public int scoreAnswersToQuestion(Quiz quiz, String userAnswer, int index) {
		Question currentQuestion = quiz.getQuestion(index);
		String[] answers = userAnswer.split("\\|");
		return currentQuestion.getCorrectNum(answers);
	}

	/**
	 * Given user's answers to every question, updates the score board and returns the total score credited
	 * @param quiz
	 * @param userAnswers
	 * @param scoreBoard
	 * @return
	 */
	public int scoreAnswersToQuiz(Quiz quiz, ArrayList<String> userAnswers, int[] scoreBoard) {
		int score = 0;
		for (int index = 0; index < userAnswers.size(); index++) {
			int correctNum = scoreAnswersToQuestion(quiz, userAnswers.get(index), index);
			scoreBoard[index] = correctNum;
			score += correctNum;
		}
		return score;
	}


	public static String formQuizResult(Question que, int i, String useranswer, int score, boolean showAnswers) {
		StringBuilder sb = new StringBuilder();
		int type = que.getType();
		String qType = null;			
		if (que.getType() == 0) qType = "Question-Response";
		else if (que.getType() == 1) qType = "Fill in the Blank";
		else if (que.getType() == 2) qType = "Multiple Choice"; 
		else if (que.getType() == 3) qType = "Picture-Response";
		else if (que.getType() == 4) qType = "Multi-Answer";
		else if (que.getType() == 5) qType = "Multiple Choice with Multiple Answers";
		sb.append(
			"<div class=\"q" + i + "-content well\">" + 
				"<h4 align=\"center\">Question " + i + " - " + qType + "</h4>" + 
				"<hr>"
		);
		ArrayList<String> answers = que.getAnswers();
		ArrayList<String> useranswers = new ArrayList(Arrays.asList(useranswer.split("\\|")));
		
		if(type == QuizInfo.QUESTION_RESPONSE) {
			ResponseQuestion q = (ResponseQuestion)que;
			sb.append(
				"<div class=\"form-group row\" style=\"vertical-align: middle\">" + 
    				"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Question:</label>" +
    				"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + q.getQuestion() + "</p>" +
    		    "</div>" +
				"<div class=\"form-group row\" style=\"vertical-align: middle\">" + 
					"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Your Answer:</label>" +
					"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + useranswer + "</p>" +
				"</div>"
			);
			if (showAnswers) {
				sb.append(
					"<div class=\"form-group row\" style=\"vertical-align: middle\">" + 
    					"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Correct Answers (comma-separated):</label>" +
    					"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + String.join(",", answers) + "</p>" +
    				"</div>"
				);
			}
		} else if(type == QuizInfo.FILL_IN_THE_BLANK) {
			FillInBlankQuestion q = (FillInBlankQuestion)que;
			sb.append(
				"<div class=\"form-group row\" style=\"vertical-align: middle\">" + 
					"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Question:</label>" +
					"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + 
						q.getPart1() + "____" + q.getPart2() + "</p>" +
				"</div>" + 	
					"<div class=\"form-group row\" style=\"vertical-align: middle\">" + 
					"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Your Answer:</label>" +
					"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + useranswer + "</p>" +
				"</div>"
			);
			if (showAnswers) {
				sb.append(
					"<div class=\"form-group row\" style=\"vertical-align: middle\">" + 
    					"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Correct Answers (comma-separated):</label>" +
    					"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + String.join(",", answers) + "</p>" +
    				"</div>"
				);
			}
		} else if(type == QuizInfo.MULTIPLE_CHOICE) {
			MultipleChoiceQuestion q = (MultipleChoiceQuestion) que;
			sb.append(
				"<div class=\"form-group row\" style=\"vertical-align: middle\">" + 
	    			"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Question:</label>" +
	    			"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + q.getQuestion() + "</p>" +
				"</div>" + 
	    		"<div class=\"form-group row\">" + 
    				"<div class=\"col-md-3\" style=\"text-align:right\">"  +
    					"<label for=\"q" + i + "-user-answer\" class=\"control-label\">Your answers:</label>" +
    				"</div>" +
    				"<div class=\"col-md-6\" style=\"text-align:left\">"
	    	);
			ArrayList<String> choices = q.getChoices();
			for (int c = 0; c < choices.size(); c++) {
				sb.append(
					"<div class=\"radio\">" + 
						"<label style=\"word-wrap:break-word\"><input type=\"radio\" name=\"q" + i + "-answer\" value=\"" + choices.get(c) + "\" disabled"
				);
				if (useranswers.contains(choices.get(c))) {
					sb.append(" checked=\"checked\"");
				}
				sb.append(
						">" + choices.get(c) + "</label>" + 
					"</div>"
				);
			}
			sb.append("</div></div>");
			if (showAnswers) {
				sb.append(
		    		"<div class=\"form-group row\">" + 
	    				"<div class=\"col-md-3\" style=\"text-align:right\">"  +
	    					"<label for=\"q" + i + "-answers\" class=\"control-label\">Correct Answer:</label>" +
	    				"</div>" +
	    				"<div class=\"col-md-6\">" +
	    					"<label name=for=\"q" + i + "-answers\">" + q.getAnswer() + "</label>" +
	    				"</div>" +
	    			"</div>"
				);
			}
		} else if(type == QuizInfo.PICTURE_RESPONSE_QUESTIONS) {
			PictureResponseQuestion q = (PictureResponseQuestion)que;
			sb.append(
				"<div class=\"form-group row\">" + 
	    			"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Question:</label>" +
	    			"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + q.getQuestion() + "</p>" +
				"</div>" + 
		    	"<div class=\"row form-group\" style=\"text-align:center\">" +
	    			"<label for=\"q" + i + "-image-preview\" class=\"control-label col-md-3\"></label>" +
	    			"<img src=\"" + q.getURL() + "\" alt=\"image cannot be loaded\" name=\"q"+ i + "-image-preview\" id=\"q" + i + "-image-preview\" class=\"col-md-6\" style=\"max-width:100%;max-height:100%;\">" +
				"</div>" +
				"<div>" + 	
					"<div class=\"form-group row\" style=\"vertical-align: middle\">" + 
						"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Your Answer:</label>" +
						"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + useranswer + "</p>" +
					"</div>" +
				"</div>"
	    	);
			if (showAnswers) {
				sb.append(
					"<div class=\"form-group row\" style=\"vertical-align: middle\">" + 
    					"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Correct Answers (comma-separated):</label>" +
    					"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + String.join(",", answers) + "</p>" +
    				"</div>"
				);
			}
		} else if(type == QuizInfo.MULTI_ANSWER) {
			MultiAnswerQuestion q = (MultiAnswerQuestion)que;
			
			sb.append(
				"<div class=\"form-group row\" style=\"vertical-align: middle\">" + 
					"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Question:</label>" +
					"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + q.getQuestion() + "</p>" +
				"</div>" +
				"<div>" + 	
					"<div class=\"form-group row\" style=\"vertical-align: middle\">" + 
						"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Your Answers:</label>" +
						"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + String.join(",", useranswer.split("\\|")) + "</p>" +
					"</div>" + 
				"</div>"
			);
			if (showAnswers) {
				String inorder = "";
				if (q.isInorder()) {
					inorder = " must be in order";
				}
				sb.append(
					"<div class=\"form-group row\" style=\"vertical-align: middle\">" + 
    					"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Correct Answers (comma-separated)" + inorder + ":</label>" +
    					"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + String.join(",", answers) + "</p>" +
    				"</div>"
				);
			}
		} else if(type == QuizInfo.MULTIPLE_ANSWER_MC) {
			MultipleAnswerMCQuestion q = (MultipleAnswerMCQuestion)que;
			sb.append(
				"<div class=\"form-group row\" style=\"vertical-align: middle\">" + 
	    			"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Question:</label>" +
	    			"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + q.getQuestion() + "</p>" +
				"</div>" +
	    		"<div class=\"form-group row\">" + 
					"<div class=\"col-md-3\" style=\"text-align:right\">"  +
						"<label for=\"q" + i + "-user-answer\" class=\"control-label\">Your answers:</label>" +
					"</div>" +
					"<div class=\"col-md-6\">"
	    	);
			ArrayList<String> choices = q.getChoices();
			for (int c = 0; c < choices.size(); c++) {
				sb.append(
					"<div class=\"row\">" + 
						  "<label style=\"word-wrap:break-word\"><input type=\"checkbox\" name=\"q" + i + "-answer-" + choices.get(c) + "\"" + choices.get(c) + "\" disabled"
				);
				if (useranswers.contains(choices.get(c))) {
					sb.append(" checked");
				}
				sb.append(
					"> " + choices.get(c) + "</label>" + 
					"</div>"
				);
			}
			sb.append("</div></div>");
			if (showAnswers) {
				sb.append(
					"<div class=\"form-group row\" style=\"vertical-align: middle\">" + 
    					"<label for=\"q" + i + "-question\" class=\"control-label col-md-3\">Correct Answers (comma-separated):</label>" +
    					"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + String.join(",", answers) + "</p>" +
    				"</div>"
				);
			}

		}
		sb.append("<hr><p style=\"color:red\" align=\"center\">Your score: " + score + "</p></div>");
		return sb.toString();
	}
	
	
	/**
	 * Generates the code to build the answer-question page with textboxes and checkboxes corresponding to each question type
	 * @param que
	 * @param i
	 * @return
	 */
	public static String formQuestion(Question que, int i) {
		StringBuilder sb = new StringBuilder();
		int type = que.getType();
		String qType = null;			
		if (que.getType() == 0) qType = "Question-Response";
		else if (que.getType() == 1) qType = "Fill in the Blank";
		else if (que.getType() == 2) qType = "Multiple Choice"; 
		else if (que.getType() == 3) qType = "Picture-Response";
		else if (que.getType() == 4) qType = "Multi-Answer";
		else if (que.getType() == 5) qType = "Multiple Choice with Multiple Answers";
		sb.append(
			"<div class=\"q" + i + "-content well\">" + 
				"<h4 align=\"center\">Question " + i + " - " + qType + "</h4>" + 
				"<hr>"
		);
		if(type == QuizInfo.QUESTION_RESPONSE) {
			ResponseQuestion q = (ResponseQuestion)que;
			sb.append(
				"<div class=\"form-group row\" style=\"vertical-align: middle\">" + 
    				"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Question:</label>" +
    				"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + q.getQuestion() + "</p>" +
    		    "</div>" + 
    		    "<div class=\"form-group row\">" + 
   					"<label for=\"q" + i + "-answer\" class=\"control-label col-md-2\">Answer:</label>" +
   					"<div class=\"col-md-8\">" +
   				    	"<input type=\"text\" name=\"q" + i + "-answer\" class=\"form-control\" placeholder=\"answer\" required/>" +
   					"</div>" +
   		    	"</div>"    
			);
		} else if(type == QuizInfo.FILL_IN_THE_BLANK) {
			FillInBlankQuestion q = (FillInBlankQuestion)que;
			sb.append(
				"<div class=\"form-group row\" style=\"vertical-align: middle\">" + 
					"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Question:</label>" +
					"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + 
						q.getPart1() + "____" + q.getPart2() + "</p>" +
				"</div>" + 
				"<div class=\"form-group row\">" + 
					"<label for=\"q" + i + "-answer\" class=\"control-label col-md-2\">Answer:</label>" +
					"<div class=\"col-md-8\">" +
				    	"<input type=\"text\" name=\"q" + i + "-answer\" class=\"form-control\" placeholder=\"answer\" required/>" +
					"</div>" +
		    	"</div>"
			);
		} else if(type == QuizInfo.MULTIPLE_CHOICE) {
			MultipleChoiceQuestion q = (MultipleChoiceQuestion) que;
			sb.append(
				"<div class=\"form-group row\" style=\"vertical-align: middle\">" + 
	    			"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Question:</label>" +
	    			"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + q.getQuestion() + "</p>" +
				"</div>" +
	    		"<div class=\"form-group row\">" + 
	    			"<div class=\"col-md-3\"></div>" +
	    			"<div class=\"col-md-6\">"
	    	);
			ArrayList<String> choices = q.getChoices();
			for (int c = 0; c < choices.size(); c++) {
				sb.append(
					"<div class=\"radio\">" + 
						  "<label style=\"word-wrap:break-word\"><input type=\"radio\" name=\"q" + i + "-answer\" value=\"" + choices.get(c) + "\">" + choices.get(c) + "</label>" + 
					"</div>"
				);
			}
			sb.append("</div></div>");
		} else if(type == QuizInfo.PICTURE_RESPONSE_QUESTIONS) {
			PictureResponseQuestion q = (PictureResponseQuestion)que;
			sb.append(
				"<div class=\"form-group row\">" + 
	    			"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Question:</label>" +
	    			"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + q.getQuestion() + "</p>" +
				"</div>" + 
		    	"<div class=\"row form-group\" style=\"text-align:center\">" +
	    			"<label for=\"q" + i + "-image-preview\" class=\"control-label col-md-3\"></label>" +
	    			"<img src=\"" + q.getURL() + "\" alt=\"image cannot be loaded\" name=\"q"+ i + "-image-preview\" id=\"q" + i + "-image-preview\" class=\"col-md-6\" style=\"max-width:100%;max-height:100%;\">" +
				"</div>" +
				"<div class=\"form-group row\">" + 
					"<label for=\"q" + i + "-answer\" class=\"control-label col-md-2\">Answer:</label>" +
					"<div class=\"col-md-8\">" +
			    		"<input type=\"text\" name=\"q" + i + "-answer\" class=\"form-control\" placeholder=\"answer\" required/>" +
			    	"</div>" +
			    "</div>"
			);
		} else if(type == QuizInfo.MULTI_ANSWER) {
			MultiAnswerQuestion q = (MultiAnswerQuestion)que;
			
			sb.append(
				"<div class=\"form-group row\" style=\"vertical-align: middle\">" + 
					"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Question:</label>" +
					"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + q.getQuestion() + "</p>" +
				"</div>" +
				"<div class=\"form-group row\">" + 
					"<div class=\"col-md-3\"></div>" +
					"<div class=\"col-md-6\">"
			);
			if (q.isInorder()) {
				sb.append("<h5 align=\"center\">Answers must be in correct order</h5>");
			}
			for (int c = 0; c < q.getAnswerNumber(); c++) {
				sb.append(
					"<div class=\"row form-group\">" +
						"<label for=\"q" + i + "-answer" + (c + 1) + "\" class=\"control-label col-md-3\">Answer " + (c + 1) + ":</label>" +
						"<div class=\"col-md-8\">" +	
							"<input type=\"text\" name=\"q" + i + "-answer" + (c + 1) + "\" class=\"form-control\" placeholder=\"answer " + (c + 1) + "\" required/>" +
						"</div>" +
					"</div>"
				);
			}
			sb.append("</div></div>");
		} else if(type == QuizInfo.MULTIPLE_ANSWER_MC) {
			MultipleAnswerMCQuestion q = (MultipleAnswerMCQuestion)que;
			sb.append(
				"<div class=\"form-group row\" style=\"vertical-align: middle\">" + 
	    			"<label for=\"q" + i + "-question\" class=\"control-label col-md-2\">Question:</label>" +
	    			"<p name=\"q" + i + "-question\" class=\"col-md-8\" style=\"word-wrap:break-word\">" + q.getQuestion() + "</p>" +
				"</div>" +
	    		"<div class=\"form-group row\">" + 
	    			"<div class=\"col-md-3\"></div>" +
	    			"<div class=\"col-md-6\">"
	    	);
			sb.append("<h5 align=\"center\">Select all correct answers (one point is deducted for each wrong answer)</h5>");
			ArrayList<String> choices = q.getChoices();
			for (int c = 0; c < choices.size(); c++) {
				sb.append(
					"<div class=\"row\">" + 
						  "<label style=\"word-wrap:break-word\"><input type=\"checkbox\" name=\"q" + i + "-answer-" + choices.get(c) + "\"" + choices.get(c) + "\"> " + choices.get(c) + "</label>" + 
					"</div>"
				);
			}
			sb.append("</div></div>");
		}
		sb.append("</div>");
		return sb.toString();
	}
}
