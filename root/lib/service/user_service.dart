// UserService: reads/writes the 'users/{uid}' document in Firestore.
// Centralizing Firestore logic keeps UI widgets lean and testable.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static const String _collection = 'users';

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
    if (snapshot.exists) return;
    await userRef.set({
      'id': uid,
      'name': name.trim(),
      'email': email.trim(),
      'phoneNumber': '',
      'profileImageUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update fields on the user's profile; auto-bumps lastUpdatedAt
  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    data['lastUpdatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection(_collection).doc(uid).update(data);
  }

  // Delete user profile
  static Future<void> deleteUser(String uid) async {
    // TODO: Add warning before user does it

    // TODO: Have user reauthenticate themselves before deleting

    await _firebaseAuth.currentUser?.delete();
  }
}
