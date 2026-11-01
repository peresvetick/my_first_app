import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_first_app/data/app_store.dart';
import 'package:my_first_app/utils/app_image.dart';
import 'package:my_first_app/utils/persist_path.dart';
import 'package:my_first_app/features/map/map_picker_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('️ Панель управления'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Добавить контент',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Кнопка: Добавить магазин
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.store, color: Colors.blue),
                ),
                title: const Text('Добавить магазин', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Новый магазин снаряжения'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
               onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AddStoreScreen()),
  );
},
              ),
            ),
            const SizedBox(height: 8),

            // Кнопка: Добавить локацию
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on, color: Colors.green),
                ),
                title: const Text('Добавить локацию', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Парк, место для похода'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AddParkScreen()),
  );
},

              ),
            ),
            const SizedBox(height: 8),

            // Кнопка: Добавить тур
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.explore, color: Colors.orange),
                ),
                title: const Text('Добавить тур', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Организованный поход или экскурсия'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AddTourScreen()),
  );
},
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Управление и очистка',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.storefront, color: Colors.blue),
                title: const Text('Магазины'),
                subtitle: const Text('Список, правка, удаление'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminManageStoresScreen()),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.park, color: Colors.green),
                title: const Text('Парки / локации'),
                subtitle: const Text('Список, правка, удаление'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminManageParksScreen()),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.explore, color: Colors.orange),
                title: const Text('Туры'),
                subtitle: const Text('Список, правка, удаление'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminManageToursScreen()),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.dynamic_feed, color: Colors.purple),
                title: const Text('Посты ленты'),
                subtitle: const Text('Удаление постов'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminManagePostsScreen()),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.place, color: Colors.brown),
                title: const Text('Народные точки'),
                subtitle: const Text('Точки с народной карты'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminManageFolkPointsScreen()),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.groups, color: Colors.teal),
                title: const Text('Группы'),
                subtitle: const Text('Переименовать / удалить'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminManageGroupsScreen()),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.campaign, color: Colors.indigo),
                title: const Text('Каналы'),
                subtitle: const Text('Переименовать / удалить'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminManageChannelsScreen()),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Кнопка: Вернуться к профилю
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Вернуться в профиль'),
            ),
          ],
        ),
      ),
    );
  }
}

// 🏪 ЭКРАН ДОБАВЛЕНИЯ / РЕДАКТИРОВАНИЯ МАГАЗИНА
class AddStoreScreen extends StatefulWidget {
  final Map<String, dynamic>? existingStore;
  const AddStoreScreen({super.key, this.existingStore});

  @override
  State<AddStoreScreen> createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends State<AddStoreScreen> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _imagePath;

 double? _selectedLat;
  double? _selectedLng;

  final List<String> _categories = [
    'Спорт и туризм', 'Рыбалка и охота', 'Прокат снаряжения', 
    'Кафе и еда', 'Аптека и медицина', 'Сувениры', 'Другое'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingStore != null) {
      _nameCtrl.text = widget.existingStore!['name'];
      _addressCtrl.text = widget.existingStore!['address'];
      _categoryCtrl.text = widget.existingStore!['category'];
      _hoursCtrl.text = widget.existingStore!['hours'];
      _phoneCtrl.text = widget.existingStore!['phone'];
      if (widget.existingStore!['image'].contains('/')) {
        _imagePath = widget.existingStore!['image'];
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _imagePath = image.path);
  }

        Future<void> _saveStore() async {
    if (_nameCtrl.text.trim().isEmpty || _addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Заполните название и адрес!')));
      return;
    }
    String? finalImagePath = _imagePath;
    
    if (_imagePath != null && !_imagePath!.startsWith('/var/')) {
      try {
        // ✅ ВАЖНО: здесь должно быть await!
        final fileName = 'store_${DateTime.now().millisecondsSinceEpoch}.jpg';
        finalImagePath = await persistMediaPath(_imagePath!, fileName) ?? _imagePath;
      } catch (e) {
        print('❌ Ошибка сохранения фото магазина: $e');
      }
    }
    // ... (остальной код метода остается без изменений)

    final storeData = {
      'id': widget.existingStore?['id'] ?? DateTime.now().millisecondsSinceEpoch,
      'name': _nameCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'category': _categoryCtrl.text.isEmpty ? 'Другое' : _categoryCtrl.text,
      'hours': _hoursCtrl.text.trim().isEmpty ? 'Круглосуточно' : _hoursCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim().isEmpty ? 'Не указан' : _phoneCtrl.text.trim(),
      'image': finalImagePath ?? '🏪',
      'rating': widget.existingStore?['rating'] ?? 5.0,
      'reviews': widget.existingStore?['reviews'] ?? 0,
      'inStock': widget.existingStore?['inStock'] ?? [],
      'lat': _selectedLat,
      'lng': _selectedLng,
    };

    if (widget.existingStore != null) {
      AppStore().updateStore(storeData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Магазин обновлен!')));
    } else {
      AppStore().addStore(storeData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Магазин добавлен!')));
    }
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingStore != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Редактировать магазин' : 'Добавить магазин')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[400]!)),
                child: _imagePath != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(12), child: appImage(_imagePath, fit: BoxFit.cover))
                    : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Нажмите, чтобы выбрать фото', style: TextStyle(color: Colors.grey)),
                      ]),
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Название магазина *', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Адрес *', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            
            // ✅ ВЫПАДАЮЩИЙ СПИСОК КАТЕГОРИЙ
            DropdownButtonFormField<String>(
              value: _categories.contains(_categoryCtrl.text) ? _categoryCtrl.text : null,
              items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (val) => setState(() => _categoryCtrl.text = val ?? ''),
              decoration: const InputDecoration(labelText: 'Категория', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _hoursCtrl, decoration: const InputDecoration(labelText: 'Часы работы', border: OutlineInputBorder()))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Телефон', border: OutlineInputBorder()))),
              ],
            ),

              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.map, color: Colors.blue),
                  title: const Text('📍 Место на карте'),
                  subtitle: Text(_selectedLat != null ? 'Координаты заданы ✅' : 'Нажми, чтобы выбрать'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MapPickerScreen(initialLat: _selectedLat, initialLng: _selectedLng)),
                    );
                    if (result != null) {
                      setState(() {
                        _selectedLat = result.latitude;
                        _selectedLng = result.longitude;
                      });
                    }
                  },
                ),
              ),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveStore,
              icon: const Icon(Icons.save),
              label: Text(isEdit ? 'Сохранить изменения' : 'Добавить магазин'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
// 🏕️ ЭКРАН ДОБАВЛЕНИЯ ТУРА
class AddTourScreen extends StatefulWidget {
  final Map<String, dynamic>? existingTour;
  const AddTourScreen({super.key, this.existingTour});

  @override
  State<AddTourScreen> createState() => _AddTourScreenState();
}

class _AddTourScreenState extends State<AddTourScreen> {
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  String? _imagePath;
  double? _selectedLat;
  double? _selectedLng;

  final List<String> _categories = [
    'Поход выходного дня', 'Экстремальный туризм', 'Экскурсия', 
    'Велотур', 'Водный поход', 'Горный туризм', 'Другое'
  ];
  String _selectedCategory = 'Поход выходного дня';

  @override
  void initState() {
    super.initState();
    if (widget.existingTour != null) {
      _nameCtrl.text = widget.existingTour!['name'];
      _descriptionCtrl.text = widget.existingTour!['description'];
      _priceCtrl.text = widget.existingTour!['price'];
      _durationCtrl.text = widget.existingTour!['duration'];
      _selectedCategory = widget.existingTour!['category'];
      _selectedLat = (widget.existingTour!['lat'] as num?)?.toDouble();
      _selectedLng = (widget.existingTour!['lng'] as num?)?.toDouble();
      if (widget.existingTour!['image'].contains('/')) {
        _imagePath = widget.existingTour!['image'];
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _imagePath = image.path);
  }

        Future<void> _saveTour() async {
    if (_nameCtrl.text.trim().isEmpty || _descriptionCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Заполните название и описание!')));
      return;
    }
    String? finalImagePath = _imagePath;
    
    if (_imagePath != null && !_imagePath!.startsWith('/var/')) {
      try {
        // ✅ ВАЖНО: здесь должно быть await!
        final fileName = 'tour_${DateTime.now().millisecondsSinceEpoch}.jpg';
        finalImagePath = await persistMediaPath(_imagePath!, fileName) ?? _imagePath;
      } catch (e) {
        print('❌ Ошибка сохранения фото тура: $e');
      }
    }
    // ... (остальной код метода остается без изменений)

    final tourData = {
      'id': widget.existingTour?['id'] ?? DateTime.now().millisecondsSinceEpoch,
      'name': _nameCtrl.text.trim(),
      'description': _descriptionCtrl.text.trim(),
      'price': _priceCtrl.text.trim().isEmpty ? 'Бесплатно' : _priceCtrl.text.trim(),
      'duration': _durationCtrl.text.trim().isEmpty ? '1 день' : _durationCtrl.text.trim(),
      'category': _selectedCategory,
      'image': finalImagePath ?? '🏕️',
      'lat': _selectedLat,
      'lng': _selectedLng,
    };

    if (widget.existingTour != null) {
      AppStore().updateTour(tourData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Тур обновлен!')));
    } else {
      AppStore().addTour(tourData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Тур добавлен!')));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingTour != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Редактировать тур' : 'Добавить тур')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[400]!)),
                child: _imagePath != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(12), child: appImage(_imagePath, fit: BoxFit.cover))
                    : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Нажмите, чтобы выбрать фото', style: TextStyle(color: Colors.grey)),
                      ]),
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Название тура *', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _descriptionCtrl, decoration: const InputDecoration(labelText: 'Описание *', border: OutlineInputBorder()), maxLines: 3),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val ?? 'Поход выходного дня'),
              decoration: const InputDecoration(labelText: 'Категория', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Цена', border: OutlineInputBorder()))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _durationCtrl, decoration: const InputDecoration(labelText: 'Длительность', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.map_outlined),
              title: const Text('Точка на карте'),
              subtitle: Text(_selectedLat != null ? 'Координаты заданы ✅' : 'Нажми, чтобы выбрать'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MapPickerScreen(initialLat: _selectedLat, initialLng: _selectedLng)),
                );
                if (result != null) {
                  setState(() {
                    _selectedLat = result.latitude;
                    _selectedLng = result.longitude;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveTour,
              icon: const Icon(Icons.save),
              label: Text(isEdit ? 'Сохранить изменения' : 'Добавить тур'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
// 🌲 ЭКРАН ДОБАВЛЕНИЯ ПАРКА
class AddParkScreen extends StatefulWidget {
  final Map<String, dynamic>? existingPark;
  const AddParkScreen({super.key, this.existingPark});

  @override
  State<AddParkScreen> createState() => _AddParkScreenState();
}

class _AddParkScreenState extends State<AddParkScreen> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  String? _imagePath;

  final List<String> _types = [
    'Национальный парк', 'Заповедник', 'Городской парк', 
    'Лесопарк', 'Природный заказник', 'Другое'
  ];
    double? _selectedLat;
  double? _selectedLng;

  String _selectedType = 'Национальный парк';

  @override
  void initState() {
    super.initState();
    if (widget.existingPark != null) {
      _nameCtrl.text = widget.existingPark!['name'];
      _addressCtrl.text = widget.existingPark!['address'];
      _descriptionCtrl.text = widget.existingPark!['description'];
      _selectedType = widget.existingPark!['type'];
      if (widget.existingPark!['image'].contains('/')) {
        _imagePath = widget.existingPark!['image'];
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _imagePath = image.path);
  }

        Future<void> _savePark() async {
    if (_nameCtrl.text.trim().isEmpty || _addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Заполните название и адрес!')));
      return;
    }
    String? finalImagePath = _imagePath;
    
    if (_imagePath != null && !_imagePath!.startsWith('/var/')) {
      try {
        // ✅ ВАЖНО: здесь должно быть await!
        final fileName = 'park_${DateTime.now().millisecondsSinceEpoch}.jpg';
        finalImagePath = await persistMediaPath(_imagePath!, fileName) ?? _imagePath;
      } catch (e) {
        print('❌ Ошибка сохранения фото парка: $e');
      }
    }
    // ... (остальной код метода остается без изменений)

    final parkData = {
      'id': widget.existingPark?['id'] ?? DateTime.now().millisecondsSinceEpoch,
      'name': _nameCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'description': _descriptionCtrl.text.trim(),
      'type': _selectedType,
      'image': finalImagePath ?? '🌲',
      'lat': _selectedLat, // ← ← ← ДОБАВЬ ЭТИ ДВЕ СТРОКИ
      'lng': _selectedLng,
    };

    if (widget.existingPark != null) {
      AppStore().updatePark(parkData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Парк обновлен!')));
    } else {
      AppStore().addPark(parkData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Парк добавлен!')));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingPark != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Редактировать парк' : 'Добавить парк')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[400]!)),
                child: _imagePath != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(12), child: appImage(_imagePath, fit: BoxFit.cover))
                    : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Нажмите, чтобы выбрать фото', style: TextStyle(color: Colors.grey)),
                      ]),
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Название парка *', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Адрес *', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _descriptionCtrl, decoration: const InputDecoration(labelText: 'Описание', border: OutlineInputBorder()), maxLines: 3),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _types.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (val) => setState(() => _selectedType = val ?? 'Национальный парк'),
              decoration: const InputDecoration(labelText: 'Тип', border: OutlineInputBorder()),
            ),
                          const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.map, color: Colors.green),
                  title: const Text('📍 Место на карте'),
                  subtitle: Text(_selectedLat != null ? 'Координаты заданы ✅' : 'Нажми, чтобы выбрать'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MapPickerScreen(initialLat: _selectedLat, initialLng: _selectedLng)),
                    );
                    if (result != null) {
                      setState(() {
                        _selectedLat = result.latitude;
                        _selectedLng = result.longitude;
                      });
                    }
                  },
                ),
              ),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _savePark,
              icon: const Icon(Icons.save),
              label: Text(isEdit ? 'Сохранить изменения' : 'Добавить парк'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ——— Админ: управление списками ———

Future<bool> _confirmDelete(BuildContext context, String title) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: const Text('Это действие нельзя отменить.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Удалить'),
        ),
      ],
    ),
  );
  return ok == true;
}

Future<bool> _confirmAction(BuildContext context, String title, String body) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Да')),
      ],
    ),
  );
  return ok == true;
}

class AdminManageStoresScreen extends StatelessWidget {
  const AdminManageStoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Магазины'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'clear') {
                if (await _confirmAction(context, 'Очистить магазины?', 'Все магазины будут удалены.')) {
                  await AppStore().clearStores();
                }
              } else if (v == 'restore') {
                if (await _confirmAction(context, 'Восстановить сиды?', 'Список заменится на стандартные магазины.')) {
                  await AppStore().restoreStoresSeeds();
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'clear', child: Text('Очистить раздел')),
              PopupMenuItem(value: 'restore', child: Text('Восстановить сиды')),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: AppStore().storesNotifier,
        builder: (_, items, __) {
          if (items.isEmpty) {
            return const Center(child: Text('Магазинов нет'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final s = items[i];
              return ListTile(
                leading: Text('${s['image'] ?? '🏪'}', style: const TextStyle(fontSize: 24)),
                title: Text('${s['name']}'),
                subtitle: Text('${s['address'] ?? s['category'] ?? ''}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddStoreScreen(existingStore: s)),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    if (await _confirmDelete(context, 'Удалить «${s['name']}»?')) {
                      await AppStore().deleteStore(s['id'] as int);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminManageParksScreen extends StatelessWidget {
  const AdminManageParksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Парки / локации'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'clear') {
                if (await _confirmAction(context, 'Очистить парки?', 'Все парки будут удалены.')) {
                  await AppStore().clearParks();
                }
              } else if (v == 'restore') {
                if (await _confirmAction(context, 'Восстановить сиды?', 'Список заменится на стандартные парки.')) {
                  await AppStore().restoreParksSeeds();
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'clear', child: Text('Очистить раздел')),
              PopupMenuItem(value: 'restore', child: Text('Восстановить сиды')),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: AppStore().parksNotifier,
        builder: (_, items, __) {
          if (items.isEmpty) {
            return const Center(child: Text('Парков нет'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final p = items[i];
              return ListTile(
                leading: Text('${p['image'] ?? '🌲'}', style: const TextStyle(fontSize: 24)),
                title: Text('${p['name']}'),
                subtitle: Text('${p['address'] ?? p['description'] ?? ''}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddParkScreen(existingPark: p)),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    if (await _confirmDelete(context, 'Удалить «${p['name']}»?')) {
                      await AppStore().deletePark(p['id'] as int);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminManageToursScreen extends StatelessWidget {
  const AdminManageToursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Туры'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'clear') {
                if (await _confirmAction(context, 'Очистить туры?', 'Все туры будут удалены.')) {
                  await AppStore().clearTours();
                }
              } else if (v == 'restore') {
                if (await _confirmAction(context, 'Восстановить сиды?', 'Список заменится на стандартные туры.')) {
                  await AppStore().restoreToursSeeds();
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'clear', child: Text('Очистить раздел')),
              PopupMenuItem(value: 'restore', child: Text('Восстановить сиды')),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: AppStore().toursNotifier,
        builder: (_, items, __) {
          if (items.isEmpty) {
            return const Center(child: Text('Туров нет'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final t = items[i];
              return ListTile(
                leading: Text('${t['image'] ?? '🥾'}', style: const TextStyle(fontSize: 24)),
                title: Text('${t['name']}'),
                subtitle: Text('${t['description'] ?? t['address'] ?? ''}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddTourScreen(existingTour: t)),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    if (await _confirmDelete(context, 'Удалить «${t['name']}»?')) {
                      await AppStore().deleteTour(t['id'] as int);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminManagePostsScreen extends StatelessWidget {
  const AdminManagePostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Посты ленты'),
        actions: [
          IconButton(
            tooltip: 'Очистить все',
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              if (await _confirmAction(context, 'Очистить ленту?', 'Все посты будут удалены.')) {
                await AppStore().clearFeedPosts();
              }
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: AppStore().feedPostsNotifier,
        builder: (_, visible, __) {
          // Показываем и скрытые — берём полный список из store
          final items = AppStore().feedPosts;
          if (items.isEmpty) {
            return const Center(child: Text('Постов нет'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final p = items[i];
              final hidden = p['hidden'] == true;
              return ListTile(
                leading: Text('${p['authorAvatar'] ?? '👤'}', style: const TextStyle(fontSize: 22)),
                title: Text('${p['author'] ?? 'Автор'}${hidden ? ' (скрыт)' : ''}'),
                subtitle: Text(
                  '${p['text'] ?? ''}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    if (await _confirmDelete(context, 'Удалить пост?')) {
                      await AppStore().deleteFeedPost(p['id'] as int);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminManageFolkPointsScreen extends StatelessWidget {
  const AdminManageFolkPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Народные точки'),
        actions: [
          IconButton(
            tooltip: 'Очистить все',
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              if (await _confirmAction(context, 'Очистить точки?', 'Все народные точки будут удалены.')) {
                await AppStore().clearUserMapPoints();
              }
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: AppStore().userMapPointsNotifier,
        builder: (_, items, __) {
          if (items.isEmpty) {
            return const Center(child: Text('Точек нет'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final p = items[i];
              final title = '${p['title'] ?? p['name'] ?? 'Точка'}';
              return ListTile(
                leading: const Icon(Icons.place, color: Colors.brown),
                title: Text(title),
                subtitle: Text('${p['description'] ?? ''}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    if (await _confirmDelete(context, 'Удалить «$title»?')) {
                      AppStore().deleteUserPoint(p['id'] as int);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Future<String?> _askRename(BuildContext context, String currentName) async {
  final ctrl = TextEditingController(text: currentName);
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Переименовать'),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Новое название'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
          child: const Text('Сохранить'),
        ),
      ],
    ),
  );
  if (result == null || result.isEmpty) return null;
  return result;
}

class AdminManageGroupsScreen extends StatelessWidget {
  const AdminManageGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Группы'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'clear') {
                if (await _confirmAction(context, 'Очистить группы?', 'Все группы и их чаты будут удалены.')) {
                  await AppStore().clearGroups();
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'clear', child: Text('Очистить раздел')),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: AppStore().groupsNotifier,
        builder: (_, items, __) {
          if (items.isEmpty) {
            return const Center(child: Text('Групп нет'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final g = items[i];
              final owner = g['createdBy'] ?? 'система';
              return ListTile(
                leading: Text('${g['avatar'] ?? '🌿'}', style: const TextStyle(fontSize: 24)),
                title: Text('${g['name']}'),
                subtitle: Text('${g['topic'] ?? ''} • создал: $owner'),
                onTap: () async {
                  final name = await _askRename(context, '${g['name']}');
                  if (name != null) await AppStore().renameGroup(g['id'] as int, name);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    if (await _confirmDelete(context, 'Удалить «${g['name']}»?')) {
                      await AppStore().deleteGroup(g['id'] as int);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminManageChannelsScreen extends StatelessWidget {
  const AdminManageChannelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каналы'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'clear') {
                if (await _confirmAction(context, 'Очистить каналы?', 'Все каналы и их чаты будут удалены.')) {
                  await AppStore().clearChannels();
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'clear', child: Text('Очистить раздел')),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: AppStore().channelsNotifier,
        builder: (_, items, __) {
          if (items.isEmpty) {
            return const Center(child: Text('Каналов нет'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final c = items[i];
              final owner = c['createdBy'] ?? 'система';
              return ListTile(
                leading: Text('${c['avatar'] ?? '📢'}', style: const TextStyle(fontSize: 24)),
                title: Text('${c['name']}'),
                subtitle: Text('создал: $owner'),
                onTap: () async {
                  final name = await _askRename(context, '${c['name']}');
                  if (name != null) await AppStore().renameChannel(c['id'] as int, name);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    if (await _confirmDelete(context, 'Удалить «${c['name']}»?')) {
                      await AppStore().deleteChannel(c['id'] as int);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
