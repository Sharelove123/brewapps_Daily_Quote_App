import 'quote.dart';

/// Collection model for user-created quote collections
class QuoteCollection {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String color;
  final DateTime? createdAt;
  final List<Quote> quotes;
  final int quoteCount;

  QuoteCollection({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.color = '#A855F7',
    this.createdAt,
    this.quotes = const [],
    this.quoteCount = 0,
  });

  factory QuoteCollection.fromJson(Map<String, dynamic> json) {
    return QuoteCollection(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? 'Untitled',
      description: json['description'],
      color: json['color'] ?? '#A855F7',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      quoteCount: json['quote_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'description': description,
      'color': color,
    };
  }

  QuoteCollection copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? color,
    DateTime? createdAt,
    List<Quote>? quotes,
    int? quoteCount,
  }) {
    return QuoteCollection(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      quotes: quotes ?? this.quotes,
      quoteCount: quoteCount ?? this.quoteCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuoteCollection &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
