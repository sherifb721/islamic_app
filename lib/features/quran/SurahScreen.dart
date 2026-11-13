
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islamic_app/core/theme/color.dart';
import 'package:mushaf_text/mushaf_text.dart';
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

class _SurahScreenState extends State<SurahScreen> {
  late Future<Map<String, dynamic>> readerFuture;
  PageController? pageController;

  int currentPage = 1;
  bool controlsVisible = true;
  Offset? _pointerDownPosition;

  static const Color goldColor = Color(0xFFD9B66D);
  static const String lastPageKey = 'last_reading_page';

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

  // بدايات الأجزاء في ترتيب مصحف المدينة.
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
  }

  Future<Map<String, dynamic>> _loadReader() async {
    final pagesJson = await rootBundle.loadString(
      'assets/data/pages.json',
    );

    final decodedPages = jsonDecode(pagesJson) as List<dynamic>;

    final pages = decodedPages.map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();

    if (pages.length != 604) {
      throw Exception('عدد صفحات المصحف غير صحيح');
    }

    final initialPageIndex = _findInitialPage(pages);

    final prefs = await SharedPreferences.getInstance();
    final savedPage = prefs.getInt(lastPageKey);

    int selectedPageIndex = initialPageIndex;

    if (savedPage != null &&
        savedPage >= 1 &&
        savedPage <= 604) {
      final savedSurah = pages[savedPage - 1]['sura'] as int;

      if (savedSurah == widget.surahNumber) {
        selectedPageIndex = savedPage - 1;
      }
    }

    return {
      'pages': pages,
      'initialPageIndex': selectedPageIndex,
    };
  }

  int _findInitialPage(List<Map<String, dynamic>> pages) {
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

  void _toggleControls() {
    setState(() {
      controlsVisible = !controlsVisible;
    });
  }

  Future<void> _showSearchDialog(
      List<Map<String, dynamic>> pages,
      ) async {
    final surahController = TextEditingController(
      text: widget.surahNumber.toString(),
    );

    final ayahController = TextEditingController(
      text: '1',
    );

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

    for (int i = 0; i < pages.length; i++) {
      final pageSurah = pages[i]['sura'] as int;
      final pageAyah = pages[i]['aya'] as int;

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
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildMushafPage(
      int pageNumber,
      bool isOpeningSurah,
      ) {
    final frameImage = isOpeningSurah
        ? 'assets/images/frame_fatiha_baqara.png'
        : 'assets/images/new frame.png';

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          frameImage,
          fit: BoxFit.fill,
        ),
        Align(
          alignment: Alignment.center,
          child: FractionallySizedBox(
            widthFactor: isOpeningSurah ? 0.80 : 0.80,
            heightFactor: isOpeningSurah ? 0.90 : 0.90,
            child: ClipRect(
              child: MushafPage(
                page: pageNumber,
                colors: MushafColors.light,
                tajweed: true,
              ),
            ),
          ),
        ),
      ],
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
        body: FutureBuilder<Map<String, dynamic>>(
          future: readerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
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

            final pages =
            data['pages'] as List<Map<String, dynamic>>;

            final initialIndex =
            data['initialPageIndex'] as int;

            if (pageController == null) {
              pageController = PageController(
                initialPage: initialIndex,
              );

              currentPage = initialIndex + 1;

              _saveLastPage(currentPage, pages);
            }

            final currentPageData = pages[currentPage - 1];

            final currentSurahNumber =
            currentPageData['sura'] as int;

            final currentSurahName =
            surahNames[currentSurahNumber - 1];

            final currentJuz =
            _getCurrentJuz(currentPageData);

            return Stack(
              fit: StackFit.expand,
              children: [
                Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (event) {
                    _pointerDownPosition = event.localPosition;
                  },
                  onPointerUp: (event) {
                    final start = _pointerDownPosition;
                    _pointerDownPosition = null;

                    if (start != null &&
                        (event.localPosition - start).distance < 12) {
                      _toggleControls();
                    }
                  },
                  onPointerCancel: (_) {
                    _pointerDownPosition = null;
                  },
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index + 1;
                      });

                      _saveLastPage(currentPage, pages);
                    },
                    itemBuilder: (context, index) {
                      final isOpeningSurah =
                          index == 0 || index == 1;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: _buildMushafPage(
                          index + 1,
                          isOpeningSurah,
                        ),
                      );
                    },
                  ),
                ),

                // الشريط العلوي الشفاف
                if (controlsVisible)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: AppColor.primaryGreen.withOpacity(0.85),
                      child: SafeArea(
                        bottom: false,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            tooltip: 'البحث عن آية',
                            onPressed: () {
                              _showSearchDialog(pages);
                            },
                            icon: const Icon(
                              Icons.search,
                              color: goldColor,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // الشريط السفلي الشفاف
                if (controlsVisible)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: AppColor.primaryGreen.withOpacity(0.85),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                currentSurahName,
                                style: const TextStyle(
                                  color: goldColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'صفحة ${_arabicNumber(currentPage)}',
                                style: const TextStyle(
                                  color: AppColor.lightGold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'الجزء ${_arabicNumber(currentJuz)}',
                                style: const TextStyle(
                                  color: goldColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
