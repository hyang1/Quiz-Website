package servlet;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dbconnection.UserManager;
import user.User;

/**
 * Servlet implementation class RegisterServlet
 */
@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public RegisterServlet() {
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
		UserManager accounts = (UserManager) this.getServletContext().getAttribute("UserManager");
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		String confirmPassword = request.getParameter("confirm-password");
		String nextPage;
		if (username.length() == 0 || password.length() == 0 || confirmPassword.length() == 0) {
			request.setAttribute("registerError", "Please fill in all fields.");
			nextPage = "login_homepage.jsp";
		}  else if (!password.equals(confirmPassword)){
			request.setAttribute("registerError", "Passwords do not match. Try again.");
			nextPage = "login_homepage.jsp";
		} else if (accounts.accountExists(username)) {
			request.setAttribute("registerError", "Username already taken. Try again.");
			nextPage = "login_homepage.jsp";
		} else {
			String encryptedPassword = UserManager.saltAndEncryptPassword(password);
			accounts.createAccount(username, encryptedPassword);
			User currentUser = accounts.getUser(username, encryptedPassword);
			request.getSession().setAttribute("currentUser", currentUser);
			
			Cookie username_cookie = new Cookie("username", username);
			Cookie login_cookie = new Cookie("encryptedPassword", UserManager.saltAndEncryptPassword(password));
			username_cookie.setMaxAge(60 * 60 * 24);
			login_cookie.setMaxAge(60 * 60 * 24); // user automatically logged out after 24 hours
			response.addCookie(username_cookie);
			response.addCookie(login_cookie);
			
			nextPage = "user_homepage.jsp";
		}
		RequestDispatcher dispatcher = request.getRequestDispatcher(nextPage);
		dispatcher.forward(request, response);
	}

}
