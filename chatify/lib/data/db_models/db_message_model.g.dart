// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DbMessageModelAdapter extends TypeAdapter<DbMessageModel> {
  @override
  final int typeId = 2;

  @override
  DbMessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DbMessageModel(
      id: fields[0],
      message: fields[1],
      from: fields[2],
      to: fields[3],
      createdAt: fields[4],
      receivedAt: fields[5] as DateTime?,
      openedAt: fields[6] as DateTime?,
      messageType: fields[7] as String?,
      filePath: fields[8] as String?,
      fileLocalPath: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DbMessageModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.message)
      ..writeByte(2)
      ..write(obj.from)
      ..writeByte(3)
      ..write(obj.to)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.receivedAt)
      ..writeByte(6)
      ..write(obj.openedAt)
      ..writeByte(7)
      ..write(obj.messageType)
      ..writeByte(8)
      ..write(obj.filePath)
      ..writeByte(9)
      ..write(obj.fileLocalPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DbMessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
