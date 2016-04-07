package quiz.QuestionTypes;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;

import quiz.QuizInfo;

public class MultipleChoiceQuestion extends Question {
	
	private String question;
	protected ArrayList<String> choices;
	
	//For downloading from SQL
	public MultipleChoiceQuestion(String questionstr, ArrayList<String> answers, int divider) {
		super(questionstr, answers);
		String choicesstr = questionstr.substring(0, divider);
		question = questionstr.substring(divider);
		choices = new ArrayList<String>(Arrays.asList(choicesstr.split("\\|"))); 
		randomizeChoices();
	}
	
	//For creating and later adding to SQL
	public MultipleChoiceQuestion(String question, ArrayList<String> choices, ArrayList<String> answers) {
		super(String.join("|", choices) + question, answers);
		this.question = question;
		this.choices = choices;
		divider = String.join("|", choices).length();
	} 
	
	//Randomizes the choices ArrayList on creation
	public void randomizeChoices() {
		for(int x = 0; x < choices.size(); x++) {
			int seed1 = (int)(Math.random()*choices.size());
			int seed2 = (int)(Math.random()*choices.size());
			Collections.swap(choices, seed1, seed2);
		}
	}
	
	//Gets the answer string
	public String getQuestion() {
		return question;
	}
	
	//Returns all the multiple choices for the specific question
	public ArrayList<String> getChoices() {
		return choices;
	}
	
	//Gets the choice at the particular index
	public String getChoice(int index) {
		return choices.get(index);
	}
	
	//Gets the correct answer to this question
	public String getAnswer() {
		return answers.get(0);
	}
	
	//Gets the correct answer in string form, inherited by its subclass, namely MultipleAnswerMC
	public String getCorrectString(){
		String result = "";
		for(int i = 0; i < answers.size();i++) {
			result+=answers.get(i);
			if(i!=answers.size()-1) result += "|";
		}
		return result;
	}
	
	//Returns the concatenation of all the wrong answers for the front-end
	public String getWrongAnswersStr() {
		String result = "";
		for(int i = 0; i < choices.size();i++) {
			if(answers.contains(choices.get(i))) continue;
			result+=choices.get(i);
			if(i!=choices.size()-1) result+="|";
		}
		return result;
	}
	
	//Returns whether the user input is correct
	public boolean isCorrect(String input) {
		int index = Integer.parseInt(input);
		if(choices.get(index).equals(answers.get(0))) return true;
		return false;	
	}
	
	
	//Returns the question type
	public int getType() {
		return  QuizInfo.MULTIPLE_CHOICE;
	}

}

