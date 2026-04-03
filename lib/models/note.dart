import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 7)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? updatedAt;

  @HiveField(5)
  String? subject;

  Note({
    required this.id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    this.updatedAt,
    this.subject,
  }) : createdAt = createdAt ?? DateTime.now();
}
