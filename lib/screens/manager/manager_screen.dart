import 'dart:async';
import 'dart:math';
import 'package:blush_hush_admin/widgets/name_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:blush_hush_admin/widgets/add_manager_widget.dart';
import 'package:blush_hush_admin/widgets/search_bar_widget.dart';
import '../../constants/styles.dart';
import '../../provider/manager_provider.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  void _onSearchFilter(BuildContext context, String query) {
    Provider.of<ManagerProvider>(context, listen: false).filterManagers(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Managers", style: Styles.heading2),
              SizedBox(height: 20),
              SearchBarWidget(
                onChanged: (query) => _onSearchFilter(context, query),
              ),
              SizedBox(height: 20),
              Consumer<ManagerProvider>(
                builder: (context, provider, _) {
                  final managers = provider.filteredManagers;
                  return Expanded(
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : managers.isEmpty
                        ? const Center(child: Text("No Managers Found"))
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: managers.length,
                            itemBuilder: (context, index) {
                              final manager = managers[index];
                              return ProfileDetailCard(name: manager['name'],email: manager['email'],);
                            },
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Styles.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(50),
        ),
        onPressed: () {
          showCreateManagerModal(context);
        },
        child: Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
