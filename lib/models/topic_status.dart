import 'package:hive/hive.dart';

part 'topic_status.g.dart';

@HiveType(typeId: 3)
enum TopicLevel {
  @HiveField(0)
  notStarted,
  
  @HiveField(1)
  inProgress,
  
  @HiveField(2)
  completed
}

@HiveType(typeId: 4)
class TopicStatus extends HiveObject {
  @HiveField(0)
  String subject;

  @HiveField(1)
  String topic;

  @HiveField(2)
  TopicLevel level;

  @HiveField(3)
  int totalQuestions;

  @HiveField(4)
  int correctAnswers;

  @HiveField(5)
  int wrongAnswers;

  @HiveField(6)
  int emptyAnswers;

  TopicStatus({
    required this.subject,
    required this.topic,
    this.level = TopicLevel.notStarted,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.emptyAnswers = 0,
  });

  double get successRate {
    if (totalQuestions == 0) return 0.0;
    return (correctAnswers / totalQuestions) * 100;
  }
}
