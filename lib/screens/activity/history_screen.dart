import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/activity_provider.dart';
import '../../models/activity_model.dart';
import '../../widgets/activity_card.dart';
import '../../theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // Helper method to group activities by absolute dates
  Map<String, List<ActivityModel>> _groupActivitiesByDate(List<ActivityModel> list) {
    final Map<String, List<ActivityModel>> groups = {};
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final yesterdayStr = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));

    for (var activity in list) {
      final activityDateStr = DateFormat('yyyy-MM-dd').format(activity.dateTime);
      String heading;
      if (activityDateStr == todayStr) {
        heading = 'Today';
      } else if (activityDateStr == yesterdayStr) {
        heading = 'Yesterday';
      } else {
        heading = DateFormat('EEEE, MMMM d, yyyy').format(activity.dateTime);
      }

      if (!groups.containsKey(heading)) {
        groups[heading] = [];
      }
      groups[heading]!.add(activity);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    final activities = activityProvider.activities;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
        actions: [
          if (activities.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
              onPressed: () {
                _showClearAllDialog(context, activityProvider);
              },
            )
        ],
      ),
      body: SafeArea(
        child: activities.isEmpty
            ? _buildEmptyState(context)
            : _buildGroupedListView(context, activityProvider, activities),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Friendly Illustration Ring
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                size: 56,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Workouts Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "You haven't logged any activities yet. Start logging your workouts to see your summary history here!",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Open Add screen
                Navigator.pushNamed(context, '/add');
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Log First Activity'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedListView(
    BuildContext context,
    ActivityProvider provider,
    List<ActivityModel> list,
  ) {
    final groupedMap = _groupActivitiesByDate(list);
    final dateKeys = groupedMap.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: dateKeys.length,
      itemBuilder: (context, index) {
        final dateHeading = dateKeys[index];
        final dayActivities = groupedMap[dateHeading]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 12.0, left: 4.0),
              child: Text(
                dateHeading,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // Sublist of Activities
            ...dayActivities.map((activity) {
              return Dismissible(
                key: Key('activity_${activity.id}'),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  if (activity.id != null) {
                    provider.deleteActivity(activity.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Deleted ${activity.activityType} workout'),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'UNDO',
                          textColor: AppTheme.accentLavender,
                          onPressed: () {
                            provider.addActivity(
                              type: activity.activityType,
                              duration: activity.duration,
                              calories: activity.calories,
                              dateTime: activity.dateTime,
                            );
                          },
                        ),
                      ),
                    );
                  }
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                child: ActivityCard(
                  activity: activity,
                  onDelete: () {
                    if (activity.id != null) {
                      _showDeleteConfirmDialog(context, provider, activity);
                    }
                  },
                ),
              );
            }).toList(),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, ActivityProvider provider, ActivityModel activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout?', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this ${activity.activityType} workout?', style: const TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textLight, fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () {
              provider.deleteActivity(activity.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted ${activity.activityType} workout'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, ActivityProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Workouts?', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: const Text('This will delete all logged physical activities permanently. This action cannot be undone.', style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textLight, fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () {
              provider.clearAllUserData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cleared all workouts history'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.redAccent, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
