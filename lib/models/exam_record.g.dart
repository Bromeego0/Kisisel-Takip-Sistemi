// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExamRecordAdapter extends TypeAdapter<ExamRecord> {
  @override
  final int typeId = 1;

  @override
  ExamRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExamRecord(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      examName: fields[2] as String,
      examType: fields[3] as String,
      results: (fields[4] as List).cast<ExamSubjectResult>(),
      totalCorrect: fields[5] as int,
      totalWrong: fields[6] as int,
      totalEmpty: fields[7] as int,
      netScore: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ExamRecord obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.examName)
      ..writeByte(3)
      ..write(obj.examType)
      ..writeByte(4)
      ..write(obj.results)
      ..writeByte(5)
      ..write(obj.totalCorrect)
      ..writeByte(6)
      ..write(obj.totalWrong)
      ..writeByte(7)
      ..write(obj.totalEmpty)
      ..writeByte(8)
      ..write(obj.netScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExamSubjectResultAdapter extends TypeAdapter<ExamSubjectResult> {
  @override
  final int typeId = 2;

  @override
  ExamSubjectResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExamSubjectResult(
      subject: fields[0] as String,
      correct: fields[1] as int,
      wrong: fields[2] as int,
      empty: fields[3] as int,
      net: fields[4] as double,
      weakTopics: (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ExamSubjectResult obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.subject)
      ..writeByte(1)
      ..write(obj.correct)
      ..writeByte(2)
      ..write(obj.wrong)
      ..writeByte(3)
      ..write(obj.empty)
      ..writeByte(4)
      ..write(obj.net)
      ..writeByte(5)
      ..write(obj.weakTopics);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamSubjectResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
