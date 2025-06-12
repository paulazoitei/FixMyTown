
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'full_image_screen.dart';

class MyReportsAdminScreen extends StatefulWidget {
  const MyReportsAdminScreen({super.key});

  @override
  State<MyReportsAdminScreen> createState() => _MyReportsAdminScreenState();
}

class _MyReportsAdminScreenState extends State<MyReportsAdminScreen> {
  List<dynamic> reports = [];
  List<bool> expandedStates = [];
  bool isLoading = true;
  bool isDeleting = false;
  String? _normalizeStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'received':
        return 'Received';
      case 'in progress':
        return 'In Progress';
      case 'fixed':
        return 'Fixed';
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    final uri = Uri.parse("http://10.0.2.2:8081/api/v1/reports/admin/me");
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
        expandedStates = List.generate(reports.length, (_) => false);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
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
        child:  isLoading
            ? const Center(child: CircularProgressIndicator())
            : isDeleting
            ? const Center(child: CircularProgressIndicator())
            : reports.isEmpty
            ? const Center(
          child: Text(
            "No reports have been submitted in your area .",
            style: TextStyle(fontSize: 19, fontStyle: FontStyle.italic),
          ),
        )

            : Padding(
          padding: const EdgeInsets.only(top: 100),
          child: ListView.builder(
            itemCount: reports.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemBuilder: (context, index) {
              final report = reports[index];
              final title = report['title']?.toString() ?? "Untitled Report";
              final description = report['description']?.toString() ?? "No description";
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
                            _labelCoordinates(latitude, longitude),
                            _labelValueRow("Reported At:", createdAt, icon: Icons.access_time, iconColor: Colors.orange),

                            if (imageUrl != null && imageUrl.isNotEmpty) ...[
                              const SizedBox(height: 12),

                              const SizedBox(height: 6),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.photo_library, size: 24),
                                label: const Text("View Full Image"),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FullImageScreen(
                                        imageUrl: "http://10.0.2.2:8081$imageUrl",
                                      ),
                                    ),
                                  );
                                },
                              ),

                            ],

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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Status:",
                                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: _normalizeStatus(report['status']),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.2),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white70),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      dropdownColor: Colors.grey[800],
                                      style: const TextStyle(color: Colors.white),
                                      items: ['Received', 'In Progress', 'Fixed']
                                          .map((status) => DropdownMenuItem(
                                        value: status,
                                        child: Text(status),
                                      ))
                                          .toList(),
                                      onChanged: (value) async {
                                        if (value != null) {
                                          final prefs = await SharedPreferences.getInstance();
                                          final token = prefs.getString('jwtToken');
                                          await http.put(
                                            Uri.parse("http://10.0.2.2:8081/api/v1/reports/admin/${report['id']}/status"),
                                            headers: {
                                              "Authorization": "Bearer $token",
                                              "Content-Type": "application/json",
                                            },
                                            body: jsonEncode({'status': value}),
                                          );

                                          setState(() {
                                            reports[index]['status'] = value;
                                          });
                                        }
                                      },
                                    ),
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red.shade800,
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      icon: const Icon(Icons.delete_forever, size: 22, color: Colors.redAccent),
                                      label: const Text("Report Probably Fake – Delete"),

                                        onPressed: () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text("Confirm Deletion"),
                                              content: const Text("Are you sure you want to delete this report?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text("Cancel"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: const Text("Delete"),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirmed == true) {
                                            setState(() => isDeleting = true);
                                            final prefs = await SharedPreferences.getInstance();
                                            final token = prefs.getString('jwtToken');

                                            final response = await http.delete(
                                              Uri.parse("http://10.0.2.2:8081/api/v1/reports/admin/${report['id']}"),
                                              headers: {
                                                "Authorization": "Bearer $token",
                                              },
                                            );
                                            setState(() => isDeleting = false);

                                            if (!mounted) return;

                                            if (response.statusCode == 200) {
                                              setState(() {
                                                reports.removeAt(index);
                                                expandedStates.removeAt(index);
                                              });

                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text("Report deleted."),
                                                  ),
                                                );
                                              }

                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Failed to delete report.")),
                                              );

                                            }
                                          }
                                        },

                                    ),
                                    TextButton.icon(
                                      onPressed: () async {
                                        final prefs = await SharedPreferences.getInstance();
                                        final token = prefs.getString('jwtToken');

                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (_) => const Center(child: CircularProgressIndicator()),
                                        );

                                        final response = await http.post(
                                          Uri.parse("http://10.0.2.2:8081/api/v1/reports/admin/${report['id']}/ai-check"),
                                          headers: {
                                            "Authorization": "Bearer $token",
                                            "Content-Type": "application/json",
                                          },
                                        );
                                        Navigator.pop(context);

                                        if (response.statusCode == 200) {
                                          final aiVerdict = jsonDecode(response.body)['choices'][0]['message']['content'];

                                          showDialog(
                                            context: context,
                                            barrierDismissible: true,
                                            builder: (_) => Dialog(
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.smart_toy, color: Colors.green, size: 48),
                                                    const SizedBox(height: 16),
                                                    const Text(
                                                      "AI Verdict",
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Text(
                                                      aiVerdict,
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(fontSize: 16),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        OutlinedButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: const Text("Cancel"),
                                                        ),
                                                        ElevatedButton(

                                                            onPressed: () async {
                                                              Navigator.pop(context);
                                                              await Future.delayed(Duration(milliseconds: 100));

                                                              if (!mounted) return;

                                                              setState(() => isDeleting = true);
                                                              final deleteResponse = await http.delete(
                                                                Uri.parse("http://10.0.2.2:8081/api/v1/reports/admin/${report['id']}"),
                                                                headers: {
                                                                  "Authorization": "Bearer $token",
                                                                },
                                                              );
                                                              setState(() => isDeleting = false);

                                                              if (!mounted) return;

                                                              if (deleteResponse.statusCode == 200) {
                                                                setState(() {
                                                                  reports.removeAt(index);
                                                                  expandedStates.removeAt(index);
                                                                });
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  const SnackBar(content: Text("Report deleted based on AI check.")),
                                                                );
                                                              } else {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  const SnackBar(content: Text("Failed to delete report after AI check.")),
                                                                );
                                                              }
                                                            },

                                                            style: ElevatedButton.styleFrom(
                                                            backgroundColor: const Color(0xFF00695C),
                                                            foregroundColor: Colors.white,
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                          ),
                                                          child: const Text("Delete Report"),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );

                                        }
                                      },
                                      icon: const Icon(Icons.smart_toy, color: Colors.blueAccent),
                                      label: const Text("AI Check"),
                                    )


                                  ],
                                ),
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
