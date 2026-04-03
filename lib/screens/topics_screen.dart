import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/subjects_data.dart';
import '../models/topic_status.dart';
import '../providers/topic_provider.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  String _selectedSubject = SubjectsData.getAllSubjects().keys.first;

  @override
  Widget build(BuildContext context) {
    final allSubjects = SubjectsData.getAllSubjects().keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konu Takibi'),
      ),
      body: Column(
        children: [
          // Ders Seçici
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: allSubjects.length,
              itemBuilder: (context, index) {
                final subject = allSubjects[index];
                final isSelected = subject == _selectedSubject;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(subject),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedSubject = subject;
                        });
                      }
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const Divider(height: 1),
          
          // Konu Listesi
          Expanded(
            child: Consumer<TopicProvider>(
              builder: (context, provider, child) {
                final topics = provider.getTopicsForSubject(_selectedSubject);

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final topicStatus = topics[index];
                    
                    Color statusColor = Colors.grey;
                    IconData statusIcon = Icons.radio_button_unchecked;
                    
                    if (topicStatus.level == TopicLevel.completed) {
                      statusColor = Colors.green;
                      statusIcon = Icons.check_circle;
                    } else if (topicStatus.level == TopicLevel.inProgress) {
                      statusColor = Colors.orange;
                      statusIcon = Icons.play_circle_filled;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: Icon(statusIcon, color: statusColor),
                        title: Text(
                          topicStatus.topic,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: topicStatus.level == TopicLevel.completed 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                        ),
                        subtitle: Text('Başarı: %${topicStatus.successRate.toStringAsFixed(1)} | Çözülen: ${topicStatus.totalQuestions}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStat('Doğru', topicStatus.correctAnswers, Colors.green),
                                    _buildStat('Yanlış', topicStatus.wrongAnswers, Colors.red),
                                    _buildStat('Boş', topicStatus.emptyAnswers, Colors.grey),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => provider.updateTopicLevel(
                                          _selectedSubject, topicStatus.topic, TopicLevel.notStarted),
                                      child: const Text('Başlanmadı'),
                                    ),
                                    OutlinedButton(
                                      onPressed: () => provider.updateTopicLevel(
                                          _selectedSubject, topicStatus.topic, TopicLevel.inProgress),
                                      child: const Text('Devam Ediyor'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => provider.updateTopicLevel(
                                          _selectedSubject, topicStatus.topic, TopicLevel.completed),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      child: const Text('Tamamlandı'),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(value.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
