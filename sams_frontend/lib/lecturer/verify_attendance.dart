import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifyAttendancePage extends StatefulWidget {
  final int classSessionId;
  final String subjectCode;
  final String subjectName;
  final String classDate;
  final String startTime;
  final String endTime;

  const VerifyAttendancePage({
    super.key,
    required this.classSessionId,
    required this.subjectCode,
    required this.subjectName,
    required this.classDate,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<VerifyAttendancePage> createState() => _VerifyAttendancePageState();
}

class _VerifyAttendancePageState extends State<VerifyAttendancePage> {
  List<Map<String, String>> submissions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubmissions();
  }

  Future<void> fetchSubmissions() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .get(
            Uri.parse(
              'http://10.0.2.2:8000/api/attendance/${widget.classSessionId}/submissions',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          submissions = data
              .map<Map<String, String>>(
                (item) => {
                  'name': item['name']?.toString() ?? '-',
                  'matric': item['matric']?.toString() ?? '-',
                  'time': item['time']?.toString() ?? '-',
                  'status': item['status']?.toString() ?? 'Pending',
                  'location_name': item['location_name']?.toString() ?? '-',
                },
              )
              .toList();
        });
      }
    } catch (_) {
      //
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'Present':
        return const Color(0xFF5ECF84);
      case 'Late':
        return const Color(0xFFE0A92F);
      case 'Absent':
        return const Color(0xFFF06A6A);
      default:
        return Colors.black54;
    }
  }

  Color _statusBackgroundColor(String status) {
    switch (status) {
      case 'Present':
        return const Color(0xFFE6F8EC);
      case 'Late':
        return const Color(0xFFFFF3D8);
      case 'Absent':
        return const Color(0xFFFFE6E6);
      default:
        return const Color(0xFFF3F3F3);
    }
  }

  String _formatClassDate(String value) {
    if (value.isEmpty) return '-';
    try {
      final date = DateTime.parse(value);
      const weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return value;
    }
  }

  String _formatTime(String value) {
    if (value.isEmpty) return '-';
    try {
      final parts = value.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? parts[1] : '00';
      final suffix = hour >= 12 ? 'pm' : 'am';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return '$hour:$minute $suffix';
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Nunito'),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F1F2),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                color: const Color(0xFF2E4E96),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Verify Attendance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: fetchSubmissions,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${widget.subjectCode} ${widget.subjectName}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatClassDate(widget.classDate),
                              style: const TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${_formatTime(widget.startTime)} - ${_formatTime(widget.endTime)}',
                              style: const TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Submitted Students',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF4F6FA),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'MATRIC NO',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF6F7A8C),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'LOCATION',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF6F7A8C),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'STATUS',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF6F7A8C),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'ACTION',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF6F7A8C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isLoading)
                              const Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              )
                            else if (submissions.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'No attendance submissions yet.',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              )
                            else
                              ...List.generate(submissions.length, (index) {
                                final item = submissions[index];
                                final status = item['status'] ?? '';
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: index == 0
                                            ? Colors.transparent
                                            : const Color(0xFFE9EDF4),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          item['matric'] ?? '',
                                          style: const TextStyle(fontSize: 11, color: Colors.black87),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          item['location_name'] ?? 'Faculty Location',
                                          style: const TextStyle(fontSize: 11, color: Colors.black87),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _statusBackgroundColor(status),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            status,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: _statusTextColor(status),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 4),
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF4CAF50),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: const Text(
                                                'Approve',
                                                style: TextStyle(color: Colors.white, fontSize: 10),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE74C3C),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: const Text(
                                                'Reject',
                                                style: TextStyle(color: Colors.white, fontSize: 10),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
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