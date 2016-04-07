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
 * Servlet implementation class ConfirmFriendServlet
 */
@WebServlet("/ConfirmFriendServlet")
public class ConfirmFriendServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ConfirmFriendServlet() {
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
		String senderUsername = request.getParameter("sender");
		String currentUsername = ((User)request.getSession().getAttribute("currentUser")).getUsername();
		UserManager users = (UserManager)this.getServletContext().getAttribute("UserManager");
		users.acceptFriendRequest(senderUsername, currentUsername);
		
		request.setAttribute("message", "You are now friends with " + senderUsername);
		
		RequestDispatcher dispatcher = request.getRequestDispatcher("inbox.jsp");
		dispatcher.forward(request, response);
	}

}
