import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_service.dart';
import 'result_screen.dart';

class LessonScreen extends StatefulWidget {
  final int lessonIndex;
  final List<Lesson> allLessons;
  final ProgressData progress;

  const LessonScreen({
    super.key,
    required this.lessonIndex,
    required this.allLessons,
    required this.progress,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _progressService = ProgressService();
  final _answerController = TextEditingController();

  late Lesson _lesson;
  int _currentWordIdx = 0;
  int _currentExampleIdx = 0;
  int _attempts = 0;
  int _correctCount = 0;
  int _xpEarned = 0;
  bool _showingWord = true;

  String _feedback = '';
  Color _feedbackColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _lesson = widget.allLessons[widget.lessonIndex];
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  double get _progressValue {
    final word = _lesson.words[_currentWordIdx];
    final wordProgress = _showingWord
        ? _currentWordIdx
        : _currentWordIdx + (_currentExampleIdx / word.examples.length);
    return (wordProgress / _lesson.words.length).clamp(0.0, 1.0);
  }

  String _cleanText(String text) {
    var result = text.toLowerCase();
    result = result.replaceAll(RegExp(r'[^\w\s]', unicode: true), '');
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();
    return result;
  }

  void _checkAnswer() {
    if (_showingWord) {
      setState(() {
        _showingWord = false;
        _currentExampleIdx = 0;
        _attempts = 0;
        _feedback = '';
        _answerController.clear();
      });
      return;
    }

    final word = _lesson.words[_currentWordIdx];
    final example = word.examples[_currentExampleIdx];
    final userAnswer = _answerController.text.trim();

    if (_cleanText(userAnswer) == _cleanText(example.en)) {
      final xp = _attempts == 0 ? 10 : (_attempts == 1 ? 5 : 2);
      setState(() {
        _correctCount++;
        _xpEarned += xp;
        _feedback = "✅ To'g'ri! +$xp XP";
        _feedbackColor = Colors.green.shade600;
      });
      Future.delayed(const Duration(milliseconds: 1200), _nextExample);
    } else {
      setState(() {
        _attempts++;
        if (_attempts >= 2) {
          _feedback = "❌ To'g'ri javob:\n${example.en}\nEndi shuni yozing:";
          _feedbackColor = Colors.red.shade600;
          _answerController.clear();
        } else {
          _feedback = "⚠️ Noto'g'ri, yana urinib ko'ring!";
          _feedbackColor = Colors.orange.shade700;
        }
      });
    }
  }

  void _nextExample() {
    if (!mounted) return;
    final word = _lesson.words[_currentWordIdx];

    if (_currentExampleIdx < word.examples.length - 1) {
      setState(() {
        _currentExampleIdx++;
        _attempts = 0;
        _feedback = '';
        _answerController.clear();
      });
    } else if (_currentWordIdx < _lesson.words.length - 1) {
      setState(() {
        _currentWordIdx++;
        _showingWord = true;
        _feedback = '';
        _answerController.clear();
      });
    } else {
      _finishLesson();
    }
  }

  void _nextButtonPressed() {
    if (_showingWord) {
      _checkAnswer();
    } else {
      _nextExample();
    }
  }

  Future<void> _finishLesson() async {
    final lessonNum = widget.lessonIndex + 1;
    final progress = widget.progress;

    if (!progress.completedLessons.contains(lessonNum)) {
      progress.completedLessons.add(lessonNum);
      progress.totalXp += _xpEarned;
      await _progressService.save(progress);
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          lessonNum: lessonNum,
          correct: _correctCount,
          total: _lesson.totalExamples,
          xp: _xpEarned,
          story: _lesson.story,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final word = _lesson.words[_currentWordIdx];

    late final String titleText;
    late final String mainText;
    late final String secondaryText;
    late final String promptText;

    if (_showingWord) {
      titleText =
          "${_lesson.title} - ${_currentWordIdx + 1}/${_lesson.words.length} so'z";
      mainText = word.uz;
      secondaryText = word.en;
      promptText = "Bu so'zni yodlab oling";
    } else {
      final example = word.examples[_currentExampleIdx];
      titleText =
          "${_lesson.title} - ${word.en} | ${_currentExampleIdx + 1}/${word.examples.length} misol";
      mainText = example.uz;
      secondaryText = '';
      promptText = 'Inglizcha tarjimasini yozing:';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dars'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              titleText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      mainText,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (secondaryText.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        secondaryText,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(promptText, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            TextField(
              controller: _answerController,
              enabled: !_showingWord,
              decoration: const InputDecoration(
                hintText: "Inglizcha tarjimasini yozing...",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                if (!_showingWord) _checkAnswer();
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: Text(
                _feedback,
                textAlign: TextAlign.center,
                style: TextStyle(color: _feedbackColor),
              ),
            ),
            LinearProgressIndicator(value: _progressValue),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _showingWord ? null : _checkAnswer,
                    child: const Text('Tekshirish'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _nextButtonPressed,
                    child: Text(_showingWord ? 'Tayyor, boshladik!' : 'Keyingi'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
