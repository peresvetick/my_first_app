import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import 'package:my_first_app/app/theme/app_theme.dart';
import 'package:my_first_app/utils/app_image.dart';
import 'package:my_first_app/app/widgets/app_widgets.dart';
import 'package:my_first_app/data/app_store.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  void _showCreatePostDialog(BuildContext context) {
    final textCtrl = TextEditingController();
    final images = <XFile>[];
    XFile? video;
    var aspect = 'square';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg))),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Создать пост', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: textCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Что нового?'),
                    ),
                    const SizedBox(height: 12),
                    const Text('Формат медиа'),
                    const SizedBox(height: 6),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'square', label: Text('Квадрат')),
                        ButtonSegment(value: 'wide', label: Text('Широкий')),
                      ],
                      selected: {aspect},
                      onSelectionChanged: (s) => setDialogState(() => aspect = s.first),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            final files = await ImagePicker().pickMultiImage(imageQuality: 85);
                            if (files.isNotEmpty) setDialogState(() => images.addAll(files));
                          },
                          icon: const Icon(Icons.photo_library_outlined),
                          label: Text('Фото (${images.length})'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final file = await ImagePicker().pickVideo(source: ImageSource.gallery);
                            if (file != null) setDialogState(() => video = file);
                          },
                          icon: const Icon(Icons.videocam_outlined),
                          label: Text(video == null ? 'Видео' : 'Видео ✓'),
                        ),
                      ],
                    ),
                    if (images.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 72,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 6),
                          itemBuilder: (_, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: appImage(images[i].path, width: 72, height: 72, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (textCtrl.text.trim().isEmpty && images.isEmpty && video == null) return;
                        await AppStore().createPost(
                          AppStore().userName,
                          AppStore().userAvatar,
                          textCtrl.text.trim(),
                          imagePaths: images.map((e) => e.path).toList(),
                          videoPath: video?.path,
                          mediaAspect: aspect,
                        );
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      },
                      child: const Text('Опубликовать'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Лента'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchUsersScreen())),
          ),
          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _showCreatePostDialog(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(context),
        tooltip: 'Создать пост',
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: AppStore().feedPostsNotifier,
        builder: (_, posts, __) {
          final visiblePosts = posts.where((p) => p['hidden'] != true).toList();
          if (visiblePosts.isEmpty) {
            return const EmptyState(
              title: 'Постов пока нет',
              subtitle: 'Будьте первым — нажмите + и поделитесь находкой',
              icon: Icons.dynamic_feed_outlined,
            );
          }
          // Лента «Слои Земли»: градиент от позиции скролла
          return _EarthLayersFeed(posts: visiblePosts);
        },
      ),
    );
  }
}

/// Лента с полноэкранным градиентом по скроллу (без текстовых подписей слоёв).
class _EarthLayersFeed extends StatefulWidget {
  final List<Map<String, dynamic>> posts;
  const _EarthLayersFeed({required this.posts});

  @override
  State<_EarthLayersFeed> createState() => _EarthLayersFeedState();
}

class _EarthLayersFeedState extends State<_EarthLayersFeed> {
  double _scrollT = 0;

  /// Цвета слоёв: космос → атмосфера → облака → деревья → земля.
  static const _black = Color(0xFF000000);
  static const _purple = Color(0xFF4A148C);
  static const _sky = Color(0xFF4FC3F7);
  static const _white = Color(0xFFFFFFFF);
  static const _green = Color(0xFF2E7D32);
  static const _brown = Color(0xFF5D4037);

  /// Интерполяция двух цветов.
  Color _lerp(Color a, Color b, double t) => Color.lerp(a, b, t.clamp(0.0, 1.0))!;

  /// Пара цветов градиента по доле скролла 0..1.
  (Color, Color) _colorsForScroll(double t) {
    if (t <= 0.10) {
      final local = t / 0.10;
      return (_lerp(_black, _purple, local), _lerp(_black, _purple, (local + 0.25).clamp(0.0, 1.0)));
    }
    if (t <= 0.30) {
      final local = (t - 0.10) / 0.20;
      return (_lerp(_purple, _sky, local), _lerp(_purple, _sky, (local + 0.2).clamp(0.0, 1.0)));
    }
    if (t <= 0.50) {
      final local = (t - 0.30) / 0.20;
      return (_lerp(_sky, _white, local), _lerp(_sky, _white, (local + 0.15).clamp(0.0, 1.0)));
    }
    if (t <= 0.70) {
      final local = (t - 0.50) / 0.20;
      return (_lerp(_white, _green, local), _lerp(_white, _green, (local + 0.2).clamp(0.0, 1.0)));
    }
    final local = ((t - 0.70) / 0.30).clamp(0.0, 1.0);
    return (_lerp(_green, _brown, local), _lerp(_green, _brown, (local + 0.25).clamp(0.0, 1.0)));
  }

  @override
  Widget build(BuildContext context) {
    final posts = widget.posts;
    final pair = _colorsForScroll(_scrollT);
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [pair.$1, pair.$2],
        ),
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.axis != Axis.vertical) return false;
          final max = n.metrics.maxScrollExtent <= 0 ? 1.0 : n.metrics.maxScrollExtent;
          final t = (n.metrics.pixels / max).clamp(0.0, 1.0);
          if ((t - _scrollT).abs() > 0.01) setState(() => _scrollT = t);
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 88),
          itemCount: posts.length,
          itemBuilder: (_, i) {
            return Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: width * 0.8,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: _FeedPostCard(post: posts[i]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeedPostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  const _FeedPostCard({required this.post});

  @override
  State<_FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<_FeedPostCard> {
  bool _burst = false;
  int _page = 0;

  List<Map<String, dynamic>> get _media {
    final raw = widget.post['media'];
    if (raw is List && raw.isNotEmpty) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    final image = widget.post['image'];
    if (image is String && image.isNotEmpty) return [{'type': 'image', 'path': image}];
    return [];
  }

  Future<void> _like() async {
    HapticFeedback.lightImpact();
    await AppStore().addSunToPost(widget.post['id']);
    setState(() => _burst = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _burst = false);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final liked = post['likedByUser'] == true;
    final aspect = post['mediaAspect'] == 'wide' ? 16 / 9 : 1.0;
    final media = _media;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(child: Text(post['authorAvatar'] ?? '👤')),
              title: Text('${post['author']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'hide') AppStore().hidePost(post['id']);
                  if (value == 'report') AppStore().reportPost(post['id'], 'spam');
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'report', child: Text('Пожаловаться')),
                  PopupMenuItem(value: 'hide', child: Text('Скрыть')),
                ],
              ),
            ),
            if ((post['text'] as String?)?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('${post['text']}', style: const TextStyle(fontSize: 16)),
              ),
            if (media.isNotEmpty) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onDoubleTap: _like,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: aspect,
                      child: PageView.builder(
                        itemCount: media.length,
                        onPageChanged: (p) => setState(() => _page = p),
                        itemBuilder: (_, i) {
                          final item = media[i];
                          if (item['type'] == 'video') {
                            return _VideoThumb(path: '${item['path']}');
                          }
                          return appImage('${item['path']}', fit: BoxFit.cover, width: double.infinity);
                        },
                      ),
                    ),
                    if (_burst)
                      const Icon(Icons.favorite, color: Color(0xFF2E7D4F), size: 84)
                          .animate()
                          .scale(begin: const Offset(0.4, 0.4), end: const Offset(1.2, 1.2), duration: 350.ms)
                          .fadeOut(delay: 250.ms),
                    if (media.length > 1)
                      Positioned(
                        bottom: 10,
                        child: Row(
                          children: List.generate(
                            media.length,
                            (i) => Container(
                              width: 7,
                              height: 7,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i == _page ? Colors.white : Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _like,
                    icon: Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      color: liked ? AppColors.forestMid : Colors.grey,
                    ),
                  ),
                  Text('${post['suns']}', style: TextStyle(fontWeight: FontWeight.bold, color: liked ? AppColors.forestMid : null)),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CommentsScreen(postId: post['id'], author: post['author'])),
                    ),
                  ),
                  Text('${(post['comments'] as List?)?.length ?? 0}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoThumb extends StatefulWidget {
  final String path;
  const _VideoThumb({required this.path});

  @override
  State<_VideoThumb> createState() => _VideoThumbState();
}

class _VideoThumbState extends State<_VideoThumb> {
  late final VideoPlayerController _ctrl;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final path = widget.path;
    if (kIsWeb || path.startsWith('http') || path.startsWith('blob:') || path.startsWith('data:')) {
      _ctrl = VideoPlayerController.networkUrl(Uri.parse(path));
    } else {
      _ctrl = VideoPlayerController.networkUrl(Uri.file(path));
    }
    _ctrl.initialize().then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const ColoredBox(color: Colors.black12, child: Center(child: CircularProgressIndicator()));
    return Stack(
      alignment: Alignment.center,
      children: [
        VideoPlayer(_ctrl),
        IconButton(
          onPressed: () {
            setState(() {
              _ctrl.value.isPlaying ? _ctrl.pause() : _ctrl.play();
            });
          },
          icon: Icon(_ctrl.value.isPlaying ? Icons.pause_circle : Icons.play_circle, color: Colors.white, size: 56),
        ),
      ],
    );
  }
}

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});
  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  String _query = '';
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    var users = AppStore().users;
    if (_query.isNotEmpty) {
      users = users.where((u) => '${u['nick']}'.toLowerCase().contains(_query.toLowerCase())).toList();
    }
    if (_filter == 'posts') {
      users = users.where((u) => ((u['posts'] as List?) ?? []).isNotEmpty).toList();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Поиск пользователей')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Ник...'),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('Все')),
                ButtonSegment(value: 'posts', label: Text('С постами')),
              ],
              selected: {_filter},
              onSelectionChanged: (s) => setState(() => _filter = s.first),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (_, i) {
                final u = users[i];
                return ListTile(
                  leading: CircleAvatar(child: Text('${u['avatar']}')),
                  title: Text('${u['nick']}'),
                  subtitle: Text('${u['bio'] ?? ''}'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(user: u))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const UserProfileScreen({super.key, required this.user});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${user['nick']}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(radius: 40, child: Text('${user['avatar']}', style: const TextStyle(fontSize: 32))),
            const SizedBox(height: 12),
            Text('${user['nick']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('${user['bio'] ?? ''}'),
          ],
        ),
      ),
    );
  }
}

class CommentsScreen extends StatefulWidget {
  final int postId;
  final String author;
  const CommentsScreen({super.key, required this.postId, required this.author});
  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _ctrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final index = AppStore().feedPosts.indexWhere((p) => p['id'] == widget.postId);
    final post = index != -1 ? AppStore().feedPosts[index] : <String, dynamic>{};
    final comments = (post['comments'] as List?) ?? [];
    return Scaffold(
      appBar: AppBar(title: Text('Комментарии • ${widget.author}')),
      body: Column(
        children: [
          Expanded(
            child: comments.isEmpty
                ? const Center(child: Text('Будьте первым!'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: comments.length,
                    itemBuilder: (_, i) {
                      final c = comments[i];
                      return ListTile(
                        title: Text('${c['user']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('${c['text']}'),
                        trailing: Text('${c['time']}', style: const TextStyle(fontSize: 11)),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'Комментарий...'))),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.forestMid),
                  onPressed: () async {
                    if (_ctrl.text.trim().isEmpty) return;
                    await AppStore().addCommentToPost(widget.postId, 'Вы', _ctrl.text.trim());
                    _ctrl.clear();
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
