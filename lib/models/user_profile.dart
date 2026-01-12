/// User profile model extending Supabase auth
class UserProfile {
  final String id;
  final String? displayName;
  final String? email;
  final String? avatarUrl;
  final String notificationTime;
  final String theme;
  final String accentColor;
  final double fontScale;
  final String cardStyle;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    this.displayName,
    this.email,
    this.avatarUrl,
    this.notificationTime = '08:00:00',
    this.theme = 'system',
    this.accentColor = 'purple',
    this.fontScale = 1.0,
    this.cardStyle = 'modern',
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      displayName: json['display_name'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      notificationTime: json['notification_time'] ?? '08:00:00',
      theme: json['theme'] ?? 'system',
      accentColor: json['accent_color'] ?? 'purple',
      fontScale: (json['font_scale'] ?? 1.0).toDouble(),
      cardStyle: json['card_style'] ?? 'modern',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'notification_time': notificationTime,
      'theme': theme,
      'accent_color': accentColor,
      'font_scale': fontScale,
      'card_style': cardStyle,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? email,
    String? avatarUrl,
    String? notificationTime,
    String? theme,
    String? accentColor,
    double? fontScale,
    String? cardStyle,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      notificationTime: notificationTime ?? this.notificationTime,
      theme: theme ?? this.theme,
      accentColor: accentColor ?? this.accentColor,
      fontScale: fontScale ?? this.fontScale,
      cardStyle: cardStyle ?? this.cardStyle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfile &&
        other.id == id &&
        other.displayName == displayName &&
        other.email == email &&
        other.avatarUrl == avatarUrl &&
        other.notificationTime == notificationTime &&
        other.theme == theme &&
        other.accentColor == accentColor &&
        other.fontScale == fontScale &&
        other.cardStyle == cardStyle;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        displayName.hashCode ^
        email.hashCode ^
        avatarUrl.hashCode ^
        notificationTime.hashCode ^
        theme.hashCode ^
        accentColor.hashCode ^
        fontScale.hashCode ^
        cardStyle.hashCode;
  }
}
