import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'services/data_service.dart';
import 'widgets/app_bottom_nav.dart';
import 'screens/home_screen.dart';
import 'screens/materials_screen.dart';
import 'screens/inspiration_screen.dart';
import 'screens/vocabulary_screen.dart';
import 'screens/plots_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  await DataService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '小灵感',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const MainScreen(),
    );
  }
}

class _TabInfo {
  final String label;
  final IconData icon;
  final Widget screen;
  const _TabInfo(this.label, this.icon, this.screen);
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    DataService.instance.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    DataService.instance.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  List<_TabInfo> _buildTabs() {
    final tabs = <_TabInfo>[
      const _TabInfo('今日', Icons.calendar_today, HomeScreen()),
      const _TabInfo('素材', Icons.menu_book_rounded, MaterialsScreen()),
    ];
    if (DataService.instance.isOptionalTabEnabled('vocabulary')) {
      tabs.add(const _TabInfo('词汇', Icons.text_fields_rounded, VocabularyScreen()));
    }
    tabs.add(const _TabInfo('灵感', Icons.edit_note_rounded, InspirationScreen()));
    if (DataService.instance.isOptionalTabEnabled('plots')) {
      tabs.add(const _TabInfo('剧情', Icons.movie_creation_outlined, PlotsScreen()));
    }
    tabs.addAll(const [
      _TabInfo('统计', Icons.bar_chart_rounded, StatsScreen()),
      _TabInfo('我的', Icons.person_outline_rounded, ProfileScreen()),
    ]);
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _buildTabs();
    final safeIndex = _currentIndex.clamp(0, tabs.length - 1);
    if (safeIndex != _currentIndex) {
      _currentIndex = safeIndex;
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: tabs.map((t) => t.screen).toList(),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        items: tabs
            .map((t) => BottomNavItem(icon: t.icon, label: t.label))
            .toList(),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
