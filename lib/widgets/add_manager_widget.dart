import 'package:blush_hush_admin/services/function_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showCreateManagerModal(BuildContext context) {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      bool obscureText = true;
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "New Site Manager",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text(
                        "Create",
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () {
                        createManagerAndSendEmail(
                          context: context,
                          name: _nameController.text.trim(),
                          email: _emailController.text.trim(),
                          phone: _phoneController.text.trim(),
                          password: _passwordController.text.trim(),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Site Manager Information",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Fields
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: "Phone Number"),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Password (min 6 characters)",
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
                  ),
                  obscureText: obscureText,
                ),

                const SizedBox(height: 12),

                // Info card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.badge, color: Colors.purple, size: 18),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "A unique Manager ID (SMxxx) will be automatically generated",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.email, color: Colors.blue, size: 18),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Login credentials will be sent to the manager's email automatically",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 18),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Make sure the email address is correct",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    },
  );
}
