import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  const MapPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? _selectedPoint;
  late LatLng _center;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _selectedPoint = LatLng(widget.initialLat!, widget.initialLng!);
      _center = _selectedPoint!;
    } else {
      _center = const LatLng(55.751244, 37.618423); // Центр Москвы
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📍 Тыкни в карту'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () {
              if (_selectedPoint != null) {
                Navigator.pop(context, _selectedPoint); // Возвращаем координаты назад
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сначала ткни в карту!')));
              }
            },
          )
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 13.0,
          onTap: (tapPosition, point) {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedPoint = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://a.tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.naturehub',
          ),
          if (_selectedPoint != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _selectedPoint!,
                  width: 50, height: 50,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 45),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
