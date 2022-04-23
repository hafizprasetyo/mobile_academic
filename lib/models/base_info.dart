import 'dart:convert';

class BaseInfo {
  BaseInfo({
    required this.id,
    required this.name,
    required this.endpoint,
  });

  final int id;
  final String name;
  final String endpoint;

  factory BaseInfo.fromJson(String str) => BaseInfo.fromMap(json.decode(str));
  String toJson() => json.encode(toMap());

  factory BaseInfo.fromMap(Map<String, dynamic> json) => BaseInfo(
        id: json["id"],
        name: json["name"],
        endpoint: json["endpoint"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "endpoint": endpoint,
      };
}
