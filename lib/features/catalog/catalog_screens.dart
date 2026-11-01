import 'package:flutter/material.dart';
import 'package:my_first_app/app/widgets/app_widgets.dart';
import 'package:my_first_app/utils/app_image.dart';
import 'package:my_first_app/data/app_store.dart';

class ParksScreen extends StatelessWidget {
  const ParksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🌲 Парки и прогулки')),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: AppStore().parksNotifier,
        builder: (_, parks, __) {
          if (parks.isEmpty) {
            return const EmptyState(title: 'Парков пока нет');
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: parks.length,
            itemBuilder: (_, i) {
              final park = parks[i];
              return CatalogTile(
                title: park['name'] ?? 'Без названия',
                category: park['type'] ?? 'Парк',
                image: park['image'] ?? '🌲',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ParkDetailScreen(park: park)),
                ),
              );
            },
          );
          },
        ),
      );
    }
  }

// 🌲 ЭКРАН ДЕТАЛЕЙ ПАРКА С ОТЗЫВАМИ
class ParkDetailScreen extends StatefulWidget {
  final Map<String, dynamic> park;
  const ParkDetailScreen({super.key, required this.park});

  @override
  State<ParkDetailScreen> createState() => _ParkDetailScreenState();
}

class _ParkDetailScreenState extends State<ParkDetailScreen> {
  final _reviewCtrl = TextEditingController();
  int _selectedRating = 5;

  @override
  Widget build(BuildContext context) {
    try {
    final park = widget.park;
    final imageValue = park['image'];
    final isFile = imageValue is String && looksLikeImagePath(imageValue);
    final reviews = AppStore().parkReviews[park['id']] ?? [];
    final parkName = '${park['name'] ?? 'Парк'}';

    return Scaffold(
      appBar: AppBar(title: Text(parkName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: isFile
                  ? ClipRRect(borderRadius: BorderRadius.circular(12), child: appImage(imageValue, fit: BoxFit.cover, width: double.infinity))
                  : Text(imageValue is String && imageValue.isNotEmpty ? imageValue : '🌲', style: const TextStyle(fontSize: 60)),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(parkName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('${park['type'] ?? park['category'] ?? ''}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('${park['address'] ?? ''}', style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 12),
                  Text('${park['description'] ?? ''}', style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('Отзывы', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            if (reviews.isEmpty)
              const Text('Отзывов пока нет. Будьте первым!', style: TextStyle(color: Colors.grey))
            else
              ...reviews.map((review) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(review['user'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Text(review['date'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(5, (i) => Icon(Icons.star, color: i < review['rating'] ? Colors.amber : Colors.grey[300], size: 16)),
                          ),
                          const SizedBox(height: 4),
                          Text(review['text']),
                        ],
                      ),
                    ),
                  )),
            
            const SizedBox(height: 24),
            const Text('Оставить отзыв', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return IconButton(
                  icon: Icon(Icons.star, color: i < _selectedRating ? Colors.amber : Colors.grey[300], size: 32),
                  onPressed: () => setState(() => _selectedRating = i + 1),
                );
              }),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _reviewCtrl,
              decoration: const InputDecoration(labelText: 'Ваш отзыв', border: OutlineInputBorder(), hintText: 'Поделитесь впечатлениями...'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_reviewCtrl.text.trim().isNotEmpty) {
                    AppStore().addParkReview(park['id'], AppStore().userName, _reviewCtrl.text.trim(), _selectedRating);
                    _reviewCtrl.clear();
                    setState(() {});
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
    );
    } catch (_) {
      return const Scaffold(body: Center(child: Text('Данные временно недоступны')));
    }
  }
}

class ToursScreen extends StatelessWidget {
  const ToursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏕️ Туры и походы')),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: AppStore().toursNotifier,
        builder: (_, tours, __) {
          if (tours.isEmpty) {
            return const EmptyState(title: 'Туров пока нет', icon: Icons.explore_outlined);
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: tours.length,
            itemBuilder: (_, i) {
              final tour = tours[i];
              final subtitle =
                  '${tour['duration'] ?? '1 день'} • ${tour['price'] ?? 'Бесплатно'}';
              return CatalogTile(
                title: tour['name'] ?? 'Без названия',
                category: subtitle,
                image: tour['image'] ?? '🏕️',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TourDetailScreen(tour: tour)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
class TourDetailScreen extends StatefulWidget {
  final Map<String, dynamic> tour;
  const TourDetailScreen({super.key, required this.tour});

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  final _reviewCtrl = TextEditingController();
  int _selectedRating = 5;

  @override
  Widget build(BuildContext context) {
    try {
    final tour = widget.tour;
    final imageValue = tour['image'];
    final isFile = imageValue is String && looksLikeImagePath(imageValue);
    final reviews = AppStore().tourReviews[tour['id']] ?? [];
    final tourName = '${tour['name'] ?? 'Тур'}';

    return Scaffold(
      appBar: AppBar(title: Text(tourName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: isFile
                  ? ClipRRect(borderRadius: BorderRadius.circular(12), child: appImage(imageValue, fit: BoxFit.cover, width: double.infinity))
                  : Text(imageValue is String && imageValue.isNotEmpty ? imageValue : '🌲', style: const TextStyle(fontSize: 60)),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tourName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('${tour['category'] ?? ''}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('Длительность: ${tour['duration']}', style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('Цена: ${tour['price']}', style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(tour['description'] ?? '', style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('Отзывы', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            if (reviews.isEmpty)
              const Text('Отзывов пока нет. Будьте первым!', style: TextStyle(color: Colors.grey))
            else
              ...reviews.map((review) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(review['user'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Text(review['date'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(5, (i) => Icon(Icons.star, color: i < review['rating'] ? Colors.amber : Colors.grey[300], size: 16)),
                          ),
                          const SizedBox(height: 4),
                          Text(review['text']),
                        ],
                      ),
                    ),
                  )),
            
            const SizedBox(height: 24),
            const Text('Оставить отзыв', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return IconButton(
                  icon: Icon(Icons.star, color: i < _selectedRating ? Colors.amber : Colors.grey[300], size: 32),
                  onPressed: () => setState(() => _selectedRating = i + 1),
                );
              }),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _reviewCtrl,
              decoration: const InputDecoration(labelText: 'Ваш отзыв', border: OutlineInputBorder(), hintText: 'Поделитесь впечатлениями...'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_reviewCtrl.text.trim().isNotEmpty) {
                    AppStore().addTourReview(tour['id'], AppStore().userName, _reviewCtrl.text.trim(), _selectedRating);
                    _reviewCtrl.clear();
                    setState(() {});
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
    );
    } catch (_) {
      return const Scaffold(body: Center(child: Text('Данные временно недоступны')));
    }
  }
}
class StoresScreen extends StatelessWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏪 Магазины')),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: AppStore().storesNotifier,
        builder: (_, stores, __) {
          if (stores.isEmpty) {
            return const EmptyState(title: 'Магазинов пока нет', icon: Icons.store_outlined);
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: stores.length,
            itemBuilder: (_, i) {
              final store = stores[i];
              return CatalogTile(
                title: store['name'] ?? 'Без названия',
                category:
                    '${store['category'] ?? 'Категория'} • ★ ${store['rating'] ?? '5.0'}',
                image: store['image'] ?? '🏪',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StoreDetailScreen(store: store)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// 🏪 ДЕТАЛИ МАГАЗИНА (восстановленный класс)
class StoreDetailScreen extends StatefulWidget {
  final Map<String, dynamic> store;
  const StoreDetailScreen({super.key, required this.store});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    try {
      final store = widget.store;
      final name = '${store['name'] ?? 'Магазин'}';
      return Scaffold(
        appBar: AppBar(
          title: Text(name),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Инфо'), Tab(text: 'Отзывы'), Tab(text: 'Написать')],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildInfoTab(store),
            _buildReviewsTab(store),
            _buildMessageTab(store),
          ],
        ),
      );
    } catch (_) {
      return const Scaffold(body: Center(child: Text('Данные временно недоступны')));
    }
  }

  Widget _buildInfoTab(Map<String, dynamic> store) {
    final imageValue = store['image'];
    final isFile = imageValue is String && looksLikeImagePath(imageValue);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: isFile
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: appImage(imageValue, fit: BoxFit.cover, width: double.infinity),
                  )
                : Text(imageValue ?? '🏪', style: const TextStyle(fontSize: 60)),
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.store, store['category'] ?? 'Категория не указана'),
          _infoRow(Icons.location_on, store['address'] ?? 'Адрес не указан'),
          _infoRow(Icons.access_time, store['hours'] ?? 'Круглосуточно'),
          _infoRow(Icons.phone, store['phone'] ?? 'Не указан'),
          _infoRow(Icons.star, '${store['rating'] ?? 5.0} (${store['reviews'] ?? 0} отзывов)'),
          const SizedBox(height: 20),
          const Text('В наличии:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (store['inStock'] is List && (store['inStock'] as List).isNotEmpty)
                ? (store['inStock'] as List).map((item) => Chip(label: Text(item), backgroundColor: Colors.green[50])).toList()
                : [const Chip(label: Text('Информация уточняется'), backgroundColor: Colors.grey)],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(Map<String, dynamic> store) {
    final reviews = AppStore().storeReviews[store['id']] ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (_, i) {
        final review = reviews[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(review['user'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(review['date'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(Icons.star, color: i < review['rating'] ? Colors.amber : Colors.grey[300], size: 16),
                  ),
                ),
                const SizedBox(height: 8),
                Text(review['text']),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageTab(Map<String, dynamic> store) {
    final messages = AppStore().storeMessages[store['id']] ?? [];
    final TextEditingController _ctrl = TextEditingController();
    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? const Center(child: Text('Нет сообщений. Напишите магазину!', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    return Align(
                      alignment: msg['from'] == 'Вы' ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: msg['from'] == 'Вы' ? Colors.green[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(msg['message']),
                            const SizedBox(height: 4),
                            Text(msg['time'], style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: InputDecoration(
                    hintText: 'Ваше сообщение',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.green),
                onPressed: () {
                  if (_ctrl.text.trim().isNotEmpty) {
                    setState(() {
                      AppStore().sendMessageToStore(store['id'], _ctrl.text.trim());
                      _ctrl.clear();
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.green[700], size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
          ],
        ),
      );
}
