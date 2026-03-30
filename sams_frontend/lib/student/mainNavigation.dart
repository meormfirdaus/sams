
import 'package:flutter/material.dart';
import 'homepage.dart';
import 'class.dart';
import 'curriculum_page.dart';


class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    StudentHomepage(),
    CurriculumPage(), // Curriculum page 
    StudentClassPage(),
    Placeholder(), // Payment page (create later)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SizedBox(
        height: 85,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: const Color(0xFF67C5C4),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
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
              icon: Icon(Icons.menu_book_outlined),
              label: "Class",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payments_outlined),
              label: "Payment",
            ),
          ],
          iconSize: 30,
        ),
      ),
    );
  }
}