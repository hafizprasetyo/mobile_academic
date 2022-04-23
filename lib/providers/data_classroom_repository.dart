import 'dart:io';

import 'package:academic/providers/data_authentication_repository.dart';
import 'package:academic/utils/constants.dart';
import 'package:academic/utils/http_helper.dart';

class DataClassroomRepository extends DataAuthenticationRepository {
  static String _className = 'DataClassroomRepository';
  static String _fileName = 'data_classroom_repository.dart';

  Future<Map<String, dynamic>> getClassroom({required int id}) async {
    try {
      String token = await this.getAccessToken();
      String endpoint = Constants.classroomsEndpoint + "/" + id.toString();

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.get,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return body;
    } catch (error) {
      print('[ $_className.getClassroom ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getLessons({
    required int classroomId,
    int? categoryId,
  }) async {
    try {
      String token = await this.getAccessToken();
      String endpoint = Constants.classroomLessonsEndpoint.replaceAll(
        '{key}',
        classroomId.toString(),
      );

      if (categoryId != null) {
        endpoint += "?category_id=$categoryId";
      }

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.get,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return body;
    } catch (error) {
      print('[ $_className.getLessons ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getParticipants({
    required int classroomId,
  }) async {
    try {
      String token = await this.getAccessToken();
      String endpoint = Constants.classroomParticipantsEndpoint.replaceAll(
        '{key}',
        classroomId.toString(),
      );

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.get,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return body;
    } catch (error) {
      print('[ $_className.getParticipants ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }
}
