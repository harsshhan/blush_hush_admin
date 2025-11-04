import 'package:blush_hush_admin/constants/styles.dart';
import 'package:blush_hush_admin/screens/client/add_client_dialog.dart';
import 'package:blush_hush_admin/widgets/name_card_widget.dart';
import 'package:blush_hush_admin/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/client_provider.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.backgroundColor,
      body: SafeArea(
        child: Consumer<ClientProvider>(
          builder: (context, clientProvider, _) {
            if (clientProvider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }
        
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Clients",
                    style: Styles.heading2,
                  ),
                  SizedBox(height: 20),
                  SearchBarWidget(onChanged: clientProvider.searchClients),
                  SizedBox(height: 20),
        
                  if (clientProvider.filteredClients.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                size: 64, color: Colors.grey[400]),
                            SizedBox(height: 16),
                            Text(
                              'No clients yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: clientProvider.filteredClients.length,
                        itemBuilder: (context, index) {
                          final client = clientProvider.filteredClients[index];
                          return ProfileDetailCard(
                            name: client['name'],phone: client['phone'],);
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(50)),
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (context) => AddClientDialog(),
          );
          if (result != null && result['success'] == true) {
            await context.read<ClientProvider>().refreshClients();
          }
        },
        
        backgroundColor: Styles.primaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  
}