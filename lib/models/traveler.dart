class Traveler {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? profileImage;
  final DateTime createdAt;

  Traveler({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.profileImage,
    required this.createdAt,
  });

  factory Traveler.fromMap(Map<String, dynamic> map) {
    return Traveler(
      id: map['id'],
      fullName: map['full_name'],
      email: map['email'],
      phone: map['phone'],
      profileImage: map['profile_image'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
