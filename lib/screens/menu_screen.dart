import 'package:flutter/material.dart';
import '../main.dart' show themeNotifier;
import '../models/lesson.dart';
import '../services/lesson_service.dart';
import '../services/progress_service.dart';
import 'lesson_screen.dart';
import 'info_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _lessonService = LessonService();
  final _progressService = ProgressService();

  List<Lesson> _lessons = [];
  ProgressData _progress = ProgressData.empty();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEverything();
  }

  Future<void> _loadEverything() async {
    final lessons = await _lessonService.loadAllLessons();
    final progress = await _progressService.load();
    setState(() {
      _lessons = lessons;
      _progress = progress;
      _loading = false;
    });
  }

  Future<void> _refreshProgress() async {
    final progress = await _progressService.load();
    setState(() => _progress = progress);
  }

  void _openLesson(int idx) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          lessonIndex: idx,
          allLessons: _lessons,
          progress: _progress,
        ),
      ),
    );
    _refreshProgress();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oson Bilim'),
        actions: [
          IconButton(
            icon: Icon(isLight ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              themeNotifier.value =
                  isLight ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InfoScreen()),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        '🏆 Jami ball: ${_progress.totalXp} XP',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _lessons.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Darslar topilmadi.\n'
                              'assets/darslar/ papkasiga *.json fayllar qo\'shing.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: _lessons.length,
                          itemBuilder: (context, idx) {
                            final lesson = _lessons[idx];
                            final lessonNum = idx + 1;
                            final isCompleted = _progress.completedLessons
                                .contains(lessonNum);

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              elevation: 3,
                              color: isCompleted
                                  ? Colors.green.shade600
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () => _openLesson(idx),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lesson.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: isCompleted
                                                  ? Colors.white
                                                  : null,
                                            ),
                                      ),
                                      Text(
                                        "${lesson.words.length} ta so'z",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: isCompleted
                                                  ? Colors.white70
                                                  : null,
                                            ),
                                      ),
                                      Text(
                                        isCompleted
                                            ? '✅ Tugatilgan'
                                            : '▶️ Boshlash',
                                        style: TextStyle(
                                          color: isCompleted
                                              ? Colors.white
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
