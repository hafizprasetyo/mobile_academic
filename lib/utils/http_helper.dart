import 'dart:convert';
import 'dart:io';

import 'package:academic/exceptions/api_exception.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';

/// `Static` Helper untuk permintaan `http` di seluruh aplikasi.
class HttpHelper {
  static String _className = 'HttpHelper';
  static String _fileName = 'http_helper.dart';

  /// Memanggil permintaan `http` yang diberikan.
  /// [url] dapat berupa `string` atau `Uri`.
  /// [type] dapat berupa salah satu [RequestType].
  /// [body] dan [encoding] hanya berlaku untuk permintaan [RequestType.post] dan [RequestType.put]. Sebaliknya,
  /// mereka tidak berpengaruh.
  /// Ini dioptimalkan untuk permintaan yang mengantisipasi badan respons tipe `Map<string, dynamic>`, seperti pada respons tipe file JSON.
  static Future<Map<String, dynamic>> invokeHttp(String url, RequestType type,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) async {
    http.Response response;
    Map<String, dynamic> responseBody;

    try {
      response = await _invoke(url, type,
          headers: headers, body: body, encoding: encoding);
    } catch (error) {
      print('[ $_className.invokeHttp ] $_fileName : ${error.toString()}');
      rethrow;
    }

    responseBody = jsonDecode(response.body);
    return responseBody;
  }

  /// Memanggil permintaan `http` yang diberikan.
  /// [url] dapat berupa `string` atau `Uri`.
  /// [type] dapat berupa salah satu [RequestType].
  /// [body] dan [encoding] hanya berlaku untuk permintaan [RequestType.post] dan [RequestType.put]. Sebaliknya,
  /// mereka tidak berpengaruh.
  /// Ini dioptimalkan untuk permintaan yang mengantisipasi badan tanggapan tipe `List<dynamic>`, seperti dalam daftar objek JSON.
  static Future<List<dynamic>> invokeHttp2(String url, RequestType type,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) async {
    http.Response response;
    List<dynamic> responseBody;

    try {
      response = await _invoke(url, type,
          headers: headers, body: body, encoding: encoding);
    } catch (error) {
      print('[ $_className.invokeHttp2 ] $_fileName : ${error.toString()}');
      rethrow;
    }

    responseBody = jsonDecode(response.body);
    return responseBody;
  }

  /// Ingat permintaan `http`, mengembalikan [http.response] yang tidak terpengaruh.
  static Future<http.Response> _invoke(String url, RequestType type,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) async {
    http.Response response;
    Uri uri = Uri.parse(url);

    try {
      switch (type) {
        case RequestType.get:
          response = await http.get(uri, headers: headers);
          break;
        case RequestType.post:
          response = await http.post(uri,
              headers: headers, body: jsonEncode(body), encoding: encoding);
          break;
        case RequestType.put:
          response = await http.put(uri,
              headers: headers, body: jsonEncode(body), encoding: encoding);
          break;
        case RequestType.delete:
          response = await http.delete(uri, headers: headers);
          break;
      }

      // menangani respon dan kesalahan apa pun
      return _apiResponse(response);
    } on http.ClientException catch (e) {
      print('[ $_className._invoke ] $_fileName : ${e.uri?.origin}');
      // menangani kesalahan permintaan sebelum ada respon
      throw http.ClientException(Strings.requestFailed);
    } on SocketException catch (e) {
      print('[ $_className._invoke ] $_fileName : ${e.toString()}');
      // menangani tidak ada koneksi internet
      throw SocketException(Strings.noConnection);
    } catch (error) {
      print('[ $_className._invoke ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  static http.Response _apiResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 204:
        return response;
      default:
        Map<String, dynamic> body = jsonDecode(response.body);

        String errorType = body['error'] ?? Initials.internalServer;
        Map<String, dynamic> messages =
            body['messages'] ?? {'error': Strings.serverError};

        print(body.toString());
        throw APIException(response.statusCode, errorType, messages);
    }
  }
}

// tipe yang digunakan oleh pembantu
enum RequestType { get, post, put, delete }
