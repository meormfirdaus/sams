import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'module_model.dart';
import 'available_classes_page.dart';

class BookNowPage extends StatefulWidget {
  const BookNowPage({super.key});

  @override
  State<BookNowPage> createState() => _BookNowPageState();
}

class _BookNowPageState extends State<BookNowPage> {
  final TextEditingController _searchController = TextEditingController();

  List<ModuleModel> _allModules = [];
  List<ModuleModel> _filteredModules = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int? _studentId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterModules);
    _loadStudentIdAndFetchModules();
  }

  Future<void> _loadStudentIdAndFetchModules() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStudentId = prefs.getInt('student_id');

    setState(() {
      _studentId = savedStudentId;
    });

    await fetchModules();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchModules() async {
    try {
      final response = await http.get(
        //Uri.parse('http://127.0.0.1:8000/api/modules'),
        Uri.parse('http://10.0.2.2:8000/api/modules'),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = decoded['data'];

        final modules =
            data.map((e) => ModuleModel.fromJson(e)).toList().cast<ModuleModel>();

        setState(() {
          _allModules = modules;
          _filteredModules = modules;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load modules';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _filterModules() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredModules = _allModules.where((module) {
        return module.code.toLowerCase().contains(query) ||
            module.name.toLowerCase().contains(query) ||
            module.location.toLowerCase().contains(query) ||
            module.lecturer.toLowerCase().contains(query) ||
            module.category.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3FC7C4);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'KoQ Module Booking',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage))
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2E2A9),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '📌 Reminder',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Passed modules cannot be booked\n'
                                    'Same core module: max 2 attempts\n'
                                    'Only not taken / failed modules allowed\n'
                                    'Maximum 2 modules per booking',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search module...',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._filteredModules.map(
                              (module) => ModuleCard(
                                module: module,
                                studentId: _studentId,
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModuleCard extends StatelessWidget {
  final ModuleModel module;
  final int? studentId;

  const ModuleCard({
    super.key,
    required this.module,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF43C7C7);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            '${module.code} ${module.name}'.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📍 ${module.location}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  '👤 ${module.lecturer}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  '⚙ ${module.category}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: module.booked || studentId == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AvailableClassesPage(
                          module: module,
                          studentId: studentId!,
                        ),
                      ),
                    );
                  },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: module.booked
                    ? Colors.red
                    : (studentId == null ? Colors.grey : primaryColor),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                module.booked
                    ? 'Booked class date: ${module.bookedClassDate ?? "-"}'
                    : (studentId == null ? 'Student session not found' : 'View Date Available'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}