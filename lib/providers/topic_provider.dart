import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/topic_status.dart';
import '../services/database_service.dart';
import '../data/subjects_data.dart';

class TopicProvider with ChangeNotifier {
  late Box<TopicStatus> _box;

  TopicProvider() {
    _box = DatabaseService.topicBox;
    _initTopics();
  }

  void _initTopics() {
    // Populate topics if empty
    if (_box.isEmpty) {
      final subjects = SubjectsData.getAllSubjects();
      for (var subject in subjects.keys) {
        for (var topic in subjects[subject]!) {
          final key = '${subject}_$topic';
          _box.put(key, TopicStatus(subject: subject, topic: topic));
        }
      }
    }
  }

  List<TopicStatus> getTopicsForSubject(String subject) {
    return _box.values.where((t) => t.subject == subject).toList();
  }

  TopicStatus? getTopicStatus(String subject, String topic) {
    return _box.get('${subject}_$topic');
  }

  Future<void> updateTopicLevel(String subject, String topic, TopicLevel level) async {
    TopicStatus? status = getTopicStatus(subject, topic);
    if (status != null) {
      status.level = level;
      await status.save();
      notifyListeners();
    }
  }
}
