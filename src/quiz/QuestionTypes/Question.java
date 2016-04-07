package quiz.QuestionTypes;

import java.util.ArrayList;

//General class for Question types, its subclasses inherit most of their variables and methods from this
public class Question {
	protected String questionstr;
	protected ArrayList<String> answers;
	protected int divider = -1;

	//Default empty constructor
	public Question() {
	}
	
	//Basic constructor for both upload and download
	public Question(String questionstr, ArrayList<String> answers){
		this.questionstr = questionstr;
		this.answers = answers;
	}
	
	//Gets the question string as it is pulled from the database
	public String getQuestionStr() {
		return questionstr;
	}
	
	//Gets the question string itself without other parameters attached to it, overridden by subclasses
	public String getQuestion() {
		return getQuestionStr();
	}
	
	//Gets the correct answers
	public ArrayList<String> getAnswers() {
		return answers;
	}
	
	//Gets the correct answers concatenated together
	public String getAnswersStr() {
		return String.join("|", answers);
	}
	
	//Overridden by subclasses, returns the correct answer if that's the only answer
	public String getAnswer() {
		return null;
	}
	
	//Overridden by subclasses, returns the type of their corresponding type
	public int getType() {
		return -1;
	}
	
	//if the given answer matches one of the answers, return true; else return false
	public int getCorrectNum(String[] useranswer) {
		int correctnum = 0;
		for(int i = 0; i < useranswer.length; i++) {
			if(answers.contains(useranswer[i])) correctnum++;
		}
		return correctnum;
	}
	
	//Overridden by subclasses, returns the divider that is used to separate data downloaded from database
	public int getDivider(){
		return divider;
	}
	
	//Add an answer to the answers array
	public void addAnswer(String answer) {
		answers.add(answer);
	}
	
	public int getAnswerNumber() {
		return 1;
	}
}