import 'package:flutter/material.dart';
import 'package:blush_hush_admin/services/client_service.dart';

class ClientProvider with ChangeNotifier {
  final ClientService _clientService = ClientService();
  
  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _filteredClients = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  
  List<Map<String, dynamic>> get clients => _clients;
  List<Map<String, dynamic>> get filteredClients => _filteredClients;
  bool get isLoading => _isLoading;
  int get clientCount => _clients.length;

  Future<void> loadClients() async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final clientsData = await _clientService.getClients();
      _clients = clientsData;
      _filteredClients = List<Map<String, dynamic>>.from(_clients);
      _isInitialized = true;
    } catch (e) {
      print('Error loading clients: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    if (!_isInitialized) {
      await loadClients();
    }
  }

  Future<void> refreshClients() async {
    await loadClients();
  }

  void searchClients(String query) {
    if (query.isEmpty) {
      _filteredClients = List<Map<String, dynamic>>.from(_clients);
    } else {
      _filteredClients = _clients.where((client) {
        final name = client['name']?.toString().toLowerCase() ?? '';
        final phone = client['phone']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        
        return name.contains(searchQuery) || phone.contains(searchQuery);
      }).toList();
    }
    notifyListeners();
  }

  Future<String> createClient({
    required String name,
    required String phone,
    String? email,
    String? address,
  }) async {
    try {
      final clientId = await _clientService.createClient(
        name: name,
        phone: phone,
        email: email,
        address: address,
      );
      
      await loadClients();
      
      return clientId;
    } catch (e) {
      rethrow;
    }
  }

  // Future<void> updateClient(String clientId, Map<String, dynamic> data) async {
  //   try {
  //     await _clientService.updateClient(clientId, data);
      
  //     // Refresh the client list
  //     await loadClients();
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // // Delete client
  // Future<void> deleteClient(String clientId) async {
  //   try {
  //     await _clientService.deleteClient(clientId);
      
  //     // Refresh the client list
  //     await loadClients();
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // // Get client by ID
  // Map<String, dynamic>? getClientById(String clientId) {
  //   try {
  //     return _clients.firstWhere((client) => client['id'] == clientId);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // // Get client count for dashboard
  // Future<int> getClientCount() async {
  //   return await _clientService.getClientCount();
  // }

  // // Filter clients by status
  // List<Map<String, dynamic>> getClientsByStatus(String status) {
  //   if (status.toLowerCase() == 'all') {
  //     return _clients;
  // //   }
    
  //   return _clients.where((client) {
  //     final clientStatus = client['status']?.toString().toLowerCase() ?? 'active';
  //     return clientStatus == status.toLowerCase();
  //   }).toList();
  // }


  // Clear search results
  void clearSearch() {
    _filteredClients = List<Map<String, dynamic>>.from(_clients);
    notifyListeners();
  }
}
