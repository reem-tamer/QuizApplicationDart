import 'dart:math';

class Question {
  int id;
  String body;
  List<String> answers; // list of correct answers
  List<String> alternatives; // wrong choices
  String hint;
  List<String> topics;

  Question({
    required this.id,
    required this.body,
    required this.answers,
    required this.alternatives,
    required this.hint,
    required this.topics,
  });
  List<String> get_shuffled_choices() {
    List<String> all_choices =
        []
          ..addAll(answers)
          ..addAll(alternatives);
    all_choices.shuffle(Random());
    return all_choices; // returns a shuffeled list of correct and alternative answers
  }

  bool checkAnswer(String userInput) {
    List<String>
    userAnswers = // cleaning the user input (splits it into a list of strings, trims the strings and makes them lowercase
        // remove any empty strings
        userInput
            .split(',')
            .map(
              (s) => s.trim().toLowerCase(),
            ) //.map iterates over a list and transforms it (easier than a for loop)
            .where((s) => s.isNotEmpty) // removes any empty strings
            .toList();
    List<String>
    correctAnswers = // sorting both user input and correct answers so A,B is the same as B,A
        answers.map((s) => s.toLowerCase()).toList()..sort();
    userAnswers.sort();
    return userAnswers.join(',') == correctAnswers.join(',');
    // turning it into str for easier comparisom instead of having to iterate over a list
  }
}
