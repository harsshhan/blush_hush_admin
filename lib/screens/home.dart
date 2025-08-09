import 'package:blush_hush_admin/constants/styles.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.background_color,
      body: Center(child: Text("Home"),),
    );
  }
}