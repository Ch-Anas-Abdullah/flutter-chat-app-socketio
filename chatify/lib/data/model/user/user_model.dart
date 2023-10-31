// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  UserModel({
    this.id,
    this.name,
    this.image,
    this.about,
    this.lastSeen,
    this.status,
    this.sockedId,
    this.typing,
    this.phoneNumber,
    this.phoneWithDialCode,
    this.dialCode,
    this.createdAt,
  });

  String? id;
  String? name;
  String? image;
  String? about;
  DateTime? lastSeen;
  bool? status;
  dynamic typing;
  String? sockedId;
  String? phoneNumber;
  String? phoneWithDialCode;
  String? dialCode;
  DateTime? createdAt;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        about: json["about"],
        typing: json["typing"],
        lastSeen:
            json["lastSeen"] == null ? null : DateTime.parse(json["lastSeen"]),
        status: json["status"],
        sockedId: json["sockedId"],
        phoneNumber: json["phoneNumber"],
        phoneWithDialCode: json["phoneWithDialCode"],
        dialCode: json["dialCode"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "about": about,
        "lastSeen": lastSeen == null ? null : lastSeen!.toIso8601String(),
        "status": status,
        "sockedId": sockedId,
        "phoneNumber": phoneNumber,
        "phoneWithDialCode": phoneWithDialCode,
        "dialCode": dialCode,
        "createdAt": createdAt == null ? null : createdAt!.toIso8601String(),
      };
}
