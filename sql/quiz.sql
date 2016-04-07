USE c_cs108_hyang63;

-- User related tables:
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS friends;
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS history;

-- Quiz related tables:
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS answers;
DROP TABLE IF EXISTS quizzes;
DROP TABLE IF EXISTS tags;

-- remove table if it already exists and start from scratch


-- USER RELATED TABLES

CREATE TABLE users (
	username TEXT,
    password TEXT,
    userstatus INT,
    gamesplayed INT,
    quizzesmade INT,
    achievements TEXT
);

INSERT INTO users VALUES("admin", "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8", 1, 0, 0, "");

-- Represents the relationships that exist
-- between two users (NOTE, it is probably
-- a good idea to validate these usernames
-- within the users table...)
CREATE TABLE friends (
	user1 TEXT,
	user2 TEXT
);

CREATE TABLE messages(
	sender TEXT, -- user id of sender
	recipient TEXT, -- user id of recipient
	message TEXT, -- only applicable to notes
	type INT, -- Integer flag: 0 for friend request, 1 for challenge, 2 for note, etc.
	time TIMESTAMP
);

CREATE TABLE history(
	username TEXT,
	type INT,            -- quizzes made = 0, quizzes taken = 1, and achievements = 2
	starttime TIMESTAMP, -- time of beginning a quiz taken; otherwise just competion time 
	endtime TIMESTAMP,   -- time of completion
	itemid TEXT, -- id of quiz made/taken or of achievement attained
	score INT -- only applicable to quiz taken
);


-- QUIZ RELATED TABLES

CREATE TABLE questions(
    questionid INT,
    questiontype INT, -- see QuizInfo.Java for enums
    questionstr TEXT,
    divider INT
);

CREATE TABLE answers(
    answerid INT,
    answerstr TEXT,
    questionid INT
);
        
CREATE TABLE quizzes(
	quizid INT,
	questionorder TEXT, -- ' ' separated list of question ids
	random INT,    -- 0 = not random, 1 = random
	page INT, -- 0 = all at once, 1 = single page
	correction INT, -- 0 = score at end, 1 = immediate scoring
	practice INT,     -- 0 = practice mode not enabled, 1 = enabled
	description TEXT,
	creator TEXT,
	category TEXT,
	quizname TEXT
);

CREATE TABLE tags(
	quizid INT,
	tag TEXT
);
