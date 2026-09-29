import '../models/quiz_item.dart';
import '../models/quiz_result.dart';
import '../repositories/quiz_repository.dart';

class QuizSession {
  QuizSession({
    required List<QuizItem> questions,
    required this.playerName,
  }) : _questions = List.unmodifiable(questions);

  final List<QuizItem> _questions;
  final String playerName;
  final List<int?> _answers = [];

  List<QuizItem> get questions => _questions;
  int get answeredQuestions => _answers.length;
  int get correctAnswers => _countCorrectAnswers();

  bool answerQuestion(int questionIndex, int selectedOption) {
    if (questionIndex < 0 || questionIndex >= _questions.length) {
      throw RangeError.index(questionIndex, _questions, 'questionIndex');
    }
    if (selectedOption < 0 ||
        selectedOption >= _questions[questionIndex].options.length) {
      throw RangeError('selectedOption does not match the question options.');
    }

    while (_answers.length <= questionIndex) {
      _answers.add(null);
    }
    _answers[questionIndex] = selectedOption;
    return _questions[questionIndex].isCorrect(selectedOption);
  }

  QuizResult finish() => QuizResult(
        playerName: playerName,
        score: correctAnswers,
        totalQuestions: _questions.length,
        completedAt: DateTime.now(),
      );

  int _countCorrectAnswers() {
    var score = 0;
    for (var index = 0; index < _answers.length; index++) {
      final selectedOption = _answers[index];
      if (selectedOption != null &&
          _questions[index].isCorrect(selectedOption)) {
        score++;
      }
    }
    return score;
  }
}

class QuizService {
  const QuizService(this.questionRepository, this.scoreRepository);

  final QuestionRepository questionRepository;
  final ScoreRepository scoreRepository;

  Future<QuizSession> createSession(String playerName) async {
    final questions = await questionRepository.loadQuestions();
    if (questions.isEmpty) {
      throw StateError('The question bank is empty.');
    }
    return QuizSession(questions: questions, playerName: playerName);
  }

  Future<void> saveResult(QuizResult result) {
    return scoreRepository.saveResult(result);
  }

  Future<List<QuizResult>> loadScoreHistory() {
    return scoreRepository.loadResults();
  }
}
