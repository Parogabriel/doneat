enum PickupStatus {
  awaiting,
  inTransit,
  delivered,
  cancelled;

  String toJson() => name.toUpperCase();

  static PickupStatus fromJson(String json) {
    switch (json.toUpperCase()) {
      case 'AWAITING':
        return PickupStatus.awaiting;
      case 'IN_TRANSIT':
      case 'INTRANSIT':
        return PickupStatus.inTransit;
      case 'DELIVERED':
        return PickupStatus.delivered;
      case 'CANCELLED':
        return PickupStatus.cancelled;
      default:
        return PickupStatus.awaiting;
    }
  }
}

class GeoPoint {
  final double lat;
  final double lng;

  const GeoPoint({
    required this.lat,
    required this.lng,
  });

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}

class Pickup {
  final String id;
  final String donationId;
  final String donorId;
  final String receiverId;
  final PickupStatus status;
  final GeoPoint? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Pickup({
    required this.id,
    required this.donationId,
    required this.donorId,
    required this.receiverId,
    required this.status,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pickup.fromJson(Map<String, dynamic> json, String id) {
    final location = json['currentLocation'] as Map<String, dynamic>?;
    return Pickup(
      id: id,
      donationId: json['donationId'] as String? ?? '',
      donorId: json['donorId'] as String? ?? '',
      receiverId: json['receiverId'] as String? ?? '',
      status: PickupStatus.fromJson(json['status'] as String? ?? 'AWAITING'),
      location: location != null ? GeoPoint.fromJson(location) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'donationId': donationId,
      'donorId': donorId,
      'receiverId': receiverId,
      'status': status.toJson(),
      if (location != null) 'currentLocation': location!.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
