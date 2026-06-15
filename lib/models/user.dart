enum UserRole {
  donor,
  receiver,
  admin;

  String toJson() => name.toUpperCase();

  static UserRole? fromJson(String? json) {
    if (json == null || json.isEmpty) return null;
    switch (json.toUpperCase()) {
      case 'DONOR':
        return UserRole.donor;
      case 'RECEIVER':
        return UserRole.receiver;
      case 'ADMIN':
        return UserRole.admin;
      default:
        return null;
    }
  }
}

class UserLocation {
  final double lat;
  final double lng;

  const UserLocation({
    required this.lat,
    required this.lng,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
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

class User {
  final String userId;
  final String displayName;
  final String email;
  final UserRole? role;
  final String? businessName;
  final int xp;
  final int level;
  final List<String> badges;
  final UserLocation? location;

  const User({
    required this.userId,
    required this.displayName,
    required this.email,
    this.role,
    this.businessName,
    required this.xp,
    required this.level,
    required this.badges,
    this.location,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      role: UserRole.fromJson(json['role'] as String?),
      businessName: json['businessName'] as String?,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      badges: List<String>.from(json['badges'] as List? ?? []),
      location: json['location'] != null
          ? UserLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'role': role?.toJson(),
      if (businessName != null) 'businessName': businessName,
      'xp': xp,
      'level': level,
      'badges': badges,
      if (location != null) 'location': location!.toJson(),
    };
  }

  User copyWith({
    String? displayName,
    UserRole? role,
    String? businessName,
    int? xp,
    int? level,
    List<String>? badges,
    UserLocation? location,
  }) {
    return User(
      userId: userId,
      displayName: displayName ?? this.displayName,
      email: email,
      role: role ?? this.role,
      businessName: businessName ?? this.businessName,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      badges: badges ?? this.badges,
      location: location ?? this.location,
    );
  }
}
