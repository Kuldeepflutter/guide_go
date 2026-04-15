import 'package:flutter/material.dart';
import 'package:guidego/models/guide.dart';
import 'package:go_router/go_router.dart';

class GuideCard extends StatelessWidget {
  final Guide guide;
  const GuideCard({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: guide.profileImage != null
              ? NetworkImage(guide.profileImage!)
              : null,
          child: guide.profileImage == null
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(
          guide.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "⭐ ${guide.rating?.toStringAsFixed(1) ?? '0.0'}  •  ₹${guide.dayRate?.toStringAsFixed(0) ?? '--'}/hr",
        ),
        onTap: () => context.push('/guide/${guide.id}'),
      ),
    );
  }
}
