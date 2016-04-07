package quiz.QuestionTypes;


import java.util.ArrayList;

import quiz.QuizInfo;

//Implementation of Picture Response Question
public class PictureResponseQuestion extends Question {
	
	private String question;
	private String url;
	
	//Constructor for download
	public PictureResponseQuestion(String questionstr, ArrayList<String> answers) {
		super(questionstr, answers);
		int index = questionstr.indexOf(" ");
		url = questionstr.substring(0, index);
		question = questionstr.substring(index + 1);
	}
	
	//Constructor for upload
	public PictureResponseQuestion(String question, String url, ArrayList<String> answers) {
		this(url + " " + question, answers);
	}
	
	//Returns the question string
	public String getQuestion() {
		return question;
	}
	
	//Returns the url of the picture
	public String getURL() {
		return url;
	}
	
	//Returns the question type
	public int getType() {
		return QuizInfo.PICTURE_RESPONSE_QUESTIONS;
	}

}
