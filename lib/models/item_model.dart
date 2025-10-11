class Item {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? category;
  final String? condition;
  final List<String> tags;
  final double radiusKm;
  final double trustScore;
  final String? imageUrl;
  final DateTime createdAt;
  final Map<String, dynamic>? location;

  Item({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.category,
    this.condition,
    this.tags = const [],
    this.radiusKm = 5.0,
    this.trustScore = 0.0,
    this.imageUrl,
    DateTime? createdAt,
    this.location,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Item.fromMap(Map<String, dynamic> m) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    List<String> parseTags(dynamic t) {
      if (t == null) return [];
      if (t is List) return t.map((e) => e.toString()).toList();
      if (t is String) return [t];
      return [];
    }

    return Item(
      id: m['id']?.toString() ?? '',
      userId: m['user_id']?.toString() ?? '',
      title: m['title'] ?? '',
      description: m['description'],
      category: m['category'],
      condition: m['condition'],
      tags: parseTags(m['tags']),
      radiusKm: parseDouble(m['radius_km']),
      trustScore: parseDouble(m['trust_score']),
      imageUrl: m['image_url'],
      createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : DateTime.now(),
      location: m['location'] is Map ? Map<String, dynamic>.from(m['location']) : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'category': category,
        'condition': condition,
        'tags': tags,
        'radius_km': radiusKm,
        'trust_score': trustScore,
        'image_url': imageUrl,
        'created_at': createdAt.toIso8601String(),
        'location': location,
      };
}
