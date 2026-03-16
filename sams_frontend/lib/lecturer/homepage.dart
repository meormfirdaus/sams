import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LecturerHomepage extends StatefulWidget {
  const LecturerHomepage({super.key});

  @override
  State<LecturerHomepage> createState() => _LecturerHomepageState();
}

class _LecturerHomepageState extends State<LecturerHomepage> {
  final int _selectedIndex = 0;

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  final List<Map<String, String>> courses = [
    {
      'code': 'BCS 3133',
      'name': 'SOFTWARE ENGINEERING\nPRACTICES',
    },
    {
      'code': 'BCS 3143',
      'name': 'SOFTWARE PROJECT\nMANAGEMENT',
    },
  ];

  final List<Map<String, String>> modules = [
    {
      'code': 'HQD3062',
      'name': 'EDIT LIKE A PRO WITH\nCANVA',
    },
    {
      'code': 'HQS3022',
      'name': 'KAYAK',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F1F2),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
              decoration: const BoxDecoration(
                color: Color(0xFF2E4E96),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedIndex == 0
                        ? 'Home'
                        : _selectedIndex == 1
                            ? 'Curriculum'
                            : _selectedIndex == 2
                                ? 'Course and Module List'
                                : 'Payment',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: _logout,
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _buildPageContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    if (_selectedIndex == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Course',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          _buildListCard(
            titleOne: 'COURSE CODE',
            titleTwo: 'COURSE NAME',
            actionTitle: 'ACTION',
            data: courses,
            viewLabel: 'View Course',
          ),
          const SizedBox(height: 18),
          const Text(
            'Module',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          _buildListCard(
            titleOne: 'MODULE CODE',
            titleTwo: 'MODULE NAME',
            actionTitle: 'ACTION',
            data: modules,
            viewLabel: 'View Module',
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    if (_selectedIndex == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 120),
          child: Text(
            'Home Page Content',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    if (_selectedIndex == 1) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 120),
          child: Text(
            'Curriculum Page Content',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 120),
        child: Text(
          'Payment Page Content',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildListCard({
    required String titleOne,
    required String titleTwo,
    required String actionTitle,
    required List<Map<String, String>> data,
    required String viewLabel,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    titleOne,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    titleTwo,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    actionTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFF3C3C3C)),
          ...List.generate(data.length, (index) {
            final item = data[index];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          item['code'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          item['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildActionButton(viewLabel),
                            const SizedBox(height: 8),
                            _buildActionButton('Attendance'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (index != data.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 14,
                    endIndent: 14,
                    color: Color(0xFF3C3C3C),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label) {
    return SizedBox(
      width: 92,
      height: 30,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E4E96),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

}