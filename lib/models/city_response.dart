import 'dart:convert';

class CityResponse {
  CityResponse({
    required this.totalResults,
    required this.results,
  });

  final int totalResults;
  final List<City> results;

  factory CityResponse.fromJson(String str) =>
      CityResponse.fromMap(json.decode(str));
  String toJson() => json.encode(toMap());

  factory CityResponse.fromMap(Map<String, dynamic> json) => CityResponse(
        totalResults: json["totalResults"],
        results: List<City>.from(json["results"].map((x) => City.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "totalResults": totalResults,
        "results": List<dynamic>.from(results.map((x) => x.toMap())),
      };
}

class City {
  City({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory City.fromJson(String str) => City.fromMap(json.decode(str));
  String toJson() => json.encode(toMap());

  factory City.fromMap(Map<String, dynamic> json) => City(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
      };
}
