import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/background_home_screen.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.build, color: Colors.white, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'FixMyTown',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(
                          cardColor: Colors.white.withOpacity(0.95),
                        ),
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white,size:30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          onSelected: (value) async {
                            if (value == 'logout') {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.remove('jwtToken');
                              if (context.mounted) {
                                Navigator.pushReplacementNamed(context, '/login');
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'logout',
                              child: ListTile(
                                leading: Icon(Icons.logout, color: Colors.red),
                                title: Text('Logout'),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Welcome to FixMyTown!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildFeatureCard(
                          icon: Icons.add_location_alt,
                          title: 'Report',
                          onTap: () => Navigator.pushNamed(context, '/report'),
                        ),
                        _buildFeatureCard(
                          icon: Icons.article,
                          title: 'My Reports',
                          onTap: () => Navigator.pushNamed(context, '/myReports'),
                        ),
                        _buildFeatureCard(
                          icon: Icons.notifications_active,
                          title: 'Alerts',
                          onTap: () => Navigator.pushNamed(context, '/notifications'),
                        ),
                        _buildFeatureCard(
                          icon: Icons.thumb_up,
                          title: 'Vote',
                          onTap: () => Navigator.pushNamed(context, '/vote'),
                        ),
                        _buildFeatureCard(
                          icon: Icons.feedback,
                          title: 'Comments',
                          onTap: () => Navigator.pushNamed(context, '/feedback'),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/change-password'),
                      icon: const Icon(Icons.lock, color: Colors.white,size: 25),
                      label: const Text(
                        "Change Password",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Color(0xFF2E7D32)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
