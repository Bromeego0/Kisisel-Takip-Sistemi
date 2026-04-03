import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../data/subjects_data.dart';
import '../models/todo_item.dart';
import '../providers/todo_provider.dart';

void showAddTodoDialog(BuildContext context, {DateTime? initialDate}) {
  final titleController = TextEditingController();
  final notesController = TextEditingController();
  String? selectedSubject;
  String? selectedTopic;
  int priority = 1;
  DateTime selectedDate = initialDate ?? DateTime.now();
  final allSubjects = SubjectsData.getAllSubjects();

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Görev Ekle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Yapılacak',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedSubject,
                items: allSubjects.keys.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() {
                  selectedSubject = v;
                  selectedTopic = null;
                }),
                decoration: const InputDecoration(labelText: 'Ders', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              if (selectedSubject != null)
                DropdownButtonFormField<String>(
                  value: selectedTopic,
                  items: (allSubjects[selectedSubject] ?? []).map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => selectedTopic = v),
                  decoration: const InputDecoration(labelText: 'Konu', border: OutlineInputBorder()),
                ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Tarih'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: priority,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Düşük ◇')),
                  DropdownMenuItem(value: 1, child: Text('Orta ◇◇')),
                  DropdownMenuItem(value: 2, child: Text('Yüksek ◇◇◇')),
                ],
                onChanged: (v) => setState(() => priority = v ?? 1),
                decoration: const InputDecoration(labelText: 'Öncelik', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Not (İsteğe Bağlı)',
                  hintText: 'Örn: Fizik ders kitabı ödevi sayfa 120',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && selectedSubject != null && selectedTopic != null) {
                final todo = TodoItem(
                  id: const Uuid().v4(),
                  title: titleController.text,
                  subject: selectedSubject!,
                  topic: selectedTopic!,
                  dueDate: selectedDate,
                  priority: priority,
                  notes: notesController.text.isEmpty ? null : notesController.text,
                );
                context.read<TodoProvider>().addTodo(todo);
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    ),
  );
}
