import 'package:hive/hive.dart';

part 'study_session.g.dart';

@HiveType(typeId: 0)
class StudySession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String subject;

  @HiveField(3)
  String topic;

  @HiveField(4)
  int durationMinutes;

  @HiveField(5)
  int questionsSolved;

  @HiveField(6)
  int correctAnswers;

  @HiveField(7)
  int wrongAnswers;

  @HiveField(8)
  int emptyAnswers;

  @HiveField(9)
  String? notes;

  StudySession({
    required this.id,
    required this.date,
    required this.subject,
    required this.topic,
    required this.durationMinutes,
    required this.questionsSolved,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.emptyAnswers = 0,
    this.notes,
  });

  double get netScore => correctAnswers - (wrongAnswers * 0.25);

  String get durationFormatted {
    int hours = durationMinutes ~/ 60;
    int minutes = durationMinutes % 60;
    if (hours == 0) return '${minutes}d';
    if (minutes == 0) return '${hours}s';
    return '${hours}s ${minutes}d';
  }
}
