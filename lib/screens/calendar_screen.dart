import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../providers/study_provider.dart';
import '../providers/exam_provider.dart';
import '../providers/todo_provider.dart';
import '../data/subjects_data.dart';
import '../models/todo_item.dart';
import '../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<String>> _allSubjects = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _allSubjects = SubjectsData.getAllSubjects();
  }

  // Check if a day has any events (study sessions, exams, or todos)
  bool _dayHasEvents(DateTime day, StudyProvider studyProvider, ExamProvider examProvider, TodoProvider todoProvider) {
    final sessions = studyProvider.getSessionsForDay(day);
    final exams = examProvider.getExamsForDay(day);
    final todos = todoProvider.getTodosForDay(day);
    return sessions.isNotEmpty || exams.isNotEmpty || todos.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Takvim'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Consumer3<StudyProvider, ExamProvider, TodoProvider>(
        builder: (context, studyProvider, examProvider, todoProvider, child) {
          return Column(
            children: [
              // Calendar Header with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2100),
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (_dayHasEvents(date, studyProvider, examProvider, todoProvider)) {
                        return Positioned(
                          bottom: 1,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                  calendarStyle: CalendarStyle(
                    defaultDecoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    weekendDecoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    selectedTextStyle: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                    todayDecoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    outsideDecoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                    outsideTextStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    defaultTextStyle: const TextStyle(color: Colors.white),
                    weekendTextStyle: const TextStyle(color: Colors.white70),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.white70, fontSize: 12),
                    weekendStyle: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Selected Date Header
                      if (_selectedDay != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            DateFormat('EEEE, d MMMM y', 'tr_TR').format(_selectedDay!),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),

                      // Desktop: Side-by-side layout
                      if (!isMobile && _selectedDay != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildSessionsList(studyProvider, examProvider),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: _buildTodosList(todoProvider),
                            ),
                          ],
                        )
                      // Mobile: Stacked layout
                      else if (isMobile && _selectedDay != null)
                        Column(
                          children: [
                            _buildSessionsList(studyProvider, examProvider),
                            const SizedBox(height: 16),
                            _buildTodosList(todoProvider),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSessionsList(StudyProvider studyProvider, ExamProvider examProvider) {
    if (_selectedDay == null) return const SizedBox();

    final sessions = studyProvider.getSessionsForDay(_selectedDay!);
    final exams = examProvider.getExamsForDay(_selectedDay!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.school, color: AppTheme.successColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Çalışma Seansları',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (sessions.isEmpty && exams.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(Icons.menu_book_outlined, size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Bu gün çalışma yok',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                ...sessions.map((session) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.05),
                          border: Border.all(color: AppTheme.successColor.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${session.subject} - ${session.topic}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    session.durationFormatted,
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.successColor),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${session.correctAnswers}D ${session.wrongAnswers}Y ${session.emptyAnswers}B',
                                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                ),
                                Text(
                                  '${session.netScore.toStringAsFixed(1)} Net',
                                  style: TextStyle(fontSize: 10, color: AppTheme.infoColor, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
                ...exams.map((exam) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withOpacity(0.08),
                          border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    exam.examName,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.warningColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    exam.examType,
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange[700]),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${exam.totalCorrect}D ${exam.totalWrong}Y',
                                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                ),
                                Text(
                                  '${exam.netScore.toStringAsFixed(1)} Net',
                                  style: TextStyle(fontSize: 10, color: AppTheme.infoColor, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTodosList(TodoProvider todoProvider) {
    if (_selectedDay == null) return const SizedBox();

    final dayTodos = todoProvider.getTodosForDay(_selectedDay!);
    final allCompleted = dayTodos.isNotEmpty && dayTodos.every((t) => t.isCompleted);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.checklist_rtl, color: AppTheme.primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Yapılacaklar',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (allCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.15),
                    border: Border.all(color: AppTheme.successColor.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.successColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Tamamlandı',
                        style: TextStyle(fontSize: 10, color: AppTheme.successColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (dayTodos.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(Icons.event_note, size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Bu gün için etkinlik yok',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: dayTodos
                  .map((todo) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: todo.isCompleted ? AppTheme.successColor.withOpacity(0.05) : Theme.of(context).colorScheme.surface,
                            border: Border.all(
                              color: todo.isCompleted ? AppTheme.successColor.withOpacity(0.3) : Colors.grey[200]!,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (todo.notes != null && todo.notes!.isNotEmpty) {
                                  _showTodoDetailsDialog(todo);
                                } else {
                                  todoProvider.toggleTodoCompletion(todo.id);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Checkbox(
                                        value: todo.isCompleted,
                                        onChanged: (value) {
                                          todoProvider.toggleTodoCompletion(todo.id);
                                        },
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        activeColor: AppTheme.successColor,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            todo.title,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                              color: todo.isCompleted ? Colors.grey[500] : Theme.of(context).colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            todo.subject,
                                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                          ),
                                          if (todo.notes != null && todo.notes!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Text(
                                                todo.notes!.length > 60 ? '${todo.notes!.substring(0, 60)}...' : todo.notes!,
                                                style: TextStyle(fontSize: 9, color: AppTheme.primaryColor, fontStyle: FontStyle.italic),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: todo.priority == 2
                                            ? AppTheme.errorColor.withOpacity(0.15)
                                            : todo.priority == 1
                                                ? AppTheme.warningColor.withOpacity(0.15)
                                                : AppTheme.successColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        todo.priority == 2 ? 'Y' : todo.priority == 1 ? 'O' : 'D',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: todo.priority == 2
                                              ? AppTheme.errorColor
                                              : todo.priority == 1
                                                  ? Colors.orange[700]
                                                  : AppTheme.successColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  void _showTodoDetailsDialog(TodoItem todo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(todo.title),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ders',
                                style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600),
                              ),
                              Text(
                                todo.subject,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Konu',
                                style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600),
                              ),
                              Text(
                                todo.topic,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey[300]),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Not',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          todo.notes ?? '',
                          style: const TextStyle(fontSize: 14, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey[300]),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Durum',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600),
                            ),
                            Text(
                              todo.isCompleted ? 'Tamamlandı ✓' : 'Beklemede',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: todo.isCompleted ? AppTheme.successColor : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Öncelik',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600),
                            ),
                            Text(
                              todo.priority == 2 ? 'Yüksek' : todo.priority == 1 ? 'Orta' : 'Düşük',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: todo.priority == 2 ? AppTheme.errorColor : todo.priority == 1 ? Colors.orange : AppTheme.successColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }


}
