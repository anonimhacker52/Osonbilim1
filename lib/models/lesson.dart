class Example {
  final String uz;
  final String en;

  Example({required this.uz, required this.en});

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      uz: json['uz'] as String? ?? '',
      en: json['en'] as String? ?? '',
    );
  }
}

class Word {
  final String uz;
  final String en;
  final List<Example> examples;

  Word({required this.uz, required this.en, required this.examples});

  factory Word.fromJson(Map<String, dynamic> json) {
    final examplesJson = json['examples'] as List<dynamic>? ?? [];
    return Word(
      uz: json['uz'] as String? ?? '',
      en: json['en'] as String? ?? '',
      examples: examplesJson
          .map((e) => Example.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LessonStory {
  final String text;

  LessonStory({required this.text});

  factory LessonStory.fromJson(Map<String, dynamic> json) {
    return LessonStory(text: json['text'] as String? ?? '');
  }
}

class Lesson {
  final String title;
  final List<Word> words;
  final LessonStory? story;

  Lesson({required this.title, required this.words, this.story});

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final wordsJson = json['words'] as List<dynamic>? ?? [];
    return Lesson(
      title: json['title'] as String? ?? '',
      words: wordsJson
          .map((w) => Word.fromJson(w as Map<String, dynamic>))
          .toList(),
      story: json['story'] != null
          ? LessonStory.fromJson(json['story'] as Map<String, dynamic>)
          : null,
    );
  }

  int get totalExamples =>
      words.fold(0, (sum, w) => sum + w.examples.length);
}
