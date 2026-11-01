import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:my_first_app/app/theme/app_theme.dart';
import 'package:my_first_app/utils/persist_path.dart';
import 'package:my_first_app/utils/app_image.dart';
import 'package:my_first_app/app/widgets/app_widgets.dart';
import 'package:my_first_app/data/app_store.dart';
import 'package:my_first_app/data/models/models.dart';
import 'package:my_first_app/features/catalog/catalog_screens.dart';
import 'package:my_first_app/features/catalog/category_places_screen.dart';
import 'package:my_first_app/features/map/map_picker_screen.dart';
import 'package:my_first_app/features/map/user_point_detail_screen.dart';
import 'package:my_first_app/features/map/weather_panel.dart';
import 'package:my_first_app/features/route_planner/route_planner_screen.dart';
import 'package:my_first_app/features/sos/sos_sheet.dart';
import 'package:my_first_app/services/location_service.dart';
import 'package:my_first_app/services/location_suggestion_service.dart';
import 'package:my_first_app/services/weather_service.dart';

/// Карта: официальная (парки/магазины/туры) и народная (пользовательские точки).
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  /// 0 = официальная, 1 = народная
  int _mapMode = 0;
  bool _showParks = true;
  bool _showTours = true;
  bool _showStores = true;

  final _mapController = MapController();
  final _location = LocationService();
  final _weather = WeatherService();
  final _suggestions = LocationSuggestionService();

  double _lat = WeatherPlace.moscow.lat;
  double _lng = WeatherPlace.moscow.lng;
  bool _hasLocation = false;
  String _placeName = 'Москва';
  WeatherSnapshot? _weatherSnap;
  bool _weatherLoading = false;
  /// Показывать автопредложение места один раз за сессию экрана.
  bool _suggestedOnce = false;

  @override
  void initState() {
    super.initState();
    final saved = AppStore().selectedWeatherPlace;
    if (saved != null && !saved.useDeviceLocation) {
      _lat = saved.lat;
      _lng = saved.lng;
      _placeName = saved.name;
      _loadWeather();
    } else {
      _goToMyLocation(silent: true);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _goToMyLocation({bool silent = false}) async {
    if (!silent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📍 Определяем местоположение...')),
      );
    }
    final result = await _location.getCurrentLocation();
    final pos = result.position;
    if (pos == null) {
      // Graceful fallback: Москва, приложение не падает
      final moscow = LocationService.moscow;
      setState(() {
        _lat = moscow.latitude;
        _lng = moscow.longitude;
        _hasLocation = false;
        _placeName = 'Москва';
      });
      try {
        _mapController.move(moscow, 11.5);
      } catch (_) {}
      AppStore().setSelectedWeatherPlace(
        const WeatherPlace(name: 'Москва', lat: 55.751244, lng: 37.618423),
      );
      // На старте (silent) не шумим SnackBar'ом
      if (!silent && mounted) {
        _showLocationFailSnack(result.failReason);
      }
      await _loadWeather();
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _lat = pos.latitude;
      _lng = pos.longitude;
      _hasLocation = true;
      _placeName = result.fromCache ? 'Последняя известная точка' : 'Моё местоположение';
    });
    _mapController.move(pos, 14.5);
    AppStore().setSelectedWeatherPlace(
      WeatherPlace(name: _placeName, lat: pos.latitude, lng: pos.longitude, useDeviceLocation: true),
    );
    if (!silent && result.fromCache && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS медленный — показана последняя известная точка')),
      );
    }
    await _loadWeather();
    _maybeSuggestNearby(pos);
  }

  void _showLocationFailSnack(LocationFailReason? reason) {
    String message;
    SnackBarAction? action;
    switch (reason) {
      case LocationFailReason.serviceDisabled:
        message = 'Включите геолокацию в системе. Показана Москва.';
        action = SnackBarAction(
          label: 'Настройки',
          onPressed: () => _location.openLocationSettings(),
        );
        break;
      case LocationFailReason.permissionDeniedForever:
        message = 'Доступ к геопозиции запрещён. Разрешите в настройках.';
        action = SnackBarAction(
          label: 'Открыть',
          onPressed: () => _location.openAppSettings(),
        );
        break;
      case LocationFailReason.permissionDenied:
        message = 'Нужно разрешение на геопозицию. Показана Москва.';
        break;
      case LocationFailReason.timeout:
        message = 'Таймаут GPS — показана Москва. Попробуйте на улице.';
        break;
      default:
        message = 'Не удалось получить геопозицию — показана Москва.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), action: action, duration: const Duration(seconds: 5)),
    );
  }

  /// Ближайшее место в радиусе 5 км — SnackBar с маршрутом.
  void _maybeSuggestNearby(LatLng pos) {
    if (_suggestedOnce || !mounted) return;
    try {
      final near = _suggestions.findNearest(pos);
      if (near == null) return;
      _suggestedOnce = true;
      final name = '${near.place['name'] ?? 'Место'}';
      final km = near.distanceKm.toStringAsFixed(1);
      final emoji = near.place['placeType'] == 'store'
          ? '🏪'
          : (near.place['placeType'] == 'tour' ? '🥾' : '🌲');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          content: Text('$emoji Рядом с вами: $name ($km км)'),
          action: SnackBarAction(
            label: 'Построить маршрут',
            onPressed: () {
              Navigator.push(
                context,
                natureRoute(RoutePlannerScreen(initialPlace: near.place)),
              );
            },
          ),
        ),
      );
    } catch (_) {
      // Тихий skip при ошибке предложения
    }
  }

  Future<void> _loadWeather() async {
    setState(() => _weatherLoading = true);
    try {
      final snap = await _weather.fetch(_lat, _lng);
      AppStore().cacheWeatherSnapshot({
        'current': snap.current,
        'hourly': snap.hourly
            .map((h) => {
                  'label': h.label,
                  'temperature': h.temperature,
                  'weatherCode': h.weatherCode,
                  'windSpeed': h.windSpeed,
                })
            .toList(),
        'lat': _lat,
        'lng': _lng,
      });
      if (mounted) setState(() => _weatherSnap = snap);
    } catch (_) {
      // Офлайн: берём кэш Hive
      final cached = AppStore().cachedWeather;
      if (cached != null && mounted) {
        final hours = (cached['hourly'] as List? ?? [])
            .map((e) => HourlyWeather(
                  label: '${e['label']}',
                  temperature: (e['temperature'] as num).toInt(),
                  weatherCode: (e['weatherCode'] as num).toInt(),
                  windSpeed: (e['windSpeed'] as num?)?.toInt() ?? 0,
                ))
            .toList();
        setState(() {
          _weatherSnap = WeatherSnapshot(
            current: Map<String, dynamic>.from(cached['current'] as Map? ?? {}),
            hourly: hours,
          );
        });
      } else if (mounted) {
        setState(() {
          _weatherSnap = WeatherSnapshot(
            current: {'temperature': '?', 'weathercode': 99, 'windspeed': '?'},
            hourly: const [],
          );
        });
      }
    } finally {
      if (mounted) setState(() => _weatherLoading = false);
    }
  }

  Future<void> _pickCity() async {
    final controller = TextEditingController();
    List<GeoCity> results = [];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Выбор города', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.my_location, color: AppColors.forestMid),
                    title: const Text('Моё местоположение'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _goToMyLocation();
                    },
                  ),
                  if (AppStore().savedCities.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Сохранённые', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: AppStore().savedCities.map((c) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text('${c['name']}'),
                              onPressed: () async {
                                Navigator.pop(ctx);
                                setState(() {
                                  _lat = (c['lat'] as num).toDouble();
                                  _lng = (c['lng'] as num).toDouble();
                                  _placeName = '${c['name']}';
                                  _hasLocation = false;
                                });
                                _mapController.move(LatLng(_lat, _lng), 12);
                                AppStore().setSelectedWeatherPlace(
                                  WeatherPlace(name: _placeName, lat: _lat, lng: _lng),
                                );
                                await _loadWeather();
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Например: Казань',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (q) async {
                      final list = await _weather.searchCities(q);
                      setModal(() => results = list);
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (_, i) {
                        final c = results[i];
                        return ListTile(
                          title: Text(c.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.bookmark_add_outlined),
                            onPressed: () {
                              AppStore().addSavedCity({'name': c.name, 'lat': c.lat, 'lng': c.lng});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Сохранено: ${c.name}')),
                              );
                              setModal(() {});
                            },
                          ),
                          onTap: () async {
                            Navigator.pop(ctx);
                            setState(() {
                              _lat = c.lat;
                              _lng = c.lng;
                              _placeName = c.name;
                              _hasLocation = false;
                            });
                            _mapController.move(LatLng(c.lat, c.lng), 12);
                            AppStore().setSelectedWeatherPlace(
                              WeatherPlace(name: c.name, lat: c.lat, lng: c.lng),
                            );
                            AppStore().addSavedCity({'name': c.name, 'lat': c.lat, 'lng': c.lng});
                            await _loadWeather();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  double? _d(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  LatLng _coordsOf(Map<String, dynamic> item, {required double fallbackLat, required double fallbackLng}) {
    return LatLng(_d(item['lat']) ?? fallbackLat, _d(item['lng']) ?? fallbackLng);
  }

  Color _folkColor(String cat) {
    switch (cat) {
      case 'Грибы':
        return const Color(0xFF8B5A2B);
      case 'Ягоды':
        return const Color(0xFFC2185B);
      case 'Рыбалка':
        return const Color(0xFF1565C0);
      case 'Опасно':
        return const Color(0xFFC62828);
      default:
        return AppColors.amber;
    }
  }

  String _folkEmoji(String cat) {
    switch (cat) {
      case 'Грибы':
        return '🍄';
      case 'Ягоды':
        return '🫐';
      case 'Рыбалка':
        return '🎣';
      case 'Опасно':
        return '⚠️';
      case 'Красивое место':
        return '🌄';
      default:
        return '📍';
    }
  }

  Future<void> _addFolkPoint() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'Грибы';
    String? imagePath;
    LatLng? picked;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Новая точка на Народной карте', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Название')),
                    const SizedBox(height: 10),
                    TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Описание'), maxLines: 2),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      items: const [
                        'Грибы',
                        'Ягоды',
                        'Рыбалка',
                        'Красивое место',
                        'Опасно',
                      ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setModal(() => category = v ?? category),
                      decoration: const InputDecoration(labelText: 'Категория'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final res = await Navigator.push<LatLng>(
                          ctx,
                          natureRoute(const MapPickerScreen()),
                        );
                        if (res != null) setModal(() => picked = res);
                      },
                      icon: const Icon(Icons.map_outlined),
                      label: Text(picked == null ? 'Указать на карте' : 'Точка выбрана ✓'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                        if (file != null) setModal(() => imagePath = file.path);
                      },
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(imagePath == null ? 'Фото из галереи' : 'Фото выбрано ✓'),
                    ),
                    if (imagePath != null) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: appImage(imagePath, height: 120, fit: BoxFit.cover),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleCtrl.text.trim().isEmpty || picked == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Нужны название и точка на карте')),
                          );
                          return;
                        }
                        String? savedPath;
                        if (imagePath != null) {
                          final name = 'point_${DateTime.now().millisecondsSinceEpoch}.jpg';
                          savedPath = await persistMediaPath(imagePath!, name) ?? imagePath;
                        }
                        AppStore().addUserPoint({
                          'id': DateTime.now().millisecondsSinceEpoch,
                          'title': titleCtrl.text.trim(),
                          'name': titleCtrl.text.trim(),
                          'description': descCtrl.text.trim(),
                          'category': category,
                          'lat': picked!.latitude,
                          'lng': picked!.longitude,
                          if (savedPath != null) 'image': savedPath,
                          'icon': _folkEmoji(category),
                        });
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ Точка добавлена на Народную карту')),
                          );
                          setState(() => _mapMode = 1);
                          _mapController.move(picked!, 14);
                        }
                      },
                      child: const Text('Сохранить точку'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Marker> _officialMarkers() {
    final markers = <Marker>[];
    if (_showParks) {
      final parks = AppStore().parks;
      for (var i = 0; i < parks.length; i++) {
        final p = parks[i];
        final pos = _coordsOf(p, fallbackLat: 55.75 + i * 0.012, fallbackLng: 37.61 + i * 0.01);
        markers.add(Marker(
          point: pos,
          width: 48,
          height: 48,
          child: GestureDetector(
            onTap: () => Navigator.push(context, natureRoute(ParkDetailScreen(park: p))),
            child: const MapPin(emoji: '🌳', color: AppColors.forestMid),
          ),
        ));
      }
    }
    if (_showTours) {
      final tours = AppStore().tours;
      for (var i = 0; i < tours.length; i++) {
        final t = tours[i];
        final pos = _coordsOf(t, fallbackLat: 55.76 + i * 0.012, fallbackLng: 37.63 + i * 0.01);
        markers.add(Marker(
          point: pos,
          width: 48,
          height: 48,
          child: GestureDetector(
            onTap: () => Navigator.push(context, natureRoute(TourDetailScreen(tour: t))),
            child: const MapPin(emoji: '🏕️', color: Color(0xFFE65100)),
          ),
        ));
      }
    }
    if (_showStores) {
      final stores = AppStore().stores;
      for (var i = 0; i < stores.length; i++) {
        final s = stores[i];
        final pos = _coordsOf(s, fallbackLat: 55.74 + i * 0.012, fallbackLng: 37.60 + i * 0.01);
        markers.add(Marker(
          point: pos,
          width: 48,
          height: 48,
          child: GestureDetector(
            onTap: () => Navigator.push(context, natureRoute(StoreDetailScreen(store: s))),
            child: const MapPin(emoji: '🏪', color: Color(0xFF00695C)),
          ),
        ));
      }
    }
    return markers;
  }

  List<Marker> _folkMarkers(List<Map<String, dynamic>> points) {
    return points.map((p) {
      final cat = '${p['category'] ?? ''}';
      final pos = _coordsOf(p, fallbackLat: _lat, fallbackLng: _lng);
      return Marker(
        point: pos,
        width: 48,
        height: 48,
        child: GestureDetector(
          onTap: () => Navigator.push(context, natureRoute(UserPointDetailScreen(point: p))),
          onLongPress: AppStore().userName == 'albert'
              ? () {
                  AppStore().deleteUserPoint(p['id'] as int);
                  setState(() {});
                }
              : null,
          child: MapPin(emoji: _folkEmoji(cat), color: _folkColor(cat)),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isOfficial = _mapMode == 0;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Row(
                children: [
                  const Text(
                    'NatureHub',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.forest),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Слои',
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Слои официальной карты'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SwitchListTile(title: const Text('Парки'), value: _showParks, onChanged: (v) => setState(() => _showParks = v)),
                            SwitchListTile(title: const Text('Туры'), value: _showTours, onChanged: (v) => setState(() => _showTours = v)),
                            SwitchListTile(title: const Text('Магазины'), value: _showStores, onChanged: (v) => setState(() => _showStores = v)),
                          ],
                        ),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                      ),
                    ),
                    icon: const Icon(Icons.layers_outlined),
                  ),
                  IconButton(
                    tooltip: 'SOS',
                    onPressed: () => showSosSheet(context, lat: _lat, lng: _lng),
                    icon: Icon(Icons.sos, color: Colors.red.shade700),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: WeatherPanel(
                snapshot: _weatherSnap,
                placeName: _placeName,
                loading: _weatherLoading,
                onChooseCity: _pickCity,
              ),
            ),
            // Режимы карты — ОТДЕЛЬНЫЙ Row НАД картой (не внутри Stack)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              child: Row(
                children: [
                  Expanded(
                    child: _ModeChip(
                      label: 'Официальная',
                      selected: isOfficial,
                      onTap: () => setState(() => _mapMode = 0),
                      color: AppColors.forestMid,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ModeChip(
                      label: 'Народная',
                      selected: !isOfficial,
                      onTap: () => setState(() => _mapMode = 1),
                      color: const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
            if (isOfficial)
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _QuickChip(label: 'Магазины', onTap: () => Navigator.push(context, natureRoute(const StoresScreen()))),
                    _QuickChip(label: 'Парки', onTap: () => Navigator.push(context, natureRoute(const ParksScreen()))),
                    _QuickChip(label: 'Туры', onTap: () => Navigator.push(context, natureRoute(const ToursScreen()))),
                    _QuickChip(
                      label: 'Прогулки',
                      onTap: () => Navigator.push(
                        context,
                        natureRoute(const CategoryPlacesScreen(category: 'walk', title: 'Прогулки')),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  child: Stack(
                    children: [
                      ValueListenableBuilder<List<Map<String, dynamic>>>(
                        valueListenable: isOfficial ? AppStore().parksNotifier : AppStore().userMapPointsNotifier,
                        builder: (_, __, ___) {
                          // Слушаем и stores/tours через rebuild setState на переключателях
                          final markers = isOfficial
                              ? _officialMarkers()
                              : _folkMarkers(AppStore().userMapPoints);
                          return FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: LatLng(_lat, _lng),
                              initialZoom: 12,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.naturehub.app',
                              ),
                              MarkerClusterLayerWidget(
                                options: MarkerClusterLayerOptions(
                                  maxClusterRadius: 45,
                                  size: const Size(44, 44),
                                  markers: [
                                    if (_hasLocation)
                                      Marker(
                                        point: LatLng(_lat, _lng),
                                        width: 44,
                                        height: 44,
                                        child: const MapPin(emoji: '📍', color: Color(0xFF1565C0)),
                                      ),
                                    ...markers,
                                  ],
                                  builder: (context, clusterMarkers) => Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isOfficial ? AppColors.forestMid : const Color(0xFFD97706),
                                      shape: BoxShape.circle,
                                      boxShadow: AppShadows.soft(context),
                                    ),
                                    child: Text(
                                      '${clusterMarkers.length}',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      // Подписка на stores/tours тоже
                      ValueListenableBuilder(
                        valueListenable: AppStore().storesNotifier,
                        builder: (_, __, ___) => ValueListenableBuilder(
                          valueListenable: AppStore().toursNotifier,
                          builder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FloatingActionButton.small(
                              heroTag: 'loc',
                              onPressed: () => _goToMyLocation(),
                              child: const Icon(Icons.my_location),
                            ),
                            const SizedBox(height: 8),
                            if (!isOfficial)
                              FloatingActionButton.small(
                                heroTag: 'add',
                                backgroundColor: const Color(0xFFD97706),
                                onPressed: _addFolkPoint,
                                child: const Icon(Icons.add_location_alt),
                              ),
                            if (!isOfficial) const SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: 'route',
                              backgroundColor: const Color(0xFF6A1B9A),
                              onPressed: () => Navigator.push(context, natureRoute(const RoutePlannerScreen())),
                              child: const Icon(Icons.route),
                            ),
                            const SizedBox(height: 8),
                            // SOS под остальными FAB
                            FloatingActionButton.small(
                              heroTag: 'sos_map',
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                              onPressed: () => showSosSheet(context, lat: _lat, lng: _lng),
                              child: const Icon(Icons.sos),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  const _ModeChip({required this.label, required this.selected, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color : Theme.of(context).cardColor,
      elevation: selected ? 2 : 0,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
        backgroundColor: AppColors.forest.withValues(alpha: 0.08),
      ),
    );
  }
}
