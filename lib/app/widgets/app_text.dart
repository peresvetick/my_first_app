import 'package:flutter/material.dart';
import 'package:my_first_app/data/app_store.dart';

/// Текст с учётом настройки «Для дедов» (fontSizeMultiplier).
class AppText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: AppStore().fontSizeMultiplierNotifier,
      builder: (_, scale, __) {
        final base = style ?? DefaultTextStyle.of(context).style;
        final fontSize = (base.fontSize ?? 14) * scale;
        return Text(
          data,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          style: base.copyWith(fontSize: fontSize),
        );
      },
    );
  }
}
