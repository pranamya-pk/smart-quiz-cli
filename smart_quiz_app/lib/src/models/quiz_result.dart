class QuizResult {
  QuizResult({
    required this.playerName,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  }) {
    if (totalQuestions <= 0) {
      throw ArgumentError.value(totalQuestions, 'totalQuestions');
    }
    if (score < 0 || score > totalQuestions) {
      throw ArgumentError.value(score, 'score');
    }
  }

  final String playerName;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;

  double get percentage => score / totalQuestions * 100;

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'score': score,
        'totalQuestions': totalQuestions,
        'completedAt': completedAt.toIso8601String(),
      };

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    final playerName = json['playerName'];
    final score = json['score'];
    final totalQuestions = json['totalQuestions'];
    final completedAt = json['completedAt'];

    if (playerName is! String ||
        score is! int ||
        totalQuestions is! int ||
        completedAt is! String) {
      throw const FormatException('Score history contains an invalid result.');
    }

    return QuizResult(
      playerName: playerName,
      score: score,
      totalQuestions: totalQuestions,
      completedAt: DateTime.parse(completedAt),
    );
  }
}
