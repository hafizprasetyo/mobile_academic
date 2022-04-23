import 'dart:convert';

class ExamPoint {
  ExamPoint({
    required this.totalQuestions,
    required this.totalCorrect,
    required this.totalWrong,
    required this.totalMissed,
    required this.totalScore,
    required this.totalInvalid,
    required this.errors,
  });

  final int totalQuestions;
  final int totalCorrect;
  final int totalWrong;
  final int totalMissed;
  final double totalScore;
  final int totalInvalid;
  final List errors;

  factory ExamPoint.fromJson(String str) => ExamPoint.fromMap(json.decode(str));
  String toJson() => json.encode(toMap());

  factory ExamPoint.fromMap(Map<String, dynamic> json) => ExamPoint(
        totalQuestions: json["totalQuestions"],
        totalCorrect: json["totalCorrect"],
        totalWrong: json["totalWrong"],
        totalMissed: json["totalMissed"],
        totalScore: json["totalScore"],
        totalInvalid: json["totalInvalid"],
        errors: json['errors'],
      );

  Map<String, dynamic> toMap() => {
        "totalQuestions": totalQuestions,
        "totalCorrect": totalCorrect,
        "totalWrong": totalWrong,
        "totalMissed": totalMissed,
        "totalScore": totalScore,
        "totalInvalid": totalInvalid,
        "errors": errors,
      };
}
