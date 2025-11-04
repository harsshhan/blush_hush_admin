import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/project_doc_model.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<DocumentReference> addProject({
    required String name,
    required String siteLocation,
    required String client,
    required String manager_id,
    required List<DocumentModel> documents,
  }) async {
    return await _firestore
        .runTransaction<DocumentReference>((transaction) async {
          final projectRef = _firestore.collection('projects').doc();

          transaction.set(projectRef, {
            'name': name,
            'siteLocation': siteLocation,
            'client': client,
            'manager_id': manager_id,
            'createdAt': FieldValue.serverTimestamp(),
            'status': 'active',
          });

          final managerRef = _firestore
              .collection('site_managers')
              .doc(manager_id);
          transaction.update(managerRef, {
            'assigned_projects': FieldValue.arrayUnion([projectRef.id]),
          });

          return projectRef;
        })
        .then((projectRef) async {
          await _uploadDocuments(projectRef, documents);
          return projectRef;
        });
  }

  Future<void> _uploadDocuments(
    DocumentReference projectRef,
    List<DocumentModel> documents,
  ) async {
    for (var document in documents) {
      if (document.filePath.isNotEmpty) {
        try {
          final file = File(document.filePath);
          if (await file.exists()) {
            final storageRef = _storage.ref().child(
              'projects/${projectRef.id}/${document.fileName}',
            );
            final uploadTask = await storageRef.putFile(file);
            final fileUrl = await uploadTask.ref.getDownloadURL();

            await projectRef.collection('documents').add({
              'name': document.fileName,
              'type': document.fileType,
              'fileUrl': fileUrl,
              'uploadedAt': FieldValue.serverTimestamp(),
            });
          }
        } catch (e) {
          print('Error uploading document ${document.fileName}: $e');
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> getProjects() async {
    final snapshot = await _firestore.collection('projects').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {'id': doc.id, ...data};
    }).toList();
  }

  Future<void> updateProjectStatus(String projectId, String status) async {
    await _firestore.collection('projects').doc(projectId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> fetchDocuments(String project_id) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(project_id)
        .collection('documents')
        .get();

    return snapshot.docs.map((d) => d.data()).toList();
  }

  Stream<List<Map<String, dynamic>>> streamProjectUpdates(String projectId) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .collection('updates')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            final rawImages = data['images'] ?? [];

            // Filter and validate image URLs
            final List<String> validImages = [];
            for (var img in rawImages) {
              if (img is String && img.isNotEmpty) {
                try {
                  final uri = Uri.parse(img);
                  if (uri.hasScheme && uri.hasAuthority) {
                    validImages.add(img);
                  }
                } catch (e) {
                  // Skip invalid URLs
                  print('Invalid image URL: $img');
                }
              }
            }

            return {
              'id': doc.id,
              'title': data['title'],
              'images': validImages,
              'date': data['date'],
              'status': data['status'],
            };
          }).toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> streamRecentUpdates({int limit = 10}) {
    return _firestore.collectionGroup('updates').limit(limit).snapshots().map((
      snapshot,
    ) {
      final List<Map<String, dynamic>> updates = [];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final projectRef = doc.reference.parent.parent;
        final projectId = projectRef?.id;
        if (projectId == null) continue;

        final rawImages = data['images'] ?? [];
        final List<String> validImages = [];
        for (var img in rawImages) {
          if (img is String && img.isNotEmpty) {
            try {
              final uri = Uri.parse(img);
              if (uri.hasScheme && uri.hasAuthority) {
                validImages.add(img);
              }
            } catch (_) {}
          }
        }

        final date = data['date'];
        if (date is! Timestamp) {
          // Skip updates without a valid Timestamp date
          continue;
        }

        updates.add({
          'updateId': doc.id,
          'projectId': projectId,
          'title': data['title'],
          'images': validImages,
          'date': date,
          'status': data['status'],
        });
      }

      // Sort by date desc and enforce limit
      updates.sort((a, b) {
        final ad = a['date'] as Timestamp;
        final bd = b['date'] as Timestamp;
        return bd.compareTo(ad);
      });
      return updates.take(limit).toList();
    });
  }
}
