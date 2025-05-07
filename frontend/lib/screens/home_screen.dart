import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FixMyTown'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('jwtToken');
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to FixMyTown! ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                icon: Icons.add_location_alt,
                title: 'Report a Problem',
                description:
                'Take a picture, select category, and send your report.',
                onTap: () {
                  // TODO: navigate to report screen
                },
              ),
              _buildFeatureCard(
                icon: Icons.map,
                title: 'Interactive Map',
                description:
                'View reported problems with filters by category and status.',
                onTap: () {
                  // TODO: navigate to map screen
                },
              ),
              _buildFeatureCard(
                icon: Icons.notifications_active,
                title: 'Notifications',
                description:
                'Get updates when your reported issues progress.',
                onTap: () {
                  // TODO: navigate to notifications screen
                },
              ),
              _buildFeatureCard(
                icon: Icons.thumb_up,
                title: 'Vote Problems',
                description:
                'Support the most important issues reported by citizens.',
                onTap: () {
                  // TODO: navigate to voting screen
                },
              ),
              _buildFeatureCard(
                icon: Icons.feedback,
                title: 'Feedback & Comments',
                description:
                'Discuss and confirm solutions with your community.',
                onTap: () {
                  // TODO: navigate to feedback screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
