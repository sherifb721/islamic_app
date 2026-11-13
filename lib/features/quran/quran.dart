
import 'package:flutter/services.dart';

class QuranService {
  static Future<List<Map<String, dynamic>>> loadQuran() async {
    try {
      final data = await rootBundle.loadString(
        'assets/data/quran-simple',
      );

      final lines = data.split(RegExp(r'\r?\n'));

      final List<Map<String, dynamic>> ayahs = [];

      for (final line in lines) {
        if (line.trim().isEmpty || line.trim().startsWith('#')) {
          continue;
        }

        final parts = line.split('|');

        if (parts.length != 3) {
          continue;
        }

        final surahNumber = int.tryParse(parts[0].trim());
        final ayahNumber = int.tryParse(parts[1].trim());

        if (surahNumber == null || ayahNumber == null) {
          continue;
        }

        ayahs.add({
          'surahNumber': surahNumber,
          'ayahNumber': ayahNumber,
          'text': parts[2].trim(),
        });
      }

      if (ayahs.isEmpty) {
        throw Exception('ملف القرآن فارغ أو تنسيقه غير صحيح');
      }

      return ayahs;
    } catch (e) {
      throw Exception('فشل تحميل القرآن: $e');
    }
  }
}
