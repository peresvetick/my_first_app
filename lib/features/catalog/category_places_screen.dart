import 'package:flutter/material.dart';

class CategoryPlacesScreen extends StatelessWidget {
  final String category, title;
  const CategoryPlacesScreen({super.key, required this.category, required this.title});

  @override
  Widget build(BuildContext context) {
    final placesWithImages = {
      'Парк Горького': 'assets/images/gorkova.jpg',
      'ВДНХ': 'assets/images/vgnh.webp',
      'Сокольники': 'assets/images/photoo.webp',
      'Останкино': 'assets/images/ostankino.jpg',
    };
    final places = category == 'walk'
        ? ['Парк Горького', 'ВДНХ', 'Сокольники', 'Останкино']
        : ['Озеро Тихое', 'Пляж Северный'];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: places.length,
        itemBuilder: (_, i) {
          final placeName = places[i];
          final imagePath = placesWithImages[placeName] ?? 'assets/images/photoo.webp';
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  width: 60, height: 60, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60, height: 60, color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
              title: Text(placeName),
              subtitle: const Text('📍 Описание • Фото'),
              trailing: const Icon(Icons.arrow_forward),
            ),
          );
        },
      ),
    );
  }
} 
