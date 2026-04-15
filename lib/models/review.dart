class Review {
  final String id;
  final String bookingId;
  final String travelerId;
  final String guideId;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.bookingId,
    required this.travelerId,
    required this.guideId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      bookingId: map['booking_id'],
      travelerId: map['traveler_id'],
      guideId: map['guide_id'],
      rating: double.tryParse(map['rating'].toString()) ?? 0,
      comment: map['comment'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'traveler_id': travelerId,
      'guide_id': guideId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
