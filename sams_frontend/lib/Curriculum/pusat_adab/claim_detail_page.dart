import 'package:flutter/material.dart';

class ClaimDetailPage extends StatelessWidget {
  const ClaimDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF4F2F2),
      body: SafeArea(
        child: Center(
          child: Text(
            'Claim Detail',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
