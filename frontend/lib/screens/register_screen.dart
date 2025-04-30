import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  Future<void> _registerToBackend() async {
    final url = Uri.parse("http://10.0.2.2:8081/api/v1/registration");

    final body = {
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        _showErrorDialog("Success", "Account created successfully.");
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      } else {
        _showErrorDialog("Error", response.body);
      }
    } catch (e) {
      _showErrorDialog("Connection Error", "Could not connect to server.");
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool isPasswordValid(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*()_+{}\[\]:;<>,.?~\\/-]).{8,}$');
    return regex.hasMatch(password);
  }

  bool isEmailValid(String email) {
    final regex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return regex.hasMatch(email);
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Verificăm primul câmp gol și oprim acolo cu un dialog
    if (firstName.isEmpty) {
      _showErrorDialog("Missing Field", "First Name is required.");
      return;
    }
    if (lastName.isEmpty) {
      _showErrorDialog("Missing Field", "Last Name is required.");
      return;
    }
    if (email.isEmpty) {
      _showErrorDialog("Missing Field", "Email is required.");
      return;
    }
    if (password.isEmpty) {
      _showErrorDialog("Missing Field", "Password is required.");
      return;
    }
    if (confirmPassword.isEmpty) {
      _showErrorDialog("Missing Field", "Confirm Password is required.");
      return;
    }

    // Validare email
    if (!isEmailValid(email)) {
      _showErrorDialog("Invalid Email", "Please enter a valid email address.");
      return;
    }

    // Validare parolă complexă
    if (!isPasswordValid(password)) {
      _showErrorDialog(
        "Weak Password",
        "Password must be at least 8 characters and include:\n• uppercase\n• lowercase\n• number\n• special character.",
      );
      return;
    }

    // Verificare potrivire parolă
    if (password != confirmPassword) {
      _showErrorDialog("Password Mismatch", "Passwords do not match.");
      return;
    }

    _registerToBackend();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fundal_fixmytown.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 60, bottom: 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(_firstNameController, "First Name"),
                  const SizedBox(height: 20),
                  _buildTextField(_lastNameController, "Last Name"),
                  const SizedBox(height: 20),
                  _buildTextField(_emailController, "Email"),
                  const SizedBox(height: 20),
                  _buildTextField(_passwordController, "Password", obscure: true),
                  const SizedBox(height: 20),
                  _buildTextField(_confirmPasswordController, "Confirm Password", obscure: true),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: const Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00695C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                      ).copyWith(
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                        splashFactory: NoSplash.splashFactory,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool obscure = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$hint is required";
        }
        return null;
      },
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: Colors.redAccent,
        ),
      ),
    );
  }
}
