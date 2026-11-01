import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_first_app/data/app_store.dart';
import 'package:my_first_app/utils/app_image.dart';
import 'package:my_first_app/services/ai_guide_service.dart';

class UserPointDetailScreen extends StatefulWidget {
  final Map<String, dynamic> point;
  const UserPointDetailScreen({super.key, required this.point});
  @override
  State<UserPointDetailScreen> createState() => _UserPointDetailScreenState();
}

class _UserPointDetailScreenState extends State<UserPointDetailScreen> {
  bool _isLiked = false;
  int _likes = 0;
  final TextEditingController _reviewCtrl = TextEditingController();
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _reviews = List<Map<String, dynamic>>.from(widget.point['reviews'] ?? []);
    _likes = widget.point['likes'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final point = widget.point;
    final imageValue = point['image'];
    final isFile = imageValue is String && (imageValue.startsWith('/') || imageValue.startsWith('file://'));

    return Scaffold(
      appBar: AppBar(title: Text(point['name'])),
      body: Row(
        children: [
          // СЛЕВА: КАРТА С ТОЧКОЙ
          Expanded(
            flex: 1,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(point['lat'] as double, point['lng'] as double),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(urlTemplate: 'https://a.tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.naturehub'),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(point['lat'] as double, point['lng'] as double),
                      width: 50, height: 50,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 45),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // СПРАВА: ФОТО, ЛАЙКИ, ОТЗЫВЫ
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isFile)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: appImage(imageValue, width: double.infinity, height: 200, fit: BoxFit.cover),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: Text(imageValue ?? '📍', style: const TextStyle(fontSize: 60)),
                    ),
                  const SizedBox(height: 16),
                  Text(point['name'] ?? point['title'] ?? 'Точка', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${point['category'] ?? ''}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.tips_and_updates_outlined, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AiGuideService().tipForCategory(point['category'].toString()),
                            style: TextStyle(fontSize: 13, color: Colors.green[900]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Автор: ${point['author']}', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: _isLiked ? Colors.red : Colors.grey),
                        onPressed: () {
                          setState(() {
                            _isLiked = !_isLiked;
                            _likes += _isLiked ? 1 : -1;
                          });
                        },
                      ),
                      Text('$_likes', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Отзывы:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_reviews.isEmpty)
                    const Text('Отзывов пока нет', style: TextStyle(color: Colors.grey))
                  else
                    ..._reviews.map((review) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(review['user'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(review['text']),
                                const SizedBox(height: 4),
                                Text(review['date'], style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                              ],
                            ),
                          ),
                        )),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _reviewCtrl,
                    decoration: const InputDecoration(labelText: 'Ваш отзыв', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_reviewCtrl.text.trim().isNotEmpty) {
                          setState(() {
                            _reviews.add({
                              'user': AppStore().userName,
                              'text': _reviewCtrl.text.trim(),
                              'date': 'Только что',
                            });
                            _reviewCtrl.clear();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Отзыв добавлен!')));
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Отправить отзыв'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
