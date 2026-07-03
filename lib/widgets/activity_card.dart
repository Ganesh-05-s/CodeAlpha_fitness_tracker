import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity_model.dart';
import '../theme/app_theme.dart';

class ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback? onDelete;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onDelete,
  });

  // Get Icon based on activity type
  IconData _getIcon() {
    switch (activity.activityType.toLowerCase()) {
      case 'running':
        return Icons.directions_run_rounded;
      case 'walking':
        return Icons.directions_walk_rounded;
      case 'cycling':
        return Icons.directions_bike_rounded;
      case 'gym':
        return Icons.fitness_center_rounded;
      case 'yoga':
        return Icons.self_improvement_rounded;
      case 'swimming':
        return Icons.pool_rounded;
      default:
        return Icons.bolt_rounded;
    }
  }

  // Get Color theme based on activity type
  Color _getColor() {
    switch (activity.activityType.toLowerCase()) {
      case 'running':
        return const Color(0xFFF4511E); // Orange-Red
      case 'walking':
        return const Color(0xFFFB8C00); // Orange
      case 'cycling':
        return const Color(0xFF1E88E5); // Blue
      case 'gym':
        return AppTheme.primaryPurple; // Purple
      case 'yoga':
        return const Color(0xFF00897B); // Teal
      case 'swimming':
        return const Color(0xFF039BE5); // Light Blue
      default:
        return const Color(0xFF7E57C2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final timeStr = DateFormat('hh:mm a').format(activity.dateTime);
    final dateStr = DateFormat('MMM dd, yyyy').format(activity.dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon block
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getIcon(),
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              // Activity Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.activityType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${activity.duration} mins • $timeStr',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              // Calories & Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '+${activity.calories} kcal',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: onDelete,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
