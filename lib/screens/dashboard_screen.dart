import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';


import '../providers/study_provider.dart';
import '../providers/exam_provider.dart';
import '../providers/todo_provider.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';
import '../models/study_session.dart';
import '../widgets/empty_state_widget.dart';

import '../theme/app_theme.dart';

// Motivasyon Quotes — YKS temalı Türkçe
const List<String> motivationQuotes = [
  '🎯 Başarı, her gün atılan küçük adımların toplamıdır. Bugün de bir adım at!',
  '💪 Sınav sadece bir kapı, onu açacak anahtar senin elinde.',
  '🔥 Her çözdüğün soru seni hedefe bir adım daha yaklaştırıyor.',
  '✨ Bugün verdiğin emek, yarın seni gülümsetecek.',
  '🚀 Hedefine odaklan, geri kalan her şey yerli yerine oturacak.',
  '📚 Binlerce kişi aynı sınava giriyor ama hazırlığını yapan kazanıyor.',
];

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    final theme = Theme.of(context);
    final cardBg = theme.colorScheme.surface;
    final textColor = theme.colorScheme.onSurface;
    final subTextColor = theme.colorScheme.onSurface.withOpacity(0.6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders Çalışma Paneli'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: Consumer4<StudyProvider, ExamProvider, TodoProvider, NoteProvider>(
        builder: (context, studyProvider, examProvider, todoProvider, noteProvider, child) {
          final today = DateTime.now();
          final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isMobile
                      ? _buildMobileLayout(context, studyProvider, examProvider, todoProvider, noteProvider, today, startOfWeek)
                      : _buildDesktopLayout(context, studyProvider, examProvider, todoProvider, noteProvider, today, startOfWeek),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Mobile Layout (vertical stacking)
  Widget _buildMobileLayout(
    BuildContext context,
    StudyProvider studyProvider,
    ExamProvider examProvider,
    TodoProvider todoProvider,
    NoteProvider noteProvider,
    DateTime today,
    DateTime startOfWeek,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPerformanceSection(studyProvider, today),
        const SizedBox(height: 20),
        _buildStreakAndGoalCard(studyProvider, today),
        const SizedBox(height: 20),
        _buildNetCalculationCard(studyProvider, today),
        const SizedBox(height: 20),
        _buildTodayCourseBreakdown(studyProvider, today),
        const SizedBox(height: 20),
        _buildRecentActivities(studyProvider, examProvider, today),
        const SizedBox(height: 20),
        _buildPieChart(studyProvider),
        const SizedBox(height: 20),
        _buildCourseChart(studyProvider),
        const SizedBox(height: 20),
        _buildTasksPanel(todoProvider, today),
        const SizedBox(height: 20),
        _buildNotesPanel(noteProvider),
        const SizedBox(height: 20),
        _buildMotivationQuote(),
        const SizedBox(height: 88),
      ],
    );
  }

  // Desktop Layout (improved columns)
  Widget _buildDesktopLayout(
    BuildContext context,
    StudyProvider studyProvider,
    ExamProvider examProvider,
    TodoProvider todoProvider,
    NoteProvider noteProvider,
    DateTime today,
    DateTime startOfWeek,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPerformanceSection(studyProvider, today),
        const SizedBox(height: 24),
        _buildStreakAndGoalCard(studyProvider, today),
        const SizedBox(height: 24),
        _buildNetCalculationCard(studyProvider, today),
        const SizedBox(height: 24),
        _buildTodayCourseBreakdown(studyProvider, today),
        const SizedBox(height: 24),
        _buildRecentActivities(studyProvider, examProvider, today),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: _buildPieChart(studyProvider),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: _buildTasksPanel(todoProvider, today),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildCourseChart(studyProvider),
        const SizedBox(height: 24),
        _buildNotesPanel(noteProvider),
        const SizedBox(height: 24),
        _buildMotivationQuote(),
        const SizedBox(height: 88),
      ],
    );
  }

  // ───────────────────────────────────────
  // Performance Section (D/Y/B/Toplam Cards + Timer)
  // ───────────────────────────────────────
  Widget _buildPerformanceSection(StudyProvider studyProvider, DateTime today) {
    final todaysSessions = studyProvider.getSessionsForDay(today);
    int totalCorrect = todaysSessions.fold(0, (sum, s) => sum + s.correctAnswers);
    int totalWrong = todaysSessions.fold(0, (sum, s) => sum + s.wrongAnswers);
    int totalBlank = todaysSessions.fold(0, (sum, s) => sum + (s.questionsSolved - s.correctAnswers - s.wrongAnswers));
    int totalDuration = todaysSessions.fold(0, (sum, s) => sum + s.durationMinutes);
    int totalSolved = todaysSessions.fold(0, (sum, s) => sum + s.questionsSolved);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPerformanceCard(
                title: 'Doğru',
                value: '$totalCorrect',
                subtitle: 'Soru',
                icon: Icons.check_circle_outline,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPerformanceCard(
                title: 'Yanlış',
                value: '$totalWrong',
                subtitle: 'Soru',
                icon: Icons.cancel_outlined,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPerformanceCard(
                title: 'Boş',
                value: '$totalBlank',
                subtitle: 'Soru',
                icon: Icons.help_outline,
                color: AppTheme.warningColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPerformanceCard(
                title: 'Toplam',
                value: '$totalSolved',
                subtitle: 'Soru',
                icon: Icons.list_alt,
                color: AppTheme.infoColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDurationDisplay(totalDuration),
      ],
    );
  }

  Widget _buildPerformanceCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 9, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationDisplay(int minutes) {
    int hours = minutes ~/ 60;
    int mins = minutes % 60;

    String formatDuration() {
      if (minutes == 0) return '0:00:00';
      return '${hours.toString().padLeft(1, '0')}:${mins.toString().padLeft(2, '0')}:00';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.secondaryColor, AppTheme.infoColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.infoColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.timer, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Çalışma Süresi',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    formatDuration(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Bugün',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────
  // Streak & Günlük Hedef
  // ───────────────────────────────────────
  Widget _buildStreakAndGoalCard(StudyProvider studyProvider, DateTime today) {
    final streak = studyProvider.getStudyStreak();
    final todaysSessions = studyProvider.getSessionsForDay(today);
    final todayMinutes = todaysSessions.fold(0, (sum, s) => sum + s.durationMinutes);
    const dailyGoal = 120;
    final percentage = ((todayMinutes / dailyGoal) * 100).clamp(0, 100);

    return Row(
      children: [
        // Streak Kartı
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Çalışma Serisi',
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '🔥 $streak',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                const SizedBox(height: 6),
                Text(
                  '$streak gün üst üste',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Günlük Hedef Kartı
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.flag, color: AppTheme.primaryColor, size: 18),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Günlük Hedef',
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage >= 100 ? AppTheme.successColor : AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: percentage >= 100 ? AppTheme.successColor : AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${todayMinutes}dk / ${dailyGoal}dk',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────
  // Net Hesabı Kartı
  // ───────────────────────────────────────
  Widget _buildNetCalculationCard(StudyProvider studyProvider, DateTime today) {
    final todaysSessions = studyProvider.getSessionsForDay(today);
    int totalCorrect = todaysSessions.fold(0, (sum, s) => sum + s.correctAnswers);
    int totalWrong = todaysSessions.fold(0, (sum, s) => sum + s.wrongAnswers);
    int totalBlank = todaysSessions.fold(0, (sum, s) => sum + (s.questionsSolved - s.correctAnswers - s.wrongAnswers));
    int totalSolved = todaysSessions.fold(0, (sum, s) => sum + s.questionsSolved);

    double netScore = totalCorrect - (totalWrong / 4);
    bool isPositive = netScore >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: AppTheme.warningColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calculate, color: Colors.amber[700], size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Net Hesabı',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                'D − (Y÷4)',
                style: TextStyle(fontSize: 10, color: Colors.grey[500], fontStyle: FontStyle.italic),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (totalSolved == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Henüz çalışma kaydı yok',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
            )
          else
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        isPositive ? AppTheme.successColor.withOpacity(0.15) : AppTheme.errorColor.withOpacity(0.15),
                        isPositive ? AppTheme.successColor.withOpacity(0.05) : AppTheme.errorColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPositive ? AppTheme.successColor.withOpacity(0.4) : AppTheme.errorColor.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Toplam Net',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w600),
                      ),
                      Text(
                        netScore.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNetStatItem('D', '$totalCorrect', AppTheme.successColor),
                    _buildNetStatItem('Y', '$totalWrong', AppTheme.errorColor),
                    _buildNetStatItem('B', '$totalBlank', AppTheme.warningColor),
                    _buildNetStatItem('Toplam', '$totalSolved', AppTheme.infoColor),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNetStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  // ───────────────────────────────────────
  // Bugün Ders Bazlı Özet (YENİ)
  // ───────────────────────────────────────
  Widget _buildTodayCourseBreakdown(StudyProvider studyProvider, DateTime today) {
    final breakdown = studyProvider.getTodayCourseBreakdown();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.school, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Bugün Çalışılan Dersler',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (breakdown.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Bugün henüz çalışma yok',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: breakdown.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getCourseColor(entry.key).withOpacity(0.15),
                        _getCourseColor(entry.key).withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(color: _getCourseColor(entry.key).withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getCourseColor(entry.key),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getCourseColor(entry.key),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getCourseColor(entry.key).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${entry.value}dk',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getCourseColor(entry.key),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────
  // Son Yapılanlar
  // ───────────────────────────────────────
  Widget _buildRecentActivities(StudyProvider studyProvider, ExamProvider examProvider, DateTime today) {
    final todaysSessions = studyProvider.getSessionsForDay(today);
    final todaysExams = examProvider.getExamsForDay(today);
    List<dynamic> allActivities = [...todaysSessions, ...todaysExams];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                child: Icon(Icons.history, color: AppTheme.successColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Son Yapılanlar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          allActivities.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.book,
                  title: 'Henüz çalışma yok',
                  subtitle: 'İlk çalışmanı başlatmak için + butonuna tıkla',
                  iconColor: AppTheme.infoColor,
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allActivities.take(5).length,
                  itemBuilder: (context, index) {
                    final activity = allActivities[index];
                    if (activity is StudySession) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.infoColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(Icons.book, color: AppTheme.infoColor, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${activity.subject} - ${activity.topic}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${activity.durationFormatted} | ${activity.correctAnswers}D ${activity.wrongAnswers}Y',
                                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${activity.correctAnswers}D',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.successColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.warningColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(Icons.assignment, color: Colors.orange[600], size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity.examName,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${activity.examType} Denemesi',
                                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.warningColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${activity.netScore} Net',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────
  // Çalışma Dağılımı Pie Chart
  // ───────────────────────────────────────
  Widget _buildPieChart(StudyProvider studyProvider) {
    final courseData = _getCourseData(studyProvider);
    final totalMinutes = courseData.values.fold(0, (sum, val) => sum + val);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.pie_chart, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Çalışma Dağılımı',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (totalMinutes == 0)
            EmptyStateWidget(
              icon: Icons.bar_chart_rounded,
              title: 'Henüz veri yok',
              subtitle: 'Çalışma ekledikçe grafik oluşacak',
              iconColor: AppTheme.primaryColor,
            )
          else
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: courseData.entries.map((entry) {
                    final percentage = (entry.value / totalMinutes) * 100;
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${percentage.toStringAsFixed(0)}%',
                      radius: 60,
                      color: _getCourseColor(entry.key),
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: courseData.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getCourseColor(entry.key),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    entry.key,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────
  // Ders Temeline Göre Analiz (Bar Chart)
  // ───────────────────────────────────────
  Widget _buildCourseChart(StudyProvider studyProvider) {
    final courseData = _getCourseData(studyProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.bar_chart_rounded, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ders Temeline Göre Analiz',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (courseData.isEmpty)
            EmptyStateWidget(
              icon: Icons.analytics,
              title: 'Henüz veri yok',
              subtitle: 'Analiz için en az 1 çalışma kaydı gerekli',
              iconColor: AppTheme.primaryColor,
            )
          else
            ...courseData.entries.map((entry) {
              final course = entry.key;
              final minutes = entry.value;
              final hours = minutes / 60;
              final maxHours = (courseData.values.reduce((a, b) => a > b ? a : b) / 60) * 1.2;
              final percentage = (hours / maxHours).clamp(0, 1);

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          course,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getCourseColor(course).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${hours.toStringAsFixed(1)}s',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getCourseColor(course),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: percentage.toDouble(),
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(_getCourseColor(course)),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ───────────────────────────────────────
  // Görevler Listesi (Tasks Panel)
  // ───────────────────────────────────────
  Widget _buildTasksPanel(TodoProvider todoProvider, DateTime today) {
    final todayTodos = todoProvider.getTodosForDay(today);
    final completedCount = todayTodos.where((t) => t.isCompleted).length;
    final allCompleted = todayTodos.isNotEmpty && todayTodos.every((t) => t.isCompleted);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                    'Görevler',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (allCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.15),
                    border: Border.all(color: AppTheme.successColor.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.successColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Tamamlandı',
                        style: TextStyle(fontSize: 11, color: AppTheme.successColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              else if (todayTodos.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withOpacity(0.1),
                    border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$completedCount/${todayTodos.length}',
                    style: TextStyle(fontSize: 12, color: AppTheme.infoColor, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (todayTodos.isEmpty)
            // Empty state — "Etkinlik Giriniz"
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_note, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'Etkinlik Giriniz',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bugün için görev eklenmemiş',
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todayTodos.length,
              itemBuilder: (context, index) {
                final todo = todayTodos[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
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
                          todoProvider.toggleTodoCompletion(todo.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: todo.isCompleted,
                                  onChanged: (value) {
                                    todoProvider.toggleTodoCompletion(todo.id);
                                  },
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  activeColor: AppTheme.successColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      todo.title,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                        color: todo.isCompleted ? Colors.grey[500] : Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    if (todo.subject.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          todo.subject,
                                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
                );
              },
            ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────
  // Notlar Paneli
  // ───────────────────────────────────────
  Widget _buildNotesPanel(NoteProvider noteProvider) {
    final notes = noteProvider.notes.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                      color: AppTheme.warningColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.note_alt_rounded, color: Colors.amber[600], size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Notlar ve Planlar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.successColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _showAddNoteDialog();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Text(
                        '+ Ekle',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (notes.isEmpty)
            EmptyStateWidget(
              icon: Icons.note_add,
              title: 'Not yok',
              subtitle: 'Not eklemek için yukarıdaki + düğmesine tıkla',
              iconColor: AppTheme.warningColor,
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => _showNoteDetailDialog(note),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (note.subject != null && note.subject!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                note.subject!,
                                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────
  // Motivasyon Quote — Mor Gradient
  // ───────────────────────────────────────
  Widget _buildMotivationQuote() {
    final today = DateTime.now();
    final quoteIndex = today.day % motivationQuotes.length;
    final quote = motivationQuotes[quoteIndex];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.format_quote, color: Colors.white70, size: 32),
          const SizedBox(height: 12),
          Text(
            quote,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────
  // Helper Methods
  // ───────────────────────────────────────
  Map<String, int> _getCourseData(StudyProvider studyProvider) {
    final courseMinutes = <String, int>{};
    for (var session in studyProvider.sessions) {
      courseMinutes[session.subject] = (courseMinutes[session.subject] ?? 0) + session.durationMinutes;
    }
    return Map.fromEntries(
      courseMinutes.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  Color _getCourseColor(String course) {
    const colors = {
      'Matematik': AppTheme.primaryColor,
      'Matematik (TYT)': AppTheme.primaryColor,
      'Matematik (AYT)': Color(0xFF8B7FFF),
      'Türkçe': AppTheme.errorColor,
      'Fen': AppTheme.successColor,
      'Fizik (TYT)': Color(0xFF4ECDC4),
      'Fizik (AYT)': Color(0xFF2DB5A0),
      'Kimya (TYT)': Color(0xFFFF9500),
      'Kimya (AYT)': Color(0xFFE08600),
      'Biyoloji (TYT)': Color(0xFF9B59B6),
      'Biyoloji (AYT)': Color(0xFF8E44AD),
      'Sosyal': AppTheme.warningColor,
      'Coğrafya': AppTheme.secondaryColor,
      'Diğer': Color(0xFFB1B1B1),
    };
    return colors[course] ?? Colors.grey;
  }

  // ───────────────────────────────────────
  // Dialogs
  // ───────────────────────────────────────
  void _showNoteDetailDialog(Note note) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(note.title),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (note.subject != null && note.subject!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Ders: ${note.subject}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
                      ),
                    ),
                  Text(
                    note.content,
                    style: const TextStyle(fontSize: 14, height: 1.5),
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
            ElevatedButton.icon(
              onPressed: () {
                Provider.of<NoteProvider>(context, listen: false).deleteNote(note.id);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Sil'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            ),
          ],
        );
      },
    );
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String title = '';
        String subject = '';
        String content = '';

        return AlertDialog(
          title: const Text('Not Ekle'),
          content: SizedBox(
            width: 300,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Başlık',
                      hintText: 'Not başlığını girin',
                    ),
                    onChanged: (value) => title = value,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Ders',
                      hintText: 'Ders adını girin',
                    ),
                    onChanged: (value) => subject = value,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'İçerik',
                      hintText: 'Not içeriğini girin',
                    ),
                    maxLines: 3,
                    onChanged: (value) => content = value,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (title.isNotEmpty) {
                  final note = Note(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: title,
                    subject: subject.isEmpty ? 'Genel' : subject,
                    content: content,
                  );
                  Provider.of<NoteProvider>(context, listen: false).addNote(note);
                  Navigator.pop(context);
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }
}
