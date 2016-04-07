package user;

public class HistoryItem {
	
	private String username;
	private String itemId;
	// We want to keep type as an integer value
	// because we potentially want to support multiple 
	// HistoryItem types beyond just quizzes played and quizzes made
	private int type; // type denotes whether it is a quiz played or quiz made
	private long startTime;
	private long endTime;
	private int score; // optional parameter and is only applicable to 'quiz taken'
	
	/**
	 * Constructor for a quiz/game played type of HistoryItem
	 * @param username
	 * @param itemId
	 * @param type
	 * @param startTime
	 * @param endTime
	 * @param score
	 */
	public HistoryItem(String username, String itemId, int type, long startTime, 
			long endTime, int score) {
		this.username = username;
		this.itemId = itemId;
		this.type = type;
		this.startTime = startTime;
		this.endTime = endTime;
		this.score = score;
	}
	
	/**
	 * Constructor for a quiz made type of HistoryItem
	 * @param username
	 * @param itemId
	 * @param type
	 * @param time
	 */
	public HistoryItem(String username, String itemId, int type, long startTime, 
			long endTime) {
		this.username = username;
		this.itemId = itemId;
		this.type = type;
		this.startTime = startTime;
		this.endTime = endTime;
		this.score = -1; // SENTINEL value for when 
	}
	
	/*
	 * Public Interface:
	 */
	
	// Getter functions:
	
	public String getItemId() {
		return itemId;
	}
	
	public int getType() {
		return type;
	}
	
	public long getStartTime() {
		return startTime;
	}
	
	public long getEndTime() {
		return endTime;
	}
	
	/**
	 * Returns the integer score for a particular game
	 * played by the user.
	 * @return the integer value for the score
	 * a user got for a particular game played.
	 * If this command is used on a HistoryItem that
	 * is actually a quiz made instance, then -1 
	 * is returned (interpret as a sentinel value).
	 */
	public int getScore() {
		return score;
	}
	
	public String getUser() {
		return username;
	}
	
	@Override
	public String toString() {
		String result = "Username:" + username + ", ";
		result += "Item ID:" + itemId + ", ";
		result += "Type:" + type + ", ";
		result += "Start Time:" + startTime + ", ";
		result += "End Time:" + endTime + ", ";
		result += "Score:" + score;
		return result;
	}
}
