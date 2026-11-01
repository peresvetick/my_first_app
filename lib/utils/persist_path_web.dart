Future<String?> persistMediaPath(String sourcePath, String fileName) async {
  if (sourcePath.isEmpty) return null;
  return sourcePath;
}

bool mediaPathExists(String path) => path.isNotEmpty;
