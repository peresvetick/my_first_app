import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/app/theme/app_theme.dart';

void main() {
  test('тема NatureHub собирается', () {
    expect(buildNatureLightTheme().colorScheme.primary, isNotNull);
    expect(buildNatureDarkTheme().brightness, Brightness.dark);
  });
}
