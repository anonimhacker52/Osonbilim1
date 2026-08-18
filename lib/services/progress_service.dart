import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressData {
  List<int> completedLessons;
  int totalXp;

  ProgressData({required this.completedLessons, required this.totalXp});

  factory ProgressData.empty() =>
      ProgressData(completedLessons: [], totalXp: 0);

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    return ProgressData(
      completedLessons:
          (json['completed_lessons'] as List<dynamic>? ?? [])
              .map((e) => e as int)
              .toList(),
      totalXp: json['total_xp'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'completed_lessons': completedLessons,
        'total_xp': totalXp,
      };
}

class ProgressService {
  static const _storageKey = 'osonbilim_progress';

  Future<ProgressData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return ProgressData.empty();
    try {
      return ProgressData.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return ProgressData.empty();
    }
  }

  Future<void> save(ProgressData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(data.toJson()));
  }
}
