import 'package:kisisel_gelisim_takibi/models/study_session.dart';
import 'package:kisisel_gelisim_takibi/models/exam_record.dart';
import 'package:kisisel_gelisim_takibi/models/todo_item.dart';
import 'package:kisisel_gelisim_takibi/models/note.dart';
import 'package:kisisel_gelisim_takibi/services/database_service.dart';
import 'package:uuid/uuid.dart';

class DataInitializationService {
  static Future<void> loadSampleDataIfEmpty() async {
    final studyBox = DatabaseService.studyBox;
    final examBox = DatabaseService.examBox;
    final todoBox = DatabaseService.todoBox;
    final noteBox = DatabaseService.noteBox;

    if (studyBox.isEmpty && examBox.isEmpty && todoBox.isEmpty && noteBox.isEmpty) {
      await _loadSampleSessions();
      await _loadSampleExams();
      await _loadSampleTodos();
      await _loadSampleNotes();
    }
  }

  static Future<void> _loadSampleSessions() async {
    final studyBox = DatabaseService.studyBox;
    final now = DateTime.now();

    // Today's sessions — dashboard never empty
    final todaySessions = [
      StudySession(
        id: 'session_today_1',
        subject: 'Matematik (TYT)',
        topic: 'Denklem Çözme',
        questionsSolved: 35,
        correctAnswers: 28,
        wrongAnswers: 5,
        emptyAnswers: 2,
        durationMinutes: 45,
        date: now,
        notes: 'Birinci dereceden denklemler tekrarı',
      ),
      StudySession(
        id: 'session_today_2',
        subject: 'Türkçe',
        topic: 'Paragrafta Anlam',
        questionsSolved: 20,
        correctAnswers: 16,
        wrongAnswers: 3,
        emptyAnswers: 1,
        durationMinutes: 30,
        date: now,
        notes: 'Paragraf çözüm teknikleri',
      ),
      StudySession(
        id: 'session_today_3',
        subject: 'Fizik (TYT)',
        topic: 'Kuvvet ve Hareket',
        questionsSolved: 15,
        correctAnswers: 10,
        wrongAnswers: 4,
        emptyAnswers: 1,
        durationMinutes: 25,
        date: now,
        notes: 'Newton hareket yasaları',
      ),
    ];

    for (final session in todaySessions) {
      await studyBox.put(session.id, session);
    }

    // Past days — streak data (consecutive days)
    final subjects = ['Matematik (TYT)', 'Türkçe', 'Fizik (TYT)', 'Kimya (TYT)', 'Biyoloji (TYT)'];
    final topics = [
      'Temel Kavramlar',
      'Sözcükte Anlam',
      'Madde ve Özellikleri',
      'Atom ve Periyodik Sistem',
      'Hücre',
    ];

    for (int i = 1; i <= 14; i++) {
      final date = now.subtract(Duration(days: i));
      // At least 1 session per day for streak
      final session = StudySession(
        id: 'session_past_$i',
        subject: subjects[i % subjects.length],
        topic: topics[i % topics.length],
        questionsSolved: 20 + (i * 3) % 40,
        correctAnswers: 12 + (i * 2) % 20,
        wrongAnswers: 4 + i % 8,
        emptyAnswers: 2 + i % 4,
        durationMinutes: 25 + (i * 7) % 60,
        date: date,
        notes: 'Çalışma kaydı - gün $i',
      );
      await studyBox.put(session.id, session);

      // Add a second session every other day
      if (i % 2 == 0) {
        final session2 = StudySession(
          id: 'session_past_${i}_b',
          subject: subjects[(i + 2) % subjects.length],
          topic: topics[(i + 2) % topics.length],
          questionsSolved: 15 + (i * 2) % 30,
          correctAnswers: 10 + i % 15,
          wrongAnswers: 3 + i % 6,
          emptyAnswers: 2 + i % 3,
          durationMinutes: 20 + (i * 5) % 45,
          date: date,
          notes: 'İkinci çalışma - gün $i',
        );
        await studyBox.put(session2.id, session2);
      }
    }
  }

  static Future<void> _loadSampleExams() async {
    final examBox = DatabaseService.examBox;
    final now = DateTime.now();
    final examTypes = ['TYT', 'AYT'];
    final subjects = ['Matematik (TYT)', 'Türkçe', 'Fizik (TYT)', 'Kimya (TYT)'];

    for (int i = 0; i < 6; i++) {
      final date = now.subtract(Duration(days: i * 4));
      final results = subjects.map((subject) => ExamSubjectResult(
        subject: subject,
        correct: 15 + (i * 3) % 20,
        wrong: 5 + (i * 2) % 10,
        empty: 2 + i % 5,
        net: (13.5 + (i * 2.5)),
        weakTopics: ['Konu 1', 'Konu 2'],
      )).toList();

      final totalCorrect = results.fold(0, (sum, r) => sum + r.correct);
      final totalWrong = results.fold(0, (sum, r) => sum + r.wrong);
      final totalEmpty = results.fold(0, (sum, r) => sum + r.empty);
      final netScore = totalCorrect - (totalWrong / 4);

      final exam = ExamRecord(
        id: 'exam_$i',
        date: date,
        examName: '${examTypes[i % examTypes.length]} Deneme ${i + 1}',
        examType: examTypes[i % examTypes.length],
        results: results,
        totalCorrect: totalCorrect,
        totalWrong: totalWrong,
        totalEmpty: totalEmpty,
        netScore: netScore,
      );
      await examBox.put(exam.id, exam);
    }
  }

  static Future<void> _loadSampleTodos() async {
    final todoBox = DatabaseService.todoBox;
    final now = DateTime.now();

    final todos = [
      // Today — 1 completed, 2 pending
      TodoItem(
        id: const Uuid().v4(),
        title: 'Matematik - Türev Konusu Çalış',
        subject: 'Matematik (AYT)',
        topic: 'Türev',
        dueDate: now,
        priority: 2,
        isCompleted: true,
        completedAt: now,
        notes: 'Ders kitabı sayfa 150-160 aralığı',
      ),
      TodoItem(
        id: const Uuid().v4(),
        title: 'Türkçe - Paragraf Soruları Çöz',
        subject: 'Türkçe',
        topic: 'Paragrafta Anlam',
        dueDate: now,
        priority: 1,
        isCompleted: false,
        notes: 'En az 20 paragraf sorusu çöz',
      ),
      TodoItem(
        id: const Uuid().v4(),
        title: 'Fizik - Kuvvet Test',
        subject: 'Fizik (TYT)',
        topic: 'Kuvvet ve Hareket',
        dueDate: now,
        priority: 2,
        isCompleted: false,
        notes: 'Test kitabı bölüm sonu testi',
      ),
      // Tomorrow
      TodoItem(
        id: const Uuid().v4(),
        title: 'Kimya - Atom Modelleri',
        subject: 'Kimya (TYT)',
        topic: 'Atom ve Periyodik Sistem',
        dueDate: now.add(const Duration(days: 1)),
        priority: 1,
        isCompleted: false,
        notes: 'Bohr atom modeli ve kuantum sayıları',
      ),
      // Day after tomorrow
      TodoItem(
        id: const Uuid().v4(),
        title: 'Biyoloji - Hücre Bölünmeleri',
        subject: 'Biyoloji (TYT)',
        topic: 'Hücre Bölünmeleri',
        dueDate: now.add(const Duration(days: 2)),
        priority: 2,
        isCompleted: false,
      ),
    ];

    for (final todo in todos) {
      await todoBox.put(todo.id, todo);
    }
  }

  static Future<void> _loadSampleNotes() async {
    final noteBox = DatabaseService.noteBox;
    final now = DateTime.now();

    final notes = [
      Note(
        id: const Uuid().v4(),
        title: 'Calculus Türev Kuralları',
        subject: 'Matematik',
        content: '''
Türev almada uygulanan temel kurallar:
1. Toplam Kuralı: [f(x) + g(x)]' = f'(x) + g'(x)
2. Çarpım Kuralı: [f(x)·g(x)]' = f'(x)·g(x) + f(x)·g'(x)
3. Bölüm Kuralı: [f(x)/g(x)]' = [f'(x)·g(x) - f(x)·g'(x)] / [g(x)]²
4. Zincir Kuralı: [f(g(x))]' = f'(g(x))·g'(x)

Önemli: Trigonometrik ve logaritmik fonksiyonların türevlerini unutma!
        ''',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Note(
        id: const Uuid().v4(),
        title: 'Fizik Formülleri - Kuvvet',
        subject: 'Fizik',
        content: '''
Temel Formüller:
- F = m × a (Newton'un 2. yasası)
- W = F × d × cos(θ) (İş)
- Ek = ½mv² (Kinetik Enerji)
- Ep = mgh (Potansiyel Enerji)
- p = mv (Momentum)

Dikkat: Birim dönüşümlerini kontrol et!
        ''',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    for (final note in notes) {
      await noteBox.put(note.id, note);
    }
  }
}
