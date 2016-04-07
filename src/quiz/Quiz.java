package quiz;

import java.util.ArrayList;
import java.util.Collections;

import quiz.QuestionTypes.Question;

//Quiz class that is the base structure for the functionalities provided across the website.
//Involves parameters and attributes of a quiz, including its questions and qualities.
public class Quiz {
	
	private ArrayList<Question> questions;
	private int category;
	private boolean random = false; //true for randomized
	private boolean page = false; //true for single-page and false for multiple pages
	private boolean correction = false; //true for immediate correction and false for final correction
	private boolean practice = false; //true for allowing practice mode
	private String description;
	private String creator;
	private int currentQuestionIndex = 0;
	String name;

	//Constructor 1: Not sure if it's useful
	public Quiz() {
	}
	
	//Constructor 2: takes in the question array
	public Quiz(ArrayList<Question> questions) {
		this.questions = questions;
		if(random)
			randomizeQuestions();
	}
	
	//Constructor 3: comprehensive, take in the question array, quiz description and creator id
	public Quiz(ArrayList<Question> questions, String description, String creator, String name) {
		this(questions);
		this.description = description;
		this.creator = creator;
		this.name = name;
	}
	
	//Constructor 4: most comprehensive with all fields to initialize and for later upload to mySQL
	public Quiz(ArrayList<Question> questions, boolean random, boolean page, boolean correction, boolean practice, String description, String creator, int category, String name) {
		this(questions, description, creator,name);
		this.random = random;
		this.page = !page;
		this.correction = correction;
		this.practice = practice;
		this.category = category;
	}
	
	//Randomizes the question order, only called if random = true
	public void randomizeQuestions() {
		for(int x = 0; x < questions.size(); x++) {
			int seed1 = (int)(Math.random()*questions.size());
			int seed2 = (int)(Math.random()*questions.size());
			Collections.swap(questions, seed1, seed2);
		}
	}
	
	//Sets the quiz's category to belong in one of the available types
	public void setCategory(int category) {
		this.category = category;
	}
	
	//Returns the name of the Quiz
	public String getName(){
		return name;
	}
	
	//Sets the boolean to decide if the quiz is randomized or not. True for randomized order, false for sequential order
	public void setRandom(boolean random) {
		this.random = random;
	}
	
	//Sets the boolean for single-page or multiple page. True for single-page, false for multiple page
	public void setPage(boolean page) {
		this.page = page;
	}
	
	//Sets the boolean for immediate correction. True for immediate correction
	public void setCorrection(boolean correction) {
		this.correction = correction;
	}
	
	//Sets if the quiz can be taken in practice mode. True for allowing practice and false for not allowing practice
	public void setPractice(boolean practice) {
		this.practice = practice;
	}
	
	//Resets the description associated with the quiz
	public void setDescription(String description) {
		this.description = description;
	}
	
	//Inserts the question at specific index. (Index from 0)
	public void insertQuestion(Question que, int index) {
		questions.add(index, que);
	}

	
	//Returns the total number of questions in the quiz
	public int getLength() {
		return questions.size();
	}
	
	public int getCategory() {
		return category;
	}
	
	//Returns if the quiz is in randomized order or sequential order; true for random and false for sequential
	public boolean isRandomized() {
		return random;
	}
	
	//Returns if the quiz should be one-page or multiple-page(one question per page); true for single-page and false for multiple-page
	public boolean isSinglePage(){
		return page;
	}
	
	//Returns if the quiz gives immediate Correction; true for immediate correction and false for final correction
	public boolean isImmediateCorrection() {
		return correction;
	}
	
	//Returns if the quiz can be taken in practice mode or not
	public boolean isPractice() {
		return practice;
	}
	
	//Returns the description string of the quiz
	public String getDescription(){
		return description;
	}
	
	//Adds question to the quiz to be the last question
	public void addQuestion(Question que) {
		questions.add(que);
	}
	
	//Removes the question with the specific index
	public void removeQuestion(int index){
		if(index < this.getLength() - 1) return;
		questions.remove(index);
	}
	
	//Gets the question with the specific index
	public Question getQuestion(int index) {
		if(index >= questions.size()) return null;
		return questions.get(index);
	}
	
	
	//Returns the entire array of questions
	public ArrayList<Question> getQuestions() {
		return questions;
	}
	
	
	//Gets the next question and shifts the pointer forward
	public Question next() {
		if(currentQuestionIndex == this.getLength()) return null;
		currentQuestionIndex++;
		return questions.get(currentQuestionIndex - 1) ;
	}
	
	public int getQuesionIndex() {
		return currentQuestionIndex;
	}
	
	
	//Gets the previous question and shifts the pointer backward
	public Question previous() {
		if(currentQuestionIndex == 0) return null;
		currentQuestionIndex--;
		return questions.get(currentQuestionIndex + 1);
	}	

	//Gets the number of times taken
	/*public int getPopularity() {
		return taken_times;
	}*/
	

	//Gets the creator's username
	public String getCreator() {
		return creator;
	}
	
	
	public int getTotalScore(){
		int total_score = 0;
		for(int i = 0; i < this.getLength(); i++) {
			total_score+=questions.get(i).getAnswerNumber();
		}
		return total_score;
	}
}
