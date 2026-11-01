import 'package:flutter/material.dart';

import 'package:my_first_app/utils/app_image_impl.dart'
    if (dart.library.html) 'package:my_first_app/utils/app_image_web.dart' as impl;

/// Картинка по пути: emoji / http(s) / blob / локальный файл (не на web).
Widget appImage(
  String? path, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  Widget? fallback,
}) {
  return impl.buildAppImage(
    path,
    fit: fit,
    width: width,
    height: height,
    fallback: fallback,
  );
}

/// True, если строка похожа на путь к файлу/сети, а не на emoji.
bool looksLikeImagePath(String? value) {
  if (value == null || value.isEmpty) return false;
  if (value.startsWith('http://') ||
      value.startsWith('https://') ||
      value.startsWith('blob:') ||
      value.startsWith('data:')) {
    return true;
  }
  if (value.contains('/') || value.contains('\\')) return true;
  return false;
}

/// Провайдер для CircleAvatar (null на web для локальных путей без blob/http).
ImageProvider? appImageProvider(String? path) => impl.imageProviderFor(path);
