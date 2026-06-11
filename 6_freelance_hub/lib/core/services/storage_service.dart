import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final _storage = FirebaseStorage.instance;

  /// Faz upload de uma foto de entrega para `delivery_photos/{contractId}/{nome}`.
  /// Retorna a download URL https que pode ser persistida no doc do contrato.
  Future<String> uploadDeliveryPhoto({
    required String contractId,
    required File file,
  }) async {
    final ext = _extensionFor(file.path);
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${_randomTag()}$ext';
    final ref = _storage.ref('delivery_photos/$contractId/$fileName');
    final metadata = SettableMetadata(
      contentType: _contentTypeFor(ext),
    );
    final task = await ref.putFile(file, metadata);
    return task.ref.getDownloadURL();
  }

  static String _extensionFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return '.png';
    if (lower.endsWith('.heic')) return '.heic';
    if (lower.endsWith('.webp')) return '.webp';
    return '.jpg';
  }

  static String _contentTypeFor(String ext) {
    switch (ext) {
      case '.png':
        return 'image/png';
      case '.heic':
        return 'image/heic';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  // 6 chars hex pseudo-random só pra evitar colisão se 2 uploads
  // baterem no mesmo millisecond (improvável, mas defensivo).
  static String _randomTag() {
    final ms = DateTime.now().microsecondsSinceEpoch;
    return ms.toRadixString(16).substring(ms.toRadixString(16).length - 6);
  }
}
