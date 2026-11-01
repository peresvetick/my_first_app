import 'package:flutter/material.dart';
import 'package:my_first_app/app/theme/app_theme.dart';
import 'package:my_first_app/data/app_store.dart';
import 'package:my_first_app/data/models/models.dart';
import 'package:my_first_app/services/ai_guide_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Реальные обучающие ролики про выживание в лесу.
const survivalVideos = <Map<String, String>>[
  {
    'title': 'Basics of Wilderness Survival',
    'id': '6trGSIMI3Hc',
  },
  {
    'title': 'How to Survive in the Woods',
    'id': 'eC7xQ2H3dE0',
  },
  {
    'title': 'Lost in the Woods — What To Do',
    'id': 'R1vskie5kUc',
  },
];

class CourseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> category;

  const CourseDetailScreen({super.key, required this.category});

  void _openVideo(BuildContext context, String videoId, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CourseVideoScreen(videoId: videoId, title: title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category['title'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _openVideo(context, survivalVideos.first['id']!, survivalVideos.first['title']!),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: [Color(0xFF102A20), Color(0xFF1B5E3B)]),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.black.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                          child: const Icon(Icons.play_arrow_rounded, size: 48, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        const Text('Обучающее видео', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(survivalVideos.first['title']!, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Ещё ролики', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...survivalVideos.skip(1).map((v) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.ondemand_video, color: AppColors.forestMid),
                    title: Text(v['title']!),
                    trailing: const Icon(Icons.play_circle_outline),
                    onTap: () => _openVideo(context, v['id']!, v['title']!),
                  ),
                )),
            const SizedBox(height: 20),
            const Text('О курсе', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(category['description'], style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            Text('Пройдите тест. Для успешной сдачи нужно ≥80%.', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  final title = category['title'] as String;
                  final questions = AiGuideService().questionsForCourse(title);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => QuizScreen(questions: questions, courseTitle: title)),
                  );
                },
                icon: const Icon(Icons.quiz),
                label: const Text('Пройти тест'),
                style: ElevatedButton.styleFrom(backgroundColor: category['color'], foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseVideoScreen extends StatefulWidget {
  final String videoId;
  final String title;
  const CourseVideoScreen({super.key, required this.videoId, required this.title});

  @override
  State<CourseVideoScreen> createState() => _CourseVideoScreenState();
}

class _CourseVideoScreenState extends State<CourseVideoScreen> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        children: [
          YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Совет: после ролика пройдите тест курса.'),
          ),
        ],
      ),
    );
  }
}
class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});
  
  final List<Map<String, dynamic>> _categories = const [
    {
      'title': '🎣 Дикая рыбалка',
      'description': 'Как поймать рыбу в дикой природе',
      'icon': '🎣',
      'color': Colors.blue,
      'videoUrl': 'https://www.youtube.com/watch?v=example1',
    },
    {
      'title': '🌿 Опасные растения',
      'description': 'Как распознать борщевик и другие опасные растения',
      'icon': '🌿',
      'color': Colors.red,
      'videoUrl': 'https://www.youtube.com/watch?v=example2',
    },
    {
      'title': '🌍 Экологическая безопасность',
      'description': 'Как вести себя в природе и защищать экологию',
      'icon': '🌍',
      'color': Colors.green,
      'videoUrl': 'https://www.youtube.com/watch?v=example3',
    },
    {
      'title': '🧭 Что делать если заблудился',
      'description': 'Правила выживания в лесу',
      'icon': '🧭',
      'color': Colors.orange,
      'videoUrl': 'https://www.youtube.com/watch?v=example4',
    },
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Расширить кругозор'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final category = _categories[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseDetailScreen(category: category),
                ),
              ),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: category['color'].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(category['icon'], style: const TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category['description'],
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// 📖 ЭКРАН ДЕТАЛЕЙ КУРСА
// 📝 ЭКРАН ТЕСТА
class QuizScreen extends StatefulWidget {
  final List<Question> questions;
  final String courseTitle;
  
  const QuizScreen({
    super.key,
    required this.questions,
    required this.courseTitle,
  });
  
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Question> _shuffledQuestions;
  int _currentQuestionIndex = 0;
  Map<int, int> _userAnswers = {}; // questionIndex -> selectedOptionIndex
  bool _showResult = false;
  
  @override
  void initState() {
    super.initState();
    _shuffledQuestions = List.from(widget.questions)..shuffle();
  }
  
  void _selectAnswer(int optionIndex) {
    if (_userAnswers.containsKey(_currentQuestionIndex)) return;
    
    setState(() {
      _userAnswers[_currentQuestionIndex] = optionIndex;
    });
  }
  
  void _nextQuestion() {
    if (_currentQuestionIndex < _shuffledQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      final correctCount = _userAnswers.entries
          .where((e) => e.value == _shuffledQuestions[e.key].correctOptionIndex)
          .length;
      final score = correctCount / _shuffledQuestions.length;
      AppStore().saveTestResult(
        widget.courseTitle,
        correctCount,
        _shuffledQuestions.length,
      );
      // Явная выдача хештега при успешном тесте (≥80%)
      if (score >= 0.8) {
        final key = AppStore().hashtagKeyForCourse(widget.courseTitle);
        AppStore().addHashtag(key);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Получен хештег: ${availableHashtags[key]?.tag ?? key}')),
          );
        }
      }
      setState(() {
        _showResult = true;
      });
    }
  }
  
  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }
  
  double _calculateScore() {
    int correctAnswers = 0;
    _userAnswers.forEach((questionIndex, selectedOption) {
      if (selectedOption == _shuffledQuestions[questionIndex].correctOptionIndex) {
        correctAnswers++;
      }
    });
    return correctAnswers / _shuffledQuestions.length;
  }
  
  @override
  Widget build(BuildContext context) {
    if (_showResult) {
      return _buildResultScreen();
    }
    
    final currentQuestion = _shuffledQuestions[_currentQuestionIndex];
    final hasAnswered = _userAnswers.containsKey(_currentQuestionIndex);
    final selectedOption = _userAnswers[_currentQuestionIndex];
    final isCorrect = selectedOption == currentQuestion.correctOptionIndex;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Тест: ${widget.courseTitle}'),
      ),
      body: Column(
        children: [
          // Прогресс-бар
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _shuffledQuestions.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Вопрос ${_currentQuestionIndex + 1} из ${_shuffledQuestions.length}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Текст вопроса
                  Text(
                    currentQuestion.questionText,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  
                  // Варианты ответов
                  ...List.generate(currentQuestion.options.length, (index) {
                    final isSelected = selectedOption == index;
                    final isCorrectAnswer = index == currentQuestion.correctOptionIndex;
                    final showCorrectness = hasAnswered;
                    
                    Color? backgroundColor;
                    if (showCorrectness) {
                      if (isCorrectAnswer) {
                        backgroundColor = Colors.green[100];
                      } else if (isSelected && !isCorrectAnswer) {
                        backgroundColor = Colors.red[100];
                      }
                    } else if (isSelected) {
                      backgroundColor = Colors.blue[100];
                    }
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton(
                        onPressed: hasAnswered ? null : () => _selectAnswer(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: backgroundColor ?? Colors.white,
                          foregroundColor: Colors.black,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? Colors.blue : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          '${String.fromCharCode(65 + index)}. ${currentQuestion.options[index]}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    );
                  }),
                  
                  // Объяснение (показывается после ответа)
                  if (hasAnswered) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green[50] : Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCorrect ? Colors.green : Colors.orange,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.info,
                                color: isCorrect ? Colors.green : Colors.orange,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isCorrect ? 'Правильно!' : 'Объяснение:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isCorrect ? Colors.green[800] : Colors.orange[800],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentQuestion.explanation,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          

          // Кнопки навигации
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
            ),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousQuestion,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Назад'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: hasAnswered ? _nextQuestion : null,
                    icon: Icon(_currentQuestionIndex < _shuffledQuestions.length - 1 ? Icons.arrow_forward : Icons.check),
                    label: Text(_currentQuestionIndex < _shuffledQuestions.length - 1 ? 'Далее' : 'Завершить тест'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Экран результатов
  Widget _buildResultScreen() {
    final score = _calculateScore();
    final percentage = (score * 100).toInt();
    final isPassed = score >= 0.8;
    final correctCount = _userAnswers.entries.where((e) => e.value == _shuffledQuestions[e.key].correctOptionIndex).length;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Результаты теста'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Icon(
              isPassed ? Icons.celebration : Icons.sentiment_dissatisfied,
              size: 100,
              color: isPassed ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              isPassed ? 'Поздравляем!' : 'Тест не сдан',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isPassed ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isPassed ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isPassed ? Colors.green : Colors.red,
                  width: 3,
                ),
              ),
              child: Text(
                'Ваш результат: $percentage%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isPassed ? Colors.green[800] : Colors.red[800],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '$correctCount',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          Text('Правильно', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      Container(width: 1, height: 50, color: Colors.grey[300]),
                      Column(
                        children: [
                          Text(
                            '${_shuffledQuestions.length - correctCount}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                          Text('Неправильно', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      Container(width: 1, height: 50, color: Colors.grey[300]),
                      Column(
                        children: [
                          Text(
                            '${_shuffledQuestions.length}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Всего вопросов', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (isPassed)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Column(  // ← ← ← Просто Column, без const
  children: [
    const Icon(Icons.celebration, size: 48, color: Colors.amber),
    const SizedBox(height: 12),
    Text(  // ← ← ← Просто Text, без const
      'Тест успешно сдан! 🎉',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber[800]),
    ),
                    SizedBox(height: 8),
                    Text(
                      'Вы набрали более 80% и получаете хештег в профиль!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Column(  // ← ← ← Просто Column, без const
  children: [
    const Icon(Icons.celebration, size: 48, color: Colors.amber),
    const SizedBox(height: 12),
    Text(  // ← ← ← Просто Text, без const
      'Тест успешно сдан! 🎉',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[800]),
    ),
                    SizedBox(height: 8),
                    Text(
                      'Необходимо набрать минимум 80% для успешной сдачи. Попробуйте еще раз!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Вернуться к курсам
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Вернуться к курсам'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (!isPassed)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _shuffledQuestions.shuffle();
                      _currentQuestionIndex = 0;
                      _userAnswers.clear();
                      _showResult = false;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Пройти тест заново'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
