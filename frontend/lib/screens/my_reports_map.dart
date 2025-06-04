import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'report_details_screen.dart';

class MyReportsMapScreen extends StatefulWidget {
  const MyReportsMapScreen({super.key});

  @override
  State<MyReportsMapScreen> createState() => _MyReportsMapScreenState();
}

class _MyReportsMapScreenState extends State<MyReportsMapScreen> {
  final MapController _mapController = MapController();
  List<dynamic> myReports = [];

  @override
  void initState() {
    super.initState();
    fetchMyReports();
  }

  Future<void> fetchMyReports() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    final response = await http.get(
      Uri.parse("http://10.0.2.2:8081/api/v1/reports/user/me"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        myReports = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load your reports")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
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
          centerTitle: true,
          title: const Text(
            ' My Reports Map',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),

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
            markers: myReports.map((report) {
              final lat = double.tryParse(report['latitude'].toString());
              final lng = double.tryParse(report['longitude'].toString());
              if (lat == null || lng == null) return null;

              return Marker(
                point: LatLng(lat, lng),
                width: 60,
                height: 60,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportDetailsScreen(report: report),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.location_pin,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
              );
            }).whereType<Marker>().toList(),
          ),
        ],
      ),
    );
  }
}
