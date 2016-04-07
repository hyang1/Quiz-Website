package user;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashSet;


public class User {
	
	private static HashSet<String> emptyString = new HashSet<String>(Arrays.asList(""));
	
	private String username;
	private String password;
	private int userStatus;
	private int gamesPlayed;
	private int quizzesMade;
	private HashSet<String> achievements;
	private HashSet<String> friends; // HashSet of userIds of friends
	private ArrayList<HistoryItem> history;
	private ArrayList<Message> messages;
	
	/**
	 * Constructor: This is the constructor
	 * 	for when a user is being FIRST made and there
	 * 	is no information associated with the individual
	 * 	IMPORTANT NOTE: the password is a meaningful input
	 *  meaning it hasn't been encrypted yet
	 * @param username
	 * @param password encrypted version of the password
	 */
	public User(String username, String encryptedPassword) {
		this.username = username;
		this.password = encryptedPassword;
		userStatus = 0;
		gamesPlayed = 0;
		quizzesMade = 0;
		achievements = new HashSet<String>();
		friends = new HashSet<String>();
		history = new ArrayList<HistoryItem>();
		messages = new ArrayList<Message>();
	}
	
	/**
	 * Constructor: This is the constructor
	 * 	for when a user is being pulled from our SQL database
	 * @param usrname
	 * @param encrypted version of the person's password
	 * @param gp number of games played
	 * @param qm number of quizzes made
	 * @param achievements comma separated list of achievements
	 */
	public User(String usrname, String encrypted, int userStatus, int gp, int qm, String achievements) {
		this.username = usrname;
		this.password = encrypted;
		this.gamesPlayed = gp;
		this.userStatus = userStatus;
		this.quizzesMade = qm;
		this.achievements = new HashSet<String>(
				java.util.Arrays.asList(achievements.split(",")));
		(this.achievements).removeAll(emptyString);
		this.friends = new HashSet<String>();
		this.history = new ArrayList<HistoryItem>();
		this.messages = new ArrayList<Message>();
	}
	
	/*
	 * Public Interface
	 */
	
	// Setter functions:
	
	/**
	 * Given a HistoryItem, this method detects
	 * what type of HistoryItem it is (increments
	 * the respective counters if necessary) and
	 * it checks whether an achievement has been
	 * obtained by the current User.
	 * @param item a HistoryItem instance
	 */
	public void addHistoryItem(HistoryItem item) {
		if (item.getType() == 0) {
			this.quizzesMade++;
		} else if (item.getType() == 1) {
			this.gamesPlayed++;
		} // open to extension to other history item types
		checkForAchievement();
		history.add(item);

	}
	
	/**
	 * Take the obtained HashSet of usernames (friends) and save it to 
	 * the User object
	 * @param friends
	 */
	public void addPreexistingFriends(HashSet<String> friends) {
		this.friends = friends;
	}
	
	/**
	 * Take the obtained ArrayList of HistoryItem objects and save it to 
	 * the User object
	 * @param history
	 */
	public void addPreexistingHistory(ArrayList<HistoryItem> history) {
		this.history = history;
	}

	
	/**
	 * Take the obtained ArrayList of Message objects and save it to 
	 * the User object
	 * @param messages
	 */
	public void addPreexistingMessages(ArrayList<Message> messages) {
		this.messages = messages;
	}
	
	// Getter functions:
	
	/**
	 * Returns the username
	 * @return
	 */
	public String getUsername() {
		return username;
	}
	
	/**
	 * Returns the userStatus, 1 denotes an administrator
	 * and 0 denotes a default User.
	 * @return
	 */
	public int getUserStatus() {
		return userStatus;
	}
	
	/**
	 * Returns the User's password in its
	 * encrypted form.
	 * @return
	 */
	public String getEncryptedPassword() {
		return password;
	}
	
	/**
	 * Returns the number of games/quizzes 
	 * played by the current User.
	 * @return
	 */
	public int getNumGamesPlayed() {
		return gamesPlayed;
	}
	
	/**
	 * Returns the number of quizzes made
	 * by the current User
	 * @return
	 */
	public int getNumQuizzesMade() {
		return quizzesMade;
	}
	
	/**
	 * Return a String that is essentially a comma
	 * separated list of different achievements
	 * (e.g."Amateur Author,Prolific Author")
	 * @return
	 */
	public String getAchievements() {
		return commaSeparate(achievements);
	}
	
	/**
	 * Return a HashSet of Strings which are the 
	 * achievements a user has earned.
	 */
	public HashSet<String> getAchievementsSet() {
		return achievements;
	}
	
	/**
	 * Returns the HashSet of a User's friends'
	 * usernames.
	 * @return
	 */
	public HashSet<String> getFriends() {
		return friends;
	}
	
	/**
	 * Returns a full list of the User's HistoryItems
	 * @return
	 */
	public ArrayList<HistoryItem> getHistory() {
		return history;
	}
	
	/**
	 * Returns a list of the User's most recent HistoryItems that
	 * correspond to the quizzes taken type.
	 * @param limit
	 * @return
	 */
	public ArrayList<HistoryItem> getRecentQuizzesTaken(int limit) { // 1
		return filterHistoryByType(limit, 1);
	}

	/**
	 * Returns a list of the User's most recent HistoryItems that
	 * correspond to the quizzes made type.
	 * @param limit
	 * @return
	 */
	public ArrayList<HistoryItem> getRecentQuizzesMade(int limit) { // 0
		return filterHistoryByType(limit, 0);
	}
	
	/**
	 * Returns a User's list of Messages.
	 * @return
	 */
	public ArrayList<Message> getMessages() {
		return messages;
	}
	
	/**
	 * Gives the user the highest score achievement
	 */
	public void addIAmGreatestAchievement() {
		achievements.add("I am the Greatest");
	}
	
	/**
	 * Gives the user the practice mode achievement
	 */
	public void addPracticeMakesPerfectAchievement() {
		achievements.add("Practice Makes Perfect");
	}
	
	@Override
	public String toString() {
		String result = "";
		result += "Username: " + username + " Password: " + password + "\n";
		result += "Games Played: " + gamesPlayed + " Quizzes Made: " + quizzesMade + "\n";
		result += "Achievements:\n";
		result += "\t" + commaSeparate(achievements) + "\n";
		result += "Friends:\n"; 
		result += "\t" + commaSeparate(friends) + "\n";
		result += "History:\n";
		for (HistoryItem item : history)
			result += "\t" + item.toString() + "\n";
		result += "Messages:\n";
		for (Message message : messages)
			result += "\t" + message.toString() + "\n";
		return result;
	}
	
	/*
	 * Private Helper Methods:
	 */

	private ArrayList<HistoryItem> filterHistoryByType(int limit, int type) {
		boolean unbounded = false;
		if (limit < 0) unbounded = true;
		ArrayList<HistoryItem> result = new ArrayList<HistoryItem>();
		Collections.sort(history, new HistoryComparator());
		for (int i = 0; i < history.size(); i++) {
			if (history.get(i).getType() == type && (limit > 0 || unbounded)) {
				result.add(history.get(i));
				limit--;
			}
			if (limit == 0) break;
		}		
		return result;
	}
	
	private static String commaSeparate(HashSet<String> set) {
		String result = "";
		String[] achievementsArray = set.toArray(new String[set.size()]);
		
		if(set == null || set.size() == 0) return "";
		for (int i = 0; i < achievementsArray.length - 1; i++) {
			result += achievementsArray[i] + ",";
		 }
		 result += achievementsArray[achievementsArray.length - 1];
		 return result;
	}
	
	private void checkForAchievement() {
		if (quizzesMade == 1) {
			achievements.add("Amateur Author");
		}
		if (quizzesMade == 5) {
			achievements.add("Prolific Author");
		}
		if (quizzesMade == 10) {
			achievements.add("Prodigious Author");
		}
		if (gamesPlayed == 10) {
			achievements.add("Quiz Machine");
		}
		
		// STILL NEEDS I am the Greatest and Practice Makes Perfect achievements
		
	}

	public class HistoryComparator implements Comparator<HistoryItem> {
		@Override
		public int compare(HistoryItem i1, HistoryItem i2) {
			return -1 * (new Date(i1.getEndTime())).compareTo(new Date(i2.getEndTime()));
		}
	}
}
