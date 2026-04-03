import 'package:hive/hive.dart';

part 'todo_item.g.dart';

@HiveType(typeId: 6)
class TodoItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String subject;

  @HiveField(3)
  String topic;

  @HiveField(4)
  DateTime dueDate;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  int priority; // 0 = Düşük, 1 = Orta, 2 = Yüksek

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime? completedAt;

  @HiveField(9)
  String? notes; // Optional notes for the todo

  TodoItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.topic,
    required this.dueDate,
    this.isCompleted = false,
    this.priority = 1,
    DateTime? createdAt,
    this.completedAt,
    this.notes,
  }) : createdAt = createdAt ?? DateTime.now();
}
