import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class DailyGoalWidget extends StatelessWidget {
  const DailyGoalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProfile = authProvider.userProfile;
    final lang = userProfile?['primaryLanguage'] ?? 'amharic';
    final xpMap = userProfile?['xp'] ?? {};
    final currentXP = xpMap[lang] ?? 0;

    // Mock daily goal (in production, this would be stored in user profile)
    const dailyGoalXP = 50;
    final progress = (currentXP % dailyGoalXP) / dailyGoalXP;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.duoGreen.withValues(alpha: 0.1), AppTheme.duoBlue.withValues(alpha: 0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.duoGreen.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: AppTheme.duoYellow, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Daily Goal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(currentXP % dailyGoalXP)} / $dailyGoalXP XP',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.duoGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.duoGreen),
            ),
          ),
          if (progress >= 1.0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.duoGreen, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Goal completed! 🎉',
                  style: TextStyle(
                    color: AppTheme.duoGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
