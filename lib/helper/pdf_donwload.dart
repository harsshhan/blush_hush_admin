import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Future<String?> downloadFile(String url, String fileName, {BuildContext? context}) async {
//   try {
//     // Ensure the filename has .pdf extension
//     String finalFileName = fileName;
//     if (!fileName.toLowerCase().endsWith('.pdf')) {
//       finalFileName = '$fileName.pdf';
//     }
    
//     // Get the appropriate directory
//     final dir = await getApplicationDocumentsDirectory();
//     final filePath = "${dir.path}/$finalFileName";
    
//     print("Downloading to: $filePath");
    
//     // Create Dio instance with options
//     final dio = Dio();
    
//     // Download with progress tracking (optional)
//     await dio.download(
//       url,
//       filePath,
//       onReceiveProgress: (received, total) {
//         if (total != -1) {
//           final progress = (received / total * 100).toStringAsFixed(0);
//           print('Download progress: $progress%');
//         }
//       },
//       options: Options(
//         // Set headers to ensure we're requesting a PDF
//         headers: {
//           'Accept': 'application/pdf',
//         },
//         // Follow redirects
//         followRedirects: true,
//         // Set timeout
//         receiveTimeout: const Duration(seconds: 30),
//         sendTimeout: const Duration(seconds: 30),
//       ),
//     );
    
//     // Verify the file was created and has content
//     final file = File(filePath);
//     if (await file.exists()) {
//       final fileSize = await file.length();
//       print('Downloaded successfully: $filePath (${fileSize} bytes)');
      
//       if (context != null && context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Downloaded: $finalFileName'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
      
//       return filePath;
//     } else {
//       throw Exception('File was not created');
//     }
    
//   } catch (e) {
//     print('Download error: $e');
    
//     if (context != null && context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Download failed: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
    
//     return null;
//   }
// }

// Alternative version for downloads folder (Android/iOS)
Future<String?> downloadFileToDownloads(String url, String fileName, {BuildContext? context}) async {
  try {
    // Ensure the filename has .pdf extension
    String finalFileName = fileName;
    if (!fileName.toLowerCase().endsWith('.pdf')) {
      finalFileName = '$fileName.pdf';
    }
    
    Directory? dir;
    
    if (Platform.isAndroid) {
      // For Android, try to use Downloads directory
      dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        // Fallback to external storage
        dir = await getExternalStorageDirectory();
      }
    } else {
      // For iOS, use documents directory
      dir = await getApplicationDocumentsDirectory();
    }
    
    if (dir == null) {
      throw Exception('Could not access storage directory');
    }
    
    final filePath = "${dir.path}/$finalFileName";
    print("Downloading to: $filePath");
    
    final dio = Dio();
    await dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          final progress = (received / total * 100).toStringAsFixed(0);
          print('Download progress: $progress%');
        }
      },
      options: Options(
        headers: {'Accept': 'application/pdf'},
        followRedirects: true,
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
    
    final file = File(filePath);
    if (await file.exists()) {
      final fileSize = await file.length();
      print('Downloaded successfully: $filePath (${fileSize} bytes)');
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded to Downloads: $finalFileName'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                // You could open the file here or show its location
                print('File saved at: $filePath');
              },
            ),
          ),
        );
      }
      
      return filePath;
    } else {
      throw Exception('File was not created');
    }
    
  } catch (e) {
    print('Download error: $e');
    
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    return null;
  }
}

// Usage examples:
/*
// Basic usage:
await downloadFile('https://example.com/document.pdf', 'my_document', context: context);

// Download to Downloads folder:
await downloadFileToDownloads('https://example.com/document.pdf', 'my_document', context: context);

// With progress tracking in UI:
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => const AlertDialog(
    content: Row(
      children: [
        CircularProgressIndicator(),
        SizedBox(width: 16),
        Text('Downloading...'),
      ],
    ),
  ),
);

final filePath = await downloadFile(url, fileName, context: context);
Navigator.of(context).pop(); // Close loading dialog

if (filePath != null) {
  // File downloaded successfully, you can now open it
  print('File ready at: $filePath');
}
*/