import 'package:flutter/material.dart';

import '../constants/styles.dart';

class ProfileDetailCard extends StatelessWidget {
  final String name;
  final String? email;
  final String? phone;

  const ProfileDetailCard({super.key, required this.name,this.email,this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(16),
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
            name ?? 'Unknown Client',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Styles.primaryColor,
            ),
          ),
          SizedBox(height: 8),
          if (phone != null && phone!.isNotEmpty) ...[
            Text('Phone: $phone', style: Styles.small),
          ],

          if (email != null && email!.isNotEmpty) ...[
            Text('Email: $email', style: Styles.small),
          ],
        ],
      ),
    );
  }
}
