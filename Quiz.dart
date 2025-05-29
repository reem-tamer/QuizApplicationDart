import 'question.dart';
import 'dart:io';
class Quiz {
  final bool isPractice; // final means itll never change again
  final List<Question> questions; //list of questions objects
  int correctCount = 0;
  int incorrectCount = 0;
  int skippedCount = 0;
  Set<String> weakTopics = {};
  List<Question> questionQueue;

  Quiz(this.questions, this.isPractice) : questionQueue = List.from(questions);
  // making a copy of the quizQuestions list
  // so that we can shuffle it and not affect the original list

  void start() {
    int questionIndex = 0; // counter for the question number we are on
    while (questionIndex < questionQueue.length) {
      Question q = questionQueue[questionIndex];
      print("${questionIndex + 1}) ${q.body}");
      //q is the current question we are in (named it q for quicker typing :())
      // Get and randomize the choices.
      List<String> choices =
          q.get_shuffled_choices(); //using the method in the class

      // mapping the letters to the choices
      Map<String, String> letterDict = {};

      for (int i = 0; i < choices.length; i++) {
        String letter = String.fromCharCode(65 + i);
        letterDict[letter] =
            choices[i]; //letterdict["A"]= choices[0] key to value
        print("  $letter) ${choices[i]}"); //formatted print
      }
      stdout.write("Your answer (or type 'skip'): ");
      String? userAnswer = stdin.readLineSync();

      if (userAnswer == null || userAnswer.trim().toLowerCase() == 'skip') {
        print("Question skipped.\n");
        skippedCount++;
        weakTopics.addAll(q.topics);
        questionIndex++;
        continue; //to prevent the code from continuing the rest of the logic like checking for correct answers etc
      }

      List<String> selectedAnswers =
          []; //list for multiple correct answers option
      List<String> letterInputs =
          userAnswer.split(',').map((s) => s.trim().toUpperCase()).toList();

      // Convert letter input to answer choices
      for (var letter in letterInputs) {
        if (letterDict.containsKey(letter)) {
          //checking if the letter is in the dictionary (validity of the input)
          selectedAnswers.add(letterDict[letter]!);
        } //adding the value (choice itself not the letter) so we can check it later
      }

      if (q.checkAnswer(selectedAnswers.join(', '))) {
        //handling correct answers if its in practice mode send feedback correct
        //but either exam OR practice increase the count and move on to the next q
        if (isPractice) {
          print("Correct!\n");
        }
        correctCount++;
        questionIndex++;
      } else {
        //its false
        if (isPractice) {
          print("Incorrect!"); //feedback for practice mode
          print("Hint: ${q.hint}"); //hint for practice mode
        }
        incorrectCount++; //increase the incorrect count for practice and exam
        weakTopics.addAll(
          q.topics,
        ); //adding the topics to the weak topics set practice & exam

        if (isPractice) {
          stdout.write(
            "Enter 'retry' to try again, 'show' to see the answer, or press enter to move on: ",
          );
          String? option = stdin.readLineSync();
          if (option != null && option.toLowerCase() == 'retry') {
            print("");
            continue; //if user wants to retry it countinues before the questions are incremented so it will retry the same question
          } else if (option != null && option.toLowerCase() == 'show') {
            print("The correct answer(s): ${q.answers.join(', ')}\n");
          }
          questionQueue.add(
            q,
          ); // re-add the question to the queue when its wrong
        }
        questionIndex++;
      }
    }

    // Report
    print("\n--- Quiz Report ---");
    print("Correct answers: $correctCount");
    print("Incorrect answers: $incorrectCount");
    print("Skipped questions: $skippedCount");

    if (weakTopics.isNotEmpty) {
      print("Topics that may need more practice: ${weakTopics.join(', ')}");
    }
    print("Goodbye! Fun studying!\n");
  }
}
