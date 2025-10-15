// ProfileSummaryScreen: shows basic profile info + navigation to edit, sign out
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p5_expense/service/auth_service.dart';
import 'package:p5_expense/view/profile_editing.dart';

class ProfileSummaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fb_auth.User? user = AuthService.currentUser;
    if (user == null) {
      return Scaffold(body: Center(child: Text('Not signed in')));
    }
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService.signOut();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Signed out')),
                );
                // Return to root so AuthGate can show the sign-up screen
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Profile not found'));
          }
          final data = snapshot.data!.data()!;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: (data['profileImageUrl'] ?? '').toString().isNotEmpty
                    ? NetworkImage(data['profileImageUrl'])
                    : null,
                child: (data['profileImageUrl'] ?? '').toString().isEmpty
                    ? Icon(Icons.person, size: 40)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(data['name'] ?? '', style: Theme.of(context).textTheme.headlineSmall),
              Text(data['email'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text('Phone: ${(data['phoneNumber'] ?? '').isEmpty ? 'N/A' : data['phoneNumber']}'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProfileEditingScreen()),
                  );
                },
                child: Text('Edit Profile'),
              ),
            ],
          );
        },
      ),
    );
  }
}


