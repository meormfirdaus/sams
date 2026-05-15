import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'payment_records_page.dart';
import 'verify_student_payment_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _searchController = TextEditingController();

  bool isLoading = true;
  String selectedStatus = 'Pending';
  String selectedCourse = 'All';

  int pendingCount = 0;
  int approvedCount = 0;
  int rejectedCount = 0;

  List records = [];
  int currentPage = 1;
  int lastPage = 1;

  final List<String> courses = [
    'All',
    'Software Engineering',
  ];

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData({int page = 1}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final uri = Uri.parse(
        //'http://127.0.0.1:8000/api/tuition/treasurer/pending'
        'http://10.0.2.2:8000/api/tuition/treasurer/pending'
        '?status=$selectedStatus'
        '&search=${Uri.encodeComponent(_searchController.text.trim())}'
        '&course=${Uri.encodeComponent(selectedCourse)}'
        '&page=$page',
      );

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          pendingCount = data['summary']['pending_count'] ?? 0;
          approvedCount = data['summary']['approved_count'] ?? 0;
          rejectedCount = data['summary']['rejected_count'] ?? 0;

          records = data['records']['data'] ?? [];
          currentPage = data['records']['current_page'] ?? 1;
          lastPage = data['records']['last_page'] ?? 1;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']?.toString() ?? 'Failed to load data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Color statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFFE8F8EE);
      case 'rejected':
        return const Color(0xFFFFE6E6);
      default:
        return const Color(0xFFFFF2CC);
    }
  }

  Color statusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF2EAD67);
      case 'rejected':
        return const Color(0xFFE85B5B);
      default:
        return const Color(0xFFF4B400);
    }
  }

  Widget _summaryCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        height: 72,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E2E2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8C8C8C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(String title, String value, Color color) {
    final bool active = selectedStatus == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedStatus = value;
          });
          fetchDashboardData();
        },
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 2.5,
              color: active ? color : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF22B8CF);
    const bgColor = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: primaryColor,
                ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tuition Fee Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaymentRecordsPage(),
                        ),
                      );
                      fetchDashboardData();
                    },
                    child: const Text(
                      'Records',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD6F3F7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Semester 2, 2025/2026',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _summaryCard('$pendingCount', 'Pending', const Color(0xFFF4B400)),
                              _summaryCard('$approvedCount', 'Approved', const Color(0xFF2EAD67)),
                              _summaryCard('$rejectedCount', 'Rejected', const Color(0xFFE85B5B)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search Matric No.',
                              prefixIcon: const Icon(Icons.search, size: 18),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
                              ),
                            ),
                            onSubmitted: (_) => fetchDashboardData(),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E2E2)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedCourse,
                                      isExpanded: true,
                                      items: courses.map((course) {
                                        return DropdownMenuItem(
                                          value: course,
                                          child: Text(course, style: const TextStyle(fontSize: 12)),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedCourse = value!;
                                        });
                                        fetchDashboardData();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: fetchDashboardData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF7F7F7F),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(color: Color(0xFFE2E2E2)),
                                  ),
                                ),
                                child: const Text('Refresh'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _tabItem('Pending', 'Pending', const Color(0xFFF4B400)),
                              _tabItem('Approved', 'Approved', const Color(0xFF2EAD67)),
                              _tabItem('Rejected', 'Rejected', const Color(0xFFE85B5B)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E2E2)),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: const Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'MATRIC NO.',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8A8A8A)),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'AMOUNT',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8A8A8A)),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'STATUS',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8A8A8A)),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'ACTION',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8A8A8A)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                if (records.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text('No payment records found.'),
                                  )
                                else
                                  ...records.map((item) {
                                    final status = item['status']?.toString() ?? 'Pending';
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(color: Color(0xFFF1F1F1)),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['matric_no']?.toString() ?? '-',
                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  item['name']?.toString() ?? '-',
                                                  style: const TextStyle(fontSize: 10, color: Color(0xFF888888)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'RM ${(item['amount'] ?? 0).toString()}',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: statusBg(status),
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              child: Text(
                                                status.toUpperCase(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: statusText(status),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Center(
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => VerifyStudentPaymentPage(
                                                        paymentId: item['id'],
                                                      ),
                                                    ),
                                                  );
                                                  fetchDashboardData(page: currentPage);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: primaryColor,
                                                  minimumSize: const Size(58, 32),
                                                  padding: EdgeInsets.zero,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(14),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'View',
                                                  style: TextStyle(fontSize: 11, color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Showing page $currentPage of $lastPage',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: currentPage > 1
                                        ? () => fetchDashboardData(page: currentPage - 1)
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE0E0E0),
                                      foregroundColor: const Color(0xFF666666),
                                      minimumSize: const Size(66, 34),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text('< Prev'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: currentPage < lastPage
                                        ? () => fetchDashboardData(page: currentPage + 1)
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(66, 34),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text('Next >'),
                                  ),
                                ],
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