import 'package:blush_hush_admin/constants/styles.dart';
import 'package:blush_hush_admin/provider/project_provider.dart';
import 'package:blush_hush_admin/widgets/image_viewer_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProjectUpdatesTimeline extends StatelessWidget {
  final String projectId;

  const ProjectUpdatesTimeline({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: context.read<ProjectProvider>().updatesStream(projectId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load updates',
              style: TextStyle(color: Colors.redAccent),
            ),
          );
        }
        final updates = snapshot.data ?? [];
        if (updates.isEmpty) {
          return Center(
            child: Text(
              'No updates yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(15),
          itemCount: updates.length,
          itemBuilder: (context, index) {
            final update = updates[index];
            final isLast = index == updates.length - 1;
            return _TimelineItem(update: update, isLast: isLast);
          },
        );
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final Map<String, dynamic> update;
  final bool isLast;

  const _TimelineItem({required this.update, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final String title = update['title']?.toString() ?? 'Untitled';
    final List<dynamic> imagesRaw = (update['images'] is List)
        ? update['images'] as List
        : const [];
    final List<String> images = imagesRaw.whereType<String>().toList();
    final dynamic date = update['date'];
    final String status = update['status']?.toString() ?? '';

    return Stack(
      children: [
        if (!isLast)
          Positioned(
            left: 11,
            top: 12,
            bottom: 0,
            child: Container(
              width: 2,
              color: Styles.primaryColor.withOpacity(0.3),
            ),
          ),
        Positioned(
          left: 6,
          top: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Styles.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 24),
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Styles.containerbgcolor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatLongDate(date),
                      style: TextStyle(
                        color: Styles.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (status.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Styles.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          status[0].toUpperCase() + status.substring(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                if (images.isNotEmpty) ...[
                  SizedBox(height: 12),
                  _ImagesGrid(imageUrls: images),
                ],
                SizedBox(height: 15),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, color: Styles.primaryColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

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
      final month = months[dt.month - 1];
      return '$month ${dt.day} ${dt.year}';
    }
    return 'Date not available';
  }
}

class _ImagesGrid extends StatelessWidget {
  final List<String> imageUrls;

  const _ImagesGrid({required this.imageUrls});

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter out invalid URLs
    final validUrls = imageUrls.where((url) => _isValidUrl(url)).toList();

    if (validUrls.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No valid images available',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
      );
    }

    final crossAxisCount = 3;
    final displayUrls = validUrls.take(6).toList();
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: displayUrls.length,
      itemBuilder: (context, index) {
        final url = displayUrls[index];
        final isLastAndMore =
            index == displayUrls.length - 1 &&
            validUrls.length > displayUrls.length;
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ImageViewerPage(imageUrls: validUrls, initialIndex: index),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: url,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.black12,
                        child: Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, color: Colors.black54),
                            SizedBox(height: 4),
                            Text(
                              'Image unable to load',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (isLastAndMore)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+${validUrls.length - displayUrls.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
