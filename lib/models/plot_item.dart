class PlotItem {
  final String id;
  final String type; // 'steps' or 'free'
  final List<String> steps;
  final String freeContent;
  final String category;
  final List<String> tags;
  final bool isFavorite;
  final DateTime createdAt;
  final int wordCount;

  PlotItem({
    required this.id,
    required this.type,
    this.steps = const [],
    this.freeContent = '',
    required this.category,
    this.tags = const [],
    this.isFavorite = false,
    required this.createdAt,
    int? wordCount,
  }) : wordCount = wordCount ?? (type == 'steps' ? steps.join('').length : freeContent.length);

  String get displayContent {
    if (type == 'steps') {
      return steps.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n');
    }
    return freeContent;
  }

  PlotItem copyWith({
    String? id, String? type, List<String>? steps, String? freeContent,
    String? category, List<String>? tags, bool? isFavorite,
    DateTime? createdAt, int? wordCount,
  }) {
    return PlotItem(
      id: id ?? this.id, type: type ?? this.type,
      steps: steps ?? this.steps, freeContent: freeContent ?? this.freeContent,
      category: category ?? this.category, tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt, wordCount: wordCount ?? this.wordCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type, 'steps': steps, 'freeContent': freeContent,
    'category': category, 'tags': tags, 'isFavorite': isFavorite,
    'createdAt': createdAt.toIso8601String(), 'wordCount': wordCount,
  };

  factory PlotItem.fromJson(Map<String, dynamic> json) => PlotItem(
    id: json['id'], type: json['type'],
    steps: List<String>.from(json['steps'] ?? []),
    freeContent: json['freeContent'] ?? '',
    category: json['category'], tags: List<String>.from(json['tags'] ?? []),
    isFavorite: json['isFavorite'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    wordCount: json['wordCount'],
  );
}
