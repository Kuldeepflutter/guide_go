class AppUser {
  final String id;
  // Matches 'full_name' from the travelers table
  final String fullName;
  final String email;
  // Matches 'phone' from the travelers table (nullable)
  final String? phone;
  // Matches 'profile_image' from the travelers table (nullable)
  final String? profileImage;
  // Matches 'created_at' from the travelers table
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.createdAt,
    this.phone,
    this.profileImage,
  });

  /// Creates an [AppUser] from a map (from the 'travelers' table).
  factory AppUser.fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final fullName = map['full_name'];
    final email = map['email'];
    final createdAt = map['created_at'];

    if (id == null || fullName == null || email == null || createdAt == null) {
      throw ArgumentError(
          'User map must contain id, full_name, email, and created_at.');
    }

    return AppUser(
      id: id,
      fullName: fullName,
      email: email,
      createdAt: DateTime.parse(createdAt),
      phone: map['phone'],
      profileImage: map['profile_image'],
    );
  }

  /// Creates a map representation for inserting into the 'travelers' table.
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
