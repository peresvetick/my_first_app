import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:my_first_app/app/theme/app_theme.dart';
import 'package:my_first_app/app/widgets/app_widgets.dart';
import 'package:my_first_app/data/app_store.dart';
import 'package:my_first_app/services/ai_guide_service.dart';
import 'package:my_first_app/services/osrm_service.dart';
import 'package:my_first_app/utils/geo_utils.dart';

class RoutePlannerScreen extends StatefulWidget {
  /// Место для предвыбора (автопредложение с карты).
  final Map<String, dynamic>? initialPlace;

  const RoutePlannerScreen({super.key, this.initialPlace});

  @override
  State<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  final _mapController = MapController();
  final _ai = AiGuideService();
  final _osrm = OsrmService();
  final _selected = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _ordered = [];
  List<LatLng> _routeLine = [];
  bool _demoRoute = false;
  bool _routing = false;
  String _narrative = '';
  List<Map<String, dynamic>> _allPlaces = [];
  double _approxKm = 0;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  void _loadPlaces() {
    final places = <Map<String, dynamic>>[];
    for (final park in AppStore().parks) {
      places.add({...park, 'placeType': 'park', 'name': park['name'] ?? 'Парк'});
    }
    for (final tour in AppStore().tours) {
      places.add({...tour, 'placeType': 'tour', 'name': tour['name'] ?? 'Тур'});
    }
    for (final store in AppStore().stores) {
      places.add({...store, 'placeType': 'store', 'name': store['name'] ?? 'Магазин'});
    }
    for (final point in AppStore().userMapPoints) {
      places.add({...point, 'placeType': 'user', 'name': point['title'] ?? point['name'] ?? 'Точка'});
    }
    setState(() => _allPlaces = places);

    // Предвыбор места из автопредложения
    final initial = widget.initialPlace;
    if (initial != null) {
      Map<String, dynamic>? match;
      for (final p in places) {
        if (p['id'] == initial['id']) {
          match = p;
          break;
        }
      }
      final place = match ?? {...initial, 'name': initial['name'] ?? initial['title'] ?? 'Место'};
      if (_hasCoords(place) && !_selected.any((e) => e['id'] == place['id'])) {
        _selected.add(place);
        WidgetsBinding.instance.addPostFrameCallback((_) => _rebuildRoute());
      }
    }
  }

  double? _d(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  bool _hasCoords(Map<String, dynamic> p) => _d(p['lat']) != null && _d(p['lng']) != null;

  String _addressOf(Map<String, dynamic> p) {
    final a = p['address'] ?? p['location'] ?? p['description'] ?? p['placeType'] ?? '';
    return '$a';
  }

  Widget _placeVisual(Map<String, dynamic> p) {
    final image = p['image'];
    if (image is String && image.isNotEmpty) {
      if (image.startsWith('http')) {
        return Image.network(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _emojiFallback(p));
      }
      // Эмодзи или локальный путь — показываем крупно
      if (image.length <= 4) {
        return Center(child: Text(image, style: const TextStyle(fontSize: 64)));
      }
    }
    return _emojiFallback(p);
  }

  Widget _emojiFallback(Map<String, dynamic> p) {
    final type = '${p['placeType'] ?? ''}';
    final emoji = type == 'store'
        ? '🏪'
        : (type == 'tour' ? '🥾' : (type == 'park' ? '🌲' : '📍'));
    return Center(child: Text(emoji, style: const TextStyle(fontSize: 64)));
  }

  void _toggle(Map<String, dynamic> place) {
    final id = place['id'];
    setState(() {
      final i = _selected.indexWhere((e) => e['id'] == id);
      if (i >= 0) {
        _selected.removeAt(i);
      } else {
        _selected.add(place);
      }
    });
    _rebuildRoute();
  }

  Future<void> _rebuildRoute() async {
    final withCoords = _selected.where(_hasCoords).toList();
    final ordered = _ai.orderPlaces(withCoords);
    final narrative = _ai.routeNarrative(ordered);
    final pts = ordered
        .where(_hasCoords)
        .map((e) => LatLng(_d(e['lat'])!, _d(e['lng'])!))
        .toList();
    final approx = GeoUtils.routeLengthKm(pts);
    setState(() {
      _ordered = ordered;
      _narrative = narrative;
      _approxKm = approx;
      _routing = ordered.length >= 2;
    });

    if (ordered.length < 2) {
      setState(() {
        _routeLine = [];
        _demoRoute = false;
        _routing = false;
      });
      return;
    }

    final waypoints = ordered.map((e) => LatLng(_d(e['lat'])!, _d(e['lng'])!)).toList();
    final osrm = await _osrm.route(waypoints);
    if (!mounted) return;
    if (osrm != null && osrm.length >= 2) {
      setState(() {
        _routeLine = osrm;
        _demoRoute = false;
        _routing = false;
      });
    } else {
      setState(() {
        _routeLine = waypoints;
        _demoRoute = true;
        _routing = false;
      });
    }
    _mapController.move(waypoints.first, 11);
  }

  @override
  Widget build(BuildContext context) {
    final previewPlaces = _ordered.isNotEmpty ? _ordered : _selected.where(_hasCoords).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Планировщик маршрута'),
        actions: [
          IconButton(
            tooltip: 'Перестроить',
            onPressed: _selected.isEmpty ? null : _rebuildRoute,
            icon: const Icon(Icons.route),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_narrative.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: AppCard(
                gradient: const LinearGradient(colors: AppColors.officialGradient),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_narrative, style: const TextStyle(color: Colors.white, height: 1.35)),
                    if (_approxKm > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        '≈ ${_approxKm.toStringAsFixed(1)} км',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ],
                    if (_demoRoute) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                        child: const Text('Демо-маршрут (OSRM недоступен)', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                    if (_routing) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(color: Colors.white),
                    ],
                  ],
                ),
              ),
            ),
          if (previewPlaces.isNotEmpty)
            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.86),
                itemCount: previewPlaces.length,
                itemBuilder: (_, i) {
                  final p = previewPlaces[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(6, 10, 6, 4),
                    child: Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 120,
                            height: double.infinity,
                            child: ColoredBox(
                              color: AppColors.mist,
                              child: _placeVisual(p),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${p['name']}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _addressOf(p),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_approxKm > 0 && _narrative.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('≈ ${_approxKm.toStringAsFixed(1)} км', style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _routeLine.isNotEmpty ? _routeLine.first : const LatLng(55.751244, 37.618423),
                    initialZoom: 11,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.naturehub.app',
                    ),
                    if (_routeLine.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routeLine,
                            color: _demoRoute ? Colors.orange : AppColors.forestMid,
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        for (var i = 0; i < _ordered.length; i++)
                          Marker(
                            point: LatLng(_d(_ordered[i]['lat'])!, _d(_ordered[i]['lng'])!),
                            width: 36,
                            height: 36,
                            child: CircleAvatar(
                              backgroundColor: AppColors.forestMid,
                              child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Выберите места (${_selected.length})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
          Expanded(
            child: _allPlaces.isEmpty
                ? const EmptyState(title: 'Пока нет мест')
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _allPlaces.length,
                    itemBuilder: (_, i) {
                      final p = _allPlaces[i];
                      final selected = _selected.any((e) => e['id'] == p['id']);
                      final ok = _hasCoords(p);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: CheckboxListTile(
                          value: selected,
                          onChanged: ok ? (_) => _toggle(p) : null,
                          title: Text('${p['name']}'),
                          subtitle: Text(ok ? '${p['placeType']}' : 'Нет координат'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
