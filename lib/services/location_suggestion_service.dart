import 'package:latlong2/latlong.dart';

import 'package:my_first_app/data/app_store.dart';
import 'package:my_first_app/utils/geo_utils.dart';

/// Ближайшее место в радиусе вокруг пользователя.
class NearbySuggestion {
  final Map<String, dynamic> place;
  final double distanceKm;

  const NearbySuggestion({required this.place, required this.distanceKm});
}

/// Сервис автопредложения парков / магазинов / туров рядом.
class LocationSuggestionService {
  /// Радиус поиска, км.
  static const defaultRadiusKm = 5.0;

  /// Находит ближайшее место в радиусе [radiusKm].
  NearbySuggestion? findNearest(LatLng user, {double radiusKm = defaultRadiusKm}) {
    try {
      final candidates = <Map<String, dynamic>>[
        ...AppStore().parks.map((p) => {...p, 'placeType': 'park', 'name': p['name'] ?? 'Парк'}),
        ...AppStore().stores.map((p) => {...p, 'placeType': 'store', 'name': p['name'] ?? 'Магазин'}),
        ...AppStore().tours.map((p) => {...p, 'placeType': 'tour', 'name': p['name'] ?? 'Тур'}),
      ];

      NearbySuggestion? best;
      for (final place in candidates) {
        final lat = _asDouble(place['lat']);
        final lng = _asDouble(place['lng']);
        if (lat == null || lng == null) continue;
        final d = GeoUtils.distanceKm(user.latitude, user.longitude, lat, lng);
        if (d > radiusKm) continue;
        if (best == null || d < best.distanceKm) {
          best = NearbySuggestion(place: place, distanceKm: d);
        }
      }
      return best;
    } catch (_) {
      return null;
    }
  }

  double? _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}
