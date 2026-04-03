import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/todo_item.dart';
import '../services/database_service.dart';

class TodoProvider with ChangeNotifier {
  late Box<TodoItem> _box;

  TodoProvider() {
    _box = DatabaseService.todoBox;
  }

  List<TodoItem> get todos => _box.values.toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<TodoItem> getIncompleteTodos() {
    return todos.where((t) => !t.isCompleted).toList();
  }

  List<TodoItem> getTodosForWeek(DateTime startOfWeek) {
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return todos.where((t) => 
      !t.dueDate.isBefore(startOfWeek) && t.dueDate.isBefore(endOfWeek)
    ).toList();
  }

  List<TodoItem> getTodosForDay(DateTime day) {
    return todos.where((t) =>
      t.dueDate.year == day.year &&
      t.dueDate.month == day.month &&
      t.dueDate.day == day.day
    ).toList();
  }

  bool hasAllCompletedForDay(DateTime day) {
    final dayTodos = getTodosForDay(day);
    if (dayTodos.isEmpty) return false;
    return dayTodos.every((t) => t.isCompleted);
  }

  List<TodoItem> getCompletedTodosThisWeek(DateTime startOfWeek) {
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return todos.where((t) => 
      t.isCompleted &&
      t.completedAt != null &&
      t.completedAt!.isAfter(startOfWeek) &&
      t.completedAt!.isBefore(endOfWeek)
    ).toList();
  }

  int getCompletionPercentageThisWeek(DateTime startOfWeek) {
    final weekTodos = getTodosForWeek(startOfWeek);
    if (weekTodos.isEmpty) return 0;
    final completed = weekTodos.where((t) => t.isCompleted).length;
    return ((completed / weekTodos.length) * 100).toInt();
  }

  Future<void> addTodo(TodoItem todo) async {
    await _box.put(todo.id, todo);
    notifyListeners();
  }

  Future<void> updateTodo(TodoItem todo) async {
    await _box.put(todo.id, todo);
    notifyListeners();
  }

  Future<void> toggleTodoCompletion(String id) async {
    final todo = _box.get(id);
    if (todo != null) {
      todo.isCompleted = !todo.isCompleted;
      if (todo.isCompleted) {
        todo.completedAt = DateTime.now();
      } else {
        todo.completedAt = null;
      }
      await _box.put(id, todo);
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    await _box.delete(id);
    notifyListeners();
  }
}
