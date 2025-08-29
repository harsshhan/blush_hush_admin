import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerService {
  final _col = FirebaseFirestore.instance.collection("site_managers");

  Stream<List<Map<String, dynamic>>> listenManagers() {
    return _col.snapshots().map((snap) =>
      snap.docs.map((d) => {"id": d.id, ...d.data()}).toList());
  }

  // Future-based method for single admin (no streams needed)
  Future<List<Map<String, dynamic>>> getManagers() async {
    final snapshot = await _col.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        "id": doc.id,
        ...data,
      };
    }).toList();
  }

  Future<Map<String, dynamic>?> getManagerById(String managerId) async {
    final doc = await _col.doc(managerId).get();
    if (doc.exists) {
      return {"id": doc.id, ...doc.data()!};
    }
    return null;
  }

  
  // Future-based method for single admin
  Future<List<Map<String, dynamic>>> getManagerWithProjectsOnce(String managerId) async {
    final doc = await _col.doc(managerId).get();
    if (doc.exists) {
      final data = doc.data()!;
      final assignedProjects = data['assigned_projects'] as List<dynamic>? ?? [];
      return [{"id": doc.id, ...data, 'projectCount': assignedProjects.length}];
    }
    return <Map<String, dynamic>>[];
  }

  

  // Future-based method for single admin
  Future<List<Map<String, dynamic>>> getManagersWithProjectCounts() async {
    final snapshot = await _col.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final assignedProjects = data['assigned_projects'] as List<dynamic>? ?? [];
      return {
        "id": doc.id,
        ...data,
        'projectCount': assignedProjects.length,
      };
    }).toList();
  }



  // Add a project to manager's assigned projects
  Future<void> addProjectToManager(String managerId, String projectId) async {
    await _col.doc(managerId).update({
      'assigned_projects': FieldValue.arrayUnion([projectId])
    });
  }

}