import 'package:blush_hush_admin/constants/styles.dart';
import 'package:blush_hush_admin/screens/client/client_screen.dart';
import 'package:blush_hush_admin/screens/home.dart';
import 'package:blush_hush_admin/screens/manager/manager_screen.dart';
import 'package:blush_hush_admin/screens/project_screens/project_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/nav_provider.dart';


class HomeScafold extends StatelessWidget {
  const HomeScafold({super.key});

  final _screens = const [
    HomeTab(),
    ProjectScreen(),
    ClientScreen(),
    ManagerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavProvider>();

    return Scaffold(
      body: _screens[navProvider.index],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Styles.primaryColor,
        unselectedItemColor: Styles.iconColor,
        showUnselectedLabels: true,
        currentIndex: navProvider.index,
        onTap: (index) {
          navProvider.setIndex(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Projects"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Clients"),
          BottomNavigationBarItem(icon: Icon(Icons.manage_accounts), label: "Managers"),
        ],
      ),
    );
  }
}