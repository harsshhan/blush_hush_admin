import 'package:blush_hush_admin/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blush_hush_admin/widgets/project_updates_timeline.dart';

import '../../helper/pdf_donwload.dart';
import '../../helper/pdf_screen.dart';
import '../../provider/manager_provider.dart';
import '../../provider/project_provider.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Map<String, dynamic> project;
  final int initialTabIndex;

  const ProjectDetailScreen({
    super.key,
    required this.project,
    this.initialTabIndex = 0,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  int _selectedTabIndex = 0;
  String _selectedDocType = 'invoice';
  final List<String> _tabs = ['About', 'Updates', 'Documents'];

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().fetchProjectDocuments(
        widget.project['id'],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.project['name'] ?? 'Project Details',
          style: Styles.heading1.copyWith(fontSize: 20),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
        backgroundColor: Styles.backgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: _tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                final isSelected = _selectedTabIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Styles.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        tab,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Tab Content
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildAboutTab();
      case 1:
        return ProjectUpdatesTimeline(projectId: widget.project['id']);
      case 2:
        return _buildDocumentTab();
      default:
        return _buildAboutTab();
    }
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'About',
            children: [
              _buildInfoRow('Project Name', widget.project['name'] ?? 'N/A'),
              _buildInfoRow(
                'Site Location',
                widget.project['siteLocation'] ?? 'N/A',
              ),
              _buildInfoRow('Client', widget.project['client'] ?? 'N/A'),
              _buildInfoRow(
                'Status',
                _getStatusText(widget.project['status'] ?? 'active'),
              ),
              _buildInfoRow(
                'Created Date',
                _formatDate(widget.project['createdAt']),
              ),
            ],
          ),

          SizedBox(height: 20),

          _buildManagerInfo(),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Styles.containerbgcolor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Styles.primaryColor,
            ),
          ),
          SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: Styles.small)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagerInfo() {
    return Consumer<ManagerProvider>(
      builder: (context, managerProvider, _) {
        final managerId = widget.project['manager_id'];
        final manager = managerProvider.managers.firstWhere(
          (m) => m['id'] == managerId,
          orElse: () => {'name': 'Unassigned', 'phone': 'N/A', 'email': 'N/A'},
        );

        return _buildInfoCard(
          title: 'Site Manager',
          children: [
            _buildInfoRow('Name', manager['name'] ?? 'Unassigned'),
            _buildInfoRow('Phone', manager['phone'] ?? 'N/A'),
            _buildInfoRow('Email', manager['email'] ?? 'N/A'),
          ],
        );
      },
    );
  }

  Widget _buildDocumentTab() {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, _) {
        if (projectProvider.docsLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final invoices = projectProvider.getInvoices(widget.project['id']);
        final agreements = projectProvider.getAgreements(widget.project['id']);

        if (invoices.isEmpty && agreements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No documents uploaded yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        List<Map<String, dynamic>> selectedDocs = _selectedDocType == 'invoice'
            ? invoices
            : agreements;

        return Stack(
          children: [
            // Scrollable docs
            Positioned.fill(
              child: selectedDocs.isEmpty
                  ? Center(
                      child: Text(
                        'No ${_selectedDocType[0].toUpperCase()}${_selectedDocType.substring(1)}s found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 15,
                        bottom: 80,
                      ),
                      itemCount: selectedDocs.length,
                      itemBuilder: (context, index) {
                        final doc = selectedDocs[index];
                        return _buildDocumentItem(doc);
                      },
                    ),
            ),

            // Buttons
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedDocType == 'invoice'
                          ? Styles.primaryColor
                          : Colors.grey[300],
                    ),
                    onPressed: () =>
                        setState(() => _selectedDocType = 'invoice'),
                    child: Text(
                      "Invoice",
                      style: TextStyle(
                        color: _selectedDocType == 'invoice'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedDocType == 'agreement'
                          ? Styles.primaryColor
                          : Colors.grey[300],
                    ),
                    onPressed: () =>
                        setState(() => _selectedDocType = 'agreement'),
                    child: Text(
                      "Agreement",
                      style: TextStyle(
                        color: _selectedDocType == 'agreement'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDocumentItem(Map<String, dynamic> doc) {
    return Card(
      color: Styles.containerbgcolor,
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          _getDocumentIcon(doc['type'] ?? ''),
          color: Styles.primaryColor,
        ),
        title: Text(
          doc['name'] ?? 'Unnamed Document',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.visibility, color: Styles.primaryColor),
              onPressed: () {
                final url = doc['fileUrl'];
                if (url != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfViewerScreen(url: url),
                    ),
                  );
                }
              },
            ),
            IconButton(
              onPressed: () async {
                final url = doc['fileUrl'];
                final name = doc['name'] ?? "document.pdf";
                if (url != null) {
                  await downloadFileToDownloads(url, name);
                }
              },
              icon: Icon(Icons.download, color: Styles.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDocumentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'invoice':
        return Icons.receipt;
      case 'agreement':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Ongoing';
      case 'completed':
        return 'Completed';
      case 'paused':
        return 'Paused';
      default:
        return status;
    }
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      final dateTime = date.toDate();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    return 'Date not available';
  }

  // long date formatting is handled inside the updates timeline widget
}
