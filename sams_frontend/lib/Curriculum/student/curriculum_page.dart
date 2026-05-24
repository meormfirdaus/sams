import 'package:flutter/material.dart';
import 'activities_page.dart';
import 'module_booking_page.dart';
import '../student/credit_claim_page.dart';

class CurriculumPage extends StatelessWidget {
  const CurriculumPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3FC7C4);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            Container(
             width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
              decoration: const BoxDecoration(
                color: Color(0xFF67C5C4),
              ),
              child: const Text(
                'Curriculum Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Nunito',
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Access',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap a module to continue',
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
                      children: const [
                        CurriculumModuleCard(
                          title: 'Module Booking',
                          imagePath: 'assets/images/module_booking.png',
                        ),
                        // CurriculumModuleCard(
                        //   title: 'Club Activity',
                        //   imagePath: 'assets/images/club_activity.png',
                        // ),
                        CurriculumModuleCard(
                          title: 'Credit Claim',
                          imagePath: 'assets/images/credit_claim.png',
                        ),
                        CurriculumModuleCard(
                          title: 'Activities',
                          imagePath: 'assets/images/activities.png',
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

class CurriculumModuleCard extends StatelessWidget {
  final String title;
  final String imagePath;

  const CurriculumModuleCard({
    super.key,
    required this.title,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3FC7C4);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (title == 'Module Booking') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ModuleBookingPage(),
            ),
          );
        } else if (title == 'Credit Claim') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreditClaimPage(),
            ),
          );
        } else if (title == 'Activities') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ActivitiesPage(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title tapped')),
          );
        }
},
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
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_outlined,
                      size: 70,
                      color: Colors.grey,
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
                color: primaryColor,
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

