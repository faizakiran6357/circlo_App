// class Exchange {
//   final String id;
//   final String itemId;
//   final String proposerId;
//   final List<String> offeredItemIds;
//   final String status;
//   final DateTime createdAt;
//   final DateTime? updatedAt;
//   final Map<String, dynamic>? meetupLocation;

//   Exchange({
//     required this.id,
//     required this.itemId,
//     required this.proposerId,
//     required this.offeredItemIds,
//     required this.status,
//     required this.createdAt,
//     this.updatedAt,
//     this.meetupLocation,
//   });

//   factory Exchange.fromMap(Map<String, dynamic> map) => Exchange(
//         id: map['id'].toString(),
//         itemId: map['item_id'].toString(),
//         proposerId: map['proposer_id'].toString(),
//         offeredItemIds: List<String>.from(map['offered_item_ids'] ?? []),
//         status: map['status'] ?? 'proposed',
//         createdAt: DateTime.parse(map['created_at']),
//         updatedAt: map['updated_at'] != null
//             ? DateTime.parse(map['updated_at'])
//             : null,
//         meetupLocation: map['meetup_location'] != null
//             ? Map<String, dynamic>.from(map['meetup_location'])
//             : null,
//       );
// }
// class Exchange {
//   final String id;
//   final String status;
//   final String? itemId;
//   final String? proposerId;
//   final List<dynamic>? offeredItemIds;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final Map<String, dynamic>? item;
//   final Map<String, dynamic>? proposer;
//   final List<dynamic>? offeredItems;

//   Exchange({
//     required this.id,
//     required this.status,
//     this.itemId,
//     this.proposerId,
//     this.offeredItemIds,
//     this.createdAt,
//     this.updatedAt,
//     this.item,
//     this.proposer,
//     this.offeredItems,
//   });

//   factory Exchange.fromMap(Map<String, dynamic> map) {
//     return Exchange(
//       id: map['id'].toString(),
//       status: map['status'] ?? '',
//       itemId: map['item_id']?.toString(),
//       proposerId: map['proposer_id']?.toString(),
//       offeredItemIds: map['offered_item_ids'] ?? [],
//       createdAt: map['created_at'] != null
//           ? DateTime.tryParse(map['created_at'])
//           : null,
//       updatedAt: map['updated_at'] != null
//           ? DateTime.tryParse(map['updated_at'])
//           : null,
//       item: map['items'] != null
//           ? Map<String, dynamic>.from(map['items'])
//           : null,
//       proposer: map['proposer'] != null
//           ? Map<String, dynamic>.from(map['proposer'])
//           : null,
//       offeredItems: map['offered_items'] != null
//           ? List<Map<String, dynamic>>.from(map['offered_items'])
//           : [],
//     );
//   }
// }
// class Exchange {
//   final String id;
//   final String itemId;
//   final String proposerId;
//   final List<String> offeredItemIds;
//   final String status;
//   final Map<String, dynamic>? meetupLocation;
//   final DateTime createdAt;
//   final DateTime? updatedAt;

//   Exchange({
//     required this.id,
//     required this.itemId,
//     required this.proposerId,
//     required this.offeredItemIds,
//     required this.status,
//     this.meetupLocation,
//     required this.createdAt,
//     this.updatedAt,
//   });

//   /// 🧩 Create Exchange object from Supabase record
//   factory Exchange.fromMap(Map<String, dynamic> map) {
//     return Exchange(
//       id: map['id'].toString(),
//       itemId: map['item_id'].toString(),
//       proposerId: map['proposer_id'].toString(),
//       offeredItemIds: map['offered_item_ids'] != null
//           ? List<String>.from(map['offered_item_ids'])
//           : [],
//       status: map['status'] ?? 'proposed',
//       meetupLocation: map['meetup_location'] != null
//           ? Map<String, dynamic>.from(map['meetup_location'])
//           : null,
//       createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
//       updatedAt: map['updated_at'] != null
//           ? DateTime.tryParse(map['updated_at'])
//           : null,
//     );
//   }

//   /// 🧩 Convert to Map for Supabase insert/update
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'item_id': itemId,
//       'proposer_id': proposerId,
//       'offered_item_ids': offeredItemIds,
//       'status': status,
//       'meetup_location': meetupLocation,
//       'created_at': createdAt.toIso8601String(),
//       'updated_at': updatedAt?.toIso8601String(),
//     };
//   }

//   /// 🧩 Clone with changes (for provider updates)
//   Exchange copyWith({
//     String? id,
//     String? itemId,
//     String? proposerId,
//     List<String>? offeredItemIds,
//     String? status,
//     Map<String, dynamic>? meetupLocation,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return Exchange(
//       id: id ?? this.id,
//       itemId: itemId ?? this.itemId,
//       proposerId: proposerId ?? this.proposerId,
//       offeredItemIds: offeredItemIds ?? this.offeredItemIds,
//       status: status ?? this.status,
//       meetupLocation: meetupLocation ?? this.meetupLocation,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }
// }
class Exchange {
  final String id;
  final String itemId;
  final String proposerId;
  final List<String> offeredItemIds;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Optional joined data (for displaying details)
  final Map<String, dynamic>? item;          // Item being requested
  final Map<String, dynamic>? offeredItem;   // Item offered by proposer
  final Map<String, dynamic>? proposer;      // Proposer user info

  Exchange({
    required this.id,
    required this.itemId,
    required this.proposerId,
    required this.offeredItemIds,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.item,
    this.offeredItem,
    this.proposer,
  });

  /// ✅ Factory constructor to build from a Supabase record
  factory Exchange.fromMap(Map<String, dynamic> map) {
    return Exchange(
      id: map['id'].toString(),
      itemId: map['item_id']?.toString() ?? '',
      proposerId: map['proposer_id']?.toString() ?? '',
      offeredItemIds: (map['offered_item_ids'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: map['status'] ?? 'unknown',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt:
          map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,
      item: map['item'] != null
          ? Map<String, dynamic>.from(map['item'])
          : null,
      offeredItem: map['offered_item'] != null
          ? Map<String, dynamic>.from(map['offered_item'])
          : null,
      proposer: map['proposer'] != null
          ? Map<String, dynamic>.from(map['proposer'])
          : null,
    );
  }

  /// ✅ Convert back to map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_id': itemId,
      'proposer_id': proposerId,
      'offered_item_ids': offeredItemIds,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// ✅ Allows copying and updating only specific fields
  Exchange copyWith({
    String? id,
    String? itemId,
    String? proposerId,
    List<String>? offeredItemIds,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? item,
    Map<String, dynamic>? offeredItem,
    Map<String, dynamic>? proposer,
  }) {
    return Exchange(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      proposerId: proposerId ?? this.proposerId,
      offeredItemIds: offeredItemIds ?? this.offeredItemIds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      item: item ?? this.item,
      offeredItem: offeredItem ?? this.offeredItem,
      proposer: proposer ?? this.proposer,
    );
  }
}
