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
 * Servlet implementation class AcceptChallengeServlet
 */
@WebServlet("/AcceptChallengeServlet")
public class AcceptChallengeServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public AcceptChallengeServlet() {
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
		// TODO Auto-generated method stub
		String senderUsername = request.getParameter("sender");
		String currentUsername = ((User)request.getSession().getAttribute("currentUser")).getUsername();
		int score = Integer.parseInt(request.getParameter("score"));
		UserManager users = (UserManager)this.getServletContext().getAttribute("UserManager");
		users.ignoreChallenge(senderUsername, currentUsername, request.getParameter("quiz-id") + "|" + score);
		
		request.setAttribute("message", "You accepted a challenge from " + senderUsername);
		
		RequestDispatcher dispatcher = request.getRequestDispatcher("quiz_summary.jsp?quiz_id=" + request.getParameter("quiz-id"));
		dispatcher.forward(request, response);
	}

}
