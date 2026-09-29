import 'dart:io';

import 'package:smart_quiz_app/smart_quiz.dart';
import 'package:smart_quiz_app/src/ui/console_app.dart';

Future<void> main() async {
  final questionFile = File('data/questions.json');
  final scoreFile = File('data/score_history.json');
  final quizService = QuizService(
    JsonQuestionRepository(questionFile),
    JsonScoreRepository(scoreFile),
  );

  await ConsoleApp(quizService).run();
}
