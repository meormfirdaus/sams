import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sams_frontend/lecturer/mainNavigation.dart' as lecturer_nav;
import 'package:sams_frontend/student/mainNavigation.dart' as student_nav;
import 'package:sams_frontend/treasurer/dashboard_page.dart' as treasurer_page;

void main() {
  runApp(const SAMSApp());
}

class SAMSApp extends StatelessWidget {
  const SAMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAMS Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedRole;
  bool isLoading = false;

  final List<String> roles = [
    'Student',
    'Lecturer',
    'Faculty Registrar',
    'Treasury',
    'Pusat Adab',
  ];

  Future<void> login() async {
    String id = idController.text.trim().toUpperCase();
    String password = passwordController.text.trim();

    String apiRole;
    switch ((selectedRole ?? '').trim().toLowerCase()) {
      case 'student':
        apiRole = 'student';
        break;
      case 'lecturer':
        apiRole = 'lecturer';
        break;
      case 'treasury':
        apiRole = 'treasury';
        break;
      case 'faculty registrar':
        apiRole = 'faculty_registrar';
        break;
      case 'pusat adab':
        apiRole = 'pusat_adab';
        break;
      default:
        apiRole = (selectedRole ?? '').trim().toLowerCase();
    }

    if (id.isEmpty || password.isEmpty || selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter ID, password and select role")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        //Uri.parse('http://10.62.79.61:8000/api/login'),
        Uri.parse('http://10.0.2.2:8000/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'id_number': id,
          'password': password,
          'role': apiRole,
        }),
      ).timeout(const Duration(seconds: 10));

      final Map<String, dynamic> data = response.body.isNotEmpty
          ? json.decode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (!mounted) return;

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('login_id', id);
        await prefs.setString('role', (data['role'] ?? apiRole).toString());

        if (data['user_id'] != null) {
          await prefs.setInt('user_id', int.tryParse(data['user_id'].toString()) ?? 0);
        }

        if (data['student_id'] != null) {
          final parsedStudentId = int.tryParse(data['student_id'].toString());
          if (parsedStudentId != null) {
            await prefs.setInt('student_id', parsedStudentId);
          }
        } else {
          await prefs.remove('student_id');
        }

        if (data['lecturer_id'] != null) {
          final parsedLecturerId = int.tryParse(data['lecturer_id'].toString());
          if (parsedLecturerId != null) {
            await prefs.setInt('lecturer_id', parsedLecturerId);
          }
        } else {
          await prefs.remove('lecturer_id');
        }

        if (data['treasurer_id'] != null) {
          final parsedTreasurerId = int.tryParse(data['treasurer_id'].toString());
          if (parsedTreasurerId != null) {
            await prefs.setInt('treasurer_id', parsedTreasurerId);
          }
        } else {
          await prefs.remove('treasurer_id');
        }

        final resolvedRole = (data['role'] ?? apiRole).toString().trim();
        final normalizedRole = resolvedRole.toLowerCase();

        if (normalizedRole == 'lecturer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const lecturer_nav.MainNavigation(),
            ),
          );
        } else if (normalizedRole == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const student_nav.MainNavigation(),
            ),
          );
        } else if (normalizedRole == 'treasury' || normalizedRole == 'treasurer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const treasurer_page.DashboardPage(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message']?.toString() ?? 'Login successful')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message']?.toString() ?? 'Login failed. Please check your credentials.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to connect to server: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SAMS Login"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "SA Management System",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: idController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: "Matric ID / Staff ID",
                hintText: "Example: CB23017 / STF001",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(
                labelText: "Select Role",
                border: OutlineInputBorder(),
              ),
              items: roles.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRole = value;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : login,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
