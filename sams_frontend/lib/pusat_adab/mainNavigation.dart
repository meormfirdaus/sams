import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart' show LoginPage;
import '../Curriculum/pusat_adab/approve_credit_page.dart';
import '../Curriculum/pusat_adab/record_participation_page.dart';
import '../Curriculum/pusat_adab/register_module_page.dart';
import '../Curriculum/pusat_adab/review_submission_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  int _curriculumMode = 0;

  void _selectPage(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 1) {
        _curriculumMode = 0;
      }
    });
  }

  void _openCurriculumPage(int mode) {
    setState(() {
      _currentIndex = 1;
      _curriculumMode = mode;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      PusatAdabHomePage(
        onReviewSubmissionsTap: () => _openCurriculumPage(0),
        onApproveCreditTap: () => _openCurriculumPage(1),
        onRegisterModuleTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterModulePage()),
          );
        },
        onRecordParticipationTap: () => _selectPage(2),
        onLogout: _logout,
      ),
      _curriculumMode == 0
          ? const ReviewSubmissionPage()
          : const ApproveCreditPage(),
      const RecordParticipationPage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: SizedBox(
        height: 85,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _selectPage,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF67C5C4),
          unselectedItemColor: Colors.grey,
          iconSize: 30,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.autorenew),
              label: "Curriculum",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_turned_in_outlined),
              label: "Participation",
            ),
          ],
        ),
      ),
    );
  }
}

class PusatAdabHomePage extends StatelessWidget {
  final VoidCallback onReviewSubmissionsTap;
  final VoidCallback onApproveCreditTap;
  final VoidCallback onRegisterModuleTap;
  final VoidCallback onRecordParticipationTap;
  final VoidCallback onLogout;

  const PusatAdabHomePage({
    super.key,
    required this.onReviewSubmissionsTap,
    required this.onApproveCreditTap,
    required this.onRegisterModuleTap,
    required this.onRecordParticipationTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF27206F),
                    Color(0xFF5A4DFF),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Dashboard Pusat Adab",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout, color: Colors.white),
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Quick Access",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      width: 75,
                      height: 2,
                      margin: const EdgeInsets.only(top: 3, bottom: 8),
                      color: const Color(0xFF36CACA),
                    ),
                    const Text(
                      "Tap a module to continue",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 18),

                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 22,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 0.82,
                      children: [
                        _MenuCard(
                          image: "assets/images/review.png",
                          title: "Review Submissions",
                          fallbackIcon: Icons.rate_review_outlined,
                          onTap: onReviewSubmissionsTap,
                        ),
                        _MenuCard(
                          image: "assets/images/credit_claim.png",
                          title: "Approve Credit",
                          fallbackIcon: Icons.verified_outlined,
                          onTap: onApproveCreditTap,
                        ),
                        _MenuCard(
                          image: "assets/images/register.jpeg",
                          title: "Register Module",
                          fallbackIcon: Icons.add_circle_outline,
                          onTap: onRegisterModuleTap,
                        ),
                        _MenuCard(
                          image: "assets/images/participation.png",
                          title: "Record Participation",
                          fallbackIcon: Icons.assignment_turned_in_outlined,
                          onTap: onRecordParticipationTap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String image;
  final String title;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.image,
    required this.title,
    required this.fallbackIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      fallbackIcon,
                      size: 70,
                      color: const Color(0xFF35C9CA),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF35C9CA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
