/// An item that can be presented as part of a quiz.
///
/// The abstract class gives the app a common contract for quiz content. New
/// question formats can extend this class without changing the quiz engine.
abstract class QuizItem {
  String get id;
  String get question;
  String get category;
  String get difficulty;
  List<String> get options;

  bool isCorrect(int selectedOption);

  Map<String, dynamic> toJson();
}

/// A multiple-choice question with one correct option.
class MultipleChoiceQuestion extends QuizItem {
  MultipleChoiceQuestion({
    required String id,
    required String question,
    required String category,
    required String difficulty,
    required List<String> options,
    required int correctOption,
  })  : _id = id,
        _question = question,
        _category = category,
        _difficulty = difficulty,
        _options = List.unmodifiable(options),
        _correctOption = correctOption {
    if (_options.length < 2) {
      throw ArgumentError('A question needs at least two options.');
    }
    if (_correctOption < 0 || _correctOption >= _options.length) {
      throw ArgumentError(
          'The correct option must point to an available option.');
    }
  }

  final String _id;
  final String _question;
  final String _category;
  final String _difficulty;
  final List<String> _options;
  final int _correctOption;

  @override
  String get id => _id;

  @override
  String get question => _question;

  @override
  String get category => _category;

  @override
  String get difficulty => _difficulty;

  @override
  List<String> get options => _options;

  int get correctOption => _correctOption;

  @override
  bool isCorrect(int selectedOption) => selectedOption == _correctOption;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'category': category,
        'difficulty': difficulty,
        'options': options,
        'correctOption': correctOption,
      };
}

/// Converts the JSON map into a concrete [QuizItem].
class QuestionFactory {
  const QuestionFactory();

  QuizItem fromJson(Map<String, dynamic> json) {
    final options = json['options'];
    if (options is! List) {
      throw const FormatException('Question options must be a JSON list.');
    }

    return MultipleChoiceQuestion(
      id: _requiredString(json, 'id'),
      question: _requiredString(json, 'question'),
      category: _requiredString(json, 'category'),
      difficulty: _requiredString(json, 'difficulty'),
      options: options.map((option) => option.toString()).toList(),
      correctOption: _requiredInt(json, 'correctOption'),
    );
  }

  String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException(
          'Question field "$key" must be a non-empty string.');
    }
    return value;
  }

  int _requiredInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! int) {
      throw FormatException('Question field "$key" must be an integer.');
    }
    return value;
  }
}
