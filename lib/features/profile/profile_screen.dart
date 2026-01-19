import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import 'daily_goal_widget.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProfile = authProvider.userProfile;
    final lang = userProfile?['primaryLanguage'] ?? 'amharic';
    
    // Total XP across all languages
    final languagesMap = userProfile?['languages'] ?? {};
    int totalXPAcrossAll = 0;
    languagesMap.forEach((key, data) {
      totalXPAcrossAll += (data['xp'] ?? 0) as int;
    });

    // Streak is top-level
    final int streak = userProfile?['streak'] ?? 0;
    
    // Completed lessons (total across all languages for general stat?)
    int totalCompleted = 0;
    languagesMap.forEach((key, data) {
       final completed = data['completedLessons'] ?? [];
       totalCompleted += completed.length as int;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.duoGray),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
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
                   _buildStatCard(context, Icons.flash_on, '$streak', 'Streak', AppTheme.duoOrange),
                   _buildStatCard(context, Icons.stars, '$totalXPAcrossAll', 'Total XP', AppTheme.duoBlue),
                   _buildStatCard(context, Icons.check_circle, '$totalCompleted', 'Lessons', AppTheme.duoYellow),
                   _buildStatCard(
                     context, 
                     Icons.language, 
                     lang[0].toUpperCase() + lang.substring(1), 
                     'Learning', 
                     AppTheme.duoGreen,
                     onTap: () => _showLanguagePicker(context, authProvider),
                   ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Daily Goal Widget
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: DailyGoalWidget(),
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

  Widget _buildStatCard(BuildContext context, IconData icon, String value, String label, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.duoLightGray, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                  Text(label, style: const TextStyle(color: AppTheme.duoGray, fontSize: 10), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Switch Language', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _langTile(context, authProvider, 'Amharic', 'amharic'),
            _langTile(context, authProvider, 'Afaan Oromo', 'afaan oromo'),
            _langTile(context, authProvider, 'Tigregna', 'tigregna'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _langTile(BuildContext context, AuthProvider authProvider, String title, String code) {
    final currentLang = authProvider.userProfile?['primaryLanguage'] ?? 'amharic';
    final isSelected = currentLang == code;

    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.duoGreen) : null,
      onTap: () {
        if (!isSelected) {
          authProvider.setPrimaryLanguage(code);
        }
        Navigator.pop(context);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
