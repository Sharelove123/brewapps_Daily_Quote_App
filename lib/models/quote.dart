/// Quote model with Supabase integration
class Quote {
  final String id;
  final String text;
  final String author;
  final String? categoryId;
  final String? categoryName;
  final bool isFeatured;
  final DateTime? createdAt;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    this.categoryId,
    this.categoryName,
    this.isFeatured = false,
    this.createdAt,
  });

  /// Factory constructor to create a Quote from Supabase JSON
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] ?? '',
      text: json['text'] ?? json['q'] ?? 'Unknown Quote',
      author: json['author'] ?? json['a'] ?? 'Unknown Author',
      categoryId: json['category_id'],
      categoryName: json['categories']?['name'],
      isFeatured: json['is_featured'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  /// Convert Quote to Map for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'category_id': categoryId,
      'is_featured': isFeatured,
    };
  }

  /// Create a copy with modified fields
  Quote copyWith({
    String? id,
    String? text,
    String? author,
    String? categoryId,
    String? categoryName,
    bool? isFeatured,
    DateTime? createdAt,
  }) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quote && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Quote(id: $id, author: $author)';
}
