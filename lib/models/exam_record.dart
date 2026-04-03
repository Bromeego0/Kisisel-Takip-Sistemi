import 'package:hive/hive.dart';

part 'exam_record.g.dart';

@HiveType(typeId: 1)
class ExamRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String examName;

  @HiveField(3)
  String examType; // e.g. "TYT", "AYT", "Branş"

  @HiveField(4)
  List<ExamSubjectResult> results;

  @HiveField(5)
  int totalCorrect;

  @HiveField(6)
  int totalWrong;

  @HiveField(7)
  int totalEmpty;

  @HiveField(8)
  double netScore;

  ExamRecord({
    required this.id,
    required this.date,
    required this.examName,
    required this.examType,
    required this.results,
    required this.totalCorrect,
    required this.totalWrong,
    required this.totalEmpty,
    required this.netScore,
  });
}

@HiveType(typeId: 2)
class ExamSubjectResult extends HiveObject {
  @HiveField(0)
  String subject;

  @HiveField(1)
  int correct;

  @HiveField(2)
  int wrong;

  @HiveField(3)
  int empty;

  @HiveField(4)
  double net;

  @HiveField(5)
  List<String> weakTopics;

  ExamSubjectResult({
    required this.subject,
    required this.correct,
    required this.wrong,
    required this.empty,
    required this.net,
    required this.weakTopics,
  });
}
