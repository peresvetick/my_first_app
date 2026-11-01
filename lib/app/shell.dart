import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:my_first_app/app/theme/app_theme.dart';
import 'package:my_first_app/data/app_store.dart';
import 'package:my_first_app/features/auth/login_screen.dart';

/// Корневое приложение NatureHub.
class NatureHubApp extends StatelessWidget {
  const NatureHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppStore().darkModeNotifier,
      builder: (_, isDark, __) {
        return ValueListenableBuilder<String>(
          valueListenable: AppStore().themePresetNotifier,
          builder: (_, preset, __) {
            return ValueListenableBuilder<double>(
              valueListenable: AppStore().fontSizeMultiplierNotifier,
              builder: (_, scale, __) {
                return MaterialApp(
                  title: 'NatureHub',
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                  theme: buildThemeForPreset(preset, dark: false),
                  darkTheme: buildThemeForPreset(preset, dark: true),
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(scale),
                      ),
                      child: child ?? const SizedBox.shrink(),
                    );
                  },
                  home: const LoginScreen(),
                );
              },
            );
          },
        );
      },
    );
  }
}
