import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:guidego/providers/booking_provider.dart';
class BookingLocationView extends StatefulWidget {
  final String bookingId;

  const BookingLocationView({
    super.key, 
    required this.bookingId
  });

  @override
  State<BookingLocationView> createState() => _BookingLocationViewState();
}

class _BookingLocationViewState extends State<BookingLocationView> {
  // State variables
  LatLng? _location;
  bool _isLoading = true;
  String? _errorMessage;
  @override
   void initState() {
    super.initState();
    _fetchLocationData();
  }

  /// Simulates fetching data from your Booking Provider
  Future<void> _fetchLocationData() async {
    try {
     //fetch location from booking provider
      final bookingProvider = context.read<BookingProvider>();
      final locationStr = await bookingProvider.getBookingLocation(widget.bookingId);
      await Future.delayed(const Duration(seconds: 2));
      final parts = locationStr?.split(',') ?? [];
      if (parts.length != 2) {
        throw Exception("Invalid location format");
      }
      // 3. Mock Data: Replace this with your parsed API response
      // Example: final lat = response['lat']; final lng = response['lng'];
      final fetchedLocation = LatLng(
        double.parse(parts[0]),
        double.parse(parts[1]),
      );

      if (mounted) {
        setState(() {
          _location = fetchedLocation;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load location: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking #${widget.bookingId}"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // State 1: Loading
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Fetching booking location..."),
          ],
        ),
      );
    }

    // State 2: Error
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _fetchLocationData();
              },
              child: const Text("Retry"),
            )
          ],
        ),
      );
    }

    // State 3: Success (Show Map)
    return FlutterMap(
      options: MapOptions(
        initialCenter: _location!, // Center map on fetched location
        initialZoom: 15.0,
      ),
      children: [
        // Layer 1: The Map Tiles (OpenStreetMap)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.yourcompany.app',
        ),
        
        // Layer 2: The Marker Pin
        MarkerLayer(
          markers: [
            Marker(
              point: _location!,
              width: 80,
              height: 80,
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }
}