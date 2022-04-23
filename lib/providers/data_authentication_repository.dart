import 'dart:io';

import 'package:academic/models/user.dart';
import 'package:academic/utils/constants.dart';
import 'package:academic/utils/http_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataAuthenticationRepository {
  static String _className = 'DataAuthenticationRepository';
  static String _fileName = 'data_authentication_repository.dart';

  Future<void> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      Map<String, dynamic> params = {
        'fullname': fullName,
        'username': username,
        'email': email,
        'password': password
      };

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        Constants.usersEndpoint,
        RequestType.post,
        body: params,
      );

      await _saveMailStatus(status: body['emailSent']);
    } catch (error) {
      print('[ $_className.register ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  Future<void> authenticate({
    required String email,
    required String password,
  }) async {
    try {
      Map<String, dynamic> params = {'email': email, 'password': password};
      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        Constants.loginEndpoint,
        RequestType.post,
        body: params,
      );

      String token = body['accessToken'];
      User user = await fetchCredentials(token: token);

      await saveCredentials(token: token, user: user);
    } catch (error) {
      print('[ $_className.authenticate ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.remove(Constants.isAuthenticatedKey);
      preferences.remove(Constants.userKey);
      preferences.remove(Constants.userIdKey);
      preferences.remove(Constants.tokenKey);
    } catch (error) {
      print('[ $_className.logout ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  Future<String> getAccessToken() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? accessToken = preferences.getString(Constants.tokenKey);

      if (accessToken == null) {
        throw Exception(Strings.getLocalPrefsFailed);
      }

      return accessToken;
    } catch (error) {
      print('[ $_className.getAccessToken ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  /// Validasi status akses user (aktif/nonaktif)
  Future<bool> validateAccess() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? userPreferences = preferences.getString(Constants.userKey);

      if (userPreferences == null) {
        throw Exception(Strings.getLocalPrefsFailed);
      }

      User user = User.fromJson(userPreferences);
      return user.status;
    } catch (error) {
      print('[ $_className.validateAccess ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  Future<User> getCurrentUser() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? userPreferences = preferences.getString(Constants.userKey);

      if (userPreferences == null) {
        throw Exception(Strings.getLocalPrefsFailed);
      }

      return User.fromJson(userPreferences);
    } catch (error) {
      print('[ $_className.getCurrentUser ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      return preferences.getBool(Constants.isAuthenticatedKey) ?? false;
    } catch (error) {
      print('[ $_className.isAuthenticated ] $_fileName : ${error.toString()}');
      return false;
    }
  }

  Future<int> getUserId() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      int? id = preferences.getInt(Constants.userIdKey);

      if (id == null) {
        throw Exception(Strings.getLocalPrefsFailed);
      }

      return id;
    } catch (error) {
      print('[ $_className.getUserId ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  /// Simpan ke penyimpanan local informasi :
  /// `token`
  /// `user id`
  /// `user object`
  /// `authentication status`
  Future<void> saveCredentials({
    required String token,
    required User user,
    bool authenticated = true,
  }) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      await Future.wait([
        preferences.setString(Constants.tokenKey, token),
        preferences.setInt(Constants.userIdKey, user.id),
        preferences.setString(Constants.userKey, user.toJson()),
        preferences.setBool(Constants.isAuthenticatedKey, authenticated)
      ]);
    } catch (error) {
      print('[ $_className.saveCredentials ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  /// Memuat informasi user :
  /// `id`
  /// `email`
  /// `username`
  /// `fullName`
  /// `phoneNumber`
  /// `photoUrl`
  /// `role`
  /// `emailVerify`
  /// `emailVerifyAt`
  /// `status`
  Future<User> fetchCredentials({required String token}) async {
    try {
      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        Constants.credentialsEndpoint,
        RequestType.get,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return User.fromMap(body);
    } catch (error) {
      print(
          '[ $_className.fetchCredentials ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  /// Validasi email verifikasi (terkirim/tidak terkirim)
  Future<bool> validateMailStatus() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      return preferences.getBool(Constants.emailSentKey) ?? false;
    } catch (error) {
      print(
          '[ $_className.validateMailStatus ] $_fileName : ${error.toString()}');
      return false;
    }
  }

  /// Simpan status email verifikasi (terkirim/tidak terkirim)
  Future<void> _saveMailStatus({required bool status}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setBool(Constants.emailSentKey, status);
    } catch (error) {
      print('[ $_className._saveMailStatus ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }
}
