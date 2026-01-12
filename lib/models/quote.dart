class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});

  /// Factory constructor to create a Quote from the ZenQuotes API JSON
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['q'] ?? 'Unknown Quote',
      author: json['a'] ?? 'Unknown Author',
    );
  }

  /// Convert Quote to Map for persistence
  Map<String, dynamic> toJson() {
    return {'q': text, 'a': author};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quote &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          author == other.author;

  @override
  int get hashCode => text.hashCode ^ author.hashCode;
}
