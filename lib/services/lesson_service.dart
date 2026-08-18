import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/lesson.dart';

class LessonService {
  Future<List<Lesson>> loadAllLessons() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);

    final lessonPaths = manifestMap.keys
        .where((path) => path.startsWith('assets/darslar/') && path.endsWith('.json'))
        .toList()
      ..sort();

    final lessons = <Lesson>[];
    for (final path in lessonPaths) {
      final content = await rootBundle.loadString(path);
      final Map<String, dynamic> json = jsonDecode(content);
      lessons.add(Lesson.fromJson(json));
    }
    return lessons;
  }
}
