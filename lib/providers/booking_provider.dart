import 'package:flutter/material.dart';
import 'package:guidego/models/booking.dart';
import 'package:guidego/screens/payment_screen.dart';
import 'package:guidego/services/booking_service.dart';
import 'package:guidego/services/auth_service.dart';

class BookingProvider extends ChangeNotifier {
  final _bookingService = BookingService();
  final _authService = AuthService();

  List<Booking> _bookings = [];
  List<Booking> get bookings => _bookings;

  bool _loading = false;
  bool get loading => _loading;

  // 🔹 Load bookings
  Future<void> loadBookings() async {
    final user = _authService.currentUser;
    if (user == null) return;

    _loading = true;
    notifyListeners();

    _bookings = await _bookingService.fetchTravelerBookings(user.id);

    _loading = false;
    notifyListeners();
  }

  // 🔹 Create booking + payment
  Future<void> createBookingAndPay(
    BuildContext context,
    Map<String, dynamic> bookingData,
  ) async {
    // 1️⃣ Create booking (payment_status = pending)
    final booking = await _bookingService.createBooking(bookingData);

    final bookingId = booking['id'];
    final amount = double.parse(booking['total_amount'].toString());

    // 2️⃣ Create Razorpay order
    final order = await _bookingService.createRazorpayOrder(
      bookingId: bookingId,
      amount: (amount * 1),
    );

    final orderId = order['order_id'];

    // 3️⃣ Open payment screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          bookingId: bookingId,
          orderId: orderId, // This is now correctly passed
          amount: amount.round(), // FIX: Convert double to int here
        ),
      ),
    );

    // 4️⃣ Refresh bookings
    await loadBookings();
  }

  // 🔹 Verify payment
  Future<void> verifyPayment({
    required String bookingId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    await _bookingService.verifyPayment(
      bookingId: bookingId,
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
    );

    await loadBookings();
  }

  // 🔹 Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    await _bookingService.cancelBooking(bookingId);
    await loadBookings();
  }

  // 🔹 Mark payment failed
  Future<void> markPaymentFailed(String bookingId) async {
    await _bookingService.markPaymentFailed(bookingId);
    await loadBookings();
  }

  Future<void> updateBookingLocation({
    required String bookingId,
    required String location,
  }) async {
    await _bookingService.updateBookingLocation(
      bookingId: bookingId,
      location: location,
    );
    await loadBookings();
  }
 // 🔹 Get booking location
  Future<String?> getBookingLocation(String bookingId) async {
    return await _bookingService.getBookingLocation(bookingId);
  }
}
