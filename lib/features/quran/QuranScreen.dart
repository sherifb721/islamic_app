
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/core/theme/color.dart';
import 'package:islamic_app/features/quran/SurahScreen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  bool searchActive = false;
  late Future<Map<String, int?>> lastReadingFuture;

  static const List<String> surahData = [
    'الفاتحة|7|مكية',
    'البقرة|286|مدنية',
    'آل عمران|200|مدنية',
    'النساء|176|مدنية',
    'المائدة|120|مدنية',
    'الأنعام|165|مكية',
    'الأعراف|206|مكية',
    'الأنفال|75|مدنية',
    'التوبة|129|مدنية',
    'يونس|109|مكية',
    'هود|123|مكية',
    'يوسف|111|مكية',
    'الرعد|43|مدنية',
    'إبراهيم|52|مكية',
    'الحجر|99|مكية',
    'النحل|128|مكية',
    'الإسراء|111|مكية',
    'الكهف|110|مكية',
    'مريم|98|مكية',
    'طه|135|مكية',
    'الأنبياء|112|مكية',
    'الحج|78|مدنية',
    'المؤمنون|118|مكية',
    'النور|64|مدنية',
    'الفرقان|77|مكية',
    'الشعراء|227|مكية',
    'النمل|93|مكية',
    'القصص|88|مكية',
    'العنكبوت|69|مكية',
    'الروم|60|مكية',
    'لقمان|34|مكية',
    'السجدة|30|مكية',
    'الأحزاب|73|مدنية',
    'سبأ|54|مكية',
    'فاطر|45|مكية',
    'يس|83|مكية',
    'الصافات|182|مكية',
    'ص|88|مكية',
    'الزمر|75|مكية',
    'غافر|85|مكية',
    'فصلت|54|مكية',
    'الشورى|53|مكية',
    'الزخرف|89|مكية',
    'الدخان|59|مكية',
    'الجاثية|37|مكية',
    'الأحقاف|35|مكية',
    'محمد|38|مدنية',
    'الفتح|29|مدنية',
    'الحجرات|18|مدنية',
    'ق|45|مكية',
    'الذاريات|60|مكية',
    'الطور|49|مكية',
    'النجم|62|مكية',
    'القمر|55|مكية',
    'الرحمن|78|مدنية',
    'الواقعة|96|مكية',
    'الحديد|29|مدنية',
    'المجادلة|22|مدنية',
    'الحشر|24|مدنية',
    'الممتحنة|13|مدنية',
    'الصف|14|مدنية',
    'الجمعة|11|مدنية',
    'المنافقون|11|مدنية',
    'التغابن|18|مدنية',
    'الطلاق|12|مدنية',
    'التحريم|12|مدنية',
    'الملك|30|مكية',
    'القلم|52|مكية',
    'الحاقة|52|مكية',
    'المعارج|44|مكية',
    'نوح|28|مكية',
    'الجن|28|مكية',
    'المزمل|20|مكية',
    'المدثر|56|مكية',
    'القيامة|40|مكية',
    'الإنسان|31|مدنية',
    'المرسلات|50|مكية',
    'النبأ|40|مكية',
    'النازعات|46|مكية',
    'عبس|42|مكية',
    'التكوير|29|مكية',
    'الانفطار|19|مكية',
    'المطففين|36|مكية',
    'الانشقاق|25|مكية',
    'البروج|22|مكية',
    'الطارق|17|مكية',
    'الأعلى|19|مكية',
    'الغاشية|26|مكية',
    'الفجر|30|مكية',
    'البلد|20|مكية',
    'الشمس|15|مكية',
    'الليل|21|مكية',
    'الضحى|11|مكية',
    'الشرح|8|مكية',
    'التين|8|مكية',
    'العلق|19|مكية',
    'القدر|5|مكية',
    'البينة|8|مدنية',
    'الزلزلة|8|مدنية',
    'العاديات|11|مكية',
    'القارعة|11|مكية',
    'التكاثر|8|مكية',
    'العصر|3|مكية',
    'الهمزة|9|مكية',
    'الفيل|5|مكية',
    'قريش|4|مكية',
    'الماعون|7|مكية',
    'الكوثر|3|مكية',
    'الكافرون|6|مكية',
    'النصر|3|مدنية',
    'المسد|5|مكية',
    'الإخلاص|4|مكية',
    'الفلق|5|مكية',
    'الناس|6|مكية',
  ];

  late final List<Map<String, dynamic>> surahs = List.generate(
    surahData.length,
        (index) {
      final parts = surahData[index].split('|');

      return {
        'number': index + 1,
        'name': parts[0],
        'verses': int.parse(parts[1]),
        'type': parts[2],
      };
    },
  );

  List<Map<String, dynamic>> get filteredSurahs {
    final query = searchController.text.trim();

    if (query.isEmpty) return surahs;

    return surahs.where((surah) {
      return (surah['name'] as String).contains(query) ||
          surah['number'].toString() == query;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    lastReadingFuture = _loadLastReading();

    searchFocusNode.addListener(() {
      if (searchFocusNode.hasFocus && !searchActive) {
        setState(() {
          searchActive = true;
        });
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  Future<Map<String, int?>> _loadLastReading() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'page': prefs.getInt('last_reading_page'),
      'surah': prefs.getInt('last_reading_surah'),
      'ayah': prefs.getInt('last_reading_ayah'),
    };
  }

  Future<void> _openSurah(Map<String, dynamic> surah) async {
    searchFocusNode.unfocus();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahScreen(
          surahNumber: surah['number'] as int,
          surahName: surah['name'] as String,
          totalAyahs: surah['verses'] as int,
          revelationType: surah['type'] as String,
        ),
      ),
    );

    if (mounted) {
      setState(() {
        lastReadingFuture = _loadLastReading();
      });
    }
  }

  void _clearSearch() {
    searchController.clear();
    searchFocusNode.unfocus();

    setState(() {
      searchActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColor.primaryBackground,
        appBar: AppBar(
          backgroundColor: AppColor.primaryBackground,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColor.primaryGold,
            ),
          ),
          title: const Text(
            'القرآن الكريم',
            style: TextStyle(
              color: AppColor.lightGold,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _clearSearch,
              icon: const Icon(
                Icons.refresh,
                color: AppColor.primaryGold,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildSearchField(),
              ),
              Expanded(
                child: searchActive
                    ? _buildSearchResults()
                    : _buildHomeContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      focusNode: searchFocusNode,
      textDirection: TextDirection.rtl,
      style: const TextStyle(color: AppColor.primaryText),
      onTap: () {
        setState(() {
          searchActive = true;
        });
      },
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: 'ابحث عن سورة بالاسم أو الرقم...',
        hintStyle: const TextStyle(
          color: AppColor.secondaryText,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColor.primaryGold,
        ),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
          onPressed: () {
            searchController.clear();
            setState(() {});
          },
          icon: const Icon(
            Icons.close,
            color: AppColor.secondaryText,
          ),
        )
            : null,
        filled: true,
        fillColor: AppColor.cardGreen,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = filteredSurahs;

    if (results.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد سورة بهذا الاسم',
          style: TextStyle(
            color: AppColor.secondaryText,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _buildSurahTile(results[index]);
      },
    );
  }

  Widget _buildHomeContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildLastReadingCard(),
        const SizedBox(height: 24),
        _buildSectionTitle('تصفح القرآن'),
        const SizedBox(height: 12),
        _buildShortcuts(),
        const SizedBox(height: 24),
        _buildSectionTitle('فهرس السور'),
        const SizedBox(height: 12),
        ...surahs.map(_buildSurahTile),
      ],
    );
  }

  Widget _buildLastReadingCard() {
    return FutureBuilder<Map<String, int?>>(
      future: lastReadingFuture,
      builder: (context, snapshot) {
        final savedSurahNumber = snapshot.data?['surah'];
        final savedAyah = snapshot.data?['ayah'];
        final savedPage = snapshot.data?['page'];

        Map<String, dynamic>? savedSurah;

        if (savedSurahNumber != null &&
            savedSurahNumber >= 1 &&
            savedSurahNumber <= surahs.length) {
          savedSurah = surahs[savedSurahNumber - 1];
        }

        final surahName =
            savedSurah?['name'] as String? ?? 'لم تبدأ القراءة بعد';
        final hasReading = savedSurah != null;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColor.cardGreen,
                AppColor.primaryGreen,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColor.borders),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.menu_book,
                    color: AppColor.primaryGold,
                    size: 30,
                  ),
                  Text(
                    'آخر قراءة',
                    style: TextStyle(
                      color: AppColor.lightGold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                hasReading ? 'سورة $surahName' : surahName,
                style: const TextStyle(
                  color: AppColor.primaryText,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                hasReading
                    ? 'الآية ${savedAyah ?? 1} • الصفحة ${savedPage ?? 1}'
                    : 'ستظهر هنا آخر سورة وصلت إليها',
                style: const TextStyle(color: AppColor.secondaryText),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _openSurah(savedSurah ?? surahs.first);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: Text(
                    hasReading ? 'متابعة القراءة' : 'ابدأ القراءة',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryGold,
                    foregroundColor: AppColor.primaryBackground,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.right,
      style: const TextStyle(
        color: AppColor.lightGold,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildShortcuts() {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(child: _buildShortcut(Icons.menu_book, 'السور')),
        const SizedBox(width: 10),
        Expanded(
          child: _buildShortcut(
            Icons.bookmarks_outlined,
            'العلامات',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildShortcut(Icons.grid_view, 'الأجزاء'),
        ),
      ],
    );
  }

  Widget _buildShortcut(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColor.cardGreen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.borders),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColor.primaryGold,
            size: 25,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColor.primaryText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahTile(Map<String, dynamic> surah) {
    return InkWell(
      onTap: () => _openSurah(surah),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColor.cardGreen.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColor.borders.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColor.primaryGold),
              ),
              alignment: Alignment.center,
              child: Text(
                '${surah['number']}',
                style: const TextStyle(
                  color: AppColor.lightGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah['name'] as String,
                    style: const TextStyle(
                      color: AppColor.primaryText,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${surah['type']} • ${surah['verses']} آية',
                    style: const TextStyle(
                      color: AppColor.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_back_ios,
              color: AppColor.primaryGold,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}
