import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:guidego/models/booking.dart';

class BookingTile extends StatelessWidget {
  final Booking booking;
  const BookingTile({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final date =
    DateFormat('EEE, MMM d').format(booking.startTime);
    final start = DateFormat('hh:mm a').format(booking.startTime);
    final end = DateFormat('hh:mm a').format(booking.endTime);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.calendar_month, color: Colors.teal),
        title: Text("Guide ID: ${booking.guideId}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$date\n$start - $end\nStatus: ${booking.status}"),
        trailing: booking.status == 'pending'
            ? IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cancel feature coming soon")),
            );
          },
        )
            : null,
      ),
    );
  }
}
