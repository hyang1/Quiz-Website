package servlet;

import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
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
@WebServlet("/SearchServlet")
public class SearchServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public SearchServlet() {
		super();
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
				
		if (request.getParameter("search-category").equals("Users")) {
			UserManager um = (UserManager) request.getServletContext().getAttribute("UserManager");
			String pattern = request.getParameter("search-query");
			ArrayList<User> userResults = um.search(pattern);
			request.setAttribute("SearchResultsUsers", userResults);
		} else if (request.getParameter("search-category").equals("Quizzes")) {
			QuizManager qm = (QuizManager) request.getServletContext().getAttribute("QuizManager");
			String field = request.getParameter("search-field");
			String query = request.getParameter("search-query");
			ResultSet quizRs;
			if (field.equals("Name")) {
				quizRs = qm.getQuizByName(query);
				
			} else if (field.equals("Category")) {
				int category = Integer.parseInt(request.getParameter("category-field"));
				quizRs = qm.getQuizByCategory(category);
			} else if (field.equals("Tag")) {
				quizRs = qm.getQuizByTag(query);
			} else {
				quizRs = null;
			}
			
			ArrayList<Integer> quizIds = new ArrayList<Integer>();
			ArrayList<String> quizNames = new ArrayList<String>();
			
			try {
				while (quizRs.next()) {
					int quizId = quizRs.getInt("quizid");
					String quizName;
					if (field.equals("Name") || field.equals("Category")) {
						quizName = quizRs.getString("quizname");
					} else {
						quizName = quizRs.getString("tag");
					}
					quizIds.add(quizId);
					quizNames.add(quizName);
				}
			} catch (SQLException e) {
				e.printStackTrace();
			}
			
			request.setAttribute("SearchResultsQuizIds", quizIds);
			request.setAttribute("SearchResultsQuizNames", quizNames);
		}
		
		RequestDispatcher dispatcher = request.getRequestDispatcher("search.jsp");
		dispatcher.forward(request, response);
		
	}

}





