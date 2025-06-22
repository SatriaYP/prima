import 'package:flutter/material.dart';

class RecentActivitiesWidget extends StatelessWidget {
  final List<ActivityItem> activities;

  const RecentActivitiesWidget({
    Key? key,
    required this.activities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aktivitas Terbaru',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (activities.isEmpty)
              const Center(
                child: Text('Tidak ada aktivitas terbaru'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Icon(activity.icon),
                    ),
                    title: Text(activity.title),
                    subtitle: Text(activity.subtitle),
                    trailing: Text(activity.timeAgo),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class ActivityItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String timeAgo;

  const ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
  });
}
