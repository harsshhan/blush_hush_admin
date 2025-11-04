import 'package:flutter/material.dart';
import 'package:blush_hush_admin/provider/client_provider.dart';
import 'package:blush_hush_admin/constants/styles.dart';

class ClientSearchDialog extends StatefulWidget {
  final ClientProvider clientProvider;
  final Function(String clientId, String clientName) onClientSelected;

  const ClientSearchDialog({
    Key? key,
    required this.clientProvider,
    required this.onClientSelected,
  }) : super(key: key);

  @override
  State<ClientSearchDialog> createState() => _ClientSearchDialogState();
}

class _ClientSearchDialogState extends State<ClientSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredClients = [];

  @override
  void initState() {
    super.initState();
    _filteredClients = List.from(widget.clientProvider.clients);
  }

  void _filterClients(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredClients = List.from(widget.clientProvider.clients);
      });
    } else {
      setState(() {
        _filteredClients = widget.clientProvider.clients.where((client) {
          final name = client['name']?.toString().toLowerCase() ?? '';
          final phone = client['phone']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          
          return name.contains(searchQuery) || phone.contains(searchQuery);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Client",
                  style: Styles.heading1.copyWith(fontSize: 20),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search clients by name or phone...",
                prefixIcon: Icon(Icons.search, color: Styles.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: _filterClients,
            ),
            SizedBox(height: 20),
            
            // Results count
            Text(
              "${_filteredClients.length} client${_filteredClients.length == 1 ? '' : 's'} found",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 15),
            
            // Client list
            Expanded(
              child: _filteredClients.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isEmpty 
                          ? "No clients available"
                          : "No clients found matching '${_searchController.text}'",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredClients.length,
                      itemBuilder: (context, index) {
                        final client = _filteredClients[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(
                              client['name'] ?? 'Unknown',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  'Phone: ${client['phone'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                if (client['email'] != null) ...[
                                  SizedBox(height: 2),
                                  Text(
                                    'Email: ${client['email']}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: Styles.primaryColor,
                              size: 16,
                            ),
                            onTap: () {
                              widget.onClientSelected(
                                client['id'],
                                client['name'] ?? 'Unknown',
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
