package servlet;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dbconnection.UserManager;
import user.User;

/**
 * Servlet implementation class ClearQuizHistoryServlet
 */
@WebServlet("/ClearQuizHistoryServlet")
public class ClearQuizHistoryServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ClearQuizHistoryServlet() {
        super();
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		UserManager users = (UserManager) this.getServletContext().getAttribute("UserManager");
		User currentUser = (User) (request.getSession().getAttribute("currentUser"));
		String quizId = request.getParameter("quiz_id");
		if (request.getParameter("ClearQuizHistory") != null) {
			users.removeQuizHistory(currentUser, quizId);
			System.out.println("HISTORY FOR QUIZID (" + quizId + ") CLEARED");
		}
		RequestDispatcher dispatcher = request.getRequestDispatcher("quiz_summary.jsp?quiz_id=" + quizId);
		dispatcher.forward(request, response);
	}

}
