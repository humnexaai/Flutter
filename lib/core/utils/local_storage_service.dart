import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  const LocalStorageService._();

  static Future<File> savePdfToDownloads(
    Uint8List bytes, {
    required String fileName,
  }) async {
    final downloadDir = await _resolveDownloadDirectory();
    final safeName = fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';
    final file = File(p.join(downloadDir.path, safeName));
    return file.writeAsBytes(bytes, flush: true);
  }

  static Future<Directory> _resolveDownloadDirectory() async {
    if (Platform.isAndroid) {
      final nativeDownloads = Directory('/storage/emulated/0/Download');
      if (await nativeDownloads.exists()) {
        return nativeDownloads;
      }
    }

    try {
      final candidate = await getDownloadsDirectory();
      if (candidate != null) {
        return candidate;
      }
    } catch (_) {
      // Fallback handled below for platforms without download dirs.
    }

    return getApplicationDocumentsDirectory();
  }
}
