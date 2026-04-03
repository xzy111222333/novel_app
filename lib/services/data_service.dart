import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/material_item.dart';
import '../models/vocabulary_item.dart';
import '../models/inspiration_item.dart';
import '../models/plot_item.dart';
import 'sample_data.dart';

class DataService extends ChangeNotifier {
  static final DataService instance = DataService._internal();
  DataService._internal();

  static const _uuid = Uuid();
  static String generateId() => _uuid.v4();

  // === Data ===
  List<MaterialItem> _materials = [];
  List<VocabularyItem> _vocabulary = [];
  List<InspirationItem> _inspirations = [];
  List<PlotItem> _plots = [];

  // === Categories (no '全部', that's UI-only) ===
  List<String> _materialCategories = ['对话', '动作描写', '心理描写', '人物描写', '环境描写'];
  List<String> _vocabularyCategories = ['环境', '外貌', '神态', '声音', '动作', '心理'];
  List<String> _plotCategories = ['打脸剧情', '总裁剧情', '宫斗剧情', '甜宠剧情', '校园剧情', '装逼剧情', '憋屈剧情', '未婚先孕'];

  // === Optional tab config ===
  List<String> _enabledOptionalTabs = [];

  // === Getters ===
  List<MaterialItem> get materials => _materials;
  List<VocabularyItem> get vocabulary => _vocabulary;
  List<InspirationItem> get inspirations => _inspirations;
  List<PlotItem> get plots => _plots;

  List<String> get materialCategories => _materialCategories;
  List<String> get vocabularyCategories => _vocabularyCategories;
  List<String> get plotCategories => _plotCategories;
  List<String> get enabledOptionalTabs => _enabledOptionalTabs;

  // === Today's items ===
  List<MaterialItem> get todayMaterials =>
      _materials.where((m) => _isToday(m.createdAt)).toList();
  List<VocabularyItem> get todayVocabulary =>
      _vocabulary.where((v) => _isToday(v.createdAt)).toList();
  List<InspirationItem> get todayInspirations =>
      _inspirations.where((i) => _isToday(i.createdAt)).toList();
  List<PlotItem> get todayPlots =>
      _plots.where((p) => _isToday(p.createdAt)).toList();

  static bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  // === Word counts ===
  int get totalWordCount =>
      materialWordCount + vocabularyWordCount + inspirationWordCount + plotWordCount;
  int get materialWordCount =>
      _materials.fold(0, (sum, m) => sum + m.content.length);
  int get vocabularyWordCount =>
      _vocabulary.fold(0, (sum, v) => sum + v.content.length);
  int get inspirationWordCount =>
      _inspirations.fold(0, (sum, i) => sum + i.content.length + (i.title?.length ?? 0));
  int get plotWordCount => _plots.fold(0, (sum, p) {
        if (p.type == 'steps') {
          return sum + p.steps.fold(0, (s, step) => s + step.length);
        }
        return sum + p.freeContent.length;
      });

  Map<String, int> get todayCounts => {
        'materials': todayMaterials.length,
        'vocabulary': todayVocabulary.length,
        'inspirations': todayInspirations.length,
        'plots': todayPlots.length,
      };

  Map<String, int> get totalCounts => {
        'materials': _materials.length,
        'vocabulary': _vocabulary.length,
        'inspirations': _inspirations.length,
        'plots': _plots.length,
      };

  // === Random past inspiration (for 随机回顾) ===
  InspirationItem? getRandomPastInspiration() {
    final past = _inspirations.where((i) => !_isToday(i.createdAt)).toList();
    if (past.isEmpty) return null;
    return past[Random().nextInt(past.length)];
  }

  // === All tags (collected from all items) ===
  Set<String> get allTags {
    final tags = <String>{};
    for (final m in _materials) { tags.addAll(m.tags); }
    for (final v in _vocabulary) { tags.addAll(v.tags); }
    for (final i in _inspirations) { tags.addAll(i.tags); }
    for (final p in _plots) { tags.addAll(p.tags); }
    return tags;
  }

  // === Favorites ===
  List<dynamic> get favorites {
    final result = <dynamic>[];
    result.addAll(_materials.where((m) => m.isFavorite));
    result.addAll(_vocabulary.where((v) => v.isFavorite));
    result.addAll(_inspirations.where((i) => i.isFavorite));
    result.addAll(_plots.where((p) => p.isFavorite));
    return result;
  }

  int get favoritesCount => favorites.length;

  // === Initialize ===
  Future<void> init() async {
    await _loadFromPrefs();
    if (_materials.isEmpty &&
        _vocabulary.isEmpty &&
        _inspirations.isEmpty &&
        _plots.isEmpty) {
      _loadSampleData();
      await _saveToPrefs();
    }
    notifyListeners();
  }

  void _loadSampleData() {
    _materials = SampleData.getMaterials();
    _vocabulary = SampleData.getVocabulary();
    _inspirations = SampleData.getInspirations();
    _plots = SampleData.getPlots();
  }

  // ============ CRUD: Materials ============
  void addMaterial(MaterialItem item) {
    _materials.insert(0, item);
    _saveToPrefs();
    notifyListeners();
  }

  void updateMaterial(MaterialItem item) {
    final idx = _materials.indexWhere((m) => m.id == item.id);
    if (idx != -1) {
      _materials[idx] = item;
      _saveToPrefs();
      notifyListeners();
    }
  }

  void deleteMaterial(String id) {
    _materials.removeWhere((m) => m.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  void toggleMaterialFavorite(String id) {
    final idx = _materials.indexWhere((m) => m.id == id);
    if (idx != -1) {
      _materials[idx] = _materials[idx].copyWith(isFavorite: !_materials[idx].isFavorite);
      _saveToPrefs();
      notifyListeners();
    }
  }

  // ============ CRUD: Vocabulary ============
  void addVocabulary(VocabularyItem item) {
    _vocabulary.insert(0, item);
    _saveToPrefs();
    notifyListeners();
  }

  void updateVocabulary(VocabularyItem item) {
    final idx = _vocabulary.indexWhere((v) => v.id == item.id);
    if (idx != -1) {
      _vocabulary[idx] = item;
      _saveToPrefs();
      notifyListeners();
    }
  }

  void deleteVocabulary(String id) {
    _vocabulary.removeWhere((v) => v.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  void toggleVocabularyFavorite(String id) {
    final idx = _vocabulary.indexWhere((v) => v.id == id);
    if (idx != -1) {
      _vocabulary[idx] = _vocabulary[idx].copyWith(isFavorite: !_vocabulary[idx].isFavorite);
      _saveToPrefs();
      notifyListeners();
    }
  }

  // ============ CRUD: Inspirations ============
  void addInspiration(InspirationItem item) {
    _inspirations.insert(0, item);
    _saveToPrefs();
    notifyListeners();
  }

  void updateInspiration(InspirationItem item) {
    final idx = _inspirations.indexWhere((i) => i.id == item.id);
    if (idx != -1) {
      _inspirations[idx] = item;
      _saveToPrefs();
      notifyListeners();
    }
  }

  void deleteInspiration(String id) {
    _inspirations.removeWhere((i) => i.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  void toggleInspirationFavorite(String id) {
    final idx = _inspirations.indexWhere((i) => i.id == id);
    if (idx != -1) {
      _inspirations[idx] =
          _inspirations[idx].copyWith(isFavorite: !_inspirations[idx].isFavorite);
      _saveToPrefs();
      notifyListeners();
    }
  }

  // ============ CRUD: Plots ============
  void addPlot(PlotItem item) {
    _plots.insert(0, item);
    _saveToPrefs();
    notifyListeners();
  }

  void updatePlot(PlotItem item) {
    final idx = _plots.indexWhere((p) => p.id == item.id);
    if (idx != -1) {
      _plots[idx] = item;
      _saveToPrefs();
      notifyListeners();
    }
  }

  void deletePlot(String id) {
    _plots.removeWhere((p) => p.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  void togglePlotFavorite(String id) {
    final idx = _plots.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _plots[idx] = _plots[idx].copyWith(isFavorite: !_plots[idx].isFavorite);
      _saveToPrefs();
      notifyListeners();
    }
  }

  // ============ Convert Inspiration ============
  void convertInspirationToMaterial(InspirationItem inspiration) {
    final material = MaterialItem(
      id: generateId(),
      content: (inspiration.title != null ? '${inspiration.title}\n' : '') +
          inspiration.content,
      category: _materialCategories.isNotEmpty ? _materialCategories.first : '未分类',
      tags: List.from(inspiration.tags),
      source: '灵感转换',
      isFavorite: false,
      createdAt: DateTime.now(),
    );
    addMaterial(material);
  }

  void convertInspirationToVocabulary(InspirationItem inspiration) {
    final vocab = VocabularyItem(
      id: generateId(),
      content: inspiration.content,
      category: _vocabularyCategories.isNotEmpty ? _vocabularyCategories.first : '未分类',
      tags: List.from(inspiration.tags),
      isFavorite: false,
      createdAt: DateTime.now(),
    );
    addVocabulary(vocab);
  }

  // ============ Category Management ============
  List<String> getCategories(String module) {
    switch (module) {
      case 'material':
        return _materialCategories;
      case 'vocabulary':
        return _vocabularyCategories;
      case 'plot':
        return _plotCategories;
      default:
        return [];
    }
  }

  void addCategory(String module, String name) {
    if (name.isEmpty) return;
    final list = _getMutableCategoryList(module);
    if (list != null && !list.contains(name)) {
      list.add(name);
      _saveToPrefs();
      notifyListeners();
    }
  }

  void renameCategory(String module, String oldName, String newName) {
    if (newName.isEmpty || oldName == newName) return;
    final list = _getMutableCategoryList(module);
    if (list == null) return;
    final idx = list.indexOf(oldName);
    if (idx == -1) return;
    list[idx] = newName;
    // Update items with old category
    if (module == 'material') {
      for (int i = 0; i < _materials.length; i++) {
        if (_materials[i].category == oldName) {
          _materials[i] = _materials[i].copyWith(category: newName);
        }
      }
    } else if (module == 'vocabulary') {
      for (int i = 0; i < _vocabulary.length; i++) {
        if (_vocabulary[i].category == oldName) {
          _vocabulary[i] = _vocabulary[i].copyWith(category: newName);
        }
      }
    } else if (module == 'plot') {
      for (int i = 0; i < _plots.length; i++) {
        if (_plots[i].category == oldName) {
          _plots[i] = _plots[i].copyWith(category: newName);
        }
      }
    }
    _saveToPrefs();
    notifyListeners();
  }

  void deleteCategory(String module, String name) {
    final list = _getMutableCategoryList(module);
    if (list != null) {
      list.remove(name);
      _saveToPrefs();
      notifyListeners();
    }
  }

  List<String>? _getMutableCategoryList(String module) {
    switch (module) {
      case 'material':
        return _materialCategories;
      case 'vocabulary':
        return _vocabularyCategories;
      case 'plot':
        return _plotCategories;
      default:
        return null;
    }
  }

  // ============ Tab Management ============
  bool isOptionalTabEnabled(String tabKey) => _enabledOptionalTabs.contains(tabKey);

  void toggleOptionalTab(String tabKey) {
    if (_enabledOptionalTabs.contains(tabKey)) {
      _enabledOptionalTabs.remove(tabKey);
    } else {
      _enabledOptionalTabs.add(tabKey);
    }
    _saveToPrefs();
    notifyListeners();
  }

  // ============ Global Search ============
  List<Map<String, dynamic>> globalSearch(String query) {
    if (query.isEmpty) return [];
    final lq = query.toLowerCase();
    final results = <Map<String, dynamic>>[];
    for (final m in _materials) {
      if (m.content.toLowerCase().contains(lq) ||
          m.category.toLowerCase().contains(lq) ||
          m.tags.any((t) => t.toLowerCase().contains(lq))) {
        results.add({'type': 'material', 'item': m});
      }
    }
    for (final v in _vocabulary) {
      if (v.content.toLowerCase().contains(lq) ||
          v.category.toLowerCase().contains(lq) ||
          v.tags.any((t) => t.toLowerCase().contains(lq))) {
        results.add({'type': 'vocabulary', 'item': v});
      }
    }
    for (final i in _inspirations) {
      if (i.content.toLowerCase().contains(lq) ||
          (i.title?.toLowerCase().contains(lq) ?? false) ||
          i.tags.any((t) => t.toLowerCase().contains(lq))) {
        results.add({'type': 'inspiration', 'item': i});
      }
    }
    for (final p in _plots) {
      if (p.displayContent.toLowerCase().contains(lq) ||
          p.category.toLowerCase().contains(lq) ||
          p.tags.any((t) => t.toLowerCase().contains(lq))) {
        results.add({'type': 'plot', 'item': p});
      }
    }
    return results;
  }

  // ============ Weekly stats (for heatmap) ============
  Map<String, List<int>> getWeeklyActivity() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final result = <String, List<int>>{
      'materials': List.filled(7, 0),
      'vocabulary': List.filled(7, 0),
      'inspirations': List.filled(7, 0),
      'plots': List.filled(7, 0),
    };
    for (final m in _materials) {
      final dayIdx = m.createdAt.difference(DateTime(monday.year, monday.month, monday.day)).inDays;
      if (dayIdx >= 0 && dayIdx < 7) result['materials']![dayIdx]++;
    }
    for (final v in _vocabulary) {
      final dayIdx = v.createdAt.difference(DateTime(monday.year, monday.month, monday.day)).inDays;
      if (dayIdx >= 0 && dayIdx < 7) result['vocabulary']![dayIdx]++;
    }
    for (final i in _inspirations) {
      final dayIdx = i.createdAt.difference(DateTime(monday.year, monday.month, monday.day)).inDays;
      if (dayIdx >= 0 && dayIdx < 7) result['inspirations']![dayIdx]++;
    }
    for (final p in _plots) {
      final dayIdx = p.createdAt.difference(DateTime(monday.year, monday.month, monday.day)).inDays;
      if (dayIdx >= 0 && dayIdx < 7) result['plots']![dayIdx]++;
    }
    return result;
  }

  // Daily word counts for bar chart (last 7 days)
  List<int> getDailyWordCounts() {
    final now = DateTime.now();
    final counts = List.filled(7, 0);
    for (int d = 0; d < 7; d++) {
      final date = now.subtract(Duration(days: 6 - d));
      int dayCount = 0;
      for (final m in _materials) {
        if (_isSameDay(m.createdAt, date)) dayCount += m.content.length;
      }
      for (final v in _vocabulary) {
        if (_isSameDay(v.createdAt, date)) dayCount += v.content.length;
      }
      for (final i in _inspirations) {
        if (_isSameDay(i.createdAt, date)) dayCount += i.content.length;
      }
      for (final p in _plots) {
        if (_isSameDay(p.createdAt, date)) {
          dayCount += p.type == 'steps' ? p.steps.join('').length : p.freeContent.length;
        }
      }
      counts[d] = dayCount;
    }
    return counts;
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ============ Export ============
  String exportToJson() {
    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'appName': '小灵感',
      'version': '1.0.0',
      'materials': _materials.map((m) => m.toJson()).toList(),
      'vocabulary': _vocabulary.map((v) => v.toJson()).toList(),
      'inspirations': _inspirations.map((i) => i.toJson()).toList(),
      'plots': _plots.map((p) => p.toJson()).toList(),
      'materialCategories': _materialCategories,
      'vocabularyCategories': _vocabularyCategories,
      'plotCategories': _plotCategories,
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  // ============ Reset ============
  Future<void> resetToSampleData() async {
    _materials.clear();
    _vocabulary.clear();
    _inspirations.clear();
    _plots.clear();
    _materialCategories = ['对话', '动作描写', '心理描写', '人物描写', '环境描写'];
    _vocabularyCategories = ['环境', '外貌', '神态', '声音', '动作', '心理'];
    _plotCategories = ['打脸剧情', '总裁剧情', '宫斗剧情', '甜宠剧情', '校园剧情', '装逼剧情', '憋屈剧情', '未婚先孕'];
    _loadSampleData();
    await _saveToPrefs();
    notifyListeners();
  }

  // ============ Persistence ============
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'data_materials', jsonEncode(_materials.map((m) => m.toJson()).toList()));
      await prefs.setString(
          'data_vocabulary', jsonEncode(_vocabulary.map((v) => v.toJson()).toList()));
      await prefs.setString(
          'data_inspirations', jsonEncode(_inspirations.map((i) => i.toJson()).toList()));
      await prefs.setString(
          'data_plots', jsonEncode(_plots.map((p) => p.toJson()).toList()));
      await prefs.setString('cat_material', jsonEncode(_materialCategories));
      await prefs.setString('cat_vocabulary', jsonEncode(_vocabularyCategories));
      await prefs.setString('cat_plot', jsonEncode(_plotCategories));
      await prefs.setString('config_tabs', jsonEncode(_enabledOptionalTabs));
    } catch (e) {
      debugPrint('DataService save error: $e');
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final mJson = prefs.getString('data_materials');
      if (mJson != null) {
        _materials = (jsonDecode(mJson) as List)
            .map((j) => MaterialItem.fromJson(j as Map<String, dynamic>))
            .toList();
      }

      final vJson = prefs.getString('data_vocabulary');
      if (vJson != null) {
        _vocabulary = (jsonDecode(vJson) as List)
            .map((j) => VocabularyItem.fromJson(j as Map<String, dynamic>))
            .toList();
      }

      final iJson = prefs.getString('data_inspirations');
      if (iJson != null) {
        _inspirations = (jsonDecode(iJson) as List)
            .map((j) => InspirationItem.fromJson(j as Map<String, dynamic>))
            .toList();
      }

      final pJson = prefs.getString('data_plots');
      if (pJson != null) {
        _plots = (jsonDecode(pJson) as List)
            .map((j) => PlotItem.fromJson(j as Map<String, dynamic>))
            .toList();
      }

      final mcJson = prefs.getString('cat_material');
      if (mcJson != null) {
        _materialCategories = List<String>.from(jsonDecode(mcJson));
      }

      final vcJson = prefs.getString('cat_vocabulary');
      if (vcJson != null) {
        _vocabularyCategories = List<String>.from(jsonDecode(vcJson));
      }

      final pcJson = prefs.getString('cat_plot');
      if (pcJson != null) {
        _plotCategories = List<String>.from(jsonDecode(pcJson));
      }

      final tabsJson = prefs.getString('config_tabs');
      if (tabsJson != null) {
        _enabledOptionalTabs = List<String>.from(jsonDecode(tabsJson));
      }
    } catch (e) {
      debugPrint('DataService load error: $e');
    }
  }
}
