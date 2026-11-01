import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Гео-утилиты: Haversine и сумма длины маршрута.
class GeoUtils {
  GeoUtils._();

  static const _earthRadiusKm = 6371.0;

  /// Расстояние между двумя точками в км (формула Хаверсина).
  static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) * math.cos(_toRad(lat2)) * math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  static double distanceBetween(LatLng a, LatLng b) =>
      distanceKm(a.latitude, a.longitude, b.latitude, b.longitude);

  /// Сумма сегментов между соседними точками (порядок важен).
  static double routeLengthKm(List<LatLng> points) {
    if (points.length < 2) return 0;
    var total = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      total += distanceBetween(points[i], points[i + 1]);
    }
    return total;
  }

  static double _toRad(double deg) => deg * math.pi / 180.0;
}
