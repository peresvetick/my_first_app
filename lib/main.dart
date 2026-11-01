import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:my_first_app/app/shell.dart';
import 'package:my_first_app/data/app_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('app_data');
  await AppStore().init();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ru'), Locale('en'), Locale('zh')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ru'),
      startLocale: Locale(AppStore().localeCode),
      child: const NatureHubApp(),
    ),
  );
}
