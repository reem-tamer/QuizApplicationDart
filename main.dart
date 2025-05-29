// char code
//65 ==> a
//66 ==> b
//67 ==> c
//68 ==> d

import 'question.dart';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'quiz.dart';

List<Question> loadQuestions(String filePath) {
  final file = File(filePath);
  final jsonString = file.readAsStringSync();
  final Map<String, dynamic> jsonData = jsonDecode(jsonString);

  List<dynamic> questionList = jsonData['questions'];
  List<Question> questions =
      questionList.map((q) {
        return Question(
          id: q['id'],
          body: q['body'],
          answers: List<String>.from(q['answer']),
          alternatives: List<String>.from(q['alternatives']),
          hint: q['hint'],
          topics: List<String>.from(q['topics']),
        );
      }).toList();
  return questions;
}

void main() {
  //first step is to load the questions
  List<Question> allQuestions = loadQuestions('questions.json');

  print("Welcome to the Quiz App");

  //mode selection
  String mode = '';
  while (mode != 'practice' && mode != 'exam') {
    stdout.write("Choose a mode ('practice' or 'exam'): ");
    mode = stdin.readLineSync()?.toLowerCase() ?? '';
  } // while loop to keep repeating the question until the user inputs a valid mode
  bool isPractice = mode == 'practice';

  //asking for the number of questions
  stdout.write("How many questions would you like?: ");
  int numQuestions = int.parse(stdin.readLineSync()!);

  //set of all topics (questions is the list of object questions)
  Set<String> allTopics = {};
  for (var q in allQuestions) {
    allTopics.addAll(q.topics);
  }

  // turning the set to a list so its easier to iterate over
  //then printing the topics for the user to choose from
  print("Available topics:");
  List<String> topicList = allTopics.toList();
  for (int i = 0; i < topicList.length; i++) {
    print("${i + 1}) ${topicList[i]}");
  }

  // asking the user to choose a topic
  stdout.write(
    "Choose a topic (or multiple topics separated by commas, or type 'all'): ",
  );
  String? topicInput = stdin.readLineSync();
  Set<String> selectedTopics = {};

  if (topicInput != null && topicInput.toLowerCase() != "all") {
    // if the user input is not null and not equal to all then it will split the input
    // and add the topics to the selectedTopics set
    List<String> choices = topicInput.split(",");
    for (var choice in choices) {
      int index = int.tryParse(choice.trim()) ?? 0;
      if (index > 0 && index <= topicList.length) {
        selectedTopics.add(topicList[index - 1]);
      } // put the topics chosen by the user in selected topics
    }
  } else {
    selectedTopics = allTopics;
  }

  //filtering the questions based on the selected topics
  List<Question> filteredQuestions = [];
  for (var q in allQuestions) {
    for (var t in q.topics) {
      if (selectedTopics.contains(t)) {
        filteredQuestions.add(q);
        break;
        // if the topic is found in the question then it breaks out of the loop
        // so it doesnt add the same question multiple times
        // assuming some questions might belong to several topics
      }
    }
  }
  //shuffling the questions

  filteredQuestions.shuffle(Random());
  if (numQuestions > filteredQuestions.length) {
    numQuestions = filteredQuestions.length;
    //if the user wants more questions than is available
    // then set the number of questions he want to the list of the filtered questions we have
  }
  List<Question> quizQuestions =
      filteredQuestions.sublist(0, numQuestions).toList();
  //slicing from question zero till the number of questions the user wants

  // create a quiz instance with the selected questions and mode
  Quiz quiz = Quiz(quizQuestions, isPractice);
  quiz.start();

  // ask if the user wants to retake the quiz or take another one
  stdout.write(
    "Do you want to retake the same quiz (retake), take another one (another), or exit (exit)? ",
  );
  String? choice = stdin.readLineSync();
  if (choice != null) {
    if (choice.toLowerCase() == 'retake') {
      // reccreate the quiz with the same questions and mode.
      Quiz quiz2 = Quiz(quizQuestions, isPractice);
      quiz2.start();
    } else if (choice.toLowerCase() == 'another') {
      // loop again to start a new quiz with new settings.
      main();
    } else if (choice.toLowerCase() == 'exit') {
      print("Goodbye!");
    } else {
      print("Invalid choice. Exiting.");
    }
  }
}
