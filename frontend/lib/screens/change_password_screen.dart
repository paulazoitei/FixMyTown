import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String message = '';
  Color messageColor = Colors.red;

  Future<void> _changePassword() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (_passwordController.text != _confirmController.text) {
      setState(() {
        message = 'Passwords do not match';
        messageColor = Colors.red;
      });
      return;
    }

    final password = _passwordController.text.trim();
    final regex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~_.,;:<>?^%()\[\]{}|\\/\+=\-]).{8,}$');


    if (!regex.hasMatch(password)) {
      setState(() {
        message =
        'Password must be at least 8 characters, include upper/lowercase, number and symbol';
        messageColor = Colors.red;
      });
      return;
    }

    final Uri url = Uri.parse(
        'http://10.0.2.2:8081/api/v1/auth/change-password');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"newPassword": password}),
      );

      setState(() {
        if (response.statusCode == 200) {
          message = 'Password changed successfully';
          messageColor = Colors.green;
        } else {
          message = 'Error: ${response.body}';
          messageColor = Colors.red;
        }
      });
    } catch (e) {
      setState(() {
        message = 'Something went wrong. Try again later.';
        messageColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background_home_screen.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'New Password',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        overlayColor: const Color(0xFF1B5E20).withOpacity(0.2), // verde închis, subtil la apăsare
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 4, // efect ușor 3D
                        shadowColor: Colors.black45,
                      ),
                      child: const Text(
                        'CHANGE',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                  ),

                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(
                      color: messageColor,
                      fontSize: 16, // ← mărime mai vizibilă pentru eroare
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}