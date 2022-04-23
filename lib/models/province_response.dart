import 'dart:convert';

class ProvinceResponse {
  ProvinceResponse({
    required this.totalResults,
    required this.results,
  });

  final int totalResults;
  final List<Province> results;

  factory ProvinceResponse.fromJson(String str) =>
      ProvinceResponse.fromMap(json.decode(str));
  String toJson() => json.encode(toMap());

  factory ProvinceResponse.fromMap(Map<String, dynamic> json) =>
      ProvinceResponse(
        totalResults: json["totalResults"],
        results: List<Province>.from(
            json["results"].map((x) => Province.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "totalResults": totalResults,
        "results": List<dynamic>.from(results.map((x) => x.toMap())),
      };
}

class Province {
  Province({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory Province.fromJson(String str) => Province.fromMap(json.decode(str));
  String toJson() => json.encode(toMap());

  factory Province.fromMap(Map<String, dynamic> json) => Province(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
      };
}
