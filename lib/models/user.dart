import 'package:academic/models/base_info.dart';
import 'package:academic/models/timestamp.dart';
import 'dart:convert';

class User {
  User({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.phoneNumber,
    this.photoUrl,
    this.role,
    required this.emailVerify,
    this.emailVerifyAt,
    required this.dates,
    required this.status,
    this.gender,
    this.dateOfBirth,
    this.provinceInfo,
    this.cityInfo,
    this.address,
  });

  final int id;
  final String email;
  final String username;
  final String fullName;
  final String? phoneNumber;
  final String? photoUrl;
  final String? role;
  final bool emailVerify;
  final String? emailVerifyAt;
  final Dates dates;
  final String? gender;
  final String? dateOfBirth;
  final BaseInfo? provinceInfo;
  final BaseInfo? cityInfo;
  final String? address;
  final bool status;

  factory User.fromJson(String str) => User.fromMap(json.decode(str));
  String toJson() => json.encode(toMap());

  factory User.fromMap(Map<String, dynamic> json) => User(
        id: json["id"],
        email: json["email"],
        username: json["username"],
        fullName: json["fullName"],
        phoneNumber: json["phoneNumber"],
        photoUrl: json["photoUrl"],
        role: json["role"],
        emailVerify: json["emailVerify"],
        emailVerifyAt: json["emailVerifyAt"],
        dates: Dates.fromMap(json["dates"]),
        gender: json["gender"],
        dateOfBirth: json["dateOfBirth"],
        provinceInfo: json["provinceInfo"] == null
            ? null
            : BaseInfo.fromMap(json["provinceInfo"]),
        cityInfo: json["cityInfo"] == null
            ? null
            : BaseInfo.fromMap(json["cityInfo"]),
        address: json["address"],
        status: json['status'],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "email": email,
        "username": username,
        "fullName": fullName,
        "phoneNumber": phoneNumber,
        "photoUrl": photoUrl,
        "role": role,
        "emailVerify": emailVerify,
        "emailVerifyAt": emailVerifyAt,
        "dates": dates.toMap(),
        "gender": gender,
        "dateOfBirth": dateOfBirth,
        "provinceInfo": provinceInfo?.toMap(),
        "cityInfo": cityInfo?.toMap(),
        "address": address,
        "status": status
      };
}
