import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:my_first_app/data/models/models.dart';

/// Офлайн ИИ-гид: советы, вопросы тестов и порядок маршрута.
/// Позже сюда же можно подключить OpenAI/Gemini без смены UI.
class AiGuideService {
  final _rnd = Random();

  /// Собирает совет из блоков: безопасность / снаряжение / сезон / этика.
  String tipForCategory(String category) {
    final key = _normalizeCategory(category);
    final blocks = _tipBlocks[key] ?? _tipBlocks['default']!;
    final safety = blocks['safety']![_rnd.nextInt(blocks['safety']!.length)];
    final gear = blocks['gear']![_rnd.nextInt(blocks['gear']!.length)];
    final season = blocks['season']![_rnd.nextInt(blocks['season']!.length)];
    final ethic = blocks['ethic']![_rnd.nextInt(blocks['ethic']!.length)];
    return 'Совет ($category):\n• $safety\n• $gear\n• $season\n• $ethic';
  }

  /// Генерирует набор вопросов под тему курса.
  List<Question> questionsForCourse(String courseId, {int count = 8}) {
    final bank = _questionBankFor(courseId);
    final copy = List<Question>.from(bank)..shuffle(_rnd);
    if (copy.length <= count) return copy;
    return copy.take(count).toList();
  }

  /// Оптимальный порядок точек: ближайший сосед от старта.
  List<Map<String, dynamic>> orderPlaces(
    List<Map<String, dynamic>> places, {
    LatLng? start,
  }) {
    if (places.isEmpty) return [];
    final remaining = List<Map<String, dynamic>>.from(places);
    final ordered = <Map<String, dynamic>>[];
    var cursor = start ??
        LatLng(
          _asDouble(remaining.first['lat']) ?? 55.75,
          _asDouble(remaining.first['lng']) ?? 37.62,
        );
    final distance = const Distance();

    while (remaining.isNotEmpty) {
      remaining.sort((a, b) {
        final da = distance(
          cursor,
          LatLng(_asDouble(a['lat']) ?? cursor.latitude, _asDouble(a['lng']) ?? cursor.longitude),
        );
        final db = distance(
          cursor,
          LatLng(_asDouble(b['lat']) ?? cursor.latitude, _asDouble(b['lng']) ?? cursor.longitude),
        );
        return da.compareTo(db);
      });
      final next = remaining.removeAt(0);
      ordered.add(next);
      cursor = LatLng(
        _asDouble(next['lat']) ?? cursor.latitude,
        _asDouble(next['lng']) ?? cursor.longitude,
      );
    }
    return ordered;
  }

  /// Короткое текстовое объяснение маршрута.
  String routeNarrative(List<Map<String, dynamic>> ordered) {
    if (ordered.isEmpty) return 'Выберите места — построим удобный порядок маршрута.';
    final names = ordered.map((e) => e['name'] ?? e['title'] ?? 'точка').join(' → ');
    final kmHint = ordered.length <= 2 ? 'короткая прогулка' : (ordered.length <= 4 ? 'полудневный маршрут' : 'насыщенный день');
    return 'Рекомендуемый порядок: $names.\nЭто $kmHint. Между точками держитесь троп и берите воду.';
  }

  String _normalizeCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains('гриб')) return 'Грибы';
    if (c.contains('ягод')) return 'Ягоды';
    if (c.contains('рыб')) return 'Рыбалка';
    if (c.contains('опас')) return 'Опасно';
    if (c.contains('парк')) return 'Парк';
    if (c.contains('тур') || c.contains('поход')) return 'Тур';
    if (c.contains('магаз') || c.contains('спорт')) return 'Магазин';
    if (c.contains('красив')) return 'Красивое место';
    return category;
  }

  double? _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  List<Question> _questionBankFor(String courseId) {
    final id = courseId.toLowerCase();
    if (id.contains('рыбал')) return _fishingQuestions;
    if (id.contains('растен') || id.contains('борщев')) return _plantsQuestions;
    if (id.contains('эколог') || id.contains('безопасн')) return _ecoQuestions;
    return _survivalQuestions;
  }

  static const _tipBlocks = <String, Map<String, List<String>>>{
    'Грибы': {
      'safety': [
        'Берите только знакомые виды — при сомнении оставляйте гриб на месте',
        'Не собирайте у дорог и свалок: грибы накапливают токсины',
      ],
      'gear': [
        'Возьмите корзину (не пакет) и небольшой нож',
        'Пригодится компас/офлайн-карта и заряженный телефон',
      ],
      'season': [
        'Лучшее время — раннее утро после дождя',
        'В жару грибы портятся быстрее — обрабатывайте в тот же день',
      ],
      'ethic': [
        'Срезайте аккуратно, не разрывайте грибницу',
        'Не топчите подстилку — сохраните место для других',
      ],
    },
    'Ягоды': {
      'safety': [
        'Не ешьте незнакомые ягоды — даже одна может быть опасной',
        'Собирайте вдали от дорог и ЛЭП',
      ],
      'gear': ['Возьмите контейнер с крышкой и перчатки', 'Полезны репеллент и вода'],
      'season': ['После дождя ягоды чище и сочнее', 'В полдень ягоды быстрее мнутся — собирайте утром'],
      'ethic': ['Оставляйте часть ягод птицам и зверям', 'Не ломайте ветки кустов'],
    },
    'Рыбалка': {
      'safety': ['Проверьте правила и лицензию региона', 'На берегу следите за скользкими камнями'],
      'gear': ['Подсак спасёт улов', 'Возьмите запас лески и тёплую одежду'],
      'season': ['Клёв часто лучше на рассвете и закате', 'В жару рыба уходит глубже'],
      'ethic': ['Соблюдайте тишину и чистоту берега', 'Отпускайте мелочь по правилам'],
    },
    'Красивое место': {
      'safety': ['Не подходите к обрывам без страховки', 'Сообщите близким маршрут'],
      'gear': ['Пауэрбанк и запас воды обязательны', 'Удобная обувь для троп'],
      'season': ['Золотой час — за час до заката', 'После дождя тропы скользкие'],
      'ethic': ['Унесите весь мусор с собой', 'Не шумите в тихих зонах'],
    },
    'Опасно': {
      'safety': ['Не заходите в зону без подготовки', 'Держите аптечку и запасной канал связи'],
      'gear': ['Фонарь, свисток, тёплый слой', 'Офлайн-карта местности'],
      'season': ['Погода меняется быстро — следите за прогнозом', 'В сумерках риск выше'],
      'ethic': ['Не зовите других в опасную зону без опыта', 'Сообщайте властям о реальной угрозе'],
    },
    'Парк': {
      'safety': ['Смотрите под ноги на корнях и мокрых дорожках', 'В жару пейте воду чаще'],
      'gear': ['Удобные кроссовки и бутылка воды', 'Лёгкий дождевик не помешает'],
      'season': ['Утром меньше людей и свежее воздух', 'Вечером берите фонарик'],
      'ethic': ['Держите собак на поводке где нужно', 'Не сходите с размеченных троп'],
    },
    'Тур': {
      'safety': ['Сообщите маршрут и ETA близким', 'Проверьте аптечку и связь'],
      'gear': ['Палатка, спальник, горелка — тест до выхода', '2 литра воды на человека в день'],
      'season': ['Учитывайте светлый день и ночную температуру', 'В межсезонье берите запасной слой'],
      'ethic': ['Leave No Trace: лагерь как не было', 'Не рубите живые деревья'],
    },
    'Магазин': {
      'safety': ['Проверьте часы работы в праздники', 'Храните чек на гарантийные товары'],
      'gear': ['Список снаряжения экономит импульсивные покупки', 'Сравните вес рюкзака до кассы'],
      'season': ['Перед сезоном бывают акции на outdoor', 'Зимой уточняйте наличие размеров'],
      'ethic': ['Поддерживайте локальных продавцов снаряжения', 'Не оставляйте мусор у входа'],
    },
    'default': {
      'safety': ['Ориентируйтесь на местности и берегите себя', 'Следите за погодой'],
      'gear': ['Вода, связь, удобная обувь', 'Лёгкий перекус и фонарик'],
      'season': ['Подстройте план под светлый день', 'Одевайтесь слоями'],
      'ethic': ['Берегите природу для других', 'Уносите мусор с собой'],
    },
  };

  static final _survivalQuestions = <Question>[
    Question(
      questionText: 'Что сделать первым, если поняли, что заблудились в лесу?',
      options: ['Бежать наугад', 'Остановиться, успокоиться, отметить ориентиры', 'Кричать без паузы час', 'Выбросить тяжёлый рюкзак'],
      correctOptionIndex: 1,
      explanation: 'Паника тратит силы. Стоп — оценка — план.',
    ),
    Question(
      questionText: 'Какой минимум воды брать в летний однодневный выход?',
      options: ['100 мл', 'Около 2 литров на человека', 'Только термос чая', 'Пить из любой лужи'],
      correctOptionIndex: 1,
      explanation: 'Ориентир — около 2 л, больше в жару.',
    ),
    Question(
      questionText: 'Лучший способ сообщить о себе спасателям по телефону?',
      options: ['Коротко: где вы, сколько людей, что случилось', 'Долго рассказывать биографию', 'Сразу выключить телефон', 'Писать только SMS стикерами'],
      correctOptionIndex: 0,
      explanation: 'Чёткие факты помогают быстрее найти вас.',
    ),
    Question(
      questionText: 'Зачем нужен свисток в походе?',
      options: ['Только для собак', 'Сигнал помощи без потери голоса', 'Украшение рюкзака', 'Отпугивать облака'],
      correctOptionIndex: 1,
      explanation: 'Свисток слышен дальше и экономит силы.',
    ),
    Question(
      questionText: 'Где безопаснее разводить костёр?',
      options: ['Под кронами елей', 'На подготовленной площадке вдали от сухой травы', 'В палатке', 'На торфянике'],
      correctOptionIndex: 1,
      explanation: 'Контроль огня и чистая площадка критичны.',
    ),
    Question(
      questionText: 'Что помогает согреться при остановке на холоде?',
      options: ['Сидеть неподвижно мокрым', 'Движение мышц + сухой слой одежды', 'Снять куртку', 'Пить снег горстями'],
      correctOptionIndex: 1,
      explanation: 'Активность и сухость дают тепло.',
    ),
    Question(
      questionText: 'Как экономить батарею телефона в холоде?',
      options: ['Держать у тела, режим энергосбережения', 'Снимать видео 4K', 'Оставить на снегу', 'Включить фонарик на всю ночь'],
      correctOptionIndex: 0,
      explanation: 'Тепло и редкие включения берегут заряд.',
    ),
    Question(
      questionText: 'Признак надёжного дневного ориентира?',
      options: ['Случайный пень', 'Река, ЛЭП, дорога — линейные объекты', 'Туман', 'Чужой рюкзак'],
      correctOptionIndex: 1,
      explanation: 'Линейные ориентиры легче держать в уме.',
    ),
  ];

  static final _fishingQuestions = <Question>[
    Question(
      questionText: 'Почему важна тишина на берегу?',
      options: ['Чтобы не разбудить деревья', 'Рыба чувствительна к вибрациям и шуму', 'Так требует этикет кафе', 'Тишина греет воду'],
      correctOptionIndex: 1,
      explanation: 'Шум и топот отпугивают рыбу у берега.',
    ),
    Question(
      questionText: 'Зачем подсак?',
      options: ['Носить бутерброды', 'Безопасно взять рыбу у берега', 'Мерить глубину', 'Сушить носки'],
      correctOptionIndex: 1,
      explanation: 'Подсак снижает сходы и травмы рыбы.',
    ),
    Question(
      questionText: 'Когда часто лучше клёв?',
      options: ['Только в полдень', 'Рассвет и вечерние часы', 'Только в грозу в лодке', 'Никогда'],
      correctOptionIndex: 1,
      explanation: 'Сумерки и утро обычно активнее.',
    ),
    Question(
      questionText: 'Что проверить перед рыбалкой?',
      options: ['Только мем в чате', 'Правила региона и лицензию', 'Цвет машины соседа', 'Курс акций'],
      correctOptionIndex: 1,
      explanation: 'Соблюдение правил — обязанность рыболова.',
    ),
    Question(
      questionText: 'Как обращаться с мелкой рыбой?',
      options: ['Оставлять на солнце', 'Отпускать по правилам аккуратно', 'Кидать в кусты', 'Красить'],
      correctOptionIndex: 1,
      explanation: 'Бережное отпускание сохраняет популяцию.',
    ),
    Question(
      questionText: 'Безопасность на мокрых камнях?',
      options: ['Бегать босиком', 'Осторожный шаг и нескользящая обувь', 'Прыжки с удилищем', 'Закрыть глаза'],
      correctOptionIndex: 1,
      explanation: 'Скользкий берег — частая травма.',
    ),
    Question(
      questionText: 'Что взять от насекомых у воды?',
      options: ['Только духи', 'Репеллент и закрытую одежду', 'Металлическую сеть на голову всегда', 'Ничего'],
      correctOptionIndex: 1,
      explanation: 'Мошка и комары у воды активны.',
    ),
    Question(
      questionText: 'Этика берега?',
      options: ['Оставить леску и пакеты', 'Убрать мусор и остатки снастей', 'Ломать камыши для селфи', 'Музыка на максимум'],
      correctOptionIndex: 1,
      explanation: 'Чистый берег — правило хорошего тона.',
    ),
  ];

  static final _plantsQuestions = <Question>[
    Question(
      questionText: 'Главное правило незнакомого растения?',
      options: ['Съесть немного', 'Не пробовать и не трогать без знания', 'Сварить всегда безопасно', 'Дать ребёнку'],
      correctOptionIndex: 1,
      explanation: 'Ошибка с растением может быть тяжёлой.',
    ),
    Question(
      questionText: 'Борщевик опасен чем?',
      options: ['Только запахом', 'Соком, вызывающим ожоги на солнце', 'Тем, что вкусный', 'Темнотой листьев'],
      correctOptionIndex: 1,
      explanation: 'Фототоксичный сок + солнце = ожог.',
    ),
    Question(
      questionText: 'Что делать при контакте с соком борщевика?',
      options: ['Загорать', 'Промыть, закрыть от солнца, при необходимости к врачу', 'Натереть землёй', 'Игнорировать'],
      correctOptionIndex: 1,
      explanation: 'Смывание и защита от UV снижают ущерб.',
    ),
    Question(
      questionText: 'Где чаще растёт борщевик?',
      options: ['Только в пустыне', 'Пустыри, обочины, заросли у дорог', 'Только в квартире', 'На дне озера'],
      correctOptionIndex: 1,
      explanation: 'Любит нарушенные открытые места.',
    ),
    Question(
      questionText: 'Как собирать знакомые съедобные растения?',
      options: ['Вырывать с корнем всё поле', 'Брать умеренно, оставляя часть популяции', 'Травить химией', 'Топтать'],
      correctOptionIndex: 1,
      explanation: 'Устойчивый сбор сохраняет место.',
    ),
    Question(
      questionText: 'Перчатки нужны когда?',
      options: ['Никогда', 'При работе с потенциально едкими растениями', 'Только зимой дома', 'Для селфи'],
      correctOptionIndex: 1,
      explanation: 'Барьер защищает кожу.',
    ),
    Question(
      questionText: 'Можно ли ориентироваться только на цвет ягоды?',
      options: ['Да, красные всегда ок', 'Нет, цвет не гарантия съедобности', 'Да, чёрные всегда яд', 'Да, по TikTok'],
      correctOptionIndex: 1,
      explanation: 'Нужна точная идентификация вида.',
    ),
    Question(
      questionText: 'Детям у борщевика?',
      options: ['Играть в зарослях', 'Держать подальше и объяснять опасность', 'Дать срезать стебель', 'Смазать соком'],
      correctOptionIndex: 1,
      explanation: 'Дети особенно уязвимы к ожогам.',
    ),
  ];

  static final _ecoQuestions = <Question>[
    Question(
      questionText: 'Принцип Leave No Trace?',
      options: ['Оставить следы для Instagram', 'Не оставлять мусор и не портить природу', 'Жечь всё пластиковое', 'Кормить всех зверей хлебом'],
      correctOptionIndex: 1,
      explanation: 'Минимум следов — максимум уважения.',
    ),
    Question(
      questionText: 'Куда девать мусор в походе?',
      options: ['Закопать батарейки', 'Унести с собой', 'Кинуть в ручей', 'Спрятать под мох'],
      correctOptionIndex: 1,
      explanation: 'Всё, что принесли — уносите.',
    ),
    Question(
      questionText: 'Почему нельзя кормить диких животных?',
      options: ['Они слишком вежливые', 'Меняет поведение и вредит здоровью', 'Закон требует кормить', 'Так быстрее растут'],
      correctOptionIndex: 1,
      explanation: 'Прикорм делает животных зависимыми и опасными.',
    ),
    Question(
      questionText: 'Лучший костёр с точки зрения экологии?',
      options: ['Огромный всю ночь', 'Минимальный, на готовой площадке, полностью погашенный', 'Из живых деревьев', 'На торфе без контроля'],
      correctOptionIndex: 1,
      explanation: 'Контроль и минимум топлива.',
    ),
    Question(
      questionText: 'Мыть посуду у реки?',
      options: ['С пеной прямо в воде', 'В стороне, без химии в поток', 'Стирать маслом', 'Не мыть никогда'],
      correctOptionIndex: 1,
      explanation: 'Берегите водоём от загрязнения.',
    ),
    Question(
      questionText: 'Шум в ООПТ?',
      options: ['Колонки на полную', 'Соблюдать тишину и правила территории', 'Фейерверки', 'Гонки на квадроциклах везде'],
      correctOptionIndex: 1,
      explanation: 'Режим ООПТ защищает природу и людей.',
    ),
    Question(
      questionText: 'Одноразовый пластик в походе?',
      options: ['Чем больше, тем лучше', 'Минимизировать и уносить', 'Сжигать в палатке', 'Дарить зверям'],
      correctOptionIndex: 1,
      explanation: 'Меньше пластика — меньше вреда.',
    ),
    Question(
      questionText: 'Зачем сообщать о свалке в лесу?',
      options: ['Для лайков только', 'Чтобы службы или волонтёры могли убрать', 'Чтобы напугать туристов', 'Незачем'],
      correctOptionIndex: 1,
      explanation: 'Гражданская позиция помогает территории.',
    ),
  ];
}
