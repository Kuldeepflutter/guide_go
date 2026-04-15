import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:guidego/models/traveler.dart';
import 'package:guidego/models/guide.dart';
//import 'package:guidego/models/booking.dart';
import 'package:guidego/models/location.dart';
import 'package:guidego/models/review.dart';

class DbService {
  final SupabaseClient supabase = Supabase.instance.client;

  // 🔹 Fetch traveler by ID
  Future<Traveler?> fetchTraveler(String id) async {
    final data = await supabase.from('travelers').select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return Traveler.fromMap(data);
  }

  // 🔹 Update traveler info
  Future<void> updateTravelerProfile(String id, Map<String, dynamic> updates) async {
    await supabase.from('travelers').update(updates).eq('id', id);
  }

  // 🔹 Fetch all guides with location
  Future<List<Guide>> fetchGuides() async {
    final response = await supabase
        .from('guides')
        .select('*, locations:location_id(name, country)')
        .order('rating', ascending: false);
    return (response as List).map((e) => Guide.fromMap(e)).toList();
  }

  // 🔹 Fetch single guide
  Future<Guide?> fetchGuideById(String id) async {
    final data = await supabase
        .from('guides')
        .select('*, locations:location_id(name)')
        .eq('id', id)
        .maybeSingle();
    return data == null ? null : Guide.fromMap(data);
  }

  // 🔹 Fetch locations
  Future<List<Location>> fetchLocations() async {
    final response = await supabase.from('locations').select().order('name', ascending: true);
    return (response as List).map((e) => Location.fromMap(e)).toList();
  }

  // 🔹 Fetch reviews for a guide
  Future<List<Review>> fetchReviews(String guideId) async {
    final response =
    await supabase.from('reviews').select().eq('guide_id', guideId).order('created_at', ascending: false);
    return (response as List).map((e) => Review.fromMap(e)).toList();
  }
}

