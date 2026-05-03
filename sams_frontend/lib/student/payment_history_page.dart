import 'package:flutter/material.dart';

class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF40C4C4);
    const Color bgColor = Color(0xFFF3F3F3);
    const Color borderColor = Color(0xFFB7C0CC);
    const Color greenText = Color(0xFF00C853);
    const Color redText = Color(0xFFE53935);
    const Color yellowText = Color(0xFFF39C12);
    const Color tagBg = Color(0xFFE6F7EE);
    const Color pendingBg = Color(0xFFF8E8A5);

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
                      'Payment History',
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: _SemesterChip(text: 'Semester 2, 2025/2026'),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        value: 'RM 649.30',
                        label: 'Total Paid',
                        valueColor: greenText,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _InfoCard(
                        value: 'RM 860.70',
                        label: 'Outstanding',
                        valueColor: redText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Container(
                  padding: const EdgeInsets.all(12),
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
                              'DATE',
                              style: TextStyle(
                                color: Color(0xFF566276),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'AMOUNT',
                              style: TextStyle(
                                color: Color(0xFF566276),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'METHOD',
                              style: TextStyle(
                                color: Color(0xFF566276),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'STATUS',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Color(0xFF566276),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Divider(height: 1),
                      SizedBox(height: 12),
                      _HistoryRow(
                        date: '26 Feb 2026',
                        amount: 'RM 400.00',
                        method: 'Online\nBanking',
                        status: 'APPROVED',
                        statusColor: greenText,
                        statusBg: tagBg,
                      ),
                      Divider(height: 20),
                      _HistoryRow(
                        date: '8 Mar 2026',
                        amount: 'RM 249.30',
                        method: 'Online\nBanking',
                        status: 'APPROVED',
                        statusColor: greenText,
                        statusBg: tagBg,
                      ),
                      Divider(height: 20),
                      _HistoryRow(
                        date: '11 Mar 2026',
                        amount: 'RM 350.00',
                        method: 'Online\nBanking',
                        status: 'PENDING',
                        statusColor: yellowText,
                        statusBg: pendingBg,
                      ),
                    ],
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

class _SemesterChip extends StatelessWidget {
  final String text;

  const _SemesterChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD8F6F4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF40C4C4),
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _InfoCard({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFB7C0CC)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String date;
  final String amount;
  final String method;
  final String status;
  final Color statusColor;
  final Color statusBg;

  const _HistoryRow({
    required this.date,
    required this.amount,
    required this.method,
    required this.status,
    required this.statusColor,
    required this.statusBg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(date, style: const TextStyle(fontSize: 15))),
        Expanded(child: Text(amount, style: const TextStyle(fontSize: 15))),
        Expanded(child: Text(method, style: const TextStyle(fontSize: 15))),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}