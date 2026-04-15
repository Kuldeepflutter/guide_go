import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:guidego/models/booking.dart';

class BookingService {
  final SupabaseClient supabase = Supabase.instance.client;

  //  Create booking
 
 // Future<void> createBooking(Map<String, dynamic> bookingData) async {
 //   await supabase.from('bookings').insert(bookingData);
 // }
Future<Map<String, dynamic>> createBooking(
    Map<String, dynamic> bookingData) async {
  final response = await supabase
      .from('bookings')
      .insert(bookingData)
      .select()
      .single();

  return response;
}
//update booking location 
  Future<void> updateBookingLocation({
    required String bookingId,
    required String location,
  }) async {
    try {
      await supabase
          .from('bookings')
          .update({
        'location': location,
      })
          .eq('id', bookingId);

      print('✅ Booking location updated');
    } catch (e) {
      print('❌ Error updating booking location: $e');
      throw Exception('Failed to update booking location');
    }
  }
  //view booking location
  Future<String?> getBookingLocation(String bookingId) async {
    final response = await supabase
        .from('bookings')
        .select('location')
        .eq('id', bookingId)
        .single();

    return response['location'] as String?;
  }


  //  Fetch bookings for a traveler
  Future<List<Booking>> fetchTravelerBookings(String travelerId) async {
    final response = await supabase
        .from('bookings')
        .select('*, guides(full_name, profile_image)')
        .eq('traveler_id', travelerId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => Booking.fromMap(e)).toList();
  }

  Future<Map<String, dynamic>> createRazorpayOrder({
    required String bookingId,
    required double amount,
  }) async {
    try {
      final response = await supabase.functions.invoke(
        'create-razorpay-order',
        body: {
          'booking_id': bookingId,
          'amount': amount,
        },
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Create Razorpay order failed: $e');
    }
  }


// verfiy payment 
  Future<bool> verifyRazorpayPayment({
    required String bookingId,
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    final response = await supabase.functions.invoke(
      'verify-razorpay-payment',
      body: {
        'booking_id': bookingId,
        'payment_id': paymentId,
        'order_id': orderId,
        'signature': signature,
      },
    );

    return response.data['success'] as bool;
  }

  Future<void> verifyPayment({
    required String bookingId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      await supabase.functions.invoke(
        'verify-payment',
        body: {
          'booking_id': bookingId,
          // ⚠️ These keys MUST match the "const { ... } = await req.json()" in your Deno code
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
      );
    } catch (e) {
      throw Exception('Payment verification failed: $e');
    }
  }
  //  Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    await supabase
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId);
  }

  Future<void> markPaymentFailed(String bookingId) async {
    await supabase
        .from('bookings')
        .update({'payment_status': 'failed'})
        .eq('id', bookingId);
  }

}

