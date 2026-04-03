import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/note.dart';
import '../services/database_service.dart';

class NoteProvider with ChangeNotifier {
  late Box<Note> _box;

  NoteProvider() {
    _box = DatabaseService.noteBox;
  }

  List<Note> get notes => _box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Note> getNotesBySubject(String subject) {
    return notes.where((n) => n.subject == subject).toList();
  }

  Future<void> addNote(Note note) async {
    await _box.put(note.id, note);
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    note.updatedAt = DateTime.now();
    await _box.put(note.id, note);
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Note? getNote(String id) {
    return _box.get(id);
  }

  int get totalNotes => _box.length;
}
