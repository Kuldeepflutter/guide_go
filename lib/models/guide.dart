class Guide {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? profileImage;
  final String? bio;
  final double? dayRate; // ✅ FIXED
  final int? experienceYears;
  final List<String>? languages;
  final double? rating;
  final String? locationId;
  final DateTime createdAt;

  Guide({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.profileImage,
    this.bio,
    this.dayRate,
    this.experienceYears,
    this.languages,
    this.rating,
    this.locationId,
    required this.createdAt,
  });

  factory Guide.fromMap(Map<String, dynamic> map) {
    return Guide(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      phone: map['phone']?.toString(),
      profileImage: map['profile_image'] as String?,
      bio: map['bio']?.toString(),

      // ✅ SAFE numeric parsing — column is "day_rate" in Supabase (snake_case)
      dayRate: (map['dayRate'] as num?)?.toDouble(),

      experienceYears: map['experience_years'] as int?,
      languages: map['languages'] != null
          ? List<String>.from(map['languages'])
          : null,
      rating: (map['rating'] as num?)?.toDouble(),
      locationId: map['location_id'] as String?,
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
      'bio': bio,
      'dayRate': dayRate,
      'experience_years': experienceYears,
      'languages': languages,
      'rating': rating,
      'location_id': locationId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
