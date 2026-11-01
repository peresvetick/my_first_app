import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Бесплатный роутинг через OSRM public demo.
class OsrmService {
  /// Возвращает точки полилинии. При ошибке — null (вызывающий рисует прямую).
  Future<List<LatLng>?> route(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return null;
    try {
      final coords = waypoints.map((p) => '${p.longitude},${p.latitude}').join(';');
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/foot/$coords?overview=full&geometries=geojson',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['code'] != 'Ok') return null;
      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) return null;
      final geometry = routes.first['geometry'] as Map<String, dynamic>;
      final coordsList = geometry['coordinates'] as List;
      return coordsList
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
    } catch (_) {
      return null;
    }
  }
}
