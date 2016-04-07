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
 * Servlet implementation class MessageServlet
 */
@WebServlet("/MessageServlet")
public class MessageServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public MessageServlet() {
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
		String senderUsername = ((User)request.getSession().getAttribute("currentUser")).getUsername();
		String recipientUsername = request.getParameter("recipient");
		String messageBody = request.getParameter("message-body");
		UserManager users = (UserManager)this.getServletContext().getAttribute("UserManager");
		users.sendNote(senderUsername, recipientUsername, messageBody);
		
		String sourcePage = request.getParameter("source");
		String nextPage;
		if (sourcePage.equals("inbox")) {
			nextPage = "inbox.jsp";
		} else if (sourcePage.equals(senderUsername)) {
			nextPage = "user_profile.jsp";
			request.setAttribute("message", "Announcement made!");
		} else {
			nextPage = "user_profile.jsp?username=" + recipientUsername;
			request.setAttribute("message", "Message sent!");
		}
		
		RequestDispatcher dispatcher = request.getRequestDispatcher(nextPage);
		dispatcher.forward(request, response);
	}

}
