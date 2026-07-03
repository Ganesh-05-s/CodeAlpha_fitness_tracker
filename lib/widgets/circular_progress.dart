import 'package:flutter/material.dart';

class GoalProgressRing extends StatelessWidget {
  final double percentage; // 0.0 to 1.0+
  final String title;
  final String subtitle;
  final IconData icon;
  final Color progressColor;
  final Color backgroundColor;

  const GoalProgressRing({
    super.key,
    required this.percentage,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Clamp to at least 0.0 and maximum 1.0 for progress circle rendering
    final double displayPercent = percentage.clamp(0.0, 1.0);
    final int percentInt = (percentage * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress indicator
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Track
              SizedBox(
                width: 75,
                height: 75,
                child: CircularProgressIndicator(
                  value: 1.0,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(backgroundColor),
                  strokeWidth: 8,
                ),
              ),
              // Progress Line
              SizedBox(
                width: 75,
                height: 75,
                child: CircularProgressIndicator(
                  value: displayPercent,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Center Icon
              Icon(
                icon,
                color: progressColor,
                size: 28,
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          // Percentage badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: progressColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$percentInt%',
              style: TextStyle(
                color: progressColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
