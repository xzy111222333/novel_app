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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    DataService.instance.addListener(_handleChange);
  }

  @override
  void dispose() {
    DataService.instance.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    if (mounted) {
      setState(() {});
    }
  }

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
  final String keyName;
  final String label;
  final IconData icon;
  final Widget screen;
  const _TabInfo(this.keyName, this.label, this.icon, this.screen);
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

  void _jumpToTab(String key) {
    final tabs = _buildTabs();
    final index = tabs.indexWhere((tab) => tab.keyName == key);
    if (index == -1) {
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  List<_TabInfo> _buildTabs() {
    final tabs = <_TabInfo>[
      _TabInfo('home', '今日', Icons.check_circle_outline_rounded,
          HomeScreen(onNavigateToTab: _jumpToTab)),
      const _TabInfo(
        'materials',
        '素材',
        Icons.menu_book_rounded,
        MaterialsScreen(),
      ),
    ];
    if (DataService.instance.isOptionalTabEnabled('vocabulary')) {
      tabs.add(const _TabInfo(
        'vocabulary',
        '词汇',
        Icons.text_fields_rounded,
        VocabularyScreen(),
      ));
    }
    tabs.add(const _TabInfo(
      'inspirations',
      '灵感',
      Icons.edit_note_rounded,
      InspirationScreen(),
    ));
    if (DataService.instance.isOptionalTabEnabled('plots')) {
      tabs.add(const _TabInfo(
        'plots',
        '剧情',
        Icons.movie_creation_outlined,
        PlotsScreen(),
      ));
    }
    tabs.addAll(const [
      _TabInfo('stats', '统计', Icons.bar_chart_rounded, StatsScreen()),
      _TabInfo('profile', '我的', Icons.person_outline_rounded, ProfileScreen()),
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
      body: Stack(
        children: [
          // 纸张纹理背景 — 圆点网格
          Positioned.fill(
            child: CustomPaint(painter: _PaperTexturePainter()),
          ),
          IndexedStack(
            index: _currentIndex,
            children: tabs.map((t) => t.screen).toList(),
          ),
        ],
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

/// 草稿纸圆点纹理
class _PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE5E0D8).withAlpha(60)
      ..style = PaintingStyle.fill;
    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
