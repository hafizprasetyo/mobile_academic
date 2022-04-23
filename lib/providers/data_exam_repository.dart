import 'dart:io';

import 'package:academic/models/exam_point.dart';
import 'package:academic/providers/data_authentication_repository.dart';
import 'package:academic/utils/constants.dart';
import 'package:academic/utils/http_helper.dart';
import 'package:academic/utils/utils.dart';
import 'package:collection/collection.dart';

class DataExamRepository extends DataAuthenticationRepository {
  static String _className = 'DataExamRepository';
  static String _fileName = 'data_exam_repository.dart';

  /// Simpan (update) hasil tes ke `endpoint` yang ditentukan
  Future<Map<String, dynamic>> storeFinalResult({
    required String endpoint,
    required double grades,
    required bool overdue,
    int? timeFinish,
  }) async {
    try {
      String token = await this.getAccessToken();

      Map<String, dynamic> params = {
        'overdue': overdue,
        'grades': grades,
        'timeFinish': timeFinish,
      };

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.put,
        body: params,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return body;
    } catch (error) {
      print(
          '[ $_className.storeFinalResult ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  // Simpan satu soal hasil tes
  Future<Map<String, dynamic>> storeSingleQuestionResult({
    required int lessonAttemptId,
    required int? quizAttemptId,
    required int questionKey,
    required String questionType,
    required dynamic userAnswer,
    required bool flag,
    required double cost,
  }) async {
    try {
      String token = await this.getAccessToken();
      Map<String, dynamic> params = {
        'taskId': lessonAttemptId,
        'submissionId': quizAttemptId,
        'questionKey': questionKey,
        'qType': questionType,
        'userAnswer': userAnswer,
        'flag': flag,
        'cost': cost,
      };

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        Constants.questionAttemptsEndpoint,
        RequestType.post,
        body: params,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return body;
    } catch (error) {
      print(
          '[ $_className.storeSingleQuestionResult ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  /// Simpan semua soal hasil tes
  Future<ExamPoint> storeQuestionsResult({
    required int lessonAttemptId,
    required int? quizAttemptId,
    required List questionsTemp,
  }) async {
    int invalidCount = 0;
    List errors = [];

    int correctCount = 0;
    int wrongCount = 0;
    double correctScore = 0;
    double wrongScore = 0;

    try {
      questionsTemp.forEach((element) async {
        Map<String, dynamic>? body;
        List correctAnswerList = element['correctAnswer'];
        List options = element['options'];

        bool flag = false;
        double cost = 0.0;

        switch (element['qType']) {
          case 'singlechoice':
            Map<String, dynamic>? data =
                getItemByValueInElements(options, 'key', element['userAnswer']);

            if (data != null) {
              flag = data['flag'];
              cost = double.parse(data['point'].toString());

              if (flag) {
                correctScore += cost;
                correctCount += 1;
              } else {
                wrongScore += cost;
                wrongCount += 1;
              }
            }

            body = await this.storeSingleQuestionResult(
              lessonAttemptId: lessonAttemptId,
              quizAttemptId: quizAttemptId,
              questionKey: element['questionKey'],
              questionType: element['qType'],
              userAnswer: element['userAnswer'],
              flag: flag,
              cost: cost,
            );
            break;
          case 'multichoice':
            List userAnswerList = element['userAnswer'];
            Function eq = ListEquality().equals;

            if (eq(correctAnswerList..sort(), userAnswerList..sort())) {
              correctCount += 1;
            } else {
              wrongCount += 1;
            }

            if (userAnswerList.length > 0) {
              userAnswerList.forEach((key) async {
                Map<String, dynamic>? data =
                    getItemByValueInElements(options, 'key', key);

                if (data != null) {
                  flag = data['flag'];
                  cost = double.parse(data['point'].toString());

                  if (flag) {
                    correctScore += cost;
                  } else {
                    wrongScore += cost;
                  }
                }

                body = await this.storeSingleQuestionResult(
                  lessonAttemptId: lessonAttemptId,
                  quizAttemptId: quizAttemptId,
                  questionKey: element['questionKey'],
                  questionType: element['qType'],
                  userAnswer: key,
                  flag: flag,
                  cost: cost,
                );
              });
            } else {
              body = await this.storeSingleQuestionResult(
                lessonAttemptId: lessonAttemptId,
                quizAttemptId: quizAttemptId,
                questionKey: element['questionKey'],
                questionType: element['qType'],
                userAnswer: null,
                flag: flag,
                cost: cost,
              );
            }
            break;
          case 'essay':
            if (!empty(element['userAnswer'])) {
              if (correctAnswerList.contains(element['userAnswer'])) {
                Map<String, dynamic>? data = getItemByValueInElements(
                    options, 'htmlAnswer', element['userAnswer']);
                correctCount += 1;

                if (data != null) {
                  flag = data['flag'];
                  cost = double.parse(data['point'].toString());

                  if (flag) {
                    correctScore += cost;
                  } else {
                    wrongScore += cost;
                  }
                }
              } else {
                wrongCount += 1;
              }

              body = await this.storeSingleQuestionResult(
                lessonAttemptId: lessonAttemptId,
                quizAttemptId: quizAttemptId,
                questionKey: element['questionKey'],
                questionType: element['qType'],
                userAnswer: element['userAnswer'],
                flag: flag,
                cost: cost,
              );
            } else {
              body = await this.storeSingleQuestionResult(
                lessonAttemptId: lessonAttemptId,
                quizAttemptId: quizAttemptId,
                questionKey: element['questionKey'],
                questionType: element['qType'],
                userAnswer: null,
                flag: flag,
                cost: cost,
              );
            }
        }

        invalidCount += body?['invalid'] ?? false ? 1 : 0;
        errors.add(body?['errors'] ?? []);
      });

      Map<String, dynamic> result = {
        'totalQuestions': questionsTemp.length,
        'totalCorrect': correctCount,
        'totalWrong': wrongCount,
        'totalMissed': questionsTemp.length - (correctCount + wrongCount),
        'totalScore': correctScore - wrongScore,
        'totalInvalid': invalidCount,
        'errors': errors,
      };

      print(result);
      return ExamPoint.fromMap(result);
    } catch (error) {
      print(
          '[ $_className.storeQuestionsResult ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }
}
