import 'package:flutter/material.dart';

import '../constants/styles.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.background_color,
      body: Center(child: Text("Client Screen"),),
    );
  }
}