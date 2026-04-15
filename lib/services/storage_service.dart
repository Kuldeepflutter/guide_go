import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<String?> uploadProfileImage({
    required File file,
    required String userId,
  }) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName = 'traveler_$userId.$fileExt';
      final filePath = fileName;

      await supabase.storage
          .from('profile_pics')
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));
      
      final publicUrl =
          supabase.storage.from('profile_pics').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
       print('Upload error: $e');
      return null;
    }
  }
}
