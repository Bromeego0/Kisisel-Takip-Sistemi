import 'package:hive/hive.dart';

part 'exam_type.g.dart';

@HiveType(typeId: 5)
class ExamType extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> subjects;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  bool isCustom;

  ExamType({
    required this.id,
    required this.name,
    required this.subjects,
    required this.createdAt,
    this.isCustom = true,
  });
}
