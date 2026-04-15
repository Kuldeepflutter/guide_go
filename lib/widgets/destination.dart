import 'package:flutter/material.dart';
import 'package:guidego/models/location.dart';

class DestinationCard extends StatelessWidget {
  final Location location;
  const DestinationCard({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.teal.shade100,
        borderRadius: BorderRadius.circular(16),
        image: location.imageUrl != null
            ? DecorationImage(
          image: NetworkImage(location.imageUrl!),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(76), BlendMode.darken),
        )
            : null,
      ),
      child: Center(
        child: Text(
          location.name,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
