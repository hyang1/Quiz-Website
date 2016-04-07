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
 * Servlet implementation class PromoteUserServlet
 */
@WebServlet("/PromoteUserServlet")
public class PromoteUserServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public PromoteUserServlet() {
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
		String userToPromote = request.getParameter("recipient");
		User currentUser = ((User)request.getSession().getAttribute("currentUser"));
		UserManager users = (UserManager)this.getServletContext().getAttribute("UserManager");
		users.promoteUserToAdmin(currentUser, userToPromote);
		request.setAttribute("message", "User promoted!");
		
		RequestDispatcher dispatcher = request.getRequestDispatcher("user_profile.jsp?username=" + userToPromote);
		dispatcher.forward(request, response);
	}

}
