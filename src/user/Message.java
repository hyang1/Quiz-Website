package user;

public class Message {
	
	private String sender;
	private String recipient;
	// We want to keep type as an integer value because we 
	// potentially want to support multiple Message types
	// beyond just friend requests, challenges and notes
	private int type;
	private long time;
	private String message;
	
	/**
	 * Constructor for the Friend Request
	 * Message types
	 * @param sender
	 * @param recipient
	 * @param type
	 */
	public Message(String sender, String recipient, int type, long time) {
		this.sender = sender;
		this.recipient = recipient;
		this.type = type;
		this.time = time;
		this.message = null;
	}
	
	/**
	 * Constructor for the Note and Challenge Message type
	 * @param sender
	 * @param recipient
	 * @param type
	 * @param message
	 */
	public Message(String sender, String recipient, int type, long time, String message) {
		this.sender = sender;
		this.recipient = recipient;
		this.type = type;
		this.time = time;
		this.message = message;
	}
	
	/*
	 * Public Interface:
	 */
	
	// Getter Functions:
	
	public String getSender() {
		return sender;
	}
	
	public String getRecipient() {
		return recipient;
	}
	
	public int getType() {
		return type;
	}
	
	public long getTime() {
		return time;
	}
	
	/**
	 * Returns the text message of a Note.
	 * @return a String that contains the text
	 * in the Message if the type is a Note. if 
	 * the Message is a different type, null is 
	 * given.
	 */
	public String getMessage() {
		return message;
	}
	
	@Override
	public String toString() {
		String result = "Sender:" + sender + ", ";
		result += "Recipient:" + recipient + ", ";
		result += "Type:" + type + ", ";
		result += "Time:" + time + ", ";
		result += "Message:\"" + message + "\"";
		return result;
	}	
}
