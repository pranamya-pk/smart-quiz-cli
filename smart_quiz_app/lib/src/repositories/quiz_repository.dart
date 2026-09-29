import 'dart:convert';
import 'dart:io';

import '../models/quiz_item.dart';
import '../models/quiz_result.dart';

abstract class QuestionRepository {
  Future<List<QuizItem>> loadQuestions();
}

class JsonQuestionRepository implements QuestionRepository {
  JsonQuestionRepository(this.file, {QuestionFactory? factory})
      : _factory = factory ?? const QuestionFactory();

  final File file;
  final QuestionFactory _factory;

  @override
  Future<List<QuizItem>> loadQuestions() async {
    if (!await file.exists()) {
      throw StateError('Question file was not found: ${file.path}');
    }

    final contents = await file.readAsString();
    final decoded = jsonDecode(contents);
    if (decoded is! List) {
      throw const FormatException('Question data must be a JSON list.');
    }

    return decoded.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Each question must be a JSON object.');
      }
      return _factory.fromJson(item);
    }).toList(growable: false);
  }
}

abstract class ScoreRepository {
  Future<List<QuizResult>> loadResults();
  Future<void> saveResult(QuizResult result);
}

class JsonScoreRepository implements ScoreRepository {
  JsonScoreRepository(this.file);

  final File file;

  @override
  Future<List<QuizResult>> loadResults() async {
    if (!await file.exists()) {
      return [];
    }

    final contents = await file.readAsString();
    if (contents.trim().isEmpty) {
      return [];
    }

    final decoded = jsonDecode(contents);
    if (decoded is! List) {
      throw const FormatException('Score history must be a JSON list.');
    }

    return decoded.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Each saved score must be a JSON object.');
      }
      return QuizResult.fromJson(item);
    }).toList(growable: true);
  }

  @override
  Future<void> saveResult(QuizResult result) async {
    await file.parent.create(recursive: true);
    final results = await loadResults();
    results.add(result);
    final encoded = const JsonEncoder.withIndent('  ').convert(
      results.map((savedResult) => savedResult.toJson()).toList(),
    );
    await file.writeAsString('$encoded\n');
  }
}
