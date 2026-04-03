// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TopicStatusAdapter extends TypeAdapter<TopicStatus> {
  @override
  final int typeId = 4;

  @override
  TopicStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TopicStatus(
      subject: fields[0] as String,
      topic: fields[1] as String,
      level: fields[2] as TopicLevel,
      totalQuestions: fields[3] as int,
      correctAnswers: fields[4] as int,
      wrongAnswers: fields[5] as int,
      emptyAnswers: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TopicStatus obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.subject)
      ..writeByte(1)
      ..write(obj.topic)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.totalQuestions)
      ..writeByte(4)
      ..write(obj.correctAnswers)
      ..writeByte(5)
      ..write(obj.wrongAnswers)
      ..writeByte(6)
      ..write(obj.emptyAnswers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopicStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TopicLevelAdapter extends TypeAdapter<TopicLevel> {
  @override
  final int typeId = 3;

  @override
  TopicLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TopicLevel.notStarted;
      case 1:
        return TopicLevel.inProgress;
      case 2:
        return TopicLevel.completed;
      default:
        return TopicLevel.notStarted;
    }
  }

  @override
  void write(BinaryWriter writer, TopicLevel obj) {
    switch (obj) {
      case TopicLevel.notStarted:
        writer.writeByte(0);
        break;
      case TopicLevel.inProgress:
        writer.writeByte(1);
        break;
      case TopicLevel.completed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopicLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
