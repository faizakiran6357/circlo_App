// class AppUser {
//   final String id;
//   final String? displayName;
//   final String? email;
//   final String? avatarUrl;
//   final double trustScore;
//   final int points;
//   final List<dynamic> badges;
//   final Map<String, dynamic>? location;

//   AppUser({
//     required this.id,
//     this.displayName,
//     this.email,
//     this.avatarUrl,
//     this.trustScore = 0,
//     this.points = 0,
//     this.badges = const [],
//     this.location,
//   });

//   factory AppUser.fromMap(Map<String, dynamic> m) {
//     double parseDouble(dynamic v) {
//       if (v == null) return 0.0;
//       if (v is double) return v;
//       if (v is int) return v.toDouble();
//       if (v is String) return double.tryParse(v) ?? 0.0;
//       return 0.0;
//     }

//     return AppUser(
//       id: m['id']?.toString() ?? '',
//       displayName: m['display_name'],
//       email: m['email'],
//       avatarUrl: m['avatar_url'],
//       trustScore: parseDouble(m['trust_score']),
//       points: (m['points'] is int) ? m['points'] as int : int.tryParse(m['points']?.toString() ?? '0') ?? 0,
//       badges: m['badges'] ?? [],
//       location: m['location'] is Map ? Map<String, dynamic>.from(m['location']) : null,
//     );
//   }
// }
class AppUser {
  final String id;
  final String? displayName;
  final String? email;
  final String? avatarUrl;
  final double trustScore;
  final int points;
  final List<dynamic> badges;
  final Map<String, dynamic>? location;
  final double? radiusKm; // ✅ Added to store preferred radius

  AppUser({
    required this.id,
    this.displayName,
    this.email,
    this.avatarUrl,
    this.trustScore = 0,
    this.points = 0,
    this.badges = const [],
    this.location,
    this.radiusKm = 30, // ✅ Default to 30km
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
      points: (m['points'] is int)
          ? m['points'] as int
          : int.tryParse(m['points']?.toString() ?? '0') ?? 0,
      badges: m['badges'] ?? [],
      location: m['location'] is Map
          ? Map<String, dynamic>.from(m['location'])
          : null,
      radiusKm: parseDouble(m['radius_km']), // ✅ Read from Supabase if exists
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'display_name': displayName,
      'email': email,
      'avatar_url': avatarUrl,
      'trust_score': trustScore,
      'points': points,
      'badges': badges,
      'location': location,
      'radius_km': radiusKm, // ✅ Include in map for Supabase
    };
  }

  // ✅ Fix for your "copyWith not defined" error
  AppUser copyWith({
    String? id,
    String? displayName,
    String? email,
    String? avatarUrl,
    double? trustScore,
    int? points,
    List<dynamic>? badges,
    Map<String, dynamic>? location,
    double? radiusKm,
  }) {
    return AppUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      trustScore: trustScore ?? this.trustScore,
      points: points ?? this.points,
      badges: badges ?? this.badges,
      location: location ?? this.location,
      radiusKm: radiusKm ?? this.radiusKm,
    );
  }
}
