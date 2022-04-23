import 'dart:io';

import 'package:academic/providers/data_authentication_repository.dart';
import 'package:academic/utils/constants.dart';
import 'package:academic/utils/http_helper.dart';

class DataCategoryRepository extends DataAuthenticationRepository {
  static String _className = 'DataCategoryRepository';
  static String _fileName = 'data_category_repository.dart';

  Future<Map<String, dynamic>> getAll() async {
    try {
      String token = await this.getAccessToken();
      String endpoint = Constants.categoriesEndpoint;

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.get,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return body;
    } catch (error) {
      print('[ $_className.getAll ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCategory({required int id}) async {
    try {
      String token = await this.getAccessToken();
      String endpoint = Constants.categoriesEndpoint + "/" + id.toString();

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.get,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return body;
    } catch (error) {
      print('[ $_className.getCategory ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }
}
