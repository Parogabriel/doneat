enum DonationCategory {
  meals,
  breads,
  fruits,
  vegetables,
  others;

  String toJson() => name.toUpperCase();

  static DonationCategory fromJson(String json) {
    switch (json.toUpperCase()) {
      case 'MEALS':
      case 'REFEIÇÕES':
        return DonationCategory.meals;
      case 'BREADS':
      case 'SALGADOS':
      case 'DOCES':
      case 'PÃES':
        return DonationCategory.breads;
      case 'FRUITS':
      case 'FRUTAS':
      case 'IN NATURA':
        return DonationCategory.fruits;
      case 'VEGETABLES':
      case 'VEGETAIS':
        return DonationCategory.vegetables;
      default:
        return DonationCategory.others;
    }
  }
}

enum DonationStatus {
  available,
  reserved,
  completed,
  cancelled;

  String toJson() => name.toUpperCase();

  static DonationStatus fromJson(String json) {
    switch (json.toUpperCase()) {
      case 'AVAILABLE':
        return DonationStatus.available;
      case 'RESERVED':
        return DonationStatus.reserved;
      case 'COMPLETED':
        return DonationStatus.completed;
      case 'CANCELLED':
        return DonationStatus.cancelled;
      default:
        return DonationStatus.available;
    }
  }
}

class DonationLocation {
  final double lat;
  final double lng;
  final String address;

  const DonationLocation({
    required this.lat,
    required this.lng,
    required this.address,
  });

  factory DonationLocation.fromJson(Map<String, dynamic> json) {
    return DonationLocation(
      lat: (json['lat'] as num?)?.toDouble() ?? -23.5505,
      lng: (json['lng'] as num?)?.toDouble() ?? -46.6333,
      address: json['address'] as String? ?? 'São Paulo, Brasil',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
    };
  }
}

class Donation {
  final String id;
  final String donorId;
  final String title;
  final String description;
  final DonationCategory category;
  final int quantity;
  final String unit;
  final DateTime expirationTime;
  final DonationStatus status;
  final DonationLocation location;
  final DateTime createdAt;
  final String? image;

  const Donation({
    required this.id,
    required this.donorId,
    required this.title,
    required this.description,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expirationTime,
    required this.status,
    required this.location,
    required this.createdAt,
    this.image,
  });

  factory Donation.fromJson(Map<String, dynamic> json, String id) {
    return Donation(
      id: id,
      donorId: json['donorId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: DonationCategory.fromJson(json['category'] as String? ?? 'Others'),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unit: json['unit'] as String? ?? 'units',
      expirationTime: json['expirationTime'] != null
          ? DateTime.parse(json['expirationTime'] as String)
          : DateTime.now().add(const Duration(hours: 4)),
      status: DonationStatus.fromJson(json['status'] as String? ?? 'AVAILABLE'),
      location: DonationLocation.fromJson(json['location'] as Map<String, dynamic>? ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'donorId': donorId,
      'title': title,
      'description': description,
      'category': category.toJson(),
      'quantity': quantity,
      'unit': unit,
      'expirationTime': expirationTime.toIso8601String(),
      'status': status.toJson(),
      'location': location.toJson(),
      'createdAt': createdAt.toIso8601String(),
      if (image != null) 'image': image,
    };
  }

  Donation copyWith({
    DonationStatus? status,
  }) {
    return Donation(
      id: id,
      donorId: donorId,
      title: title,
      description: description,
      category: category,
      quantity: quantity,
      unit: unit,
      expirationTime: expirationTime,
      status: status ?? this.status,
      location: location,
      createdAt: createdAt,
      image: image,
    );
  }
}
