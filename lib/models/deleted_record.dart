class DeletedRecord {
  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final DateTime deletedAt;

  const DeletedRecord({
    required this.id,
    required this.type,
    required this.payload,
    required this.deletedAt,
  });

  DeletedRecord copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? payload,
    DateTime? deletedAt,
  }) {
    return DeletedRecord(
      id: id ?? this.id,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'payload': payload,
        'deletedAt': deletedAt.toIso8601String(),
      };

  factory DeletedRecord.fromJson(Map<String, dynamic> json) {
    return DeletedRecord(
      id: json['id'] as String,
      type: json['type'] as String,
      payload: Map<String, dynamic>.from(
        json['payload'] as Map? ?? const {},
      ),
      deletedAt: DateTime.parse(json['deletedAt'] as String),
    );
  }
}
