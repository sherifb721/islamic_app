import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islamic_app/core/theme/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SurahScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final int totalAyahs;
  final String revelationType;

  const SurahScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.totalAyahs,
    required this.revelationType,
  });

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _Ayah {
  final int surah;
  final int number;
  final String text;

  const _Ayah({
    required this.surah,
    required this.number,
    required this.text,
  });
}

class _ReaderData {
  final List<Map<String, dynamic>> pages;
  final List<List<_Ayah>> pageAyahs;
  final Map<int, int> surahAyahCounts;
  final int initialPageIndex;

  const _ReaderData({
    required this.pages,
    required this.pageAyahs,
    required this.surahAyahCounts,
    required this.initialPageIndex,
  });
}

class _Segment {
  final int? surah;
  final bool showBasmala;
  final bool showTitle;
  final List<_Ayah> ayahs;

  const _Segment._({
    this.surah,
    this.showBasmala = false,
    this.showTitle = false,
    this.ayahs = const [],
  });

  factory _Segment.text(List<_Ayah> ayahs) => _Segment._(ayahs: ayahs);

  factory _Segment.heading(int surah, bool showBasmala, bool showTitle) {
    return _Segment._(
      surah: surah,
      showBasmala: showBasmala,
      showTitle: showTitle,
    );
  }
}

class _SurahScreenState extends State<SurahScreen> {
  static const Color goldColor = Color(0xFFD9B66D);
  static const Color inkColor = Color(0xFF30220D);
  static const Color markerFill = Color(0xFF0F4A3A);
  static const Color jalalaColor = Color(0xFFB3261E);
  static const String lastPageKey = 'last_reading_page';
  static const String bookmarkPageKey = 'quran_bookmark_page';

  static const String quranFontFamily = 'serif';
  static const double minAyahFontSize = 10;
  static const double maxAyahFontSize = 32;

  static const double frameAspect = 1024 / 1536;
  static const double maxFrameStretch = 1.12;

  static const double contentTop = 0.17;
  static const double contentSide = 0.12;
  static const double contentBottom = 0.14;

  static const List<double> leftPillSlot = [0.128, 0.317, 0.025, 0.064];
  static const List<double> centerPillSlot = [0.441, 0.558, 0.025, 0.064];
  static const List<double> rightPillSlot = [0.682, 0.871, 0.025, 0.064];
  static const List<double> titleSlot = [0.265, 0.733, 0.083, 0.146];
  static const List<double> bottomSlot = [0.441, 0.559, 0.910, 0.955];

  static const double titleLineHeight = 1.6;
  static const double titleVerticalSpace = 24;
  static const double basmalaScale = 1.1;
  static const double basmalaLineHeight = 1.7;
  static const double basmalaVerticalSpace = 12;
  static const double markerScale = 1.35;

  static const TextStyle ayahStyle = TextStyle(
    color: Color(0xFF21190F),
    fontSize: 24,
    height: 1.6,
    fontWeight: FontWeight.w400,
    fontFamily: quranFontFamily,
  );

  late Future<_ReaderData> readerFuture;

  PageController? pageController;

  int currentPage = 1;
  int? bookmarkedPage;

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

  static const List<List<int>> juzStarts = [
    [1, 1],
    [2, 142],
    [2, 253],
    [3, 93],
    [4, 24],
    [4, 148],
    [5, 82],
    [6, 111],
    [7, 88],
    [8, 41],
    [9, 93],
    [11, 6],
    [12, 53],
    [15, 1],
    [17, 1],
    [18, 75],
    [21, 1],
    [23, 1],
    [25, 21],
    [27, 56],
    [29, 46],
    [33, 31],
    [36, 28],
    [39, 32],
    [41, 47],
    [46, 1],
    [51, 31],
    [58, 1],
    [67, 1],
    [78, 1],
  ];

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    readerFuture = _loadReader();
    _loadBookmark();
  }

  Future<_ReaderData> _loadReader() async {
    final pagesJson = await rootBundle.loadString(
      'assets/data/pages.json',
    );

    final quranText = await rootBundle.loadString(
      'assets/data/quran-simple',
    );

    final decodedPages = jsonDecode(pagesJson) as List<dynamic>;

    final pages = decodedPages.map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();

    if (pages.length != 604) {
      throw Exception('عدد صفحات المصحف غير صحيح');
    }

    final List<_Ayah> allAyahs = [];
    final Map<int, int> surahAyahCounts = {};

    for (final line in const LineSplitter().convert(quranText)) {
      final trimmedLine = line.trim();

      if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) {
        continue;
      }

      final parts = trimmedLine.split('|');

      if (parts.length < 3) continue;

      final surah = int.tryParse(parts[0].trim());
      final ayah = int.tryParse(parts[1].trim());
      final text = parts.sublist(2).join('|').trim();

      if (surah == null || ayah == null || text.isEmpty) {
        continue;
      }

      allAyahs.add(
        _Ayah(
          surah: surah,
          number: ayah,
          text: text,
        ),
      );

      final previousCount = surahAyahCounts[surah] ?? 0;

      if (ayah > previousCount) {
        surahAyahCounts[surah] = ayah;
      }
    }

    if (allAyahs.isEmpty) {
      throw Exception('ملف القرآن فارغ أو لم تتم قراءته بشكل صحيح');
    }

    final List<int> pageStartIndexes = [];

    for (final page in pages) {
      final surah = page['sura'] as int;
      final ayah = page['aya'] as int;

      final index = allAyahs.indexWhere(
            (item) => item.surah == surah && item.number == ayah,
      );

      if (index == -1) {
        throw Exception(
          'لم يتم العثور على بداية الصفحة ${page['page']}',
        );
      }

      pageStartIndexes.add(index);
    }

    final List<List<_Ayah>> pageAyahs = [];

    for (int i = 0; i < pages.length; i++) {
      final startIndex = pageStartIndexes[i];

      final endIndex = i + 1 < pages.length
          ? pageStartIndexes[i + 1]
          : allAyahs.length;

      if (endIndex <= startIndex) {
        throw Exception('حدث خطأ في ترتيب صفحات المصحف');
      }

      pageAyahs.add(
        allAyahs.sublist(startIndex, endIndex),
      );
    }

    final initialPageIndex = await _findInitialPage(pages);

    return _ReaderData(
      pages: pages,
      pageAyahs: pageAyahs,
      surahAyahCounts: surahAyahCounts,
      initialPageIndex: initialPageIndex,
    );
  }

  Future<int> _findInitialPage(
      List<Map<String, dynamic>> pages,
      ) async {
    int result = 0;

    for (int i = 0; i < pages.length; i++) {
      final pageSurah = pages[i]['sura'] as int;
      final pageAyah = pages[i]['aya'] as int;

      if (_comparePosition(
        pageSurah,
        pageAyah,
        widget.surahNumber,
        1,
      ) <=
          0) {
        result = i;
      } else {
        break;
      }
    }

    return result;
  }

  Future<void> _loadBookmark() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      bookmarkedPage = prefs.getInt(bookmarkPageKey);
    });
  }

  int _comparePosition(
      int surah1,
      int ayah1,
      int surah2,
      int ayah2,
      ) {
    if (surah1 != surah2) {
      return surah1.compareTo(surah2);
    }

    return ayah1.compareTo(ayah2);
  }

  String _arabicNumber(int number) {
    const digits = [
      '٠', '١', '٢', '٣', '٤',
      '٥', '٦', '٧', '٨', '٩',
    ];

    return number.toString().split('').map((digit) {
      return digits[int.parse(digit)];
    }).join();
  }

  int _getCurrentJuz(Map<String, dynamic> pageData) {
    final surah = pageData['sura'] as int;
    final ayah = pageData['aya'] as int;

    int juz = 1;

    for (int i = 0; i < juzStarts.length; i++) {
      final start = juzStarts[i];

      if (_comparePosition(
        surah,
        ayah,
        start[0],
        start[1],
      ) >=
          0) {
        juz = i + 1;
      } else {
        break;
      }
    }

    return juz;
  }

  String _stripMarks(String value) {
    return value
        .replaceAll(RegExp(r'[\u0640\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll('ٱ', 'ا');
  }

  static const Set<String> jalalaForms = {
    'الله',
    'لله',
    'والله',
    'بالله',
    'فالله',
    'تالله',
    'ولله',
    'فلله',
    'اللهم',
  };

  bool _isJalala(String word) {
    return jalalaForms.contains(_stripMarks(word));
  }

  String _ayahTextWithoutBasmala(_Ayah ayah) {
    if (ayah.number != 1 || ayah.surah == 1 || ayah.surah == 9) {
      return ayah.text;
    }

    final words = ayah.text.split(RegExp(r'\s+'));

    if (words.length > 4 && _stripMarks(words.first) == 'بسم') {
      return words.sublist(4).join(' ');
    }

    return ayah.text;
  }

  Future<void> _saveLastPage(
      int page,
      List<Map<String, dynamic>> pages,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final pageData = pages[page - 1];

    await prefs.setInt(lastPageKey, page);

    await prefs.setInt(
      'last_reading_surah',
      pageData['sura'] as int,
    );

    await prefs.setInt(
      'last_reading_ayah',
      pageData['aya'] as int,
    );
  }

  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();

    if (bookmarkedPage == currentPage) {
      await prefs.remove(bookmarkPageKey);

      if (!mounted) return;

      setState(() {
        bookmarkedPage = null;
      });

      _showMessage('تم إلغاء العلامة المرجعية');
    } else {
      await prefs.setInt(bookmarkPageKey, currentPage);

      if (!mounted) return;

      setState(() {
        bookmarkedPage = currentPage;
      });

      _showMessage('تم حفظ العلامة المرجعية');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        backgroundColor: AppColor.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showSearchDialog(_ReaderData data) async {
    final surahController = TextEditingController(
      text: widget.surahNumber.toString(),
    );

    final ayahController = TextEditingController(text: '1');

    final result = await showDialog<List<int>>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColor.primaryGreen,
            title: const Text(
              'الانتقال إلى آية',
              style: TextStyle(
                color: AppColor.lightGold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: surahController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: AppColor.primaryText,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'رقم السورة',
                    labelStyle: TextStyle(
                      color: AppColor.secondaryText,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ayahController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: AppColor.primaryText,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'رقم الآية',
                    labelStyle: TextStyle(
                      color: AppColor.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text(
                  'إلغاء',
                  style: TextStyle(
                    color: AppColor.secondaryText,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  final surah = int.tryParse(
                    surahController.text.trim(),
                  );

                  final ayah = int.tryParse(
                    ayahController.text.trim(),
                  );

                  if (surah == null ||
                      ayah == null ||
                      surah < 1 ||
                      surah > 114 ||
                      ayah < 1) {
                    return;
                  }

                  final maxAyahs = data.surahAyahCounts[surah];

                  if (maxAyahs == null || ayah > maxAyahs) {
                    return;
                  }

                  Navigator.pop(
                    dialogContext,
                    [surah, ayah],
                  );
                },
                child: const Text(
                  'انتقال',
                  style: TextStyle(
                    color: AppColor.lightGold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    surahController.dispose();
    ayahController.dispose();

    if (result == null || !mounted) return;

    final targetSurah = result[0];
    final targetAyah = result[1];

    int targetPageIndex = -1;

    for (int i = 0; i < data.pages.length; i++) {
      final pageSurah = data.pages[i]['sura'] as int;
      final pageAyah = data.pages[i]['aya'] as int;

      if (_comparePosition(
        pageSurah,
        pageAyah,
        targetSurah,
        targetAyah,
      ) <=
          0) {
        targetPageIndex = i;
      } else {
        break;
      }
    }

    if (targetPageIndex < 0) return;

    pageController?.animateToPage(
      targetPageIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildAyahMarker(int number, double size) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: markerFill,
        border: Border.all(
          color: goldColor,
          width: 1.6,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.16),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _arabicNumber(number),
            style: const TextStyle(
              color: AppColor.lightGold,
              fontSize: 16,
              height: 1.1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahTitle(int surah, double fontSize) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: goldColor.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: goldColor,
          width: 1.4,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'سُورَةُ ${surahNames[surah - 1]}',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: inkColor,
            fontSize: fontSize,
            height: titleLineHeight,
            fontWeight: FontWeight.bold,
            fontFamily: quranFontFamily,
          ),
        ),
      ),
    );
  }

  Widget _buildDiamond() {
    return SizedBox(
      width: 22,
      height: 22,
      child: Center(
        child: Transform.rotate(
          angle: 0.785398,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: markerFill,
              border: Border.all(
                color: goldColor,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: goldColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasmalaLine({required bool fadeLeft}) {
    return Container(
      height: 1.6,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: fadeLeft
              ? [goldColor.withOpacity(0.15), goldColor]
              : [goldColor, goldColor.withOpacity(0.15)],
        ),
      ),
    );
  }

  Widget _buildBasmala(double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                _buildDiamond(),
                const SizedBox(width: 6),
                Expanded(child: _buildBasmalaLine(fadeLeft: true)),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.7,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: const Color(0xFF21190F),
                        fontSize: fontSize * basmalaScale,
                        height: basmalaLineHeight,
                        fontWeight: FontWeight.w400,
                        fontFamily: quranFontFamily,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: _buildBasmalaLine(fadeLeft: false)),
                const SizedBox(width: 6),
                _buildDiamond(),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_Segment> _buildSegments(List<_Ayah> ayahs) {
    final segments = <_Segment>[];
    var current = <_Ayah>[];

    void flush() {
      if (current.isEmpty) return;
      segments.add(_Segment.text(current));
      current = <_Ayah>[];
    }

    for (final ayah in ayahs) {
      if (ayah.number == 1) {
        flush();

        segments.add(
          _Segment.heading(
            ayah.surah,
            ayah.surah != 1 && ayah.surah != 9,
            segments.isNotEmpty,
          ),
        );
      }

      current.add(ayah);
    }

    flush();

    return segments;
  }

  List<InlineSpan> _buildAyahSpans(List<_Ayah> ayahs, double fontSize) {
    final spans = <InlineSpan>[];

    for (final ayah in ayahs) {
      for (final word
      in _ayahTextWithoutBasmala(ayah).split(RegExp(r'\s+'))) {
        if (word.isEmpty) continue;

        spans.add(
          TextSpan(
            text: '$word ',
            style: _isJalala(word)
                ? const TextStyle(color: jalalaColor)
                : null,
          ),
        );
      }

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _buildAyahMarker(ayah.number, fontSize * markerScale),
        ),
      );

      spans.add(const TextSpan(text: ' '));
    }

    return spans;
  }

  double _measureContentHeight(
      List<_Segment> segments,
      double width,
      double fontSize,
      ) {
    double total = 0;

    for (final segment in segments) {
      if (segment.surah != null) {
        if (segment.showTitle) {
          total += fontSize * titleLineHeight + titleVerticalSpace;
        }

        if (segment.showBasmala) {
          total += fontSize * basmalaScale * basmalaLineHeight +
              basmalaVerticalSpace;
        }

        continue;
      }

      final markerSize = fontSize * markerScale;

      final painter = TextPainter(
        text: TextSpan(
          style: ayahStyle.copyWith(fontSize: fontSize),
          children: _buildAyahSpans(segment.ayahs, fontSize),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.justify,
      );

      painter.setPlaceholderDimensions(
        List.filled(
          segment.ayahs.length,
          PlaceholderDimensions(
            size: Size(markerSize + 6, markerSize),
            alignment: PlaceholderAlignment.middle,
          ),
        ),
      );

      painter.layout(maxWidth: width);
      total += painter.height;
      painter.dispose();
    }

    return total;
  }

  double _fitFontSize(
      List<_Segment> segments,
      double width,
      double height,
      ) {
    double low = minAyahFontSize;
    double high = maxAyahFontSize;

    if (_measureContentHeight(segments, width, low) >= height) {
      return low;
    }

    if (_measureContentHeight(segments, width, high) <= height) {
      return high;
    }

    for (int i = 0; i < 10; i++) {
      final mid = (low + high) / 2;

      if (_measureContentHeight(segments, width, mid) <= height) {
        low = mid;
      } else {
        high = mid;
      }
    }

    return low;
  }

  Widget _buildAyahContent({
    required List<_Ayah> ayahs,
    required double areaWidth,
    required double areaHeight,
    required bool centered,
  }) {
    final segments = _buildSegments(ayahs);
    final fontSize = _fitFontSize(segments, areaWidth, areaHeight);
    final blocks = <Widget>[];

    for (final segment in segments) {
      if (segment.surah != null) {
        if (segment.showTitle) {
          blocks.add(_buildSurahTitle(segment.surah!, fontSize));
        }

        if (segment.showBasmala) {
          blocks.add(_buildBasmala(fontSize));
        }
      } else {
        blocks.add(
          Text.rich(
            TextSpan(children: _buildAyahSpans(segment.ayahs, fontSize)),
            textAlign: TextAlign.justify,
            textDirection: TextDirection.rtl,
            style: ayahStyle.copyWith(fontSize: fontSize),
          ),
        );
      }
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: centered ? Alignment.center : Alignment.topCenter,
        child: SizedBox(
          width: areaWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: blocks,
          ),
        ),
      ),
    );
  }

  Widget _buildSlot(
      List<double> slot,
      double width,
      double height,
      Widget child,
      ) {
    return Positioned(
      left: width * slot[0],
      top: height * slot[2],
      width: width * (slot[1] - slot[0]),
      height: height * (slot[3] - slot[2]),
      child: child,
    );
  }

  Widget _buildSlotText(String text, {double fontSize = 16}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: inkColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: quranFontFamily,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMushafPage({
    required int pageNumber,
    required Map<String, dynamic> pageData,
    required List<_Ayah> ayahs,
  }) {
    final surahName = surahNames[(pageData['sura'] as int) - 1];
    final juz = _getCurrentJuz(pageData);

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = width / frameAspect;

        if (height > constraints.maxHeight) {
          height = constraints.maxHeight;
          width = height * frameAspect;
        } else {
          final stretched = height * maxFrameStretch;
          height = stretched < constraints.maxHeight
              ? stretched
              : constraints.maxHeight;
        }

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/quran_frame.png',
                  fit: BoxFit.fill,
                ),
                _buildSlot(
                  leftPillSlot,
                  width,
                  height,
                  _buildSlotText('سورة $surahName'),
                ),
                _buildSlot(
                  centerPillSlot,
                  width,
                  height,
                  _buildSlotText(_arabicNumber(pageNumber)),
                ),
                _buildSlot(
                  rightPillSlot,
                  width,
                  height,
                  _buildSlotText('الجزء ${_arabicNumber(juz)}'),
                ),
                _buildSlot(
                  titleSlot,
                  width,
                  height,
                  _buildSlotText('سُورَةُ $surahName', fontSize: 30),
                ),
                Positioned(
                  top: height * contentTop,
                  left: width * contentSide,
                  right: width * contentSide,
                  bottom: height * contentBottom,
                  child: _buildAyahContent(
                    ayahs: ayahs,
                    areaWidth: width * (1 - 2 * contentSide),
                    areaHeight: height * (1 - contentTop - contentBottom),
                    centered: pageNumber <= 2,
                  ),
                ),
                _buildSlot(
                  bottomSlot,
                  width,
                  height,
                  _buildSlotText(_arabicNumber(pageNumber), fontSize: 19),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 42,
  }) {
    return Material(
      color: const Color(0xFF123B35).withOpacity(0.96),
      shape: const CircleBorder(
        side: BorderSide(
          color: goldColor,
          width: 1.3,
        ),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            color: goldColor,
            size: size * 0.55,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required VoidCallback onSearch,
    required VoidCallback onBookmark,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: const Text(
                  'القرآن الكريم',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: AppColor.lightGold,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: quranFontFamily,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCircleButton(
                    icon: bookmarkedPage == currentPage
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    onPressed: onBookmark,
                  ),
                  const SizedBox(width: 8),
                  _buildCircleButton(
                    icon: Icons.search,
                    onPressed: onSearch,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCircleButton(
                    icon: Icons.nightlight_round,
                    onPressed: () {
                      _showMessage('وضع الليل غير مفعّل حاليًا');
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildCircleButton(
                    icon: Icons.settings,
                    onPressed: () {
                      _showMessage('الإعدادات غير مفعّلة حاليًا');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomTool({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool highlighted = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 2,
          ),
          decoration: highlighted
              ? BoxDecoration(
            color: goldColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: goldColor,
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: goldColor.withOpacity(0.35),
                blurRadius: 10,
              ),
            ],
          )
              : null,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: goldColor,
                  size: 25,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColor.lightGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar({
    required VoidCallback onPrevious,
    required VoidCallback onNext,
    required VoidCallback onBookmark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF06352E).withOpacity(0.98),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: goldColor,
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildCircleButton(
            icon: Icons.chevron_right,
            size: 40,
            onPressed: onPrevious,
          ),
          _buildBottomTool(
            icon: Icons.menu_book_outlined,
            label: 'التفسير',
            onPressed: () {
              _showMessage('التفسير غير مفعّل حاليًا');
            },
          ),
          _buildBottomTool(
            icon: Icons.headphones,
            label: 'استماع',
            highlighted: true,
            onPressed: () {
              _showMessage('الاستماع غير مفعّل حاليًا');
            },
          ),
          _buildBottomTool(
            icon: Icons.translate,
            label: 'ترجمة',
            onPressed: () {
              _showMessage('الترجمة غير مفعّلة حاليًا');
            },
          ),
          _buildBottomTool(
            icon: bookmarkedPage == currentPage
                ? Icons.bookmark
                : Icons.bookmark_border,
            label: 'علامة',
            onPressed: onBookmark,
          ),
          _buildBottomTool(
            icon: Icons.share_outlined,
            label: 'مشاركة',
            onPressed: () {
              _showMessage('المشاركة غير مفعّلة حاليًا');
            },
          ),
          _buildCircleButton(
            icon: Icons.chevron_left,
            size: 40,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    pageController?.dispose();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColor.primaryBackground,
        body: FutureBuilder<_ReaderData>(
          future: readerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: goldColor,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'تعذر تحميل المصحف:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              );
            }

            final data = snapshot.data!;

            if (pageController == null) {
              pageController = PageController(
                initialPage: data.initialPageIndex,
              );

              currentPage = data.initialPageIndex + 1;

              _saveLastPage(currentPage, data.pages);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/quran_background.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.12),
                      ),
                    ),
                    SafeArea(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              12,
                              16,
                              8,
                            ),
                            child: _buildHeader(
                              onSearch: () {
                                _showSearchDialog(data);
                              },
                              onBookmark: _toggleBookmark,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                                vertical: 4,
                              ),
                              child: PageView.builder(
                                controller: pageController,
                                itemCount: data.pages.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    currentPage = index + 1;
                                  });

                                  _saveLastPage(currentPage, data.pages);
                                },
                                itemBuilder: (context, index) {
                                  return _buildMushafPage(
                                    pageNumber: index + 1,
                                    pageData: data.pages[index],
                                    ayahs: data.pageAyahs[index],
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              12,
                              4,
                              12,
                              8,
                            ),
                            child: _buildBottomBar(
                              onPrevious: () {
                                if (currentPage > 1) {
                                  pageController?.previousPage(
                                    duration: const Duration(
                                      milliseconds: 300,
                                    ),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              onNext: () {
                                if (currentPage < data.pages.length) {
                                  pageController?.nextPage(
                                    duration: const Duration(
                                      milliseconds: 300,
                                    ),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              onBookmark: _toggleBookmark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}