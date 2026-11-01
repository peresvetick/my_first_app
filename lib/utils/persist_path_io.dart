import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String?> persistMediaPath(String sourcePath, String fileName) async {
  try {
    final appDir = await getApplicationDocumentsDirectory();
    final savedFile = File('${appDir.path}/$fileName');
    await File(sourcePath).copy(savedFile.path);
    return savedFile.path;
  } catch (_) {
    return null;
  }
}

bool mediaPathExists(String path) {
  try {
    return path.isNotEmpty && File(path).existsSync();
  } catch (_) {
    return false;
  }
}
