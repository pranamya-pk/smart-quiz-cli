import 'dart:io';

import 'package:smart_quiz_app/smart_quiz.dart';
import 'package:test/test.dart';

void main() {
  group('MultipleChoiceQuestion', () {
    final question = MultipleChoiceQuestion(
      id: 'test-1',
      question: 'Which answer is correct?',
      category: 'Testing',
      difficulty: 'Easy',
      options: ['No', 'Yes'],
      correctOption: 1,
    );

    test('checks the selected answer', () {
      expect(question.isCorrect(1), isTrue);
      expect(question.isCorrect(0), isFalse);
    });

    test('can be converted to JSON', () {
      expect(question.toJson()['correctOption'], 1);
      expect(question.toJson()['options'], ['No', 'Yes']);
    });
  });

  group('QuizSession', () {
    test('calculates a score after answers are submitted', () {
      final session = QuizSession(
        playerName: 'Asha',
        questions: [
          MultipleChoiceQuestion(
            id: 'one',
            question: '1 + 1?',
            category: 'Basics',
            difficulty: 'Easy',
            options: ['1', '2'],
            correctOption: 1,
          ),
          MultipleChoiceQuestion(
            id: 'two',
            question: 'Dart file extension?',
            category: 'Basics',
            difficulty: 'Easy',
            options: ['.dart', '.java'],
            correctOption: 0,
          ),
        ],
      );

      session.answerQuestion(0, 1);
      session.answerQuestion(1, 1);

      final result = session.finish();
      expect(result.score, 1);
      expect(result.totalQuestions, 2);
      expect(result.percentage, 50);
    });
  });

  group('JsonScoreRepository', () {
    test('saves and loads results asynchronously', () async {
      final directory =
          await Directory.systemTemp.createTemp('smart_quiz_test_');
      final file = File('${directory.path}/scores.json');
      final repository = JsonScoreRepository(file);
      final result = QuizResult(
        playerName: 'Test User',
        score: 3,
        totalQuestions: 4,
        completedAt: DateTime(2026, 1, 1),
      );

      await repository.saveResult(result);
      final loaded = await repository.loadResults();

      expect(loaded, hasLength(1));
      expect(loaded.single.playerName, 'Test User');
      expect(loaded.single.score, 3);
      await directory.delete(recursive: true);
    });
  });
}
