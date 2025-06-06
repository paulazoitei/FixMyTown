import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class ProfileAdminScreen extends StatefulWidget {
  const ProfileAdminScreen({super.key});

  @override
  State<ProfileAdminScreen> createState() => _ProfileAdminScreenState();
}

class _ProfileAdminScreenState extends State<ProfileAdminScreen> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8081/api/v1/reports/admin/me/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        profileData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("Failed to load profile: ${response.body}");
    }
  }

  Widget buildLabel(String title, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: Colors.white70, size: 22),
          if (icon != null) const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '$title: ',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17),
                children: [
                  TextSpan(
                    text: value,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.normal, color: Colors.white, fontSize: 17),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Admin Profile",
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff00b09b), Color(0xff96c93d)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe1f8dc), Color(0xffc0e8a9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : profileData == null
            ? const Center(child: Text("Failed to load data"))
            : Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff70e1f5), Color(0xffffd194)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.asset(
                      'assets/images/profile_default.png',
                      width: 120, // ⬅️ mai mic
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "${profileData!['firstName']} ${profileData!['lastName']}",
                    style: GoogleFonts.poppins(
                      fontSize: 22, // ⬆️ font puțin mai mare
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profileData!['email'],
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white,

                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1, color: Colors.white54),
                  const SizedBox(height: 16),
                  buildLabel("Role", profileData!['role'], icon: Icons.admin_panel_settings),
                  buildLabel("Zone", profileData!['zone'], icon: Icons.location_on),
                  buildLabel("Total Reports", '${profileData!['totalReports']}', icon: Icons.assignment),
                  buildLabel("Reports This Month", '${profileData!['lastMonthReports']}', icon: Icons.calendar_today),
                  buildLabel("Fixed Reports", '${profileData!['fixedReports']}', icon: Icons.check_circle_outline),
                ],
              ),
            ),
          ),
        ),
      ),

    );
  }
}
