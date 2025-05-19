// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:animate_do/animate_do.dart';
//
// class MyReportsScreen extends StatefulWidget {
//   const MyReportsScreen({super.key});
//
//   @override
//   State<MyReportsScreen> createState() => _MyReportsScreenState();
// }
//
// class _MyReportsScreenState extends State<MyReportsScreen> {
//   List<dynamic> reports = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchReports();
//   }
//
//   Future<void> fetchReports() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('jwtToken');
//
//     final uri = Uri.parse("http://10.0.2.2:8081/api/v1/reports/user/me");
//     final response = await http.get(
//       uri,
//       headers: {
//         "Authorization": "Bearer $token",
//         "Content-Type": "application/json",
//       },
//     );
//
//     if (response.statusCode == 200) {
//       setState(() {
//         reports = jsonDecode(response.body);
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Error loading reports.")),
//       );
//     }
//   }
//
//   String formatDateTime(String? raw) {
//     if (raw == null) return 'Unknown';
//     try {
//       final dateTime = DateTime.parse(raw);
//       return "${dateTime.day.toString().padLeft(2, '0')}-"
//           "${dateTime.month.toString().padLeft(2, '0')}-"
//           "${dateTime.year} at "
//           "${dateTime.hour.toString().padLeft(2, '0')}:"
//           "${dateTime.minute.toString().padLeft(2, '0')}";
//     } catch (_) {
//       return raw;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: Text(
//           "My Reports",
//           style: GoogleFonts.poppins(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xff00b09b), Color(0xff96c93d)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xfff5fefc), Color(0xffe9f5e3)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: reports.isEmpty
//             ? const Center(child: CircularProgressIndicator())
//             : Padding(
//           padding: const EdgeInsets.only(top: 100),
//           child: ListView.builder(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             itemCount: reports.length,
//             itemBuilder: (context, index) {
//               final report = reports[index];
//               final title = report['title']?.toString() ?? "Untitled Report";
//               final description = report['description']?.toString() ?? "No description";
//               final zone = report['zone']?.toString() ?? "Unknown";
//               final latitude = report['latitude']?.toString() ?? "N/A";
//               final longitude = report['longitude']?.toString() ?? "N/A";
//               final createdAt = formatDateTime(report['createdAt']?.toString());
//               final imageUrl = report['imageUrl']?.toString();
//
//               return SlideInUp(
//                 duration: Duration(milliseconds: 500 + (index * 100)),
//                 child: Container(
//                   margin: const EdgeInsets.only(bottom: 20),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xffa8e063), Color(0xff56ab2f)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(24),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black26,
//                         blurRadius: 10,
//                         offset: const Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       if (imageUrl != null && imageUrl.isNotEmpty)
//                         ClipRRect(
//                           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//                           child: Image.network(
//                             "http://10.0.2.2:8081$imageUrl",
//                             height: 200,
//                             width: double.infinity,
//                             fit: BoxFit.cover,
//                             errorBuilder: (_, __, ___) => Container(
//                               height: 200,
//                               color: Colors.grey[200],
//                               child: const Center(
//                                 child: Icon(Icons.image_not_supported, size: 40),
//                               ),
//                             ),
//                           ),
//                         ),
//                       Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: const [
//                                 Icon(Icons.article_outlined, color: Colors.white),
//                                 SizedBox(width: 8),
//                                 Text("Report Details",
//                                     style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white)),
//                               ],
//                             ),
//                             const SizedBox(height: 12),
//                             _labelValue("Title:", title),
//                             _labelValue("Description:", description),
//                             _labelValueRow("Zone:", zone, icon: Icons.map, iconColor: Colors.greenAccent),
//                             _labelValueRow(
//                               "Location:",
//                               "Lat: $latitude | Lng: $longitude",
//                               icon: Icons.location_on,
//                               iconColor: Colors.red,
//                             ),
//                             _labelValueRow(
//                               "Reported At:",
//                               createdAt,
//                               icon: Icons.access_time,
//                               iconColor: Colors.orange,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _labelValue(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label,
//               style: GoogleFonts.poppins(
//                   fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
//           Text(value,
//               style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
//         ],
//       ),
//     );
//   }
//
//   Widget _labelValueRow(String label, String value,
//       {IconData? icon, Color? iconColor}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label,
//               style: GoogleFonts.poppins(
//                   fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
//           const SizedBox(height: 4),
//           Row(
//             children: [
//               if (icon != null)
//                 Icon(icon, size: 18, color: iconColor ?? Colors.white),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: Text(value,
//                     style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  List<dynamic> reports = [];
  List<bool> expandedStates = [];

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    final uri = Uri.parse("http://10.0.2.2:8081/api/v1/reports/user/me");
    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        reports = jsonDecode(response.body);
        expandedStates = List.filled(reports.length, false);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error loading reports.")),
      );
    }
  }

  String formatDateTime(String? raw) {
    if (raw == null) return 'Unknown';
    try {
      final dateTime = DateTime.parse(raw);
      return "${dateTime.day.toString().padLeft(2, '0')}-"
          "${dateTime.month.toString().padLeft(2, '0')}-"
          "${dateTime.year} at "
          "${dateTime.hour.toString().padLeft(2, '0')}:"
          "${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "My Reports",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
        child: reports.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.only(top: 100),
          child: ListView.builder(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: reports.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemBuilder: (context, index) {
              final report = reports[index];
              final title = report['title']?.toString() ?? "Untitled Report";
              final description = report['description']?.toString() ?? "No description";
              final zone = report['zone']?.toString() ?? "Unknown";
              final latitude = report['latitude']?.toString() ?? "N/A";
              final longitude = report['longitude']?.toString() ?? "N/A";
              final createdAt = formatDateTime(report['createdAt']?.toString());
              final imageUrl = report['imageUrl']?.toString();

              return FadeIn(
                duration: Duration(milliseconds: 500 + (index * 100)),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          child: Image.network(
                            "http://10.0.2.2:8081$imageUrl",
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.image_not_supported, size: 40),
                              ),
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.article_outlined, color: Colors.white),
                                SizedBox(width: 8),
                                Text("Report Details",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _labelValue("Title:", title),
                            _labelValue("Description:", description),
                            _labelValueRow("Zone:", zone, icon: Icons.map, iconColor: Colors.greenAccent),
                            _labelCoordinates(latitude, longitude),
                            _labelValueRow("Reported At:", createdAt, icon: Icons.access_time, iconColor: Colors.orange),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  expandedStates[index] = !expandedStates[index];
                                });
                              },
                              child: Text(
                                expandedStates[index] ? 'Hide Details' : 'View More',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                            if (expandedStates[index])
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text("Status: In Progress\nFeedback: Will be inspected soon...",
                                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _labelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
          Text(value, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _labelValueRow(String label, String value, {IconData? icon, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
          const SizedBox(height: 4),
          Row(
            children: [
              if (icon != null) Icon(icon, size: 18, color: iconColor ?? Colors.white),
              const SizedBox(width: 6),
              Expanded(
                child: Text(value,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _labelCoordinates(String lat, String lng) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Location:",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
          const SizedBox(height: 4),
          Text("Lat: $lat",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
          Text("Lng: $lng",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }
}
