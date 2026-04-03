import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/study_session.dart';
import '../services/database_service.dart';
import '../models/topic_status.dart';

class StudyProvider with ChangeNotifier {
  late Box<StudySession> _box;
  late Box<TopicStatus> _topicBox;

  StudyProvider() {
    _box = DatabaseService.studyBox;
    _topicBox = DatabaseService.topicBox;
  }

  List<StudySession> get sessions => _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));

  List<StudySession> getSessionsForDay(DateTime day) {
    return sessions.where((s) => 
      s.date.year == day.year && 
      s.date.month == day.month && 
      s.date.day == day.day
    ).toList();
  }

  // Calculate current study streak (consecutive days of study)
  int getStudyStreak() {
    if (sessions.isEmpty) return 0;
    
    final sortedSessions = List<StudySession>.from(sessions)
        ..sort((a, b) => b.date.compareTo(a.date));
    
    int streak = 0;
    DateTime? lastDate;
    
    for (final session in sortedSessions) {
      final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
      
      if (lastDate == null) {
        lastDate = sessionDate;
        streak = 1;
      } else {
        final daysDifference = lastDate.difference(sessionDate).inDays;
        if (daysDifference == 0) {
          continue; // Aynı gün, atla
        } else if (daysDifference == 1) {
          streak++;
          lastDate = sessionDate;
        } else {
          break;
        }
      }
    }
    
    return streak;
  }

  // Get total study hours for this month
  int getMonthlyStudyHours() {
    final now = DateTime.now();
    final minutes = sessions
        .where((s) => s.date.year == now.year && s.date.month == now.month)
        .fold(0, (sum, s) => sum + s.durationMinutes);
    return minutes ~/ 60;
  }

  // Get today's course breakdown: subject -> minutes
  Map<String, int> getTodayCourseBreakdown() {
    final today = DateTime.now();
    final todaySessions = getSessionsForDay(today);
    final breakdown = <String, int>{};
    for (var s in todaySessions) {
      breakdown[s.subject] = (breakdown[s.subject] ?? 0) + s.durationMinutes;
    }
    return breakdown;
  }

  // Get sessions for a date range (inclusive)
  List<StudySession> getSessionsForPeriod(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return sessions.where((s) =>
      s.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
      s.date.isBefore(endDate.add(const Duration(seconds: 1)))
    ).toList();
  }

  // Get net score for a specific day
  double getNetScoreForDay(DateTime day) {
    final daySessions = getSessionsForDay(day);
    int correct = daySessions.fold(0, (sum, s) => sum + s.correctAnswers);
    int wrong = daySessions.fold(0, (sum, s) => sum + s.wrongAnswers);
    return correct - (wrong / 4);
  }

  Future<void> addSession(StudySession session) async {
    await _box.put(session.id, session);
    _updateTopicStatus(session);
    notifyListeners();
  }

  Future<void> deleteSession(String id) async {
    final session = _box.get(id);
    if (session != null) {
      _revertTopicStatus(session);
      await _box.delete(id);
      notifyListeners();
    }
  }

  void _updateTopicStatus(StudySession session) {
    final key = '${session.subject}_${session.topic}';
    TopicStatus? status = _topicBox.get(key);

    if (status == null) {
      status = TopicStatus(subject: session.subject, topic: session.topic);
    }

    if (status.level == TopicLevel.notStarted) {
      status.level = TopicLevel.inProgress;
    }

    status.totalQuestions += session.questionsSolved;
    status.correctAnswers += session.correctAnswers;
    status.wrongAnswers += session.wrongAnswers;
    status.emptyAnswers += session.emptyAnswers;

    _topicBox.put(key, status);
  }

  void _revertTopicStatus(StudySession session) {
    final key = '${session.subject}_${session.topic}';
    TopicStatus? status = _topicBox.get(key);

    if (status != null) {
      status.totalQuestions -= session.questionsSolved;
      status.correctAnswers -= session.correctAnswers;
      status.wrongAnswers -= session.wrongAnswers;
      status.emptyAnswers -= session.emptyAnswers;
      
      if (status.totalQuestions < 0) status.totalQuestions = 0;
      if (status.correctAnswers < 0) status.correctAnswers = 0;
      if (status.wrongAnswers < 0) status.wrongAnswers = 0;
      if (status.emptyAnswers < 0) status.emptyAnswers = 0;

      status.save();
    }
  }
}
