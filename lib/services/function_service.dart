import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../provider/manager_provider.dart'; // Import for debugPrint

Future<void> createManagerAndSendEmail({
  required BuildContext context,
  required String name,
  required String email,
  required String phone,
  required String password,
}) async {
  // Basic validation before API call
  print("$name,$email,$password,$phone");
  if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields are required.")));
    }
    return;
  }

  if (password.length < 6) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 6 characters."),
        ),
      );
    }
    return;
  }

  // Check if context is still valid before showing dialog
  if (!context.mounted) return;

  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final callable = FirebaseFunctions.instanceFor(
      region: 'us-central1',
    ).httpsCallable('sendManagerCredentials');

    await FirebaseAuth.instance.currentUser?.getIdToken(true); // refresh token
    final result = await callable.call({
      "email": email,
      "name": name,
      "password": password,
      "phone": phone,
    });

    // Make sure the context is still valid before trying to pop
    if (!context.mounted) return;

    Navigator.pop(context); // Close loading

    final data = result.data;
    if (data['success'] == true) {
      final newManager = {
        "id": data['managerId'],
        "name": name,
        "email": email,
        "phone": phone,
      };

      if (context.mounted) {
        context.read<ManagerProvider>().addManager(newManager);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Manager created! ID: ${data['managerId']}"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      throw Exception(data['message'] ?? "Unknown error occurred.");
    }
  } on FirebaseFunctionsException catch (e) {
    debugPrint(
      "FirebaseFunctionsException: ${e.code} | ${e.message} | ${e.details}",
    );

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cloud Function error: ${e.message}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    debugPrint("Generic Error: $e");

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }
}
