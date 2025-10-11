class AppUser {
  final String id;
  final String? displayName;
  final String? email;
  final String? avatarUrl;
  final double trustScore;
  final int points;
  final List<dynamic> badges;
  final Map<String, dynamic>? location;

  AppUser({
    required this.id,
    this.displayName,
    this.email,
    this.avatarUrl,
    this.trustScore = 0,
    this.points = 0,
    this.badges = const [],
    this.location,
  });

  factory AppUser.fromMap(Map<String, dynamic> m) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return AppUser(
      id: m['id']?.toString() ?? '',
      displayName: m['display_name'],
      email: m['email'],
      avatarUrl: m['avatar_url'],
      trustScore: parseDouble(m['trust_score']),
      points: (m['points'] is int) ? m['points'] as int : int.tryParse(m['points']?.toString() ?? '0') ?? 0,
      badges: m['badges'] ?? [],
      location: m['location'] is Map ? Map<String, dynamic>.from(m['location']) : null,
    );
  }
}
