import 'package:flutter/material.dart';

import 'package:my_first_app/utils/app_image.dart' show looksLikeImagePath;

Widget buildAppImage(
  String? path, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  Widget? fallback,
}) {
  if (path == null || path.isEmpty) {
    return fallback ?? const SizedBox.shrink();
  }
  if (!looksLikeImagePath(path)) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(child: Text(path, style: TextStyle(fontSize: (height ?? 48) * 0.5))),
    );
  }
  if (path.startsWith('http://') ||
      path.startsWith('https://') ||
      path.startsWith('blob:') ||
      path.startsWith('data:')) {
    return Image.network(
      path,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) =>
          fallback ?? const ColoredBox(color: Colors.black12, child: Icon(Icons.broken_image)),
    );
  }
  return fallback ??
      ColoredBox(
        color: Colors.black12,
        child: SizedBox(
          width: width,
          height: height,
          child: const Icon(Icons.image_not_supported),
        ),
      );
}

ImageProvider? imageProviderFor(String? path) {
  if (path == null || path.isEmpty || !looksLikeImagePath(path)) return null;
  if (path.startsWith('http://') ||
      path.startsWith('https://') ||
      path.startsWith('blob:') ||
      path.startsWith('data:')) {
    return NetworkImage(path);
  }
  return null;
}
