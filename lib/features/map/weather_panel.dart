import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:my_first_app/app/theme/app_theme.dart';
import 'package:my_first_app/app/widgets/app_widgets.dart';
import 'package:my_first_app/services/weather_service.dart';

/// Компактная погода: Сейчас / +1ч / +3ч.
class WeatherPanel extends StatelessWidget {
  final WeatherSnapshot? snapshot;
  final String placeName;
  final bool loading;
  final VoidCallback onChooseCity;

  const WeatherPanel({
    super.key,
    required this.snapshot,
    required this.placeName,
    required this.loading,
    required this.onChooseCity,
  });

  int? _tempAt(List<HourlyWeather> hours, int index) {
    if (hours.isEmpty) return null;
    if (index < hours.length) return hours[index].temperature;
    return hours.last.temperature;
  }

  @override
  Widget build(BuildContext context) {
    final current = snapshot?.current;
    final code = current == null ? 99 : (current['weathercode'] as num?)?.toInt() ?? 99;
    final nowTemp = current == null ? null : (current['temperature'] as num?)?.round();
    final hours = snapshot?.hourly ?? const <HourlyWeather>[];
    // hourly[0] часто «Сейчас»; +1ч ≈ index 1; +3ч ≈ index 3
    final t1 = _tempAt(hours, hours.isNotEmpty && hours.first.label == 'Сейчас' ? 1 : 0);
    final t3 = _tempAt(hours, hours.isNotEmpty && hours.first.label == 'Сейчас' ? 3 : 2);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      gradient: const LinearGradient(
        colors: [Color(0xFF1B5E3B), Color(0xFF2E7D4F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onChooseCity,
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          placeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                      const Icon(Icons.expand_more, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),
              Text(WeatherService.emojiForCode(code), style: const TextStyle(fontSize: 20)),
              if (loading) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            child: Row(
              key: ValueKey('$nowTemp-$t1-$t3'),
              children: [
                _Chip(label: 'weather_now'.tr(), value: nowTemp),
                const SizedBox(width: 8),
                _Chip(label: 'weather_in_1h'.tr(), value: t1),
                const SizedBox(width: 8),
                _Chip(label: 'weather_in_3h'.tr(), value: t3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final int? value;
  const _Chip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10), textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(
              value == null ? '—' : '$value°C',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
