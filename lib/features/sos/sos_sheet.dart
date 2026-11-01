import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import 'package:my_first_app/app/theme/app_theme.dart';
import 'package:my_first_app/app/widgets/app_text.dart';
import 'package:my_first_app/services/location_service.dart';

/// Красная SOS: инструкции и крупные координаты.
/// [lat]/[lng] — координаты с карты; иначе пробуем геолокацию / Москву.
Future<void> showSosSheet(BuildContext context, {double? lat, double? lng}) async {
  HapticFeedback.heavyImpact();
  LatLng coords = LocationService.moscow;
  if (lat != null && lng != null) {
    coords = LatLng(lat, lng);
  } else {
    final live = await LocationService().getCurrentLatLng();
    if (live != null) coords = live;
  }

  if (!context.mounted) return;
  final latStr = coords.latitude.toStringAsFixed(5);
  final lngStr = coords.longitude.toStringAsFixed(5);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.sos, color: Colors.red, size: 32),
                SizedBox(width: 8),
                Expanded(
                  child: AppText('SOS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const AppText(
              'Сохраните спокойствие. Вы находитесь здесь. Покажите этот экран спасателям',
              style: TextStyle(fontSize: 16, height: 1.35, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                children: [
                  const AppText('Ваши координаты', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SelectableText(
                    '$latStr\n$lngStr',
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 0.5, height: 1.25),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: '$latStr, $lngStr'));
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Координаты скопированы')));
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Скопировать для спасателей'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const AppText('1. Остановитесь и успокойтесь — не бегите наугад.'),
            const SizedBox(height: 8),
            const AppText('2. Позвоните 112. Назовите координаты выше.'),
            const SizedBox(height: 8),
            const AppText('3. Оставайтесь на месте, если безопасно. Экономьте батарею.'),
            const SizedBox(height: 8),
            const AppText('4. Подайте сигнал: свисток, фонарь, яркая ткань.'),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Понятно'),
            ),
          ],
        ),
      );
    },
  );
}
