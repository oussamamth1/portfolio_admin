import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class StorageService {
  StorageService._();
  static final instance = StorageService._();

  Future<String> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) async {
    final client = Supabase.instance.client;
    final path = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await client.storage
        .from(AppConfig.storageBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );
    return client.storage.from(AppConfig.storageBucket).getPublicUrl(path);
  }
}
