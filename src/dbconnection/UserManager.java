package dbconnection;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.*;

import user.Message;
import user.User;
import user.HistoryItem;


public class UserManager {

	private DBConnection connection;
	private static MessageDigest md;

	public UserManager(DBConnection connection) {
		this.connection = connection;
		try {
			md = MessageDigest.getInstance("SHA");
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}
	}
	
	
	/** Returns true if an account with the given username exists, false otherwise.
	 * @param username - username of account
	 * @return 
	 */
	public boolean accountExists(String username) {
		return connection.accountExists(username);
	}
	
	/**
	 * Returns a user given their username and encryptedPassword
	 * @param username
	 * @param password
	 * @return a User instance if the username and password
	 * are valid; null otherwise.
	 */
	public User getUser(String username, String encryptedPassword) {
		if (!connection.authenticateUser(username, encryptedPassword)) return null;
		return connection.getUser(username, false);
	}
	
	/**
	 * Returns a user given their username.
	 * @param username
	 * @return
	 */
	public User getUserPublicInfo(String username) {
		return connection.getUser(username, true);
	}
	
	/**
	 * Attempts to create a new account with the given username/encrypted password.
	 * Returns true on success, false if an account already exists with that username.
	 * @param username
	 * @param password
	 * @return
	 */
	public boolean createAccount(String username, String encryptedPassword) {
		if (accountExists(username)) {
			return false;
		}
		connection.addUser(new User(username, encryptedPassword));
		return true;
	}
	
	// Initialization of Message:
	
	/**
	 * Returns true if a friend request has been sent
	 * @param user
	 * @param recipient
	 */
	public boolean friendRequestSent(String user, String recipient) {
		return connection.friendRequestSent(user, recipient);
	}
	
	/**
	 * Returns true if two users are friends
	 * @param user
	 * @param friend
	 * @return
	 */
	public boolean isFriends(String user, String friend) {
		return connection.isFriends(user, friend);
	}
	
	/**
	 * Checks if the user has sent a message to the recipient of a given type
	 * @param user
	 * @param recipient
	 * @param type
	 * @return
	 */
	public boolean checkForMessageSent(String user, String recipient, int type) {
		return connection.checkForMessage(user, recipient, type);
	}
	
	/**
	 * Given a username and a recipient, this method
	 * sends a friend request to the recipient
	 * @param user
	 * @param recipient
	 */
	public void sendFriendRequest(String user, String recipient) {
		connection.sendMessage(user, recipient, 0, "");
	}
	
	/**
	 * Given a username, recipient, and challenge info, 
	 * this method sends a challenge to the recipient with the 
	 * appropriate challenge information.
	 * @param user
	 * @param recipient
	 * @param challengeInfo a string that is delimited by the |
	 * symbol. It consists of the quizId and the score that a user
	 * would like the challenge's recipient to use/compete against.
	 */
	public void sendChallenge(String user, String recipient, String quizId, int score) {
		connection.sendMessage(user, recipient, 1, quizId + "|" + score);
	}
	
	/**
	 * Given a username, recipient, and a message, this
	 * method sends a note to the recipient with the appropriate
	 * text message.
	 * @param user
	 * @param recipient
	 * @param message a String that contains the message that 
	 * the user inputted.
	 */
	public void sendNote(String user, String recipient, String message) {
		connection.sendMessage(user, recipient, 2, message);
	}
	
	// Consumption of Messages:
	
	/**
	 * Given that a user wants to consume a friend request 
	 * Message, the Message object/instance is fed into this 
	 * method and the appropriate friendship is made between 
	 * two users (bidirectionally). In addition, the Message
	 * is removed from the messages table in the SQL database
	 * @param sender individual who sent the friend request message
	 * @param recipient individual who will be confirming the request.
	 */
	public void acceptFriendRequest(String sender, String recipient) {
		// remove friend request from messages table
		// add bidirectional friendship to friends table
		connection.addFriendship(sender, recipient);
		connection.addFriendship(recipient, sender);
		connection.removeMessage(sender, recipient, 0, "");
	}
	
	/**
	 * This method simply removes the friend request message, without
	 * performing the bidirectional friendship in the friends table.
	 * @param sender individual who sent the friend request message
	 * @param recipient individual who will be confirming the request.
	 */
	public void ignoreFriendRequest(String sender, String recipient) {
		connection.removeMessage(sender, recipient, 0, "");
	}
	
	public int getHighestScore(String itemId, String sender) {
		return connection.getHighestScore(itemId, sender);
	}
	
	/**
	 * Given that a user wants to consume a challenge Message, 
	 * the message object/instance is fed into this method and
	 * the challenge is removed from the messages table in the
	 * SQL database. NOTE: this method does NOT enforce the fact
	 * that an individual must do/participate in the challenge;
	 * that enforcement must be conducted at the User level.
	 * @param challenge a Message object
	 */
	public void acceptChallenge(Message challenge) {
		// remove challenge from messages table
		connection.removeMessage(challenge.getSender(), challenge.getRecipient(), 
				challenge.getType(), challenge.getMessage());
	}
	
	/**
	 * 
	 * @param sender
	 * @param recipient
	 * @param message
	 */
	public void ignoreChallenge(String sender, String recipient, String message) {
		connection.removeMessage(sender, recipient, 1, message);
	}
	
	/**
	 * Given that a user wants to consume/read a note Message,
	 * the message object/instance is fed into this method and
	 * the challenge is removed form the messages table in the 
	 * SQL database.
	 * @param note a Message object
	 */
	public void deleteNote(Message note) {
		// delete note from messages table
		connection.removeMessage(note.getSender(), note.getRecipient(), 
				note.getType(), note.getMessage());
	}
	
	/*
	 * Administration methods
	 */
	
	/**
	 * A Wrapper function for the general user search function
	 * that is implemented in the DBConnection class.
	 * @param pattern String pattern to find within a user's 
	 * username
	 * @return an ArrayList of User objects that correspond
	 * to the Users that contain the search query pattern.
	 */
	public ArrayList<User> search(String pattern) {
		return connection.searchForUser(pattern);
	}
	
	/**
	 * If an individual wants to change their password, they need
	 * to provide their old password to authenticate that they 
	 * are the actual user who's password needs to be changed. 
	 * The then can input the new password as their password.
	 * @param username username to change the password for
	 * @param oldPw old password String
	 * @param newPw new password String
	 */
	public void resetPassword(String username, String oldPw, String newPw) {
		if (connection.authenticateUser(username, oldPw)) {
			connection.updateUserAttribute(username, "password", 
					oldPw, newPw);
		}
	}
	
	/**
	 * Function to promote/restore the status of a 
	 * specific user to the default user status
	 * @param username
	 */
	public void promoteToDefaultUser(String username) {
		User user = connection.getUser(username, true);
		int oldVal = user.getUserStatus();
		connection.updateUserAttribute(username, 
				"userstatus", "" + oldVal, "" + 0);
	}
	
	/*
	 * History-related methods:
	 */
	
	/**
	 * Add a HistoryItem/event for a user making a quiz.
	 * This requires the quizId of the quiz made.
	 * @param user the User object corresponding to the 
	 * current user in the session.
	 * @param itemId the ID of the quiz that was taken
	 * by the user.
	 */
	public void quizMade(User user, String itemId) {
		Date date = new Date();
		String oldAchievements = user.getAchievements();
		int oldQuizzesMade = user.getNumQuizzesMade();
		HistoryItem item = new HistoryItem(user.getUsername(), 
				itemId, 0, date.getTime(), date.getTime());
		user.addHistoryItem(item);
		connection.addHistoryToDatabase(item);
		connection.updateUserAttribute(user.getUsername(), "quizzesmade",
				"" + oldQuizzesMade, "" + user.getNumQuizzesMade());
		addAchievementToDatabase(user, item.getEndTime(), oldAchievements);
	}
	
	
	/**
	 * Add a HistoryItem/event for a user taking a quiz.
	 * This requires the quizId of the quiz taken and the
	 * score obtained from finishing the quiz.
	 * @param user the User object corresponding to the 
	 * current user in the session.
	 * @param itemId the ID of the quiz that was taken
	 * by the user.
	 * @param score the score obtained by the user taking
	 * the quiz.
	 */
	public void quizTaken(User user, String itemId, long startTime, int score) {
		String oldAchievements = user.getAchievements();
		int oldQuizzesTaken = user.getNumGamesPlayed();
		HistoryItem item = new HistoryItem(user.getUsername(), 
				itemId, 1, startTime, new Date().getTime(), score);
		if (connection.highestScoreForQuiz(itemId, score)) {
			user.addIAmGreatestAchievement();
		}
		user.addHistoryItem(item);
		connection.addHistoryToDatabase(item);
		connection.updateUserAttribute(user.getUsername(), "gamesplayed",
				"" + oldQuizzesTaken, "" + user.getNumGamesPlayed());
		addAchievementToDatabase(user, item.getEndTime(), oldAchievements);
	}
	
	/**
	 * Gives user practice award achievement
	 * @param user
	 */
	public void awardPracticeModeAchievement(User user) {
		String oldAchievements = user.getAchievements();
		long time = new Date().getTime();
		user.addPracticeMakesPerfectAchievement();
		addAchievementToDatabase(user, time, oldAchievements);
	}
	
	/**
	 * Wrapper function obtaining the list of most 
	 * recent Messages sent to the current user. 
	 * @param user the User object corresponding to 
	 * the current user.
	 * @param limit the number of most recent messages
	 * that should be outputted.
	 * @return
	 */
	public ArrayList<Message> getRecentRecievedMessages(User user, int limit) {
		return connection.getRecentMessages(user.getUsername(), limit);
	}
	
	/**
	 * Given a User instance and an integer limit, this
	 * function provides the most recent HistoryItems
	 * for the given User's friends.
	 * @param user a User instance who's friends we are 
	 * interested in querying for.
	 * @param limit an integer limit for the number of
	 * most recent HistoryItems.
	 * @return
	 */
	public ArrayList<HistoryItem> getRecentFriendsHistory(User user, int limit) {
		return connection.getFriendsActivities(user.getFriends(), limit);
	}
	
	/*
	 * Administrator-related Methods:
	 */
	
	/**
	 * sender will be the administrator
	 * recipient will be the empty String (i.e. EVERYONE)
	 * type will be 3 (0 == friending, 1 == challenge, 2 == note)
	 * time will be the date/time the announcement was created
	 * message will be the text that the user wanted to post
	 * @param admin
	 * @param message
	 */
	public void createAnnouncement(User admin, String message) { 
		if (authenticateAdmin(admin)) {
			connection.sendMessage(admin.getUsername(), "", 3, message);
		}
	}
	
	/**
	 * Returns recent announcements
	 * @param admin
	 * @param integer limit to the number of 
	 * Announcements to be returned.
	 * @return the list of most recent Message instances or
	 * null if there are not announcements.
	 */
	public ArrayList<Message> getAnnouncements(int limit) {
		return connection.getRecentMessages("", limit);
	}
	
	/**
	 * Removes a user and their history
	 * @param admin
	 * @param user
	 */
	public void removeUser(User admin, String user) {
		if (authenticateAdmin(admin)) {
			connection.removeUser(user);
		}
	}
	
	/**
	 * Removes a quiz
	 * @param admin
	 * @param quizId
	 */
	public void removeQuiz(User admin, String quizId) {
		if (authenticateAdmin(admin)) {
			connection.removeQuiz(quizId);
		}
	}
	
	/**
	 * Removes a quiz's history
	 * @param admin
	 * @param quizId
	 */
	public void removeQuizHistory(User admin, String quizId) {
		if (authenticateAdmin(admin)) {
			connection.removeQuizHistory(quizId);
		}
	}
	
	/**
	 * Promotes a user to admin
	 * @param admin
	 * @param userToPromote
	 */
	public void promoteUserToAdmin(User admin, String userToPromote) {
		if (authenticateAdmin(admin)) {
			promoteToAdmin(userToPromote);
		}
	}
	
	/**
	 * Get site statistics
	 * @param admin
	 */
	public ArrayList<Integer> seeStats(User admin) {
		if (authenticateAdmin(admin)) {
			return connection.queryForStats();
		} else {
			return null;
		}
	}
	
	private boolean authenticateAdmin(User admin) {
		return admin.getUserStatus() == 1;
	}
	
	/**
	 * Encrypts given password using a salt, returns 
	 * the encryption as a String.
	 * @param password
	 * @return
	 */
	public static String saltAndEncryptPassword(String password) {
	     md.update(password.getBytes());
	     byte[] passwordHash = md.digest();
	     return hexToString(passwordHash);
	}
	
	/*
	 Given a byte[] array, produces a hex String,
	 such as "234a6f". with 2 chars for each byte in the array.
	 (provided code from Assignment 4: Threading)
	*/
	private static String hexToString(byte[] bytes) {
		StringBuffer buff = new StringBuffer();
		for (int i=0; i<bytes.length; i++) {
			int val = bytes[i];
			val = val & 0xff;  // remove higher bits, sign
			if (val<16) buff.append('0'); // leading 0
			buff.append(Integer.toString(val, 16));
		}
		return buff.toString();
	}
	
	/**
	 * Function to promote the status of a 
	 * specific user to "Administrator" status
	 * @param username
	 */
	private void promoteToAdmin(String username) {
		User user = connection.getUser(username, true);
		int oldVal = user.getUserStatus();
		connection.updateUserAttribute(username, 
				"userstatus", "" + oldVal, "" + 1);
	}
	
	/**
	 * Used to give a user achievements
	 * @param user
	 * @param item
	 */
	private void addAchievementToDatabase(User user, long time, String old) {
		HashSet<String> achievements = user.getAchievementsSet();
		if (achievements.size() > 0) {
			for (String achievement : achievements) {
				HistoryItem newItem = new HistoryItem(user.getUsername(), 
						achievement, 2, time, time, -1);
				if (!connection.containsAchievement(newItem)) {
					connection.addHistoryToDatabase(newItem);
					connection.updateUserAttribute(user.getUsername(), 
							"achievements", old, user.getAchievements());
				}
			}
		}
	}
	
}
