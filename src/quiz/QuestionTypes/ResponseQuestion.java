package quiz.QuestionTypes;

import java.util.ArrayList;

import quiz.QuizInfo;

//Implementation of Response Question
public class ResponseQuestion extends Question {

	//Constructor for both download and upload
	public ResponseQuestion(String questionstr, ArrayList<String> answers) {
		super(questionstr, answers);
	}

	//Returns the type of this question
	public int getType() {
		return QuizInfo.QUESTION_RESPONSE;
	}
}

