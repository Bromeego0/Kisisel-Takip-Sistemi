import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/exam_record.dart';
import '../services/database_service.dart';

class ExamProvider with ChangeNotifier {
  late Box<ExamRecord> _box;

  ExamProvider() {
    _box = DatabaseService.examBox;
  }

  List<ExamRecord> get exams => _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));

  List<ExamRecord> getExamsForDay(DateTime day) {
    return exams.where((e) => 
      e.date.year == day.year && 
      e.date.month == day.month && 
      e.date.day == day.day
    ).toList();
  }

  Future<void> addExam(ExamRecord exam) async {
    await _box.put(exam.id, exam);
    notifyListeners();
  }

  Future<void> deleteExam(String id) async {
    await _box.delete(id);
    notifyListeners();
  }
}
