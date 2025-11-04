import 'dart:async';

import 'package:blush_hush_admin/services/manager_service.dart';
import 'package:flutter/material.dart';

class ManagerProvider with ChangeNotifier {
  final ManagerService _service = ManagerService();
  List<Map<String, dynamic>> _managers = [];
  List<Map<String, dynamic>> get managers => _managers;

  List<Map<String, dynamic>> _filteredManagers = [];
  List<Map<String, dynamic>> get filteredManagers => _filteredManagers;

  int _managerCount = 0;
  int get managerCount => _managerCount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isInitialized = false;

  // Load managers once when needed
  Future<void> loadManagers() async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final managersData = await _service.getManagersWithProjectCounts();
      _managers = managersData;
      _managerCount = _managers.length;
      _filteredManagers = List<Map<String, dynamic>>.from(_managers);
      _isInitialized = true;
    } catch (e) {
      print('Error loading managers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Manual refresh
  Future<void> refreshManagers() async {
    await loadManagers();
  }

  // Initialize if not done
  Future<void> initialize() async {
    if (!_isInitialized) {
      await loadManagers();
    }
  }

  void filterManagers(String query) {
    if (query.isEmpty) {
      _filteredManagers = List<Map<String, dynamic>>.from(_managers);
    } else {
      _filteredManagers = _managers
          .where(
            (manager) => manager.values.any(
              (value) =>
                  value != null &&
                  value.toString().toLowerCase().contains(query.toLowerCase()),
            ),
          )
          .toList();
    }
    notifyListeners();
  }

  void addManager(Map<String, dynamic> manager) {
    _managers.add(manager);
    _filteredManagers.add(manager);
    _managerCount = _managers.length;
    notifyListeners();
  }

  // Get manager by ID
  Map<String, dynamic>? getManagerById(String managerId) {
    try {
      return _managers.firstWhere((manager) => manager['id'] == managerId);
    } catch (e) {
      return null;
    }
  }

  // Add project to manager
  Future<void> addProjectToManager(String managerId, String projectId) async {
    await _service.addProjectToManager(managerId, projectId);
    // Refresh after update
    await loadManagers();
  }



  // Get managers with no projects
  List<Map<String, dynamic>> getAvailableManagers() {
    return _managers.where((manager) {
      final projectCount = manager['projectCount'] ?? 0;
      return projectCount == 0;
    }).toList();
  }
}
