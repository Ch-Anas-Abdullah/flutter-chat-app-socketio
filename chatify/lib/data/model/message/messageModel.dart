// To parse this JSON data, do
//
//     final messageModel = messageModelFromMap(jsonString);

import 'dart:convert';

MessageModel messageModelFromMap(String str) =>
    MessageModel.fromMap(json.decode(str));

String messageModelToMap(MessageModel data) => json.encode(data.toMap());

class MessageModel {
  MessageModel({
    this.id,
    this.message,
    this.from,
    this.to,
    this.createdAt,
    this.receivedAt,
    this.openedAt,
    this.messageType,
    this.filePath,
    this.fileLocalPath,
  });

  String? id;
  String? message;
  String? from;
  String? to;
  DateTime? createdAt;
  DateTime? receivedAt;
  DateTime? openedAt;
  String? messageType;
  String? filePath;
  String? fileLocalPath;
  factory MessageModel.fromMap(Map<String, dynamic> json) => MessageModel(
        id: json["id"],
        message: json["message"],
        from: json["from"],
        to: json["to"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        receivedAt: json["receivedAt"] == null
            ? null
            : DateTime.parse(json["receivedAt"]),
        openedAt:
            json["openedAt"] == null ? null : DateTime.parse(json["openedAt"]),
        messageType: json["messageType"],
        filePath: json["filePath"],
        fileLocalPath: '',
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "message": message,
        "from": from,
        "to": to,
        "createdAt": createdAt == null ? null : createdAt!.toIso8601String(),
        "receivedAt": receivedAt == null ? "" : receivedAt!.toIso8601String(),
        "openedAt": openedAt == null ? "" : openedAt!.toIso8601String(),
        "messageType": messageType,
        "filePath": filePath ?? "",
        "fileLocalPath": fileLocalPath ?? "",
      };
}
