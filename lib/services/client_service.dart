import 'package:cloud_firestore/cloud_firestore.dart';

class ClientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'clients';

  // Get all clients
  Future<List<Map<String, dynamic>>> getClients() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  // Get client by ID
  Future<Map<String, dynamic>?> getClientById(String clientId) async {
    final doc = await _firestore.collection(_collection).doc(clientId).get();
    if (doc.exists) {
      return {
        'id': doc.id,
        ...doc.data()!,
      };
    }
    return null;
  }

  // Search clients by name or phone
  Future<List<Map<String, dynamic>>> searchClients(String query) async {
    if (query.isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase();
    final allClients = await getClients();
    
    return allClients.where((client) {
      final name = client['name']?.toString().toLowerCase() ?? '';
      final phone = client['phone']?.toString().toLowerCase() ?? '';
      
      return name.contains(lowercaseQuery) || phone.contains(lowercaseQuery);
    }).toList();
  }

  // Check if phone number already exists
  Future<bool> isPhoneNumberExists(String phoneNumber) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('phone', isEqualTo: phoneNumber)
        .get();
    
    return snapshot.docs.isNotEmpty;
  }

  // Create new client
  Future<String> createClient({
    required String name,
    required String phone,
    String? email,
    String? address,
  }) async {
    // Check if phone number already exists
    final phoneExists = await isPhoneNumberExists(phone);
    if (phoneExists) {
      throw Exception('Client with this phone number already exists');
    }

    // Create new client
    final docRef = await _firestore.collection(_collection).add({
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email?.trim(),
      'address': address?.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'active',
    });

    return docRef.id;
  }

  // Update client
  Future<void> updateClient(String clientId, Map<String, dynamic> data) async {
    // If updating phone number, check if it already exists for other clients
    if (data.containsKey('phone')) {
      final phoneExists = await isPhoneNumberExists(data['phone']);
      if (phoneExists) {
        // Check if it's the same client
        final currentClient = await getClientById(clientId);
        if (currentClient == null || currentClient['phone'] != data['phone']) {
          throw Exception('Client with this phone number already exists');
        }
      }
    }

    await _firestore.collection(_collection).doc(clientId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete client
  Future<void> deleteClient(String clientId) async {
    await _firestore.collection(_collection).doc(clientId).delete();
  }

  // Get client count
  Future<int> getClientCount() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.size;
  }

  // Get active clients
  Future<List<Map<String, dynamic>>> getActiveClients() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'active')
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }
}
