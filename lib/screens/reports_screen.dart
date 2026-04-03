import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../providers/exam_provider.dart';
import '../providers/study_provider.dart';
import '../providers/todo_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistikler & Analizler'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[700],
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Günlük'),
                  Tab(text: 'Haftalık'),
                  Tab(text: 'Aylık'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Consumer3<StudyProvider, ExamProvider, TodoProvider>(
        builder: (context, studyProvider, examProvider, todoProvider, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildDailyReport(studyProvider, examProvider, todoProvider),
              _buildWeeklyReport(studyProvider, examProvider),
              _buildMonthlyReport(studyProvider, examProvider),
            ],
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────
  // GÜNLÜK RAPOR
  // ───────────────────────────────────────
  Widget _buildDailyReport(StudyProvider studyProvider, ExamProvider examProvider, TodoProvider todoProvider) {
    final today = DateTime.now();
    final sessions = studyProvider.getSessionsForDay(today);
    final totalMinutes = sessions.fold(0, (sum, s) => sum + s.durationMinutes);
    final totalCorrect = sessions.fold(0, (sum, s) => sum + s.correctAnswers);
    final totalWrong = sessions.fold(0, (sum, s) => sum + s.wrongAnswers);
    final totalBlank = sessions.fold(0, (sum, s) => sum + (s.questionsSolved - s.correctAnswers - s.wrongAnswers));
    final totalSolved = sessions.fold(0, (sum, s) => sum + s.questionsSolved);
    final netScore = totalCorrect - (totalWrong / 4);
    final streak = studyProvider.getStudyStreak();
    final courseBreakdown = studyProvider.getTodayCourseBreakdown();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date header
          Text(
            DateFormat('d MMMM y, EEEE', 'tr_TR').format(today),
            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          // Streak badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[400]!, Colors.deepOrange[400]!],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Çalışma Serisi',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    Text(
                      '$streak gün üst üste',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Summary stats
          if (sessions.isEmpty)
            EmptyStateWidget(
              icon: Icons.today,
              title: 'Bugün çalışma yok',
              subtitle: 'Çalışma ekleyerek günlük raporunu oluştur',
              iconColor: AppTheme.primaryColor,
            )
          else ...[
            _buildSummaryRow(totalMinutes, totalCorrect, totalWrong, totalBlank, totalSolved, netScore),
            const SizedBox(height: 20),

            // Course breakdown chart
            if (courseBreakdown.isNotEmpty)
              _buildCourseBreakdownCard(courseBreakdown),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ───────────────────────────────────────
  // HAFTALIK RAPOR
  // ───────────────────────────────────────
  Widget _buildWeeklyReport(StudyProvider studyProvider, ExamProvider examProvider) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final sessions = studyProvider.getSessionsForPeriod(weekStart, weekEnd);
    final totalMinutes = sessions.fold(0, (sum, s) => sum + s.durationMinutes);
    final totalCorrect = sessions.fold(0, (sum, s) => sum + s.correctAnswers);
    final totalWrong = sessions.fold(0, (sum, s) => sum + s.wrongAnswers);
    final totalBlank = sessions.fold(0, (sum, s) => sum + (s.questionsSolved - s.correctAnswers - s.wrongAnswers));
    final totalSolved = sessions.fold(0, (sum, s) => sum + s.questionsSolved);
    final netScore = totalCorrect - (totalWrong / 4);

    // Course breakdown for the week
    final courseMinutes = <String, int>{};
    for (var s in sessions) {
      courseMinutes[s.subject] = (courseMinutes[s.subject] ?? 0) + s.durationMinutes;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${DateFormat('d MMM', 'tr_TR').format(weekStart)} - ${DateFormat('d MMM y', 'tr_TR').format(weekEnd)}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          if (sessions.isEmpty)
            EmptyStateWidget(
              icon: Icons.date_range,
              title: 'Bu hafta çalışma yok',
              subtitle: 'Hafta boyunca çalışma ekleyerek rapor oluştur',
              iconColor: AppTheme.primaryColor,
            )
          else ...[
            _buildSummaryRow(totalMinutes, totalCorrect, totalWrong, totalBlank, totalSolved, netScore),
            const SizedBox(height: 20),

            // Daily bar chart
            _buildWeeklyBarChart(studyProvider),
            const SizedBox(height: 20),

            // Course breakdown
            if (courseMinutes.isNotEmpty)
              _buildCourseBreakdownCard(courseMinutes),
            const SizedBox(height: 20),

            // Exam trend
            _buildExamTrendCard(examProvider, 7),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ───────────────────────────────────────
  // AYLIK RAPOR
  // ───────────────────────────────────────
  Widget _buildMonthlyReport(StudyProvider studyProvider, ExamProvider examProvider) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    final sessions = studyProvider.getSessionsForPeriod(monthStart, monthEnd);
    final totalMinutes = sessions.fold(0, (sum, s) => sum + s.durationMinutes);
    final totalCorrect = sessions.fold(0, (sum, s) => sum + s.correctAnswers);
    final totalWrong = sessions.fold(0, (sum, s) => sum + s.wrongAnswers);
    final totalBlank = sessions.fold(0, (sum, s) => sum + (s.questionsSolved - s.correctAnswers - s.wrongAnswers));
    final totalSolved = sessions.fold(0, (sum, s) => sum + s.questionsSolved);
    final netScore = totalCorrect - (totalWrong / 4);

    // Course breakdown for month
    final courseMinutes = <String, int>{};
    for (var s in sessions) {
      courseMinutes[s.subject] = (courseMinutes[s.subject] ?? 0) + s.durationMinutes;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            DateFormat('MMMM y', 'tr_TR').format(now),
            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          if (sessions.isEmpty)
            EmptyStateWidget(
              icon: Icons.calendar_month,
              title: 'Bu ay çalışma yok',
              subtitle: 'Çalışma ekleyerek aylık rapor oluştur',
              iconColor: AppTheme.primaryColor,
            )
          else ...[
            _buildSummaryRow(totalMinutes, totalCorrect, totalWrong, totalBlank, totalSolved, netScore),
            const SizedBox(height: 20),

            // Success distribution pie chart
            _buildSuccessDistributionCard(totalCorrect, totalWrong, totalBlank),
            const SizedBox(height: 20),

            // Course breakdown
            if (courseMinutes.isNotEmpty)
              _buildCourseBreakdownCard(courseMinutes),
            const SizedBox(height: 20),

            // Exam trend
            _buildExamTrendCard(examProvider, 30),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ───────────────────────────────────────
  // SHARED WIDGETS
  // ───────────────────────────────────────

  Widget _buildSummaryRow(int totalMinutes, int totalCorrect, int totalWrong, int totalBlank, int totalSolved, double netScore) {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    final isPositive = netScore >= 0;

    return Column(
      children: [
        // Time + Questions row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Çalışma',
                value: hours > 0 ? '${hours}s ${mins}dk' : '${mins}dk',
                icon: Icons.timer,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Toplam Soru',
                value: '$totalSolved',
                icon: Icons.help_outline,
                color: AppTheme.infoColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // D/Y/B/Net row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Doğru',
                value: '$totalCorrect',
                icon: Icons.check_circle_outline,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                title: 'Yanlış',
                value: '$totalWrong',
                icon: Icons.cancel_outlined,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                title: 'Boş',
                value: '$totalBlank',
                icon: Icons.remove_circle_outline,
                color: AppTheme.warningColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                title: 'Net',
                value: netScore.toStringAsFixed(1),
                icon: Icons.calculate,
                color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.08), color.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────
  // Course Breakdown Card
  // ───────────────────────────────────────
  Widget _buildCourseBreakdownCard(Map<String, int> courseMinutes) {
    final sortedEntries = courseMinutes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalMinutes = courseMinutes.values.fold(0, (sum, v) => sum + v);

    final colors = [
      AppTheme.primaryColor,
      AppTheme.errorColor,
      AppTheme.successColor,
      AppTheme.warningColor,
      AppTheme.secondaryColor,
      const Color(0xFF9B59B6),
      const Color(0xFFFF9500),
      AppTheme.infoColor,
    ];

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
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.pie_chart, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ders Bazlı Dağılım',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Pie chart
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: sortedEntries.asMap().entries.map((mapEntry) {
                  final idx = mapEntry.key;
                  final entry = mapEntry.value;
                  final percentage = totalMinutes > 0 ? (entry.value / totalMinutes) * 100 : 0.0;
                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    title: '${percentage.toStringAsFixed(0)}%',
                    radius: 50,
                    color: colors[idx % colors.length],
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legend + hours
          ...sortedEntries.asMap().entries.map((mapEntry) {
            final idx = mapEntry.key;
            final entry = mapEntry.value;
            final hours = entry.value / 60;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[idx % colors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    '${hours.toStringAsFixed(1)} saat',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
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
  // Weekly Bar Chart
  // ───────────────────────────────────────
  Widget _buildWeeklyBarChart(StudyProvider studyProvider) {
    final now = DateTime.now();
    List<BarChartGroupData> barGroups = [];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final sessions = studyProvider.getSessionsForDay(day);
      final totalDuration = sessions.fold(0, (sum, s) => sum + s.durationMinutes);

      barGroups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: totalDuration.toDouble(),
              color: AppTheme.primaryColor,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        ),
      );
    }

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
                  color: AppTheme.infoColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.bar_chart_rounded, color: AppTheme.infoColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Son 7 Gün Çalışma (dk)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: barGroups.isEmpty ? [BarChartGroupData(x: 0, barRods: [])] : barGroups,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final day = now.subtract(Duration(days: 6 - value.toInt()));
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('E', 'tr_TR').format(day).substring(0, 2),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────
  // Exam Trend Chart
  // ───────────────────────────────────────
  Widget _buildExamTrendCard(ExamProvider examProvider, int daysBack) {
    final cutoff = DateTime.now().subtract(Duration(days: daysBack));
    final exams = examProvider.exams
        .where((e) => e.date.isAfter(cutoff))
        .toList()
        .reversed
        .toList();

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
                  color: AppTheme.warningColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.trending_up, color: Colors.orange[600], size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Deneme Trendi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (exams.isEmpty)
            const SizedBox(
              height: 120,
              child: Center(
                child: Text('Bu dönemde deneme verisi yok', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < exams.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text('D${value.toInt() + 1}', style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: exams.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.netScore);
                      }).toList(),
                      isCurved: true,
                      color: AppTheme.primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primaryColor.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────
  // Success Distribution Pie
  // ───────────────────────────────────────
  Widget _buildSuccessDistributionCard(int correct, int wrong, int blank) {
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
                child: Icon(Icons.donut_large, color: AppTheme.successColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Başarı Dağılımı',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (correct == 0 && wrong == 0 && blank == 0)
            const SizedBox(
              height: 150,
              child: Center(
                child: Text('Henüz veri yok', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
          SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: correct.toDouble(),
                    title: 'D: $correct',
                    radius: 50,
                    color: AppTheme.successColor,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  PieChartSectionData(
                    value: wrong.toDouble(),
                    title: 'Y: $wrong',
                    radius: 50,
                    color: AppTheme.errorColor,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  PieChartSectionData(
                    value: blank.toDouble(),
                    title: 'B: $blank',
                    radius: 50,
                    color: AppTheme.warningColor,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(AppTheme.successColor, 'Doğru: $correct'),
              _buildLegendItem(AppTheme.errorColor, 'Yanlış: $wrong'),
              _buildLegendItem(AppTheme.warningColor, 'Boş: $blank'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
