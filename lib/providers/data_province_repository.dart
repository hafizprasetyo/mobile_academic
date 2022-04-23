import 'dart:io';

import 'package:academic/models/city_response.dart';
import 'package:academic/models/province_response.dart';
import 'package:academic/providers/data_authentication_repository.dart';
import 'package:academic/utils/constants.dart';
import 'package:academic/utils/http_helper.dart';

class DataProvinceRepository extends DataAuthenticationRepository {
  static String _className = 'DataProvinceRepository';
  static String _fileName = 'data_province_repository.dart';

  Future<ProvinceResponse> getAll() async {
    try {
      String token = await this.getAccessToken();
      String endpoint = Constants.provincesEndpoint;

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.get,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return ProvinceResponse.fromMap(body);
    } catch (error) {
      print('[ $_className.getAll ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }

  Future<CityResponse> getCities({required int provinceId}) async {
    try {
      String token = await this.getAccessToken();
      String endpoint = Constants.provinceCitiesEndpoint.replaceAll(
        '{key}',
        provinceId.toString(),
      );

      Map<String, dynamic> body = await HttpHelper.invokeHttp(
        endpoint,
        RequestType.get,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return CityResponse.fromMap(body);
    } catch (error) {
      print('[ $_className.getCities ] $_fileName : ${error.toString()}');
      rethrow;
    }
  }
}
