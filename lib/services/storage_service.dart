import 'dart:typed_data';
import 'api_client.dart';

/// Uploads images through the backend's /me/upload endpoint rather than
/// calling Supabase Storage directly from the client. The backend uses its
/// service-role key, so the upload always succeeds for any authenticated
/// user regardless of the Flutter Supabase client's own session/token state.
class StorageService {
  StorageService._();
  static final instance = StorageService._();

  Future<String> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) {
    return ApiClient.instance.uploadFile(
      path: '/me/upload',
      bytes: bytes,
      fileName: fileName,
      contentType: contentType,
    );
  }
}
