import 'dart:io';

import 'package:academic/providers/data_authentication_repository.dart';
import 'package:academic/utils/constants.dart';
import 'package:academic/utils/http_helper.dart';

class DataQuizRepository extends DataAuthenticationRepository {
  static String _className = 'DataQuizRepository';
  static String _fileName = 'data_quiz_repository.dart';

  Future<Map<String, dynamic>> getQuestions({required int quizId}) async {
    try {
      String token = await this.getAccessToken();
      String endpoint = Constants.quizQuestionsEndpoint.replaceAll(
        '{key}',
        quizId.toString(),
      );

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.get,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return body;
    } catch (error) {
      print('[ $_className.getQuestions ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  /// Ambil informasi riwayat kuis hasil tes
  Future<Map<String, dynamic>> getAttempt({required int attemptId}) async {
    try {
      String token = await this.getAccessToken();
      String endpoint =
          Constants.quizAttemptsEndpoint + "/" + attemptId.toString();

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.get,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return body;
    } catch (error) {
      print('[ $_className.getAttempt ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  /// Ambil riwayat soal-soal kuis hasil tes
  Future<Map<String, dynamic>> getAttemptQuestions({
    required int attemptId,
  }) async {
    try {
      String token = await this.getAccessToken();
      String endpoint = Constants.quizAttemptQuestionsEndpoint.replaceAll(
        '{key}',
        attemptId.toString(),
      );

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.get,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return body;
    } catch (error) {
      print(
          '[ $_className.getAttemptQuestions ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  /// Simpan kuis baru pada tes yang ditentukan
  Future<Map<String, dynamic>> storeNewAttempt({
    required int lessonAttemptId,
    required int quizId,
    int? timeStart,
  }) async {
    try {
      String token = await this.getAccessToken();
      Map<String, dynamic> params = {
        'taskId': lessonAttemptId.toString(),
        'quizId': quizId.toString(),
        'timeStart': timeStart
      };

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        Constants.quizAttemptsEndpoint,
        RequestType.post,
        body: params,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return body;
    } catch (error) {
      print('[ $_className.storeNewAttempt ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }
}
