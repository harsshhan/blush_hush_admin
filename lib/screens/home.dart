import 'package:blush_hush_admin/constants/styles.dart';
import 'package:blush_hush_admin/provider/manager_provider.dart';
import 'package:blush_hush_admin/provider/project_provider.dart';
import 'package:blush_hush_admin/provider/client_provider.dart';
import 'package:blush_hush_admin/widgets/dashboard_widget.dart';
import 'package:blush_hush_admin/widgets/recent_activity_list.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../provider/nav_provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with WidgetsBindingObserver {
  String _greeting = "Good Morning";
  int managerCount = 0;
  int totalProjects = 0;
  int onGoingProjects = 0;
  int totClients = 0;
  bool _isLoading = true;

  void _setGreeting() {
    final currentTime = DateTime.now();
    final hour = currentTime.hour;

    if (hour < 12) {
      _greeting = "Good Morning, Admin!";
    } else if (hour < 18) {
      _greeting = "Good Afternoon, Admin!";
    } else {
      _greeting = "Good Evening, Admin!";
    }
  }

  Future<void> _initializeDashboard() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Initialize providers
      await context.read<ProjectProvider>().initialize();
      await context.read<ManagerProvider>().initialize();
      await context.read<ClientProvider>().initialize();

      // Get project counts
      final projectProvider = context.read<ProjectProvider>();
      final managerProvider = context.read<ManagerProvider>();
      final clientProvider = context.read<ClientProvider>();

      setState(() {
        totalProjects = projectProvider.projectCount;
        onGoingProjects = projectProvider.getProjectsByStatus('Ongoing').length;
        managerCount = managerProvider.managerCount;
        totClients = clientProvider.clientCount;
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing dashboard: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _setGreeting();

    // Add observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Initialize dashboard after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDashboard();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will be called when the screen becomes visible again
    // Useful for refreshing data when returning from other screens
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh dashboard when app becomes visible
    if (state == AppLifecycleState.resumed) {
      _initializeDashboard();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  DateTime now = DateTime.now();
  String formatedDate = DateFormat('EEEE, d MMM yyyy').format(now);

  return Scaffold(
    backgroundColor: Styles.backgroundColor,
    body: SafeArea(
      child: RefreshIndicator(
        onRefresh: _initializeDashboard,
        color: Styles.primaryColor,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Text(formatedDate.toUpperCase(), style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text(_greeting, style: Styles.heading1),
            const SizedBox(height: 10),
            Text("Dashboard", style: Styles.heading1),
            const SizedBox(height: 15),

            if (_isLoading)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Styles.primaryColor),
                    const SizedBox(height: 10),
                    Text(
                      'Loading dashboard...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              )
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DashboardWidget(
                      count: totalProjects,
                      title: "TOTAL PROJECTS",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DashboardWidget(
                      count: onGoingProjects,
                      title: "ONGOING PROJECTS",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DashboardWidget(
                      count: managerCount,
                      title: "SITE MANAGERS",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DashboardWidget(
                      count: totClients,
                      title: "TOTAL CLIENTS",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      Styles.primaryColor,
                    ),
                  ),
                  onPressed: () {
                    context.read<NavProvider>().openAddProjectScreen();
                  },
                  child: const Text(
                    "Add New Project",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text("Recent Activity", style: Styles.heading1),
              const SizedBox(height: 10),
              const RecentActivityList(),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    ),
  );
}
}
