/// Модели данных NatureHub.

class TestResult {
  final String courseId;
  final int correctAnswers;
  final int totalQuestions;
  final double percentage;
  final bool passed;
  final DateTime completedAt;

  TestResult({
    required this.courseId,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.percentage,
    required this.passed,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() => {
        'courseId': courseId,
        'correctAnswers': correctAnswers,
        'totalQuestions': totalQuestions,
        'percentage': percentage,
        'passed': passed,
        'completedAt': completedAt.toIso8601String(),
      };

  factory TestResult.fromMap(Map map) => TestResult(
        courseId: map['courseId'] as String,
        correctAnswers: map['correctAnswers'] as int,
        totalQuestions: map['totalQuestions'] as int,
        percentage: (map['percentage'] as num).toDouble(),
        passed: map['passed'] as bool,
        completedAt: DateTime.tryParse('${map['completedAt']}') ?? DateTime.now(),
      );
}

class Hashtag {
  final String tag;
  final String description;
  final String color;

  const Hashtag({
    required this.tag,
    required this.description,
    required this.color,
  });
}

/// Каталог достижений после прохождения курсов.
const availableHashtags = <String, Hashtag>{
  'survival': Hashtag(
    tag: '#незаблудившийся',
    description: 'Успешно прошел тест по выживанию в лесу',
    color: 'green',
  ),
  'fishing': Hashtag(
    tag: '#дикийрыбак',
    description: 'Прошел курс по дикой рыбалке',
    color: 'blue',
  ),
  'plants': Hashtag(
    tag: '#борецсборщивиками',
    description: 'Знает опасные растения',
    color: 'red',
  ),
  'eco': Hashtag(
    tag: '#экозащитник',
    description: 'Прошел курс по экологической безопасности',
    color: 'green',
  ),
};

class Question {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  Question({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });
}

/// Выбранный город для погоды (или null = геолокация).
class WeatherPlace {
  final String name;
  final double lat;
  final double lng;
  final bool useDeviceLocation;

  const WeatherPlace({
    required this.name,
    required this.lat,
    required this.lng,
    this.useDeviceLocation = false,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'lat': lat,
        'lng': lng,
        'useDeviceLocation': useDeviceLocation,
      };

  factory WeatherPlace.fromMap(Map map) => WeatherPlace(
        name: '${map['name']}',
        lat: (map['lat'] as num).toDouble(),
        lng: (map['lng'] as num).toDouble(),
        useDeviceLocation: map['useDeviceLocation'] == true,
      );

  static const moscow = WeatherPlace(name: 'Москва', lat: 55.751244, lng: 37.618423);
}
