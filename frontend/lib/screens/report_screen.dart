import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final MapController _mapController = MapController();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  File? _selectedImage;
  LatLng? _selectedLocation;
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
  }
  void _showCustomDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.notifications_active, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00695C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("OK"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initLocation() async {
    try {
      FocusScope.of(context).unfocus();
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      final position = await Geolocator.getCurrentPosition();
      final LatLng pos = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = pos;
      });
      _mapController.move(pos, 16);

      Future.delayed(const Duration(milliseconds: 100), () {
        _sheetController.animateTo(0.65, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
      });
    } catch (_) {}
  }

  Future<void> _searchAddress() async {
    String query = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search address'),
        content: TextField(
          onChanged: (value) => query = value,
          decoration: const InputDecoration(hintText: 'Enter address...'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                List<Location> locations = await locationFromAddress(query);
                if (locations.isNotEmpty) {
                  final LatLng pos = LatLng(locations[0].latitude, locations[0].longitude);
                  setState(() {
                    _selectedLocation = pos;
                  });
                  _mapController.move(pos, 16);

                  Future.delayed(const Duration(milliseconds: 100), () {
                    _sheetController.animateTo(0.65, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
                  });
                }
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Address not found')),
                );
              }
              Navigator.pop(context);
              FocusScope.of(context).unfocus();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate() &&
        _selectedLocation != null &&
        _selectedImage != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('userId');
        final token = prefs.getString('jwtToken');

        if (userId == null || token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Utilizator neautentificat.")),
          );
          return;
        }

        final uri = Uri.parse("http://10.0.2.2:8081/api/v1/reports/submit");

        var request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['title'] = _titleController.text
          ..fields['description'] = _descController.text
          ..fields['latitude'] = _selectedLocation!.latitude.toString()
          ..fields['longitude'] = _selectedLocation!.longitude.toString()
          ..fields['userId'] = userId.toString()
          ..files.add(await http.MultipartFile.fromPath(
              'image', _selectedImage!.path));

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        print('Status: ${response.statusCode}');
        print('Body: $responseBody');

        if (response.statusCode == 200) {
          _showCustomDialog("Success", "Report was sent successfully!");

        } else if (response.statusCode == 403) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Acces interzis (403). Verifică tokenul.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Eroare la trimitere: $responseBody")),
          );
        }
      } catch (e) {
        print("Exceptie la trimitere: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Eroare internă la trimitere.")),
        );
      }
    } else {
      _showCustomDialog("Incomplete", "Please complete all fields and add a photo.");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: const LatLng(47.1600, 27.5900),
              zoom: 12,
              interactiveFlags: InteractiveFlag.all,
              onTap: (tapPosition, point) => setState(() => _selectedLocation = point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 100,
            right: 15,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'locate',
                  onPressed: _initLocation,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'search',
                  onPressed: _searchAddress,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
          ),
          if (_selectedLocation != null)
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.1,
              minChildSize: 0.08,
              maxChildSize: 0.95,
              builder: (context, scrollController) => Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/report_issue_background.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.report_problem, color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Text("Report Issue",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _titleController,
                              style: const TextStyle(color: Colors.white),
                              onTap: () => _sheetController.animateTo(0.65,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut),
                              decoration: InputDecoration(
                                labelText: "Title",
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),

                                prefixIcon: const Icon(Icons.title_outlined, color: Colors.white),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                fillColor: Colors.black.withOpacity(0.7),
                                filled: true,
                              ),
                              validator: (val) => val == null || val.isEmpty ? "Required" : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descController,
                              style: const TextStyle(color: Colors.white),
                              onTap: () => _sheetController.animateTo(0.75,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut),
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: "Description",
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),

                                prefixIcon: const Icon(Icons.description_outlined, color: Colors.white),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                fillColor: Colors.black.withOpacity(0.7),
                                filled: true,
                              ),
                              validator: (val) => val == null || val.isEmpty ? "Required" : null,
                            ),

                            const SizedBox(height: 16),
                            Row(
                              children: [
                                FilledButton.icon(
                                  onPressed: _pickImage,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.green[700],
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.image, color: Colors.white),
                                  label: const Text("Upload Photo", style: TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(width: 12),
                                if (_selectedImage != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedImage!,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 20, color: Colors.blue),
                                const SizedBox(width: 6),
                                Expanded(
                                  child:Text(
                                    "Location: ${_selectedLocation!.latitude.toStringAsFixed(5)}, ${_selectedLocation!.longitude.toStringAsFixed(5)}",
                                    style: const TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _submitReport,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  backgroundColor: Colors.green[700],
                                  elevation: 6,
                                  shadowColor: Colors.black87,
                                ),
                                icon: const Icon(Icons.send, color: Colors.white),
                                label: const Text("Send Report", style: TextStyle(fontSize: 16, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
