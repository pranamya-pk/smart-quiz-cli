import 'dart:io';

import '../models/quiz_result.dart';
import '../services/quiz_service.dart';

class ConsoleApp {
  ConsoleApp(this.quizService);

  final QuizService quizService;

  Future<void> run() async {
    _printBanner();

    var isRunning = true;
    while (isRunning) {
      _printMenu();
      final choice = _readLine('Choose an option: ');
      switch (choice) {
        case '1':
          await _startQuiz();
        case '2':
          await _showScoreHistory();
        case '3':
          _showAbout();
        case '4':
          isRunning = false;
          stdout.writeln('\nThanks for playing Smart Quiz. Keep learning!');
        default:
          stdout.writeln('\nPlease enter a number from 1 to 4.');
      }
    }
  }

  void _printBanner() {
    stdout
      ..writeln('')
      ..writeln('╔══════════════════════════════════════════════╗')
      ..writeln('║              SMART QUIZ APP                  ║')
      ..writeln('║       Learn a little. Test yourself.         ║')
      ..writeln('╚══════════════════════════════════════════════╝');
  }

  void _printMenu() {
    stdout
      ..writeln('\nMain Menu')
      ..writeln('─────────')
      ..writeln('1. Start a new quiz')
      ..writeln('2. View score history')
      ..writeln('3. About this project')
      ..writeln('4. Exit');
  }

  Future<void> _startQuiz() async {
    final name = _readLine('\nEnter your name: ').trim();
    if (name.isEmpty) {
      stdout.writeln('A name is needed to save your result.');
      return;
    }

    try {
      final session = await quizService.createSession(name);
      stdout.writeln(
        '\nWelcome, $name! Answer ${session.questions.length} questions.',
      );
      stdout.writeln('Type the option number and press Enter.\n');

      for (var index = 0; index < session.questions.length; index++) {
        final currentQuestion = session.questions[index];
        stdout
          ..writeln('Question ${index + 1}/${session.questions.length}')
          ..writeln(
              '[${currentQuestion.category} • ${currentQuestion.difficulty}]')
          ..writeln(currentQuestion.question);

        for (var optionIndex = 0;
            optionIndex < currentQuestion.options.length;
            optionIndex++) {
          stdout.writeln(
              '  ${optionIndex + 1}. ${currentQuestion.options[optionIndex]}');
        }

        final selected = _readOption(currentQuestion.options.length);
        final isCorrect = session.answerQuestion(index, selected);
        stdout.writeln(
          isCorrect ? 'Correct!' : 'Not quite — keep going!',
        );
        stdout.writeln('');
      }

      final result = session.finish();
      await quizService.saveResult(result);
      _showResult(result);
    } on Object catch (error) {
      stdout.writeln('\nCould not start the quiz: $error');
    }
  }

  Future<void> _showScoreHistory() async {
    try {
      final history = await quizService.loadScoreHistory();
      if (history.isEmpty) {
        stdout
            .writeln('\nNo saved scores yet. Complete a quiz to see it here.');
        return;
      }

      stdout
        ..writeln('\nScore History')
        ..writeln('─────────────');
      for (var index = history.length - 1; index >= 0; index--) {
        final result = history[index];
        stdout.writeln(
          '${history.length - index}. ${result.playerName} — '
          '${result.score}/${result.totalQuestions} '
          '(${result.percentage.toStringAsFixed(0)}%) '
          'on ${_formatDate(result.completedAt)}',
        );
      }
    } on Object catch (error) {
      stdout.writeln('\nCould not load score history: $error');
    }
  }

  void _showResult(QuizResult result) {
    final message = switch (result.percentage) {
      >= 80 => 'Excellent work!',
      >= 60 => 'Good job — there is room to grow.',
      _ => 'Keep practicing — you will get there.',
    };

    stdout
      ..writeln('╭──────────────────────────────────────────────╮')
      ..writeln('│                 QUIZ COMPLETE                │')
      ..writeln('╰──────────────────────────────────────────────╯')
      ..writeln(
        '  ${result.playerName}, your score is '
        '${result.score}/${result.totalQuestions} '
        '(${result.percentage.toStringAsFixed(0)}%).',
      )
      ..writeln('  $message')
      ..writeln('  Your result has been saved to score_history.json.');
  }

  void _showAbout() {
    stdout
      ..writeln('\nAbout Smart Quiz')
      ..writeln('────────────────')
      ..writeln('This Minor Project 01 application is written in Dart.')
      ..writeln('Questions are loaded from data/questions.json.')
      ..writeln('Completed quiz results are stored in data/score_history.json.')
      ..writeln(
          'It demonstrates OOP, async/await, JSON parsing, and file I/O.');
  }

  int _readOption(int optionCount) {
    while (true) {
      final input = _readLine('Your answer: ');
      final selected = int.tryParse(input);
      if (selected != null && selected >= 1 && selected <= optionCount) {
        return selected - 1;
      }
      stdout.writeln('Please enter a number between 1 and $optionCount.');
    }
  }

  String _readLine(String prompt) {
    stdout.write(prompt);
    return stdin.readLineSync() ?? '';
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }
}
