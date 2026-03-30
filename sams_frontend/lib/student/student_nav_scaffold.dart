import 'package:flutter/material.dart';
import 'homepage.dart';
import 'class.dart';
import 'curriculum_page.dart';

class StudentNavScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;

  const StudentNavScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const StudentHomepage();
        break;
      case 1:
        page = const CurriculumPage();
        break;
      case 2:
        page = const StudentClassPage();
        break;
      case 3:
        page = const Scaffold(
          body: Center(child: Text('Payment Page')),
        );
        break;
      default:
        page = const StudentHomepage();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: body,
      bottomNavigationBar: SizedBox(
        height: 85,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(context, index),
          selectedItemColor: const Color(0xFF67C5C4),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
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
              icon: Icon(Icons.menu_book_outlined),
              label: "Class",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payments_outlined),
              label: "Payment",
            ),
          ],
        ),
      ),
    );
  }
}