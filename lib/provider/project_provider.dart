import 'dart:async';

import 'package:flutter/material.dart';
import 'package:blush_hush_admin/services/project_service.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectService _projectService = ProjectService();

  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  final Map<String, List<Map<String, dynamic>>> _projectInvoices = {};
  final Map<String, List<Map<String, dynamic>>> _projectAgreements = {};
  bool _docsLoading = false;
  final Map<String, List<Map<String, dynamic>>> _projectUpdates = {};
  final Map<String, bool> _updatesLoading = {};

  List<Map<String, dynamic>> getInvoices(String projectId) =>
      _projectInvoices[projectId] ?? [];

  List<Map<String, dynamic>> getAgreements(String projectId) =>
      _projectAgreements[projectId] ?? [];
  bool get docsLoading => _docsLoading;
  List<Map<String, dynamic>> getUpdates(String projectId) =>
      _projectUpdates[projectId] ?? [];
  bool updatesLoading(String projectId) => _updatesLoading[projectId] ?? false;

  List<Map<String, dynamic>> get projects => _projects;
  int get projectCount => _projects.length;
  bool get isLoading => _isLoading;

  // Streams
  Stream<List<Map<String, dynamic>>> updatesStream(String projectId) {
    return _projectService.streamProjectUpdates(projectId);
  }

  Stream<List<Map<String, dynamic>>> recentUpdatesStream({int limit = 10}) {
    return _projectService.streamRecentUpdates(limit: limit);
  }

  // Load projects once when needed
  Future<void> loadProjects() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final projectsData = await _projectService.getProjects();
      _projects = projectsData;
      _isInitialized = true;
    } catch (e) {
      print('Error loading projects: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Manual refresh
  Future<void> refreshProjects() async {
    await loadProjects();
  }

  // Initialize if not done
  Future<void> initialize() async {
    if (!_isInitialized) {
      await loadProjects();
    }
  }

  Future<void> addProject(Map<String, dynamic> data) async {
    await _projectService.addProject(
      name: data['name'],
      siteLocation: data['siteLocation'],
      client: data['client'],
      manager_id: data['manager_id'],
      documents: data['documents'],
    );

    // Refresh the list after adding
    await loadProjects();
  }

  // Get project by ID
  Map<String, dynamic>? getProjectById(String projectId) {
    try {
      return _projects.firstWhere((project) => project['id'] == projectId);
    } catch (e) {
      return null;
    }
  }

  // Filter projects by status
  List<Map<String, dynamic>> getProjectsByStatus(String status) {
    if (status.toLowerCase() == 'all') {
      return _projects;
    }

    return _projects.where((project) {
      final projectStatus =
          project['status']?.toString().toLowerCase() ?? 'active';
      if (status.toLowerCase() == 'ongoing') {
        return projectStatus == 'active' || projectStatus == 'ongoing';
      } else if (status.toLowerCase() == 'completed') {
        return projectStatus == 'completed' || projectStatus == 'finished';
      }
      return projectStatus == status.toLowerCase();
    }).toList();
  }

  // Search projects
  List<Map<String, dynamic>> searchProjects(String query) {
    if (query.isEmpty) return _projects;

    final lowercaseQuery = query.toLowerCase();
    return _projects.where((project) {
      final name = project['name']?.toString().toLowerCase() ?? '';
      final client = project['client']?.toString().toLowerCase() ?? '';
      final location = project['siteLocation']?.toString().toLowerCase() ?? '';

      return name.contains(lowercaseQuery) ||
          client.contains(lowercaseQuery) ||
          location.contains(lowercaseQuery);
    }).toList();
  }

  Future<void> fetchProjectDocuments(String projectId) async {
    _docsLoading = true;
    notifyListeners();

    try {
      final docs = await _projectService.fetchDocuments(projectId);

      _projectInvoices[projectId] = docs
          .where((d) => d['type']?.toLowerCase() == 'invoice')
          .toList();
      _projectAgreements[projectId] = docs
          .where((d) => d['type']?.toLowerCase() == 'agreement')
          .toList();
    } catch (e) {
      print('Error fetching documents for project $projectId: $e');
      _projectInvoices[projectId] = [];
      _projectAgreements[projectId] = [];
    } finally {
      _docsLoading = false;
      notifyListeners();
    }
  }
}
