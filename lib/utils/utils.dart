import 'package:flutter/material.dart';
import 'package:academic/models/exam_point.dart';

import 'constants.dart';

enum SplitKey { LEFT, RIGHT }

double finalGrades({
  required ExamPoint examPoint,
  required double sumGrades,
}) {
  int totalCorrect = examPoint.totalCorrect;
  int totalQuestions = examPoint.totalQuestions;

  double answerScore = examPoint.totalScore;
  double questionScore = totalCorrect * sumGrades;
  double finalScore = questionScore + answerScore;

  return totalQuestions > 0 ? (finalScore / totalQuestions) * 100 : 0;
}

Map<String, dynamic>? getItemByValueInElements(
  List elements,
  String field,
  dynamic value,
) {
  int index = elements.indexWhere((item) => item[field] == value);

  return index >= 0 ? elements[index] : null;
}

String combineTwoKey(dynamic x, dynamic y, {String separator = '.'}) {
  return "$x$separator" + (y != null ? "$y" : "");
}

int getSplitKey({
  required String value,
  required SplitKey position,
  String separator = '.',
}) {
  List<String> explode = value.split(separator);

  switch (position) {
    case SplitKey.LEFT:
      return int.parse(explode[0]);
    case SplitKey.RIGHT:
      return int.parse(explode[1]);
  }
}

bool empty(dynamic value) {
  List emptyValues = [null, 0, 0.0, false, ""];

  if (value is List<dynamic>) {
    return value.length == 0;
  }

  return emptyValues.contains(value);
}

Map<String, dynamic> getSchedule(
  bool alreadyNow,
  String? openAt,
  String? closeAt,
) {
  IconData? scheduleIcon;
  String? scheduleAt;

  if (!empty(openAt) && !empty(closeAt) && !alreadyNow) {
    scheduleIcon = null;
    scheduleAt = null;
  } else if (!empty(closeAt) && alreadyNow) {
    scheduleIcon = Icons.lock_clock_outlined;
    scheduleAt = closeAt;
  } else if (!empty(openAt) && !alreadyNow) {
    scheduleIcon = Icons.lock_open_outlined;
    scheduleAt = openAt;
  } else if (!empty(closeAt) && !alreadyNow) {
    scheduleIcon = Icons.lock;
    scheduleAt = Labels.has_end.toUpperCase();
  }

  return {'at': scheduleAt, 'icon': scheduleIcon};
}
