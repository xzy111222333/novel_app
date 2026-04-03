import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/deleted_record.dart';
import '../models/inspiration_item.dart';
import '../models/material_item.dart';
import '../models/plot_item.dart';
import '../models/vocabulary_item.dart';
import 'sample_data.dart';

class DataService extends ChangeNotifier {
  static final DataService instance = DataService._internal();
  DataService._internal();

  static const _uuid = Uuid();
  static const _schemaVersion = 2;

  static String generateId() => _uuid.v4();

  static const List<String> _defaultMaterialCategories = [
    '对话',
    '动作描写',
    '心理描写',
    '人物描写',
    '环境描写',
  ];

  static const List<String> _defaultVocabularyCategories = [
    '环境',
    '外貌',
    '神态',
    '声音',
    '动作',
    '心理',
  ];

  static const List<String> _defaultPlotCategories = [
    '打脸剧情',
    '总裁剧情',
    '宫斗剧情',
    '甜宠剧情',
    '校园剧情',
    '装逼剧情',
    '憋屈剧情',
    '未婚先孕',
  ];

  List<MaterialItem> _materials = [];
  List<VocabularyItem> _vocabulary = [];
  List<InspirationItem> _inspirations = [];
  List<PlotItem> _plots = [];
  List<DeletedRecord> _recentlyDeleted = [];

  List<String> _materialCategories = List<String>.from(_defaultMaterialCategories);
  List<String> _vocabularyCategories =
      List<String>.from(_defaultVocabularyCategories);
  List<String> _plotCategories = List<String>.from(_defaultPlotCategories);
  List<String> _enabledOptionalTabs = [];

  String _profileName = '我';
  String _themePresetId = 'default';

  List<MaterialItem> get materials => List.unmodifiable(_materials);
  List<VocabularyItem> get vocabulary => List.unmodifiable(_vocabulary);
  List<InspirationItem> get inspirations => List.unmodifiable(_inspirations);
  List<PlotItem> get plots => List.unmodifiable(_plots);
  List<DeletedRecord> get recentlyDeleted =>
      List.unmodifiable(_recentlyDeleted);

  List<String> get materialCategories => List.unmodifiable(_materialCategories);
  List<String> get vocabularyCategories =>
      List.unmodifiable(_vocabularyCategories);
  List<String> get plotCategories => List.unmodifiable(_plotCategories);
  List<String> get enabledOptionalTabs => List.unmodifiable(_enabledOptionalTabs);

  String get profileName => _profileName;
  String get themePresetId => _themePresetId;

  List<MaterialItem> get todayMaterials =>
      _materials.where((item) => _isToday(item.createdAt)).toList();
  List<VocabularyItem> get todayVocabulary =>
      _vocabulary.where((item) => _isToday(item.createdAt)).toList();
  List<InspirationItem> get todayInspirations =>
      _inspirations.where((item) => _isToday(item.createdAt)).toList();
  List<PlotItem> get todayPlots =>
      _plots.where((item) => _isToday(item.createdAt)).toList();

  int get materialWordCount =>
      _materials.fold(0, (sum, item) => sum + item.wordCount);
  int get vocabularyWordCount =>
      _vocabulary.fold(0, (sum, item) => sum + item.wordCount);
  int get inspirationWordCount =>
      _inspirations.fold(0, (sum, item) => sum + item.wordCount);
  int get plotWordCount => _plots.fold(0, (sum, item) => sum + item.wordCount);
  int get totalWordCount =>
      materialWordCount +
      vocabularyWordCount +
      inspirationWordCount +
      plotWordCount;

  List<dynamic> get favorites {
    final result = <dynamic>[];
    result.addAll(_materials.where((item) => item.isFavorite));
    result.addAll(_vocabulary.where((item) => item.isFavorite));
    result.addAll(_inspirations.where((item) => item.isFavorite));
    result.addAll(_plots.where((item) => item.isFavorite));
    result.sort((a, b) => _createdAtOf(b).compareTo(_createdAtOf(a)));
    return result;
  }

  int get favoritesCount => favorites.length;

  Set<String> get allTags {
    final tags = <String>{};
    for (final item in _materials) {
      tags.addAll(item.tags);
    }
    for (final item in _vocabulary) {
      tags.addAll(item.tags);
    }
    for (final item in _inspirations) {
      tags.addAll(item.tags);
    }
    for (final item in _plots) {
      tags.addAll(item.tags);
    }
    return tags;
  }

  Map<String, int> get totalCounts => {
        'materials': _materials.length,
        'vocabulary': _vocabulary.length,
        'inspirations': _inspirations.length,
        'plots': _plots.length,
      };

  Future<void> init() async {
    await _loadFromPrefs();
    await _migrateLegacyData();
    _ensureDefaultState();
    if (_materials.isEmpty &&
        _vocabulary.isEmpty &&
        _inspirations.isEmpty &&
        _plots.isEmpty) {
      _loadSampleData();
      await _saveToPrefs();
    }
    notifyListeners();
  }

  void updateProfileName(String value) {
    final next = value.trim();
    if (next.isEmpty || next == _profileName) {
      return;
    }
    _profileName = next;
    _persistAndNotify();
  }

  void updateThemePreset(String presetId) {
    if (_themePresetId == presetId) {
      return;
    }
    _themePresetId = presetId;
    _persistAndNotify();
  }

  List<String> getCategories(String module) {
    switch (module) {
      case 'material':
        return materialCategories;
      case 'vocabulary':
        return vocabularyCategories;
      case 'plot':
        return plotCategories;
      default:
        return const [];
    }
  }

  void addCategory(String module, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final categories = _mutableCategoryList(module);
    if (categories == null || categories.contains(trimmed)) {
      return;
    }
    categories.add(trimmed);
    _persistAndNotify();
  }

  void renameCategory(String module, String oldName, String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || oldName == trimmed) {
      return;
    }
    final categories = _mutableCategoryList(module);
    if (categories == null) {
      return;
    }
    final index = categories.indexOf(oldName);
    if (index == -1) {
      return;
    }
    categories[index] = trimmed;
    _replaceCategoryInItems(module, oldName, trimmed);
    _persistAndNotify();
  }

  void deleteCategory(String module, String name) {
    final categories = _mutableCategoryList(module);
    if (categories == null || !categories.contains(name)) {
      return;
    }
    if (categories.length == 1) {
      return;
    }
    categories.remove(name);
    final fallback = categories.first;
    _replaceCategoryInItems(module, name, fallback);
    _persistAndNotify();
  }

  void renameTag(String oldTag, String newTag) {
    final trimmed = newTag.trim();
    if (oldTag.isEmpty || trimmed.isEmpty || oldTag == trimmed) {
      return;
    }
    _materials = _materials
        .map((item) => item.copyWith(tags: _replaceTag(item.tags, oldTag, trimmed)))
        .toList();
    _vocabulary = _vocabulary
        .map((item) => item.copyWith(tags: _replaceTag(item.tags, oldTag, trimmed)))
        .toList();
    _inspirations = _inspirations
        .map((item) => item.copyWith(tags: _replaceTag(item.tags, oldTag, trimmed)))
        .toList();
    _plots = _plots
        .map((item) => item.copyWith(tags: _replaceTag(item.tags, oldTag, trimmed)))
        .toList();
    _persistAndNotify();
  }

  void deleteTag(String tag) {
    if (tag.isEmpty) {
      return;
    }
    _materials = _materials
        .map((item) => item.copyWith(tags: _removeTag(item.tags, tag)))
        .toList();
    _vocabulary = _vocabulary
        .map((item) => item.copyWith(tags: _removeTag(item.tags, tag)))
        .toList();
    _inspirations = _inspirations
        .map((item) => item.copyWith(tags: _removeTag(item.tags, tag)))
        .toList();
    _plots = _plots
        .map((item) => item.copyWith(tags: _removeTag(item.tags, tag)))
        .toList();
    _persistAndNotify();
  }

  bool isOptionalTabEnabled(String tabKey) =>
      _enabledOptionalTabs.contains(tabKey);

  void toggleOptionalTab(String tabKey) {
    if (_enabledOptionalTabs.contains(tabKey)) {
      _enabledOptionalTabs.remove(tabKey);
    } else {
      _enabledOptionalTabs.add(tabKey);
    }
    _persistAndNotify();
  }

  void addMaterial(MaterialItem item) {
    _materials.insert(0, item);
    _persistAndNotify();
  }

  void updateMaterial(MaterialItem item) {
    final index = _materials.indexWhere((entry) => entry.id == item.id);
    if (index == -1) {
      return;
    }
    _materials[index] = item;
    _persistAndNotify();
  }

  void deleteMaterial(String id) {
    _deleteEntity<MaterialItem>(
      id: id,
      source: _materials,
      type: 'material',
      serializer: (item) => item.toJson(),
    );
  }

  void purgeMaterial(String id) {
    _materials.removeWhere((item) => item.id == id);
    _persistAndNotify();
  }

  void toggleMaterialFavorite(String id) {
    final index = _materials.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }
    _materials[index] = _materials[index]
        .copyWith(isFavorite: !_materials[index].isFavorite);
    _persistAndNotify();
  }

  void addVocabulary(VocabularyItem item) {
    _vocabulary.insert(0, item);
    _persistAndNotify();
  }

  void updateVocabulary(VocabularyItem item) {
    final index = _vocabulary.indexWhere((entry) => entry.id == item.id);
    if (index == -1) {
      return;
    }
    _vocabulary[index] = item;
    _persistAndNotify();
  }

  void deleteVocabulary(String id) {
    _deleteEntity<VocabularyItem>(
      id: id,
      source: _vocabulary,
      type: 'vocabulary',
      serializer: (item) => item.toJson(),
    );
  }

  void purgeVocabulary(String id) {
    _vocabulary.removeWhere((item) => item.id == id);
    _persistAndNotify();
  }

  void toggleVocabularyFavorite(String id) {
    final index = _vocabulary.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }
    _vocabulary[index] = _vocabulary[index]
        .copyWith(isFavorite: !_vocabulary[index].isFavorite);
    _persistAndNotify();
  }

  void addInspiration(InspirationItem item) {
    _inspirations.insert(0, item);
    _persistAndNotify();
  }

  void updateInspiration(InspirationItem item) {
    final index = _inspirations.indexWhere((entry) => entry.id == item.id);
    if (index == -1) {
      return;
    }
    _inspirations[index] = item;
    _persistAndNotify();
  }

  void deleteInspiration(String id) {
    _deleteEntity<InspirationItem>(
      id: id,
      source: _inspirations,
      type: 'inspiration',
      serializer: (item) => item.toJson(),
    );
  }

  void purgeInspiration(String id) {
    _inspirations.removeWhere((item) => item.id == id);
    _persistAndNotify();
  }

  void toggleInspirationFavorite(String id) {
    final index = _inspirations.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }
    _inspirations[index] = _inspirations[index]
        .copyWith(isFavorite: !_inspirations[index].isFavorite);
    _persistAndNotify();
  }

  void addPlot(PlotItem item) {
    _plots.insert(0, item);
    _persistAndNotify();
  }

  void updatePlot(PlotItem item) {
    final index = _plots.indexWhere((entry) => entry.id == item.id);
    if (index == -1) {
      return;
    }
    _plots[index] = item;
    _persistAndNotify();
  }

  void deletePlot(String id) {
    _deleteEntity<PlotItem>(
      id: id,
      source: _plots,
      type: 'plot',
      serializer: (item) => item.toJson(),
    );
  }

  void purgePlot(String id) {
    _plots.removeWhere((item) => item.id == id);
    _persistAndNotify();
  }

  void togglePlotFavorite(String id) {
    final index = _plots.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }
    _plots[index] = _plots[index].copyWith(isFavorite: !_plots[index].isFavorite);
    _persistAndNotify();
  }

  void convertInspirationToMaterial(InspirationItem inspiration) {
    addMaterial(
      MaterialItem(
        id: generateId(),
        content: [
          if ((inspiration.title ?? '').trim().isNotEmpty) inspiration.title!,
          inspiration.content,
        ].join('\n'),
        category: _materialCategories.first,
        tags: List<String>.from(inspiration.tags),
        source: '灵感转换',
        createdAt: DateTime.now(),
      ),
    );
  }

  void convertInspirationToVocabulary(InspirationItem inspiration) {
    addVocabulary(
      VocabularyItem(
        id: generateId(),
        content: inspiration.content,
        category: _vocabularyCategories.first,
        tags: List<String>.from(inspiration.tags),
        createdAt: DateTime.now(),
      ),
    );
  }

  InspirationItem? getRandomPastInspiration() {
    final candidates = _inspirations.where((item) => !_isToday(item.createdAt)).toList();
    if (candidates.isEmpty) {
      return null;
    }
    candidates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return candidates.first;
  }

  bool hasAnyContentOn(DateTime date) {
    final normalized = _normalizeDate(date);
    return [
      ..._materials.map((item) => item.createdAt),
      ..._vocabulary.map((item) => item.createdAt),
      ..._inspirations.map((item) => item.createdAt),
      ..._plots.map((item) => item.createdAt),
    ].any((value) => _normalizeDate(value) == normalized);
  }

  int entryCountOn(DateTime date) {
    final normalized = _normalizeDate(date);
    return [
      ..._materials.map((item) => item.createdAt),
      ..._vocabulary.map((item) => item.createdAt),
      ..._inspirations.map((item) => item.createdAt),
      ..._plots.map((item) => item.createdAt),
    ].where((value) => _normalizeDate(value) == normalized).length;
  }

  int wordCountOn(DateTime date) {
    final normalized = _normalizeDate(date);
    var total = 0;
    for (final item in _materials) {
      if (_normalizeDate(item.createdAt) == normalized) {
        total += item.wordCount;
      }
    }
    for (final item in _vocabulary) {
      if (_normalizeDate(item.createdAt) == normalized) {
        total += item.wordCount;
      }
    }
    for (final item in _inspirations) {
      if (_normalizeDate(item.createdAt) == normalized) {
        total += item.wordCount;
      }
    }
    for (final item in _plots) {
      if (_normalizeDate(item.createdAt) == normalized) {
        total += item.wordCount;
      }
    }
    return total;
  }

  Map<DateTime, int> wordCountMapForRange(DateTime start, DateTime end) {
    final result = <DateTime, int>{};
    var current = _normalizeDate(start);
    final last = _normalizeDate(end);
    while (!current.isAfter(last)) {
      result[current] = wordCountOn(current);
      current = current.add(const Duration(days: 1));
    }
    return result;
  }

  Map<String, int> moduleCountsInRange(DateTime start, DateTime end) => {
        'materials': _materials.where((item) => _isInRange(item.createdAt, start, end)).length,
        'vocabulary':
            _vocabulary.where((item) => _isInRange(item.createdAt, start, end)).length,
        'inspirations':
            _inspirations.where((item) => _isInRange(item.createdAt, start, end)).length,
        'plots': _plots.where((item) => _isInRange(item.createdAt, start, end)).length,
      };

  Map<String, int> moduleWordsInRange(DateTime start, DateTime end) => {
        'materials': _materials
            .where((item) => _isInRange(item.createdAt, start, end))
            .fold(0, (sum, item) => sum + item.wordCount),
        'vocabulary': _vocabulary
            .where((item) => _isInRange(item.createdAt, start, end))
            .fold(0, (sum, item) => sum + item.wordCount),
        'inspirations': _inspirations
            .where((item) => _isInRange(item.createdAt, start, end))
            .fold(0, (sum, item) => sum + item.wordCount),
        'plots': _plots
            .where((item) => _isInRange(item.createdAt, start, end))
            .fold(0, (sum, item) => sum + item.wordCount),
      };

  List<Map<String, dynamic>> globalSearch(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const [];
    }
    final results = <Map<String, dynamic>>[];
    for (final item in _materials) {
      if (_matchesMaterial(item, normalized)) {
        results.add({'type': 'material', 'item': item});
      }
    }
    for (final item in _vocabulary) {
      if (_matchesVocabulary(item, normalized)) {
        results.add({'type': 'vocabulary', 'item': item});
      }
    }
    for (final item in _inspirations) {
      if (_matchesInspiration(item, normalized)) {
        results.add({'type': 'inspiration', 'item': item});
      }
    }
    for (final item in _plots) {
      if (_matchesPlot(item, normalized)) {
        results.add({'type': 'plot', 'item': item});
      }
    }
    results.sort(
      (a, b) => _createdAtOf(b['item']).compareTo(_createdAtOf(a['item'])),
    );
    return results;
  }

  void restoreDeleted(String recordId) {
    final index = _recentlyDeleted.indexWhere((record) => record.id == recordId);
    if (index == -1) {
      return;
    }
    final record = _recentlyDeleted.removeAt(index);
    switch (record.type) {
      case 'material':
        _materials.insert(
          0,
          MaterialItem.fromJson(record.payload),
        );
        break;
      case 'vocabulary':
        _vocabulary.insert(
          0,
          VocabularyItem.fromJson(record.payload),
        );
        break;
      case 'inspiration':
        _inspirations.insert(
          0,
          InspirationItem.fromJson(record.payload),
        );
        break;
      case 'plot':
        _plots.insert(
          0,
          PlotItem.fromJson(record.payload),
        );
        break;
    }
    _persistAndNotify();
  }

  void purgeDeleted(String recordId) {
    _recentlyDeleted.removeWhere((record) => record.id == recordId);
    _persistAndNotify();
  }

  void clearRecentlyDeleted() {
    if (_recentlyDeleted.isEmpty) {
      return;
    }
    _recentlyDeleted = [];
    _persistAndNotify();
  }

  Future<void> clearAllData({bool clearDeleted = true}) async {
    _materials = [];
    _vocabulary = [];
    _inspirations = [];
    _plots = [];
    _materialCategories = List<String>.from(_defaultMaterialCategories);
    _vocabularyCategories = List<String>.from(_defaultVocabularyCategories);
    _plotCategories = List<String>.from(_defaultPlotCategories);
    _enabledOptionalTabs = [];
    if (clearDeleted) {
      _recentlyDeleted = [];
    }
    await _saveToPrefs();
    notifyListeners();
  }

  String exportToJson() {
    final payload = {
      'exportDate': DateTime.now().toIso8601String(),
      'appName': '小灵感',
      'version': '2.0.0',
      'profileName': _profileName,
      'themePresetId': _themePresetId,
      'enabledOptionalTabs': _enabledOptionalTabs,
      'materials': _materials.map((item) => item.toJson()).toList(),
      'vocabulary': _vocabulary.map((item) => item.toJson()).toList(),
      'inspirations': _inspirations.map((item) => item.toJson()).toList(),
      'plots': _plots.map((item) => item.toJson()).toList(),
      'materialCategories': _materialCategories,
      'vocabularyCategories': _vocabularyCategories,
      'plotCategories': _plotCategories,
      'recentlyDeleted': _recentlyDeleted.map((item) => item.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<void> importFromJson(String rawJson) async {
    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    _materials = ((decoded['materials'] as List?) ?? const [])
        .map((item) => MaterialItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    _vocabulary = ((decoded['vocabulary'] as List?) ?? const [])
        .map((item) => VocabularyItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    _inspirations = ((decoded['inspirations'] as List?) ?? const [])
        .map((item) => InspirationItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    _plots = ((decoded['plots'] as List?) ?? const [])
        .map((item) => PlotItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    _materialCategories = List<String>.from(
      decoded['materialCategories'] as List? ?? _defaultMaterialCategories,
    );
    _vocabularyCategories = List<String>.from(
      decoded['vocabularyCategories'] as List? ?? _defaultVocabularyCategories,
    );
    _plotCategories = List<String>.from(
      decoded['plotCategories'] as List? ?? _defaultPlotCategories,
    );
    _enabledOptionalTabs = List<String>.from(
      decoded['enabledOptionalTabs'] as List? ?? const [],
    );
    _recentlyDeleted = ((decoded['recentlyDeleted'] as List?) ?? const [])
        .map((item) => DeletedRecord.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    _profileName = (decoded['profileName'] as String?)?.trim().isNotEmpty == true
        ? decoded['profileName'] as String
        : '我';
    _themePresetId = decoded['themePresetId'] as String? ?? 'default';
    _ensureDefaultState();
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> _migrateLegacyData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVersion = prefs.getInt('schema_version') ?? 1;
    if (savedVersion >= _schemaVersion) {
      return;
    }
    if (_looksLikeLegacyDemoData()) {
      _materials = [];
      _vocabulary = [];
      _inspirations = [];
      _plots = [];
      _recentlyDeleted = [];
    }
    _ensureDefaultState();
    await _saveToPrefs();
    await prefs.setInt('schema_version', _schemaVersion);
  }

  void _loadSampleData() {
    _materials = SampleData.getMaterials();
    _vocabulary = SampleData.getVocabulary();
    _inspirations = SampleData.getInspirations();
    _plots = SampleData.getPlots();
  }

  bool _looksLikeLegacyDemoData() {
    if (_materials.length != 9 ||
        _vocabulary.length != 12 ||
        _inspirations.length != 8 ||
        _plots.length != 6) {
      return false;
    }
    final hasMaterialSeed =
        _materials.any((item) => item.content.contains('你以为你赢了？'));
    final hasVocabularySeed =
        _vocabulary.any((item) => item.content == '幽暗的房间');
    final hasInspirationSeed =
        _inspirations.any((item) => item.title == '双重身份的女主');
    final hasPlotSeed = _plots.any(
      (item) => item.displayContent.contains('女主在宴会上被当众羞辱'),
    );
    return hasMaterialSeed &&
        hasVocabularySeed &&
        hasInspirationSeed &&
        hasPlotSeed;
  }

  void _ensureDefaultState() {
    if (_materialCategories.isEmpty) {
      _materialCategories = List<String>.from(_defaultMaterialCategories);
    }
    if (_vocabularyCategories.isEmpty) {
      _vocabularyCategories = List<String>.from(_defaultVocabularyCategories);
    }
    if (_plotCategories.isEmpty) {
      _plotCategories = List<String>.from(_defaultPlotCategories);
    }
    if (_profileName.trim().isEmpty) {
      _profileName = '我';
    }
    if (_themePresetId.trim().isEmpty) {
      _themePresetId = 'default';
    }
  }

  Future<void> _persistAndNotify() async {
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('schema_version', _schemaVersion);
      await prefs.setString(
        'data_materials',
        jsonEncode(_materials.map((item) => item.toJson()).toList()),
      );
      await prefs.setString(
        'data_vocabulary',
        jsonEncode(_vocabulary.map((item) => item.toJson()).toList()),
      );
      await prefs.setString(
        'data_inspirations',
        jsonEncode(_inspirations.map((item) => item.toJson()).toList()),
      );
      await prefs.setString(
        'data_plots',
        jsonEncode(_plots.map((item) => item.toJson()).toList()),
      );
      await prefs.setString('cat_material', jsonEncode(_materialCategories));
      await prefs.setString('cat_vocabulary', jsonEncode(_vocabularyCategories));
      await prefs.setString('cat_plot', jsonEncode(_plotCategories));
      await prefs.setString('config_tabs', jsonEncode(_enabledOptionalTabs));
      await prefs.setString('config_profile_name', _profileName);
      await prefs.setString('config_theme_preset', _themePresetId);
      await prefs.setString(
        'data_recently_deleted',
        jsonEncode(_recentlyDeleted.map((item) => item.toJson()).toList()),
      );
    } catch (error) {
      debugPrint('DataService save error: $error');
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final materialsJson = prefs.getString('data_materials');
      final vocabularyJson = prefs.getString('data_vocabulary');
      final inspirationsJson = prefs.getString('data_inspirations');
      final plotsJson = prefs.getString('data_plots');
      final deletedJson = prefs.getString('data_recently_deleted');

      if (materialsJson != null) {
        _materials = (jsonDecode(materialsJson) as List)
            .map((item) => MaterialItem.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      if (vocabularyJson != null) {
        _vocabulary = (jsonDecode(vocabularyJson) as List)
            .map((item) => VocabularyItem.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      if (inspirationsJson != null) {
        _inspirations = (jsonDecode(inspirationsJson) as List)
            .map((item) => InspirationItem.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      if (plotsJson != null) {
        _plots = (jsonDecode(plotsJson) as List)
            .map((item) => PlotItem.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      if (deletedJson != null) {
        _recentlyDeleted = (jsonDecode(deletedJson) as List)
            .map((item) => DeletedRecord.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }

      final materialCategoriesJson = prefs.getString('cat_material');
      if (materialCategoriesJson != null) {
        _materialCategories = List<String>.from(jsonDecode(materialCategoriesJson));
      }
      final vocabularyCategoriesJson = prefs.getString('cat_vocabulary');
      if (vocabularyCategoriesJson != null) {
        _vocabularyCategories =
            List<String>.from(jsonDecode(vocabularyCategoriesJson));
      }
      final plotCategoriesJson = prefs.getString('cat_plot');
      if (plotCategoriesJson != null) {
        _plotCategories = List<String>.from(jsonDecode(plotCategoriesJson));
      }
      final tabsJson = prefs.getString('config_tabs');
      if (tabsJson != null) {
        _enabledOptionalTabs = List<String>.from(jsonDecode(tabsJson));
      }
      _profileName = prefs.getString('config_profile_name') ?? '我';
      _themePresetId = prefs.getString('config_theme_preset') ?? 'default';
    } catch (error) {
      debugPrint('DataService load error: $error');
    }
  }

  void _deleteEntity<T>({
    required String id,
    required List<T> source,
    required String type,
    required Map<String, dynamic> Function(T item) serializer,
  }) {
    final index = source.indexWhere((item) => _idOf(item) == id);
    if (index == -1) {
      return;
    }
    final item = source.removeAt(index);
    _recentlyDeleted.insert(
      0,
      DeletedRecord(
        id: generateId(),
        type: type,
        payload: serializer(item),
        deletedAt: DateTime.now(),
      ),
    );
    _persistAndNotify();
  }

  List<String>? _mutableCategoryList(String module) {
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

  void _replaceCategoryInItems(String module, String oldName, String newName) {
    switch (module) {
      case 'material':
        _materials = _materials
            .map(
              (item) => item.category == oldName
                  ? item.copyWith(category: newName)
                  : item,
            )
            .toList();
        break;
      case 'vocabulary':
        _vocabulary = _vocabulary
            .map(
              (item) => item.category == oldName
                  ? item.copyWith(category: newName)
                  : item,
            )
            .toList();
        break;
      case 'plot':
        _plots = _plots
            .map(
              (item) => item.category == oldName
                  ? item.copyWith(category: newName)
                  : item,
            )
            .toList();
        break;
    }
  }

  List<String> _replaceTag(List<String> tags, String oldTag, String newTag) {
    final replaced = tags.map((tag) => tag == oldTag ? newTag : tag).toSet().toList();
    replaced.sort();
    return replaced;
  }

  List<String> _removeTag(List<String> tags, String tagToRemove) {
    return tags.where((tag) => tag != tagToRemove).toList();
  }

  static DateTime _normalizeDate(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool _isToday(DateTime value) => _normalizeDate(value) == _normalizeDate(DateTime.now());

  static bool _isInRange(DateTime value, DateTime start, DateTime end) {
    final normalized = _normalizeDate(value);
    final rangeStart = _normalizeDate(start);
    final rangeEnd = _normalizeDate(end);
    return !normalized.isBefore(rangeStart) && !normalized.isAfter(rangeEnd);
  }

  static bool _matchesMaterial(MaterialItem item, String query) {
    return item.content.toLowerCase().contains(query) ||
        item.category.toLowerCase().contains(query) ||
        item.source.toLowerCase().contains(query) ||
        item.tags.any((tag) => tag.toLowerCase().contains(query));
  }

  static bool _matchesVocabulary(VocabularyItem item, String query) {
    return item.content.toLowerCase().contains(query) ||
        item.category.toLowerCase().contains(query) ||
        item.tags.any((tag) => tag.toLowerCase().contains(query));
  }

  static bool _matchesInspiration(InspirationItem item, String query) {
    return item.content.toLowerCase().contains(query) ||
        (item.title?.toLowerCase().contains(query) ?? false) ||
        item.tags.any((tag) => tag.toLowerCase().contains(query));
  }

  static bool _matchesPlot(PlotItem item, String query) {
    return item.displayContent.toLowerCase().contains(query) ||
        item.category.toLowerCase().contains(query) ||
        item.tags.any((tag) => tag.toLowerCase().contains(query));
  }

  static DateTime _createdAtOf(dynamic item) {
    if (item is MaterialItem) {
      return item.createdAt;
    }
    if (item is VocabularyItem) {
      return item.createdAt;
    }
    if (item is InspirationItem) {
      return item.createdAt;
    }
    if (item is PlotItem) {
      return item.createdAt;
    }
    throw ArgumentError('Unsupported item type: ${item.runtimeType}');
  }

  static String _idOf(dynamic item) {
    if (item is MaterialItem) {
      return item.id;
    }
    if (item is VocabularyItem) {
      return item.id;
    }
    if (item is InspirationItem) {
      return item.id;
    }
    if (item is PlotItem) {
      return item.id;
    }
    throw ArgumentError('Unsupported item type: ${item.runtimeType}');
  }
}
