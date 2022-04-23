import 'dart:io';

import 'package:academic/providers/data_authentication_repository.dart';
import 'package:academic/utils/constants.dart';
import 'package:academic/utils/http_helper.dart';

class DataLessonRepository extends DataAuthenticationRepository {
  static String _className = 'DataLessonRepository';
  static String _fileName = 'data_lesson_repository.dart';

  Future<Map<String, dynamic>> getLesson({required int id}) async {
    try {
      String token = await this.getAccessToken();
      String endpoint = Constants.lessonsEndpoint + "/" + id.toString();

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.get,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return body;
    } catch (error) {
      print('[ $_className.getLesson ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getBooks({required int lessonId}) async {
    try {
      String token = await this.getAccessToken();
      String endpoint = Constants.lessonsBooksEndpoint.replaceAll(
        '{key}',
        lessonId.toString(),
      );

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.get,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return body;
    } catch (error) {
      print('[ $_className.getBooks ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getQuestions({required int lessonId}) async {
    try {
      String token = await this.getAccessToken();
      String endpoint = Constants.lessonQuestionsEndpoint.replaceAll(
        '{key}',
        lessonId.toString(),
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

  Future<Map<String, dynamic>> getQuizzes({required int lessonId}) async {
    try {
      String token = await this.getAccessToken();
      String endpoint = Constants.lessonQuizzesEndpoint.replaceAll(
        '{key}',
        lessonId.toString(),
      );

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.get,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return body;
    } catch (error) {
      print('[ $_className.getQuizzes ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  // Ambil semua informasi riwayat tes
  Future<Map<String, dynamic>> getAttempts({
    int? limit,
    int? offset,
  }) async {
    try {
      int userId = await this.getUserId();
      String token = await this.getAccessToken();

      String endpoint = Constants.lessonAttemptsEndpoint +
          "?participant_id=" +
          userId.toString();

      if (limit != null) {
        endpoint += "&limit=$limit";
      }

      if (offset != null) {
        endpoint += "&offset=$offset";
      }

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.get,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return body;
    } catch (error) {
      print('[ $_className.getAttempts ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  /// Ambil informasi riwayat hasil tes
  Future<Map<String, dynamic>> getAttempt({required int attemptId}) async {
    try {
      String token = await this.getAccessToken();
      String endpoint =
          Constants.lessonAttemptsEndpoint + "/" + attemptId.toString();

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

  /// Ambil riwayat soal-soal hasil tes
  Future<Map<String, dynamic>> getAttemptQuestions({
    required int attemptId,
  }) async {
    try {
      String token = await this.getAccessToken();
      String endpoint = Constants.lessonAttemptQuestionsEndpoint.replaceAll(
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

  /// Ambil riwayat kuis-kuis hasil tes
  Future<Map<String, dynamic>> getAttemptQuizzes({
    required int attemptId,
  }) async {
    try {
      String token = await this.getAccessToken();
      String endpoint = Constants.lessonAttemptQuizzesEndpoint.replaceAll(
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
          '[ $_className.getAttemptQuizzes ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  /// Simpan tes baru
  Future<Map<String, dynamic>> storeNewAttempt({
    required int classroomId,
    required int lessonId,
    int? timeStart,
  }) async {
    try {
      int userId = await this.getUserId();
      String token = await this.getAccessToken();
      Map<String, dynamic> params = {
        'classroomId': classroomId.toString(),
        'lessonId': lessonId.toString(),
        'participantId': userId.toString(),
        'timeStart': timeStart
      };

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        Constants.lessonAttemptsEndpoint,
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
