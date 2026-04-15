import 'package:flutter/material.dart';
import 'package:guidego/models/traveler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TravelerProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  Traveler? _traveler;
  Traveler? get traveler => _traveler;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Fetches the traveler's profile, creating it if it doesn't exist.
  Future<void> loadTraveler() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final supabaseUser = _supabase.auth.currentUser;
      if (supabaseUser == null) {
        throw Exception('User is not authenticated.');
      }

      final userId = supabaseUser.id;
      final userEmail = supabaseUser.email;

      // Corrected: Safely query for the profile without using .single().
      final response = await _supabase
          .from('travelers')
          .select()
          .eq('id', userId);

      Map<String, dynamic> profileData;

      // **CORRECTED SELF-HEALING LOGIC:**
      if (response.isEmpty) {
        // If no profile exists, create one.
        final newProfile = {
          'id': userId,
          'full_name': userEmail ?? 'New Traveler', // Use email as a fallback name
          'email': userEmail,
        };

        profileData = await _supabase
            .from('travelers')
            .insert(newProfile)
            .select()
            .single();

      } else {
        // If profile exists, use the first result.
        profileData = response.first;
      }

      _traveler = Traveler.fromMap(profileData);

    } catch (e) {
      _error = e.toString();
      _traveler = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Updates the traveler's profile.
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (_traveler == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _supabase
          .from('travelers')
          .update(updates)
          .eq('id', _traveler!.id);

      await loadTraveler(); // Refresh data after update.
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clears traveler data on logout.
  void clearTraveler() {
    _traveler = null;
    notifyListeners();
  }
}
