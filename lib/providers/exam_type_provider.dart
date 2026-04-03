import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/exam_type.dart';
import '../services/database_service.dart';

class ExamTypeProvider with ChangeNotifier {
  late Box<ExamType> _box;

  ExamTypeProvider() {
    _box = DatabaseService.examTypeBox;
    _initDefaultExamTypes();
  }

  void _initDefaultExamTypes() {
    if (_box.isEmpty) {
      final defaultTypes = [
        ExamType(
          id: 'tyt',
          name: 'TYT',
          subjects: ['Türkçe', 'Matematik (TYT)', 'Fizik (TYT)', 'Kimya (TYT)', 'Biyoloji (TYT)'],
          createdAt: DateTime.now(),
          isCustom: false,
        ),
        ExamType(
          id: 'ayt',
          name: 'AYT',
          subjects: ['Matematik (AYT)', 'Fizik (AYT)', 'Kimya (AYT)', 'Biyoloji (AYT)'],
          createdAt: DateTime.now(),
          isCustom: false,
        ),
      ];
      for (var type in defaultTypes) {
        _box.put(type.id, type);
      }
    }
  }

  List<ExamType> get examTypes => _box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<String> getSubjectsForExamType(String examTypeId) {
    final type = _box.get(examTypeId);
    return type?.subjects ?? [];
  }

  Future<void> addExamType(ExamType examType) async {
    await _box.put(examType.id, examType);
    notifyListeners();
  }

  Future<void> updateExamType(ExamType examType) async {
    await _box.put(examType.id, examType);
    notifyListeners();
  }

  Future<void> deleteExamType(String id) async {
    final type = _box.get(id);
    if (type != null && type.isCustom) {
      await _box.delete(id);
      notifyListeners();
    }
  }

  ExamType? getExamType(String id) {
    return _box.get(id);
  }
}
