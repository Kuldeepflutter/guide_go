import 'package:flutter/material.dart';
import 'package:guidego/models/guide.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GuideProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<Guide> _guides = [];
  List<Guide> get guides => _guides;

  Guide? _selectedGuide;
  Guide? get selectedGuide => _selectedGuide;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;
  Future<void> fetchGuides() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _supabase.from('guides').select();
      _guides = data.map((item) => Guide.fromMap(item)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  Future<void> fetchGuideById(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _supabase
          .from('guides')
          .select()
          .eq('id', id)
          .single();
         print("RAW GUIDE DATA: $data");
      _selectedGuide = Guide.fromMap(data);

    } catch (e) {
      _error = e.toString();
      _selectedGuide = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
    
  }

  // Clears the selected guide from memory.
  void clearSelectedGuide() {
    _selectedGuide = null;
    notifyListeners();
  }
}
