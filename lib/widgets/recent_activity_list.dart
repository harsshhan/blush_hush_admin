import 'package:blush_hush_admin/constants/styles.dart';
import 'package:blush_hush_admin/provider/project_provider.dart';
import 'package:blush_hush_admin/screens/project_screens/project_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key});

  String _formatLongDate(dynamic date) {
    if (date is Timestamp) {
      final dt = date.toDate();
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${months[dt.month - 1]} ${dt.day} ${dt.year}';
    }
    return 'Date not available';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: context.read<ProjectProvider>().recentUpdatesStream(
            limit: 10,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(color: Styles.primaryColor),
                ),
              );
            }
            if (snapshot.hasError) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Failed to load recent activity',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    SizedBox(height: 6),
                    Text(
                      snapshot.error.toString(),
                      style: TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ],
                ),
              );
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No recent activity',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                final update = items[index];
                final String title =
                    update['title']?.toString() ?? 'Untitled update';
                final String status = update['status']?.toString() ?? '';
                final dynamic date = update['date'];
                final String projectId = update['projectId'];

                return Container(
                  decoration: BoxDecoration(
                    color: Styles.containerbgcolor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: InkWell(
                    onTap: () async {
                      final project = context
                          .read<ProjectProvider>()
                          .getProjectById(projectId);
                      if (project == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProjectDetailScreen(
                            project: project,
                            initialTabIndex: 1,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color: Styles.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Styles.primaryColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      _formatLongDate(date),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                if (status.isNotEmpty) ...[
                                  SizedBox(height: 6),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Styles.primaryColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      status[0].toUpperCase() +
                                          status.substring(1),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
