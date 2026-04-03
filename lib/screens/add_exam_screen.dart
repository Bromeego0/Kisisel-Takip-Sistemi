import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../data/subjects_data.dart';
import '../models/exam_record.dart';
import '../providers/exam_provider.dart';

class AddExamScreen extends StatefulWidget {
  const AddExamScreen({super.key});

  @override
  State<AddExamScreen> createState() => _AddExamScreenState();
}

class SubjectInputData {
  String? subject;
  final TextEditingController correctController = TextEditingController();
  final TextEditingController wrongController = TextEditingController();
  final TextEditingController emptyController = TextEditingController();

  void dispose() {
    correctController.dispose();
    wrongController.dispose();
    emptyController.dispose();
  }
}

class _AddExamScreenState extends State<AddExamScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  final TextEditingController _examNameController = TextEditingController();
  String _examType = 'TYT'; // Default
  bool _isGeneralExam = false; // Quick mode for general exams
  final TextEditingController _generalNetController = TextEditingController();

  final List<SubjectInputData> _subjectInputs = [SubjectInputData()];
  List<String> _allSubjects = [];
  List<String> _availableExamTypes = [];

  @override
  void initState() {
    super.initState();
    _allSubjects = SubjectsData.getAllSubjects().keys.toList();
    _availableExamTypes = ['TYT', 'AYT', 'LGS', 'ALES', 'KPSS', 'Diğer'];
  }

  @override
  void dispose() {
    _examNameController.dispose();
    _generalNetController.dispose();
    for (var input in _subjectInputs) {
      input.dispose();
    }
    super.dispose();
  }

  void _addSubjectInput() {
    setState(() {
      _subjectInputs.add(SubjectInputData());
    });
  }

  void _removeSubjectInput(int index) {
    if (_subjectInputs.length > 1) {
      setState(() {
        _subjectInputs[index].dispose();
        _subjectInputs.removeAt(index);
      });
    }
  }

  void _saveExam() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen eksik alanları doldurun')),
      );
      return;
    }

    // General exam mode
    if (_isGeneralExam) {
      double net = double.tryParse(_generalNetController.text) ?? 0;
      final exam = ExamRecord(
        id: const Uuid().v4(),
        date: _selectedDate,
        examName: _examNameController.text.trim().isEmpty ? 'İsimsiz Deneme' : _examNameController.text.trim(),
        examType: _examType,
        results: [],
        totalCorrect: 0,
        totalWrong: 0,
        totalEmpty: 0,
        netScore: net,
      );
      
      context.read<ExamProvider>().addExam(exam);
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Deneme başarıyla kaydedildi!')),
      );
      return;
    }

    // Detailed mode
    int totalCorrect = 0, totalWrong = 0, totalEmpty = 0;
    double totalNet = 0;
    List<ExamSubjectResult> results = [];

    for (var input in _subjectInputs) {
      if (input.subject == null) continue;

      int c = int.tryParse(input.correctController.text) ?? 0;
      int w = int.tryParse(input.wrongController.text) ?? 0;
      int e = int.tryParse(input.emptyController.text) ?? 0;
      double net = c - (w * 0.25);

      totalCorrect += c;
      totalWrong += w;
      totalEmpty += e;
      totalNet += net;

      results.add(ExamSubjectResult(
        subject: input.subject!,
        correct: c,
        wrong: w,
        empty: e,
        net: net,
        weakTopics: [], // Can be enhanced to select weak topics
      ));
    }

    final exam = ExamRecord(
      id: const Uuid().v4(),
      date: _selectedDate,
      examName: _examNameController.text.trim().isEmpty ? 'İsimsiz Deneme' : _examNameController.text.trim(),
      examType: _examType,
      results: results,
      totalCorrect: totalCorrect,
      totalWrong: totalWrong,
      totalEmpty: totalEmpty,
      netScore: totalNet,
    );

    context.read<ExamProvider>().addExam(exam);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);

    messenger.showSnackBar(
      const SnackBar(content: Text('Deneme başarıyla kaydedildi!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deneme Sınavı Ekle'),
        backgroundColor: Colors.orange[400],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Deneme Modu Seçimi
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isGeneralExam = false),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: !_isGeneralExam ? Colors.blue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.list_alt,
                                      color: !_isGeneralExam ? Colors.white : Colors.blue,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Detaylı',
                                      style: TextStyle(
                                        color: !_isGeneralExam ? Colors.white : Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isGeneralExam = true),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _isGeneralExam ? Colors.blue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.bolt,
                                      color: _isGeneralExam ? Colors.white : Colors.blue,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Hızlı',
                                      style: TextStyle(
                                        color: _isGeneralExam ? Colors.white : Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isGeneralExam
                            ? 'Sadece genel neti girin'
                            : 'Ders bazında netleri girin',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Deneme Adı
              TextFormField(
                controller: _examNameController,
                decoration: const InputDecoration(
                  labelText: 'Deneme Adı (Örn: TYT Genel Deneme 5)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Gerekli' : null,
              ),
              const SizedBox(height: 16),

              // Tür ve Tarih Yan Yana
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Türü',
                        border: OutlineInputBorder(),
                      ),
                      value: _examType,
                      items: _availableExamTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() { _examType = val!; });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() { _selectedDate = picked; });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tarih',
                          border: OutlineInputBorder(),
                        ),
                        child: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (_isGeneralExam) ...[
                // Genel Net Girişi
                TextFormField(
                  controller: _generalNetController,
                  decoration: const InputDecoration(
                    labelText: 'Genel Net',
                    border: OutlineInputBorder(),
                    hintText: '180.5',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Lütfen net girin';
                    if (double.tryParse(val) == null) return 'Geçerli bir sayı girin';
                    return null;
                  },
                ),
              ] else ...[
                const Text('Ders Netleri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...List.generate(_subjectInputs.length, (index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(labelText: 'Ders Seçin', isDense: true),
                                  value: _subjectInputs[index].subject,
                                  items: _allSubjects.map((String subject) {
                                    return DropdownMenuItem<String>(
                                      value: subject,
                                      child: Text(subject, overflow: TextOverflow.ellipsis),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() { _subjectInputs[index].subject = val; });
                                  },
                                  validator: (val) => val == null ? 'Seçiniz' : null,
                                ),
                              ),
                              if (_subjectInputs.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _removeSubjectInput(index),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _subjectInputs[index].correctController,
                                  decoration: const InputDecoration(labelText: 'D', isDense: true, fillColor: Color(0xFFE8F5E9)),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _subjectInputs[index].wrongController,
                                  decoration: const InputDecoration(labelText: 'Y', isDense: true, fillColor: Color(0xFFFFEBEE)),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _subjectInputs[index].emptyController,
                                  decoration: const InputDecoration(labelText: 'B', isDense: true, fillColor: Color(0xFFEEEEEE)),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: _addSubjectInput,
                  icon: const Icon(Icons.add),
                  label: const Text('Başka Ders Ekle'),
                ),
              ],
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveExam,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Kaydet', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
