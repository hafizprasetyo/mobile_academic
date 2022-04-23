import 'dart:io';

import 'package:academic/models/user.dart';
import 'package:academic/providers/data_authentication_repository.dart';
import 'package:academic/utils/constants.dart';
import 'package:academic/utils/http_helper.dart';

class DataUserRepository extends DataAuthenticationRepository {
  static String _className = 'DataUserRepository';
  static String _fileName = 'data_user_repository.dart';

  /// Memuat informasi lengkap tentang user
  Future<User> getProfile({String? accessToken, int? userId}) async {
    try {
      String token = accessToken ?? await getAccessToken();
      int id = userId ?? await getUserId();
      String endpoint = Constants.usersEndpoint + "/" + id.toString();

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.get,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      User user = User.fromMap(body);
      await this.saveCredentials(token: token, user: user);

      return user;
    } catch (error) {
      print('[ $_className.getProfile ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  /// Kembalikan object `User` bila ada perubahan
  /// atau `null` jika tidak ada perubahan
  Future<User?> saveProfile({
    String? fullName,
    String? phoneNumber,
    String? gender,
    String? address,
  }) async {
    try {
      int userId = await this.getUserId();
      String token = await this.getAccessToken();
      String endpoint = Constants.usersEndpoint + "/" + userId.toString();

      Map<String, dynamic> params = {
        "fullName": fullName,
        "phoneNumber": phoneNumber,
        "gender": gender,
        "address": address,
      };

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.put,
        body: params,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (body['affected'] > 0) {
        User user = await this.getProfile(accessToken: token, userId: userId);
        return user;
      } else {
        return null;
      }
    } catch (error) {
      print('[ $_className.saveProfile ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getClassrooms() async {
    try {
      int userId = await this.getUserId();
      String token = await this.getAccessToken();
      String endpoint = Constants.userClassroomsEndpoint.replaceAll(
        '{key}',
        userId.toString(),
      );

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.get,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return body;
    } catch (error) {
      print('[ $_className.getClassrooms ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }
}
