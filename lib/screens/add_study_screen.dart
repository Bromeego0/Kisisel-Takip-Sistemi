import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../data/subjects_data.dart';
import '../models/study_session.dart';
import '../providers/study_provider.dart';

class AddStudyScreen extends StatefulWidget {
  const AddStudyScreen({super.key});

  @override
  State<AddStudyScreen> createState() => _AddStudyScreenState();
}

class _AddStudyScreenState extends State<AddStudyScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  String? _selectedSubject;
  String? _selectedTopic;

  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _correctController = TextEditingController();
  final TextEditingController _wrongController = TextEditingController();
  final TextEditingController _emptyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Map<String, List<String>> _subjects = {};

  @override
  void initState() {
    super.initState();
    _subjects = SubjectsData.getAllSubjects();
  }

  @override
  void dispose() {
    _durationController.dispose();
    _correctController.dispose();
    _wrongController.dispose();
    _emptyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveSession() {
    if (_formKey.currentState!.validate() && _selectedSubject != null && _selectedTopic != null) {
      final correct = int.tryParse(_correctController.text) ?? 0;
      final wrong = int.tryParse(_wrongController.text) ?? 0;
      final empty = int.tryParse(_emptyController.text) ?? 0;
      final total = correct + wrong + empty;

      // Parse duration from "HH:MM" format
      int durationMinutes = 0;
      try {
        final parts = _durationController.text.split(':');
        if (parts.length == 2) {
          int hours = int.parse(parts[0]);
          int minutes = int.parse(parts[1]);
          durationMinutes = (hours * 60) + minutes;
        } else if (parts.length == 1) {
          durationMinutes = int.parse(parts[0]);
        }
      } catch (e) {
        durationMinutes = int.tryParse(_durationController.text) ?? 0;
      }

      final session = StudySession(
        id: const Uuid().v4(),
        date: _selectedDate,
        subject: _selectedSubject!,
        topic: _selectedTopic!,
        durationMinutes: durationMinutes,
        questionsSolved: total,
        correctAnswers: correct,
        wrongAnswers: wrong,
        emptyAnswers: empty,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      context.read<StudyProvider>().addSession(session);
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      
      messenger.showSnackBar(
        const SnackBar(content: Text('Çalışma başarıyla kaydedildi!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm zorunlu alanları doldurun.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders Çalışması Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tarih Seçimi
              ListTile(
                title: const Text('Tarih'),
                subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Ders Seçimi
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Ders Seçin'),
                value: _selectedSubject,
                items: _subjects.keys.map((String subject) {
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSubject = newValue;
                    _selectedTopic = null; // Reset topic when subject changes
                  });
                },
                validator: (value) => value == null ? 'Lütfen ders seçin' : null,
              ),
              const SizedBox(height: 16),

              // Konu Seçimi
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Konu Seçin'),
                value: _selectedTopic,
                items: _selectedSubject == null
                    ? []
                    : _subjects[_selectedSubject!]!.map((String topic) {
                        return DropdownMenuItem<String>(
                          value: topic,
                          child: Text(topic),
                        );
                      }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTopic = newValue;
                  });
                },
                validator: (value) => value == null ? 'Lütfen konu seçin' : null,
              ),
              const SizedBox(height: 16),

              // Süre
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(
                  labelText: 'Çalışma Süresi',
                  hintText: 'Saat:Dakika (örn: 1:30 veya 90)',
                  suffixText: 's:d',
                  helperText: 'Saat:Dakika veya toplam dakika cinsinden girin',
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen süreyi girin';
                  }
                  try {
                    if (value.contains(':')) {
                      final parts = value.split(':');
                      if (parts.length != 2) throw Exception();
                      int.parse(parts[0]);
                      int.parse(parts[1]);
                    } else {
                      int.parse(value);
                    }
                    return null;
                  } catch (e) {
                    return 'Geçerli format girin (örn: 1:30 veya 90)';
                  }
                },
              ),
              const SizedBox(height: 24),

              // Soru İstatistikleri
              const Text('Soru İstatistikleri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _correctController,
                      decoration: const InputDecoration(labelText: 'Doğru', fillColor: Color(0xFFE8F5E9)),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _wrongController,
                      decoration: const InputDecoration(labelText: 'Yanlış', fillColor: Color(0xFFFFEBEE)),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _emptyController,
                      decoration: const InputDecoration(labelText: 'Boş', fillColor: Color(0xFFEEEEEE)),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notlar
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notlar (İsteğe bağlı)',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),

              // Kaydet Butonu
              ElevatedButton(
                onPressed: _saveSession,
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
