
import 'dart:convert';

import 'package:flutter/services.dart';

import 'search_item.dart';

class SearchService {
  SearchService._();

  static final SearchService instance = SearchService._();

  static const String _quranPath = 'assets/data/quran-simple';
  static const String _pagesPath = 'assets/data/pages.json';

  static const List<String> surahNames = [
    'الفاتحة', 'البقرة', 'آل عمران', 'النساء', 'المائدة',
    'الأنعام', 'الأعراف', 'الأنفال', 'التوبة', 'يونس',
    'هود', 'يوسف', 'الرعد', 'إبراهيم', 'الحجر',
    'النحل', 'الإسراء', 'الكهف', 'مريم', 'طه',
    'الأنبياء', 'الحج', 'المؤمنون', 'النور', 'الفرقان',
    'الشعراء', 'النمل', 'القصص', 'العنكبوت', 'الروم',
    'لقمان', 'السجدة', 'الأحزاب', 'سبأ', 'فاطر',
    'يس', 'الصافات', 'ص', 'الزمر', 'غافر',
    'فصلت', 'الشورى', 'الزخرف', 'الدخان', 'الجاثية',
    'الأحقاف', 'محمد', 'الفتح', 'الحجرات', 'ق',
    'الذاريات', 'الطور', 'النجم', 'القمر', 'الرحمن',
    'الواقعة', 'الحديد', 'المجادلة', 'الحشر', 'الممتحنة',
    'الصف', 'الجمعة', 'المنافقون', 'التغابن', 'الطلاق',
    'التحريم', 'الملك', 'القلم', 'الحاقة', 'المعارج',
    'نوح', 'الجن', 'المزمل', 'المدثر', 'القيامة',
    'الإنسان', 'المرسلات', 'النبأ', 'النازعات', 'عبس',
    'التكوير', 'الانفطار', 'المطففين', 'الانشقاق', 'البروج',
    'الطارق', 'الأعلى', 'الغاشية', 'الفجر', 'البلد',
    'الشمس', 'الليل', 'الضحى', 'الشرح', 'التين',
    'العلق', 'القدر', 'البينة', 'الزلزلة', 'العاديات',
    'القارعة', 'التكاثر', 'العصر', 'الهمزة', 'الفيل',
    'قريش', 'الماعون', 'الكوثر', 'الكافرون', 'النصر',
    'المسد', 'الإخلاص', 'الفلق', 'الناس',
  ];

  List<Map<String, dynamic>>? _ayahs;
  List<Map<String, dynamic>>? _pages;

  Future<void> _load() async {
    if (_ayahs != null && _pages != null) return;

    final quranText = await rootBundle.loadString(_quranPath);
    final lines = quranText.split(RegExp(r'\r?\n'));
    final ayahs = <Map<String, dynamic>>[];

    for (final line in lines) {
      if (line.trim().isEmpty || line.trim().startsWith('#')) {
        continue;
      }

      final parts = line.split('|');
      if (parts.length != 3) continue;

      final surah = int.tryParse(parts[0].trim());
      final ayah = int.tryParse(parts[1].trim());

      if (surah == null || ayah == null) continue;

      ayahs.add({
        'surah': surah,
        'ayah': ayah,
        'text': parts[2].trim(),
      });
    }

    final pagesJson = await rootBundle.loadString(_pagesPath);
    final decoded = jsonDecode(pagesJson) as List<dynamic>;

    final pages = decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    _ayahs = ayahs;
    _pages = pages;
  }

  String _normalize(String value) {
    return value
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll('ـ', '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
  }

  int _pageForPosition(int surah, int ayah) {
    var pageNumber = 1;

    for (var i = 0; i < _pages!.length; i++) {
      final pageSurah = _pages![i]['sura'] as int;
      final pageAyah = _pages![i]['aya'] as int;

      if (pageSurah < surah ||
          (pageSurah == surah && pageAyah <= ayah)) {
        pageNumber =
            (_pages![i]['page'] as int?) ?? (i + 1);
      } else {
        break;
      }
    }

    return pageNumber;
  }

  Future<List<SearchItem>> search(
      String query, {
        SearchContentType? type,
        int limit = 100,
      }) async {
    await _load();

    final normalizedQuery = _normalize(query);

    if (normalizedQuery.isEmpty) return [];

    final results = <SearchItem>[];

    if (type == null || type == SearchContentType.quran) {
      // البحث في أسماء السور
      for (var i = 0; i < surahNames.length; i++) {
        final name = surahNames[i];

        if (_normalize(name).contains(normalizedQuery)) {
          results.add(
            SearchItem(
              id: 'surah_${i + 1}',
              title: 'سورة $name',
              subtitle: 'الانتقال إلى بداية السورة',
              type: SearchContentType.quran,
              surahNumber: i + 1,
              ayahNumber: 1,
              pageNumber: _pageForPosition(i + 1, 1),
            ),
          );
        }
      }

      // البحث في نصوص الآيات
      for (final item in _ayahs!) {
        final text = item['text'] as String;

        if (_normalize(text).contains(normalizedQuery)) {
          final surah = item['surah'] as int;
          final ayah = item['ayah'] as int;

          results.add(
            SearchItem(
              id: 'ayah_${surah}_$ayah',
              title: text,
              subtitle: 'سورة ${surahNames[surah - 1]}',
              reference: 'الآية $ayah',
              type: SearchContentType.quran,
              surahNumber: surah,
              ayahNumber: ayah,
              pageNumber: _pageForPosition(surah, ayah),
            ),
          );

          if (results.length >= limit) break;
        }
      }
    }

    return results.take(limit).toList();
  }
}
