package listeners;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

import dbconnection.*;

/**
 * Application Lifecycle Listener implementation class DBConnectionListener
 *
 */
@WebListener
public class DBConnectionListener implements ServletContextListener {

    /**
     * Default constructor. 
     */
    public DBConnectionListener() {
    	
    }

	/**
     * @see ServletContextListener#contextDestroyed(ServletContextEvent)
     */
    public void contextDestroyed(ServletContextEvent arg0)  { 
    	
    }

	/**
     * @see ServletContextListener#contextInitialized(ServletContextEvent)
     */
    public void contextInitialized(ServletContextEvent arg0)  { 
         DBConnection connection = new DBConnection();
         UserManager accounts = new UserManager(connection);
         QuizManager quizzes = new QuizManager(connection);
        		 
        
         ServletContext context = arg0.getServletContext();
         
         context.setAttribute("DBConnection", connection);
         context.setAttribute("UserManager", accounts);
         context.setAttribute("QuizManager", quizzes);
    }
	
}
