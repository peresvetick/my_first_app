import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_first_app/app/theme/app_theme.dart';
import 'package:my_first_app/utils/app_image.dart';
import 'package:my_first_app/app/widgets/app_text.dart';
import 'package:my_first_app/data/app_store.dart';
import 'package:my_first_app/data/models/models.dart';
import 'package:my_first_app/features/admin/admin_screens.dart';
import 'package:my_first_app/features/auth/login_screen.dart';
import 'package:my_first_app/features/learn/learn_screens.dart';
import 'package:my_first_app/features/sos/sos_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  // Метод для редактирования биографии
  void _showEditBioDialog(BuildContext context) {
    final ctrl = TextEditingController(text: AppStore().userBio);
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('✏️ О себе'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'Напишите немного о себе...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          maxLength: 100,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              AppStore().updateUserBio(ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          if (AppStore().userName == 'albert')
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DevToolsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ValueListenableBuilder<String?>(
              valueListenable: AppStore().userAvatarPathNotifier,
              builder: (_, path, __) => ValueListenableBuilder<String>(
                valueListenable: AppStore().userAvatarNotifier,
                builder: (_, avatar, __) => CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green[100],
                  backgroundImage: appImageProvider(path),
                  child: path == null ? Text(avatar, style: const TextStyle(fontSize: 40)) : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<String>(
              valueListenable: AppStore().userNameNotifier,
              builder: (_, name, __) => AppText(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            ValueListenableBuilder<String>(
              valueListenable: AppStore().userNickNotifier,
              builder: (_, nick, __) => nick.isEmpty
                  ? const SizedBox.shrink()
                  : AppText('@$nick', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ValueListenableBuilder<String>(
              valueListenable: AppStore().userCityNotifier,
              builder: (_, city, __) => ValueListenableBuilder<int?>(
                valueListenable: AppStore().userAgeNotifier,
                builder: (_, age, __) {
                  final bits = <String>[
                    if (city.isNotEmpty) city,
                    if (age != null) '$age лет',
                  ];
                  if (bits.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: AppText(bits.join(' • '), style: TextStyle(color: Colors.grey.shade700)),
                  );
                },
              ),
            ),
            ValueListenableBuilder<List<String>>(
              valueListenable: AppStore().userHobbiesNotifier,
              builder: (_, hobbies, __) {
                if (hobbies.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 6,
                    children: hobbies.map((h) => Chip(label: Text(h), visualDensity: VisualDensity.compact)).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => showSosSheet(context),
              icon: Icon(Icons.sos, color: Colors.red.shade700),
              label: Text('sos'.tr(), style: TextStyle(color: Colors.red.shade700)),
            ),
            
            const SizedBox(height: 8),

            // ← ← ← ПОЛЕ "О СЕБЕ"
            ValueListenableBuilder<String>(
              valueListenable: AppStore().userBioNotifier,
              builder: (_, bio, __) {
                return Column(
                  children: [
                    if (bio.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                        child: Text(
                          bio,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ),
                    TextButton(
                      onPressed: () => _showEditBioDialog(context),
                      child: const Text('✏️ Редактировать описание', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 16),

            // ← ← ← МОИ ХЕШТЕГИ (награды)
            ValueListenableBuilder<List<String>>(
              valueListenable: AppStore().userHashtagsNotifier,
              builder: (_, hashtags, __) {
                if (hashtags.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🏆 Мои достижения:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: hashtags.map((hashtagKey) {
                        final hashtag = availableHashtags[hashtagKey];
                        if (hashtag == null) return const SizedBox.shrink();
                        final color = hashtag.color == 'green' ? Colors.green : (hashtag.color == 'blue' ? Colors.blue : Colors.red);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color, width: 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(hashtag.tag, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                color: color,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => AppStore().removeHashtag(hashtagKey),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),

            // ← ← ← ДОСТУПНЫЕ НАГРАДЫ (если тест пройден, но хештег не добавлен)
            ValueListenableBuilder<List<String>>(
              valueListenable: AppStore().userHashtagsNotifier,
              builder: (_, userHashtags, __) {
                final available = availableHashtags.entries
                    .where((e) => !userHashtags.contains(e.key))
                    .toList();
                
                if (available.isEmpty) return const SizedBox.shrink();
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✨ Доступные награды:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: available.map((entry) {
                        final hashtag = entry.value;
                        final color = hashtag.color == 'green' ? Colors.green : (hashtag.color == 'blue' ? Colors.blue : Colors.red);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(hashtag.tag, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => AppStore().addHashtag(entry.key),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.add, size: 12, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),

// ← ← ← КНОПКИ АДМИНИСТРАТОРА (видны только тебе!)
ValueListenableBuilder<String>(
  valueListenable: AppStore().userNameNotifier,
  builder: (_, name, __) {
    // Показываем кнопки только если логин "albert"
    if (name != 'albert') return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          '🛠️ Управление контентом',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.admin_panel_settings, color: Colors.purple),
            title: const Text('Панель администратора'),
            subtitle: const Text('Добавлять магазины, локации, туры'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminScreen()),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  },
),

            // ← ← ← КНОПКА "РАСШИРИТЬ КРУГОЗОР"
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.school, color: Colors.purple),
                title: const Text('📚 Расширить кругозор'),
                subtitle: const Text('Курсы и тесты по выживанию'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CoursesScreen()),
                ),
              ),
            ),
            
            
            _btn(Icons.edit, 'Редактировать профиль', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
            _btn(Icons.settings, 'Настройки', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
            _btn(Icons.logout, 'Выйти', () {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Выйти из аккаунта?'),
      content: const Text('Вы вернётесь на экран входа.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Закрываем диалог
            // Возвращаемся на экран входа
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Выйти'),
        ),
      ],
    ),
  );
}, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _btn(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : Colors.green),
        title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : null)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController(text: AppStore().userName);
  final _nickCtrl = TextEditingController(text: AppStore().userNick);
  final _cityCtrl = TextEditingController(text: AppStore().userCity);
  final _ageCtrl = TextEditingController(text: AppStore().userAge?.toString() ?? '');
  final _hobbyCtrl = TextEditingController();
  String _selectedAvatar = AppStore().userAvatar;
  String? _avatarPath = AppStore().userAvatarPath;
  List<String> _hobbies = List.from(AppStore().userHobbies);
  final _avatars = ['🌲', '🦌', '🦅', '🏔️', '⛺', '🍄', '🌊', '🧭', '🔥', '🌿'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактирование')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage: appImageProvider(_avatarPath),
              child: _avatarPath == null ? Text(_selectedAvatar, style: const TextStyle(fontSize: 40)) : null,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
              if (file != null) setState(() => _avatarPath = file.path);
            },
            icon: const Icon(Icons.photo),
            label: const Text('Фото из галереи'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _avatars
                .map((a) => GestureDetector(
                      onTap: () => setState(() {
                        _selectedAvatar = a;
                        _avatarPath = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: _selectedAvatar == a && _avatarPath == null ? Colors.green : Colors.transparent, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(a, style: const TextStyle(fontSize: 24)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Имя')),
          const SizedBox(height: 10),
          TextField(controller: _nickCtrl, decoration: const InputDecoration(labelText: 'Никнейм')),
          const SizedBox(height: 10),
          TextField(controller: _cityCtrl, decoration: const InputDecoration(labelText: 'Город')),
          const SizedBox(height: 10),
          TextField(controller: _ageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Возраст')),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: TextField(controller: _hobbyCtrl, decoration: const InputDecoration(labelText: 'Увлечение'))),
              IconButton(
                onPressed: () {
                  if (_hobbyCtrl.text.trim().isEmpty) return;
                  setState(() {
                    _hobbies.add(_hobbyCtrl.text.trim());
                    _hobbyCtrl.clear();
                  });
                },
                icon: const Icon(Icons.add_circle, color: Colors.green),
              ),
            ],
          ),
          Wrap(spacing: 6, children: _hobbies.map((h) => Chip(label: Text(h), onDeleted: () => setState(() => _hobbies.remove(h)))).toList()),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              AppStore().updateExtendedProfile(
                name: _nameCtrl.text.trim().isEmpty ? AppStore().userName : _nameCtrl.text.trim(),
                avatar: _selectedAvatar,
                nick: _nickCtrl.text.trim(),
                city: _cityCtrl.text.trim(),
                age: int.tryParse(_ageCtrl.text.trim()),
                hobbies: _hobbies,
                avatarPath: _avatarPath,
                clearAvatarPath: _avatarPath == null,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Профиль сохранён')));
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
class DevToolsScreen extends StatefulWidget {
  const DevToolsScreen({super.key});
  @override
  State<DevToolsScreen> createState() => _DevToolsScreenState();
}

class _DevToolsScreenState extends State<DevToolsScreen> {
  final _imageUrlCtrl = TextEditingController();
  final _postTextCtrl = TextEditingController();
  String _selectedAuthor = 'ЛеснойВолк';
  
  final _authors = ['ЛеснойВолк', 'РыбакДВ', 'ГрибникПро'];
  final _avatars = {'ЛеснойВолк': '🐺', 'РыбакДВ': '🎣', 'ГрибникПро': '🍄'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🛠️ DevTools')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📊 Статистика', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: AppStore().feedPostsNotifier,
                      builder: (_, posts, __) => Text('Постов: ${posts.length}'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('➕ Добавить пост', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _postTextCtrl,
                      decoration: const InputDecoration(labelText: 'Текст поста', border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _imageUrlCtrl,
                      decoration: const InputDecoration(labelText: 'Путь к фото (assets/images/...)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    DropdownButton<String>(
                      value: _selectedAuthor,
                      isExpanded: true,
                      items: _authors.map((author) => DropdownMenuItem(value: author, child: Text('${_avatars[author]} $author'))).toList(),
                      onChanged: (v) => setState(() => _selectedAuthor = v!),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _addPost,
                      icon: const Icon(Icons.add),
                      label: const Text('Добавить пост'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🗑️ Опасная зона', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _clearDatabase,
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Очистить всю базу данных'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addPost() {
    if (_postTextCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введите текст поста')));
      return;
    }

    final newPost = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'author': _selectedAuthor,
      'authorAvatar': _avatars[_selectedAuthor],
      'text': _postTextCtrl.text,
      'suns': 0,
      'comments': [],
      'hidden': false,
    };

    if (_imageUrlCtrl.text.isNotEmpty) {
      newPost['image'] = _imageUrlCtrl.text;
    }

    AppStore().feedPosts.add(newPost);
    AppStore().feedPostsNotifier.value = List.from(AppStore().feedPosts);
    AppStore().save();

    _postTextCtrl.clear();
    _imageUrlCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Пост добавлен!')));
  }

  Future<void> _clearDatabase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('⚠️ Очистить базу?'),
        content: const Text('Все посты, группы и сообщения будут удалены!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await AppStore().clearAllData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ База очищена! Перезапустите приложение')));
    }
  }
}
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: Text('dark_theme'.tr()),
              subtitle: Text(isDark ? 'Активна' : 'Выключена'),
              value: isDark,
              onChanged: (v) => AppStore().toggleTheme(v),
              secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ValueListenableBuilder<double>(
              valueListenable: AppStore().fontSizeMultiplierNotifier,
              builder: (_, scale, __) => SwitchListTile(
                title: const Text('Крупный шрифт'),
                subtitle: Text(scale >= 1.4 ? 'Включён (×1.5)' : 'Выключен'),
                value: scale >= 1.4,
                onChanged: (v) => AppStore().setLargeFont(v),
                secondary: const Icon(Icons.format_size),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Тема оформления', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<String>(
                    valueListenable: AppStore().themePresetNotifier,
                    builder: (_, preset, __) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kThemePresets.map((key) {
                        final label = kThemePresetLabels[key] ?? key;
                        return ChoiceChip(
                          label: Text(label),
                          selected: preset == key,
                          onSelected: (_) => AppStore().setThemePreset(key),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ValueListenableBuilder<bool>(
              valueListenable: AppStore().groupNotificationsNotifier,
              builder: (_, enabled, __) => SwitchListTile(
                title: const Text('Уведомления групп'),
                subtitle: Text(enabled ? 'Включены' : 'Выключены'),
                value: enabled,
                onChanged: (v) => AppStore().setGroupNotificationsEnabled(v),
                secondary: Icon(enabled ? Icons.notifications_active : Icons.notifications_off),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.cleaning_services_outlined),
              title: const Text('Очистить кэш'),
              subtitle: const Text('Погода и изображения'),
              onTap: () async {
                try {
                  await AppStore().clearCache();
                  PaintingBinding.instance.imageCache.clear();
                  PaintingBinding.instance.imageCache.clearLiveImages();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Кэш очищен')),
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Не удалось очистить кэш')),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('language'.tr(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<String>(
                    valueListenable: AppStore().localeCodeNotifier,
                    builder: (_, code, __) => SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'ru', label: Text('RU')),
                        ButtonSegment(value: 'en', label: Text('EN')),
                        ButtonSegment(value: 'zh', label: Text('中文')),
                      ],
                      selected: {code},
                      onSelectionChanged: (s) async {
                        final next = s.first;
                        AppStore().setLocaleCode(next);
                        await context.setLocale(Locale(next));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text('Версия приложения 1.0.0', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
