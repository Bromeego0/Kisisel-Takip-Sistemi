import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'services/database_service.dart';
import 'providers/study_provider.dart';
// import 'services/data_initialization_service.dart'; // Örnek veri yükleyici — gerekirse etkinleştir
import 'providers/exam_provider.dart';
import 'providers/topic_provider.dart';
import 'providers/exam_type_provider.dart';
import 'providers/todo_provider.dart';
import 'providers/note_provider.dart';
import 'theme/app_theme.dart';


import 'screens/dashboard_screen.dart';
import 'screens/add_study_screen.dart';
import 'screens/add_exam_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/topics_screen.dart';
import 'screens/todo_screen.dart';
import 'widgets/todo_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.init();
  
  // Örnek verilerin otomatik yüklenmesini kapattık:
  // await DataInitializationService.loadSampleDataIfEmpty();
  
  runApp(const KisiselGelisimApp());
}

class KisiselGelisimApp extends StatelessWidget {
  const KisiselGelisimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudyProvider()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
        ChangeNotifierProvider(create: (_) => TopicProvider()),
        ChangeNotifierProvider(create: (_) => ExamTypeProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: MaterialApp.router(
        title: 'Kişisel Gelişim',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr', 'TR'),
          Locale('en', 'US'),
        ],
        routerConfig: _router,
      ),
    );
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/todo',
          builder: (context, state) => const TodoScreen(),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsScreen(),
        ),
        GoRoute(
          path: '/topics',
          builder: (context, state) => const TopicsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/add_study',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddStudyScreen(),
    ),
    GoRoute(
      path: '/add_exam',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddExamScreen(),
    ),
  ],
);

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    int getSelectedIndex(BuildContext context) {
      final String location = GoRouterState.of(context).uri.path;
      if (location.startsWith('/dashboard')) return 0;
      if (location.startsWith('/calendar')) return 1;
      if (location.startsWith('/todo')) return 2;
      if (location.startsWith('/topics')) return 3;
      if (location.startsWith('/reports')) return 4;
      return 0;
    }

    void onItemTapped(int index, BuildContext context) {
      switch (index) {
        case 0:
          context.go('/dashboard');
          break;
        case 1:
          context.go('/calendar');
          break;
        case 2:
          context.go('/todo');
          break;
        case 3:
          context.go('/topics');
          break;
        case 4:
          context.go('/reports');
          break;
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: getSelectedIndex(context),
          onDestinationSelected: (index) => onItemTapped(index, context),
          backgroundColor: theme.colorScheme.surface,
          indicatorColor: AppTheme.primaryColor.withOpacity(0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Özet',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Ajanda',
            ),
            NavigationDestination(
              icon: Icon(Icons.checklist_outlined),
              selectedIcon: Icon(Icons.checklist),
              label: 'Yapılacaklar',
            ),
            NavigationDestination(
              icon: Icon(Icons.library_books_outlined),
              selectedIcon: Icon(Icons.library_books),
              label: 'Konular',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Raporlar',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddBottomSheet(context);
        },
        backgroundColor: AppTheme.primaryColor,
        elevation: 8,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showAddBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.book, color: Colors.white),
                  ),
                  title: const Text('Ders Çalışması Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Saat, soru, konu takibi'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/add_study');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    child: Icon(Icons.assignment, color: Colors.white),
                  ),
                  title: const Text('Deneme Sınavı Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Doğru, yanlış, net takibi'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/add_exam');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple[400],
                    child: const Icon(Icons.checklist, color: Colors.white),
                  ),
                  title: const Text('Görev / Etkinlik Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Yapılacaklar listene yeni görev ekle'),
                  onTap: () {
                    Navigator.pop(context);
                    showAddTodoDialog(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
