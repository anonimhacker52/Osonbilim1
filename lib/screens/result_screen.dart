import 'package:flutter/material.dart';
import '../models/lesson.dart';
import 'menu_screen.dart';

class ResultScreen extends StatelessWidget {
  final int lessonNum;
  final int correct;
  final int total;
  final int xp;
  final LessonStory? story;

  const ResultScreen({
    super.key,
    required this.lessonNum,
    required this.correct,
    required this.total,
    required this.xp,
    required this.story,
  });

  void _goToMenu(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MenuScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                '🎉 $lessonNum-dars tugadi!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                "✅ To'g'ri: $correct/$total\n🏆 Ball: +$xp XP",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              if (story != null) ...[
                Text(
                  '📖 Kichik hikoya',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      story!.text,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                OutlinedButton(
                  onPressed: () => _goToMenu(context),
                  child: const Text("Hikoyani o'tkazib yuborish"),
                ),
                const SizedBox(height: 10),
              ],
              FilledButton(
                onPressed: () => _goToMenu(context),
                child: const Text('Asosiy menyu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
