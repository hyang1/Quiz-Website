package quiz.QuestionTypes;

import java.util.ArrayList;

import quiz.QuizInfo;

//Implementation of the Fill in the Blank Question
public class FillInBlankQuestion extends Question {

	private String part1;
	private String part2;
		
	//For download
	public FillInBlankQuestion(String questionstr, ArrayList<String> answers, int divider) {
		super(questionstr,answers);
		part1 = questionstr.substring(0, divider);
		part2 = questionstr.substring(divider);
	}
	
	//For upload
	public FillInBlankQuestion(String part1, String part2, ArrayList<String> answers) {
		super(part1 + part2, answers);
		this.part1 = part1;
		this.part2 = part2;
		this.divider = part1.length();
	}
	
	//Returns the string part before the blank
	public String getPart1() {
		return part1;
	}
	
	//Returns the string part after the blank
	public String getPart2() {
		return part2;
	}
	
	//Returns the question type:FILL_IN_THE_BLANK
	public int getType() {
		return QuizInfo.FILL_IN_THE_BLANK;
	}

}

