import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';

class ReportsMapScreen extends StatefulWidget {
  const ReportsMapScreen({super.key});

  @override
  State<ReportsMapScreen> createState() => _ReportsMapScreenState();
}

class _ReportsMapScreenState extends State<ReportsMapScreen> {
  final MapController _mapController = MapController();
  List<dynamic> reports = [];

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    final response = await http.get(
      Uri.parse("http://10.0.2.2:8081/api/v1/reports/all"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        reports = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load reports")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports Map"),
        backgroundColor: Colors.green,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(47.1600, 27.5900),
          zoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: reports.map((report) {
              final lat = double.tryParse(report['latitude'].toString());
              final lng = double.tryParse(report['longitude'].toString());

              if (lat == null || lng == null) return null;

              return Marker(
                point: LatLng(lat, lng),
                width: 50,
                height: 50,
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      backgroundColor: Colors.white,
                      builder: (_) => _buildReportDetails(report),
                    );
                  },
                  child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                ),

              );
            }).whereType<Marker>().toList(),
          ),
        ],
      ),
    );
  }
  Widget _buildReportDetails(dynamic report) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            report['title'] ?? 'No title',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            report['description'] ?? 'No description',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (report['status'] != null)
            Row(
              children: [
                const Icon(Icons.info, size: 18, color: Colors.blueAccent),
                const SizedBox(width: 6),
                Text(
                  "Status: ${report['status']}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          const SizedBox(height: 12),
          if (report['imageUrl'] != null && report['imageUrl'].toString().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "http://10.0.2.2:8081${report['imageUrl']}",
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(child: Text("Image not available")),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

}
