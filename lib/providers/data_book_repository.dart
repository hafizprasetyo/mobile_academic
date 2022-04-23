import 'dart:io';

import 'package:academic/providers/data_authentication_repository.dart';
import 'package:academic/utils/constants.dart';
import 'package:academic/utils/http_helper.dart';

class DataBookRepository extends DataAuthenticationRepository {
  static String _className = 'DataBookRepository';
  static String _fileName = 'data_book_repository.dart';

  Future<Map<String, dynamic>> getBook({required int id}) async {
    try {
      String token = await this.getAccessToken();
      String endpoint = Constants.booksEndpoint + "/" + id.toString();

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.get,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return body;
    } catch (error) {
      print('[ $_className.getBook ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }
}
