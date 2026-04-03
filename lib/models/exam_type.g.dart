// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExamTypeAdapter extends TypeAdapter<ExamType> {
  @override
  final int typeId = 5;

  @override
  ExamType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExamType(
      id: fields[0] as String,
      name: fields[1] as String,
      subjects: (fields[2] as List).cast<String>(),
      createdAt: fields[3] as DateTime,
      isCustom: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ExamType obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.subjects)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.isCustom);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
