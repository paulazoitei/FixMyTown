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

  @override
  void initState() {
    super.initState();
    _initLocation(); // încarcă locația la deschidere
  }

  Future<void> _initLocation() async {
    try {
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
                }
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Address not found')),
                );
              }
              Navigator.pop(context);
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
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: const LatLng(47.1600, 27.5900),
              zoom: 12,
              interactiveFlags: InteractiveFlag.all,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                });
              },
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
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Colors.black),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'search',
                  onPressed: _searchAddress,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.search, color: Colors.black),
                ),
              ],
            ),
          ),
          if (_selectedLocation != null)
            DraggableScrollableSheet(
              initialChildSize: 0.35,
              minChildSize: 0.2,
              maxChildSize: 0.7,
              builder: (context, scrollController) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text("Report Issue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: "Title"),
                          validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _descController,
                          decoration: const InputDecoration(labelText: "Description"),
                          maxLines: 2,
                          validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.image),
                              label: const Text("Upload Photo"),
                            ),
                            const SizedBox(width: 10),
                            if (_selectedImage != null)
                              const Icon(Icons.check_circle, color: Colors.green),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _selectedLocation != null
                              ? "Location: ${_selectedLocation!.latitude.toStringAsFixed(5)}, ${_selectedLocation!.longitude.toStringAsFixed(5)}"
                              : "",
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _submitReport,
                          child: const Text("Send Report"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
