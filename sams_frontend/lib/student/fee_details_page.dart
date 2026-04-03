import 'package:flutter/material.dart';
import 'submit_payment_page.dart';
import 'upload_payment_proof_page.dart';

class FeeDetailsPage extends StatelessWidget {
  const FeeDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF40C4C4);
    const Color bgColor = Color(0xFFF3F3F3);
    const Color borderColor = Color(0xFFB7C0CC);
    const Color greenText = Color(0xFF00C853);
    const Color redText = Color(0xFFE53935);
    const Color yellowBg = Color(0xFFF8E8A5);
    const Color yellowText = Color(0xFFF39C12);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 92,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                color: primaryColor,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Fee Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.school, size: 58),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'CB23035 · Nur Izzah Dania binti Hipni Shahlizal\nSemester 2, 2025/2026\nBCS - Software Engineering\nFaculty of Computing',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Fee Breakdown',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'FEE TYPE',
                              style: TextStyle(
                                color: Color(0xFF566276),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            'AMOUNT',
                            style: TextStyle(
                              color: Color(0xFF566276),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(height: 1),
                      SizedBox(height: 12),
                      _BreakdownRow(label: 'Tuition Fee', value: 'RM 860.00'),
                      Divider(height: 18),
                      _BreakdownRow(label: 'Hostel Fee', value: 'RM 650.00'),
                      Divider(height: 18),
                      _BreakdownRow(
                        label: 'Total',
                        value: 'RM 1,510.00',
                        labelColor: primaryColor,
                        valueColor: primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Payment Status',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Status',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: yellowBg,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Text(
                              'PARTIAL',
                              style: TextStyle(
                                color: yellowText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      const _BreakdownRow(
                        label: 'Paid',
                        value: 'RM 649.30',
                        valueColor: greenText,
                      ),
                      const Divider(height: 24),
                      const _BreakdownRow(
                        label: 'Outstanding',
                        value: 'RM 860.70',
                        valueColor: redText,
                      ),
                      const Divider(height: 24),
                      const Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Completion',
                              style: TextStyle(
                                color: Color(0xFF677285),
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Text(
                            '43%',
                            style: TextStyle(
                              color: Color(0xFF677285),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          value: 0.43,
                          minHeight: 12,
                          backgroundColor: Color(0xFFE5E5E5),
                          valueColor: AlwaysStoppedAnimation(primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SubmitPaymentPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.payment, color: Colors.white),
                    label: const Text(
                      'Pay Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UploadPaymentProofPage(
                            pageTitle: 'Upload Payment Proof',
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    icon: const Icon(Icons.attach_file, color: primaryColor),
                    label: const Text(
                      'Upload Payment Proof',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;

  const _BreakdownRow({
    required this.label,
    required this.value,
    this.labelColor = Colors.black,
    this.valueColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: labelColor,
              fontWeight: label == 'Total' ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}