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
 * Servlet implementation class ChallengeServlet
 */
@WebServlet("/ChallengeServlet")
public class ChallengeServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ChallengeServlet() {
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
		// TODO Auto-generated method stub
		String senderUsername = ((User)request.getSession().getAttribute("currentUser")).getUsername();
		String recipientUsername = request.getParameter("recipient");
		UserManager users = (UserManager)this.getServletContext().getAttribute("UserManager");
		String quizId = request.getParameter("quiz-id");
		int score = users.getHighestScore(quizId, senderUsername);
		users.sendChallenge(senderUsername, recipientUsername, quizId, score);
		request.setAttribute("message", "Challenge sent!");
		
		RequestDispatcher dispatcher = request.getRequestDispatcher("user_profile.jsp?username=" + recipientUsername);
		dispatcher.forward(request, response);
	}

}
