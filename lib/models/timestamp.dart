import 'dart:convert';

class Dates {
  Dates({required this.created, required this.modified});

  final Timestamp created;
  final Timestamp modified;

  factory Dates.fromJson(String str) => Dates.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Dates.fromMap(Map<String, dynamic> json) => Dates(
        created: Timestamp.fromMap(json["created"]),
        modified: Timestamp.fromMap(json["modified"]),
      );

  Map<String, dynamic> toMap() => {
        "created": created.toMap(),
        "modified": modified.toMap(),
      };
}

class Timestamp {
  Timestamp({
    required this.date,
    required this.timezoneType,
    required this.timezone,
  });

  final DateTime date;
  final int timezoneType;
  final String timezone;

  factory Timestamp.fromJson(String str) => Timestamp.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Timestamp.fromMap(Map<String, dynamic> json) => Timestamp(
        date: DateTime.parse(json["date"]),
        timezoneType: json["timezone_type"],
        timezone: json["timezone"],
      );

  Map<String, dynamic> toMap() => {
        "date": date.toIso8601String(),
        "timezone_type": timezoneType,
        "timezone": timezone,
      };
}
