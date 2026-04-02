class VocabularyItem {
  final String id;
  final String content;
  final String category;
  final List<String> tags;
  final bool isFavorite;
  final DateTime createdAt;
  final int wordCount;

  VocabularyItem({
    required this.id,
    required this.content,
    required this.category,
    this.tags = const [],
    this.isFavorite = false,
    required this.createdAt,
    int? wordCount,
  }) : wordCount = wordCount ?? content.length;

  VocabularyItem copyWith({
    String? id, String? content, String? category,
    List<String>? tags, bool? isFavorite,
    DateTime? createdAt, int? wordCount,
  }) {
    return VocabularyItem(
      id: id ?? this.id, content: content ?? this.content,
      category: category ?? this.category, tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt, wordCount: wordCount ?? this.wordCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'content': content, 'category': category,
    'tags': tags, 'isFavorite': isFavorite,
    'createdAt': createdAt.toIso8601String(), 'wordCount': wordCount,
  };

  factory VocabularyItem.fromJson(Map<String, dynamic> json) => VocabularyItem(
    id: json['id'], content: json['content'], category: json['category'],
    tags: List<String>.from(json['tags'] ?? []),
    isFavorite: json['isFavorite'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    wordCount: json['wordCount'],
  );
}
