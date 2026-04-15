import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  //  Sign up traveler
  Future<AuthResponse> signUpTraveler({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    // Create traveler entry
    if (response.user != null) {
      await _supabase.from('travelers').insert({
        'id': response.user!.id,
        'full_name': fullName,
        'email': email,
      });
    }

    return response;
  }

  //  Login traveler
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ✅ Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ✅ Get current user
  User? get currentUser => _supabase.auth.currentUser;
}
