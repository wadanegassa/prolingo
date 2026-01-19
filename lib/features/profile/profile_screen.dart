import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProfile = authProvider.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.duoGray),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.duoLightGray,
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProfile?['name'] ?? 'Guest User',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Joined ${userProfile?['createdAt'] != null ? userProfile!['createdAt'].toString().substring(0, 10) : 'N/A'}',
                          style: const TextStyle(color: AppTheme.duoGray),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Stats Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.2,
                children: [
                   _buildStatCard(context, Icons.flash_on, '${userProfile?['streak'] ?? 0}', 'Streak', AppTheme.duoOrange),
                   _buildStatCard(context, Icons.stars, '${userProfile?['xp'] ?? 0}', 'Total XP', AppTheme.duoBlue),
                   _buildStatCard(context, Icons.emoji_events, '${userProfile?['level'] ?? 1}', 'Level', AppTheme.duoYellow),
                   _buildStatCard(context, Icons.language, 'Amharic', 'Learning', AppTheme.duoGreen),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Friend Activity Highlight (Placeholder)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Icon(Icons.group, size: 40, color: AppTheme.duoGray),
                      const SizedBox(height: 12),
                      const Text(
                        'Learn with friends!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Follow your friends to see their progress and stay motivated.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.duoGray),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('FIND FRIENDS'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => authProvider.logout(),
              child: const Text('LOG OUT', style: TextStyle(color: AppTheme.duoRed, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.duoLightGray, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(label, style: const TextStyle(color: AppTheme.duoGray, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
