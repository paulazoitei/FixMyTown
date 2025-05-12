import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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

  void _submitReport() {
    if (_formKey.currentState!.validate() && _selectedLocation != null) {
      print('Location: $_selectedLocation');
      print('Title: ${_titleController.text}');
      print('Description: ${_descController.text}');
      print('Image: ${_selectedImage?.path}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location and complete the form')),
      );
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
                  color: Colors.white,
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
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800])),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _titleController,
                              onTap: () => _sheetController.animateTo(0.65, duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                              decoration: InputDecoration(
                                labelText: "Title",
                                prefixIcon: const Icon(Icons.title_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                fillColor: Colors.purple[50], // <== Adaugă asta
                                filled: true,
                              ),
                              validator: (val) => val == null || val.isEmpty ? "Required" : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descController,
                              onTap: () => _sheetController.animateTo(0.75, duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: "Description",
                                prefixIcon: const Icon(Icons.description_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                fillColor: Colors.purple[50], // <== Adaugă asta
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
                                  child: Text(
                                    "Location: ${_selectedLocation!.latitude.toStringAsFixed(5)}, ${_selectedLocation!.longitude.toStringAsFixed(5)}",
                                    style: const TextStyle(fontSize: 14),
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
