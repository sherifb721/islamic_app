
import 'package:flutter/material.dart';
import 'package:islamic_app/core/theme/color.dart';
import 'package:islamic_app/features/quran/QuranScreen.dart';
import 'package:islamic_app/features/quran/quran.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryBackground,

      // APP BAR
      appBar: AppBar(
        backgroundColor: AppColor.primaryBackground,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.person_outline,
            color: AppColor.primaryGold,
            size: 28,
          ),
        ),

        title: Column(
          children: [
            const Text(
              'إسلامي',
              style: TextStyle(
                color: AppColor.lightGold,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'رفيقك في رحلتك الإيمانية',
              style: TextStyle(
                color: AppColor.primaryText,
                fontSize: 11,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: AppColor.primaryGold,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColor.primaryGold,
            ),
          ),
        ],
      ),

      // BODY
      body: Stack(
        fit: StackFit.expand,
        children: [

          // Background Image
          Image.asset(
            'assets/images/portrait.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),

          // Background Overlay
          Container(
            color: const Color.fromRGBO(11, 36, 40, 0.30),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // Prayer Times Card
                  _buildPrayerCard(),

                  const SizedBox(height: 20),

                  // Prayer Times Row
                  _buildPrayerTimes(),

                  const SizedBox(height: 24),

                  // Ayah Of The Day
                  _buildAyahCard(),

                  const SizedBox(height: 24),

                  // Section Title
                  _buildSectionTitle('أقسام التطبيق'),

                  const SizedBox(height: 14),

                  // Features Grid
                  _buildFeaturesGrid(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,

        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QuranScreen(),
              ),
            );
          } else {
            setState(() {
              selectedIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColor.primaryGreen,
        selectedItemColor: AppColor.lightGold,
        unselectedItemColor: AppColor.secondaryText,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'المصحف',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'القبلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'المفضلة',
          ),
        ],
      ),
    );
  }

  // PRAYER CARD
  Widget _buildPrayerCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.primaryGreen.withOpacity(0.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColor.primaryGold,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(
                Icons.location_on,
                color: AppColor.primaryGold,
              ),
              Text(
                'مواقيت الصلاة - القاهرة',
                style: TextStyle(
                  color: AppColor.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Divider(color: AppColor.borders),

          const Text(
            'الصلاة القادمة',
            style: TextStyle(
              color: AppColor.lightGold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'المغرب',
            style: TextStyle(
              color: AppColor.primaryText,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.access_time,
                color: AppColor.primaryGold,
              ),
              SizedBox(width: 8),
              Text(
                'متبقي 00:42:17',
                style: TextStyle(
                  color: AppColor.lightGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // PRAYER TIMES
  Widget _buildPrayerTimes() {
    final prayers = [
      {'name': 'الفجر', 'time': '04:52'},
      {'name': 'الظهر', 'time': '12:07'},
      {'name': 'العصر', 'time': '03:26'},
      {'name': 'المغرب', 'time': '05:49'},
      {'name': 'العشاء', 'time': '07:07'},
    ];

    return SizedBox(
      height: 85,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: prayers.length,
        separatorBuilder: (context, index) =>
        const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prayer = prayers[index];
          final isActive = index == 3;

          return Container(
            width: 105,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColor.primaryGold
                  : AppColor.primaryGreen.withOpacity(0.90),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColor.borders,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  prayer['name']!,
                  style: TextStyle(
                    color: isActive
                        ? AppColor.primaryBackground
                        : AppColor.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  prayer['time']!,
                  style: TextStyle(
                    color: isActive
                        ? AppColor.primaryBackground
                        : AppColor.primaryText,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // AYAH CARD
  Widget _buildAyahCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.primaryGreen.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColor.primaryGold,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'آية اليوم',
            style: TextStyle(
              color: AppColor.lightGold,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            '﴿ وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ عَلَيْهِ تَوَكَّلْتُ وَإِلَيْهِ أُنِيبُ ﴾',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppColor.primaryText,
              fontSize: 20,
              height: 1.8,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'سورة هود - الآية 88',
            style: TextStyle(
              color: AppColor.secondaryText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // SECTION TITLE
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.right,
      style: const TextStyle(
        color: AppColor.lightGold,
        fontSize: 21,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // FEATURES GRID
  Widget _buildFeaturesGrid() {
    final features = [
      {'title': 'المصحف الشريف', 'icon': Icons.menu_book},
      {'title': 'الأحاديث النبوية', 'icon': Icons.auto_stories},
      {'title': 'الأذكار', 'icon': Icons.spa_outlined},
      {'title': 'السبحة الإلكترونية', 'icon': Icons.fingerprint},
      {'title': 'القبلة', 'icon': Icons.explore},
      {'title': 'مواقيت الصلاة', 'icon': Icons.access_time},
      {'title': 'التقويم الهجري', 'icon': Icons.calendar_month},
      {'title': 'أدعية مختارة', 'icon': Icons.volunteer_activism},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: features.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final feature = features[index];


        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuranScreen(),
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.primaryGreen.withOpacity(0.92),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColor.borders,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  feature['icon'] as IconData,
                  color: AppColor.primaryGold,
                  size: 38,
                ),
                const SizedBox(height: 12),
                Text(
                  feature['title'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColor.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );

      },
    );
  }
}
