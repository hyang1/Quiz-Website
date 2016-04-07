package servlet;

import java.io.IOException;
import java.util.*;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dbconnection.DBConnection;
import dbconnection.QuizManager;
import dbconnection.UserManager;
import quiz.QuestionTypes.FillInBlankQuestion;
import quiz.QuestionTypes.MultiAnswerQuestion;
import quiz.QuestionTypes.MultipleAnswerMCQuestion;
import quiz.QuestionTypes.MultipleChoiceQuestion;
import quiz.QuestionTypes.PictureResponseQuestion;
import quiz.QuestionTypes.Question;
import quiz.QuestionTypes.ResponseQuestion;
import user.HistoryItem;
import user.User;
import quiz.Quiz;
import quiz.QuizInfo;

/**
 * Servlet implementation class MainServlet
 */
@WebServlet("/CreateQuizServlet")
public class CreateQuizServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public CreateQuizServlet() {
		super();
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		QuizManager qm = (QuizManager) request.getServletContext().getAttribute("QuizManager");
		HttpSession s = request.getSession();
		if (request.getParameter("CreateQuiz") != null || request.getParameter("ReplaceQuiz")!=null) {
			ArrayList<Question> qlist = new ArrayList<Question>();
			String description = request.getParameter("quiz-description");
			String quizcategory = request.getParameter("quiz-category");
			String quizname = request.getParameter("quiz-name");
			String[] tags = request.getParameter("quiz-tags").split("\\|");
			int category = 0;
			switch (quizcategory) {
			case "Other":
				category = 0;
				break;
			case "Literature":
				category = 1;
				break;
			case "English":
				category = 2;
				break;
			case "Science":
				category = 3;
				break;
			case "Geography":
				category = 4;
				break;
			case "History":
				category = 5;
				break;
			}
			String display = request.getParameter("quiz-display");
			boolean single_page = true;
			if (display.equals("One question per page"))
				single_page = false;
			int max_num = Integer.parseInt(request.getParameter("max-questions"));
			for (int i = 1; i <= max_num; i++) {
				addQuestionToQuiz(qlist, request, i);
			}
			User currentUser = (User) s.getAttribute("currentUser");
			String username = currentUser.getUsername();
			Quiz q = new Quiz(qlist, request.getParameter("randomize-order") != null, single_page,
					request.getParameter("immediate-scoring") != null,
					request.getParameter("practice-mode-enabled") != null, description, username, category,quizname);
			int quiz_id = 0;
			if(request.getParameter("CreateQuiz")!=null) {
				quiz_id = qm.addQuiz(q);
				UserManager accounts = (UserManager) this.getServletContext().getAttribute("UserManager");
				accounts.quizMade(currentUser, String.valueOf(quiz_id));
				for(String tag: tags) {
					qm.addTag(quiz_id, tag);
				}
			} else if(request.getParameter("ReplaceQuiz")!=null) {
				quiz_id = Integer.parseInt(request.getParameter("quiz_id"));
				qm.replaceQuiz(quiz_id, q);
				for(String tag: tags) {
					qm.addTag(quiz_id, tag);
				}
			}
			RequestDispatcher dispatcher = request.getRequestDispatcher("quiz_summary.jsp?quiz_id=" + quiz_id);
			dispatcher.forward(request, response);
		}
	}

	/**
	 * Constructs and adds the questions to the question list which will be used to build the quiz object.
	 * @param qlist
	 * @param request
	 * @param index
	 */
	public void addQuestionToQuiz(ArrayList<Question> qlist, HttpServletRequest request, int index) {
		if (request.getParameter("q" + index + "-question") == null)
			return;
		String questiontype = request.getParameter("q" + index + "-type");
		if (questiontype.equals("Question-Response")||questiontype.equals("0")) {
			String questionstr = request.getParameter("q" + index + "-question");
			String[] answer = request.getParameter("q" + index + "-answers").split("\\|");
			ArrayList<String> answers = new ArrayList<String>(Arrays.asList(answer));
			ResponseQuestion que = new ResponseQuestion(questionstr, answers);
			qlist.add(que);
		} else if (questiontype.equals("Fill in the Blank")||questiontype.equals("1")) {
			String questionstr = request.getParameter("q" + index + "-question");
			int divider = questionstr.indexOf("____");
			String part1 = questionstr.substring(0, divider);
			String part2 = questionstr.substring(divider + 4);
			String[] answer = request.getParameter("q" + index + "-answers").split("\\|");
			ArrayList<String> answers = new ArrayList<String>(Arrays.asList(answer));
			FillInBlankQuestion que = new FillInBlankQuestion(part1, part2, answers);
			qlist.add(que);
		} else if (questiontype.equals("Multiple Choice")||questiontype.equals("2")) {
			String questionstr = request.getParameter("q" + index + "-question");
			String[] correctanswer = request.getParameterValues("q" + index + "-correct");
			String[] wronganswer = request.getParameter("q" + index + "-wrong").split("\\|");
			ArrayList<String> correctanswers = new ArrayList<String>(Arrays.asList(correctanswer));
			ArrayList<String> choices = new ArrayList<String>(Arrays.asList(wronganswer));
			choices.addAll(correctanswers);
			MultipleChoiceQuestion que = new MultipleChoiceQuestion(questionstr, choices, correctanswers);
			qlist.add(que);
		} else if (questiontype.equals("Picture-Response Question")||questiontype.equals("3")) {
			String questionstr = request.getParameter("q" + index + "-question");
			String url = request.getParameter("q" + index + "-image-url");
			String[] answer = request.getParameter("q" + index + "-answers").split("\\|");
			ArrayList<String> answers = new ArrayList<String>(Arrays.asList(answer));
			PictureResponseQuestion que = new PictureResponseQuestion(questionstr, url, answers);
			qlist.add(que);
		} else if(questiontype.equals("Multi-Answer Question")||questiontype.equals("4")) {
			String questionstr = request.getParameter("q" + index + "-question");
			String[] answer = request.getParameter("q" + index + "-answers").split("\\|");
			ArrayList<String> answers = new ArrayList<String>(Arrays.asList(answer));
			int answernum = Integer.parseInt(request.getParameter("q"+index+"-num-answers"));
		    boolean inorder = (request.getParameter("q"+index+"-answer-order")!=null);
		    MultiAnswerQuestion que = new MultiAnswerQuestion(questionstr,answers,inorder,answernum);
		    qlist.add(que);
		} else if(questiontype.equals("Multiple Choice with Multiple Answers")||questiontype.equals("5")) {
			String questionstr = request.getParameter("q" + index + "-question");
			String[] correctanswer = request.getParameter("q"+index+"-correct").split("\\|");
			String[] wronganswer = request.getParameter("q"+index+"-wrong").split("\\|");
			ArrayList<String> correctanswers = new ArrayList<String>(Arrays.asList(correctanswer));
			ArrayList<String> choices = new ArrayList<String>(Arrays.asList(wronganswer));
			choices.addAll(correctanswers);
			MultipleAnswerMCQuestion que = new MultipleAnswerMCQuestion(questionstr,choices,correctanswers);
			qlist.add(que);
		}
	}

}
