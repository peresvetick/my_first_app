import 'dart:convert';

import 'package:http/http.dart' as http;

/// Прогноз погоды через Open-Meteo + поиск города.
class WeatherService {
  /// Текущая погода и ближайшие часы.
  Future<WeatherSnapshot> fetch(double lat, double lng) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng'
      '&current_weather=true'
      '&hourly=temperature_2m,weathercode,windspeed'
      '&forecast_days=1',
    );
    final response = await http
        .get(url, headers: {'User-Agent': 'NatureHub/1.0'})
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('weather ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final current = Map<String, dynamic>.from(data['current_weather'] as Map);
    final hourly = data['hourly'] as Map<String, dynamic>?;
    final hours = <HourlyWeather>[];
    if (hourly != null) {
      final times = hourly['time'] as List;
      final temps = hourly['temperature_2m'] as List;
      final codes = hourly['weathercode'] as List;
      final winds = hourly['windspeed'] as List;
      final now = DateTime.now();
      var start = 0;
      for (var i = 0; i < times.length; i++) {
        if (DateTime.parse(times[i].toString()).hour >= now.hour) {
          start = i;
          break;
        }
      }
      for (var i = start; i < start + 8 && i < times.length; i++) {
        final t = DateTime.parse(times[i].toString());
        final diff = t.difference(now).inHours;
        final label = diff <= 0
            ? 'Сейчас'
            : (diff <= 3 ? '+$diff ч' : '${t.hour.toString().padLeft(2, '0')}:00');
        hours.add(HourlyWeather(
          label: label,
          temperature: (temps[i] as num).round(),
          weatherCode: codes[i] as int,
          windSpeed: (winds[i] as num).round(),
        ));
      }
    }
    return WeatherSnapshot(current: current, hourly: hours);
  }

  /// Поиск городов (Open-Meteo Geocoding).
  Future<List<GeoCity>> searchCities(String query) async {
    if (query.trim().length < 2) return [];
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(query)}'
      '&count=8&language=ru&format=json',
    );
    final response = await http
        .get(url, headers: {'User-Agent': 'NatureHub/1.0'})
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return [];
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List? ?? [];
    return results.map((e) {
      final m = e as Map<String, dynamic>;
      final admin = m['admin1'] != null ? ', ${m['admin1']}' : '';
      final country = m['country'] != null ? ', ${m['country']}' : '';
      return GeoCity(
        name: '${m['name']}$admin$country',
        lat: (m['latitude'] as num).toDouble(),
        lng: (m['longitude'] as num).toDouble(),
      );
    }).toList();
  }

  static String emojiForCode(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 48) return '🌫️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '🌨️';
    if (code <= 82) return '🌧️';
    if (code <= 99) return '⛈️';
    return '🌡️';
  }
}

class WeatherSnapshot {
  final Map<String, dynamic> current;
  final List<HourlyWeather> hourly;
  WeatherSnapshot({required this.current, required this.hourly});
}

class HourlyWeather {
  final String label;
  final int temperature;
  final int weatherCode;
  final int windSpeed;
  HourlyWeather({
    required this.label,
    required this.temperature,
    required this.weatherCode,
    required this.windSpeed,
  });
}

class GeoCity {
  final String name;
  final double lat;
  final double lng;
  GeoCity({required this.name, required this.lat, required this.lng});
}
