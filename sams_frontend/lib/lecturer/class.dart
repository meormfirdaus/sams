import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sams_frontend/lecturer/attendance.dart';

class ClassPage extends StatefulWidget {
  const ClassPage({super.key});

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  List<Map<String, String>> courses = [];
  List<Map<String, String>> modules = [];
  bool isLoading = true;
  int lecturerId = 0;
  List<Map<String, String>> allClassSessions = [];
Map<String, List<Map<String, String>>> courseSessionsMap = {};

  @override
  void initState() {
    super.initState();
    loadSessionAndFetch();
  }

  Future<void> loadSessionAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLecturerId = prefs.getInt('lecturer_id');
    final savedUserId = prefs.getInt('user_id');

    final resolvedLecturerId = savedLecturerId ?? savedUserId ?? 0;

    if (mounted) {
      setState(() {
        lecturerId = resolvedLecturerId;
      });
    }

    debugPrint('Lecturer ClassPage loaded lecturerId: $lecturerId');
    await fetchClasses();
  }

  Future<void> fetchClasses() async {
    if (lecturerId == 0) {
      setState(() {
        isLoading = false;
        courses = [];
        modules = [];
      });
      debugPrint('No lecturer_id found in session');
      return;
    }
    try {
      final response = await http
          .get(
            Uri.parse('http://10.0.2.2:8000/api/lecturer/$lecturerId/classes'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint('Lecturer classes API success: ${response.body}');
        final List data = json.decode(response.body);

        final List<Map<String, String>> sessionData = data
            .map<Map<String, String>>((item) => {
                  'id': item['id'].toString(),
                  'code': item['subject_code']?.toString() ?? '',
                  'name': item['subject_name']?.toString() ?? '',
                  'class_date': item['class_date']?.toString() ?? '',
                  'start_time': item['start_time']?.toString() ?? '',
                  'end_time': item['end_time']?.toString() ?? '',
                })
            .toList();

        final Map<String, Map<String, String>> uniqueCourses = {};
        for (final item in sessionData) {
          final key = '${item['code']}|${item['name']}';
          uniqueCourses.putIfAbsent(
            key,
            () => {
              'code': item['code'] ?? '',
              'name': item['name'] ?? '',
            },
          );
        }

        final Map<String, List<Map<String, String>>> groupedSessions = {};
for (final item in sessionData) {
  final courseCode = (item['code'] ?? '').trim().toUpperCase();
  groupedSessions.putIfAbsent(courseCode, () => []);
  groupedSessions[courseCode]!.add(item);
}

       setState(() {
  allClassSessions = sessionData;
  courseSessionsMap = groupedSessions;
  courses = uniqueCourses.values.toList();
  modules = [];
  isLoading = false;
});
      } else {
        debugPrint('Lecturer classes API failed: ${response.statusCode}');
        debugPrint('Lecturer classes API body: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching lecturer classes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showCourseSessions(Map<String, String> course) {
   final selectedCode = (course['code'] ?? '').trim().toUpperCase();
final sessions = List<Map<String, String>>.from(
  courseSessionsMap[selectedCode] ?? <Map<String, String>>[],
);

debugPrint('Selected course code: $selectedCode');
debugPrint('Mapped sessions count: ${sessions.length}');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${course['code'] ?? ''} ${course['name'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                if (sessions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No class sessions available yet.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                else
                  ...sessions.map((session) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F7FB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        title: Text(
                          session['class_date'] ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${session['start_time'] ?? '-'} - ${session['end_time'] ?? '-'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            this.context,
                            MaterialPageRoute(
                              builder: (context) => AttendancePage(
                                classSessionId: int.tryParse(session['id'] ?? '') ?? 1,
                                subjectCode: session['code'] ?? '',
                                subjectName: session['name'] ?? '',
                                classDate: session['class_date'] ?? '',
                                startTime: session['start_time'] ?? '',
                                endTime: session['end_time'] ?? '',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAssignments = courses.isNotEmpty || modules.isNotEmpty;

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
              child: const Text(
                'Course and Module List',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchClasses,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : hasAssignments
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (courses.isNotEmpty) ...[
                                  const Text(
                                    'Course',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildListCard(
                                    titleOne: 'COURSE CODE',
                                    titleTwo: 'COURSE NAME',
                                    actionTitle: 'ACTION',
                                    data: courses,
                                    viewLabel: 'View Course',
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                if (modules.isNotEmpty) ...[
                                  const Text(
                                    'Module',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildListCard(
                                    titleOne: 'MODULE CODE',
                                    titleTwo: 'MODULE NAME',
                                    actionTitle: 'ACTION',
                                    data: modules,
                                    viewLabel: 'View Module',
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              Icon(
                                Icons.menu_book_outlined,
                                size: 72,
                                color: Color(0xFF9AA0AF),
                              ),
                              SizedBox(height: 20),
                              Center(
                                child: Text(
                                  'No course or module assigned yet',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  'Please wait until the Faculty Registrar assigns a course or module to you.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                    height: 1.4,
                                  ),
                                ),
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

  Widget _buildListCard({
    required String titleOne,
    required String titleTwo,
    required String actionTitle,
    required List<Map<String, String>> data,
    required String viewLabel,
  }) {
    return Container(
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
                            _buildActionButton(
                              'Attendance',
                              onPressed: () {
                                _showCourseSessions(item);
                              },
                            ),
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

  Widget _buildActionButton(String label, {VoidCallback? onPressed}) {
    return SizedBox(
      width: 92,
      height: 30,
      child: ElevatedButton(
        onPressed: onPressed ?? () {},
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