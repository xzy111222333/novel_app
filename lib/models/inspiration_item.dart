class InspirationItem {
  final String id;
  final String? title;
  final String content;
  final List<String> tags;
  final bool isFavorite;
  final DateTime createdAt;
  final int wordCount;

  InspirationItem({
    required this.id,
    this.title,
    required this.content,
    this.tags = const [],
    this.isFavorite = false,
    required this.createdAt,
    int? wordCount,
  }) : wordCount = wordCount ?? content.length + (title?.length ?? 0);

  InspirationItem copyWith({
    String? id, String? title, String? content,
    List<String>? tags, bool? isFavorite,
    DateTime? createdAt, int? wordCount,
  }) {
    return InspirationItem(
      id: id ?? this.id, title: title ?? this.title,
      content: content ?? this.content, tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt, wordCount: wordCount ?? this.wordCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'content': content,
    'tags': tags, 'isFavorite': isFavorite,
    'createdAt': createdAt.toIso8601String(), 'wordCount': wordCount,
  };

  factory InspirationItem.fromJson(Map<String, dynamic> json) => InspirationItem(
    id: json['id'], title: json['title'], content: json['content'],
    tags: List<String>.from(json['tags'] ?? []),
    isFavorite: json['isFavorite'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    wordCount: json['wordCount'],
  );
}
