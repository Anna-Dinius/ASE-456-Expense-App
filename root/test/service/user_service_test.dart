import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:p5_expense/service/user_service.dart';
import 'package:clock/clock.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore firestore;
  final fixedTime = DateTime(2025, 10, 12);

  setUp(() {
    mockAuth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore(clock: Clock.fixed(fixedTime));
    UserService.useFirestore(firestore);
    UserService.useAuth(mockAuth);
  });

  group('UserService Tests', () {
    test('getUser - returns null for empty uid', () async {

      final result = await UserService.getUser('');
      expect(result, isNull);
    });

    test('getUser - returns user document for valid uid', () async {
      const uid = 'test-user-123';
      
      // Create test user document with server timestamp
      await firestore.collection('users').doc(uid).set({
        'id': uid,
        'name': 'Test User',
        'email': 'test@example.com',
        'phoneNumber': '',
        'profileImageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });

      final result = await UserService.getUser(uid);
      expect(result, isNotNull);
      expect(result!.exists, isTrue);
      
      final data = result.data()!;
      expect(data['id'], equals(uid));
      expect(data['name'], equals('Test User'));
      expect(data['email'], equals('test@example.com'));
      expect((data['createdAt'] as Timestamp).toDate(), equals(fixedTime));
      expect((data['lastUpdatedAt'] as Timestamp).toDate(), equals(fixedTime));
    });

    test('createUserIfMissing - does not create if user exists', () async {
      const uid = 'test-user-123';
      
      // Create existing user with server timestamp
      await firestore.collection('users').doc(uid).set({
        'id': uid,
        'name': 'Existing User',
        'email': 'existing@example.com',
        'phoneNumber': '',
        'profileImageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Try to create user that already exists
      await UserService.createUserIfMissing(
        uid: uid,
        name: 'New User',
        email: 'new@example.com',
      );

      // Verify document wasn't changed
      final doc = await firestore.collection('users').doc(uid).get();
      final data = doc.data()!;
      expect(data['name'], equals('Existing User'));
      expect(data['email'], equals('existing@example.com'));
      expect((data['createdAt'] as Timestamp).toDate(), equals(fixedTime));
      expect((data['lastUpdatedAt'] as Timestamp).toDate(), equals(fixedTime));
    });

    test('createUserIfMissing - creates new user if not exists', () async {
      const uid = 'new-user-123';
      const name = 'New User';
      const email = 'new@example.com';
      
      await UserService.createUserIfMissing(
        uid: uid,
        name: name,
        email: email,
      );

      final doc = await firestore.collection('users').doc(uid).get();
      expect(doc.exists, isTrue);

      final data = doc.data()!;
      expect(data['id'], equals(uid));
      expect(data['name'], equals(name));
      expect(data['email'], equals(email));
      expect(data['phoneNumber'], isEmpty);
      expect(data['profileImageUrl'], isEmpty);
      expect((data['createdAt'] as Timestamp).toDate(), equals(fixedTime));
      expect((data['lastUpdatedAt'] as Timestamp).toDate(), equals(fixedTime));
    });

    test('updateUser - updates user document', () async {
      const uid = 'test-user-123';

      // Create initial user with server timestamp
      await firestore.collection('users').doc(uid).set({
        'id': uid,
        'name': 'Initial Name',
        'email': 'test@example.com',
        'phoneNumber': '',
        'profileImageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Update user
      final updateData = {
        'name': 'Updated Name',
        'phoneNumber': '123-456-7890',
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      };
      await UserService.updateUser(uid, updateData);

      // Verify update
      final doc = await firestore.collection('users').doc(uid).get();
      final data = doc.data()!;
      expect(data['name'], equals('Updated Name'));
      expect(data['phoneNumber'], equals('123-456-7890'));
      expect(data['email'], equals('test@example.com')); // Unchanged field
      
      // Verify timestamps
      expect((data['createdAt'] as Timestamp).toDate(), equals(fixedTime)); // Should not change
      expect((data['lastUpdatedAt'] as Timestamp).toDate(), equals(fixedTime)); // Should be updated
    });
  });
}
