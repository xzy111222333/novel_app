class MaterialItem {
  final String id;
  final String content;
  final String category;
  final List<String> tags;
  final String source;
  final bool isFavorite;
  final DateTime createdAt;
  final int wordCount;

  MaterialItem({
    required this.id,
    required this.content,
    required this.category,
    this.tags = const [],
    this.source = '',
    this.isFavorite = false,
    required this.createdAt,
    int? wordCount,
  }) : wordCount = wordCount ?? content.length;

  MaterialItem copyWith({
    String? id, String? content, String? category,
    List<String>? tags, String? source, bool? isFavorite,
    DateTime? createdAt, int? wordCount,
  }) {
    return MaterialItem(
      id: id ?? this.id,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      source: source ?? this.source,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      wordCount: wordCount ?? this.wordCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'content': content, 'category': category,
    'tags': tags, 'source': source, 'isFavorite': isFavorite,
    'createdAt': createdAt.toIso8601String(), 'wordCount': wordCount,
  };

  factory MaterialItem.fromJson(Map<String, dynamic> json) => MaterialItem(
    id: json['id'], content: json['content'], category: json['category'],
    tags: List<String>.from(json['tags'] ?? []),
    source: json['source'] ?? '', isFavorite: json['isFavorite'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    wordCount: json['wordCount'],
  );
}
