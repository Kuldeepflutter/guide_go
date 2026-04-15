class Booking {
  final String id;
  final String travelerId;
  final String guideId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalAmount;
  final String? message;
  final String status;
  final String paymentStatus;  // ✅ Added — maps to payment_status column
  final String? location;      // ✅ Added — "lat,lng" string
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.travelerId,
    required this.guideId,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    this.message,
    required this.status,
    this.paymentStatus = 'pending',
    this.location,
    required this.createdAt,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      travelerId: map['traveler_id'],
      guideId: map['guide_id'],
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      totalAmount: double.tryParse(map['total_amount'].toString()) ?? 0,
      message: map['message'],
      status: map['status'] ?? 'pending',
      paymentStatus: map['payment_status'] ?? 'pending',
      location: map['location'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'traveler_id': travelerId,
      'guide_id': guideId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'total_amount': totalAmount,
      'message': message,
      'status': status,
      'payment_status': paymentStatus,
      'location': location,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
