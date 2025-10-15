// UserService: reads/writes the 'users/{uid}' document in Firestore.
// Centralizing Firestore logic keeps UI widgets lean and testable.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserService {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static const String _collection = 'users';
  
  /// Allows overriding the Firestore instance for testing
  @visibleForTesting
  static void useFirestore(FirebaseFirestore firestore) {
    _firestore = firestore;
  }
  
  /// Allows overriding the Firebase Auth instance for testing
  @visibleForTesting
  static void useAuth(FirebaseAuth auth) {
    _firebaseAuth = auth;
  }

  // Read a user's profile document by uid
  static Future<DocumentSnapshot<Map<String, dynamic>>?> getUser(String uid) async {
    if (uid.isEmpty) return null;
    final doc = await _firestore.collection(_collection).doc(uid).get();
    return doc;
  }

  // Create a basic profile document only if it doesn't exist yet
  static Future<void> createUserIfMissing({
    required String uid,
    required String name,
    required String email,
  }) async {
    final userRef = _firestore.collection(_collection).doc(uid);
    final snapshot = await userRef.get();
    if (!snapshot.exists) {
      await userRef.set({
        'id': uid,
        'name': name.trim(),
        'email': email.trim(),
        'phoneNumber': '',
        'profileImageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    // If the document already exists, but the stored name is empty or a
    // placeholder like 'New User', update it with the provided non-empty name.
    final data = snapshot.data();
    if (data != null) {
      final existingName = (data['name'] as String?)?.trim() ?? '';
      final incomingName = name.trim();
      if (incomingName.isNotEmpty &&
          (existingName.isEmpty || existingName == 'New User')) {
        await userRef.update({
          'name': incomingName,
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Update fields on the user's profile; auto-bumps lastUpdatedAt
  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    data['lastUpdatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection(_collection).doc(uid).update(data);
  }

  // Delete user profile
  static Future<void> deleteUser(String uid) async {
    await _firebaseAuth.currentUser?.delete();
  }
}
