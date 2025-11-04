import 'package:blush_hush_admin/constants/styles.dart';
import 'package:blush_hush_admin/screens/client/add_client_dialog.dart';
import 'package:blush_hush_admin/widgets/input_container.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../models/project_doc_model.dart';
import '../../provider/manager_provider.dart';
import '../../provider/project_provider.dart';
import '../../provider/client_provider.dart';
import '../../widgets/client_search_dialog.dart';

class AddProjectScreen extends StatefulWidget {
  final VoidCallback onClose;
  const AddProjectScreen({super.key, required this.onClose});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final TextEditingController projectnameController = TextEditingController();
  final TextEditingController clientnameController = TextEditingController();
  final TextEditingController sitelocationController = TextEditingController();

  String? selectedManager;
  String? selectedClient;

  List<Map<String, dynamic>> documents = [];

  void _addDocument() {
    setState(() {
      documents.insert(0, {
        "nameController": TextEditingController(),
        "type": "Invoice",
        "fileName": null,
        "filePath": null,
      });
    });
  }

  Future<void> _pickFile(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        documents[index]["fileName"] = result.files.single.name;
        documents[index]["filePath"] = result.files.single.path;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize providers when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagerProvider>().initialize();
      context.read<ClientProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final managerProvider = Provider.of<ManagerProvider>(context);
    final clientProvider = Provider.of<ClientProvider>(context);
    return Scaffold(
      backgroundColor: Styles.backgroundColor,
      appBar: AppBar(
        title: Text("New Project", style: Styles.heading1),
        leading: IconButton(
          onPressed: () {
            widget.onClose();
          },
          icon: Icon(Icons.arrow_back),
        ),
        backgroundColor: Styles.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              InputContainer(
                hintText: "Project Name",
                textEditingController: projectnameController,
              ),
              SizedBox(height: 15),
              InputContainer(
                hintText: "Site Location",
                textEditingController: sitelocationController,
              ),
              SizedBox(height: 15),
              // Client Selection with Search and New Client Button
              // Client Selection with Search and New Client Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Client",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TypeAheadFormField<Map<String, dynamic>>(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: clientnameController,
                            decoration: InputDecoration(
                              hintText: "Search client by name or mobile",
                              filled: true,
                              fillColor: Styles.inputFieldColor,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          suggestionsCallback: (pattern) async {
                            final clients = context
                                .read<ClientProvider>()
                                .clients;
                            if (pattern.isEmpty) return clients;
                            return clients.where((client) {
                              final name =
                                  client['name']?.toString().toLowerCase() ??
                                  '';
                              final phone =
                                  client['phone']?.toString().toLowerCase() ??
                                  '';
                              return name.contains(pattern.toLowerCase()) ||
                                  phone.contains(pattern.toLowerCase());
                            }).toList();
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion['name'] ?? 'Unknown'),
                              subtitle: Text(suggestion['phone'] ?? ''),
                            );
                          },
                          onSuggestionSelected: (suggestion) {
                            setState(() {
                              selectedClient = suggestion['id'];
                              clientnameController.text =
                                  suggestion['name'] ?? '';
                            });
                          },
                          noItemsFoundBuilder: (context) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("No client found"),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          final result = await showDialog(
                            context: context,
                            builder: (_) => AddClientDialog(),
                          );
                          if (result != null &&
                              result is Map<String, dynamic>) {
                            // After adding, update selection
                            setState(() {
                              selectedClient = result['id'];
                              clientnameController.text = result['name'];
                            });
                            // Refresh client provider
                            context.read<ClientProvider>().initialize();
                          }
                        },
                        child: Text(
                          "New Client?",
                          style: TextStyle(
                            color: Styles.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15),
              Container(
                height: 50,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Styles.inputFieldColor,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedManager,
                    hint: Text("Select Site Manager"),
                    isExpanded: true,
                    items: managerProvider.managers.map((manager) {
                      final name = manager["name"];
                      final id = manager['id'];
                      return DropdownMenuItem<String>(
                        value: id,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedManager = value;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Documents",
                    style: Styles.heading1.copyWith(fontSize: 18),
                  ),
                  TextButton.icon(
                    onPressed: _addDocument,
                    icon: Icon(Icons.add, color: Styles.primaryColor),
                    label: Text(
                      "Add Document",
                      style: TextStyle(
                        color: Styles.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              Column(
                children: documents.asMap().entries.map((entry) {
                  int index = entry.key;
                  var doc = entry.value;

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Styles.inputFieldColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox.shrink(),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red[400]),
                              onPressed: () {
                                setState(() {
                                  documents.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: doc["nameController"],
                          readOnly: doc["fileName"] == null,
                          decoration: InputDecoration(
                            hintText: doc["fileName"] == null
                                ? "Upload a file to name this document"
                                : "Document Name",
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),

                        DropdownButtonFormField<String>(
                          value: doc["type"],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: ["Invoice", "Agreement"]
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              documents[index]["type"] = val!;
                            });
                          },
                        ),
                        SizedBox(height: 10),

                        // File upload button & file name
                        Row(
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Styles.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              onPressed: () => _pickFile(index),
                              icon: Icon(
                                Icons.upload_file,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Upload File",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                doc["fileName"] ?? "No file chosen",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: doc["fileName"] == null
                                      ? Colors.grey
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 25),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        widget.onClose();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Styles.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () async {
                        // Validate main fields
                        if (projectnameController.text.trim().isEmpty ||
                            sitelocationController.text.trim().isEmpty ||
                            selectedClient == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Please fill all project details and select a client.",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Validate documents
                        for (var doc in documents) {
                          if (doc["filePath"] != null &&
                              (doc["nameController"].text.trim().isEmpty)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Please provide a name for all uploaded documents.",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                        }

                        // ✅ Build document models
                        final docsData = documents
                            .where(
                              (doc) =>
                                  doc["filePath"] != null &&
                                  doc["filePath"]!.isNotEmpty,
                            )
                            .map((doc) {
                              return DocumentModel(
                                fileName: doc["nameController"].text.trim(),
                                fileType: doc["type"],
                                filePath: doc["filePath"],
                              );
                            })
                            .toList();

                        // Validate that at least one document is provided
                        if (docsData.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Please upload at least one document.",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              Center(child: CircularProgressIndicator()),
                        );

                        // ✅ Call provider/service
                        try {
                          await context.read<ProjectProvider>().addProject({
                            'name': projectnameController.text.trim(),
                            'siteLocation': sitelocationController.text.trim(),
                            'client': clientnameController.text.trim(),
                            'manager_id': selectedManager,
                            'documents': docsData,
                          });

                          Navigator.of(context).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Project added successfully!"),
                              backgroundColor: Colors.green,
                            ),
                          );

                          widget.onClose(); // close screen
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to add project: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text(
                        "Next",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show client search dialog
  void _showClientSearchDialog(
    BuildContext context,
    ClientProvider clientProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => ClientSearchDialog(
        clientProvider: clientProvider,
        onClientSelected: (clientId, clientName) {
          setState(() {
            selectedClient = clientId;
            clientnameController.text = clientName;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
