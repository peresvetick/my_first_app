import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:my_first_app/data/models/models.dart';
import 'package:my_first_app/data/real_poi_seeds.dart';
import 'package:my_first_app/utils/persist_path.dart';

/// Менеджер данных с сохранением в Hive.
class AppStore {
  static final AppStore _instance = AppStore._internal();
  factory AppStore() => _instance;
  AppStore._internal();

  late Box _box;

  String userName = 'Исследователь';
  String userAvatar = '🌲';
  String userBio = '';
  String userNick = '';
  String userCity = '';
  int? userAge;
  List<String> userHobbies = [];
  String? userAvatarPath;
  bool isDarkMode = false;
  double fontSizeMultiplier = 1.0;
  String localeCode = 'ru';
  /// Пресет оформления: forest | mountains | ocean | space | minimal.
  String themePreset = 'forest';
  /// Уведомления для групп (локальная настройка, без push).
  bool groupNotificationsEnabled = true;
  List<Map<String, dynamic>> groups = [];
  List<Map<String, dynamic>> channels = [];
  List<Map<String, dynamic>> feedPosts = [];
  List<Map<String, dynamic>> stores = [];
  List<Map<String, dynamic>> tours = [];
  List<Map<String, dynamic>> parks = [];
  List<Map<String, dynamic>> savedCities = [];
  Map<String, dynamic>? cachedWeather;

  Map<int, List<Map<String, dynamic>>> groupChats = {};
  Map<String, TestResult> testResults = {};
  List<String> userHashtags = [];
  WeatherPlace? selectedWeatherPlace;

  final List<Map<String, dynamic>> users = [
    {
      'id': 100,
      'nick': 'ЛеснойВолк',
      'avatar': '🐺',
      'bio': 'Люблю походы 🌲',
      'posts': [
        {
          'id': 1,
          'text': 'Видел лося! 🦌',
          'suns': 24,
          'comments': [
            {'user': 'Вы', 'text': 'Круто!', 'time': '14:30'}
          ]
        }
      ]
    },
    {'id': 101, 'nick': 'РыбакДВ', 'avatar': '🎣', 'bio': 'Рыбалка — жизнь', 'posts': []}
  ];

  final Map<int, List<Map<String, dynamic>>> storeReviews = {
    1: [
      {'user': 'Иван', 'text': 'Отлично!', 'rating': 5, 'date': '2 дня назад'}
    ]
  };
  final Map<int, List<Map<String, dynamic>>> storeMessages = {};
  Map<int, List<Map<String, dynamic>>> parkReviews = {};
  Map<int, List<Map<String, dynamic>>> tourReviews = {};

  final userNameNotifier = ValueNotifier<String>('Исследователь');
  final userAvatarNotifier = ValueNotifier<String>('🌲');
  final userBioNotifier = ValueNotifier<String>('');
  final userNickNotifier = ValueNotifier<String>('');
  final userCityNotifier = ValueNotifier<String>('');
  final userAgeNotifier = ValueNotifier<int?>(null);
  final userHobbiesNotifier = ValueNotifier<List<String>>([]);
  final userAvatarPathNotifier = ValueNotifier<String?>(null);
  final darkModeNotifier = ValueNotifier<bool>(false);
  final fontSizeMultiplierNotifier = ValueNotifier<double>(1.0);
  final localeCodeNotifier = ValueNotifier<String>('ru');
  final themePresetNotifier = ValueNotifier<String>('forest');
  final groupNotificationsNotifier = ValueNotifier<bool>(true);
  final groupsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
  final channelsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
  final groupChatsNotifier = ValueNotifier<Map<int, List<Map<String, dynamic>>>>({});
  final feedPostsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
  final testResultsNotifier = ValueNotifier<Map<String, TestResult>>({});
  final userHashtagsNotifier = ValueNotifier<List<String>>([]);
  final storesNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
  final toursNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
  final parksNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
  final savedCitiesNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
  final selectedWeatherPlaceNotifier = ValueNotifier<WeatherPlace?>(null);

  List<Map<String, dynamic>> userMapPoints = [];
  final userMapPointsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);

  void addUserPoint(Map<String, dynamic> point) {
    userMapPoints.add(point);
    userMapPointsNotifier.value = List.from(userMapPoints);
    _save();
  }

  void deleteUserPoint(int id) {
    userMapPoints.removeWhere((p) => p['id'] == id);
    userMapPointsNotifier.value = List.from(userMapPoints);
    _save();
  }

  Future<void> init() async {
    _box = Hive.box('app_data');

    // Миграция официальных POI на реальные данные (без сброса ленты/профиля)
    await migrateToLatest();

    userName = _box.get('userName', defaultValue: 'Исследователь');
    userAvatar = _box.get('userAvatar', defaultValue: '🌲');
    userBio = _box.get('userBio', defaultValue: '');
    userNick = _box.get('userNick', defaultValue: '');
    userCity = _box.get('userCity', defaultValue: '');
    userAge = _box.get('userAge') as int?;
    userAvatarPath = _box.get('userAvatarPath') as String?;
    final rawHobbies = _box.get('userHobbies');
    userHobbies = rawHobbies is List ? rawHobbies.map((e) => '$e').toList() : [];
    fontSizeMultiplier = (_box.get('fontSizeMultiplier', defaultValue: 1.0) as num).toDouble();
    localeCode = _box.get('localeCode', defaultValue: 'ru');
    themePreset = _box.get('themePreset', defaultValue: 'forest') as String;
    groupNotificationsEnabled = _box.get('groupNotificationsEnabled', defaultValue: true) as bool;
    userBioNotifier.value = userBio;
    userNickNotifier.value = userNick;
    userCityNotifier.value = userCity;
    userAgeNotifier.value = userAge;
    userHobbiesNotifier.value = List.from(userHobbies);
    userAvatarPathNotifier.value = userAvatarPath;
    fontSizeMultiplierNotifier.value = fontSizeMultiplier;
    localeCodeNotifier.value = localeCode;
    themePresetNotifier.value = themePreset;
    groupNotificationsNotifier.value = groupNotificationsEnabled;
    isDarkMode = _box.get('isDarkMode', defaultValue: false);

    savedCities = _readMapList(_box.get('savedCities'), fallback: []);
    savedCitiesNotifier.value = List.from(savedCities);
    cachedWeather = _box.get('cachedWeather') is Map
        ? Map<String, dynamic>.from(_box.get('cachedWeather') as Map)
        : null;
    channels = _readMapList(_box.get('channels'), fallback: []);
    channelsNotifier.value = List.from(channels);

    final rawGroups = _box.get('groups');
    final defaultGroups = [
      {
        'id': 1,
        'name': '🌿 Экология Москвы',
        'members': 1240,
        'topic': 'Экология',
        'description': 'Обсуждаем экологические инициативы'
      },
      {
        'id': 2,
        'name': '🎣 Рыбалка Подмосковья',
        'members': 890,
        'topic': 'Рыбалка',
        'description': 'Отчёты с рыбалки и советы'
      },
      {
        'id': 3,
        'name': '🍄 Грибники Москвы',
        'members': 3450,
        'topic': 'Грибы',
        'description': 'Делимся грибными местами'
      },
      {
        'id': 4,
        'name': '⛰️ Походы и кемпинг',
        'members': 2180,
        'topic': 'Туризм',
        'description': 'Организуем походы вместе'
      },
      {
        'id': 5,
        'name': '🚴 Велосипедисты',
        'members': 1560,
        'topic': 'Велоспорт',
        'description': 'Катаемся по паркам и лесам'
      },
    ];
    final groupsList =
        (rawGroups == null || (rawGroups is List && rawGroups.isEmpty)) ? defaultGroups : rawGroups;
    groups = (groupsList as List).map((item) => Map<String, dynamic>.from(item as Map)).toList();

    final rawPosts = _box.get('feedPosts');
    final defaultPosts = [
      {
        'id': 1,
        'author': 'ЛеснойВолк',
        'authorAvatar': '🐺',
        'text': 'Видел лося! 🦌',
        'suns': 24,
        'comments': [
          {'user': 'Вы', 'text': 'Круто!', 'time': '14:30'}
        ],
        'hidden': false,
        'likedByUser': false
      },
      {
        'id': 2,
        'author': 'РыбакДВ',
        'authorAvatar': '🎣',
        'text': 'Клёв отличный!',
        'suns': 18,
        'comments': [],
        'hidden': false,
        'likedByUser': false
      },
      {
        'id': 3,
        'author': 'ГрибникПро',
        'authorAvatar': '🍄',
        'text': 'Собрал корзину белых грибов! 🍄🍄🍄',
        'suns': 67,
        'comments': [],
        'hidden': false,
        'likedByUser': false
      },
    ];
    final postsList =
        (rawPosts == null || (rawPosts is List && rawPosts.isEmpty)) ? defaultPosts : rawPosts;
    feedPosts = (postsList as List).map((item) {
      final post = Map<String, dynamic>.from(item as Map);
      if (post['comments'] != null) {
        post['comments'] =
            (post['comments'] as List).map((c) => Map<String, dynamic>.from(c as Map)).toList();
      }
      return post;
    }).toList();

    final rawChats = _box.get('groupChats');
    final seededChats = defaultGroupChats();
    final chatsMap =
        (rawChats == null || (rawChats is Map && rawChats.isEmpty)) ? seededChats : rawChats;
    groupChats = (chatsMap as Map).map((key, value) {
      final messages =
          (value as List).map((msg) => Map<String, dynamic>.from(msg as Map)).toList();
      final id = key is int ? key : int.tryParse('$key') ?? 0;
      return MapEntry(id, messages);
    });

    userNameNotifier.value = userName;
    userAvatarNotifier.value = userAvatar;
    darkModeNotifier.value = isDarkMode;
    groupsNotifier.value = groups;
    groupChatsNotifier.value = groupChats;
    feedPostsNotifier.value = feedPosts;

    stores = _readMapList(_box.get('stores'), fallback: defaultStores());
    storesNotifier.value = stores;

    tours = _readMapList(_box.get('tours'), fallback: defaultTours());
    toursNotifier.value = tours;

    parks = _readMapList(_box.get('parks'), fallback: defaultParks());
    parksNotifier.value = parks;

    final rawUserPoints = _box.get('userMapPoints');
    if (rawUserPoints != null && rawUserPoints is List) {
      userMapPoints = rawUserPoints.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    userMapPointsNotifier.value = userMapPoints;

    final rawHashtags = _box.get('userHashtags');
    if (rawHashtags != null && rawHashtags is List) {
      userHashtags = rawHashtags.map((e) => '$e').toList();
    }
    userHashtagsNotifier.value = List.from(userHashtags);

    final rawTestResults = _box.get('testResults');
    if (rawTestResults != null && rawTestResults is List) {
      testResults = {};
      for (final item in rawTestResults) {
        if (item is Map) {
          final result = TestResult.fromMap(Map<String, dynamic>.from(item));
          testResults[result.courseId] = result;
        }
      }
    }
    testResultsNotifier.value = Map.from(testResults);

    parkReviews = _loadReviewMap(_box.get('parkReviews'));
    tourReviews = _loadReviewMap(_box.get('tourReviews'));

    final rawWeatherPlace = _box.get('selectedWeatherPlace');
    if (rawWeatherPlace != null && rawWeatherPlace is Map) {
      selectedWeatherPlace = WeatherPlace.fromMap(Map<String, dynamic>.from(rawWeatherPlace));
    }
    selectedWeatherPlaceNotifier.value = selectedWeatherPlace;
  }

  Map<int, List<Map<String, dynamic>>> _loadReviewMap(dynamic raw) {
    if (raw == null || raw is! Map) return {};
    return raw.map((key, value) {
      final id = key is int ? key : int.tryParse('$key') ?? 0;
      final list = (value as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      return MapEntry(id, list);
    });
  }

  Map _reviewMapToJson(Map<int, List<Map<String, dynamic>>> source) {
    return source.map((key, value) => MapEntry(key.toString(), value));
  }

  List<Map<String, dynamic>> _readMapList(dynamic raw, {required List<Map<String, dynamic>> fallback}) {
    if (raw == null || raw is! List || raw.isEmpty) {
      return fallback.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Обновляет официальные POI (и чаты-сиды) до актуальной версии.
  /// Лента и профиль не сбрасываются.
  Future<void> migrateToLatest() async {
    final current = _box.get('dataVersion');
    if (current == kDataVersion) return;

    await _box.delete('stores');
    await _box.delete('parks');
    await _box.delete('tours');
    // Обновляем демо-переписку групп под v3
    await _box.delete('groupChats');

    final parksSeed = defaultParks();
    final storesSeed = defaultStores();
    final toursSeed = defaultTours();
    final chatsSeed = defaultGroupChats();

    await _box.put('parks', parksSeed);
    await _box.put('stores', storesSeed);
    await _box.put('tours', toursSeed);
    await _box.put(
      'groupChats',
      chatsSeed.map((k, v) => MapEntry(k.toString(), v)),
    );
    await _box.put('dataVersion', kDataVersion);

    parks = parksSeed.map((e) => Map<String, dynamic>.from(e)).toList();
    stores = storesSeed.map((e) => Map<String, dynamic>.from(e)).toList();
    tours = toursSeed.map((e) => Map<String, dynamic>.from(e)).toList();
    groupChats = chatsSeed.map(
      (k, v) => MapEntry(k, v.map((m) => Map<String, dynamic>.from(m)).toList()),
    );
    parksNotifier.value = List.from(parks);
    storesNotifier.value = List.from(stores);
    toursNotifier.value = List.from(tours);
    groupChatsNotifier.value = Map.from(groupChats);
  }

  /// Публичное сохранение (для DevTools и внешних вызовов).
  Future<void> save() => _save();

  /// Очистка Hive-бокса (DevTools).
  Future<void> clearAllData() async {
    await _box.clear();
  }

  Future<void> _save() async {
    await _box.put('userName', userName);
    await _box.put('userAvatar', userAvatar);
    await _box.put('isDarkMode', isDarkMode);
    await _box.put('groups', groups);
    await _box.put('feedPosts', feedPosts);
    await _box.put('groupChats', groupChats);
    await _box.put('userBio', userBio);
    await _box.put('userNick', userNick);
    await _box.put('userCity', userCity);
    await _box.put('userAge', userAge);
    await _box.put('userHobbies', userHobbies);
    await _box.put('userAvatarPath', userAvatarPath);
    await _box.put('fontSizeMultiplier', fontSizeMultiplier);
    await _box.put('localeCode', localeCode);
    await _box.put('themePreset', themePreset);
    await _box.put('groupNotificationsEnabled', groupNotificationsEnabled);
    await _box.put('stores', stores);
    await _box.put('tours', tours);
    await _box.put('parks', parks);
    await _box.put('channels', channels);
    await _box.put('savedCities', savedCities);
    if (cachedWeather != null) await _box.put('cachedWeather', cachedWeather);
    await _box.put('parkReviews', _reviewMapToJson(parkReviews));
    await _box.put('tourReviews', _reviewMapToJson(tourReviews));
    await _box.put('userMapPoints', userMapPoints);
    await _box.put('userHashtags', userHashtags);
    await _box.put(
      'testResults',
      testResults.values.map((r) => r.toMap()).toList(),
    );
    if (selectedWeatherPlace != null) {
      await _box.put('selectedWeatherPlace', selectedWeatherPlace!.toMap());
    } else {
      await _box.delete('selectedWeatherPlace');
    }
    await _box.put('dataVersion', kDataVersion);
  }

  void setFontSizeMultiplier(double value) {
    fontSizeMultiplier = value;
    fontSizeMultiplierNotifier.value = value;
    _save();
  }

  /// Крупный шрифт: 1.5 вкл / 1.0 выкл.
  void setLargeFont(bool enabled) {
    setFontSizeMultiplier(enabled ? 1.5 : 1.0);
  }

  void setLocaleCode(String code) {
    localeCode = code;
    localeCodeNotifier.value = code;
    _save();
  }

  void setThemePreset(String preset) {
    themePreset = preset;
    themePresetNotifier.value = preset;
    _save();
  }

  void setGroupNotificationsEnabled(bool enabled) {
    groupNotificationsEnabled = enabled;
    groupNotificationsNotifier.value = enabled;
    _save();
  }

  /// Очистка кэша погоды и картинок (профиль/лента не трогаем).
  Future<void> clearCache() async {
    try {
      cachedWeather = null;
      await _box.delete('cachedWeather');
    } catch (_) {}
  }

  void updateExtendedProfile({
    String? name,
    String? avatar,
    String? nick,
    String? city,
    int? age,
    List<String>? hobbies,
    String? avatarPath,
    bool clearAvatarPath = false,
  }) {
    if (name != null) {
      userName = name;
      userNameNotifier.value = name;
    }
    if (avatar != null) {
      userAvatar = avatar;
      userAvatarNotifier.value = avatar;
    }
    if (nick != null) {
      userNick = nick;
      userNickNotifier.value = nick;
    }
    if (city != null) {
      userCity = city;
      userCityNotifier.value = city;
    }
    if (age != null) {
      userAge = age;
      userAgeNotifier.value = age;
    }
    if (hobbies != null) {
      userHobbies = hobbies;
      userHobbiesNotifier.value = List.from(hobbies);
    }
    if (clearAvatarPath) {
      userAvatarPath = null;
      userAvatarPathNotifier.value = null;
    } else if (avatarPath != null) {
      userAvatarPath = avatarPath;
      userAvatarPathNotifier.value = avatarPath;
    }
    _save();
  }

  void addSavedCity(Map<String, dynamic> city) {
    savedCities.removeWhere((c) => c['name'] == city['name']);
    savedCities.insert(0, city);
    if (savedCities.length > 12) savedCities = savedCities.take(12).toList();
    savedCitiesNotifier.value = List.from(savedCities);
    _save();
  }

  void cacheWeatherSnapshot(Map<String, dynamic> snap) {
    cachedWeather = snap;
    _save();
  }

  /// Владелец сообщества: ник, если задан, иначе имя.
  String get communityOwnerKey {
    final nick = userNick.trim();
    if (nick.isNotEmpty) return nick;
    return userName;
  }

  /// Админ или создатель записи (сиды без createdBy — только админ).
  bool canManageCommunity(Map<String, dynamic> item) {
    if (userName == 'albert') return true;
    final owner = item['createdBy'];
    if (owner == null) return false;
    return owner == userName || owner == userNick || owner == communityOwnerKey;
  }

  bool canDeleteCommunity(Map<String, dynamic> item) => canManageCommunity(item);

  bool isChannelItem(Map<String, dynamic> item) {
    if (item['type'] == 'channel') return true;
    final id = item['id'];
    return channels.any((c) => c['id'] == id);
  }

  Future<void> addChannel({
    required String name,
    required String description,
    required String avatar,
    required bool isPublic,
  }) async {
    channels.add({
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': name,
      'description': description,
      'avatar': avatar,
      'isPublic': isPublic,
      'members': 1,
      'type': 'channel',
      'createdBy': communityOwnerKey,
    });
    channelsNotifier.value = List.from(channels);
    await _save();
  }

  Future<void> addGroupFull({
    required String name,
    required String topic,
    String description = '',
    String avatar = '🌿',
    bool isPublic = true,
    bool isChannel = false,
  }) async {
    if (isChannel) {
      await addChannel(name: name, description: description, avatar: avatar, isPublic: isPublic);
      return;
    }
    groups.add({
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': name,
      'members': 1,
      'topic': topic,
      'description': description,
      'avatar': avatar,
      'isPublic': isPublic,
      'createdBy': communityOwnerKey,
    });
    groupsNotifier.value = List.from(groups);
    await _save();
  }

  Future<void> deleteGroup(int id) async {
    groups.removeWhere((g) => g['id'] == id);
    groupChats.remove(id);
    groupsNotifier.value = List.from(groups);
    groupChatsNotifier.value = Map.from(groupChats);
    await _save();
  }

  Future<void> deleteChannel(int id) async {
    channels.removeWhere((c) => c['id'] == id);
    groupChats.remove(id);
    channelsNotifier.value = List.from(channels);
    groupChatsNotifier.value = Map.from(groupChats);
    await _save();
  }

  Future<void> renameGroup(int id, String name) async {
    final i = groups.indexWhere((g) => g['id'] == id);
    if (i == -1) return;
    groups[i]['name'] = name.trim();
    groupsNotifier.value = List.from(groups);
    await _save();
  }

  Future<void> renameChannel(int id, String name) async {
    final i = channels.indexWhere((c) => c['id'] == id);
    if (i == -1) return;
    channels[i]['name'] = name.trim();
    channelsNotifier.value = List.from(channels);
    await _save();
  }

  Future<void> clearGroups() async {
    for (final g in groups) {
      groupChats.remove(g['id']);
    }
    groups = [];
    groupsNotifier.value = [];
    groupChatsNotifier.value = Map.from(groupChats);
    await _save();
  }

  Future<void> clearChannels() async {
    for (final c in channels) {
      groupChats.remove(c['id']);
    }
    channels = [];
    channelsNotifier.value = [];
    groupChatsNotifier.value = Map.from(groupChats);
    await _save();
  }

  void setSelectedWeatherPlace(WeatherPlace? place) {
    selectedWeatherPlace = place;
    selectedWeatherPlaceNotifier.value = place;
    _save();
  }

  Future<void> updateProfile(String name, String avatar) async {
    userName = name;
    userAvatar = avatar;
    userNameNotifier.value = name;
    userAvatarNotifier.value = avatar;
    await _save();
  }

  Future<void> toggleTheme(bool isDark) async {
    isDarkMode = isDark;
    darkModeNotifier.value = isDark;
    await _save();
  }

  void updateUserBio(String bio) {
    userBio = bio;
    userBioNotifier.value = bio;
    _save();
  }

  Future<void> addGroup(String name, String topic) async {
    groups.add({
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': name,
      'members': 1,
      'topic': topic,
      'createdBy': communityOwnerKey,
    });
    groupsNotifier.value = List.from(groups);
    await _save();
  }

  Future<void> addSunToPost(int postId) async {
    final i = feedPosts.indexWhere((p) => p['id'] == postId);
    if (i != -1) {
      final currentPost = feedPosts[i];
      final alreadyLiked = currentPost['likedByUser'] ?? false;

      if (alreadyLiked) {
        feedPosts[i]['suns'] = (feedPosts[i]['suns'] as int) - 1;
        feedPosts[i]['likedByUser'] = false;
      } else {
        feedPosts[i]['suns'] = (feedPosts[i]['suns'] as int) + 1;
        feedPosts[i]['likedByUser'] = true;
      }

      feedPostsNotifier.value = List.from(feedPosts);
      await _save();
    }
  }

  Future<void> addCommentToPost(int postId, String user, String text) async {
    final i = feedPosts.indexWhere((p) => p['id'] == postId);
    if (i != -1) {
      if (feedPosts[i]['comments'] == null) feedPosts[i]['comments'] = [];
      (feedPosts[i]['comments'] as List).add({
        'user': user,
        'text': text,
        'time':
            '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}'
      });
      feedPostsNotifier.value = List.from(feedPosts);
      await _save();
    }
  }

  /// Создание поста: несколько фото и/или одно видео + формат медиа.
  Future<void> createPost(
    String author,
    String authorAvatar,
    String text, {
    String? imagePath,
    List<String>? imagePaths,
    String? videoPath,
    String mediaAspect = 'square',
  }) async {
    final media = <Map<String, String>>[];
    final paths = <String>[
      if (imagePaths != null) ...imagePaths,
      if (imagePath != null && imagePath.isNotEmpty) imagePath,
    ];

    for (var i = 0; i < paths.length; i++) {
      try {
        final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final saved = await persistMediaPath(paths[i], fileName);
        if (saved != null) media.add({'type': 'image', 'path': saved});
      } catch (e) {
        if (kDebugMode) print('❌ Ошибка фото: $e');
      }
    }

    if (videoPath != null && videoPath.isNotEmpty) {
      try {
        final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}.mp4';
        final saved = await persistMediaPath(videoPath, fileName);
        if (saved != null) media.add({'type': 'video', 'path': saved});
      } catch (e) {
        if (kDebugMode) print('❌ Ошибка видео: $e');
      }
    }

    final newPost = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'author': author,
      'authorAvatar': authorAvatar,
      'text': text,
      'suns': 0,
      'comments': [],
      'hidden': false,
      'likedByUser': false,
      'mediaAspect': mediaAspect,
      'media': media,
      if (media.isNotEmpty && media.first['type'] == 'image') 'image': media.first['path'],
    };

    feedPosts.insert(0, newPost);
    feedPostsNotifier.value = List.from(feedPosts);
    await _save();
  }

  Future<void> reportPost(int postId, String reason) async {
    final i = feedPosts.indexWhere((p) => p['id'] == postId);
    if (i != -1) {
      feedPosts[i]['reported'] = true;
      feedPostsNotifier.value = List.from(feedPosts);
      await _save();
    }
  }

  Future<void> hidePost(int postId) async {
    final i = feedPosts.indexWhere((p) => p['id'] == postId);
    if (i != -1) {
      feedPosts[i]['hidden'] = true;
      feedPostsNotifier.value =
          List.from(feedPosts.where((p) => !(p['hidden'] == true)));
      await _save();
    }
  }

  /// Жёсткое удаление поста из ленты (админка).
  Future<void> deleteFeedPost(int postId) async {
    feedPosts.removeWhere((p) => p['id'] == postId);
    feedPostsNotifier.value =
        List.from(feedPosts.where((p) => !(p['hidden'] == true)));
    await _save();
  }

  Future<void> clearStores() async {
    stores = [];
    storesNotifier.value = [];
    await _save();
  }

  Future<void> clearParks() async {
    parks = [];
    parksNotifier.value = [];
    await _save();
  }

  Future<void> clearTours() async {
    tours = [];
    toursNotifier.value = [];
    await _save();
  }

  Future<void> clearFeedPosts() async {
    feedPosts = [];
    feedPostsNotifier.value = [];
    await _save();
  }

  Future<void> clearUserMapPoints() async {
    userMapPoints = [];
    userMapPointsNotifier.value = [];
    await _save();
  }

  /// Восстановить сиды каталога (профиль и ленту не трогаем).
  Future<void> restoreStoresSeeds() async {
    stores = defaultStores();
    storesNotifier.value = List.from(stores);
    await _save();
  }

  Future<void> restoreParksSeeds() async {
    parks = defaultParks();
    parksNotifier.value = List.from(parks);
    await _save();
  }

  Future<void> restoreToursSeeds() async {
    tours = defaultTours();
    toursNotifier.value = List.from(tours);
    await _save();
  }

  /// Отправка сообщения в групповой чат (текст / стикер / голосовое).
  Future<void> sendMessageToGroup(
    int groupId,
    String message, {
    bool isSticker = false,
    bool isVoice = false,
    String? audioPath,
    int? durationSec,
  }) async {
    if (!groupChats.containsKey(groupId)) groupChats[groupId] = [];
    final entry = <String, dynamic>{
      'user': 'Вы',
      'message': message,
      'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
    };
    if (isSticker) entry['isSticker'] = true;
    if (isVoice) {
      entry['isVoice'] = true;
      if (audioPath != null) entry['audioPath'] = audioPath;
      if (durationSec != null) entry['durationSec'] = durationSec;
    }
    groupChats[groupId]!.add(entry);
    groupChatsNotifier.value = Map.from(groupChats);
    await _save();
  }

  Future<void> sendMessageToStore(int storeId, String message) async {
    if (!storeMessages.containsKey(storeId)) storeMessages[storeId] = [];
    storeMessages[storeId]!.add({
      'from': 'Вы',
      'message': message,
      'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}'
    });
  }

  void addStoreReview(int storeId, String user, String text, int rating) {
    if (!storeReviews.containsKey(storeId)) storeReviews[storeId] = [];
    storeReviews[storeId]!
        .add({'user': user, 'text': text, 'rating': rating, 'date': 'Только что'});
  }

  Map<String, dynamic>? findUserByNick(String nick) {
    try {
      return users.firstWhere((u) => u['nick'].toLowerCase().contains(nick.toLowerCase()));
    } catch (e) {
      return null;
    }
  }

  void saveTestResult(String courseId, int correct, int total) {
    final percentage = (correct / total) * 100;
    final passed = percentage >= 80;
    final result = TestResult(
      courseId: courseId,
      correctAnswers: correct,
      totalQuestions: total,
      percentage: percentage,
      passed: passed,
      completedAt: DateTime.now(),
    );
    testResults[courseId] = result;
    testResultsNotifier.value = Map.from(testResults);
    if (passed) {
      final hashtagKey = hashtagKeyForCourse(courseId);
      addHashtag(hashtagKey);
    }
    _save();
  }

  /// Публичный ключ достижения по названию курса.
  String hashtagKeyForCourse(String courseId) {
    final id = courseId.toLowerCase();
    if (id.contains('выживание') || id.contains('заблудился') || id.contains('лес')) return 'survival';
    if (id.contains('рыбалка') || id.contains('рыб')) return 'fishing';
    if (id.contains('растения') || id.contains('борщевик') || id.contains('гриб')) return 'plants';
    if (id.contains('эколог') || id.contains('безопасн')) return 'eco';
    return 'survival';
  }

  void addHashtag(String hashtagKey) {
    if (!userHashtags.contains(hashtagKey)) {
      userHashtags.add(hashtagKey);
      userHashtagsNotifier.value = List.from(userHashtags);
      _save();
    }
  }

  void removeHashtag(String hashtagKey) {
    userHashtags.remove(hashtagKey);
    userHashtagsNotifier.value = List.from(userHashtags);
    _save();
  }

  Future<void> addStore(Map<String, dynamic> newStore) async {
    stores.add(newStore);
    storesNotifier.value = List.from(stores);
    await _save();
  }

  Future<void> addTour(Map<String, dynamic> newTour) async {
    tours.add(newTour);
    toursNotifier.value = List.from(tours);
    await _save();
  }

  Future<void> addPark(Map<String, dynamic> newPark) async {
    parks.add(newPark);
    parksNotifier.value = List.from(parks);
    await _save();
  }

  Future<void> deleteStore(int id) async {
    stores.removeWhere((s) => s['id'] == id);
    storesNotifier.value = List.from(stores);
    await _save();
  }

  Future<void> deleteTour(int id) async {
    tours.removeWhere((t) => t['id'] == id);
    toursNotifier.value = List.from(tours);
    await _save();
  }

  Future<void> deletePark(int id) async {
    parks.removeWhere((p) => p['id'] == id);
    parksNotifier.value = List.from(parks);
    await _save();
  }

  Future<void> updateStore(Map<String, dynamic> updatedStore) async {
    final index = stores.indexWhere((s) => s['id'] == updatedStore['id']);
    if (index != -1) {
      stores[index] = updatedStore;
      storesNotifier.value = List.from(stores);
      await _save();
    }
  }

  Future<void> updateTour(Map<String, dynamic> updatedTour) async {
    final index = tours.indexWhere((t) => t['id'] == updatedTour['id']);
    if (index != -1) {
      tours[index] = updatedTour;
      toursNotifier.value = List.from(tours);
      await _save();
    }
  }

  Future<void> updatePark(Map<String, dynamic> updatedPark) async {
    final index = parks.indexWhere((p) => p['id'] == updatedPark['id']);
    if (index != -1) {
      parks[index] = updatedPark;
      parksNotifier.value = List.from(parks);
      await _save();
    }
  }

  void addParkReview(int parkId, String user, String text, int rating) {
    if (!parkReviews.containsKey(parkId)) parkReviews[parkId] = [];
    parkReviews[parkId]!.add({
      'user': user,
      'text': text,
      'rating': rating,
      'date': 'Только что',
    });
    _save();
  }

  void addTourReview(int tourId, String user, String text, int rating) {
    if (!tourReviews.containsKey(tourId)) tourReviews[tourId] = [];
    tourReviews[tourId]!.add({
      'user': user,
      'text': text,
      'rating': rating,
      'date': 'Только что',
    });
    _save();
  }
}
