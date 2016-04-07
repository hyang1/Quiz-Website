package quiz.QuestionTypes;

import java.util.ArrayList;

import quiz.QuizInfo;

//Implementation of Multiple Answer Multiple Choice Question
public class MultipleAnswerMCQuestion extends MultipleChoiceQuestion {
	
	//For downloading from SQL
	public MultipleAnswerMCQuestion(String questionstr, ArrayList<String> answers, int divider) {
		super(questionstr, answers, divider);
	}
	
	//For creating and later adding to SQL
	public MultipleAnswerMCQuestion(String question, ArrayList<String> choices, ArrayList<String> answers) {
		super(question, choices, answers);
	}
	
	//Returns the question type
	public int getType() {
		return  QuizInfo.MULTIPLE_ANSWER_MC;
	}
	
	
	public int getAnswerNumber() {
		return answers.size();
	}
	//Returns the number of correct answers - number of wrong answers to be the final score
	public int getCorrectNum(String[] useranswer) {
		int correct_num = 0;
		for(int i = 0; i < useranswer.length; i++) {
			if(answers.contains(useranswer[i])) {
				correct_num++;
			}
			else {
				correct_num--;
			}
		}
		if(correct_num < 0)
			return 0;
		return correct_num;
	}

}

