import 'package:hive_flutter/hive_flutter.dart';
import '../models/study_session.dart';
import '../models/exam_record.dart';
import '../models/topic_status.dart';
import '../models/exam_type.dart';
import '../models/todo_item.dart';
import '../models/note.dart';

class DatabaseService {
  static const String _studyBoxName = 'study_sessions';
  static const String _examBoxName = 'exam_records';
  static const String _topicBoxName = 'topic_status';
  static const String _examTypeBoxName = 'exam_types';
  static const String _todoBoxName = 'todo_items';
  static const String _noteBoxName = 'notes';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(StudySessionAdapter());
    Hive.registerAdapter(ExamRecordAdapter());
    Hive.registerAdapter(ExamSubjectResultAdapter());
    Hive.registerAdapter(TopicLevelAdapter());
    Hive.registerAdapter(TopicStatusAdapter());
    Hive.registerAdapter(ExamTypeAdapter());
    Hive.registerAdapter(TodoItemAdapter());
    Hive.registerAdapter(NoteAdapter());

    // Open boxes
    await Hive.openBox<StudySession>(_studyBoxName);
    await Hive.openBox<ExamRecord>(_examBoxName);
    await Hive.openBox<TopicStatus>(_topicBoxName);
    await Hive.openBox<ExamType>(_examTypeBoxName);
    await Hive.openBox<TodoItem>(_todoBoxName);
    await Hive.openBox<Note>(_noteBoxName);
  }

  static Box<StudySession> get studyBox => Hive.box<StudySession>(_studyBoxName);
  static Box<ExamRecord> get examBox => Hive.box<ExamRecord>(_examBoxName);
  static Box<TopicStatus> get topicBox => Hive.box<TopicStatus>(_topicBoxName);
  static Box<ExamType> get examTypeBox => Hive.box<ExamType>(_examTypeBoxName);
  static Box<TodoItem> get todoBox => Hive.box<TodoItem>(_todoBoxName);
  static Box<Note> get noteBox => Hive.box<Note>(_noteBoxName);
}
