import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class LevelCard extends StatelessWidget {
  final String levelName;
  final double progress; // 0.0 to 1.0
  final bool isLocked;
  final String? lockedReason;
  final int xp;
  final VoidCallback? onTap; // Made optional

  const LevelCard({
    super.key,
    required this.levelName,
    required this.progress,
    required this.isLocked,
    this.lockedReason,
    required this.xp,
    this.onTap, // No longer required
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    Color darkColor;
    String description;
    IconData icon;

    switch (levelName) {
      case 'Basic':
        color = AppTheme.duoGreen;
        darkColor = AppTheme.duoDarkGreen;
        description = "Foundations";
        icon = Icons.terrain;
        break;
      case 'Intermediate':
        color = AppTheme.duoBlue;
        darkColor = Colors.blue[800]!;
        description = "Sentence Building";
        icon = Icons.explore;
        break;
      case 'Advanced':
        color = AppTheme.duoOrange;
        darkColor = Colors.orange[800]!;
        description = "Fluency";
        icon = Icons.workspace_premium;
        break;
      default:
        color = Colors.grey;
        darkColor = Colors.grey[700]!;
        description = "";
        icon = Icons.help;
    }

    if (isLocked) {
      color = AppTheme.duoGray;
      darkColor = Colors.grey[600]!;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? null : onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: darkColor,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background Icon
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    icon,
                    size: 140,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              levelName.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              description,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            if (isLocked)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.lock, color: Colors.white, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      lockedReason ?? "LOCKED",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Row(
                                children: [
                                  const Icon(Icons.stars, color: AppTheme.duoYellow, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$xp XP',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Progress Indicator
                      if (!isLocked)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 8,
                                backgroundColor: Colors.black12,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
