package quiz.QuestionTypes;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;

import quiz.QuizInfo;

//Implementation of the Multiple Answer Question
public class MultiAnswerQuestion extends ResponseQuestion {

	private boolean inorder;
	private String question;
	private int answernum;
	
	//Constructor for download
	public MultiAnswerQuestion(String questionstr, ArrayList<String> answers) {
		super(questionstr, answers);
		inorder = questionstr.charAt(0) == '1' ? true : false;
		int divider = questionstr.indexOf(" ");
		answernum = Integer.parseInt(questionstr.substring(1, divider));
		question = questionstr.substring(divider+1);
	}
	
	//Constructor for upload
	public MultiAnswerQuestion(String question, ArrayList<String> answers, boolean inorder,int answernum) {
		super((inorder? 1 : 0) + "" + answernum +" "+ question, answers);
		this.question = question;
		this.inorder = inorder;
	}
	
	//Returns the question asked
	public String getQuestion() {
		return question;
	}
	
	//Returns whether or not this question needs its answers in a particular order
	public boolean isInorder() {
		return inorder;
	}
	
	//Returns the type of the question
	public int getType() {
		return QuizInfo.MULTI_ANSWER;
	}
	
	//Gets the number of correct answers
	public int getAnswerNumber() {
		return answernum;
	}
	
	//Returns the number of correct answers that the user puts in
	public int getCorrectNum(String[] useranswers) {
		if(inorder == true) {
			int score = 0;
			for(int i = 0; i < useranswers.length && i < answers.size(); i++) {
				if(useranswers[i].equals(answers.get(i))) score++;
			}
			return score;
		} else {
			HashSet<String> temp = new HashSet<String>();
			temp.addAll(Arrays.asList(useranswers));
			int score = 0;
			for(int i = 0; i < answers.size(); i++) {
				if(temp.contains(answers.get(i))) score++;
			}
			return score;
		}
	}
}

