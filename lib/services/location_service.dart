import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Причина, почему геопозицию получить не удалось.
enum LocationFailReason {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  unknown,
}

/// Результат запроса геопозиции.
class LocationResult {
  final LatLng? position;
  final LocationFailReason? failReason;
  final bool fromCache;

  const LocationResult.ok(this.position, {this.fromCache = false}) : failReason = null;
  const LocationResult.fail(this.failReason)
      : position = null,
        fromCache = false;

  bool get isOk => position != null;
}

/// Сервис геолокации пользователя.
class LocationService {
  /// Координаты Москвы — fallback, если гео недоступно.
  static const moscow = LatLng(55.751244, 37.618423);

  /// Запрашивает разрешение и возвращает текущие координаты с причиной ошибки.
  Future<LocationResult> getCurrentLocation({bool highAccuracy = true}) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult.fail(LocationFailReason.serviceDisabled);
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.fail(LocationFailReason.permissionDeniedForever);
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        return const LocationResult.fail(LocationFailReason.permissionDenied);
      }

      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: highAccuracy ? LocationAccuracy.high : LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 12),
          ),
        );
        return LocationResult.ok(LatLng(position.latitude, position.longitude));
      } catch (_) {
        // Таймаут / GPS недоступен — пробуем последнюю известную точку
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          return LocationResult.ok(
            LatLng(last.latitude, last.longitude),
            fromCache: true,
          );
        }
        return const LocationResult.fail(LocationFailReason.timeout);
      }
    } catch (_) {
      return const LocationResult.fail(LocationFailReason.unknown);
    }
  }

  /// Совместимый API: координаты или null.
  Future<LatLng?> getCurrentLatLng({bool highAccuracy = true}) async {
    final r = await getCurrentLocation(highAccuracy: highAccuracy);
    return r.position;
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
