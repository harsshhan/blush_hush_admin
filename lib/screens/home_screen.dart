import 'package:blush_hush_admin/constants/styles.dart';
import 'package:blush_hush_admin/screens/client_screen.dart';
import 'package:blush_hush_admin/screens/home.dart';
import 'package:blush_hush_admin/screens/manager_screen.dart';
import 'package:blush_hush_admin/screens/project_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final _screens = [
    const HomeTab(),
    const ProjectScreen(),
    const ClientScreen(),
    const ManagerScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Styles.background_color,
        selectedItemColor: Styles.primary_color,
        unselectedItemColor: Styles.icon_color,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home),label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.work),label: "Projects"),
          BottomNavigationBarItem(icon: Icon(Icons.people),label: "Clients"),
          BottomNavigationBarItem(icon: Icon(Icons.manage_accounts),label: "Managers"),
          
        ]),
    );
  }
}