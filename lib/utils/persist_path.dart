import 'package:my_first_app/utils/persist_path_io.dart'
    if (dart.library.html) 'package:my_first_app/utils/persist_path_web.dart' as impl;

/// Копирует файл в documents (mobile) или возвращает исходный path (web).
Future<String?> persistMediaPath(String sourcePath, String fileName) {
  return impl.persistMediaPath(sourcePath, fileName);
}

/// Проверка существования локального файла (на web — true для непустого path).
bool mediaPathExists(String path) => impl.mediaPathExists(path);
