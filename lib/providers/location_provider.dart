import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:guidego/models/location.dart'; // Assuming this model exists

/// Provides and manages location data from the database.
class LocationProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<Location> _locations = [];
  List<Location> get locations => _locations;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Fetches all locations from the public 'locations' table.
  Future<void> fetchLocations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase.from('locations').select();

      _locations = response.map((data) => Location.fromMap(data)).toList();

    } catch (e) {
      _error = e.toString();
      _locations = []; // Clear locations on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches a single location by its ID.
  Future<String?> fetchLocationNameById(String locationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('locations')
          .select('name')
          .eq('location_id', locationId)
          .single();

      return response['name'] as String;

    } catch (e) {
      _error = e.toString();
      return null; // Return null on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
