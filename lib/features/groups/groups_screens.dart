import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import 'package:my_first_app/app/theme/app_theme.dart';
import 'package:my_first_app/app/widgets/app_widgets.dart';
import 'package:my_first_app/data/app_store.dart';
import 'package:my_first_app/features/feed/feed_screen.dart';
import 'package:my_first_app/utils/persist_path.dart';

/// Эмодзи-стикеры для группового чата.
const _kStickers = ['🔥', '❤️', '👍', '😂', '😮', '😢', '😡', '🎉', '🌲', '🏕️'];

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сообщества'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchUsersScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateGroupScreen())),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: AppStore().groupsNotifier,
        builder: (_, groups, __) {
          return ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: AppStore().channelsNotifier,
            builder: (_, channels, __) {
              if (groups.isEmpty && channels.isEmpty) {
                return const EmptyState(title: 'Пока нет сообществ', subtitle: 'Создайте группу или канал');
              }
              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  if (channels.isNotEmpty) ...[
                    const Text('Каналы', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 8),
                    ...channels.map((c) => _CommunityTile(
                          title: '${c['name']}',
                          subtitle: '${c['isPublic'] == true ? 'Публичный' : 'Приватный'} • ${c['description'] ?? ''}',
                          avatar: '${c['avatar'] ?? '📢'}',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => GroupChatScreen(group: {...c, 'id': c['id']})),
                          ),
                        )),
                    const SizedBox(height: 16),
                  ],
                  const Text('Группы', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...groups.map((g) => _CommunityTile(
                        title: '${g['name']}',
                        subtitle: '${g['members']} участников • ${g['topic']}',
                        avatar: '${g['avatar'] ?? g['name']?[0] ?? '🌿'}',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GroupChatScreen(group: g))),
                      )),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _CommunityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String avatar;
  final VoidCallback onTap;
  const _CommunityTile({required this.title, required this.subtitle, required this.avatar, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            CircleAvatar(backgroundColor: AppColors.forest.withValues(alpha: 0.12), child: Text(avatar)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});
  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _topic = 'Экология';
  String _avatar = '🌿';
  bool _isPublic = true;
  bool _isChannel = false;
  final _topics = ['Экология', 'Рыбалка', 'Туризм', 'Грибы', 'Велоспорт'];
  final _avatars = ['🌿', '🎣', '🏔️', '🍄', '🚴', '📢', '🔥', '🌍'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isChannel ? 'Создать канал' : 'Создать группу')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Группа')),
              ButtonSegment(value: true, label: Text('Канал')),
            ],
            selected: {_isChannel},
            onSelectionChanged: (s) => setState(() => _isChannel = s.first),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: _avatars
                .map((a) => ChoiceChip(
                      label: Text(a, style: const TextStyle(fontSize: 20)),
                      selected: _avatar == a,
                      onSelected: (_) => setState(() => _avatar = a),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Название')),
          const SizedBox(height: 12),
          TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Описание'), maxLines: 2),
          const SizedBox(height: 12),
          if (!_isChannel)
            DropdownButtonFormField<String>(
              initialValue: _topic,
              items: _topics.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _topic = v ?? _topic),
              decoration: const InputDecoration(labelText: 'Тематика'),
            ),
          SwitchListTile(
            title: Text(_isPublic ? 'Публичный' : 'Приватный'),
            value: _isPublic,
            onChanged: (v) => setState(() => _isPublic = v),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (_nameCtrl.text.trim().isEmpty) return;
              await AppStore().addGroupFull(
                name: _nameCtrl.text.trim(),
                topic: _topic,
                description: _descCtrl.text.trim(),
                avatar: _avatar,
                isPublic: _isPublic,
                isChannel: _isChannel,
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }
}

class GroupChatScreen extends StatefulWidget {
  final Map<String, dynamic> group;
  const GroupChatScreen({super.key, required this.group});
  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  AudioRecorder? _recorder;
  bool _recording = false;
  DateTime? _recordStartedAt;
  String? _pendingPath;
  late String _displayName;

  bool get _isChannel => AppStore().isChannelItem(widget.group);
  bool get _canManage => AppStore().canManageCommunity(widget.group);
  bool get _canDelete => AppStore().canDeleteCommunity(widget.group);

  @override
  void initState() {
    super.initState();
    _displayName = '${widget.group['name']}';
    if (!kIsWeb) _recorder = AudioRecorder();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _recorder?.dispose();
    super.dispose();
  }

  Future<void> _renameCommunity() async {
    final ctrl = TextEditingController(text: _displayName);
    final next = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isChannel ? 'Переименовать канал' : 'Переименовать группу'),
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
    if (next == null || next.isEmpty) return;
    final id = widget.group['id'] as int;
    try {
      if (_isChannel) {
        await AppStore().renameChannel(id, next);
      } else {
        await AppStore().renameGroup(id, next);
      }
      widget.group['name'] = next;
      if (mounted) setState(() => _displayName = next);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось переименовать')),
        );
      }
    }
  }

  Future<void> _deleteCommunity() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isChannel ? 'Удалить канал?' : 'Удалить группу?'),
        content: Text('«$_displayName» будет удалена вместе с перепиской.'),
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
    if (ok != true) return;
    final id = widget.group['id'] as int;
    try {
      if (_isChannel) {
        await AppStore().deleteChannel(id);
      } else {
        await AppStore().deleteGroup(id);
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось удалить')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.group['id'] as int;
    return Scaffold(
      backgroundColor: const Color(0xFFE7EBF0),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(
              '${widget.group['members'] ?? 1} уч. • ${widget.group['topic'] ?? (_isChannel ? 'канал' : 'чат')}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          if (_canManage || _canDelete)
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'rename') _renameCommunity();
                if (v == 'delete') _deleteCommunity();
              },
              itemBuilder: (_) => [
                if (_canManage)
                  const PopupMenuItem(value: 'rename', child: Text('Переименовать')),
                if (_canDelete)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Удалить', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<Map<int, List<Map<String, dynamic>>>>(
              valueListenable: AppStore().groupChatsNotifier,
              builder: (_, chats, __) {
                final messages = chats[id] ?? [];
                if (messages.isEmpty) {
                  return const Center(child: Text('Напишите первое сообщение', style: TextStyle(color: Colors.grey)));
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    final mine = msg['user'] == 'Вы';
                    final isSticker = msg['isSticker'] == true;
                    final isVoice = msg['isVoice'] == true;
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: EdgeInsets.fromLTRB(isSticker ? 10 : 12, isSticker ? 6 : 8, 12, 6),
                        decoration: BoxDecoration(
                          // Свои — зелёный, чужие — серый (Telegram-стиль)
                          color: mine ? Colors.green[100] : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(mine ? 16 : 4),
                            bottomRight: Radius.circular(mine ? 4 : 16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!mine)
                              Text('${msg['user']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.forestMid)),
                            if (isVoice)
                              _VoiceBubble(
                                path: '${msg['audioPath'] ?? ''}',
                                durationSec: (msg['durationSec'] as num?)?.toInt() ?? 0,
                              )
                            else if (isSticker)
                              Text('${msg['message']}', style: const TextStyle(fontSize: 48, height: 1.1))
                            else
                              Text('${msg['message']}', style: const TextStyle(fontSize: 15, height: 1.3)),
                            const SizedBox(height: 2),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text('${msg['time']}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_recording)
            Container(
              width: double.infinity,
              color: Colors.red.shade50,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: const Text('🎙 Запись… отпустите, чтобы отправить', textAlign: TextAlign.center, style: TextStyle(color: Colors.red)),
            ),
          SafeArea(
            top: false,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Фото',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('📎 Отправка фото — скоро')),
                    ),
                    icon: const Text('📎', style: TextStyle(fontSize: 20)),
                  ),
                  // Стикеры
                  IconButton(
                    tooltip: 'Стикеры',
                    onPressed: () => _showStickers(id),
                    icon: const Icon(Icons.emoji_emotions_outlined, color: AppColors.forestMid),
                  ),
                  // Голосовое: удержание = запись
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Удерживайте для записи')),
                    ),
                    onLongPressStart: (_) => _startVoice(id),
                    onLongPressEnd: (_) => _stopVoice(id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.mic,
                        color: _recording ? Colors.red : AppColors.forestMid,
                        size: 26,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: InputDecoration(
                        hintText: 'Сообщение',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _send(id),
                    ),
                  ),
                  const SizedBox(width: 6),
                  CircleAvatar(
                    backgroundColor: AppColors.forestMid,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: () => _send(id),
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

  Future<void> _send(int id) async {
    if (_ctrl.text.trim().isEmpty) return;
    await AppStore().sendMessageToGroup(id, _ctrl.text.trim());
    _ctrl.clear();
  }

  void _showStickers(int groupId) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Стикеры', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: _kStickers.map((emoji) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        Navigator.pop(ctx);
                        try {
                          await AppStore().sendMessageToGroup(groupId, emoji, isSticker: true);
                        } catch (_) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Не удалось отправить стикер')),
                            );
                          }
                        }
                      },
                      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 32))),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _startVoice(int groupId) async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Голосовые в web-демо недоступны — откройте приложение')),
        );
      }
      return;
    }
    final recorder = _recorder;
    if (recorder == null) return;
    try {
      final mic = await Permission.microphone.request();
      if (!mic.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Нужен доступ к микрофону')),
          );
        }
        return;
      }
      if (!await recorder.hasPermission()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Микрофон недоступен')),
          );
        }
        return;
      }
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      _pendingPath = path;
      _recordStartedAt = DateTime.now();
      if (mounted) setState(() => _recording = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось начать запись')),
        );
      }
    }
  }

  Future<void> _stopVoice(int groupId) async {
    if (!_recording || _recorder == null) return;
    try {
      final path = await _recorder!.stop();
      final started = _recordStartedAt;
      final duration = started == null ? 1 : DateTime.now().difference(started).inSeconds.clamp(1, 600);
      if (mounted) setState(() => _recording = false);
      final filePath = path ?? _pendingPath;
      _pendingPath = null;
      _recordStartedAt = null;
      if (filePath == null || !mediaPathExists(filePath)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Файл записи не найден')),
          );
        }
        return;
      }
      await AppStore().sendMessageToGroup(
        groupId,
        '🎤 Голосовое',
        isVoice: true,
        audioPath: filePath,
        durationSec: duration,
      );
    } catch (_) {
      if (mounted) {
        setState(() => _recording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка сохранения голосового')),
        );
      }
    }
  }
}

/// Плеер голосового сообщения с прогресс-баром.
class _VoiceBubble extends StatefulWidget {
  final String path;
  final int durationSec;
  const _VoiceBubble({required this.path, required this.durationSec});

  @override
  State<_VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<_VoiceBubble> {
  final _player = AudioPlayer();
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<void>? _completeSub;

  @override
  void initState() {
    super.initState();
    _duration = Duration(seconds: widget.durationSec > 0 ? widget.durationSec : 1);
    _posSub = _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _completeSub = _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() {
        _playing = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _completeSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    try {
      if (_playing) {
        await _player.pause();
        setState(() => _playing = false);
        return;
      }
      if (widget.path.isEmpty || !mediaPathExists(widget.path)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Аудиофайл недоступен')),
          );
        }
        return;
      }
      if (kIsWeb ||
          widget.path.startsWith('http') ||
          widget.path.startsWith('blob:') ||
          widget.path.startsWith('data:')) {
        await _player.play(UrlSource(widget.path));
      } else {
        await _player.play(DeviceFileSource(widget.path));
      }
      final d = await _player.getDuration();
      if (d != null && mounted) setState(() => _duration = d);
      setState(() => _playing = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось воспроизвести')),
        );
      }
    }
  }

  String _fmt(Duration d) {
    final s = d.inSeconds;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = _duration.inMilliseconds <= 0 ? 1 : _duration.inMilliseconds;
    final progress = (_position.inMilliseconds / totalMs).clamp(0.0, 1.0);
    return SizedBox(
      width: 200,
      child: Row(
        children: [
          IconButton(
            onPressed: _toggle,
            icon: Icon(_playing ? Icons.pause_circle_filled : Icons.play_circle_filled, color: AppColors.forestMid, size: 32),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(4),
                  backgroundColor: Colors.black12,
                  color: AppColors.forestMid,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_fmt(_position)} / ${_fmt(_duration)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
