import 'package:blush_hush_admin/constants/styles.dart';
import 'package:blush_hush_admin/screens/project_screens/add_project_screen.dart';
import 'package:blush_hush_admin/screens/project_screens/project_detail_screen.dart';
import 'package:blush_hush_admin/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/nav_provider.dart';
import '../../provider/project_provider.dart';
import '../../provider/manager_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final List<String> _filterOptions = ['All', 'Ongoing', 'Completed'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().initialize();
      context.read<ManagerProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavProvider>(
      builder: (context, nav, _) {
        if (nav.openAddProject) {
          return AddProjectScreen(
            onClose: () {
              nav.resetAddProjectFlag();
            },
          );
        }

        return Scaffold(
          backgroundColor: Styles.backgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Projects", style: Styles.heading2),
                      IconButton(
                        onPressed: () async {
                          await context
                              .read<ProjectProvider>()
                              .refreshProjects();
                          await context
                              .read<ManagerProvider>()
                              .refreshManagers();
                        },
                        icon: Icon(Icons.refresh, color: Styles.primaryColor),
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Search Bar
                  SearchBarWidget(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),

                  SizedBox(height: 20),

                  // Filter Tabs
                  _buildFilterTabs(),

                  SizedBox(height: 20),

                  // Projects List
                  Expanded(child: _buildProjectsList()),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(50)),
            onPressed: () {
              nav.openAddProjectScreen();
            },
            backgroundColor: Styles.primaryColor,
            child: Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final option = _filterOptions[index];
          final isSelected = _selectedFilter == option;

          return Container(
            margin: EdgeInsets.only(right: 15),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = option;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Styles.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Styles.primaryColor : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectsList() {
    return Consumer2<ProjectProvider, ManagerProvider>(
      builder: (context, projectProvider, managerProvider, _) {
        if (projectProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        var projects = projectProvider.projects;

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          projects = projects.where((project) {
            final name = project['name']?.toString().toLowerCase() ?? '';
            final client = project['client']?.toString().toLowerCase() ?? '';
            final location =
                project['siteLocation']?.toString().toLowerCase() ?? '';
            final query = _searchQuery.toLowerCase();

            return name.contains(query) ||
                client.contains(query) ||
                location.contains(query);
          }).toList();
        }

        // Apply status filter
        if (_selectedFilter != 'All') {
          projects = projects.where((project) {
            final status = project['status']?.toString() ?? 'active';
            if (_selectedFilter == 'Ongoing') {
              return status == 'active' || status == 'ongoing';
            } else if (_selectedFilter == 'Completed') {
              return status == 'completed' || status == 'finished';
            }
            return true;
          }).toList();
        }

        if (projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No projects found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Try adjusting your search or filters',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            final managerId = project['manager_id'];
            final manager = managerProvider.managers.firstWhere(
              (m) => m['id'] == managerId,
              orElse: () => {'name': 'Unassigned'},
            );

            return _buildProjectCard(project, manager);
          },
        );
      },
    );
  }

  Widget _buildProjectCard(
    Map<String, dynamic> project,
    Map<String, dynamic> manager,
  ) {
    final projectName = project['name'] ?? 'Unnamed Project';
    final siteLocation = project['siteLocation'] ?? 'Location not specified';
    final managerName = manager['name'] ?? 'Unassigned';
    final status = project['status'] ?? 'active';
    final createdAt = project['createdAt'];

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Styles.containerbgcolor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectDetailScreen(project: project),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Main Content
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            projectName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Styles.primaryColor,
                            ),
                          ),
                        ),
                        _buildStatusChip(status),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Site Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Site Location: $siteLocation',
                            style: Styles.small,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    // Site Manager
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Site Manager: $managerName',
                            style: Styles.small,
                          ),
                        ),
                      ],
                    ),

                    // Created Date
                    if (createdAt != null) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Created: ${_formatDate(createdAt)}',
                            style: Styles.small,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'active':
      case 'ongoing':
        chipColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        statusText = 'Ongoing';
        break;
      case 'completed':
      case 'finished':
        chipColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        statusText = 'Completed';
        break;
      case 'paused':
        chipColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        statusText = 'Paused';
        break;
      default:
        chipColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        statusText = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      final dateTime = date.toDate();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    return 'Date not available';
  }
}
