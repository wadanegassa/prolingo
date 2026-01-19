import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../lessons/lesson_provider.dart';
import 'settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.duoGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildSectionHeader('Learning'),
          _buildSwitchTile(
            'Daily Reminders',
            'Get notified to practice daily',
            Icons.notifications_active,
            settings.dailyReminders,
            (val) => settings.setDailyReminders(val),
          ),
          _buildSwitchTile(
            'Sound Effects',
            'Play sounds for correct/incorrect answers',
            Icons.volume_up,
            settings.soundEffects,
            (val) => settings.setSoundEffects(val),
          ),
          _buildSwitchTile(
            'Haptic Feedback',
            'Vibrate on interactions',
            Icons.vibration,
            settings.hapticFeedback,
            (val) => settings.setHapticFeedback(val),
          ),
          _buildSwitchTile(
            'Dark Mode',
            'Use a darker color theme',
            Icons.dark_mode,
            settings.isDarkMode,
            (val) => settings.setDarkMode(val),
          ),
          const Divider(height: 40),
          _buildSectionHeader('Account'),
          _buildListTile(
            'Language Preferences',
            'Manage your learning languages',
            Icons.language,
            () {
              // TODO: Navigate to language manager
            },
          ),
          _buildListTile(
            'Reseed Content',
            'Reload lessons with latest structure',
            Icons.refresh,
            () {
              _showReseedDialog(context);
            },
            textColor: AppTheme.duoOrange,
          ),
          _buildListTile(
            'Reset Progress',
            'Start from the beginning',
            Icons.restart_alt,
            () {
              _showResetDialog(context);
            },
            textColor: AppTheme.duoRed,
          ),
          const Divider(height: 40),
          _buildSectionHeader('About'),
          _buildListTile(
            'Privacy Policy',
            'Read our privacy policy',
            Icons.privacy_tip,
            () {},
          ),
          _buildListTile(
            'Terms of Service',
            'View terms and conditions',
            Icons.description,
            () {},
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.duoRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('LOG OUT', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.duoGray,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.duoBlue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppTheme.duoGreen.withValues(alpha: 0.5),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTheme.duoGreen;
          }
          return null;
        }),
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppTheme.duoBlue),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showReseedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reseed Content?'),
        content: const Text(
          'This will reload all lesson content with the latest structure. Your progress will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final lessonProvider = Provider.of<LessonProvider>(context, listen: false);
              final lang = authProvider.userProfile?['primaryLanguage'] ?? 'amharic';
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
              
              // Reseed with timeout safety
              try {
                final seededCount = await lessonProvider.seedData(lang).timeout(
                  const Duration(seconds: 15),
                  onTimeout: () => throw 'Connection timed out. Please try again.',
                );
                
                if (context.mounted) {
                  Navigator.pop(context); // Hide loading
                  if (seededCount > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Successfully seeded $seededCount units!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Seeding failed. Please check your internet.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                 if (context.mounted) {
                   Navigator.of(context).pop(); // Ensure loading is popped
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                   );
                 }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.duoOrange),
            child: const Text('RESEED'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will delete all your progress. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Dialog
              
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
              
              try {
                await authProvider.resetProgress().timeout(
                  const Duration(seconds: 10),
                  onTimeout: () => throw 'Reset timed out. Please try again.',
                );
                
                if (context.mounted) {
                  Navigator.pop(context); // Hide loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Progress has been reset.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop(); // Ensure loading is popped
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.duoRed),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }
}
