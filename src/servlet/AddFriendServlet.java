package servlet;

import java.io.IOException;
import java.util.Enumeration;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dbconnection.UserManager;
import user.User;

/**
 * Servlet implementation class AddFriendServlet
 */
@WebServlet("/AddFriendServlet")
public class AddFriendServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public AddFriendServlet() {
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
		String usernameToFriend = request.getParameter("recipient");
		String currentUsername = ((User)request.getSession().getAttribute("currentUser")).getUsername();
		UserManager users = (UserManager)this.getServletContext().getAttribute("UserManager");
		if (!users.isFriends(currentUsername, usernameToFriend)) {
			if (users.checkForMessageSent(currentUsername, usernameToFriend, 0)) {
				request.setAttribute("message", "You already sent a friend request");
			} else if (users.checkForMessageSent(usernameToFriend, currentUsername, 0)) {
				request.setAttribute("message", usernameToFriend + " already sent a friend request");
			} else {
				users.sendFriendRequest(currentUsername, usernameToFriend);
				request.setAttribute("message", "Friend request sent");
			}
		} else {
			request.setAttribute("message", "You and " + usernameToFriend + " are already friends");
		}
		
		RequestDispatcher dispatcher = request.getRequestDispatcher("user_profile.jsp?username=" + usernameToFriend);
		dispatcher.forward(request, response);
	}

}
