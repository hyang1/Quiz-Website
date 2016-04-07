package dbconnection;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import quiz.Quiz;
import quiz.QuizInfo;
import quiz.QuestionTypes.FillInBlankQuestion;
import quiz.QuestionTypes.MultiAnswerQuestion;
import quiz.QuestionTypes.MultipleAnswerMCQuestion;
import quiz.QuestionTypes.MultipleChoiceQuestion;
import quiz.QuestionTypes.PictureResponseQuestion;
import quiz.QuestionTypes.Question;
import quiz.QuestionTypes.ResponseQuestion;
import user.HistoryItem;

public class QuizManager {

	private DBConnection con;

	public QuizManager(DBConnection con) {
		this.con = con;
	}

	// Adds the answers in the arraylist to the database with the auto-generated
	// ids and their corresponding questionid that they belong to.
	private void addAnswers(ArrayList<String> answers, int questionid) {
		int answerid = con.getAnswerId();
		for (int i = 0; i < answers.size(); i++) {
			con.addAnswerToDatabase(answerid + i, answers.get(i), questionid);
		}
	}

	// Adds the questions to the database with the auto-generated
	// ids and their corresponding quizid that they belong to.
	private ArrayList<Integer> addQuestions(ArrayList<Question> qlist) {
		ArrayList<Integer> questionids = new ArrayList<Integer>();
		int questionid = con.getQuestionId();
		for (int i = 0; i < qlist.size(); i++) {
			Question que = qlist.get(i);
			addAnswers(que.getAnswers(), questionid + i);
			con.addQuestionToDatabase(questionid + i, que.getType(), que.getQuestionStr(), que.getDivider());
			questionids.add(questionid + i);
		}
		return questionids;
	}

	// Adds a Quiz to the database with auto-generated quizid and corresponding
	// question order of questionids
	public int addQuiz(Object quiz) {
		Quiz q = (Quiz) quiz;
		ArrayList<Integer> questionids = addQuestions(q.getQuestions());

		String questionorder = "";
		for (int i = 0; i < questionids.size(); i++) {
			questionorder += questionids.get(i) + " ";
		}
		int quizid = con.getQuizId();
		con.addQuizToDatabase(quizid, questionorder, q.isRandomized() ? 1 : 0, q.isSinglePage() ? 1 : 0,
				q.isImmediateCorrection() ? 1 : 0, q.isPractice() ? 1 : 0, q.getDescription(), q.getCreator(),
				q.getCategory(), q.getName());
		return quizid;
	}

	// Deletes the quiz with quizid of qid from the database
	public void deleteQuiz(int qid) {
		ResultSet rs = con.getResult("quizzes", "quizid", "" + qid);
		String[] questionids = null;
		try {
			while (rs.next())
				questionids = rs.getString(1).split("\\s+");
		} catch (SQLException e) {
			e.printStackTrace();
		}
		for (int i = 0; i < questionids.length; i++) {
			con.deleteResult("answers", "questionid", questionids[i]);
			con.deleteResult("questions", "questionid", questionids[i]);
		}
		con.deleteResult("quizzes", "quizid", "" + qid);
		con.deleteResult("tags", "quizid", "" + qid);
	}

	// Get the ArrayList of HistoryItems that contains information for later use
	public ArrayList<HistoryItem> getUserQuizHistory(String username, String quizid, String search_standard) {
		return con.getUserQuizHistory(username, quizid, search_standard);
	}

	// Replaces the quiz on the database with a newly generated quiz, used by
	// editing quiz after creation
	public void replaceQuiz(int quizid, Object quiz) {
		deleteQuiz(quizid);

		Quiz q = (Quiz) quiz;
		ArrayList<Integer> questionids = addQuestions(q.getQuestions());

		String questionorder = "";
		for (int i = 0; i < questionids.size(); i++) {
			questionorder += questionids.get(i) + " ";
		}

		con.addQuizToDatabase(quizid, questionorder, q.isRandomized() ? 1 : 0, q.isSinglePage() ? 1 : 0,
				q.isImmediateCorrection() ? 1 : 0, q.isPractice() ? 1 : 0, q.getDescription(), q.getCreator(),
				q.getCategory(), q.getName());
	}

	// Gets the quiz of quizid from the database, parse and populate it with corresponding questions
	public Quiz getQuiz(Object quizid) {
		int qid = (Integer) quizid;
		Quiz q = null;
		ArrayList<Question> ques = new ArrayList<Question>();
		boolean random = false, page = false, correction = false, practice = false;
		String creator = "";
		int category = -1;
		String description = "";
		String quizname = "";
		try {
			ResultSet quizrs = con.getResult("quizzes", "quizid", "" + qid);
			String[] questionids = null;
			if (quizrs.next()) {
				questionids = quizrs.getString("questionorder").split("\\s+");
				creator = quizrs.getString("creator");
				category = quizrs.getInt("category");
				description = quizrs.getString("description");
				quizname = quizrs.getString("quizname");
				random = quizrs.getInt("random") == 1 ? true : false;
				page = quizrs.getInt("page") == 1 ? true : false;
				correction = quizrs.getInt("correction") == 1 ? true : false;
				practice = quizrs.getInt("practice") == 1 ? true : false;
			}
			if (questionids == null)
				return null;
			for (int x = 0; x < questionids.length; x++) {
				ResultSet rs = con.getResult("questions", "questionid", questionids[x]);
				int questiontype = -1;
				String questionstr = "";
				int divider = -1;
				if (rs.next()) {
					questiontype = rs.getInt("questiontype");
					questionstr = rs.getString("questionstr");
					divider = rs.getInt("divider");
				}
				ArrayList<String> answers = new ArrayList<String>();
				ResultSet rsanswer = con.getResult("answers", "questionid", questionids[x]);
				while (rsanswer.next()) {
					answers.add(rsanswer.getString("answerstr"));
				}
				Question que = null;
				if (questiontype == QuizInfo.QUESTION_RESPONSE)
					que = new ResponseQuestion(questionstr, answers);
				else if (questiontype == QuizInfo.FILL_IN_THE_BLANK)
					que = new FillInBlankQuestion(questionstr, answers, divider);
				else if (questiontype == QuizInfo.MULTIPLE_CHOICE)
					que = new MultipleChoiceQuestion(questionstr, answers, divider);
				else if (questiontype == QuizInfo.PICTURE_RESPONSE_QUESTIONS)
					que = new PictureResponseQuestion(questionstr, answers);
				else if (questiontype == QuizInfo.MULTI_ANSWER)
					que = new MultiAnswerQuestion(questionstr, answers);
				else if (questiontype == QuizInfo.MULTIPLE_ANSWER_MC)
					que = new MultipleAnswerMCQuestion(questionstr, answers, divider);
				ques.add(que);
			}
			q = new Quiz(ques, random, page, correction, practice, description, creator, category, quizname);

		} catch (SQLException e) {
			e.printStackTrace();
		}
		return q;

	}
	
	// Adds a tag to a specific quiz in database
	public void addTag(int quizid, String tag) {
		con.addTagToDatabase(quizid, tag);
	}

	/*
	 * Search functionality
	 */

	/**
	 * @param pattern
	 * @return All the quizzes with the specific tag
	 */
	public ResultSet getQuizByTag(String pattern) {
		return con.getQuizByTag(pattern);
	}

	/**
	 * @param category
	 * @return All the quizzes with the specific category
	 */
	public ResultSet getQuizByCategory(int category) {
		return con.getQuizByCategory(category);
	}

	/**
	 * @param pattern
	 * @return All the quizzes with the specific name
	 */
	public ResultSet getQuizByName(String pattern) {
		return con.getQuizByName(pattern);
	}
	
	public ResultSet getResult(String table, String idtype, String id) {
		return con.getResult(table, idtype, id);
	}

	
	public void deleteResult(String table, String idtype, String id) {
		con.deleteResult(table, idtype, id);
	}
	
	public ArrayList<Integer> getPopularQuizzes() {
		return con.getPopularQuizzes();
	}
	
	public ArrayList<Integer> getRecentQuizzes() {
		return con.getRecentQuizzes();
	}
	
	
	public ArrayList<HistoryItem> getTopPlayers(String quizid, int num) {
		return con.getTopPlayers(quizid, num);
	}
	
	
	public ArrayList<HistoryItem> getQuizHistory(String quizid, String sortstandard, int num) {
		return con.getQuizHistory(quizid, sortstandard, num);
	}
	
	public ArrayList<Integer> getUserHistory(String username){
		return con.getUserHistory(username);
	}
	
	public String getQuizNameById(String quizid) {
		return con.getQuizNameById(quizid);
	}
	
	public ArrayList<String> getQuizNames(ArrayList<Integer> ids) {
		return con.getQuizNames(ids);
	}
	
	public ArrayList<HistoryItem> getQuizByTimeSpent(String user, String itemid) {
		return con.getQuizByTimeSpent(user, itemid);
	}
	
	public ArrayList<HistoryItem> getQuizRecentPerformance(String quizid) {
		return con.getQuizRecentPerformance(quizid);
	}
	
	public ArrayList<HistoryItem> getPastPlayers(String quizid) {
		return con.getPastPlayers(quizid);
	}
	
	public ArrayList<String> getTagByQuiz(int quizid) {
		return con.getTagByQuiz(quizid);
	}
	
	
}
